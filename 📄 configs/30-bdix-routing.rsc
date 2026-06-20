###############################################################################
# CONFIG: 30-BDIX-ROUTING.RSC
# Description: BDIX routing configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 30: BDIX ROUTING"
:log info "================================================"

:if ($enableBDIX = "yes") do={

  # BDIX Interface
  :if ([/interface find name=$bdixPeerInterface] = "") do={
    :log error "BDIX interface $bdixPeerInterface not found"
  } else={
    # BDIX Routes
    /ip route add dst-address=103.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_103"
    /ip route add dst-address=202.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_202"
    /ip route add dst-address=110.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_110"
    
    # BDIX Specific Routes
    /ip route add dst-address=103.251.0.0/16 gateway=$bdixPeerIP distance=1 \
      comment="BDIX_SPECIFIC"
    /ip route add dst-address=103.252.0.0/16 gateway=$bdixPeerIP distance=1 \
      comment="BDIX_SPECIFIC_2"
    
    # BDIX Firewall Rules
    /ip firewall filter add chain=forward out-interface=$bdixPeerInterface \
      action=accept comment="ACCEPT_BDIX"
    
    /ip firewall filter add chain=forward in-interface=$bdixPeerInterface \
      src-address=10.0.0.0/8 action=accept comment="ACCEPT_BDIX_INTERNAL"
    
    # BDIX NAT Exception
    /ip firewall nat add chain=srcnat out-interface=$bdixPeerInterface \
      action=accept comment="EXCEPT_BDIX_NAT"
    
    # BDIX Traffic Marking
    /ip firewall mangle add chain=prerouting out-interface=$bdixPeerInterface \
      action=mark-packet new-packet-mark=bdix-traffic comment="MARK_BDIX"
    
    # BDIX Queue
    /queue type add name="pcq-bdix" kind=pcq pcq-rate=0 pcq-classifier=dst-address
    /queue tree add name="BDIX_TRAFFIC" parent=TOTAL_DOWNLOAD \
      packet-mark=bdix-traffic queue=pcq-bdix
    
    :log info "BDIX routing configuration complete"
  }
} else={
  :log info "BDIX routing is disabled"
}