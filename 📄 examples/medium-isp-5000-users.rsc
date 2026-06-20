###############################################################################
# EXAMPLE: MEDIUM ISP - 5,000 USERS
# Version: 5.0.0
# Description: Configuration for medium ISP with up to 5,000 users
# Hardware: CCR1036 or CCR1072
# Bandwidth: 5Gbps Upstream + BDIX
###############################################################################

:log info "================================================"
:log info "MEDIUM ISP CONFIGURATION (5,000 USERS)"
:log info "================================================"

# ============================================================================
# BASIC CONFIGURATION
# ============================================================================

/system identity set name="Medium-ISP-Dhaka"
/system clock set time-zone-name=Asia/Dhaka

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

# Bridges
/interface bridge add name=bridge-local protocol-mode=none
/interface bridge add name=bridge-mgmt protocol-mode=none

# Bonding (Optional)
/interface bonding add name=bond1 mode=802.3ad slaves=sfp-sfpplus1,sfp-sfpplus2 lacp-rate=1s

# VLANs
/interface vlan add name=vlan10-PPPoE vlan-id=10 interface=bridge-local
/interface vlan add name=vlan20-MGMT vlan-id=20 interface=bridge-local
/interface vlan add name=vlan30-Voice vlan-id=30 interface=bridge-local
/interface vlan add name=vlan40-B2B vlan-id=40 interface=bridge-local
/interface vlan add name=vlan50-Guest vlan-id=50 interface=bridge-local
/interface vlan add name=vlan60-IPTV vlan-id=60 interface=bridge-local
/interface vlan add name=vlan70-Storage vlan-id=70 interface=bridge-local
/interface vlan add name=vlan99-OOB vlan-id=99 interface=bridge-mgmt
/interface vlan add name=vlan100-Hotspot vlan-id=100 interface=bridge-local

# IP Addresses
/ip address add address=192.168.20.1/24 interface=vlan20-MGMT
/ip address add address=10.10.0.1/16 interface=vlan10-PPPoE
/ip address add address=10.30.0.1/24 interface=vlan30-Voice
/ip address add address=10.40.0.1/24 interface=vlan40-B2B
/ip address add address=10.50.0.1/24 interface=vlan50-Guest
/ip address add address=10.60.0.1/24 interface=vlan60-IPTV
/ip address add address=10.70.0.1/24 interface=vlan70-Storage
/ip address add address=10.99.0.1/24 interface=vlan99-OOB
/ip address add address=10.100.0.1/24 interface=vlan100-Hotspot

# Upstream IPs
/ip address add address=103.xxx.xxx.2/30 interface=sfp-sfpplus1
/ip address add address=103.yyy.yyy.2/30 interface=sfp-sfpplus2
/ip address add address=172.16.100.2/30 interface=sfp-sfpplus3

# ============================================================================
# DHCP CONFIGURATION
# ============================================================================

/ip pool add name=dhcp-pool-mgmt ranges=192.168.20.10-192.168.20.250
/ip pool add name=dhcp-pool-b2b ranges=10.40.0.10-10.40.0.250
/ip pool add name=dhcp-pool-guest ranges=10.50.0.10-10.50.0.250
/ip pool add name=dhcp-pool-voice ranges=10.30.0.10-10.30.0.250
/ip pool add name=dhcp-pool-iptv ranges=10.60.0.10-10.60.0.250
/ip pool add name=dhcp-pool-storage ranges=10.70.0.10-10.70.0.250
/ip pool add name=dhcp-pool-oob ranges=10.99.0.10-10.99.0.250
/ip pool add name=dhcp-pool-hotspot ranges=10.100.0.10-10.100.0.250

/ip dhcp-server add name=dhcp-mgmt interface=vlan20-MGMT address-pool=dhcp-pool-mgmt
/ip dhcp-server add name=dhcp-b2b interface=vlan40-B2B address-pool=dhcp-pool-b2b
/ip dhcp-server add name=dhcp-guest interface=vlan50-Guest address-pool=dhcp-pool-guest
/ip dhcp-server add name=dhcp-voice interface=vlan30-Voice address-pool=dhcp-pool-voice
/ip dhcp-server add name=dhcp-iptv interface=vlan60-IPTV address-pool=dhcp-pool-iptv
/ip dhcp-server add name=dhcp-storage interface=vlan70-Storage address-pool=dhcp-pool-storage
/ip dhcp-server add name=dhcp-oob interface=vlan99-OOB address-pool=dhcp-pool-oob
/ip dhcp-server add name=dhcp-hotspot interface=vlan100-Hotspot address-pool=dhcp-pool-hotspot

/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.40.0.0/24 gateway=10.40.0.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.50.0.0/24 gateway=10.50.0.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.30.0.0/24 gateway=10.30.0.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.60.0.0/24 gateway=10.60.0.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.70.0.0/24 gateway=10.70.0.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.99.0.0/24 gateway=10.99.0.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.100.0.0/24 gateway=10.100.0.1 dns-server=8.8.8.8

# ============================================================================
# PPPOE CONFIGURATION
# ============================================================================

/ip pool add name=pppoe-pool ranges=10.10.1.2-10.10.255.254

# Speed Profiles
:local speeds { "5"; "10"; "20"; "30"; "40"; "50"; "60"; "70"; "80"; "90"; "100"; "120"; "140"; "160"; "180"; "200"; "300"; "500"; "700"; "1000" }
:foreach speed in=$speeds do={
    /ppp profile add name="PKG-$speed-MBPS" local-address=10.10.0.1 remote-address=pppoe-pool \
        rate-limit="$speed"."M/$speed"."M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes
}

/ppp profile add name="PKG-UNLIMITED" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="0/0" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

# BDIX Packages
/ppp profile add name="PKG-BDIX-20" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="20M/20M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/ppp profile add name="PKG-BDIX-50" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="50M/50M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/ppp profile add name="PKG-BDIX-100" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="100M/100M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

# PPPoE Server
/interface pppoe-server server add service-name="Medium-ISP-PPPoE" interface=vlan10-PPPoE \
    one-session-per-host=yes max-sessions=10000

# ============================================================================
# RADIUS CONFIGURATION
# ============================================================================

/radius add address=10.1.200.2 secret=radius-secret service=ppp,hotspot
/radius add address=10.1.200.3 secret=radius-secret service=ppp,hotspot

/radius incoming set accept=yes port=3799
/ppp aaa set use-radius=yes accounting=yes interim-update=5m
/ppp profile add name="radius-default" use-radius=yes
/ppp profile add name="radius-premium" use-radius=yes
/ppp profile add name="radius-business" use-radius=yes

# ============================================================================
# HOTSPOT CONFIGURATION
# ============================================================================

/ip hotspot profile add name=hotspot-profile hotspot-address=10.100.0.1 \
    dns-name="hotspot.medium-isp.com" login-by=http-chap,http-pap,https,cookie,trial \
    radius-accounting=yes radius-interim-update=2m use-radius=yes

/ip hotspot add name=hotspot1 interface=vlan100-Hotspot address-pool=dhcp-pool-hotspot \
    profile=hotspot-profile

/ip hotspot walled-garden ip add dst-address=8.8.8.8 action=accept
/ip hotspot walled-garden ip add dst-address=1.1.1.1 action=accept
/ip hotspot walled-garden add dst-host=*.google.com action=accept
/ip hotspot walled-garden add dst-host=*.facebook.com action=accept
/ip hotspot walled-garden add dst-host=*.apple.com action=accept
/ip hotspot walled-garden add dst-host=*.microsoft.com action=accept

/ip hotspot user add name=guest1 password=guest123
/ip hotspot user add name=guest2 password=guest456
/ip hotspot user add name=premium1 password=premium123

# ============================================================================
# VPN CONFIGURATION
# ============================================================================

/ip pool add name=vpn-pool ranges=10.20.1.2-10.20.255.254

/ppp profile add name="vpn-10mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="10M/10M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

/ppp profile add name="vpn-20mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="20M/20M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

/ppp profile add name="vpn-50mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="50M/50M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

/ppp profile add name="vpn-100mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="100M/100M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

/interface pptp-server server set enabled=yes authentication=mschap1,mschap2
/interface l2tp-server server set enabled=yes authentication=mschap1,mschap2 ipsec-secret=VPN-IPSEC-SECRET
/interface sstp-server server set enabled=yes authentication=mschap1,mschap2
/interface ovpn-server server set enabled=yes auth=sha1 cipher=aes256

/ppp secret add name=vpnuser1 password=pass123 profile=vpn-20mbps service=pptp,l2tp,sstp,ovpn
/ppp secret add name=vpnuser2 password=pass456 profile=vpn-50mbps service=pptp,l2tp,sstp,ovpn

# ============================================================================
# FIREWALL CONFIGURATION
# ============================================================================

/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.40.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.99.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=103.0.0.0/8 list=BDIX-NETWORKS
/ip firewall address-list add address=202.0.0.0/8 list=BDIX-NETWORKS

# RAW Rules
/ip firewall raw
add action=drop chain=prerouting connection-state=invalid
add action=drop chain=prerouting protocol=tcp src-port=0
add action=drop chain=prerouting protocol=udp src-port=0
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,syn
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,rst
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,!ack
add action=drop chain=prerouting protocol=tcp tcp-flags=syn,rst
add action=drop chain=prerouting protocol=icmp packet-size=1025-65535
add action=drop chain=prerouting ipv4-options=any

# DDoS Protection
add action=add-src-to-address-list chain=prerouting protocol=tcp psd=21,3s,3,1 \
    address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=tcp tcp-flags=syn \
    connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=udp \
    connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=icmp limit=5,5 \
    address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=drop chain=prerouting src-address-list=DDOS-BLACKLIST

# Filter Rules
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=input protocol=icmp
add action=accept chain=input src-address-list=TRUSTED-NETWORKS
add action=accept chain=input in-interface=vlan10-PPPoE
add action=accept chain=input in-interface=vlan100-Hotspot
add action=accept chain=input protocol=tcp dst-port=1723,1701,443,1194
add action=accept chain=input protocol=ospf
add action=accept chain=input protocol=tcp dst-port=179
add action=drop chain=input

add action=fasttrack-connection chain=forward connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=forward out-interface=sfp-sfpplus1
add action=accept chain=forward out-interface=sfp-sfpplus2
add action=accept chain=forward src-address=10.0.0.0/8 dst-address=10.0.0.0/8
add action=drop chain=forward src-address=10.50.0.0/24 dst-address=10.0.0.0/8
add action=drop chain=forward

# NAT
/ip firewall nat
add action=masquerade chain=srcnat out-interface=sfp-sfpplus1
add action=masquerade chain=srcnat out-interface=sfp-sfpplus2

# ============================================================================
# ROUTING
# ============================================================================

# Default Routes
/ip route add dst-address=0.0.0.0/0 gateway=103.xxx.xxx.1 distance=1 check-gateway=ping
/ip route add dst-address=0.0.0.0/0 gateway=103.yyy.yyy.1 distance=2 check-gateway=ping

# BDIX Routes
/ip route add dst-address=103.0.0.0/8 gateway=172.16.100.1 distance=1
/ip route add dst-address=202.0.0.0/8 gateway=172.16.100.1 distance=1
/ip route add dst-address=110.0.0.0/8 gateway=172.16.100.1 distance=1

# ============================================================================
# FAILOVER & LOAD BALANCING
# ============================================================================

/routing table add name=to-wan1 fib
/routing table add name=to-wan2 fib

/ip route add dst-address=0.0.0.0/0 gateway=103.xxx.xxx.1 routing-mark=to-wan1 distance=1
/ip route add dst-address=0.0.0.0/0 gateway=103.yyy.yyy.1 routing-mark=to-wan2 distance=1

/ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan1-conn per-connection-classifier=src-address-and-port:2/0
/ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan2-conn per-connection-classifier=src-address-and-port:2/1
/ip firewall mangle add chain=prerouting connection-mark=wan1-conn action=mark-routing new-routing-mark=to-wan1
/ip firewall mangle add chain=prerouting connection-mark=wan2-conn action=mark-routing new-routing-mark=to-wan2

# ============================================================================
# QoS CONFIGURATION
# ============================================================================

/queue type add name="pcq-download" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="pcq-upload" kind=pcq pcq-rate=0 pcq-classifier=src-address
/queue type add name="pcq-premium-download" kind=pcq pcq-rate=100M pcq-classifier=dst-address
/queue type add name="pcq-premium-upload" kind=pcq pcq-rate=100M pcq-classifier=src-address

/queue tree
add name="TOTAL_UPLOAD" parent=global packet-mark=upload queue=pcq-upload
add name="TOTAL_DOWNLOAD" parent=global packet-mark=download queue=pcq-download
add name="PPPOE_UPLOAD" parent=TOTAL_UPLOAD packet-mark=upload-pppoe queue=pcq-upload
add name="PPPOE_DOWNLOAD" parent=TOTAL_DOWNLOAD packet-mark=download queue=pcq-download

/queue simple add name="TOTAL-LIMIT" target=sfp-sfpplus1 max-limit=4500M/4500M
/queue simple add name="BACKUP-LIMIT" target=sfp-sfpplus2 max-limit=4500M/4500M

# ============================================================================
# OSPF CONFIGURATION
# ============================================================================

/routing ospf instance set [find] router-id=192.168.20.1
/routing ospf area add name=backbone area-id=0.0.0.0
/routing ospf interface add interface=bridge-local area=backbone passive=yes
/routing ospf interface add interface=sfp-sfpplus1 area=backbone network-type=point-to-point
/routing ospf interface add interface=sfp-sfpplus2 area=backbone network-type=point-to-point
/routing ospf interface add interface=sfp-sfpplus3 area=backbone network-type=point-to-point

# ============================================================================
# DNS
# ============================================================================

/ip dns set servers=8.8.8.8,1.1.1.1,8.8.4.4
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=20480KiB

# ============================================================================
# SYSTEM
# ============================================================================

/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip service set winbox address=192.168.20.0/24,10.99.0.0/24
/ip service set ssh address=192.168.20.0/24,10.99.0.0/24

# ============================================================================
# MONITORING & BACKUP
# ============================================================================

/tool netwatch add host=8.8.8.8 interval=10s timeout=2s \
    up-script=":log info \"INTERNET-UP\"" \
    down-script=":log warning \"INTERNET-DOWN\""

/system script add name=health-check source={
    :local cpu [/system resource get cpu-load]
    :local mem [/system resource get free-memory]
    :if ($cpu > 80) do={:log warning "HIGH-CPU: $cpu%"}
    :if ($mem < 100000000) do={:log warning "LOW-MEMORY"}
}

/system scheduler add name=health-check interval=5m on-event=health-check
/system scheduler add name=daily-backup start-time=02:00:00 interval=1d on-event={
    /export file=backup-([/system clock get date]).rsc
    /system backup save name=backup-([/system clock get date]).backup
}

# ============================================================================
# COMPLETION
# ============================================================================

:log info "================================================"
:log info "MEDIUM ISP CONFIGURATION COMPLETE"
:log info "Management IP: 192.168.20.1"
:log info "PPPoE Service: Medium-ISP-PPPoE"
:log info "RADIUS: Enabled (10.1.200.2)"
:log info "BDIX: Enabled (172.16.100.1)"
:log info "VPN: PPTP/L2TP/SSTP/OpenVPN"
:log info "Hotspot: vlan100-Hotspot"
:log info "================================================"