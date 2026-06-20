###############################################################################
# CONFIG: 15-WIREGUARD-VPN.RSC
# Description: WireGuard VPN configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 15: WIREGUARD VPN"
:log info "================================================"

:if ($enableWireGuard = "yes") do={

  # WireGuard Interface
  /interface wireguard add name=wg-main private-key="YOUR-PRIVATE-KEY" listen-port=13231 \
    comment="WIREGUARD_MAIN"
  
  # WireGuard IP
  /ip address add address=10.200.0.1/24 interface=wg-main comment="WIREGUARD_GATEWAY"
  
  # Firewall Rule for WireGuard
  /ip firewall filter add chain=input protocol=udp dst-port=13231 action=accept \
    comment="ACCEPT_WIREGUARD"
  
  # Sample WireGuard Peers
  /interface wireguard peers add interface=wg-main public-key="PEER1_PUBLIC_KEY" \
    allowed-address=10.200.0.2/32 comment="PEER1"
  /interface wireguard peers add interface=wg-main public-key="PEER2_PUBLIC_KEY" \
    allowed-address=10.200.0.3/32 comment="PEER2"
  /interface wireguard peers add interface=wg-main public-key="PEER3_PUBLIC_KEY" \
    allowed-address=10.200.0.4/32 comment="PEER3"
  
  # WireGuard Client Profiles
  /ppp profile add name="wireguard-10mbps" local-address=10.200.0.1 \
    remote-address=10.200.0.0/24 dns-server=8.8.8.8,1.1.1.1
  
  :log info "WireGuard VPN configuration complete"
} else={
  :log info "WireGuard VPN is disabled"
}