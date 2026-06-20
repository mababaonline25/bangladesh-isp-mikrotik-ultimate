###############################################################################
# CONFIG: 33-IPSEC-VPN.RSC
# Description: IPSec VPN (IKEv1/IKEv2) configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 33: IPSEC VPN"
:log info "================================================"

:if ($enableIPsec = "yes") do={

  # IPSec Proposals
  /ip ipsec proposal add name=ikev1-proposal auth-algorithms=sha1 \
    enc-algorithms=aes-256-cbc lifetime=8h comment="IKEV1_PROPOSAL"
  /ip ipsec proposal add name=ikev2-proposal auth-algorithms=sha256 \
    enc-algorithms=aes-256-cbc lifetime=8h pfs-group=modp2048 \
    comment="IKEV2_PROPOSAL"
  /ip ipsec proposal add name=ikev2-proposal-strong auth-algorithms=sha256 \
    enc-algorithms=aes-256-gcm lifetime=8h pfs-group=ecp256 \
    comment="IKEV2_STRONG"
  
  # IPSec Peers
  /ip ipsec peer add address=0.0.0.0/0 exchange-mode=ike2 proposal-check=obey \
    comment="IKEV2_PEER"
  /ip ipsec peer add address=0.0.0.0/0 exchange-mode=ike1 proposal-check=obey \
    comment="IKEV1_PEER"
  
  # IPSec Policies
  /ip ipsec policy add dst-address=0.0.0.0/0 src-address=0.0.0.0/0 \
    action=encrypt level=unique proposal=ikev2-proposal tunnel=yes \
    sa-dst-address=0.0.0.0 sa-src-address=0.0.0.0 comment="IPSEC_POLICY"
  
  # IPSec Mode Config
  /ip ipsec mode-config add name=ipsec-vpn address-pool=vpn-pool \
    dns-server=8.8.8.8,1.1.1.1 comment="IPSEC_MODE_CONFIG"
  
  # IPSec Identity
  /ip ipsec identity add peer=any secret=IPSEC-SECRET-CHANGE \
    mode-config=ipsec-vpn comment="IPSEC_IDENTITY"
  
  # IPSec Firewall Rules
  /ip firewall filter add chain=input protocol=udp dst-port=500 action=accept \
    comment="ACCEPT_IPSEC_IKE"
  /ip firewall filter add chain=input protocol=udp dst-port=4500 action=accept \
    comment="ACCEPT_IPSEC_NAT_T"
  /ip firewall filter add chain=input protocol=esp action=accept \
    comment="ACCEPT_IPSEC_ESP"
  /ip firewall filter add chain=input protocol=ah action=accept \
    comment="ACCEPT_IPSEC_AH"
  
  # IPSec NAT
  /ip firewall nat add action=accept chain=srcnat protocol=esp comment="EXCEPT_IPSEC_NAT"
  /ip firewall nat add action=accept chain=srcnat protocol=udp dst-port=500 comment="EXCEPT_IKE_NAT"
  
  # IPSec Logging
  /system logging add topics=ipsec,info action=memory prefix="IPSEC-"
  /system logging add topics=ipsec,debug action=memory prefix="IPSEC-DBG-"
  
  :log info "IPSec VPN configuration complete"
} else={
  :log info "IPSec VPN is disabled"
}