###############################################################################
# CONFIG: 02-INTERFACES-BRIDGE-VLAN.RSC
# Description: Interfaces, Bridges, and VLAN configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 2: INTERFACES, BRIDGES, VLAN"
:log info "================================================"

# Main Bridge
/interface bridge add name=bridge-local protocol-mode=none \
  comment="MAIN_BRIDGE" fast-forward=yes

# Management Bridge
/interface bridge add name=bridge-mgmt protocol-mode=none \
  comment="MGMT_BRIDGE"

# Bonding Interface
:if ($enableBonding = "yes") do={
  /interface bonding add name=bond1 mode=802.3ad slaves=sfp-sfpplus1,sfp-sfpplus2 \
    comment="LACP_BOND" lacp-rate=1s link-monitoring=arp
  /interface bonding add name=bond2 mode=balance-rr slaves=sfp-sfpplus3,sfp-sfpplus4 \
    comment="BOND_BALANCE" 
}

# Add all ports to bridge
/interface bridge port add bridge=bridge-local interface=ether1 comment="ETH1"
/interface bridge port add bridge=bridge-local interface=ether2 comment="ETH2"
/interface bridge port add bridge=bridge-local interface=ether3 comment="ETH3"
/interface bridge port add bridge=bridge-local interface=ether4 comment="ETH4"
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

# VLAN Filtering
/interface bridge set bridge-local vlan-filtering=yes
/interface bridge vlan add bridge=bridge-local vlan-ids=$vlanPPPoE tagged=bridge-local
/interface bridge vlan add bridge=bridge-local vlan-ids=$vlanManagement tagged=bridge-local
/interface bridge vlan add bridge=bridge-local vlan-ids=$vlanB2B tagged=bridge-local
/interface bridge vlan add bridge=bridge-local vlan-ids=$vlanGuest tagged=bridge-local
/interface bridge vlan add bridge=bridge-local vlan-ids=$vlanVoice tagged=bridge-local
/interface bridge vlan add bridge=bridge-local vlan-ids=$vlanIPTV tagged=bridge-local
/interface bridge vlan add bridge=bridge-local vlan-ids=$vlanStorage tagged=bridge-local
/interface bridge vlan add bridge=bridge-local vlan-ids=$vlanHotspot tagged=bridge-local

:log info "Interfaces, bridges, and VLAN configuration complete"