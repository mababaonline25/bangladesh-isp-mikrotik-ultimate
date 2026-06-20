###############################################################################
# CONFIG: 14-VPN-ALL-TYPES.RSC
# Description: VPN services - PPTP, L2TP, SSTP, OpenVPN
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 14: VPN - ALL TYPES"
:log info "================================================"

:if ($enableVPN = "yes") do={

  # VPN Pool
  /ip pool add name=vpn-pool ranges=10.20.1.2-10.20.255.254
  
  # VPN Profiles
  /ppp profile add name="vpn-5mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="5M/5M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required
  /ppp profile add name="vpn-10mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="10M/10M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required
  /ppp profile add name="vpn-20mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="20M/20M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required
  /ppp profile add name="vpn-50mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="50M/50M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required
  /ppp profile add name="vpn-100mbps" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="100M/100M" dns-server=8.8.8.8,1.1.1.1 use-encryption=required
  /ppp profile add name="vpn-unlimited" local-address=10.20.0.1 remote-address=vpn-pool \
    rate-limit="0/0" dns-server=8.8.8.8,1.1.1.1 use-encryption=required
  
  # PPTP Server
  /interface pptp-server server set enabled=yes authentication=mschap1,mschap2
  /ip firewall filter add chain=input protocol=tcp dst-port=1723 action=accept \
    comment="ACCEPT_PPTP"
  
  # L2TP Server
  /interface l2tp-server server set enabled=yes authentication=mschap1,mschap2 \
    ipsec-secret=VPN-IPSEC-SECRET-CHANGE
  /ip firewall filter add chain=input protocol=udp dst-port=1701,500,4500 action=accept \
    comment="ACCEPT_L2TP_IPSEC"
  
  # SSTP Server
  /interface sstp-server server set enabled=yes authentication=mschap1,mschap2 \
    certificate=web-cert
  /ip firewall filter add chain=input protocol=tcp dst-port=443 action=accept \
    comment="ACCEPT_SSTP"
  
  # OpenVPN Server
  /interface ovpn-server server set enabled=yes auth=sha1 cipher=aes256
  /ip firewall filter add chain=input protocol=udp dst-port=1194 action=accept \
    comment="ACCEPT_OPENVPN"
  /ip firewall filter add chain=input protocol=tcp dst-port=1194 action=accept \
    comment="ACCEPT_OPENVPN_TCP"
  
  # Sample VPN Users
  /ppp secret add name=vpnuser1 password=pass123 profile=vpn-20mbps service=pptp,l2tp,sstp,ovpn
  /ppp secret add name=vpnuser2 password=pass456 profile=vpn-50mbps service=pptp,l2tp,sstp,ovpn
  /ppp secret add name=vpnuser3 password=pass789 profile=vpn-100mbps service=pptp,l2tp,sstp,ovpn
  /ppp secret add name=vpnuser4 password=passABC profile=vpn-unlimited service=pptp,l2tp,sstp,ovpn
  
  :log info "VPN configuration complete"
} else={
  :log info "VPN services are disabled"
}