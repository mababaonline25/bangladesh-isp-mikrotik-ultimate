📄 docs/SECURITY-BEST-PRACTICES.md
markdown
# Security Best Practices

## Comprehensive Security Guide for ISP MikroTik Setup

---

## 1. Introduction

This document provides security best practices for securing MikroTik routers in an ISP environment. Following these practices will help protect your network from threats and ensure service reliability.

---

## 2. Access Control

### 2.1 Strong Passwords

**Requirements:**
- Minimum 12 characters
- Mix of uppercase and lowercase
- Include numbers and special characters
- Change every 90 days
- No dictionary words

**Example:**
```bash
/user set admin password="Sr@$h!nGp@$$w0rD2024"
2.2 User Management
bash
# Create different user levels
/user add name=admin group=full password=strong-pass
/user add name=network-admin group=write password=strong-pass
/user add name=monitoring group=read password=strong-pass

# Restrict admin access
/ip service set winbox address=192.168.20.0/24,10.99.0.0/24
/ip service set ssh address=192.168.20.0/24,10.99.0.0/24
2.3 SSH Hardening
bash
# Enable strong crypto
/ip ssh set strong-crypto=yes

# Set host key size
/ip ssh set host-key-size=4096

# Disable weak algorithms
/ip ssh set allow-none-crypto=no

# Use key-based authentication
/user ssh-keys add user=admin public-key-file=admin-key.pub
2.4 Two-Factor Authentication
bash
# Enable OTP (if supported)
/user set admin otp-secret=YOUR_SECRET

# Use external authentication
/radius add address=10.1.200.2 secret=radius-secret service=login
/user aaa set use-radius=yes
3. Network Security
3.1 Firewall Configuration
bash
# Default deny policy
/ip firewall filter add chain=input action=drop
/ip firewall filter add chain=forward action=drop

# Allow established connections
/ip firewall filter add chain=input action=accept connection-state=established,related
/ip firewall filter add chain=forward action=accept connection-state=established,related

# Allow management networks
/ip firewall address-list add address=192.168.20.0/24 list=MGMT-NETWORKS
/ip firewall filter add chain=input action=accept src-address-list=MGMT-NETWORKS

# Block invalid packets
/ip firewall raw add chain=prerouting action=drop connection-state=invalid
3.2 DDoS Protection
bash
# SYN flood protection
/ip firewall raw add chain=prerouting protocol=tcp tcp-flags=syn \
    action=add-src-to-address-list address-list=DDOS-BLACKLIST \
    connection-limit=25,32 address-list-timeout=1h

# UDP flood protection
/ip firewall raw add chain=prerouting protocol=udp \
    action=add-src-to-address-list address-list=DDOS-BLACKLIST \
    connection-limit=25,32 address-list-timeout=1h

# ICMP flood protection
/ip firewall raw add chain=prerouting protocol=icmp limit=5,5 \
    action=add-src-to-address-list address-list=DDOS-BLACKLIST \
    address-list-timeout=1h

# Block blacklisted
/ip firewall raw add chain=prerouting src-address-list=DDOS-BLACKLIST action=drop
3.3 Port Scanning Protection
bash
# Detect port scans
/ip firewall raw add chain=prerouting protocol=tcp psd=21,3s,3,1 \
    action=add-src-to-address-list address-list=SCAN-BLACKLIST \
    address-list-timeout=1h

# Block scanners
/ip firewall raw add chain=prerouting src-address-list=SCAN-BLACKLIST action=drop
3.4 VLAN Security
bash
# Enable VLAN filtering
/interface bridge set bridge-local vlan-filtering=yes

# Restrict VLAN access
/interface bridge vlan add bridge=bridge-local vlan-ids=10-120 tagged=bridge-local
/interface bridge vlan add bridge=bridge-local vlan-ids=20 untagged=ether1

# Isolate guest networks
/ip firewall filter add chain=forward src-address=10.50.0.0/24 dst-address=10.0.0.0/8 action=drop
4. Service Security
4.1 Disable Unused Services
bash
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
4.2 Secure Management Services
bash
# Use HTTPS
/certificate add name=web-cert common-name=router.local
/ip service set www-ssl certificate=web-cert
/ip service set www-ssl disabled=no

# Secure WinBox
/ip service set winbox address=192.168.20.0/24,10.99.0.0/24

# Secure SSH
/ip service set ssh address=192.168.20.0/24,10.99.0.0/24 port=22
4.3 VPN Security
bash
# Use strong encryption
/ppp profile set [find] use-encryption=required

# IPsec configuration
/ip ipsec proposal add auth-algorithms=sha256 enc-algorithms=aes-256-cbc

# Restrict VPN access
/ip firewall filter add chain=input src-address-list=VPN-USERS action=accept
5. Data Security
5.1 Logging
bash
# Enable comprehensive logging
/system logging add topics=info,error,warning action=memory
/system logging add topics=firewall,info action=memory
/system logging add topics=ppp,info action=memory
/system logging add topics=radius,info action=memory

# Send logs to remote server
/system logging add topics=info action=remote server=10.99.0.10
5.2 Backup Encryption
bash
# Encrypt backup
/system backup save name=backup.backup password=encryption-pass

# Secure export
/export file=backup.rsc
/certificate export passphrase=export-pass
5.3 Secure Protocols
bash
# Use secure protocols
/ip ftp set disabled=yes
/ip ssh set strong-crypto=yes
/ip service set www-ssl certificate=web-cert

# Enable HTTPS for WebFig
/ip service set www-ssl disabled=no
6. Network Monitoring
6.1 Real-time Monitoring
bash
# Enable SNMP
/snmp set enabled=yes
/snmp set contact=admin@isp.com
/snmp set location=Main-DC

# Set community
/snmp community add name=public addresses=10.99.0.0/24 read-only=yes
/snmp community add name=private addresses=192.168.20.0/24 read-write=yes
6.2 Intrusion Detection
bash
# Monitor failed logins
/ip firewall filter add chain=input protocol=tcp dst-port=22 \
    action=add-src-to-address-list address-list=SSH-BLACKLIST \
    connection-state=new src-address-list=!MGMT-NETWORKS

# Monitor port scans
/ip firewall raw add chain=prerouting protocol=tcp psd=21,3s,3,1 \
    action=add-src-to-address-list address-list=SCAN-BLACKLIST
6.3 Alerts
bash
# Email alerts
/tool e-mail set server=10.99.0.10 port=25 from=noc@isp.com
/tool e-mail send to=admin@isp.com subject="Alert" body="Security event"

# Script for alerts
/system script add name=security-alert source={
    :log warning "SECURITY ALERT: $1"
    /tool e-mail send to=admin@isp.com subject="Security Alert" body="$1"
}
7. Regular Maintenance
7.1 Updates
bash
# Check for updates
/system package update check-for-updates

# Download updates
/system package update download

# Install updates
/system package update install

# Schedule updates
/system scheduler add name=update-check interval=7d on-event="/system package update check-for-updates"
7.2 Security Audits
bash
# Run security audit
/system script run security-audit

# Check configuration
/export

# Check open ports
/ip service print
/ip firewall filter print
7.3 Password Rotation
bash
# Create script for password rotation
/system script add name=rotate-passwords source={
    # Change admin password
    /user set admin password=new-strong-password
    
    # Change PPPoE users (if needed)
    # /ppp secret set [find] password=new-password
}

# Schedule rotation
/system scheduler add name=password-rotation interval=90d on-event=rotate-passwords
8. Disaster Recovery
8.1 Backup Strategy
bash
# Daily backup
/system scheduler add name=daily-backup start-time=02:00:00 interval=1d on-event={
    /export file=backup-([/system clock get date]).rsc
    /system backup save name=backup-([/system clock get date]).backup
}

# Weekly backup
/system scheduler add name=weekly-backup start-time=03:00:00 interval=7d on-event={
    /export file=backup-weekly-([/system clock get date]).rsc
    /system backup save name=backup-weekly-([/system clock get date]).backup
}

# Offsite backup
/system scheduler add name=offsite-backup start-time=04:00:00 interval=1d on-event={
    /tool fetch url="ftp://backup-server/backup/" file=backup-([/system clock get date]).backup
}
8.2 Recovery Plan
bash
# 1. Identify the issue
# 2. Isolate affected systems
# 3. Restore from backup
/system backup load name=backup-file.backup

# 4. Verify configuration
/export

# 5. Test connectivity
/ping 8.8.8.8
/ping google.com

# 6. Monitor logs
/log print
9. Compliance
9.1 PCI-DSS Requirements
bash
# Strong encryption
/ip service set www-ssl certificate=web-cert
/ip ssh set strong-crypto=yes

# Access control
/ip service set winbox address=192.168.20.0/24
/ip service set ssh address=192.168.20.0/24

# Logging
/system logging add topics=info action=remote server=10.99.0.10
9.2 GDPR Requirements
bash
# Data protection
/ppp secret set [find] password=strong-password
/radius set [find] secret=strong-secret

# Access logging
/system logging add topics=ppp,info action=memory
/system logging add topics=radius,info action=memory
9.3 Local Regulations
bash
# Bangladesh IT Act compliance
# Maintain logs for 6 months
/system logging set [find] action=disk
/system logging add topics=info action=disk file-size=100MB files=10
10. Security Checklist
Daily
Check system logs

Monitor network traffic

Verify backup status

Check CPU/memory usage

Review firewall logs

Weekly
Run security audit

Check for updates

Review user accounts

Test backup restoration

Review security alerts

Monthly
Change passwords

Update documentation

Review firewall rules

Check compliance requirements

Test disaster recovery

Quarterly
Full security review

Penetration testing

Update security policies

Review vendor security

Update incident response plan

<div align="center"> 🛡️ [Back to Top](#security-best-practices) </div> ```