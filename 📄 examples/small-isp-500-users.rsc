###############################################################################
# EXAMPLE: SMALL ISP - 500 USERS
# Version: 5.0.0
# Description: Configuration for small ISP with up to 500 users
# Hardware: RB1100AHx4 or similar
# Bandwidth: 1Gbps Upstream
###############################################################################

:log info "================================================"
:log info "SMALL ISP CONFIGURATION (500 USERS)"
:log info "================================================"

# ============================================================================
# BASIC CONFIGURATION
# ============================================================================

/system identity set name="Small-ISP-Dhaka"
/system clock set time-zone-name=Asia/Dhaka

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

# Bridge
/interface bridge add name=bridge-local protocol-mode=none

# VLANs
/interface vlan add name=vlan10-PPPoE vlan-id=10 interface=bridge-local
/interface vlan add name=vlan20-MGMT vlan-id=20 interface=bridge-local
/interface vlan add name=vlan100-Hotspot vlan-id=100 interface=bridge-local

# IP Addresses
/ip address add address=192.168.20.1/24 interface=vlan20-MGMT
/ip address add address=10.10.0.1/16 interface=vlan10-PPPoE
/ip address add address=10.100.0.1/24 interface=vlan100-Hotspot
/ip address add address=103.xxx.xxx.2/30 interface=ether1

# ============================================================================
# DHCP CONFIGURATION
# ============================================================================

/ip pool add name=dhcp-pool-mgmt ranges=192.168.20.10-192.168.20.250
/ip pool add name=dhcp-pool-hotspot ranges=10.100.0.10-10.100.0.250

/ip dhcp-server add name=dhcp-mgmt interface=vlan20-MGMT address-pool=dhcp-pool-mgmt
/ip dhcp-server add name=dhcp-hotspot interface=vlan100-Hotspot address-pool=dhcp-pool-hotspot

/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.100.0.0/24 gateway=10.100.0.1 dns-server=8.8.8.8

# ============================================================================
# PPPOE CONFIGURATION
# ============================================================================

/ip pool add name=pppoe-pool ranges=10.10.1.2-10.10.255.254

/ppp profile add name="pppoe-default" local-address=10.10.0.1 remote-address=pppoe-pool \
    dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/ppp profile add name="PKG-5MBPS" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="5M/5M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/ppp profile add name="PKG-10MBPS" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="10M/10M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/ppp profile add name="PKG-20MBPS" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="20M/20M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/ppp profile add name="PKG-50MBPS" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="50M/50M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/interface pppoe-server server add service-name="Small-ISP-PPPoE" interface=vlan10-PPPoE \
    one-session-per-host=yes max-sessions=500

# ============================================================================
# LOCAL USERS (Without RADIUS)
# ============================================================================

/ppp secret add name=customer1 password=pass123 profile=PKG-10MBPS service=pppoe
/ppp secret add name=customer2 password=pass456 profile=PKG-20MBPS service=pppoe
/ppp secret add name=customer3 password=pass789 profile=PKG-50MBPS service=pppoe

# ============================================================================
# HOTSPOT CONFIGURATION
# ============================================================================

/ip hotspot profile add name=hotspot-profile hotspot-address=10.100.0.1 \
    dns-name="hotspot.small-isp.com" login-by=http-chap,http-pap,cookie,trial

/ip hotspot add name=hotspot1 interface=vlan100-Hotspot address-pool=dhcp-pool-hotspot \
    profile=hotspot-profile

/ip hotspot walled-garden ip add dst-address=8.8.8.8 action=accept
/ip hotspot walled-garden ip add dst-address=1.1.1.1 action=accept
/ip hotspot walled-garden add dst-host=*.google.com action=accept
/ip hotspot walled-garden add dst-host=*.facebook.com action=accept

/ip hotspot user add name=guest1 password=guest123
/ip hotspot user add name=guest2 password=guest456

# ============================================================================
# FIREWALL CONFIGURATION
# ============================================================================

/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED-NETWORKS

# RAW Rules
/ip firewall raw add chain=prerouting action=drop connection-state=invalid
/ip firewall raw add chain=prerouting protocol=tcp tcp-flags=fin,syn action=drop
/ip firewall raw add chain=prerouting protocol=tcp tcp-flags=fin,rst action=drop

# DDoS Protection
/ip firewall raw add chain=prerouting protocol=tcp psd=21,3s,3,1 \
    action=add-src-to-address-list address-list=DDOS-BLACKLIST address-list-timeout=1h
/ip firewall raw add chain=prerouting protocol=tcp tcp-flags=syn \
    connection-limit=25,32 action=add-src-to-address-list address-list=DDOS-BLACKLIST
/ip firewall raw add chain=prerouting src-address-list=DDOS-BLACKLIST action=drop

# Filter Rules
/ip firewall filter add chain=input action=accept connection-state=established,related
/ip firewall filter add chain=input action=accept protocol=icmp
/ip firewall filter add chain=input action=accept src-address-list=TRUSTED-NETWORKS
/ip firewall filter add chain=input action=accept in-interface=vlan10-PPPoE
/ip firewall filter add chain=input action=accept in-interface=vlan100-Hotspot
/ip firewall filter add chain=input action=drop

/ip firewall filter add chain=forward action=fasttrack-connection connection-state=established,related
/ip firewall filter add chain=forward action=accept connection-state=established,related
/ip firewall filter add chain=forward action=accept out-interface=ether1
/ip firewall filter add chain=forward action=accept src-address=10.0.0.0/8 dst-address=10.0.0.0/8
/ip firewall filter add chain=forward action=drop

# NAT
/ip firewall nat add chain=srcnat action=masquerade out-interface=ether1

# ============================================================================
# ROUTING
# ============================================================================

/ip route add dst-address=0.0.0.0/0 gateway=103.xxx.xxx.1 distance=1

# ============================================================================
# DNS
# ============================================================================

/ip dns set servers=8.8.8.8,1.1.1.1
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
/ip service set winbox address=192.168.20.0/24
/ip service set ssh address=192.168.20.0/24

# ============================================================================
# MONITORING
# ============================================================================

/tool netwatch add host=8.8.8.8 interval=10s timeout=2s \
    up-script=":log info \"INTERNET-UP\"" \
    down-script=":log warning \"INTERNET-DOWN\""

/system script add name=health-check source={
    :local cpu [/system resource get cpu-load]
    :if ($cpu > 80) do={:log warning "HIGH-CPU: $cpu%"}
}

/system scheduler add name=health-check interval=5m on-event=health-check

# ============================================================================
# BACKUP
# ============================================================================

/system scheduler add name=daily-backup start-time=02:00:00 interval=1d on-event={
    /export file=backup-([/system clock get date]).rsc
    :log info "Backup created"
}

# ============================================================================
# COMPLETION
# ============================================================================

:log info "================================================"
:log info "SMALL ISP CONFIGURATION COMPLETE"
:log info "Management IP: 192.168.20.1"
:log info "PPPoE Service: Small-ISP-PPPoE"
:log info "Hotspot: vlan100-Hotspot"
:log info "================================================"