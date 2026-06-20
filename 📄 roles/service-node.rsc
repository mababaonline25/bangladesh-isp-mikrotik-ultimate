###############################################################################
# ROLE: SERVICE NODE
# Version: 5.0.0
# Description: Service node for VPN, Proxy, DNS, and other services
# Hardware: RB1100AHx4, CCR1009
# Features: VPN, Web Proxy, DNS, NTP, DHCP, Containers
###############################################################################

:log info "================================================"
:log info "ROLE: SERVICE NODE CONFIGURATION"
:log info "================================================"

# ============================================================================
# SYSTEM BASE CONFIGURATION
# ============================================================================

/system identity set name="$companyName-Services"
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

/interface bridge add name=bridge-local protocol-mode=none fast-forward=yes
/interface bridge add name=bridge-mgmt protocol-mode=none

/interface bridge port add bridge=bridge-local interface=ether1
/interface bridge port add bridge=bridge-local interface=ether2
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus1

# ============================================================================
# VLAN CONFIGURATION
# ============================================================================

/interface vlan add name="vlan$vlanManagement-MGMT" vlan-id=$vlanManagement interface=bridge-local
/interface vlan add name="vlan$vlanB2B-B2B" vlan-id=$vlanB2B interface=bridge-local
/interface vlan add name="vlan$vlanMgmt-OOB" vlan-id=$vlanMgmt interface=bridge-mgmt
/interface vlan add name="vlan$vlanStorage-STORAGE" vlan-id=$vlanStorage interface=bridge-local

# ============================================================================
# IP ADDRESSING
# ============================================================================

/ip address add address=192.168.20.1/24 interface="vlan$vlanManagement-MGMT"
/ip address add address=10.40.0.1/24 interface="vlan$vlanB2B-B2B"
/ip address add address=10.99.0.1/24 interface="vlan$vlanMgmt-OOB"
/ip address add address=10.70.0.1/24 interface="vlan$vlanStorage-STORAGE"

# Upstream
/ip address add address=10.1.3.2/30 interface=sfp-sfpplus1

# ============================================================================
# DHCP CONFIGURATION (Local)
# ============================================================================

/ip pool add name=dhcp-pool-mgmt ranges=192.168.20.10-192.168.20.250
/ip pool add name=dhcp-pool-b2b ranges=10.40.0.10-10.40.0.250
/ip pool add name=dhcp-pool-oob ranges=10.99.0.10-10.99.0.250

/ip dhcp-server add name=dhcp-mgmt interface="vlan$vlanManagement-MGMT" address-pool=dhcp-pool-mgmt
/ip dhcp-server add name=dhcp-b2b interface="vlan$vlanB2B-B2B" address-pool=dhcp-pool-b2b
/ip dhcp-server add name=dhcp-oob interface="vlan$vlanMgmt-OOB" address-pool=dhcp-pool-oob

/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.40.0.0/24 gateway=10.40.0.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.99.0.0/24 gateway=10.99.0.1 dns-server=8.8.8.8

# ============================================================================
# VPN CONFIGURATION - ALL TYPES
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
    /ppp profile add name="vpn-unlimited" local-address=10.20.0.1 remote-address=vpn-pool \
        rate-limit="0/0" dns-server=8.8.8.8,1.1.1.1 use-encryption=required
    
    # PPTP
    /interface pptp-server server set enabled=yes authentication=mschap1,mschap2
    
    # L2TP
    /interface l2tp-server server set enabled=yes authentication=mschap1,mschap2 ipsec-secret=VPN-IPSEC-SECRET
    
    # SSTP
    /interface sstp-server server set enabled=yes authentication=mschap1,mschap2
    
    # OpenVPN
    /interface ovpn-server server set enabled=yes auth=sha1 cipher=aes256
    
    # Sample VPN Users
    /ppp secret add name=vpnuser1 password=pass123 profile=vpn-20mbps service=pptp,l2tp,sstp,ovpn
    /ppp secret add name=vpnuser2 password=pass456 profile=vpn-50mbps service=pptp,l2tp,sstp,ovpn
}

# ============================================================================
# WIREGUARD VPN
# ============================================================================

:if ($enableWireGuard = "yes") do={
    /interface wireguard add name=wg-main private-key="YOUR-PRIVATE-KEY" listen-port=13231
    /ip address add address=10.200.0.1/24 interface=wg-main
    
    /interface wireguard peers add interface=wg-main public-key="PEER_PUBLIC_KEY" allowed-address=10.200.0.2/32
}

# ============================================================================
# IPSEC VPN
# ============================================================================

:if ($enableIPsec = "yes") do={
    /ip ipsec proposal add name=ikev2-proposal auth-algorithms=sha256 enc-algorithms=aes-256-cbc lifetime=8h pfs-group=modp2048
    /ip ipsec peer add address=0.0.0.0/0 exchange-mode=ike2 proposal-check=obey
    /ip ipsec policy add dst-address=0.0.0.0/0 src-address=0.0.0.0/0 action=encrypt level=unique \
        proposal=ikev2-proposal tunnel=yes
    /ip ipsec mode-config add name=ipsec-vpn address-pool=vpn-pool dns-server=8.8.8.8,1.1.1.1
    /ip ipsec identity add peer=any secret=IPSEC-SECRET mode-config=ipsec-vpn
}

# ============================================================================
# WEB PROXY
# ============================================================================

:if ($enableProxy = "yes") do={
    /ip proxy set enabled=yes port=8080 max-cache-size=unlimited cache-drive=system
    /ip proxy set cache-path=/cache
    /ip proxy set max-cache-object-size=10000KiB
    /ip proxy set max-client-connections=1000
    /ip proxy set max-server-connections=500
    
    /ip proxy access add action=allow dst-host=*.youtube.com
    /ip proxy access add action=allow dst-host=*.google.com
    /ip proxy access add action=allow dst-host=*.facebook.com
    /ip proxy access add action=allow dst-host=*.wikipedia.org
    /ip proxy access add action=deny
    
    /ip firewall nat add action=redirect chain=dstnat dst-port=80 protocol=tcp to-ports=8080
}

# ============================================================================
# CONTAINER SUPPORT
# ============================================================================

:if ($enableContainer = "yes") do={
    /interface veth add name=veth1 address=172.18.0.2/16 gateway=172.18.0.1
    
    /file mkdir containers/nginx
    /file mkdir containers/adguard
    /file mkdir containers/unbound
    
    /container add name=nginx image=nginx:latest interface=veth1 root-dir=containers/nginx
    /container add name=adguard image=adguard/adguardhome:latest interface=veth1 root-dir=containers/adguard
    /container add name=unbound image=alpine/unbound:latest interface=veth1 root-dir=containers/unbound
    
    /container start nginx
    /container start adguard
    /container start unbound
}

# ============================================================================
# ROUTING
# ============================================================================

/ip route add dst-address=0.0.0.0/0 gateway=10.1.3.1 distance=1 check-gateway=ping
/ip route add dst-address=10.0.0.0/8 gateway=bridge-local distance=0

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
add action=accept chain=input protocol=icmp
add action=accept chain=input src-address-list=TRUSTED-NETWORKS
add action=accept chain=input protocol=tcp dst-port=1723,1701,443,1194
add action=accept chain=input protocol=udp dst-port=13231
add action=accept chain=input protocol=udp dst-port=500,4500
add action=accept chain=input protocol=esp
add action=drop chain=input

add action=fasttrack-connection chain=forward connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=forward out-interface=sfp-sfpplus1
add action=accept chain=forward src-address=10.0.0.0/8 dst-address=10.0.0.0/8
add action=drop chain=forward

/ip firewall nat
add action=masquerade chain=srcnat out-interface=sfp-sfpplus1

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

/tool netwatch add host=10.1.3.1 interval=10s timeout=2s \
    up-script=":log info \"CORE-UP\"" \
    down-script=":log warning \"CORE-DOWN\""

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
:log info "SERVICE NODE CONFIGURATION COMPLETE"
:log info "Management IP: 192.168.20.1"
:log info "VPN: $enableVPN (PPTP/L2TP/SSTP/OpenVPN)"
:log info "WireGuard: $enableWireGuard"
:log info "IPsec: $enableIPsec"
:log info "Proxy: $enableProxy"
:log info "Container: $enableContainer"
:log info "================================================"