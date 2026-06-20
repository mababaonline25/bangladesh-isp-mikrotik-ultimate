###############################################################################
# ROLE: ACCESS CPE
# Version: 5.0.0
# Description: Customer Premise Equipment configuration
# Hardware: hAP, RB750, RB951, etc.
# Features: PPPoE Client, DHCP, NAT, Basic Firewall, WiFi
###############################################################################

:log info "================================================"
:log info "ROLE: ACCESS CPE CONFIGURATION"
:log info "================================================"

# ============================================================================
# SYSTEM BASE CONFIGURATION
# ============================================================================

/system identity set name="$companyName-CPE-001"
/system clock set time-zone-name=Asia/Dhaka

# NTP
/system ntp client set enabled=yes
/system ntp client servers add address=time.google.com
/system ntp client servers add address=pool.ntp.org

# DNS
/ip dns set servers=8.8.8.8,1.1.1.1
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=2048KiB

# ============================================================================
# INTERFACES & BRIDGES
# ============================================================================

/interface bridge add name=bridge-local protocol-mode=none fast-forward=yes

# Add ports to bridge
/interface bridge port add bridge=bridge-local interface=ether1
/interface bridge port add bridge=bridge-local interface=ether2
/interface bridge port add bridge=bridge-local interface=ether3
/interface bridge port add bridge=bridge-local interface=ether4

# WiFi Interface (if available)
:if ([find name~"wlan"] > 0) do={
    /interface wireless set wlan1 mode=ap-bridge ssid="$companyName-WiFi" band=2ghz-b/g/n
    /interface bridge port add bridge=bridge-local interface=wlan1
}

# ============================================================================
# IP ADDRESSING
# ============================================================================

# Local Network
/ip address add address=192.168.88.1/24 interface=bridge-local

# PPPoE Client (WAN)
/interface pppoe-client add name=pppoe-wan interface=ether1 \
    user="$companyName-PPPoE" password="customer-password" \
    service-name="$companyName-PPPoE" use-peer-dns=yes add-default-route=yes

# ============================================================================
# DHCP CONFIGURATION
# ============================================================================

/ip pool add name=dhcp-pool-local ranges=192.168.88.10-192.168.88.250

/ip dhcp-server add name=dhcp-local interface=bridge-local address-pool=dhcp-pool-local \
    lease-time=1d

/ip dhcp-server network add address=192.168.88.0/24 gateway=192.168.88.1 \
    dns-server=8.8.8.8,1.1.1.1

# DHCP Options
/ip dhcp-server option add name=router code=3 value=192.168.88.1
/ip dhcp-server option add name=dns code=6 value=8.8.8.8,1.1.1.1

# ============================================================================
# FIREWALL CONFIGURATION
# ============================================================================

/ip firewall address-list add address=192.168.88.0/24 list=LOCAL-NETWORKS

# RAW Rules
/ip firewall raw
add action=drop chain=prerouting connection-state=invalid
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,syn
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,rst

# Filter Rules - Input
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=input protocol=icmp
add action=accept chain=input src-address-list=LOCAL-NETWORKS
add action=accept chain=input in-interface=pppoe-wan
add action=drop chain=input

# Filter Rules - Forward
add action=fasttrack-connection chain=forward connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=forward out-interface=pppoe-wan
add action=accept chain=forward src-address=192.168.88.0/24 dst-address=192.168.88.0/24
add action=drop chain=forward

# NAT - Masquerade
/ip firewall nat
add action=masquerade chain=srcnat out-interface=pppoe-wan

# Port Forwarding (if needed)
# add action=dst-nat chain=dstnat protocol=tcp dst-port=80 to-addresses=192.168.88.10 to-ports=80

# ============================================================================
# BASIC ROUTING
# ============================================================================

# Default route via PPPoE
/ip route add dst-address=0.0.0.0/0 gateway=pppoe-wan distance=1

# ============================================================================
# SYSTEM HARDENING
# ============================================================================

/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip service set winbox address=192.168.88.0/24
/ip service set ssh address=192.168.88.0/24

# ============================================================================
# QoS - BASIC
# ============================================================================

/queue type add name="pcq-download" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="pcq-upload" kind=pcq pcq-rate=0 pcq-classifier=src-address

/queue simple add name="PPPOE-LIMIT" target=pppoe-wan max-limit=100M/100M

# ============================================================================
# MONITORING
# ============================================================================

/tool netwatch add host=8.8.8.8 interval=30s timeout=2s \
    up-script=":log info \"INTERNET-UP\"" \
    down-script=":log warning \"INTERNET-DOWN\""

/system script add name=health-check source={
    :local cpu [/system resource get cpu-load]
    :local mem [/system resource get free-memory]
    :if ($cpu > 80) do={:log warning "HIGH-CPU: $cpu%"}
    :if ($mem < 100000000) do={:log warning "LOW-MEMORY"}
}

/system scheduler add name=health-check interval=10m on-event=health-check

# ============================================================================
# WIFI SECURITY (if available)
# ============================================================================

:if ([find name~"wlan"] > 0) do={
    /interface wireless security-profiles add name=secure-wifi \
        authentication-types=wpa2-psk mode=dynamic-keys \
        wpa2-pre-shared-key=SecureWiFiPassword
    
    /interface wireless set wlan1 security-profile=secure-wifi
    /interface wireless set wlan1 disabled=no
}

# ============================================================================
# COMPLETION
# ============================================================================

:log info "================================================"
:log info "ACCESS CPE CONFIGURATION COMPLETE"
:log info "Local Network: 192.168.88.0/24"
:log info "WiFi SSID: $companyName-WiFi"
:log info "PPPoE: Connected to $companyName-PPPoE"
:log info "================================================"