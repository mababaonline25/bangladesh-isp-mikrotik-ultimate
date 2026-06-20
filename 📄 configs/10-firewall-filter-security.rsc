###############################################################################
# CONFIG: 10-FIREWALL-FILTER-SECURITY.RSC
# Description: Filter firewall and security rules
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 10: FIREWALL - FILTER (Security)"
:log info "================================================"

/ip firewall filter

# Input Chain - Accept Established
add action=accept chain=input connection-state=established,related comment="ACCEPT_ESTABLISHED"
add action=accept chain=input protocol=icmp comment="ACCEPT_ICMP"

# Input Chain - Trusted Networks
add action=accept chain=input src-address-list=TRUSTED-NETWORKS comment="ACCEPT_TRUSTED"

# Input Chain - Services
add action=accept chain=input in-interface="vlan$vlanPPPoE-PPPoE" comment="ACCEPT_PPPOE"
add action=accept chain=input in-interface=bridge-local dst-port=1723,1701,443,1194 protocol=tcp comment="ACCEPT_VPN"
add action=accept chain=input in-interface="vlan$vlanHotspot-HOTSPOT" comment="ACCEPT_HOTSPOT"

# Input Chain - Routing Protocols
add action=accept chain=input protocol=ospf comment="ACCEPT_OSPF"
add action=accept chain=input protocol=tcp dst-port=179 comment="ACCEPT_BGP"
add action=accept chain=input protocol=udp dst-port=520 comment="ACCEPT_RIP"

# Input Chain - DHCP
add action=accept chain=input protocol=udp dst-port=67,68 comment="ACCEPT_DHCP"

# Input Chain - NTP
add action=accept chain=input protocol=udp dst-port=123 comment="ACCEPT_NTP"

# Input Chain - SNMP
add action=accept chain=input protocol=udp dst-port=161 comment="ACCEPT_SNMP"

# Input Chain - ICMP Limit
add action=accept chain=input protocol=icmp limit=10,5 comment="ACCEPT_ICMP_LIMITED"
add action=drop chain=input protocol=icmp comment="DROP_ICMP_EXCESS"

# Input Chain - Drop Others
add action=drop chain=input comment="DROP_OTHER_INPUT"

# Forward Chain - Fasttrack
add action=fasttrack-connection chain=forward connection-state=established,related comment="FASTTRACK"

# Forward Chain - Accept Established
add action=accept chain=forward connection-state=established,related comment="ACCEPT_ESTABLISHED_FWD"

# Forward Chain - WAN Interfaces
add action=accept chain=forward out-interface=$upstream1Interface comment="ACCEPT_WAN1"
:if ($enableFailover = "yes") do={
  add action=accept chain=forward out-interface=$upstream2Interface comment="ACCEPT_WAN2"
}

# Forward Chain - Internal Traffic
add action=accept chain=forward src-address=10.0.0.0/8 dst-address=10.0.0.0/8 comment="ACCEPT_INTERNAL"

# Forward Chain - Block Guest to Internal
add action=drop chain=forward src-address=10.50.0.0/24 dst-address=10.0.0.0/8 comment="BLOCK_GUEST_TO_INTERNAL"
add action=drop chain=forward src-address=10.120.0.0/24 dst-address=10.0.0.0/8 comment="BLOCK_IOT_TO_INTERNAL"

# Forward Chain - Block P2P
add action=drop chain=forward protocol=udp dst-port=6881-6889 comment="BLOCK_BITTORRENT_PORTS"

# Forward Chain - Drop Others
add action=drop chain=forward comment="DROP_OTHER_FORWARD"

# Layer 7 Protocols
/ip firewall layer7-protocol add name=block-bittorrent regexp="^(\\x13bittorrent|\\x19BitTorrent protocol|\\x00\\x00\\x00\\x01\\x00\\x00\\x00\\x00)"
/ip firewall layer7-protocol add name=block-facebook regexp="facebook.com|fb.com|fbcdn.net"
/ip firewall layer7-protocol add name=block-youtube regexp="youtube.com|youtu.be|googlevideo.com"
/ip firewall layer7-protocol add name=block-netflix regexp="netflix.com|nflxvideo.net"

# Layer 7 Filter Rules
/ip firewall filter add chain=forward layer7-protocol=block-bittorrent action=drop comment="BLOCK_BITTORRENT"
/ip firewall filter add chain=forward layer7-protocol=block-facebook action=drop comment="BLOCK_FACEBOOK"
/ip firewall filter add chain=forward layer7-protocol=block-youtube action=drop comment="BLOCK_YOUTUBE"
/ip firewall filter add chain=forward layer7-protocol=block-netflix action=drop comment="BLOCK_NETFLIX"

:log info "Filter firewall configuration complete"