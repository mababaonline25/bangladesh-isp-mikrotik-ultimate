📄 docs/TROUBLESHOOTING.md
markdown
# Troubleshooting Guide

## Common Issues and Solutions for ISP MikroTik Setup

---

## 1. PPPoE Issues

### 1.1 Users Cannot Connect

**Symptoms:**
- User gets "Authentication Failed" error
- PPPoE connection drops immediately
- No IP assigned to user

**Check:**
```bash
# Check PPPoE server status
/interface pppoe-server server print
/interface pppoe-server monitor 0

# Check active sessions
/ppp active print

# Check user authentication
/ppp secret print

# Check logs
/log print where topics~"ppp"
Solutions:

bash
# Restart PPPoE server
/interface pppoe-server server disable 0
/interface pppoe-server server enable 0

# Reset user password
/ppp secret set [find name=username] password=newpassword

# Check VLAN configuration
/interface bridge vlan print
/interface vlan print

# Check firewall rules
/ip firewall filter print where chain=input and in-interface~"PPPoE"
1.2 High Session Count
Symptoms:

Max sessions reached

New users cannot connect

Server performance degraded

Solutions:

bash
# Increase max sessions
/interface pppoe-server server set [find] max-sessions=20000

# Kill idle sessions
/ppp active remove [find idle-time>3600]

# Kill specific user sessions
/ppp active remove [find name=username]

# Kill all sessions (caution!)
/ppp active remove [find]
2. Internet Connectivity Issues
2.1 No Internet Access
Symptoms:

Cannot ping external IPs

DNS resolution fails

Websites not loading

Check:

bash
# Check upstream connection
/ping $upstream1IP
/ping 8.8.8.8
/ping google.com

# Check routes
/ip route print

# Check NAT
/ip firewall nat print

# Check DNS
/ip dns print
/ip dns cache print
Solutions:

bash
# Reset default route
/ip route remove [find dst-address=0.0.0.0/0]
/ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP

# Reset NAT
/ip firewall nat remove [find action=masquerade]
/ip firewall nat add chain=srcnat action=masquerade out-interface=$upstream1Interface

# Reset DNS
/ip dns set servers=8.8.8.8,1.1.1.1
/ip dns cache flush

# Check firewall
/ip firewall filter print where chain=forward
2.2 Intermittent Connectivity
Symptoms:

Connection drops periodically

High latency

Packet loss

Check:

bash
# Check interface stats
/interface monitor-traffic $upstream1Interface

# Check for errors
/interface print where name=$upstream1Interface

# Check logs
/log print where topics~"interface"

# Check CPU usage
/system resource print
Solutions:

bash
# Reset interface
/interface disable $upstream1Interface
/interface enable $upstream1Interface

# Check duplex settings
/interface ethernet set $upstream1Interface auto-negotiation=yes

# Enable flow control
/interface ethernet set $upstream1Interface flow-control=rx-tx

# Check cable/SFP
/system health print
3. RADIUS Issues
3.1 Authentication Fails
Symptoms:

RADIUS timeout errors

"Authentication rejected" message

Users cannot login

Check:

bash
# Check RADIUS status
/radius print
/radius monitor

# Test RADIUS
/radius test username=test password=test

# Check RADIUS logs
/log print where topics~"radius"

# Check PPP AAA
/ppp aaa print
Solutions:

bash
# Restart RADIUS
/radius remove [find]
/radius add address=10.1.200.2 secret=radius-secret service=ppp,hotspot

# Reset AAA settings
/ppp aaa set use-radius=yes accounting=yes interim-update=5m

# Check RADIUS server connectivity
/ping $radiusPrimaryIP

# Check RADIUS server logs (on RADIUS server)
sudo tail -f /var/log/freeradius/radius.log
3.2 Accounting Not Working
Symptoms:

No usage data

Billing not updating

Session time not tracking

Check:

bash
# Check accounting settings
/radius print
/ppp aaa print

# Check RADIUS accounting port
/radius set [find] accounting-port=1813

# Check RADIUS incoming
/radius incoming print
Solutions:

bash
# Enable accounting
/ppp aaa set accounting=yes

# Set interim update
/ppp aaa set interim-update=5m

# Check firewall for RADIUS ports
/ip firewall filter add chain=input protocol=udp dst-port=1812,1813 action=accept
4. Firewall Issues
4.1 Users Can't Access Internet
Symptoms:

Internal users can't browse

Firewall blocking everything

New rules not working

Check:

bash
# Check firewall rules
/ip firewall filter print

# Check NAT rules
/ip firewall nat print

# Check Mangle rules
/ip firewall mangle print

# Check connection tracking
/ip firewall connection print
Solutions:

bash
# Allow established connections
/ip firewall filter add chain=forward action=accept connection-state=established,related# Check default drop rule
/ip firewall filter add chain=forward action=drop

# Reset firewall
/ip firewall filter remove [find]
/ip firewall nat remove [find]
/ip firewall mangle remove [find]

# Add basic rules
/ip firewall filter add chain=input action=accept connection-state=established,related
/ip firewall filter add chain=input action=accept protocol=icmp
/ip firewall filter add chain=input action=drop
/ip firewall filter add chain=forward action=accept connection-state=established,related
/ip firewall filter add chain=forward action=accept
/ip firewall nat add chain=srcnat action=masquerade out-interface=$upstream1Interface
4.2 DDoS Attack
Symptoms:

High CPU usage

Network slowdown

Many connections

Check:

bash
# Check connections
/ip firewall connection print count-only

# Check CPU
/system resource print

# Check interface traffic
/interface monitor-traffic
Solutions:

bash
# Enable DDoS protection rules
/ip firewall raw add chain=prerouting action=drop connection-state=invalid
/ip firewall raw add chain=prerouting action=add-src-to-address-list \
    protocol=tcp psd=21,3s,3,1 address-list=DDOS-BLACKLIST

# Rate limit
/ip firewall filter add chain=forward protocol=tcp tcp-flags=syn \
    connection-limit=25,32 action=drop

# Block blacklisted IPs
/ip firewall filter add chain=forward src-address-list=DDOS-BLACKLIST action=drop

# Enable SYN cookies
/ip firewall connection-tracking set syn-cookies=yes
5. Performance Issues
5.1 High CPU Usage
Symptoms:

CPU > 80%

Slow response

Connection timeouts

Check:

bash
# Check CPU
/system resource print

# Check processes
/tool profile

# Check connections
/ip firewall connection print count-only
Solutions:

bash
# Enable fasttrack
/ip firewall filter add chain=forward action=fasttrack-connection \
    connection-state=established,related

# Reduce firewall rules
# Combine similar rules
# Use address lists

# Upgrade router
# Consider hardware upgrade

# Disable unused services
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
5.2 High Memory Usage
Symptoms:

Free memory < 100MB

Router unstable

Frequent reboots

Check:

bash
# Check memory
/system resource print

# Check processes
/tool profile

# Check connections
/ip firewall connection print count-only
Solutions:

bash
# Flush connections
/ip firewall connection remove [find]

# Reduce connection tracking
/ip firewall connection-tracking set max-entries=50000

# Reduce DNS cache
/ip dns set cache-size=2048KiB

# Disable unnecessary features
/ip proxy set enabled=no
6. VPN Issues
6.1 VPN Connection Fails
Symptoms:

VPN clients cannot connect

Authentication fails

Connection drops

Check:

bash
# Check VPN server status
/interface pptp-server server print
/interface l2tp-server server print
/interface sstp-server server print
/interface ovpn-server server print

# Check firewall rules
/ip firewall filter print where chain=input

# Check logs
/log print where topics~"vpn"
Solutions:

bash
# Enable VPN services
/interface pptp-server server set enabled=yes
/interface l2tp-server server set enabled=yes
/interface sstp-server server set enabled=yes
/interface ovpn-server server set enabled=yes

# Allow VPN ports
/ip firewall filter add chain=input protocol=tcp dst-port=1723 action=accept
/ip firewall filter add chain=input protocol=udp dst-port=1701,500,4500 action=accept

# Check encryption
/ppp profile set [find] use-encryption=required

# Check IPsec configuration
/ip ipsec print
6.2 WireGuard Not Working
Symptoms:

WireGuard interface not up

Peers not connecting

No traffic

Check:

bash
# Check WireGuard interface
/interface wireguard print

# Check peers
/interface wireguard peers print

# Check firewall
/ip firewall filter print where dst-port=13231
Solutions:

bash
# Restart WireGuard
/interface wireguard disable wg-main
/interface wireguard enable wg-main

# Check private key
/interface wireguard set wg-main private-key=YOUR-PRIVATE-KEY

# Check peer configuration
/interface wireguard peers set [find] allowed-address=10.200.0.2/32

# Allow WireGuard port
/ip firewall filter add chain=input protocol=udp dst-port=13231 action=accept
7. Hotspot Issues
7.1 Users Can't Access Hotspot
Symptoms:

No hotspot login page

Users can't authenticate

Slow hotspot

Check:

bash
# Check hotspot status
/ip hotspot print

# Check hotspot profile
/ip hotspot profile print

# Check active users
/ip hotspot active print

# Check logs
/log print where topics~"hotspot"
Solutions:

bash
# Restart hotspot
/ip hotspot disable hotspot1
/ip hotspot enable hotspot1

# Check DHCP
/ip dhcp-server print

# Check DNS
/ip dns print
/ip dns cache flush

# Reset hotspot
/ip hotspot remove [find]
/ip hotspot add name=hotspot1 interface=vlan100-Hotspot address-pool=dhcp-pool-hotspot
7.2 Walled Garden Not Working
Symptoms:

Blocked sites not accessible

Walled garden rules not applying

Check:

bash
# Check walled garden rules
/ip hotspot walled-garden ip print
/ip hotspot walled-garden print

# Check DNS
/ip dns print
Solutions:

bash
# Add walled garden rules
/ip hotspot walled-garden ip add dst-address=8.8.8.8 action=accept
/ip hotspot walled-garden add dst-host=*.google.com action=accept

# Check order of rules
/ip hotspot walled-garden ip move [find] 0

# Clear DNS cache
/ip dns cache flush
8. Backup & Recovery Issues
8.1 Backup Fails
Symptoms:

No backup files

Backup script errors

Insufficient space

Check:

bash
# Check disk space
/system resource print

# Check backup files
/file print

# Check scheduler
/system scheduler print
Solutions:

bash
# Free disk space
/file remove [find name="*.backup" before=7d]
/file remove [find name="*.rsc" before=7d]

# Manual backup
/export file=manual-backup.rsc
/system backup save name=manual-backup.backup

# Check scheduler
/system scheduler enable daily-backup
/system scheduler run daily-backup
8.2 Restore Fails
Symptoms:

Restore errors

Configuration missing

Router unstable

Solutions:

bash
# Restore from backup
/system backup load name=backup-file.backup

# Import RSC
/import backup-file.rsc

# Check backup integrity
/file print backup-file.rsc

# If restore fails, use Netinstall
# Reinstall RouterOS and restore from backup
9. Monitoring & Alert Issues
9.1 Email Alerts Not Working
Symptoms:

No email notifications

Email server errors

Check:

bash
# Check email configuration
/tool e-mail print

# Test email
/tool e-mail send to=admin@isp.com subject=Test body=Test
Solutions:

bash
# Configure email
/tool e-mail set server=10.99.0.10 port=25 from=noc@isp.com

# Check logs
/log print where topics~"email"

# Check firewall
/ip firewall filter add chain=input protocol=tcp dst-port=25 action=accept
10. Emergency Procedures
10.1 Emergency Reboot
bash
/system reboot
10.2 Safe Mode
bash
# Enter safe mode (WinBox)
# Changes are automatically rolled back if session disconnected

# Or via CLI
/system reboot
# Press any key during boot to enter safe mode
10.3 Emergency Reset
bash
# Reset configuration
/system reset-configuration

# Reset with keep users
/system reset-configuration keep-users=yes

# Factory reset
/system reset-configuration no-defaults=yes
10.4 Emergency Recovery (Netinstall)
Download Netinstall from MikroTik website

Configure Netinstall with:

IP: 192.168.88.1

Netmask: 255.255.255.0

Hold reset button while powering on

Wait for LED to blink

Release reset button

Install RouterOS

Restore from backup

<div align="center"> 🔧 [Back to Top](#troubleshooting-guide) </div> ```