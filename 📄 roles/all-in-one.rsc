###############################################################################
# ROLE: ALL-IN-ONE
# Version: 5.0.0
# Description: Complete ISP configuration for small to medium ISPs
# Hardware: RB1100AHx4, CCR1009, CCR1036
# User Capacity: Up to 5,000 users
# Features: PPPoE, Hotspot, VPN, Firewall, QoS, BDIX, Failover
###############################################################################

:log info "================================================"
:log info "ROLE: ALL-IN-ONE ISP CONFIGURATION"
:log info "================================================"

# ============================================================================
# SYSTEM BASE CONFIGURATION
# ============================================================================

/system identity set name="$companyName-AllInOne"
/system clock set time-zone-name=Asia/Dhaka

# NTP
/system ntp client set enabled=yes
/system ntp client servers add address=time.google.com
/system ntp client servers add address=pool.ntp.org
/system ntp client servers add address=bd.pool.ntp.org

# DNS
/ip dns set servers=8.8.8.8,1.1.1.1,8.8.4.4
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=20480KiB

# ============================================================================
# INTERFACES & BRIDGES
# ============================================================================

/interface bridge add name=bridge-local protocol-mode=none fast-forward=yes
/interface bridge add name=bridge-mgmt protocol-mode=none

# Add all ports to bridge
/interface bridge port add bridge=bridge-local interface=ether1
/interface bridge port add bridge=bridge-local interface=ether2
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus1
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus2
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus3
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus4

# ============================================================================
# VLAN CONFIGURATION
# ============================================================================

/interface vlan add name="vlan$vlanPPPoE-PPPoE" vlan-id=$vlanPPPoE interface=bridge-local
/interface vlan add name="vlan$vlanManagement-MGMT" vlan-id=$vlanManagement interface=bridge-local
/interface vlan add name="vlan$vlanVoice-VOICE" vlan-id=$vlanVoice interface=bridge-local
/interface vlan add name="vlan$vlanB2B-B2B" vlan-id=$vlanB2B interface=bridge-local
/interface vlan add name="vlan$vlanGuest-GUEST" vlan-id=$vlanGuest interface=bridge-local
/interface vlan add name="vlan$vlanIPTV-IPTV" vlan-id=$vlanIPTV interface=bridge-local
/interface vlan add name="vlan$vlanStorage-STORAGE" vlan-id=$vlanStorage interface=bridge-local
/interface vlan add name="vlan$vlanMgmt-OOB" vlan-id=$vlanMgmt interface=bridge-mgmt
/interface vlan add name="vlan$vlanHotspot-HOTSPOT" vlan-id=$vlanHotspot interface=bridge-local

# ============================================================================
# IP ADDRESSING
# ============================================================================

/ip address add address=192.168.20.1/24 interface="vlan$vlanManagement-MGMT"
/ip address add address=10.40.0.1/24 interface="vlan$vlanB2B-B2B"
/ip address add address=10.50.0.1/24 interface="vlan$vlanGuest-GUEST"
/ip address add address=10.30.0.1/24 interface="vlan$vlanVoice-VOICE"
/ip address add address=10.60.0.1/24 interface="vlan$vlanIPTV-IPTV"
/ip address add address=10.70.0.1/24 interface="vlan$vlanStorage-STORAGE"
/ip address add address=10.99.0.1/24 interface="vlan$vlanMgmt-OOB"
/ip address add address=10.100.0.1/24 interface="vlan$vlanHotspot-HOTSPOT"
/ip address add address=10.10.0.1/16 interface="vlan$vlanPPPoE-PPPoE"

# Upstream IPs
/ip address add address=$upstream1IP/30 interface=$upstream1Interface
:if ($enableFailover = "yes") do={
    /ip address add address=$upstream2IP/30 interface=$upstream2Interface
}
:if ($enableBDIX = "yes") do={
    /ip address add address=$bdixPeerIP/30 interface=$bdixPeerInterface
}

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

/ip dhcp-server add name=dhcp-mgmt interface="vlan$vlanManagement-MGMT" address-pool=dhcp-pool-mgmt
/ip dhcp-server add name=dhcp-b2b interface="vlan$vlanB2B-B2B" address-pool=dhcp-pool-b2b
/ip dhcp-server add name=dhcp-guest interface="vlan$vlanGuest-GUEST" address-pool=dhcp-pool-guest
/ip dhcp-server add name=dhcp-voice interface="vlan$vlanVoice-VOICE" address-pool=dhcp-pool-voice
/ip dhcp-server add name=dhcp-iptv interface="vlan$vlanIPTV-IPTV" address-pool=dhcp-pool-iptv
/ip dhcp-server add name=dhcp-storage interface="vlan$vlanStorage-STORAGE" address-pool=dhcp-pool-storage
/ip dhcp-server add name=dhcp-oob interface="vlan$vlanMgmt-OOB" address-pool=dhcp-pool-oob
/ip dhcp-server add name=dhcp-hotspot interface="vlan$vlanHotspot-HOTSPOT" address-pool=dhcp-pool-hotspot

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

# Default Profile
/ppp profile add name="pppoe-default" local-address=10.10.0.1 remote-address=pppoe-pool \
    dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

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
/interface pppoe-server server add service-name="$companyName-PPPoE" interface="vlan$vlanPPPoE-PPPoE" \
    one-session-per-host=yes max-sessions=5000

# ============================================================================
# RADIUS CONFIGURATION
# ============================================================================

:if ($useRadius = "yes") do={
    /radius add address=$radiusPrimaryIP secret=$radiusPrimarySecret service=ppp,hotspot
    /radius add address=$radiusBackupIP secret=$radiusBackupSecret service=ppp,hotspot
    
    /radius incoming set accept=yes port=3799
    /ppp aaa set use-radius=yes accounting=yes interim-update=5m
    /ppp profile add name="radius-default" use-radius=yes
}

# ============================================================================
# HOTSPOT CONFIGURATION
# ============================================================================

:if ($enableHotspot = "yes") do={
    /ip hotspot profile add name=hotspot-profile hotspot-address=10.100.0.1 \
        dns-name="hotspot.$companyName.com" login-by=http-chap,http-pap,cookie,trial
    
    /ip hotspot add name=hotspot1 interface="vlan$vlanHotspot-HOTSPOT" \
        address-pool=dhcp-pool-hotspot profile=hotspot-profile
    
    /ip hotspot walled-garden ip add dst-address=8.8.8.8 action=accept
    /ip hotspot walled-garden ip add dst-address=1.1.1.1 action=accept
    /ip hotspot walled-garden add dst-host=*.google.com action=accept
    /ip hotspot walled-garden add dst-host=*.facebook.com action=accept
    
    /ip hotspot user add name=guest1 password=guest123
    /ip hotspot user add name=guest2 password=guest456
}

# ============================================================================
# VPN CONFIGURATION
# ============================================================================

:if ($enableVPN = "yes") do={
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
}

# ============================================================================
# FIREWALL CONFIGURATION
# ============================================================================

# Address Lists
/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.40.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.99.0.0/24 list=TRUSTED-NETWORKS
:if ($enableBDIX = "yes") do={
    /ip firewall address-list add address=103.0.0.0/8 list=BDIX-NETWORKS
    /ip firewall address-list add address=202.0.0.0/8 list=BDIX-NETWORKS
}

# RAW Rules
/ip firewall raw
add action=drop chain=prerouting connection-state=invalid
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,syn
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,rst
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,!ack
add action=drop chain=prerouting protocol=tcp tcp-flags=syn,rst
add action=drop chain=prerouting ipv4-options=any

# DDoS Protection
add action=add-src-to-address-list chain=prerouting protocol=tcp psd=21,3s,3,1 \
    address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=tcp tcp-flags=syn \
    connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=drop chain=prerouting src-address-list=DDOS-BLACKLIST

# Filter Rules - Input
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=input protocol=icmp
add action=accept chain=input src-address-list=TRUSTED-NETWORKS
add action=accept chain=input in-interface="vlan$vlanPPPoE-PPPoE"
add action=accept chain=input in-interface="vlan$vlanHotspot-HOTSPOT"
add action=accept chain=input protocol=tcp dst-port=1723,1701,443,1194
add action=drop chain=input

# Filter Rules - Forward
add action=fasttrack-connection chain=forward connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=forward out-interface=$upstream1Interface
:if ($enableFailover = "yes") do={
    add action=accept chain=forward out-interface=$upstream2Interface
}
add action=accept chain=forward src-address=10.0.0.0/8 dst-address=10.0.0.0/8
add action=drop chain=forward src-address=10.50.0.0/24 dst-address=10.0.0.0/8
add action=drop chain=forward

# NAT
/ip firewall nat
add action=masquerade chain=srcnat out-interface=$upstream1Interface
:if ($enableFailover = "yes") do={
    add action=masquerade chain=srcnat out-interface=$upstream2Interface
}

# ============================================================================
# ROUTING
# ============================================================================

/ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP distance=1 check-gateway=ping
:if ($enableFailover = "yes") do={
    /ip route add dst-address=0.0.0.0/0 gateway=$upstream2IP distance=2 check-gateway=ping
}
:if ($enableBDIX = "yes") do={
    /ip route add dst-address=103.0.0.0/8 gateway=$bdixPeerIP distance=1
    /ip route add dst-address=202.0.0.0/8 gateway=$bdixPeerIP distance=1
}

# ============================================================================
# QoS CONFIGURATION
# ============================================================================

/queue type add name="pcq-download" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="pcq-upload" kind=pcq pcq-rate=0 pcq-classifier=src-address

/queue tree
add name="TOTAL_UPLOAD" parent=global packet-mark=upload queue=pcq-upload
add name="TOTAL_DOWNLOAD" parent=global packet-mark=download queue=pcq-download

/queue simple add name="TOTAL-LIMIT" target=$upstream1Interface max-limit=9500M/9500M

# ============================================================================
# SYSTEM HARDENING
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
:log info "ALL-IN-ONE ISP CONFIGURATION COMPLETE"
:log info "Management IP: 192.168.20.1"
:log info "PPPoE Service: $companyName-PPPoE"
:log info "Hotspot: VLAN $vlanHotspot"
:log info "RADIUS: $useRadius"
:log info "VPN: $enableVPN"
:log info "BDIX: $enableBDIX"
:log info "Failover: $enableFailover"
:log info "================================================"