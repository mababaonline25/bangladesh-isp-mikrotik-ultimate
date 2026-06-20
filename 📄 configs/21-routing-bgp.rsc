###############################################################################
# CONFIG: 21-ROUTING-BGP.RSC
# Description: BGP routing configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 21: ROUTING - BGP"
:log info "================================================"

:if ($enableBGP = "yes") do={

  # BGP Instance
  /routing bgp instance add name=bgp-instance as=65001 router-id=192.168.20.1 \
    comment="BGP_INSTANCE"
  
  # BGP Peers
  /routing bgp peer add name=upstream-peer instance=bgp-instance \
    remote-address=$upstream1IP remote-as=65000 multihop=no \
    comment="UPSTREAM_BGP"
  
  /routing bgp peer add name=backup-peer instance=bgp-instance \
    remote-address=$upstream2IP remote-as=65000 multihop=no \
    comment="BACKUP_BGP"
  
  :if ($enableBDIX = "yes") do={
    /routing bgp peer add name=bdix-peer instance=bgp-instance \
      remote-address=$bdixPeerIP remote-as=65003 multihop=no \
      comment="BDIX_BGP"
  }
  
  # BGP Networks
  /routing bgp network add network=10.0.0.0/8 synchronize=no \
    comment="BGP_NETWORK_10"
  /routing bgp network add network=192.168.20.0/24 synchronize=no \
    comment="BGP_NETWORK_MGMT"
  
  # BGP Filtering - Inbound
  /routing filter add chain=bgp-in prefix=0.0.0.0/0 action=accept \
    comment="ACCEPT_DEFAULT"
  /routing filter add chain=bgp-in prefix=10.0.0.0/8 action=reject \
    comment="REJECT_RFC1918"
  /routing filter add chain=bgp-in prefix=192.168.0.0/16 action=reject \
    comment="REJECT_RFC1918_2"
  /routing filter add chain=bgp-in prefix=172.16.0.0/12 action=reject \
    comment="REJECT_RFC1918_3"
  /routing filter add chain=bgp-in prefix=224.0.0.0/4 action=reject \
    comment="REJECT_MULTICAST"
  
  # BGP Filtering - Outbound
  /routing filter add chain=bgp-out prefix=10.0.0.0/8 action=accept \
    comment="ACCEPT_10_NETWORK"
  /routing filter add chain=bgp-out prefix=192.168.20.0/24 action=accept \
    comment="ACCEPT_MGMT_NETWORK"
  /routing filter add chain=bgp-out prefix=0.0.0.0/0 action=reject \
    comment="REJECT_DEFAULT"
  
  # BGP Communities
  /routing filter add chain=bgp-in set-bgp-community=65001:100 \
    comment="SET_COMMUNITY"
  
  # BGP Route Reflection
  /routing bgp instance set bgp-instance client-to-client-reflection=yes
  
  :log info "BGP configuration complete"
} else={
  :log info "BGP is disabled"
}