###############################################################################
# CONFIG: 04-DHCP-ALL-NETWORKS.RSC
# Description: DHCP server for all networks
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 4: DHCP SERVER - ALL NETWORKS"
:log info "================================================"

# DHCP Pools
/ip pool add name=dhcp-pool-mgmt ranges=192.168.20.10-192.168.20.250
/ip pool add name=dhcp-pool-b2b ranges=10.40.0.10-10.40.0.250
/ip pool add name=dhcp-pool-guest ranges=10.50.0.10-10.50.0.250
/ip pool add name=dhcp-pool-voice ranges=10.30.0.10-10.30.0.250
/ip pool add name=dhcp-pool-iptv ranges=10.60.0.10-10.60.0.250
/ip pool add name=dhcp-pool-storage ranges=10.70.0.10-10.70.0.250
/ip pool add name=dhcp-pool-oob ranges=10.99.0.10-10.99.0.250
/ip pool add name=dhcp-pool-hotspot ranges=10.100.0.10-10.100.0.250
/ip pool add name=dhcp-pool-cctv ranges=10.110.0.10-10.110.0.250
/ip pool add name=dhcp-pool-iot ranges=10.120.0.10-10.120.0.250

# DHCP Servers
/ip dhcp-server add name=dhcp-mgmt interface="vlan$vlanManagement-MGMT" \
  address-pool=dhcp-pool-mgmt lease-time=1d disabled=no
/ip dhcp-server add name=dhcp-b2b interface="vlan$vlanB2B-B2B" \
  address-pool=dhcp-pool-b2b lease-time=1d disabled=no
/ip dhcp-server add name=dhcp-guest interface="vlan$vlanGuest-GUEST" \
  address-pool=dhcp-pool-guest lease-time=4h disabled=no
/ip dhcp-server add name=dhcp-voice interface="vlan$vlanVoice-VOICE" \
  address-pool=dhcp-pool-voice lease-time=2h disabled=no
/ip dhcp-server add name=dhcp-iptv interface="vlan$vlanIPTV-IPTV" \
  address-pool=dhcp-pool-iptv lease-time=6h disabled=no
/ip dhcp-server add name=dhcp-storage interface="vlan$vlanStorage-STORAGE" \
  address-pool=dhcp-pool-storage lease-time=7d disabled=no
/ip dhcp-server add name=dhcp-oob interface="vlan$vlanMgmt-OOB" \
  address-pool=dhcp-pool-oob lease-time=7d disabled=no
/ip dhcp-server add name=dhcp-hotspot interface="vlan$vlanHotspot-HOTSPOT" \
  address-pool=dhcp-pool-hotspot lease-time=1h disabled=no
/ip dhcp-server add name=dhcp-cctv interface="vlan$vlanCCTV-CCTV" \
  address-pool=dhcp-pool-cctv lease-time=7d disabled=no
/ip dhcp-server add name=dhcp-iot interface="vlan$vlanIoT-IoT" \
  address-pool=dhcp-pool-iot lease-time=7d disabled=no

# DHCP Networks
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="MGMT_NET"
/ip dhcp-server network add address=10.40.0.0/24 gateway=10.40.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="B2B_NET"
/ip dhcp-server network add address=10.50.0.0/24 gateway=10.50.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="GUEST_NET"
/ip dhcp-server network add address=10.30.0.0/24 gateway=10.30.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="VOICE_NET"
/ip dhcp-server network add address=10.60.0.0/24 gateway=10.60.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="IPTV_NET"
/ip dhcp-server network add address=10.70.0.0/24 gateway=10.70.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="STORAGE_NET"
/ip dhcp-server network add address=10.99.0.0/24 gateway=10.99.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="OOB_NET"
/ip dhcp-server network add address=10.100.0.0/24 gateway=10.100.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="HOTSPOT_NET"
/ip dhcp-server network add address=10.110.0.0/24 gateway=10.110.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="CCTV_NET"
/ip dhcp-server network add address=10.120.0.0/24 gateway=10.120.0.1 \
  dns-server=8.8.8.8,1.1.1.1 comment="IOT_NET"

# DHCP Options
/ip dhcp-server option add name=router code=3 value=192.168.20.1
/ip dhcp-server option add name=dns code=6 value=8.8.8.8,1.1.1.1
/ip dhcp-server option add name=ntp code=42 value=time.google.com
/ip dhcp-server option add name=domain code=15 value=isp.local

:log info "DHCP configuration complete"