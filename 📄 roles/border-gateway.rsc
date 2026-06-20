###############################################################################
# ROLE: BORDER GATEWAY
# Version: 5.0.0
# Description: Border gateway for large ISP with BGP peering
# Hardware: CCR1072, CCR2216
# Features: BGP, NAT, Firewall, DDoS Protection, Load Balancing
###############################################################################

:log info "================================================"
:log info "ROLE: BORDER GATEWAY CONFIGURATION"
:log info "================================================"

# ============================================================================
# SYSTEM BASE CONFIGURATION
# ============================================================================

/system identity set name="$companyName-Border"
/system clock set time-zone-name=Asia/Dhaka

# NTP
/system ntp client set enabled=yes
/system ntp client servers add address=time.google.com
/system ntp client servers add address=pool.ntp.org

# DNS
/ip dns set servers=8.8.8.8,1.1.1.1
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=20480KiB

# ============================================================================
# INTERFACES & BRIDGES
# ============================================================================

/interface bridge add name=bridge-internal protocol-mode=none fast-forward=yes
/interface bridge add name=bridge-mgmt protocol-mode=none

# Add internal ports to bridge
/interface bridge port add bridge=bridge-internal interface=ether1
/interface bridge port add bridge=bridge-internal interface=ether2
/interface bridge port add bridge=bridge-internal interface=sfp-sfpplus1
/interface bridge port add bridge=bridge-internal interface=sfp-sfpplus2

# ============================================================================
# VLAN CONFIGURATION
# ============================================================================

/interface vlan add name="vlan$vlanManagement-MGMT" vlan-id=$vlanManagement interface=bridge-internal
/interface vlan add name="vlan$vlanB2B-B2B" vlan-id=$vlanB2B interface=bridge-internal
/interface vlan add name="vlan$vlanMgmt-OOB" vlan-id=$vlanMgmt interface=bridge-mgmt

# ============================================================================
# IP ADDRESSING
# ============================================================================

/ip address add address=192.168.20.1/24 interface="vlan$vlanManagement-MGMT"
/ip address add address=10.40.0.1/24 interface="vlan$vlanB2B-B2B"
/ip address add address=10.99.0.1/24 interface="vlan$vlanMgmt-OOB"

# Upstream IPs
/ip address add address=$upstream1IP/30 interface=$upstream1Interface
:if ($enableFailover = "yes") do={
    /ip address add address=$upstream2IP/30 interface=$upstream2Interface
}
:if ($enableBDIX = "yes") do={
    /ip address add address=$bdixPeerIP/30 interface=$bdixPeerInterface
}

# ============================================================================
# BGP CONFIGURATION
# ============================================================================

:if ($enableBGP = "yes") do={
    /routing bgp instance add name=bgp-instance as=65001 router-id=192.168.20.1
    
    # BGP Peers - Upstreams
    /routing bgp peer add name=upstream1-peer instance=bgp-instance \
        remote-address=$upstream1IP remote-as=65000 multihop=no
    :if ($enableFailover = "yes") do={
        /routing bgp peer add name=upstream2-peer instance=bgp-instance \
            remote-address=$upstream2IP remote-as=65000 multihop=no
    }
    :if ($enableBDIX = "yes") do={
        /routing bgp peer add name=bdix-peer instance=bgp-instance \
            remote-address=$bdixPeerIP remote-as=65003 multihop=no
    }
    
    # BGP Networks
    /routing bgp network add network=10.0.0.0/8 synchronize=no
    /routing bgp network add network=192.168.20.0/24 synchronize=no
    
    # BGP Filtering - Inbound
    /routing filter add chain=bgp-in prefix=0.0.0.0/0 action=accept
    /routing filter add chain=bgp-in prefix=10.0.0.0/8 action=reject
    /routing filter add chain=bgp-in prefix=192.168.0.0/16 action=reject
    /routing filter add chain=bgp-in prefix=172.16.0.0/12 action=reject
    
    # BGP Filtering - Outbound
    /routing filter add chain=bgp-out prefix=10.0.0.0/8 action=accept
    /routing filter add chain=bgp-out prefix=192.168.20.0/24 action=accept
    /routing filter add chain=bgp-out prefix=0.0.0.0/0 action=reject
}

# ============================================================================
# STATIC ROUTING
# ============================================================================

/ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP distance=1 check-gateway=ping
:if ($enableFailover = "yes") do={
    /ip route add dst-address=0.0.0.0/0 gateway=$upstream2IP distance=2 check-gateway=ping
}
:if ($enableBDIX = "yes") do={
    /ip route add dst-address=103.0.0.0/8 gateway=$bdixPeerIP distance=1
    /ip route add dst-address=202.0.0.0/8 gateway=$bdixPeerIP distance=1
    /ip route add dst-address=110.0.0.0/8 gateway=$bdixPeerIP distance=1
}

# ============================================================================
# FIREWALL CONFIGURATION - ADVANCED
# ============================================================================

# Address Lists
/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.40.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.99.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.0.0.0/8 list=INTERNAL-NETWORKS
:if ($enableBDIX = "yes") do={
    /ip firewall address-list add address=103.0.0.0/8 list=BDIX-NETWORKS
    /ip firewall address-list add address=202.0.0.0/8 list=BDIX-NETWORKS
}

# RAW Rules - Layer 1 Protection
/ip firewall raw
add action=drop chain=prerouting connection-state=invalid
add action=drop chain=prerouting protocol=tcp src-port=0
add action=drop chain=prerouting protocol=udp src-port=0
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,syn
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,rst
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,!ack
add action=drop chain=prerouting protocol=tcp tcp-flags=syn,rst
add action=drop chain=prerouting protocol=icmp packet-size=1025-65535
add action=drop chain=prerouting protocol=icmp fragment=yes
add action=drop chain=prerouting ipv4-options=any

# DDoS Protection - Advanced
add action=add-src-to-address-list chain=prerouting protocol=tcp psd=21,3s,3,1 \
    address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=tcp tcp-flags=syn \
    connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=udp \
    connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=icmp limit=5,5 \
    address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=drop chain=prerouting src-address-list=DDOS-BLACKLIST

# Brute Force Protection
add action=add-src-to-address-list chain=prerouting dst-port=8291 protocol=tcp \
    src-address-list=!TRUSTED-NETWORKS connection-state=new \
    address-list=WINBOX-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting dst-port=22 protocol=tcp \
    src-address-list=!TRUSTED-NETWORKS connection-state=new \
    address-list=SSH-BLACKLIST address-list-timeout=1h
add action=drop chain=prerouting src-address-list=WINBOX-BLACKLIST,SSH-BLACKLIST

# Filter Rules - Input Chain
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=input protocol=icmp
add action=accept chain=input src-address-list=TRUSTED-NETWORKS
add action=accept chain=input protocol=tcp dst-port=179 comment="BGP"
add action=accept chain=input protocol=ospf
add action=drop chain=input

# Filter Rules - Forward Chain
add action=fasttrack-connection chain=forward connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=forward out-interface=$upstream1Interface
:if ($enableFailover = "yes") do={
    add action=accept chain=forward out-interface=$upstream2Interface
}
:if ($enableBDIX = "yes") do={
    add action=accept chain=forward out-interface=$bdixPeerInterface
}
add action=accept chain=forward src-address=10.0.0.0/8 dst-address=10.0.0.0/8
add action=drop chain=forward

# NAT - Masquerade
/ip firewall nat
add action=masquerade chain=srcnat out-interface=$upstream1Interface
:if ($enableFailover = "yes") do={
    add action=masquerade chain=srcnat out-interface=$upstream2Interface
}
:if ($enableBDIX = "yes") do={
    add action=accept chain=srcnat out-interface=$bdixPeerInterface
}

# Port Forwarding (Public Services)
add action=dst-nat chain=dstnat protocol=tcp dst-port=80 to-addresses=10.80.0.10 to-ports=80
add action=dst-nat chain=dstnat protocol=tcp dst-port=443 to-addresses=10.80.0.10 to-ports=443
add action=dst-nat chain=dstnat protocol=tcp dst-port=25 to-addresses=10.80.0.20 to-ports=25

# ============================================================================
# LOAD BALANCING & FAILOVER
# ============================================================================

:if ($enableFailover = "yes") do={
    /routing table add name=to-wan1 fib
    /routing table add name=to-wan2 fib
    
    /ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP routing-mark=to-wan1 distance=1
    /ip route add dst-address=0.0.0.0/0 gateway=$upstream2IP routing-mark=to-wan2 distance=1
    
    /ip firewall mangle add chain=prerouting in-interface=bridge-internal dst-address=!10.0.0.0/8 \
        action=mark-connection new-connection-mark=wan1-conn per-connection-classifier=src-address-and-port:2/0
    /ip firewall mangle add chain=prerouting in-interface=bridge-internal dst-address=!10.0.0.0/8 \
        action=mark-connection new-connection-mark=wan2-conn per-connection-classifier=src-address-and-port:2/1
    /ip firewall mangle add chain=prerouting connection-mark=wan1-conn action=mark-routing new-routing-mark=to-wan1
    /ip firewall mangle add chain=prerouting connection-mark=wan2-conn action=mark-routing new-routing-mark=to-wan2
}

# ============================================================================
# QoS CONFIGURATION
# ============================================================================

/queue type add name="pcq-download" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="pcq-upload" kind=pcq pcq-rate=0 pcq-classifier=src-address

/queue tree
add name="TOTAL_UPLOAD" parent=global packet-mark=upload queue=pcq-upload
add name="TOTAL_DOWNLOAD" parent=global packet-mark=download queue=pcq-download

/queue simple add name="TOTAL-LIMIT-1" target=$upstream1Interface max-limit=9500M/9500M
:if ($enableFailover = "yes") do={
    /queue simple add name="TOTAL-LIMIT-2" target=$upstream2Interface max-limit=4500M/4500M
}

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

/ip ssh set strong-crypto=yes
/ip ssh set host-key-size=4096

# ============================================================================
# MONITORING & BACKUP
# ============================================================================

/tool netwatch add host=8.8.8.8 interval=10s timeout=2s \
    up-script=":log info \"INTERNET-UP\"" \
    down-script=":log warning \"INTERNET-DOWN\""

/tool netwatch add host=$upstream1IP interval=10s timeout=2s \
    up-script=":log info \"UPSTREAM1-UP\"" \
    down-script=":log warning \"UPSTREAM1-DOWN\""

:if ($enableFailover = "yes") do={
    /tool netwatch add host=$upstream2IP interval=10s timeout=2s \
        up-script=":log info \"UPSTREAM2-UP\"" \
        down-script=":log warning \"UPSTREAM2-DOWN\""
}

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
:log info "BORDER GATEWAY CONFIGURATION COMPLETE"
:log info "Management IP: 192.168.20.1"
:log info "BGP: $enableBGP (AS 65001)"
:log info "BDIX: $enableBDIX"
:log info "Failover: $enableFailover"
:log info "================================================"