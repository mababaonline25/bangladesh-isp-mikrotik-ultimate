###############################################################################
# CONFIG: 09-FIREWALL-RAW-DDOS.RSC
# Description: RAW firewall and DDoS protection
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 9: FIREWALL - RAW (DDoS Protection)"
:log info "================================================"

# RAW Firewall - Layer 1 Protection
/ip firewall raw
add action=drop chain=prerouting connection-state=invalid comment="DROP_INVALID"
add action=drop chain=prerouting protocol=tcp src-port=0 comment="DROP_PORT0_TCP"
add action=drop chain=prerouting protocol=udp src-port=0 comment="DROP_PORT0_UDP"
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,syn comment="DROP_FIN_SYN"
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,rst comment="DROP_FIN_RST"
add action=drop chain=prerouting protocol=tcp tcp-flags=fin,!ack comment="DROP_FIN_NO_ACK"
add action=drop chain=prerouting protocol=tcp tcp-flags=syn,rst comment="DROP_SYN_RST"
add action=drop chain=prerouting protocol=icmp packet-size=1025-65535 comment="DROP_LARGE_ICMP"
add action=drop chain=prerouting protocol=icmp fragment=yes comment="DROP_FRAGMENTED_ICMP"
add action=drop chain=prerouting ipv4-options=any comment="DROP_IP_OPTIONS"

# DDoS Detection
add action=add-src-to-address-list chain=prerouting protocol=tcp psd=21,3s,3,1 \
  address-list=DDOS-BLACKLIST address-list-timeout=1h comment="DDOS_PORT_SCAN"
add action=add-src-to-address-list chain=prerouting protocol=tcp tcp-flags=syn \
  connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h comment="DDOS_SYN_FLOOD"
add action=add-src-to-address-list chain=prerouting protocol=udp \
  connection-limit=25,32 address-list=DDOS-BLACKLIST address-list-timeout=1h comment="DDOS_UDP_FLOOD"
add action=add-src-to-address-list chain=prerouting protocol=icmp limit=5,5 \
  address-list=DDOS-BLACKLIST address-list-timeout=1h comment="DDOS_ICMP_FLOOD"
add action=drop chain=prerouting src-address-list=DDOS-BLACKLIST comment="DROP_DDOS_BLACKLIST"

# Brute Force Protection
add action=add-src-to-address-list chain=prerouting dst-port=8291 protocol=tcp \
  src-address-list=!TRUSTED-NETWORKS connection-state=new \
  address-list=WINBOX-BLACKLIST address-list-timeout=1h comment="WINBOX_BRUTE"
add action=add-src-to-address-list chain=prerouting dst-port=22 protocol=tcp \
  src-address-list=!TRUSTED-NETWORKS connection-state=new \
  address-list=SSH-BLACKLIST address-list-timeout=1h comment="SSH_BRUTE"
add action=add-src-to-address-list chain=prerouting dst-port=80,443 protocol=tcp \
  src-address-list=!TRUSTED-NETWORKS connection-state=new \
  address-list=HTTP-BLACKLIST address-list-timeout=1h comment="HTTP_BRUTE"
add action=drop chain=prerouting src-address-list=WINBOX-BLACKLIST,SSH-BLACKLIST,HTTP-BLACKLIST \
  comment="DROP_SERVICE_BLACKLIST"

# Port Scan Protection
add action=add-src-to-address-list chain=prerouting protocol=tcp psd=21,3s,3,1 \
  address-list=PORTSCAN-BLACKLIST address-list-timeout=1h comment="PORTSCAN"

# TCP SYN Cookie Protection
add action=drop chain=prerouting protocol=tcp tcp-flags=syn \
  src-address-list=PORTSCAN-BLACKLIST comment="DROP_PORTSCAN"

:log info "RAW firewall configuration complete"