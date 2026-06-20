###############################################################################
# CONFIG: 23-VRRP-HA.RSC
# Description: VRRP High Availability configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 23: VRRP - HIGH AVAILABILITY"
:log info "================================================"

:if ($enableVRRP = "yes") do={

  # VRRP Interfaces
  /interface vrrp add name=vrrp-mgmt interface="vlan$vlanManagement-MGMT" \
    vrid=1 priority=100 address=192.168.20.1 \
    comment="VRRP_MGMT"
  
  /interface vrrp add name=vrrp-b2b interface="vlan$vlanB2B-B2B" \
    vrid=2 priority=100 address=10.40.0.1 \
    comment="VRRP_B2B"
  
  /interface vrrp add name=vrrp-guest interface="vlan$vlanGuest-GUEST" \
    vrid=3 priority=100 address=10.50.0.1 \
    comment="VRRP_GUEST"
  
  /interface vrrp add name=vrrp-hotspot interface="vlan$vlanHotspot-HOTSPOT" \
    vrid=4 priority=100 address=10.100.0.1 \
    comment="VRRP_HOTSPOT"
  
  /interface vrrp add name=vrrp-pppoe interface="vlan$vlanPPPoE-PPPoE" \
    vrid=5 priority=100 address=10.10.0.1 \
    comment="VRRP_PPPOE"
  
  # VRRP Authentication
  /interface vrrp set [find] authentication=simple password=VRRP-SECRET
  
  # VRRP Preemption
  /interface vrrp set [find] preemption-mode=yes
  
  # VRRP Tracking
  /interface vrrp set vrrp-mgmt track-interface=$upstream1Interface priority=10
  /interface vrrp set vrrp-b2b track-interface=$upstream1Interface priority=10
  
  # VRRP Notifications
  /interface vrrp set [find] on-master=":log info \"VRRP: Became Master\""
  /interface vrrp set [find] on-backup=":log info \"VRRP: Became Backup\""
  
  :log info "VRRP configuration complete"
} else={
  :log info "VRRP is disabled"
}