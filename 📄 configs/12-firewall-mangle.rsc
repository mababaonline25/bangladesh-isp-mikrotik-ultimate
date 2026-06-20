###############################################################################
# CONFIG: 12-FIREWALL-MANGLE.RSC
# Description: Mangle configuration for traffic marking
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 12: FIREWALL - MANGLE"
:log info "================================================"

/ip firewall mangle

# Traffic Marking - Upload
add action=mark-packet chain=prerouting in-interface=bridge-local new-packet-mark=upload \
  comment="MARK_UPLOAD"

# Traffic Marking - Download
add action=mark-packet chain=prerouting in-interface=$upstream1Interface new-packet-mark=download \
  comment="MARK_DOWNLOAD"

:if ($enableFailover = "yes") do={
  add action=mark-packet chain=prerouting in-interface=$upstream2Interface new-packet-mark=download-backup \
    comment="MARK_DOWNLOAD_BACKUP"
}

# Traffic Marking - PPPoE
add action=mark-packet chain=prerouting in-interface="vlan$vlanPPPoE-PPPoE" new-packet-mark=upload-pppoe \
  comment="MARK_PPPOE_UPLOAD"

# Traffic Marking - B2B
add action=mark-packet chain=prerouting in-interface="vlan$vlanB2B-B2B" new-packet-mark=b2b-traffic \
  comment="MARK_B2B"

# Traffic Marking - Voice
add action=mark-packet chain=prerouting in-interface="vlan$vlanVoice-VOICE" new-packet-mark=voice-traffic \
  comment="MARK_VOICE"

# Traffic Marking - IPTV
add action=mark-packet chain=prerouting in-interface="vlan$vlanIPTV-IPTV" new-packet-mark=iptv-traffic \
  comment="MARK_IPTV"

# Traffic Marking - Guest
add action=mark-packet chain=prerouting in-interface="vlan$vlanGuest-GUEST" new-packet-mark=guest-traffic \
  comment="MARK_GUEST"

# Traffic Marking - Hotspot
add action=mark-packet chain=prerouting in-interface="vlan$vlanHotspot-HOTSPOT" new-packet-mark=hotspot-traffic \
  comment="MARK_HOTSPOT"

# Connection Marking for Load Balancing
:if ($enableFailover = "yes") do={
  # Mark connections for WAN1
  add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan1-conn per-connection-classifier=src-address-and-port:2/0 \
    comment="LOAD_BALANCE_WAN1"
  
  # Mark connections for WAN2
  add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan2-conn per-connection-classifier=src-address-and-port:2/1 \
    comment="LOAD_BALANCE_WAN2"
  
  # Routing marks
  add chain=prerouting connection-mark=wan1-conn action=mark-routing new-routing-mark=to-wan1 \
    comment="ROUTE_WAN1"
  add chain=prerouting connection-mark=wan2-conn action=mark-routing new-routing-mark=to-wan2 \
    comment="ROUTE_WAN2"
}

# TTL Adjustment (optional)
add chain=prerouting in-interface=bridge-local action=change-ttl new-ttl=set:64 \
  comment="SET_TTL"

:log info "Mangle configuration complete"