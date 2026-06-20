###############################################################################
# CONFIG: 39-ADVANCED-ROUTING.RSC
# Description: Advanced routing (MPLS, VPLS) configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 39: ADVANCED ROUTING"
:log info "================================================"

# MPLS Configuration
:if ($enableMPLS = "yes") do={

  # MPLS Interfaces
  /mpls interface add interface=$upstream1Interface comment="MPLS_WAN1"
  :if ($enableFailover = "yes") do={
    /mpls interface add interface=$upstream2Interface comment="MPLS_WAN2"
  }
  /mpls interface add interface=bridge-local comment="MPLS_LOCAL"
  
  # MPLS LDP
  /mpls ldp interface add interface=$upstream1Interface
  /mpls ldp interface add interface=bridge-local
  /mpls ldp set enabled=yes router-id=192.168.20.1
  
  # MPLS TE (Traffic Engineering)
  /mpls traffic-eng interface add interface=$upstream1Interface bandwidth=10000000
  /mpls traffic-eng tunnel add name=te-tunnel1 bandwidth=1000000
  
  :log info "MPLS configuration complete"
}

# VPLS Configuration
:if ($enableVPLS = "yes") do={

  # VPLS Interface
  /interface vpls add name=vpls1 remote-peer=10.1.200.10 vpls-id=100 \
    bridge=bridge-local comment="VPLS_TO_POP1"
  /interface vpls add name=vpls2 remote-peer=10.1.200.11 vpls-id=101 \
    bridge=bridge-local comment="VPLS_TO_POP2"
  
  # VPLS Settings
  /interface vpls set vpls1 keepalive-timeout=10s
  /interface vpls set vpls2 keepalive-timeout=10s
  
  # VPLS Firewall
  /ip firewall filter add chain=forward in-interface=vpls1 action=accept comment="ACCEPT_VPLS1"
  /ip firewall filter add chain=forward in-interface=vpls2 action=accept comment="ACCEPT_VPLS2"
  
  :log info "VPLS configuration complete"
}

# Policy Routing
/routing rule add src-address=10.50.0.0/24 action=lookup table=to-wan1 \
  comment="POLICY_ROUTING_GUEST"
/routing rule add src-address=10.120.0.0/24 action=lookup table=to-wan2 \
  comment="POLICY_ROUTING_IOT"

# Route Filters
/routing filter add chain=filter-route prefix=10.0.0.0/8 action=accept \
  comment="FILTER_10_NETWORK"
/routing filter add chain=filter-route prefix=192.168.0.0/16 action=reject \
  comment="FILTER_192_NETWORK"

# Load Balancing with PCC
/ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
  action=mark-connection new-connection-mark=wan1-conn per-connection-classifier=src-address-and-port:2/0 \
  comment="PCC_WAN1"
/ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
  action=mark-connection new-connection-mark=wan2-conn per-connection-classifier=src-address-and-port:2/1 \
  comment="PCC_WAN2"

:log info "Advanced routing configuration complete"