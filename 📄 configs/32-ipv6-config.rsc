###############################################################################
# CONFIG: 32-IPV6-CONFIG.RSC
# Description: IPv6 configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 32: IPv6 CONFIGURATION"
:log info "================================================"

:if ($enableIPv6 = "yes") do={

  # IPv6 Addresses
  /ipv6 address add address=$ipv6Prefix::1/64 interface=bridge-local
  /ipv6 address add address=$ipv6PPPoE::1/64 interface="vlan$vlanPPPoE-PPPoE"
  /ipv6 address add address=$ipv6Management::1/64 interface="vlan$vlanManagement-MGMT"
  
  # IPv6 Routes
  /ipv6 route add dst-address=::/0 gateway=$upstream1IP distance=1
  :if ($enableFailover = "yes") do={
    /ipv6 route add dst-address=::/0 gateway=$upstream2IP distance=2
  }
  
  # IPv6 DHCP Pool
  /ipv6 pool add name=dhcpv6-pool prefix=$ipv6Prefix::/64 prefix-length=64
  /ipv6 pool add name=dhcpv6-pppoe prefix=$ipv6PPPoE::/64 prefix-length=64
  
  # IPv6 DHCP Server
  /ipv6 dhcp-server add name=dhcpv6-mgmt interface="vlan$vlanManagement-MGMT" \
    address-pool=dhcpv6-pool lease-time=1d
  /ipv6 dhcp-server add name=dhcpv6-pppoe interface="vlan$vlanPPPoE-PPPoE" \
    address-pool=dhcpv6-pppoe lease-time=1d
  
  # IPv6 DNS
  /ip dns set servers=2001:4860:4860::8888,2001:4860:4860::8844,2606:4700:4700::1111
  
  # IPv6 Firewall - RAW
  /ipv6 firewall raw
  add action=drop chain=prerouting connection-state=invalid comment="DROP_INVALID_V6"
  add action=drop chain=prerouting protocol=icmpv6 icmp-options=4:0-255 comment="DROP_ICMP_PARAMETER"
  
  # IPv6 Firewall - Filter
  /ipv6 firewall filter
  add action=accept chain=input connection-state=established,related comment="ACCEPT_ESTABLISHED_V6"
  add action=accept chain=input protocol=icmpv6 comment="ACCEPT_ICMPV6"
  add action=accept chain=input src-address-list=TRUSTED-NETWORKS comment="ACCEPT_TRUSTED_V6"
  add action=accept chain=input in-interface="vlan$vlanPPPoE-PPPoE" comment="ACCEPT_PPPOE_V6"
  add action=drop chain=input comment="DROP_OTHER_INPUT_V6"
  
  # IPv6 Router Advertisement
  /ipv6 nd set [find] interface=bridge-local other-config=yes managed-address-configuration=yes
  
  # IPv6 Neighbor Discovery
  /ipv6 nd set [find] interface=bridge-local ra-interval=5m-10m
  
  # IPv6 SLAAC
  /ipv6 nd prefix add interface=bridge-local prefix=$ipv6Prefix::/64
  
  :log info "IPv6 configuration complete"
} else={
  :log info "IPv6 is disabled"
}