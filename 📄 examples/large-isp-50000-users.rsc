###############################################################################
# EXAMPLE: LARGE ISP - 50,000 USERS
# Version: 5.0.0
# Description: Configuration for large ISP with up to 50,000 users
# Hardware: CCR2216 or Multiple CCRs
# Bandwidth: 10Gbps+ Upstream + BDIX + Multiple IIG
###############################################################################

:log info "================================================"
:log info "LARGE ISP CONFIGURATION (50,000 USERS)"
:log info "================================================"

# ============================================================================
# BASIC CONFIGURATION
# ============================================================================

/system identity set name="Large-ISP-Dhaka-DC"
/system clock set time-zone-name=Asia/Dhaka

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

# Bridges
/interface bridge add name=bridge-core protocol-mode=none
/interface bridge add name=bridge-mgmt protocol-mode=none
/interface bridge add name=bridge-dmz protocol-mode=none

# Bonding
/interface bonding add name=bond-core mode=802.3ad slaves=sfp-sfpplus1,sfp-sfpplus2,sfp-sfpplus3,sfp-sfpplus4 lacp-rate=1s
/interface bonding add name=bond-upstream mode=802.3ad slaves=sfp-sfpplus5,sfp-sfpplus6 lacp-rate=1s
/interface bonding add name=bond-bdix mode=802.3ad slaves=sfp-sfpplus7,sfp-sfpplus8 lacp-rate=1s

# VLANs
/interface vlan add name=vlan10-PPPoE vlan-id=10 interface=bridge-core
/interface vlan add name=vlan20-MGMT vlan-id=20 interface=bridge-mgmt
/interface vlan add name=vlan30-Voice vlan-id=30 interface=bridge-core
/interface vlan add name=vlan40-B2B vlan-id=40 interface=bridge-core
/interface vlan add name=vlan50-Guest vlan-id=50 interface=bridge-core
/interface vlan add name=vlan60-IPTV vlan-id=60 interface=bridge-core
/interface vlan add name=vlan70-Storage vlan-id=70 interface=bridge-core
/interface vlan add name=vlan80-DMZ vlan-id=80 interface=bridge-dmz
/interface vlan add name=vlan99-OOB vlan-id=99 interface=bridge-mgmt
/interface vlan add name=vlan100-Hotspot vlan-id=100 interface=bridge-core
/interface vlan add name=vlan110-CCTV vlan-id=110 interface=bridge-core
/interface vlan add name=vlan120-IoT vlan-id=120 interface=bridge-core

# IP Addresses
/ip address add address=192.168.20.1/24 interface=vlan20-MGMT
/ip address add address=10.10.0.1/16 interface=vlan10-PPPoE
/ip address add address=10.30.0.1/24 interface=vlan30-Voice
/ip address add address=10.40.0.1/24 interface=vlan40-B2B
/ip address add address=10.50.0.1/24 interface=vlan50-Guest
/ip address add address=10.60.0.1/24 interface=vlan60-IPTV
/ip address add address=10.70.0.1/24 interface=vlan70-Storage
/ip address add address=10.80.0.1/24 interface=vlan80-DMZ
/ip address add address=10.99.0.1/24 interface=vlan99-OOB
/ip address add address=10.100.0.1/24 interface=vlan100-Hotspot
/ip address add address=10.110.0.1/24 interface=vlan110-CCTV
/ip address add address=10.120.0.1/24 interface=vlan120-IoT

# Upstream IPs
/ip address add address=103.xxx.xxx.2/30 interface=sfp-sfpplus5
/ip address add address=103.yyy.yyy.2/30 interface=sfp-sfpplus6
/ip address add address=103.zzz.zzz.2/30 interface=sfp-sfpplus7
/ip address add address=172.16.100.2/30 interface=sfp-sfpplus8

# ============================================================================
# DHCP CONFIGURATION
# ============================================================================

/ip pool add name=dhcp-pool-mgmt ranges=192.168.20.10-192.168.20.250
/ip pool add name=dhcp-pool-b2b ranges=10.40.0.10-10.40.0.250
/ip pool add name=dhcp-pool-guest ranges=10.50.0.10-10.50.0.250
/ip pool add name=dhcp-pool-voice ranges=10.30.0.10-10.30.0.250
/ip pool add name=dhcp-pool-iptv ranges=10.60.0.10-10.60.0.250
/ip pool add name=dhcp-pool-storage ranges=10.70.0.10-10.70.0.250
/ip pool add name=dhcp-pool-dmz ranges=10.80.0.10-10.80.0.250
/ip pool add name=dhcp-pool-oob ranges=10.99.0.10-10.99.0.250
/ip pool add name=dhcp-pool-hotspot ranges=10.100.0.10-10.100.0.250
/ip pool add name=dhcp-pool-cctv ranges=10.110.0.10-10.110.0.250
/ip pool add name=dhcp-pool-iot ranges=10.120.0.10-10.120.0.250

/ip dhcp-server add name=dhcp-mgmt interface=vlan20-MGMT address-pool=dhcp-pool-mgmt
/ip dhcp-server add name=dhcp-b2b interface=vlan40-B2B address-pool=dhcp-pool-b2b
/ip dhcp-server add name=dhcp-guest interface=vlan50-Guest address-pool=dhcp-pool-guest
/ip dhcp-server add name=dhcp-voice interface=vlan30-Voice address-pool=dhcp-pool-voice
/ip dhcp-server add name=dhcp-iptv interface=vlan60-IPTV address-pool=dhcp-pool-iptv
/ip dhcp-server add name=dhcp-storage interface=vlan70-Storage address-pool=dhcp-pool-storage
/ip dhcp-server add name=dhcp-dmz interface=vlan80-DMZ address-pool=dhcp-pool-dmz
/ip dhcp-server add name=dhcp-oob interface=vlan99-OOB address-pool=dhcp-pool-oob
/ip dhcp-server add name=dhcp-hotspot interface=vlan100-Hotspot address-pool=dhcp-pool-hotspot
/ip dhcp-server add name=dhcp-cctv interface=vlan110-CCTV address-pool=dhcp-pool-cctv
/ip dhcp-server add name=dhcp-iot interface=vlan120-IoT address-pool=dhcp-pool-iot

# ============================================================================
# PPPOE CONFIGURATION
# ============================================================================

/ip pool add name=pppoe-pool ranges=10.10.1.2-10.10.255.254

# All Speed Profiles
:local speeds { "5"; "10"; "20"; "30"; "40"; "50"; "60"; "70"; "80"; "90"; "100"; "120"; "140"; "160"; "180"; "200"; "300"; "500"; "700"; "1000" }
:foreach speed in=$speeds do={
    /ppp profile add name="PKG-$speed-MBPS" local-address=10.10.0.1 remote-address=pppoe-pool \
        rate-limit="$speed"."M/$speed"."M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes
}

/ppp profile add name="PKG-UNLIMITED" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="0/0" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

# BDIX Packages
/ppp profile add name="PKG-BDIX-20" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="20M/20M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/ppp profile add name="PKG-BDIX-50" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="50M/50M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

/ppp profile add name="PKG-BDIX-100" local-address=10.10.0.1 remote-address=pppoe-pool \
    rate-limit="100M/100M" dns-server=8.8.8.8,1.1.1.1 use-encryption=yes

# Group Profiles
/ppp profile add name="GROUP-RESIDENTIAL" local-address=10.10.0.1 remote-address=pppoe-pool
/ppp profile add name="GROUP-BUSINESS" local-address=10.10.0.1 remote-address=pppoe-pool
/ppp profile add name="GROUP-PREMIUM" local-address=10.10.0.1 remote-address=pppoe-pool
/ppp profile add name="GROUP-ENTERPRISE" local-address=10.10.0.1 remote-address=pppoe-pool

# PPPoE Server with Multiple Interfaces
/interface pppoe-server server add service-name="Large-ISP-PPPoE-1" interface=vlan10-PPPoE \
    one-session-per-host=yes max-sessions=20000

/interface pppoe-server server add service-name="Large-ISP-PPPoE-2" interface=vlan10-PPPoE \
    one-session-per-host=yes max-sessions=20000

/interface pppoe-server server add service-name="Large-ISP-PPPoE-3" interface=vlan10-PPPoE \
    one-session-per-host=yes max-sessions=10000

# ============================================================================
# RADIUS CONFIGURATION
# ============================================================================

# Primary RADIUS Cluster
/radius add address=10.1.200.2 secret=radius-secret service=ppp,hotspot
/radius add address=10.1.200.3 secret=radius-secret service=ppp,hotspot
/radius add address=10.1.200.4 secret=radius-secret service=ppp,hotspot

# RadSec Configuration
/certificate import file-name=ca.cert.pem passphrase=""
/certificate import file-name=client.cert.pem passphrase=""
/certificate import file-name=client.key.pem passphrase=""

/radius add address=radsec.isp.com protocol=radsec certificate=client.cert.pem_0 \
    service=ppp,hotspot authentication-port=2083 accounting-port=2083 secret="" timeout=3s

/radius incoming set accept=yes port=3799
/ppp aaa set use-radius=yes accounting=yes interim-update=5m

/ppp profile add name="radius-default" use-radius=yes
/ppp profile add name="radius-premium" use-radius=yes
/ppp profile add name="radius-business" use-radius=yes
/ppp profile add name="radius-residential" use-radius=yes
/ppp profile add name="radius-enterprise" use-radius=yes

# CoA Configuration
/radius coa set enabled=yes port=1700
/radius coa add address=10.1.200.2 secret=radius-secret
/radius coa add address=10.1.200.3 secret=radius-secret
/radius coa add address=10.1.200.4 secret=radius-secret

# ============================================================================
# HOTSPOT CONFIGURATION
# ============================================================================

/ip hotspot profile add name=hotspot-profile hotspot-address=10.100.0.1 \
    dns-name="hotspot.large-isp.com" login-by=http-chap,http-pap,https,cookie,trial \
    radius-accounting=yes radius-interim-update=2m use-radius=yes

/ip hotspot add name=hotspot1 interface=vlan100-Hotspot address-pool=dhcp-pool-hotspot \
    profile=hotspot-profile

/ip hotspot walled-garden ip add dst-address=8.8.8.8 action=accept
/ip hotspot walled-garden ip add dst-address=1.1.1.1 action=accept
/ip hotspot walled-garden add dst-host=*.google.com action=accept
/ip hotspot walled-garden add dst-host=*.facebook.com action=accept
/ip hotspot walled-garden add dst-host=*.apple.com action=accept
/ip hotspot walled-garden add dst-host=*.microsoft.com action=accept
/ip hotspot walled-garden add dst-host=*.captive.apple.com action=accept

# OpenRoaming / Hotspot 2.0
/certificate import file-name=iw-rsa-root-ca.cert.pem passphrase=""
/certificate import file-name=iw-rsa-radsec-signing-ca.cert.pem passphrase=""

/interface wireless interworking-profiles add name=openroaming \
    access-network-type=free-public-network internet=yes

/interface wireless hotspot20-profiles add name=openroaming \
    domain-names=hotspot.large-isp.com operator-names="LargeISP:eng"

/interface wireless nai-realms add profile=openroaming realm=hotspot.large-isp.com \
    eap-methods="eap-ttls:non-eap-pap;eap-tls:"

/interface wireless nai-realms add profile=openroaming realm=openroaming.net \
    eap-methods="eap-ttls:;eap-tls:"

# ============================================================================
# VPN CONFIGURATION
# ============================================================================

/ip pool add name=vpn-pool ranges=10.20.1.2-10.20.255.254
/ip pool add name=vpn-premium-pool ranges=10.20.1.2-10.20.10.254

# VPN Profiles
/ppp profile add name="vpn-10mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="10M/10M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

/ppp profile add name="vpn-20mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="20M/20M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

/ppp profile add name="vpn-50mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="50M/50M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

/ppp profile add name="vpn-100mbps" local-address=10.20.0.1 remote-address=vpn-premium-pool \
    rate-limit="100M/100M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

/ppp profile add name="vpn-unlimited" local-address=10.20.0.1 remote-address=vpn-premium-pool \
    rate-limit="0/0" dns-server=8.8.8.8,1.1.1.1 use-encryption=required

# VPN Servers
/interface pptp-server server set enabled=yes authentication=mschap1,mschap2
/interface l2tp-server server set enabled=yes authentication=mschap1,mschap2 ipsec-secret=VPN-IPSEC-SECRET
/interface sstp-server server set enabled=yes authentication=mschap1,mschap2
/interface ovpn-server server set enabled=yes auth=sha1 cipher=aes256

# WireGuard
/interface wireguard add name=wg-main private-key="YOUR-PRIVATE-KEY" listen-port=13231
/ip address add address=10.200.0.1/24 interface=wg-main

# ============================================================================
# IPSEC VPN (IKEv1/IKEv2)
# ============================================================================

/ip ipsec proposal add name=ikev2-proposal auth-algorithms=sha256 enc-algorithms=aes-256-cbc lifetime=8h pfs-group=modp2048
/ip ipsec peer add address=0.0.0.0/0 exchange-mode=ike2 proposal-check=obey
/ip ipsec policy add dst-address=0.0.0.0/0 src-address=0.0.0.0/0 action=encrypt level=unique \
    proposal=ikev2-proposal tunnel=yes
/ip ipsec mode-config add name=ipsec-vpn address-pool=vpn-pool dns-server=8.8.8.8,1.1.1.1
/ip ipsec identity add peer=any secret=IPSEC-SECRET mode-config=ipsec-vpn

# ============================================================================
# FIREWALL CONFIGURATION
# ============================================================================

# Address Lists
/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.40.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.99.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.80.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=103.0.0.0/8 list=BDIX-NETWORKS
/ip firewall address-list add address=202.0.0.0/8 list=BDIX-NETWORKS
/ip firewall address-list add address=110.0.0.0/8 list=BDIX-NETWORKS
/ip firewall address-list add address=10.10.0.0/16 list=PPPOE-USERS
/ip firewall address-list add address=10.20.0.0/16 list=VPN-USERS
/ip firewall address-list add address=10.50.0.0/24 list=GUEST-NETWORKS
/ip firewall address-list add address=10.120.0.0/24 list=IOT-NETWORKS

# RAW Rules - Layer 1 Protection
/ip firewall raw
add action=drop chain=prerouting connection-state=invalid
add action=drop chain=prerouting protocol=tcp src-port=0
add action=drop chain=prerouting protocol=udp src-port=0
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,syn
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,rst
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,!ack
add action=drop chain=prerouting protocol=tcp tcp-flags=syn,rst
add action=drop chain=prerouting protocol=icmp packet-size=1025-65535
add action=drop chain=prerouting protocol=icmp fragment=yes
add action=drop chain=prerouting ipv4-options=any

# DDoS Protection - Advanced
add action=add-src-to-address-list chain=prerouting protocol=tcp psd=21,3s,3,1 \
    address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=tcp tcp-flags=syn \
    connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=udp \
    connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting protocol=icmp limit=5,5 \
    address-list=DDOS-BLACKLIST address-list-timeout=1h
add action=drop chain=prerouting src-address-list=DDOS-BLACKLIST

# Brute Force Protection
add action=add-src-to-address-list chain=prerouting dst-port=8291 protocol=tcp \
    src-address-list=!TRUSTED-NETWORKS connection-state=new \
    address-list=WINBOX-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting dst-port=22 protocol=tcp \
    src-address-list=!TRUSTED-NETWORKS connection-state=new \
    address-list=SSH-BLACKLIST address-list-timeout=1h
add action=add-src-to-address-list chain=prerouting dst-port=80,443 protocol=tcp \
    src-address-list=!TRUSTED-NETWORKS connection-state=new \
    address-list=HTTP-BLACKLIST address-list-timeout=1h
add action=drop chain=prerouting src-address-list=WINBOX-BLACKLIST,SSH-BLACKLIST,HTTP-BLACKLIST

# Filter Rules - Input Chain
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=input protocol=icmp
add action=accept chain=input src-address-list=TRUSTED-NETWORKS
add action=accept chain=input in-interface=vlan10-PPPoE
add action=accept chain=input in-interface=vlan100-Hotspot
add action=accept chain=input protocol=tcp dst-port=1723,1701,443,1194,13231
add action=accept chain=input protocol=ospf
add action=accept chain=input protocol=tcp dst-port=179
add action=accept chain=input protocol=udp dst-port=500,4500
add action=accept chain=input protocol=esp
add action=drop chain=input

# Filter Rules - Forward Chain
add action=fasttrack-connection chain=forward connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=forward out-interface=sfp-sfpplus5
add action=accept chain=forward out-interface=sfp-sfpplus6
add action=accept chain=forward out-interface=sfp-sfpplus7
add action=accept chain=forward out-interface=sfp-sfpplus8
add action=accept chain=forward src-address=10.0.0.0/8 dst-address=10.0.0.0/8
add action=drop chain=forward src-address=10.50.0.0/24 dst-address=10.0.0.0/8
add action=drop chain=forward src-address=10.120.0.0/24 dst-address=10.0.0.0/8
add action=drop chain=forward

# Layer 7 Filtering
/ip firewall layer7-protocol add name=block-bittorrent regexp="^(\\x13bittorrent|\\x19BitTorrent protocol)"
/ip firewall layer7-protocol add name=block-facebook regexp="facebook.com|fb.com|fbcdn.net"
/ip firewall layer7-protocol add name=block-youtube regexp="youtube.com|youtu.be|googlevideo.com"

/ip firewall filter add chain=forward layer7-protocol=block-bittorrent action=drop

# NAT
/ip firewall nat
add action=masquerade chain=srcnat out-interface=sfp-sfpplus5
add action=masquerade chain=srcnat out-interface=sfp-sfpplus6
add action=masquerade chain=srcnat out-interface=sfp-sfpplus7
add action=accept chain=srcnat out-interface=sfp-sfpplus8

# Port Forwarding
add action=dst-nat chain=dstnat protocol=tcp dst-port=80 to-addresses=10.80.0.10 to-ports=80
add action=dst-nat chain=dstnat protocol=tcp dst-port=443 to-addresses=10.80.0.10 to-ports=443
add action=dst-nat chain=dstnat protocol=tcp dst-port=25 to-addresses=10.80.0.20 to-ports=25

# ============================================================================
# ROUTING - STATIC, BGP, OSPF
# ============================================================================

# Static Routes
/ip route add dst-address=0.0.0.0/0 gateway=103.xxx.xxx.1 distance=1 check-gateway=ping
/ip route add dst-address=0.0.0.0/0 gateway=103.yyy.yyy.1 distance=2 check-gateway=ping
/ip route add dst-address=0.0.0.0/0 gateway=103.zzz.zzz.1 distance=3 check-gateway=ping

# BDIX Routes
/ip route add dst-address=103.0.0.0/8 gateway=172.16.100.1 distance=1
/ip route add dst-address=202.0.0.0/8 gateway=172.16.100.1 distance=1
/ip route add dst-address=110.0.0.0/8 gateway=172.16.100.1 distance=1

# BGP Configuration
/routing bgp instance add name=bgp-instance as=65001 router-id=192.168.20.1
/routing bgp peer add name=upstream1-peer instance=bgp-instance remote-address=103.xxx.xxx.1 remote-as=65000
/routing bgp peer add name=upstream2-peer instance=bgp-instance remote-address=103.yyy.yyy.1 remote-as=65000
/routing bgp peer add name=upstream3-peer instance=bgp-instance remote-address=103.zzz.zzz.1 remote-as=65000
/routing bgp peer add name=bdix-peer instance=bgp-instance remote-address=172.16.100.1 remote-as=65003

/routing bgp network add network=10.0.0.0/8 synchronize=no
/routing bgp network add network=192.168.20.0/24 synchronize=no

/routing filter add chain=bgp-in prefix=0.0.0.0/0 action=accept
/routing filter add chain=bgp-in prefix=10.0.0.0/8 action=reject
/routing filter add chain=bgp-in prefix=192.168.0.0/16 action=reject

/routing filter add chain=bgp-out prefix=10.0.0.0/8 action=accept
/routing filter add chain=bgp-out prefix=192.168.20.0/24 action=accept
/routing filter add chain=bgp-out prefix=0.0.0.0/0 action=reject

# OSPF Configuration
/routing ospf instance set [find] router-id=192.168.20.1
/routing ospf area add name=backbone area-id=0.0.0.0
/routing ospf area add name=stub area-id=0.0.0.1 stub=yes
/routing ospf area add name=dmz area-id=0.0.0.2

/routing ospf interface add interface=bridge-core area=backbone passive=yes
/routing ospf interface add interface=sfp-sfpplus5 area=backbone network-type=point-to-point
/routing ospf interface add interface=sfp-sfpplus6 area=backbone network-type=point-to-point
/routing ospf interface add interface=sfp-sfpplus7 area=backbone network-type=point-to-point
/routing ospf interface add interface=sfp-sfpplus8 area=backbone network-type=point-to-point
/routing ospf interface add interface=vlan10-PPPoE area=stub passive=yes
/routing ospf interface add interface=vlan100-Hotspot area=stub passive=yes
/routing ospf interface add interface=vlan80-DMZ area=dmz passive=yes

# ============================================================================
# VRRP - HIGH AVAILABILITY
# ============================================================================

/interface vrrp add name=vrrp-mgmt interface=vlan20-MGMT vrid=1 priority=100 address=192.168.20.1
/interface vrrp add name=vrrp-b2b interface=vlan40-B2B vrid=2 priority=100 address=10.40.0.1
/interface vrrp add name=vrrp-guest interface=vlan50-Guest vrid=3 priority=100 address=10.50.0.1
/interface vrrp add name=vrrp-hotspot interface=vlan100-Hotspot vrid=4 priority=100 address=10.100.0.1
/interface vrrp add name=vrrp-pppoe interface=vlan10-PPPoE vrid=5 priority=100 address=10.10.0.1

/interface vrrp set [find] authentication=simple password=VRRP-SECRET
/interface vrrp set [find] preemption-mode=yes
/interface vrrp set vrrp-mgmt track-interface=sfp-sfpplus5 priority=10

# ============================================================================
# FAILOVER & LOAD BALANCING
# ============================================================================

/routing table add name=to-wan1 fib
/routing table add name=to-wan2 fib
/routing table add name=to-wan3 fib

/ip route add dst-address=0.0.0.0/0 gateway=103.xxx.xxx.1 routing-mark=to-wan1 distance=1
/ip route add dst-address=0.0.0.0/0 gateway=103.yyy.yyy.1 routing-mark=to-wan2 distance=1
/ip route add dst-address=0.0.0.0/0 gateway=103.zzz.zzz.1 routing-mark=to-wan3 distance=1

/ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan1-conn per-connection-classifier=src-address-and-port:3/0
/ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan2-conn per-connection-classifier=src-address-and-port:3/1
/ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan3-conn per-connection-classifier=src-address-and-port:3/2
/ip firewall mangle add chain=prerouting connection-mark=wan1-conn action=mark-routing new-routing-mark=to-wan1
/ip firewall mangle add chain=prerouting connection-mark=wan2-conn action=mark-routing new-routing-mark=to-wan2
/ip firewall mangle add chain=prerouting connection-mark=wan3-conn action=mark-routing new-routing-mark=to-wan3

# Failover Script
/system script add name=failover-check source={
    :local primary [/ping 103.xxx.xxx.1 count=3]
    :local secondary [/ping 103.yyy.yyy.1 count=3]
    :local tertiary [/ping 103.zzz.zzz.1 count=3]
    
    :if ($primary = 0) do={
        /ip route set [find comment="PRIMARY_DEFAULT"] distance=10
        :log warning "PRIMARY_UPSTREAM_DOWN"
    } else={
        /ip route set [find comment="PRIMARY_DEFAULT"] distance=1
    }
    
    :if ($secondary = 0) do={
        /ip route set [find comment="BACKUP_DEFAULT"] distance=10
    } else={
        /ip route set [find comment="BACKUP_DEFAULT"] distance=2
    }
}

/system scheduler add name=failover-scheduler interval=10s on-event=failover-check

# ============================================================================
# QoS - ADVANCED QUEUE TREE
# ============================================================================

/queue type add name="pcq-download" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="pcq-upload" kind=pcq pcq-rate=0 pcq-classifier=src-address
/queue type add name="pcq-premium-download" kind=pcq pcq-rate=100M pcq-classifier=dst-address
/queue type add name="pcq-premium-upload" kind=pcq pcq-rate=100M pcq-classifier=src-address
/queue type add name="pcq-business-download" kind=pcq pcq-rate=50M pcq-classifier=dst-address
/queue type add name="pcq-business-upload" kind=pcq pcq-rate=50M pcq-classifier=src-address

/queue tree
add name="TOTAL_UPLOAD" parent=global packet-mark=upload queue=pcq-upload
add name="TOTAL_DOWNLOAD" parent=global packet-mark=download queue=pcq-download

add name="PPPOE_UPLOAD" parent=TOTAL_UPLOAD packet-mark=upload-pppoe queue=pcq-upload
add name="PPPOE_DOWNLOAD" parent=TOTAL_DOWNLOAD packet-mark=download queue=pcq-download

add name="B2B_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=b2b-traffic queue=pcq-premium-download
add name="B2B_UPLOAD" parent=TOTAL_UPLOAD packet-mark=b2b-traffic queue=pcq-premium-upload

add name="VOICE_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=voice-traffic queue=pcq-premium-download
add name="VOICE_UPLOAD" parent=TOTAL_UPLOAD packet-mark=voice-traffic queue=pcq-premium-upload

add name="IPTV_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=iptv-traffic queue=pcq-premium-download

add name="GUEST_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=guest-traffic queue=pcq-business-download
add name="GUEST_UPLOAD" parent=TOTAL_UPLOAD packet-mark=guest-traffic queue=pcq-business-upload

add name="HOTSPOT_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=hotspot-traffic queue=pcq-business-download
add name="HOTSPOT_UPLOAD" parent=TOTAL_UPLOAD packet-mark=hotspot-traffic queue=pcq-business-upload

/queue simple add name="TOTAL-LIMIT-1" target=sfp-sfpplus5 max-limit=4000M/4000M
/queue simple add name="TOTAL-LIMIT-2" target=sfp-sfpplus6 max-limit=4000M/4000M
/queue simple add name="TOTAL-LIMIT-3" target=sfp-sfpplus7 max-limit=2000M/2000M

# ============================================================================
# CONTAINER (DOCKER) SUPPORT
# ============================================================================

/interface veth add name=veth1 address=172.18.0.2/16 gateway=172.18.0.1

/file mkdir containers/nginx
/file mkdir containers/adguard
/file mkdir containers/unbound

/container add name=nginx image=nginx:latest interface=veth1 root-dir=containers/nginx
/container add name=adguard image=adguard/adguardhome:latest interface=veth1 root-dir=containers/adguard
/container add name=unbound image=alpine/unbound:latest interface=veth1 root-dir=containers/unbound

/container start nginx
/container start adguard
/container start unbound

# ============================================================================
# SNMP MONITORING
# ============================================================================

/snmp set enabled=yes
/snmp set contact=noc@large-isp.com
/snmp set location=Dhaka-DC

/snmp community add name=public addresses=10.99.0.0/24 read-only=yes
/snmp community add name=private addresses=192.168.20.0/24 read-write=yes

/snmp set trap-community=public
/snmp set trap-target=10.99.0.10
/snmp set trap-version=2c

# ============================================================================
# DNS
# ============================================================================

/ip dns set servers=8.8.8.8,1.1.1.1,8.8.4.4,208.67.222.222
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=20480KiB
/ip dns set use-doh-server=https://cloudflare-dns.com/dns-query
/ip dns set use-doh=yes

# ============================================================================
# SYSTEM HARDENING
# ============================================================================

/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip service set winbox address=192.168.20.0/24,10.99.0.0/24
/ip service set ssh address=192.168.20.0/24,10.99.0.0/24

/ip ssh set strong-crypto=yes
/ip ssh set host-key-size=4096
/ip ssh set allow-none-crypto=no

/interface mac-telnet set allowed-interface-list=!dynamic
/interface mac-winbox set allowed-interface-list=!dynamic
/ip neighbor discovery-settings set discover-interface-list=!dynamic

# ============================================================================
# MONITORING & ALERTS
# ============================================================================

# Netwatch
/tool netwatch add host=8.8.8.8 interval=10s timeout=2s \
    up-script=":log info \"INTERNET-UP\"" \
    down-script=":log warning \"INTERNET-DOWN\""

/tool netwatch add host=103.xxx.xxx.1 interval=10s timeout=2s \
    up-script=":log info \"UPSTREAM1-UP\"" \
    down-script=":log warning \"UPSTREAM1-DOWN\""

/tool netwatch add host=103.yyy.yyy.1 interval=10s timeout=2s \
    up-script=":log info \"UPSTREAM2-UP\"" \
    down-script=":log warning \"UPSTREAM2-DOWN\""

/tool netwatch add host=103.zzz.zzz.1 interval=10s timeout=2s \
    up-script=":log info \"UPSTREAM3-UP\"" \
    down-script=":log warning \"UPSTREAM3-DOWN\""

# System Health
/system script add name=system-health source={
    :local cpu [/system resource get cpu-load]
    :local mem [/system resource get free-memory]
    :local disk [/system resource get free-hdd-space]
    :local totalMem [/system resource get total-memory]
    :local usedMem ($totalMem - $mem)
    :local memPercent ($usedMem * 100 / $totalMem)
    :local temperature [/system health get temperature]
    
    :if ($cpu > 80) do={:log warning "HIGH_CPU: $cpu%"}
    :if ($memPercent > 90) do={:log warning "HIGH_MEMORY: $memPercent%"}
    :if ($disk < 100000000) do={:log warning "LOW_DISK: $disk bytes"}
    :if ($temperature > 70) do={:log warning "HIGH_TEMP: $temperature°C"}
    :if ($cpu > 90 || $memPercent > 95) do={
        /tool e-mail send to=noc@large-isp.com subject="ALERT: Router Large-ISP" \
            body="CPU: $cpu%, Memory: $memPercent%, Temp: $temperature°C"
    }
}

/system scheduler add name=health-check interval=5m on-event=system-health

# Session Monitor
/system script add name=session-monitor source={
    :local activeUsers [/ppp active print count-only]
    :local maxUsers 50000
    :if ($activeUsers > $maxUsers) do={
        :log warning "MAX_USERS_LIMIT: $activeUsers"
        /tool e-mail send to=noc@large-isp.com subject="ALERT: Max Users Limit" \
            body="Active PPPoE Users: $activeUsers"
    }
}

/system scheduler add name=session-check interval=5m on-event=session-monitor

# Traffic Monitor
/system script add name=traffic-monitor source={
    :local rx [/interface monitor-traffic sfp-sfpplus5 once as-value]
    :local tx [/interface monitor-traffic sfp-sfpplus5 once as-value]
    :local rxRate ($rx->"rx-bits-per-second")
    :local txRate ($tx->"tx-bits-per-second")
    
    :if ($rxRate > 8000000000) do={:log warning "HIGH_RX: $rxRate bps"}
    :if ($txRate > 8000000000) do={:log warning "HIGH_TX: $txRate bps"}
}

/system scheduler add name=traffic-monitor interval=5m on-event=traffic-monitor

# ============================================================================
# BACKUP
# ============================================================================

/system scheduler add name=daily-backup start-time=02:00:00 interval=1d on-event={
    /export file=backup-([/system clock get date]).rsc
    /system backup save name=backup-([/system clock get date]).backup
    :log info ("Backup created: backup-" . [/system clock get date] . ".rsc")
}

/system scheduler add name=weekly-backup start-time=03:00:00 interval=7d on-event={
    /export file=backup-weekly-([/system clock get date]).rsc
    /system backup save name=backup-weekly-([/system clock get date]).backup
    :log info ("Weekly backup created")
}

/system scheduler add name=offsite-backup start-time=04:00:00 interval=1d on-event={
    /tool fetch url="ftp://backup.large-isp.com/backup/" \
        file=backup-([/system clock get date]).backup
}

# ============================================================================
# GRAPHING
# ============================================================================

/tool graphing interface add interface=bridge-core
/tool graphing interface add interface=sfp-sfpplus5
/tool graphing interface add interface=sfp-sfpplus6
/tool graphing interface add interface=sfp-sfpplus7
/tool graphing interface add interface=vlan10-PPPoE
/tool graphing interface add interface=vlan20-MGMT
/tool graphing interface add interface=vlan100-Hotspot

/tool graphing resource

# ============================================================================
# COMPLETION
# ============================================================================

:log info "================================================"
:log info "LARGE ISP CONFIGURATION COMPLETE"
:log info "================================================"
:log info "Company: Large-ISP"
:log info "Location: Dhaka-DC"
:log info "Management IP: 192.168.20.1"
:log info "PPPoE Service: Large-ISP-PPPoE"
:log info "RADIUS: Enabled (10.1.200.2, 10.1.200.3, 10.1.200.4)"
:log info "RadSec: Enabled (radsec.isp.com)"
:log info "BDIX: Enabled (172.16.100.1)"
:log info "BGP: Enabled (AS 65001)"
:log info "OSPF: Enabled"
:log info "VRRP: Enabled"
:log info "VPN: PPTP/L2TP/SSTP/OpenVPN/WireGuard/IPsec"
:log info "Hotspot: Enabled (vlan100-Hotspot)"
:log info "OpenRoaming: Enabled"
:log info "Container: Enabled (Docker)"
:log info "SNMP: Enabled"
:log info "================================================"
:log info "Total Users Capacity: 50,000+"
:log info "Total Bandwidth: 10Gbps+"
:log info "================================================"

:delay 10s

:log warning "System will reboot in 10 seconds..."
:delay 10s
/system reboot