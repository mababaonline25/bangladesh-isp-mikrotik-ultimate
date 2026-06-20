###############################################################################
# CONFIG: 22-ROUTING-OSPF.RSC
# Description: OSPF routing configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 22: ROUTING - OSPF"
:log info "================================================"

:if ($enableOSPF = "yes") do={

  # OSPF Instance
  /routing ospf instance set [find] router-id=192.168.20.1 \
    comment="OSPF_INSTANCE"
  
  # OSPF Areas
  /routing ospf area add name=backbone area-id=0.0.0.0 \
    comment="BACKBONE_AREA"
  /routing ospf area add name=stub area-id=0.0.0.1 stub=yes \
    comment="STUB_AREA"
  /routing ospf area add name=service area-id=0.0.0.2 \
    comment="SERVICE_AREA"
  
  # OSPF Interfaces
  /routing ospf interface add interface=bridge-local area=backbone passive=yes \
    comment="BRIDGE_INTERFACE"
  /routing ospf interface add interface=$upstream1Interface area=backbone \
    network-type=point-to-point comment="WAN1_INTERFACE"
  
  :if ($enableFailover = "yes") do={
    /routing ospf interface add interface=$upstream2Interface area=backbone \
      network-type=point-to-point comment="WAN2_INTERFACE"
  }
  
  /routing ospf interface add interface="vlan$vlanPPPoE-PPPoE" area=stub passive=yes \
    comment="PPPOE_INTERFACE"
  /routing ospf interface add interface="vlan$vlanManagement-MGMT" area=stub passive=yes \
    comment="MGMT_INTERFACE"
  /routing ospf interface add interface="vlan$vlanB2B-B2B" area=stub passive=yes \
    comment="B2B_INTERFACE"
  
  :if ($enableBDIX = "yes") do={
    /routing ospf interface add interface=$bdixPeerInterface area=backbone \
      network-type=point-to-point comment="BDIX_INTERFACE"
  }
  
  # OSPF Networks
  /routing ospf network add network=10.0.0.0/8 area=backbone \
    comment="OSPF_NETWORK_10"
  /routing ospf network add network=192.168.20.0/24 area=stub \
    comment="OSPF_NETWORK_MGMT"
  
  # OSPF Redistribution
  /routing ospf redistribute add type=connected src-address=10.0.0.0/8 \
    action=accept comment="REDISTRIBUTE_CONNECTED"
  /routing ospf redistribute add type=static action=accept \
    comment="REDISTRIBUTE_STATIC"
  
  # OSPF Route Filtering
  /routing filter add chain=ospf-in prefix=10.0.0.0/8 action=accept \
    comment="ACCEPT_10_NET"
  /routing filter add chain=ospf-in prefix=192.168.20.0/24 action=accept \
    comment="ACCEPT_MGMT"
  /routing filter add chain=ospf-in prefix=0.0.0.0/0 action=reject \
    comment="REJECT_DEFAULT"
  
  :log info "OSPF configuration complete"
} else={
  :log info "OSPF is disabled"
}