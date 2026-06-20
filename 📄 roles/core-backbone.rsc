###############################################################################
# ROLE: CORE BACKBONE
# Version: 5.0.0
# Description: Core backbone router for large ISP network
# Hardware: CCR1036, CCR1072
# Features: OSPF, MPLS, VPLS, High Availability, Traffic Engineering
###############################################################################

:log info "================================================"
:log info "ROLE: CORE BACKBONE CONFIGURATION"
:log info "================================================"

# ============================================================================
# SYSTEM BASE CONFIGURATION
# ============================================================================

/system identity set name="$companyName-Core"
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

/interface bridge add name=bridge-core protocol-mode=none fast-forward=yes
/interface bridge add name=bridge-mgmt protocol-mode=none

# Bonding for redundancy
/interface bonding add name=bond-core mode=802.3ad slaves=sfp-sfpplus1,sfp-sfpplus2 lacp-rate=1s
/interface bonding add name=bond-distribution mode=802.3ad slaves=sfp-sfpplus3,sfp-sfpplus4 lacp-rate=1s

# Add to bridge
/interface bridge port add bridge=bridge-core interface=bond-core
/interface bridge port add bridge=bridge-core interface=bond-distribution

# ============================================================================
# VLAN CONFIGURATION
# ============================================================================

/interface vlan add name="vlan$vlanManagement-MGMT" vlan-id=$vlanManagement interface=bridge-core
/interface vlan add name="vlan$vlanB2B-B2B" vlan-id=$vlanB2B interface=bridge-core
/interface vlan add name="vlan$vlanMgmt-OOB" vlan-id=$vlanMgmt interface=bridge-mgmt

# ============================================================================
# IP ADDRESSING
# ============================================================================

/ip address add address=192.168.20.1/24 interface="vlan$vlanManagement-MGMT"
/ip address add address=10.40.0.1/24 interface="vlan$vlanB2B-B2B"
/ip address add address=10.99.0.1/24 interface="vlan$vlanMgmt-OOB"

# Core Network IPs
/ip address add address=10.1.1.1/30 interface=bond-core
/ip address add address=10.1.2.1/30 interface=bond-distribution

# ============================================================================
# OSPF CONFIGURATION
# ============================================================================

:if ($enableOSPF = "yes") do={
    /routing ospf instance set [find] router-id=192.168.20.1
    
    /routing ospf area add name=backbone area-id=0.0.0.0
    /routing ospf area add name=stub area-id=0.0.0.1 stub=yes
    /routing ospf area add name=pop area-id=0.0.0.2
    
    # OSPF Interfaces
    /routing ospf interface add interface=bridge-core area=backbone passive=yes
    /routing ospf interface add interface=bond-core area=backbone network-type=point-to-point
    /routing ospf interface add interface=bond-distribution area=backbone network-type=point-to-point
    
    # OSPF Networks
    /routing ospf network add network=10.0.0.0/8 area=backbone
    /routing ospf network add network=192.168.20.0/24 area=stub
    
    # OSPF Redistribution
    /routing ospf redistribute add type=connected src-address=10.0.0.0/8 action=accept
    /routing ospf redistribute add type=static action=accept
    /routing ospf redistribute add type=bgp action=accept
}

# ============================================================================
# MPLS CONFIGURATION
# ============================================================================

:if ($enableMPLS = "yes") do={
    /mpls interface add interface=bond-core
    /mpls interface add interface=bond-distribution
    /mpls interface add interface=bridge-core
    
    /mpls ldp interface add interface=bond-core
    /mpls ldp interface add interface=bond-distribution
    /mpls ldp set enabled=yes router-id=192.168.20.1
    
    /mpls traffic-eng interface add interface=bond-core bandwidth=10000000
    /mpls traffic-eng interface add interface=bond-distribution bandwidth=10000000
}

# ============================================================================
# VPLS CONFIGURATION
# ============================================================================

:if ($enableVPLS = "yes") do={
    /interface vpls add name=vpls-pop1 remote-peer=10.1.1.2 vpls-id=100 bridge=bridge-core
    /interface vpls add name=vpls-pop2 remote-peer=10.1.1.3 vpls-id=101 bridge=bridge-core
    /interface vpls add name=vpls-pop3 remote-peer=10.1.1.4 vpls-id=102 bridge=bridge-core
    
    /interface vpls set vpls-pop1 keepalive-timeout=10s
    /interface vpls set vpls-pop2 keepalive-timeout=10s
    /interface vpls set vpls-pop3 keepalive-timeout=10s
}

# ============================================================================
# VRRP - HIGH AVAILABILITY
# ============================================================================

:if ($enableVRRP = "yes") do={
    /interface vrrp add name=vrrp-mgmt interface="vlan$vlanManagement-MGMT" vrid=1 priority=100 address=192.168.20.1
    /interface vrrp add name=vrrp-b2b interface="vlan$vlanB2B-B2B" vrid=2 priority=100 address=10.40.0.1
    /interface vrrp add name=vrrp-core interface=bond-core vrid=3 priority=100 address=10.1.1.1
    
    /interface vrrp set [find] authentication=simple password=VRRP-SECRET
    /interface vrrp set [find] preemption-mode=yes
}

# ============================================================================
# ROUTING - STATIC
# ============================================================================

/ip route add dst-address=0.0.0.0/0 gateway=10.1.1.2 distance=1 check-gateway=ping
/ip route add dst-address=10.0.0.0/8 gateway=bridge-core distance=0

# ============================================================================
# FIREWALL CONFIGURATION
# ============================================================================

/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.40.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.99.0.0/24 list=TRUSTED-NETWORKS

/ip firewall raw
add action=drop chain=prerouting connection-state=invalid
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,syn
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,rst

/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=input src-address-list=TRUSTED-NETWORKS
add action=accept chain=input protocol=ospf
add action=accept chain=input protocol=tcp dst-port=179
add action=drop chain=input

add action=fasttrack-connection chain=forward connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=forward src-address=10.0.0.0/8 dst-address=10.0.0.0/8
add action=drop chain=forward

# ============================================================================
# QoS - CORE
# ============================================================================

/queue type add name="pcq-download" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="pcq-upload" kind=pcq pcq-rate=0 pcq-classifier=src-address

/queue tree
add name="TOTAL_UPLOAD" parent=global packet-mark=upload queue=pcq-upload
add name="TOTAL_DOWNLOAD" parent=global packet-mark=download queue=pcq-download

/queue simple add name="CORE-LIMIT" target=bond-core max-limit=10000M/10000M

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

/tool netwatch add host=10.1.1.2 interval=10s timeout=2s \
    up-script=":log info \"CORE-PEER-UP\"" \
    down-script=":log warning \"CORE-PEER-DOWN\""

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
:log info "CORE BACKBONE CONFIGURATION COMPLETE"
:log info "Management IP: 192.168.20.1"
:log info "OSPF: $enableOSPF"
:log info "MPLS: $enableMPLS"
:log info "VPLS: $enableVPLS"
:log info "VRRP: $enableVRRP"
:log info "================================================"