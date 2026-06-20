###############################################################################
# CONFIG: 03-IP-ADDRESSING.RSC
# Description: IP addressing for all networks
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 3: IP ADDRESSING"
:log info "================================================"

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

# PPPoE Server IP
/ip address add address=10.10.0.1/16 interface="vlan$vlanPPPoE-PPPoE" \
  comment="PPPOE_SERVER"

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

:log info "IP addressing complete"