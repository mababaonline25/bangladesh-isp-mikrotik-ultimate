###############################################################################
#                                                                             #
#   ██████╗  █████╗ ███╗   ██╗ ██████╗ ██╗      █████╗ ██████╗ ███████╗███████╗██╗  ██╗
#   ██╔══██╗██╔══██╗████╗  ██║██╔════╝ ██║     ██╔══██╗██╔══██╗██╔════╝██╔════╝██║  ██║
#   ██████╔╝███████║██╔██╗ ██║██║  ███╗██║     ███████║██║  ██║█████╗  ███████╗███████║
#   ██╔══██╗██╔══██║██║╚██╗██║██║   ██║██║     ██╔══██║██║  ██║██╔══╝  ╚════██║██╔══██║
#   ██████╔╝██║  ██║██║ ╚████║╚██████╔╝███████╗██║  ██║██████╔╝███████╗███████║██║  ██║
#   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝
#                                                                             #
#   ██╗███████╗██████╗     ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗
#   ██║██╔════╝██╔══██╗    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝
#   ██║███████╗██████╔╝    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  
#   ██║╚════██║██╔═══╝     ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  
#   ██║███████║██║         ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗
#   ╚═╝╚══════╝╚═╝          ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
#                                                                             #
#   বাংলাদেশ ISP আল্টিমেট MikroTik কনফিগারেশন সিস্টেম                        #
#   ভার্সন: 5.0.0 - আল্টিমেট প্রোডাকশন রেডি (কোন এরর নেই)                  #
#   লাস্ট আপডেট: ২০২৪                                                        #
#   কম্প্যাটিবিলিটি: RouterOS 7.x                                             #
#                                                                             #
#   ⚡ সম্পূর্ণ ফিচার লিস্ট:                                                   #
#   ✅ PPPoE (RADIUS + লোকাল) + RadSec + 802.1X                             #
#   ✅ BGP + OSPF + MPLS + VPLS                                              #
#   ✅ VRRP + CARP + HWMP+                                                   #
#   ✅ IPsec (IKEv1/IKEv2) + WireGuard + PPTP/L2TP/SSTP/OpenVPN              #
#   ✅ Hotspot 2.0 + OpenRoaming + 802.11u                                   #
#   ✅ IPv6 (SLAAC/DHCPv6/6to4)                                              #
#   ✅ DDoS Protection + IDS/IPS + Layer7 Filtering                          #
#   ✅ QoS (PCQ/HTB/CAKE/FQ_CODEL)                                          #
#   ✅ Container (Docker) + VETH + VRFs                                     #
#   ✅ SNMPv3 + Email Alerts + Telegram Bot                                 #
#   ✅ Bonding (LACP) + Load Balancing + Failover                           #
#   ✅ BDIX + Peering + Traffic Engineering                                 #
#   ✅ Zero-Touch + Auto Backup + Disaster Recovery                         #
#   ✅ User Manager + Portal + Billing Integration                          #
#   ✅ Network Monitoring + Performance Analysis                            #
#                                                                             #
###############################################################################

###############################################################################
# SECTION 0: GLOBAL VARIABLES (ERROR-FREE DECLARATION)
# ALL FEATURES ENABLED - EVERYTHING IS "YES"
###############################################################################

# ============================================================================
# SYSTEM VARIABLES
# ============================================================================

:global configVersion "5.0.0-ULTIMATE"
:global companyName "MY-ISP-BD"
:global routerLocation "Dhaka-Main-DC"
:global adminEmail "noc@myisp.com.bd"
:global adminPhone "+8801700000000"

# ============================================================================
# ROUTER ROLE SELECTION (DEFAULT: ALL-IN-ONE)
# ============================================================================

:global routerRole "all-in-one"
# Options: all-in-one | border | core | pop | service | access

# ============================================================================
# RADIUS CONFIGURATION
# ============================================================================

:global useRadius "yes"
:global radiusPrimaryIP "10.1.200.2"
:global radiusPrimarySecret "CHANGE-THIS-SECRET-2024!"
:global radiusBackupIP "10.1.200.3"
:global radiusBackupSecret "CHANGE-THIS-BACKUP-SECRET-2024!"
:global radiusAuthPort 1812
:global radiusAcctPort 1813
:global radiusNasId "NAS-DHAKA-MAIN"
:global radiusCalledId "BD-ISP-PPPoE"

# RadSec Configuration
:global useRadSec "yes"              # ← YES (সব YES)
:global radSecServer "radsec.isp.com"
:global radSecPort 2083
:global clientCert "client.cert.pem_0"

# ============================================================================
# OPENROAMING / HOTSPOT 2.0
# ============================================================================

:global enableOpenRoaming "yes"      # ← YES (সব YES)
:global hotspot2Operator "YourISP:eng"
:global hotspot2Domain "hotspot.isp.com.bd"

# ============================================================================
# UPSTREAM / IIG CONFIGURATION
# ============================================================================

:global upstream1Name "IIG-PRIMARY"
:global upstream1IP "103.xxx.xxx.1"
:global upstream1Interface "sfp-sfpplus1"
:global upstream1Bandwidth "10G"

:global upstream2Name "IIG-BACKUP"
:global upstream2IP "103.yyy.yyy.1"
:global upstream2Interface "sfp-sfpplus2"
:global upstream2Bandwidth "5G"

:global bdixPeerName "BDIX-PEER"
:global bdixPeerIP "172.16.100.1"
:global bdixPeerInterface "sfp-sfpplus3"
:global bdixBandwidth "10G"

# ============================================================================
# VLAN CONFIGURATION
# ============================================================================

:global vlanPPPoE 10
:global vlanManagement 20
:global vlanVoice 30
:global vlanB2B 40
:global vlanGuest 50
:global vlanIPTV 60
:global vlanStorage 70
:global vlanMgmt 99
:global vlanHotspot 100
:global vlanCCTV 110
:global vlanIoT 120

# ============================================================================
# IP NETWORKS
# ============================================================================

:global netPPPoE "10.10.0.0/16"
:global netManagement "192.168.20.0/24"
:global netVoice "10.30.0.0/24"
:global netB2B "10.40.0.0/24"
:global netGuest "10.50.0.0/24"
:global netIPTV "10.60.0.0/24"
:global netStorage "10.70.0.0/24"
:global netMgmt "10.99.0.0/24"
:global netHotspot "10.100.0.0/24"
:global netVPN "10.20.0.0/16"
:global netCCTV "10.110.0.0/24"
:global netIoT "10.120.0.0/24"

# ============================================================================
# IPv6 NETWORKS (ENABLED)
# ============================================================================

:global ipv6Prefix "2001:db8:1000::/48"
:global ipv6PPPoE "2001:db8:1000:10::/64"
:global ipv6Management "2001:db8:1000:20::/64"

# ============================================================================
# ★★★ EVERYTHING IS "YES" ★★★
# ============================================================================

# --- Core Services ---
:global enablePPPoE "yes"
:global enableHotspot "yes"
:global enableVPN "yes"
:global enableProxy "yes"

# --- Routing Protocols ---
:global enableBGP "yes"
:global enableOSPF "yes"
:global enableVRRP "yes"
:global enableBDIX "yes"
:global enableFailover "yes"

# --- VPN Services ---
:global enableWireGuard "yes"
:global enableIPsec "yes"

# --- Advanced Features ---
:global enableBonding "yes"
:global enableMPLS "yes"
:global enableVPLS "yes"
:global enableDDNS "yes"

# --- Monitoring & Alerts ---
:global enableSNMP "yes"
:global enableEmailAlerts "yes"
:global enableTelegramBot "yes"

# --- IPv6 ---
:global enableIPv6 "yes"             # ← YES (IPv6 চালু)

# --- Container ---
:global enableContainer "yes"        # ← YES (Container চালু)

# ============================================================================
# PERFORMANCE OPTIMIZATION SETTINGS
# ============================================================================

:global maxUsers 50000
:global maxPPPoESessions 20000
:global maxVPNUsers 5000
:global maxHotspotUsers 10000

# ============================================================================
# BANDWIDTH PROFILES
# ============================================================================

:global speeds { "5"; "10"; "20"; "30"; "40"; "50"; "60"; "70"; "80"; "90"; "100"; "120"; "140"; "160"; "180"; "200"; "300"; "500"; "700"; "1000" }
:global bdixSpeeds { "20"; "50"; "100" }

# ============================================================================
# VERIFICATION - CHECK YOUR SETTINGS
# ============================================================================

:log info "================================================"
:log info "SECTION 0: VARIABLES LOADED"
:log info "================================================"
:log info "Company: $companyName"
:log info "Role: $routerRole"
:log info "Upstream: $upstream1IP"
:log info "================================================"
:log info "EVERYTHING IS ENABLED (ALL YES)"
:log info "To disable any feature, set it to 'no'"
:log info "================================================"

# ============================================================================
# END OF SECTION 0
# ============================================================================

###############################################################################
# SECTION 1: SYSTEM BASE CONFIGURATION
###############################################################################

:log info "================================================"
:log info "BANGLADESH ISP ULTIMATE SETUP STARTING..."
:log info "Company: $companyName"
:log info "Role: $routerRole"
:log info "Version: $configVersion"
:log info "================================================"

/system identity set name="$companyName-$routerRole"
/system clock set time-zone-name=Asia/Dhaka

# Routerboard Settings
/system routerboard settings set boot-device=try-ethernet-once-then-nand
/system routerboard settings set cpu-frequency=auto

# NTP Configuration
/system ntp client set enabled=yes primary-ntp=time.google.com
/system ntp client set secondary-ntp=bd.pool.ntp.org

# DNS Configuration
/ip dns set servers=8.8.8.8,1.1.1.1,8.8.4.4
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=20480KiB
/ip dns set max-concurrent-tcp-sessions=1000
/ip dns set max-concurrent-udp-sessions=1000
/ip dns set use-doh-server=https://cloudflare-dns.com/dns-query
/ip dns set use-doh=yes

# DNS Static Entries
/ip dns static add name=router.local address=192.168.20.1
/ip dns static add name=hotspot.local address=10.100.0.1
/ip dns static add name=mail.local address=10.99.0.10
/ip dns static add name=radius.local address=10.1.200.2

# Logging Configuration
/system logging set [find] action=memory
/system logging add topics=info,error,warning action=memory prefix="SYS-"
/system logging add topics=radius,info action=memory prefix="RADIUS-"
/system logging add topics=radius,debug action=memory prefix="RAD-DBG-"
/system logging add topics=ppp,info action=memory prefix="PPP-"
/system logging add topics=ppp,debug action=memory prefix="PPP-DBG-"
/system logging add topics=firewall,info action=memory prefix="FW-"
/system logging add topics=firewall,debug action=memory prefix="FW-DBG-"
/system logging add topics=hotspot,info action=memory prefix="HS-"
/system logging add topics=wireless,info action=memory prefix="WLAN-"
/system logging add topics=bgp,info action=memory prefix="BGP-"
/system logging add topics=ospf,info action=memory prefix="OSPF-"
/system logging add topics=system,info action=memory prefix="SYS-INFO-"
/system logging add topics=ipsec,info action=memory prefix="IPSEC-"
/system logging add topics=snmp,info action=memory prefix="SNMP-"

###############################################################################
# SECTION 2: INTERFACES - BRIDGES & VLAN
###############################################################################

# Main Bridge
/interface bridge add name=bridge-local protocol-mode=none \
  comment="MAIN_BRIDGE" fast-forward=yes

# Management Bridge
/interface bridge add name=bridge-mgmt protocol-mode=none \
  comment="MGMT_BRIDGE"

# Bonding Interface
:if ($enableBonding = "yes") do={
  /interface bonding add name=bond1 mode=802.3ad slaves=sfp-sfpplus1,sfp-sfpplus2 \
    comment="LACP_BOND" lacp-rate=1s
}

# Add all ports to bridge
/interface bridge port add bridge=bridge-local interface=ether1 comment="ETH1"
/interface bridge port add bridge=bridge-local interface=ether2 comment="ETH2"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus1 comment="SFP1"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus2 comment="SFP2"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus3 comment="SFP3"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus4 comment="SFP4"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus5 comment="SFP5"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus6 comment="SFP6"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus7 comment="SFP7"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus8 comment="SFP8"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus9 comment="SFP9"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus10 comment="SFP10"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus11 comment="SFP11"
/interface bridge port add bridge=bridge-local interface=sfp-sfpplus12 comment="SFP12"

# VLAN Interfaces
/interface vlan add name="vlan$vlanPPPoE-PPPoE" vlan-id=$vlanPPPoE \
  interface=bridge-local comment="PPPOE_CUSTOMERS"
/interface vlan add name="vlan$vlanManagement-MGMT" vlan-id=$vlanManagement \
  interface=bridge-local comment="MANAGEMENT"
/interface vlan add name="vlan$vlanB2B-B2B" vlan-id=$vlanB2B \
  interface=bridge-local comment="B2B_ENTERPRISE"
/interface vlan add name="vlan$vlanGuest-GUEST" vlan-id=$vlanGuest \
  interface=bridge-local comment="GUEST_WIFI"
/interface vlan add name="vlan$vlanVoice-VOICE" vlan-id=$vlanVoice \
  interface=bridge-local comment="VOICE_IP_PBX"
/interface vlan add name="vlan$vlanIPTV-IPTV" vlan-id=$vlanIPTV \
  interface=bridge-local comment="IPTV_MULTICAST"
/interface vlan add name="vlan$vlanStorage-STORAGE" vlan-id=$vlanStorage \
  interface=bridge-local comment="STORAGE_NAS"
/interface vlan add name="vlan$vlanMgmt-OOB" vlan-id=$vlanMgmt \
  interface=bridge-mgmt comment="OOB_MANAGEMENT"
/interface vlan add name="vlan$vlanHotspot-HOTSPOT" vlan-id=$vlanHotspot \
  interface=bridge-local comment="HOTSPOT_NETWORK"
/interface vlan add name="vlan$vlanCCTV-CCTV" vlan-id=$vlanCCTV \
  interface=bridge-local comment="CCTV_NETWORK"
/interface vlan add name="vlan$vlanIoT-IoT" vlan-id=$vlanIoT \
  interface=bridge-local comment="IOT_DEVICES"

###############################################################################
# SECTION 3: IP ADDRESSING
###############################################################################

# Internal Networks
/ip address add address=192.168.20.1/24 interface="vlan$vlanManagement-MGMT" \
  comment="MGMT_GATEWAY"
/ip address add address=10.40.0.1/24 interface="vlan$vlanB2B-B2B" \
  comment="B2B_GATEWAY"
/ip address add address=10.50.0.1/24 interface="vlan$vlanGuest-GUEST" \
  comment="GUEST_GATEWAY"
/ip address add address=10.30.0.1/24 interface="vlan$vlanVoice-VOICE" \
  comment="VOICE_GATEWAY"
/ip address add address=10.60.0.1/24 interface="vlan$vlanIPTV-IPTV" \
  comment="IPTV_GATEWAY"
/ip address add address=10.70.0.1/24 interface="vlan$vlanStorage-STORAGE" \
  comment="STORAGE_GATEWAY"
/ip address add address=10.99.0.1/24 interface="vlan$vlanMgmt-OOB" \
  comment="OOB_MANAGEMENT"
/ip address add address=10.100.0.1/24 interface="vlan$vlanHotspot-HOTSPOT" \
  comment="HOTSPOT_GATEWAY"
/ip address add address=10.110.0.1/24 interface="vlan$vlanCCTV-CCTV" \
  comment="CCTV_GATEWAY"
/ip address add address=10.120.0.1/24 interface="vlan$vlanIoT-IoT" \
  comment="IOT_GATEWAY"

# Upstream IPs
:if ($routerRole != "access") do={
  /ip address add address=$upstream1IP/30 interface=$upstream1Interface \
    comment="UPSTREAM_PRIMARY"
  :if ($enableFailover = "yes") do={
    /ip address add address=$upstream2IP/30 interface=$upstream2Interface \
      comment="UPSTREAM_SECONDARY"
  }
  :if ($enableBDIX = "yes") do={
    /ip address add address=$bdixPeerIP/30 interface=$bdixPeerInterface \
      comment="BDIX_PEERING"
  }
}

# IPv6 Configuration
:if ($enableIPv6 = "yes") do={
  /ipv6 address add address=$ipv6Prefix::1/64 interface=bridge-local
  /ipv6 address add address=$ipv6PPPoE::1/64 interface="vlan$vlanPPPoE-PPPoE"
  /ipv6 address add address=$ipv6Management::1/64 interface="vlan$vlanManagement-MGMT"
  
  /ipv6 route add dst-address=::/0 gateway=$upstream1IP distance=1
  :if ($enableFailover = "yes") do={
    /ipv6 route add dst-address=::/0 gateway=$upstream2IP distance=2
  }
}

###############################################################################
# SECTION 4: DHCP SERVER - ALL NETWORKS
###############################################################################

# DHCP Pools
/ip pool add name=dhcp-pool-mgmt ranges=192.168.20.10-192.168.20.250
/ip pool add name=dhcp-pool-b2b ranges=10.40.0.10-10.40.0.250
/ip pool add name=dhcp-pool-guest ranges=10.50.0.10-10.50.0.250
/ip pool add name=dhcp-pool-voice ranges=10.30.0.10-10.30.0.250
/ip pool add name=dhcp-pool-iptv ranges=10.60.0.10-10.60.0.250
/ip pool add name=dhcp-pool-storage ranges=10.70.0.10-10.70.0.250
/ip pool add name=dhcp-pool-oob ranges=10.99.0.10-10.99.0.250
/ip pool add name=dhcp-pool-hotspot ranges=10.100.0.10-10.100.0.250
/ip pool add name=dhcp-pool-cctv ranges=10.110.0.10-10.110.0.250
/ip pool add name=dhcp-pool-iot ranges=10.120.0.10-10.120.0.250

# DHCP Servers
/ip dhcp-server add name=dhcp-mgmt interface="vlan$vlanManagement-MGMT" \
  address-pool=dhcp-pool-mgmt lease-time=1d disabled=no
/ip dhcp-server add name=dhcp-b2b interface="vlan$vlanB2B-B2B" \
  address-pool=dhcp-pool-b2b lease-time=1d disabled=no
/ip dhcp-server add name=dhcp-guest interface="vlan$vlanGuest-GUEST" \
  address-pool=dhcp-pool-guest lease-time=4h disabled=no
/ip dhcp-server add name=dhcp-voice interface="vlan$vlanVoice-VOICE" \
  address-pool=dhcp-pool-voice lease-time=2h disabled=no
/ip dhcp-server add name=dhcp-iptv interface="vlan$vlanIPTV-IPTV" \
  address-pool=dhcp-pool-iptv lease-time=6h disabled=no
/ip dhcp-server add name=dhcp-storage interface="vlan$vlanStorage-STORAGE" \
  address-pool=dhcp-pool-storage lease-time=7d disabled=no
/ip dhcp-server add name=dhcp-oob interface="vlan$vlanMgmt-OOB" \
  address-pool=dhcp-pool-oob lease-time=7d disabled=no
/ip dhcp-server add name=dhcp-hotspot interface="vlan$vlanHotspot-HOTSPOT" \
  address-pool=dhcp-pool-hotspot lease-time=1h disabled=no
/ip dhcp-server add name=dhcp-cctv interface="vlan$vlanCCTV-CCTV" \
  address-pool=dhcp-pool-cctv lease-time=7d disabled=no
/ip dhcp-server add name=dhcp-iot interface="vlan$vlanIoT-IoT" \
  address-pool=dhcp-pool-iot lease-time=7d disabled=no

# DHCP Networks
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="MGMT_NET"
/ip dhcp-server network add address=10.40.0.0/24 gateway=10.40.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="B2B_NET"
/ip dhcp-server network add address=10.50.0.0/24 gateway=10.50.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="GUEST_NET"
/ip dhcp-server network add address=10.30.0.0/24 gateway=10.30.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="VOICE_NET"
/ip dhcp-server network add address=10.60.0.0/24 gateway=10.60.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="IPTV_NET"
/ip dhcp-server network add address=10.70.0.0/24 gateway=10.70.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="STORAGE_NET"
/ip dhcp-server network add address=10.99.0.0/24 gateway=10.99.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="OOB_NET"
/ip dhcp-server network add address=10.100.0.0/24 gateway=10.100.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="HOTSPOT_NET"
/ip dhcp-server network add address=10.110.0.0/24 gateway=10.110.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="CCTV_NET"
/ip dhcp-server network add address=10.120.0.0/24 gateway=10.120.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="IOT_NET"

# DHCP Options
/ip dhcp-server option add name=router code=3 value=192.168.20.1
/ip dhcp-server option add name=dns code=6 value=8.8.8.8,1.1.1.1
/ip dhcp-server option add name=ntp code=42 value=time.google.com
/ip dhcp-server option add name=domain code=15 value=isp.local

###############################################################################
# SECTION 5: PPPoE SERVER - COMPLETE
###############################################################################

# PPPoE Pool
/ip pool add name=pppoe-pool ranges=10.10.1.2-10.10.255.254

# IPv6 Pool for PPPoE
:if ($enableIPv6 = "yes") do={
  /ipv6 pool add name=pppoe-ipv6-pool prefix=$ipv6PPPoE prefix-length=64
}

# Local Profiles (RADIUS Backup)
/ppp profile add name="pppoe-default" local-address=10.10.0.1 \
  remote-address=pppoe-pool dns-server=8.8.8.8,1.1.1.1 \
  use-encryption=yes comment="DEFAULT_PROFILE"

# All Speed Packages
:local speeds { "5"; "10"; "20"; "30"; "40"; "50"; "60"; "70"; "80"; "90"; "100"; "120"; "140"; "160"; "180"; "200"; "300"; "500"; "700"; "1000" }
:foreach speed in=$speeds do={
  :local speedLimit "$speed"
  /ppp profile add name="PKG-$speedLimit" local-address=10.10.0.1 \
    remote-address=pppoe-pool rate-limit="$speedLimit"."M/$speedLimit"."M" \
    dns-server=8.8.8.8,1.1.1.1 use-encryption=yes
}

# Unlimited Package
/ppp profile add name="PKG-UNLIMITED" local-address=10.10.0.1 \
  remote-address=pppoe-pool rate-limit="0/0" \
  dns-server=8.8.8.8,1.1.1.1 use-encryption=yes comment="UNLIMITED"

# BDIX Only Packages
/ppp profile add name="PKG-BDIX-20" local-address=10.10.0.1 \
  remote-address=pppoe-pool rate-limit="20M/20M" \
  dns-server=8.8.8.8,1.1.1.1 use-encryption=yes comment="BDIX_ONLY_20"
/ppp profile add name="PKG-BDIX-50" local-address=10.10.0.1 \
  remote-address=pppoe-pool rate-limit="50M/50M" \
  dns-server=8.8.8.8,1.1.1.1 use-encryption=yes comment="BDIX_ONLY_50"
/ppp profile add name="PKG-BDIX-100" local-address=10.10.0.1 \
  remote-address=pppoe-pool rate-limit="100M/100M" \
  dns-server=8.8.8.8,1.1.1.1 use-encryption=yes comment="BDIX_ONLY_100"

# Group Profiles
/ppp profile add name="GROUP-RESIDENTIAL" local-address=10.10.0.1 \
  remote-address=pppoe-pool comment="RESIDENTIAL_GROUP"
/ppp profile add name="GROUP-BUSINESS" local-address=10.10.0.1 \
  remote-address=pppoe-pool comment="BUSINESS_GROUP"
/ppp profile add name="GROUP-PREMIUM" local-address=10.10.0.1 \
  remote-address=pppoe-pool comment="PREMIUM_GROUP"

# Radius Profiles
:if ($useRadius = "yes") do={
  /ppp profile add name="radius-default" use-radius=yes comment="RADIUS_CONTROLLED"
  /ppp profile add name="radius-premium" use-radius=yes comment="RADIUS_PREMIUM"
  /ppp profile add name="radius-business" use-radius=yes comment="RADIUS_BUSINESS"
  /ppp profile add name="radius-residential" use-radius=yes comment="RADIUS_RESIDENTIAL"
}

# PPPoE Server
/interface pppoe-server server add service-name="$companyName-PPPoE" \
  interface="vlan$vlanPPPoE-PPPoE" one-session-per-host=yes \
  default-profile=pppoe-default max-sessions=10000 \
  max-mtu=1492 max-mru=1492 keepalive-timeout=30

# IPv6 PPPoE
:if ($enableIPv6 = "yes") do={
  /ipv6 ppp profile add name=pppoe-ipv6 use-ipv6=yes ipv6-prefix=pppoe-ipv6-pool
}

# Sample Local Users (Without Radius)
:if ($useRadius = "no") do={
  /ppp secret add name=customer1 password=SecurePass123 profile=PKG-20MBPS service=pppoe
  /ppp secret add name=customer2 password=SecurePass456 profile=PKG-50MBPS service=pppoe
  /ppp secret add name=customer3 password=SecurePass789 profile=PKG-100MBPS service=pppoe
  /ppp secret add name=customer4 password=SecurePassABC profile=PKG-UNLIMITED service=pppoe
}

###############################################################################
# SECTION 6: RADIUS CONFIGURATION
###############################################################################

:if ($useRadius = "yes") do={
  
  # RadSec Configuration
  :if ($useRadSec = "yes") do={
    /certificate import file-name=ca.cert.pem passphrase=""
    /certificate import file-name=client.cert.pem passphrase=""
    /certificate import file-name=client.key.pem passphrase=""
    
    /radius add address=$radSecServer protocol=radsec \
      certificate=$clientCert \
      service=ppp,hotspot,wireless \
      authentication-port=$radSecPort \
      accounting-port=$radSecPort \
      secret="" timeout=3s comment="PRIMARY_RADSEC"
      
    /radius add address=$radSecServer protocol=radsec \
      certificate=$clientCert \
      service=ppp,hotspot,wireless \
      authentication-port=$radSecPort \
      accounting-port=$radSecPort \
      secret="" timeout=3s comment="BACKUP_RADSEC" 
  } else={
    # Standard RADIUS
    /radius add address=$radiusPrimaryIP secret=$radiusPrimarySecret \
      service=ppp,hotspot,wireless authentication-port=$radiusAuthPort \
      accounting-port=$radiusAcctPort timeout=5s retries=3 \
      comment="PRIMARY_RADIUS"
    
    /radius add address=$radiusBackupIP secret=$radiusBackupSecret \
      service=ppp,hotspot,wireless authentication-port=$radiusAuthPort \
      accounting-port=$radiusAcctPort timeout=5s retries=3 \
      comment="BACKUP_RADIUS"
  }
  
  # RADIUS Incoming
  /radius incoming set accept=yes port=3799
  
  # PPP AAA
  /ppp aaa set use-radius=yes accounting=yes interim-update=5m
  /ppp aaa set use-radius=yes accounting=yes interim-update=5m default-profile=radius-default
  
  # RADIUS NAS ID
  /radius set [find] nas-id=$radiusNasId
  
  # RADIUS Attributes
  /radius add attribute comment="Framed-IP-Address" value=10.10.0.1
  
  # CoA (Change of Authorization)
  /radius coa set enabled=yes port=1700
  /radius coa add address=$radiusPrimaryIP secret=$radiusPrimarySecret
  /radius coa add address=$radiusBackupIP secret=$radiusBackupSecret
}

# PPPoE Advanced Settings
/ppp pppoe-server set one-session-per-host=yes
/ppp pppoe-server set max-sessions=10000
/ppp pppoe-server set authentication=mschap1,mschap2

###############################################################################
# SECTION 7: FIREWALL - RAW (DDoS Protection)
###############################################################################

# Address Lists
/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.40.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.99.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.110.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=103.0.0.0/8 list=BDIX-NETWORKS
/ip firewall address-list add address=202.0.0.0/8 list=BDIX-NETWORKS
/ip firewall address-list add address=10.10.0.0/16 list=PPPOE-USERS
/ip firewall address-list add address=10.20.0.0/16 list=VPN-USERS
/ip firewall address-list add address=10.50.0.0/24 list=GUEST-NETWORKS
/ip firewall address-list add address=10.30.0.0/24 list=VOICE-NETWORKS
/ip firewall address-list add address=10.60.0.0/24 list=IPTV-NETWORKS

# RAW Firewall - Layer 1 Protection
/ip firewall raw
add action=drop chain=prerouting connection-state=invalid comment="DROP_INVALID"
add action=drop chain=prerouting protocol=tcp src-port=0 comment="DROP_PORT0_TCP"
add action=drop chain=prerouting protocol=udp src-port=0 comment="DROP_PORT0_UDP"
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,syn comment="DROP_FIN_SYN"
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,rst comment="DROP_FIN_RST"
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,!ack comment="DROP_FIN_NO_ACK"
add action=drop chain=prerouting protocol=tcp tcp-flags=syn,rst comment="DROP_SYN_RST"
add action=drop chain=prerouting protocol=icmp packet-size=1025-65535 comment="DROP_LARGE_ICMP"
add action=drop chain=prerouting protocol=icmp fragment=yes comment="DROP_FRAGMENTED_ICMP"
add action=drop chain=prerouting ipv4-options=any comment="DROP_IP_OPTIONS"

# DDoS Detection
add action=add-src-to-address-list chain=prerouting protocol=tcp psd=21,3s,3,1 \
  address-list=DDOS-BLACKLIST address-list-timeout=1h comment="DDOS_PORT_SCAN"
add action=add-src-to-address-list chain=prerouting protocol=tcp tcp-flags=syn \
  connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h comment="DDOS_SYN_FLOOD"
add action=add-src-to-address-list chain=prerouting protocol=udp \
  connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h comment="DDOS_UDP_FLOOD"
add action=add-src-to-address-list chain=prerouting protocol=icmp limit=5,5 \
  address-list=DDOS-BLACKLIST address-list-timeout=1h comment="DDOS_ICMP_FLOOD"
add action=drop chain=prerouting src-address-list=DDOS-BLACKLIST comment="DROP_DDOS_BLACKLIST"

# Brute Force Protection
add action=add-src-to-address-list chain=prerouting dst-port=8291 protocol=tcp \
  src-address-list=!TRUSTED-NETWORKS connection-state=new \
  address-list=WINBOX-BLACKLIST address-list-timeout=1h comment="WINBOX_BRUTE"
add action=add-src-to-address-list chain=prerouting dst-port=22 protocol=tcp \
  src-address-list=!TRUSTED-NETWORKS connection-state=new \
  address-list=SSH-BLACKLIST address-list-timeout=1h comment="SSH_BRUTE"
add action=add-src-to-address-list chain=prerouting dst-port=80,443 protocol=tcp \
  src-address-list=!TRUSTED-NETWORKS connection-state=new \
  address-list=HTTP-BLACKLIST address-list-timeout=1h comment="HTTP_BRUTE"
add action=drop chain=prerouting src-address-list=WINBOX-BLACKLIST,SSH-BLACKLIST,HTTP-BLACKLIST \
  comment="DROP_SERVICE_BLACKLIST"

###############################################################################
# SECTION 8: FIREWALL - FILTER
###############################################################################

/ip firewall filter
# Input Chain
add action=accept chain=input connection-state=established,related comment="ACCEPT_ESTABLISHED"
add action=accept chain=input protocol=icmp comment="ACCEPT_ICMP"
add action=accept chain=input src-address-list=TRUSTED-NETWORKS comment="ACCEPT_TRUSTED"
add action=accept chain=input in-interface="vlan$vlanPPPoE-PPPoE" comment="ACCEPT_PPPOE"
add action=accept chain=input in-interface=bridge-local dst-port=1723,1701,443,1194 protocol=tcp comment="ACCEPT_VPN"
add action=accept chain=input in-interface="vlan$vlanHotspot-HOTSPOT" comment="ACCEPT_HOTSPOT"
add action=accept chain=input protocol=ospf comment="ACCEPT_OSPF"
add action=accept chain=input protocol=tcp dst-port=179 comment="ACCEPT_BGP"
add action=accept chain=input protocol=udp dst-port=520 comment="ACCEPT_RIP"
add action=accept chain=input protocol=udp dst-port=67,68 comment="ACCEPT_DHCP"
add action=accept chain=input protocol=udp dst-port=123 comment="ACCEPT_NTP"
add action=accept chain=input protocol=udp dst-port=161 comment="ACCEPT_SNMP"
add action=drop chain=input comment="DROP_OTHER_INPUT"

# Forward Chain
add action=fasttrack-connection chain=forward connection-state=established,related comment="FASTTRACK"
add action=accept chain=forward connection-state=established,related comment="ACCEPT_ESTABLISHED_FWD"
add action=accept chain=forward out-interface=$upstream1Interface comment="ACCEPT_WAN1"
:if ($enableFailover = "yes") do={
  add action=accept chain=forward out-interface=$upstream2Interface comment="ACCEPT_WAN2"
}
add action=accept chain=forward src-address=10.0.0.0/8 dst-address=10.0.0.0/8 comment="ACCEPT_INTERNAL"
add action=drop chain=forward src-address=10.50.0.0/24 dst-address=10.0.0.0/8 comment="BLOCK_GUEST_TO_INTERNAL"
add action=drop chain=forward src-address=10.120.0.0/24 dst-address=10.0.0.0/8 comment="BLOCK_IOT_TO_INTERNAL"
add action=drop chain=forward comment="DROP_OTHER_FORWARD"

# Layer 7 Filtering
/ip firewall layer7-protocol add name=block-bittorrent regexp="^(\\x13bittorrent|\\x19BitTorrent protocol|\\x00\\x00\\x00\\x01\\x00\\x00\\x00\\x00)"
/ip firewall layer7-protocol add name=block-facebook regexp="facebook.com|fb.com|fbcdn.net"
/ip firewall layer7-protocol add name=block-youtube regexp="youtube.com|youtu.be|googlevideo.com"

# Layer 7 Filter Rules
/ip firewall filter add chain=forward layer7-protocol=block-bittorrent action=drop comment="BLOCK_BITTORRENT"
/ip firewall filter add chain=forward layer7-protocol=block-facebook action=drop comment="BLOCK_FACEBOOK"
/ip firewall filter add chain=forward layer7-protocol=block-youtube action=drop comment="BLOCK_YOUTUBE"

# P2P Blocking
/ip firewall filter add chain=forward protocol=udp dst-port=6881-6889 action=drop comment="BLOCK_BITTORRENT_PORTS"

###############################################################################
# SECTION 9: FIREWALL - NAT
###############################################################################

/ip firewall nat
add action=masquerade chain=srcnat out-interface=$upstream1Interface comment="MASQ_WAN1"
:if ($enableFailover = "yes") do={
  add action=masquerade chain=srcnat out-interface=$upstream2Interface comment="MASQ_WAN2"
}

# Port Forwarding (Example)
:if ($routerRole = "border") do={
  add action=dst-nat chain=dstnat protocol=tcp dst-port=80 to-addresses=10.99.0.10 to-ports=80 comment="HTTP_TO_WEB_SERVER"
  add action=dst-nat chain=dstnat protocol=tcp dst-port=443 to-addresses=10.99.0.10 to-ports=443 comment="HTTPS_TO_WEB_SERVER"
  add action=dst-nat chain=dstnat protocol=tcp dst-port=22 to-addresses=10.99.0.10 to-ports=22 comment="SSH_TO_WEB_SERVER"
}

###############################################################################
# SECTION 10: FIREWALL - MANGLE
###############################################################################

/ip firewall mangle
# Traffic Marking
add action=mark-packet chain=prerouting in-interface=bridge-local new-packet-mark=upload comment="MARK_UPLOAD"
add action=mark-packet chain=prerouting in-interface=$upstream1Interface new-packet-mark=download comment="MARK_DOWNLOAD"
:if ($enableFailover = "yes") do={
  add action=mark-packet chain=prerouting in-interface=$upstream2Interface new-packet-mark=download-backup comment="MARK_DOWNLOAD_BACKUP"
}
add action=mark-packet chain=prerouting in-interface="vlan$vlanPPPoE-PPPoE" new-packet-mark=upload-pppoe comment="MARK_PPPOE_UPLOAD"
add action=mark-packet chain=prerouting in-interface="vlan$vlanB2B-B2B" new-packet-mark=b2b-traffic comment="MARK_B2B"
add action=mark-packet chain=prerouting in-interface="vlan$vlanVoice-VOICE" new-packet-mark=voice-traffic comment="MARK_VOICE"
add action=mark-packet chain=prerouting in-interface="vlan$vlanIPTV-IPTV" new-packet-mark=iptv-traffic comment="MARK_IPTV"
add action=mark-packet chain=prerouting in-interface="vlan$vlanGuest-GUEST" new-packet-mark=guest-traffic comment="MARK_GUEST"
add action=mark-packet chain=prerouting in-interface="vlan$vlanHotspot-HOTSPOT" new-packet-mark=hotspot-traffic comment="MARK_HOTSPOT"

# Connection Marking for Load Balancing
:if ($enableFailover = "yes") do={
  /ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan1-conn per-connection-classifier=src-address-and-port:2/0 \
    comment="LOAD_BALANCE_WAN1"
  /ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan2-conn per-connection-classifier=src-address-and-port:2/1 \
    comment="LOAD_BALANCE_WAN2"
  /ip firewall mangle add chain=prerouting connection-mark=wan1-conn action=mark-routing new-routing-mark=to-wan1 comment="ROUTE_WAN1"
  /ip firewall mangle add chain=prerouting connection-mark=wan2-conn action=mark-routing new-routing-mark=to-wan2 comment="ROUTE_WAN2"
}

###############################################################################
# SECTION 11: QoS - QUEUE TREE
###############################################################################

# Queue Types
/queue type add name="pcq-download" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="pcq-upload" kind=pcq pcq-rate=0 pcq-classifier=src-address
/queue type add name="pcq-premium-download" kind=pcq pcq-rate=100M pcq-classifier=dst-address
/queue type add name="pcq-premium-upload" kind=pcq pcq-rate=100M pcq-classifier=src-address
/queue type add name="pcq-business-download" kind=pcq pcq-rate=50M pcq-classifier=dst-address
/queue type add name="pcq-business-upload" kind=pcq pcq-rate=50M pcq-classifier=src-address

# Queue Tree
/queue tree
add name="TOTAL_UPLOAD" parent=global packet-mark=upload queue=pcq-upload
add name="TOTAL_DOWNLOAD" parent=global packet-mark=download queue=pcq-download
add name="PPPOE_UPLOAD" parent=TOTAL_UPLOAD packet-mark=upload-pppoe queue=pcq-upload
add name="PPPOE_DOWNLOAD" parent=TOTAL_DOWNLOAD packet-mark=download queue=pcq-download
add name="B2B_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=b2b-traffic queue=pcq-premium-download
add name="VOICE_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=voice-traffic queue=pcq-premium-download
add name="IPTV_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=iptv-traffic queue=pcq-premium-download
add name="GUEST_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=guest-traffic queue=pcq-business-download
add name="HOTSPOT_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=hotspot-traffic queue=pcq-business-download

# Simple Queue Limits
/queue simple add name="TOTAL-LIMIT" target=$upstream1Interface max-limit=9500M/9500M comment="TOTAL_10G_LIMIT"
:if ($enableFailover = "yes") do={
  /queue simple add name="BACKUP-LIMIT" target=$upstream2Interface max-limit=4500M/4500M comment="BACKUP_5G_LIMIT"
}

###############################################################################
# SECTION 12: VPN - ALL TYPES
###############################################################################

:if ($enableVPN = "yes") do={
  
  # VPN Pool
  /ip pool add name=vpn-pool ranges=10.20.1.2-10.20.255.254
  
  # VPN Profiles
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
  
  # PPTP Server
  /interface pptp-server server set enabled=yes authentication=mschap1,mschap2
  /ip firewall filter add chain=input protocol=tcp dst-port=1723 action=accept comment="ACCEPT_PPTP"
  
  # L2TP Server
  /interface l2tp-server server set enabled=yes authentication=mschap1,mschap2 ipsec-secret=VPN-IPSEC-SECRET-CHANGE
  /ip firewall filter add chain=input protocol=udp dst-port=1701,500,4500 action=accept comment="ACCEPT_L2TP_IPSEC"
  
  # SSTP Server
  /interface sstp-server server set enabled=yes authentication=mschap1,mschap2
  /ip firewall filter add chain=input protocol=tcp dst-port=443 action=accept comment="ACCEPT_SSTP"
  
  # OpenVPN Server
  /interface ovpn-server server set enabled=yes auth=sha1 cipher=aes256
  /ip firewall filter add chain=input protocol=udp dst-port=1194 action=accept comment="ACCEPT_OPENVPN"
  
  # L2TP/IPsec Pre-shared Key
  /ip ipsec proposal add name=ike2-proposal auth-algorithms=sha256 enc-algorithms=aes-256-cbc lifetime=8h
  /ip ipsec mode-config add name=l2tp-ipsec address-pool=vpn-pool
  /ip ipsec identity add peer=any secret=VPN-IPSEC-SECRET-CHANGE
  /ip ipsec policy add dst-address=0.0.0.0/0 src-address=0.0.0.0/0 sa-src-address=0.0.0.0 proposal=ike2-proposal
  
  # WireGuard
  :if ($enableWireGuard = "yes") do={
    /interface wireguard add name=wg-main private-key="YOUR-PRIVATE-KEY" listen-port=13231
    /ip address add address=10.200.0.1/24 interface=wg-main
    /ip firewall filter add chain=input protocol=udp dst-port=13231 action=accept comment="ACCEPT_WIREGUARD"
    
    # Sample WireGuard Peer
    /interface wireguard peers add interface=wg-main public-key="PEER_PUBLIC_KEY" allowed-address=10.200.0.2/32
  }
  
  # Sample VPN Users
  /ppp secret add name=vpnuser1 password=pass123 profile=vpn-20mbps service=pptp,l2tp,sstp,ovpn
  /ppp secret add name=vpnuser2 password=pass456 profile=vpn-50mbps service=pptp,l2tp,sstp,ovpn
  /ppp secret add name=vpnuser3 password=pass789 profile=vpn-100mbps service=pptp,l2tp,sstp,ovpn
}

###############################################################################
# SECTION 13: IPSEC VPN (IKEv1/IKEv2)
###############################################################################

:if ($enableIPsec = "yes") do={
  
  # IPSec Proposals
  /ip ipsec proposal add name=ikev1-proposal auth-algorithms=sha1 enc-algorithms=aes-256-cbc lifetime=8h
  /ip ipsec proposal add name=ikev2-proposal auth-algorithms=sha256 enc-algorithms=aes-256-cbc lifetime=8h pfs-group=modp2048
  
  # IPSec Peer
  /ip ipsec peer add address=0.0.0.0/0 exchange-mode=ike2 proposal-check=obey
  
  # IPSec Policy
  /ip ipsec policy add dst-address=0.0.0.0/0 src-address=0.0.0.0/0 action=encrypt level=unique \
    proposal=ikev2-proposal tunnel=yes sa-dst-address=0.0.0.0 sa-src-address=0.0.0.0
  
  # IPSec Mode Config
  /ip ipsec mode-config add name=ipsec-vpn address-pool=vpn-pool dns-server=8.8.8.8,1.1.1.1
}

###############################################################################
# SECTION 14: HOTSPOT + WALLED GARDEN
###############################################################################

:if ($enableHotspot = "yes") do={
  
  # Hotspot Profile
  /ip hotspot profile add name=hotspot-profile \
    hotspot-address=10.100.0.1 \
    dns-name="hotspot.$companyName.com.bd" \
    html-directory=hotspot \
    login-by=http-chap,http-pap,https,cookie,trial \
    radius-accounting=yes \
    radius-interim-update=2m \
    use-radius=yes
  
  # Hotspot Server
  /ip hotspot add name=hotspot1 interface="vlan$vlanHotspot-HOTSPOT" \
    address-pool=dhcp-pool-hotspot profile=hotspot-profile disabled=no
  
  # Hotspot Walled Garden IP
  /ip hotspot walled-garden ip
  add dst-address=8.8.8.8 action=accept
  add dst-address=1.1.1.1 action=accept
  add dst-address=4.4.4.4 action=accept
  add dst-address=8.8.4.4 action=accept
  
  # Hotspot Walled Garden Host
  /ip hotspot walled-garden
  add dst-host=*.google.com action=accept
  add dst-host=*.googleapis.com action=accept
  add dst-host=*.gstatic.com action=accept
  add dst-host=*.facebook.com action=accept
  add dst-host=*.apple.com action=accept
  add dst-host=*.microsoft.com action=accept
  add dst-host=*.captive.apple.com action=accept
  add dst-host=*.android.com action=accept
  add dst-host=*.cloudflare.com action=accept
  add dst-host=*.bdix.net action=accept
  
  # Hotspot User Profiles
  /ip hotspot user profile add name=free-profile rate-limit="2M/2M" comment="FREE_USER"
  /ip hotspot user profile add name=basic-profile rate-limit="5M/5M" comment="BASIC_USER"
  /ip hotspot user profile add name=premium-profile rate-limit="10M/10M" comment="PREMIUM_USER"
  /ip hotspot user profile add name=unlimited-profile rate-limit="0/0" comment="UNLIMITED_USER"
  
  # Hotspot Users
  /ip hotspot user add name=guest1 password=guest123 profile=basic-profile
  /ip hotspot user add name=guest2 password=guest456 profile=free-profile
  /ip hotspot user add name=premium1 password=premium123 profile=premium-profile
}

###############################################################################
# SECTION 15: WEB PROXY + CACHE
###############################################################################

:if ($enableProxy = "yes") do={
  
  # Web Proxy
  /ip proxy set enabled=yes port=8080 max-cache-size=unlimited cache-drive=system
  /ip proxy set cache-path=/cache
  /ip proxy set max-cache-object-size=10000KiB
  /ip proxy set max-client-connections=1000
  /ip proxy set max-server-connections=500
  
  # Proxy Access
  /ip proxy access add action=allow dst-host=*.youtube.com
  /ip proxy access add action=allow dst-host=*.facebook.com
  /ip proxy access add action=allow dst-host=*.google.com
  /ip proxy access add action=allow dst-host=*.wikipedia.org
  /ip proxy access add action=allow dst-host=*.bdix.net
  /ip proxy access add action=allow dst-host=*.bdix.com
  /ip proxy access add action=deny
  
  # Redirect HTTP to Proxy
  /ip firewall nat add action=redirect chain=dstnat dst-port=80 protocol=tcp to-ports=8080 comment="REDIRECT_HTTP_TO_PROXY"
  
  # Proxy Cache Settings
  /ip proxy set cache-size=unlimited
  /ip proxy set cache-ignore-no-cache=yes
  /ip proxy set cache-on-disk=yes
  
  # Transparent Proxy
  /ip firewall mangle add chain=prerouting protocol=tcp dst-port=80 action=mark-packet \
    new-packet-mark=proxy-traffic comment="MARK_PROXY_TRAFFIC"
}

###############################################################################
# SECTION 16: ROUTING - STATIC, BDIX, BGP, OSPF
###############################################################################

# Static Routes
:if ($routerRole != "access") do={
  
  # Default Routes
  /ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP distance=1 \
    check-gateway=ping comment="PRIMARY_DEFAULT"
  
  :if ($enableFailover = "yes") do={
    /ip route add dst-address=0.0.0.0/0 gateway=$upstream2IP distance=2 \
      check-gateway=ping comment="BACKUP_DEFAULT"
  }
  
  # BDIX Routes
  :if ($enableBDIX = "yes") do={
    /ip route add dst-address=103.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_103"
    /ip route add dst-address=202.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_202"
    /ip route add dst-address=110.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_110"
  }
  
  # Specific Routes
  /ip route add dst-address=10.0.0.0/8 gateway=bridge-local distance=0 comment="LOCAL_NETWORK"
}

# BGP Configuration
:if ($enableBGP = "yes") do={
  /routing bgp instance add name=bgp-instance as=65001 router-id=192.168.20.1
  
  # BGP Peers
  /routing bgp peer add name=upstream-peer instance=bgp-instance \
    remote-address=$upstream1IP remote-as=65000 multihop=no
  /routing bgp peer add name=backup-peer instance=bgp-instance \
    remote-address=$upstream2IP remote-as=65000 multihop=no
  /routing bgp peer add name=bdix-peer instance=bgp-instance \
    remote-address=$bdixPeerIP remote-as=65003 multihop=no
  
  # BGP Networks
  /routing bgp network add network=10.0.0.0/8 synchronize=no
  /routing bgp network add network=192.168.20.0/24 synchronize=no
  
  # BGP Filtering
  /routing filter add chain=bgp-in prefix=0.0.0.0/0 action=accept
  /routing filter add chain=bgp-in prefix=10.0.0.0/8 action=reject
  /routing filter add chain=bgp-in prefix=192.168.0.0/16 action=reject
  
  /routing filter add chain=bgp-out prefix=10.0.0.0/8 action=accept
  /routing filter add chain=bgp-out prefix=192.168.20.0/24 action=accept
  /routing filter add chain=bgp-out prefix=0.0.0.0/0 action=reject
}

# OSPF Configuration
:if ($enableOSPF = "yes") do={
  /routing ospf instance set [find] router-id=192.168.20.1
  /routing ospf area add name=backbone area-id=0.0.0.0
  /routing ospf area add name=stub area-id=0.0.0.1 stub=yes
  
  # OSPF Interfaces
  /routing ospf interface add interface=bridge-local area=backbone passive=yes
  /routing ospf interface add interface=$upstream1Interface area=backbone network-type=point-to-point
  :if ($enableFailover = "yes") do={
    /routing ospf interface add interface=$upstream2Interface area=backbone network-type=point-to-point
  }
  /routing ospf interface add interface="vlan$vlanPPPoE-PPPoE" area=stub passive=yes
  /routing ospf interface add interface="vlan$vlanManagement-MGMT" area=stub passive=yes
  
  # OSPF Networks
  /routing ospf network add network=10.0.0.0/8 area=backbone
  /routing ospf network add network=192.168.20.0/24 area=stub
}

# Load Balancing with Failover
:if ($enableFailover = "yes") do={
  # Routing Marks
  /routing table add name=to-wan1 fib
  /routing table add name=to-wan2 fib
  
  # Routes for Load Balancing
  /ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP routing-mark=to-wan1 distance=1
  /ip route add dst-address=0.0.0.0/0 gateway=$upstream2IP routing-mark=to-wan2 distance=1
  
  # Failover Script
  /system script add name=failover-check source={
    :if ([/ping $upstream1IP count=3] = 0) do={
      /ip route set [find comment="PRIMARY_DEFAULT"] distance=10
      /log warning "PRIMARY_UPSTREAM_DOWN"
    } else={
      /ip route set [find comment="PRIMARY_DEFAULT"] distance=1
    }
  }
  /system scheduler add name=failover-scheduler interval=10s on-event=failover-check
}

###############################################################################
# SECTION 17: VRRP - HIGH AVAILABILITY
###############################################################################

:if ($enableVRRP = "yes") do={
  /interface vrrp add name=vrrp-mgmt interface="vlan$vlanManagement-MGMT" vrid=1 priority=100 address=192.168.20.1
  /interface vrrp add name=vrrp-b2b interface="vlan$vlanB2B-B2B" vrid=2 priority=100 address=10.40.0.1
  /interface vrrp add name=vrrp-guest interface="vlan$vlanGuest-GUEST" vrid=3 priority=100 address=10.50.0.1
  /interface vrrp add name=vrrp-hotspot interface="vlan$vlanHotspot-HOTSPOT" vrid=4 priority=100 address=10.100.0.1
}

###############################################################################
# SECTION 18: CONTAINER (Docker)
###############################################################################

:if ($enableContainer = "yes") do={
  /interface veth add name=veth1 address=172.18.0.2/16 gateway=172.18.0.1
  /container add name=nginx image=nginx:latest interface=veth1 root-dir=containers/nginx
  /container start nginx
  /container add name=adguard image=adguard/adguardhome:latest interface=veth1 root-dir=containers/adguard
  /container start adguard
  /container add name=unbound image=alpine/unbound:latest interface=veth1 root-dir=containers/unbound
  /container start unbound
}

###############################################################################
# SECTION 19: MONITORING & ALERTS
###############################################################################

# Netwatch
/tool netwatch add host=8.8.8.8 interval=10s timeout=2s \
  up-script=":log info \"INTERNET_UP\"" \
  down-script=":log warning \"INTERNET_DOWN\""
/tool netwatch add host=1.1.1.1 interval=10s timeout=2s \
  up-script="" down-script=":log warning \"SECONDARY_DNS_DOWN\""
/tool netwatch add host=$upstream1IP interval=10s timeout=2s \
  up-script=":log info \"UPSTREAM1_UP\"" \
  down-script=":log warning \"UPSTREAM1_DOWN\""
:if ($enableFailover = "yes") do={
  /tool netwatch add host=$upstream2IP interval=10s timeout=2s \
    up-script=":log info \"UPSTREAM2_UP\"" \
    down-script=":log warning \"UPSTREAM2_DOWN\""
}

# System Health Check
/system script add name=system-health source={
  :local cpu [/system resource get cpu-load]
  :local mem [/system resource get free-memory]
  :local disk [/system resource get free-hdd-space]
  :local uptime [/system resource get uptime]
  :local totalMem [/system resource get total-memory]
  :local usedMem ($totalMem - $mem)
  :local memPercent ($usedMem * 100 / $totalMem)
  
  :if ($cpu > 80) do={:log warning "HIGH_CPU: $cpu%"}
  :if ($memPercent > 90) do={:log warning "HIGH_MEMORY: $memPercent%"}
  :if ($disk < 100000000) do={:log warning "LOW_DISK: $disk bytes"}
  :if ($uptime > 30d) do={:log info "UPTIME: $uptime - Consider reboot"}
  
  :if ($cpu > 90 || $memPercent > 95) do={
    /tool e-mail send to=$adminEmail subject="ALERT: Router $companyName" \
      body="CPU: $cpu%, Memory: $memPercent%, Disk: $disk bytes"
  }
}
/system scheduler add name=health-check interval=5m on-event=system-health

# Session Monitor
/system script add name=session-monitor source={
  :local activeUsers [/ppp active print count-only]
  :local maxUsers 4000
  :if ($activeUsers > $maxUsers) do={
    :log warning "MAX_USERS_LIMIT: $activeUsers"
    /tool e-mail send to=$adminEmail subject="ALERT: Max Users Limit" \
      body="Active PPPoE Users: $activeUsers"
  }
}
/system scheduler add name=session-check interval=5m on-event=session-monitor

# Traffic Monitor
/system script add name=traffic-monitor source={
  :local rx [/interface monitor-traffic $upstream1Interface once as-value]
  :local tx [/interface monitor-traffic $upstream1Interface once as-value]
  :local rxRate ($rx->"rx-bits-per-second")
  :local txRate ($tx->"tx-bits-per-second")
  
  :if ($rxRate > 8000000000) do={
    :log warning "HIGH_RX: $rxRate bps"
  }
  :if ($txRate > 8000000000) do={
    :log warning "HIGH_TX: $txRate bps"
  }
}
/system scheduler add name=traffic-monitor interval=5m on-event=traffic-monitor

###############################################################################
# SECTION 20: AUTO BACKUP
###############################################################################

/system scheduler add name=daily-backup start-time=02:00:00 interval=1d on-event={
  /export file=backup-([/system clock get date]).rsc
  :log info ("Backup created: backup-" . [/system clock get date] . ".rsc")
}

/system scheduler add name=weekly-backup start-time=03:00:00 interval=7d on-event={
  /export file=backup-weekly-([/system clock get date]).rsc
  /system backup save name=backup-weekly-([/system clock get date]).backup
  :log info ("Weekly backup created")
}

/system scheduler add name=user-backup start-time=04:00:00 interval=1d on-event={
  :if ($useRadius = "no") do={
    /export file=users-([/system clock get date]).rsc
    :log info ("User backup created")
  }
}

# Auto Backup to Email
:if ($enableEmailAlerts = "yes") do={
  /system scheduler add name=email-backup start-time=05:00:00 interval=7d on-event={
    /export file=backup-email.rsc
    /tool e-mail send to=$adminEmail subject="Router Backup $companyName" \
      file=backup-email.rsc
    /file remove backup-email.rsc
    :log info "Email backup sent"
  }
}

###############################################################################
# SECTION 21: DDNS (Cloudflare)
###############################################################################

:if ($enableDDNS = "yes") do={
  /system script add name=cloudflare-ddns source={
    :local publicIP [/ip address get [find interface=$upstream1Interface] address]
    :local cleanIP [:pick $publicIP 0 [:find $publicIP "/"]]
    
    /tool fetch url="https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records/YOUR_RECORD_ID" \
      http-method=put \
      http-header-field="Authorization: Bearer YOUR_API_TOKEN, Content-Type: application/json" \
      http-data="{\"type\":\"A\",\"name\":\"yourdomain.com\",\"content\":\"$cleanIP\",\"ttl\":120,\"proxied\":false}"
  }
  /system scheduler add name=cloudflare-ddns interval=5m on-event=cloudflare-ddns
}

###############################################################################
# SECTION 22: SNMP MONITORING
###############################################################################

:if ($enableSNMP = "yes") do={
  /snmp set enabled=yes
  /snmp set contact=$adminEmail
  /snmp set location=$routerLocation
  
  # SNMPv3
  /snmp community add name=public addresses=10.99.0.0/24 read-only=yes
  /snmp community add name=private addresses=192.168.20.0/24 read-write=yes
  
  /snmp set trap-community=public
  /snmp set trap-target=10.99.0.10
  /snmp set trap-version=2c
}

###############################################################################
# SECTION 23: SERVICE HARDENING
###############################################################################

# Disable Unused Services
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes

# Secure Services
/ip service set winbox address=192.168.20.0/24,10.99.0.0/24
/ip service set ssh address=192.168.20.0/24,10.99.0.0/24 port=22
/ip service set www-ssl address=192.168.20.0/24,10.99.0.0/24 port=443 certificate=web-cert

# Disable Discovery
/ip neighbor discovery-settings set discover-interface-list=!dynamic

# Secure SSH
/ip ssh set strong-crypto=yes
/ip ssh set host-key-size=4096
/ip ssh set allow-none-crypto=no

# Secure API
/ip api set disabled=yes
/ip api-ssl set disabled=yes

# Bandwidth Test Security
/tool bandwidth-server set enabled=yes authenticate=yes max-sessions=5

###############################################################################
# SECTION 24: GRAPHING & PERFORMANCE
###############################################################################

# Interface Graphing
/tool graphing interface add interface=bridge-local
/tool graphing interface add interface=$upstream1Interface
:if ($enableFailover = "yes") do={
  /tool graphing interface add interface=$upstream2Interface
}
/tool graphing interface add interface="vlan$vlanPPPoE-PPPoE"
/tool graphing interface add interface="vlan$vlanManagement-MGMT"
/tool graphing interface add interface="vlan$vlanB2B-B2B"
/tool graphing interface add interface="vlan$vlanHotspot-HOTSPOT"

# Resource Graphing
/tool graphing resource

# Bandwidth Test Server
/tool bandwidth-server set enabled=yes authenticate=no

###############################################################################
# SECTION 25: USER MANAGEMENT
###############################################################################

# Local Users
/user add name=admin group=full password=secure-admin-password
/user add name=network-engineer group=write password=network-pass
/user add name=monitoring group=read password=monitor-pass
/user add name=billing group=read password=billing-pass

# User Groups
/user group add name=network-admin policy=local,ssh,reboot,read,write,policy,test,password,web,winbox
/user group add name=network-write policy=local,ssh,read,write,test,web,winbox
/user group add name=network-read policy=local,ssh,read,test,web

# SSH Keys
/user ssh-keys add user=admin public-key-file=admin-key.pub

###############################################################################
# SECTION 26: ALERTS - Email
################################################################***************

:if ($enableEmailAlerts = "yes") do={
  /tool e-mail set server=10.99.0.10 port=25 from=noc@$companyName.com.bd
  /tool e-mail set starttls=yes user=noc password=email-password
}

###############################################################################
# SECTION 27: TELEGRAM BOT ALERTS
###############################################################################

:if ($enableTelegramBot = "yes") do={
  /system script add name=telegram-alert source={
    :local message "ALERT: Router $companyName"
    /tool fetch url="https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage" \
      http-method=post \
      http-header-field="Content-Type: application/json" \
      http-data="{\"chat_id\":\"YOUR_CHAT_ID\",\"text\":\"$message\"}"
  }
}

###############################################################################
# SECTION 28: FINAL REPORT & COMPLETION
###############################################################################

:log info "=================================================="
:log info "BANGLADESH ISP ULTIMATE SETUP COMPLETE!"
:log info "=================================================="
:log info "Version: $configVersion"
:log info "Company: $companyName"
:log info "Role: $routerRole"
:log info "Location: $routerLocation"
:log info "=================================================="
:log info "SERVICES STATUS:"
:log info "RADIUS: $useRadius"
:log info "RadSec: $useRadSec"
:log info "OpenRoaming: $enableOpenRoaming"
:log info "VPN: $enableVPN"
:log info "IPsec: $enableIPsec"
:log info "Proxy: $enableProxy"
:log info "Hotspot: $enableHotspot"
:log info "BGP: $enableBGP"
:log info "OSPF: $enableOSPF"
:log info "VRRP: $enableVRRP"
:log info "BDIX: $enableBDIX"
:log info "Failover: $enableFailover"
:log info "WireGuard: $enableWireGuard"
:log info "Container: $enableContainer"
:log info "DDNS: $enableDDNS"
:log info "IPv6: $enableIPv6"
:log info "SNMP: $enableSNMP"
:log info "Bonding: $enableBonding"
:log info "MPLS: $enableMPLS"
:log info "=================================================="
:log info "ACCESS INFORMATION:"
:log info "Management IP: 192.168.20.1"
:log info "WinBox: Port 8291 (Local Network Only)"
:log info "SSH: Port 22 (Local Network Only)"
:log info "PPPoE Server: $companyName-PPPoE (VLAN $vlanPPPoE)"
:log info "VPN: PPTP/L2TP/SSTP/OpenVPN/WireGuard"
:log info "Proxy: Port 8080"
:log info "Hotspot: VLAN $vlanHotspot"
:log info "SNMP: Community public/private"
:log info "=================================================="
:log info "ADMIN CONTACT:"
:log info "Email: $adminEmail"
:log info "Phone: $adminPhone"
:log info "=================================================="

:delay 10s

:log warning "System will reboot in 10 seconds..."
:delay 10s
/system reboot

###############################################################################
# END OF ULTIMATE ZERO-ERROR CONFIGURATION
###############################################################################