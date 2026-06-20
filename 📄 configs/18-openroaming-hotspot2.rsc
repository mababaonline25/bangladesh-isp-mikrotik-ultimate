###############################################################################
# CONFIG: 18-OPENROAMING-HOTSPOT2.RSC
# Description: OpenRoaming / Hotspot 2.0 configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 18: OPENROAMING / HOTSPOT 2.0"
:log info "================================================"

:if ($enableOpenRoaming = "yes") do={

  # Import Certificates
  /certificate import file-name=iw-rsa-root-ca.cert.pem passphrase=""
  /certificate import file-name=iw-rsa-radsec-signing-ca.cert.pem passphrase=""
  /certificate import file-name=client.cert.pem passphrase=""
  /certificate import file-name=client.key.pem passphrase=""
  
  # Wireless Security Profile
  /interface wireless security-profiles
  add name=openroaming-profile authentication-types=wpa2-eap \
    mode=dynamic-keys eap-methods=passthrough \
    comment="OPENROAMING_SECURITY"
  
  # Wireless Interworking Profile
  /interface wireless interworking-profiles
  add name=openroaming access-network-type=free-public-network \
    internet=yes venue-group=business venue-type=unspecified-business \
    comment="OPENROAMING_INTERWORKING"
  
  # Hotspot 2.0 Profile
  /interface wireless hotspot20-profiles
  add name=openroaming domain-names=$hotspot2Domain \
    operator-names=$hotspot2Operator \
    wan-metrics="symmetric,1,50000,50000,0,0" \
    comment="HOTSPOT20_PROFILE"
  
  # NAI Realms
  /interface wireless nai-realms
  add profile=openroaming realm=$hotspot2Domain \
    eap-methods="eap-ttls:non-eap-pap;eap-tls:" \
    comment="DOMAIN_REALM"
  add profile=openroaming realm=openroaming.net \
    eap-methods="eap-ttls:;eap-tls:" \
    comment="OPENROAMING_REALM"
  
  # Roaming OIs
  /interface wireless roaming-ois
  add profile=openroaming oi=AA146B0000 comment="OPENROAMING"
  add profile=openroaming oi=5A03BA0000 comment="OPENROAMING2"
  add profile=openroaming oi=5A03BA0200 comment="OPENROAMING3"
  add profile=openroaming oi=BAA2D00000 comment="OPENROAMING4"
  add profile=openroaming oi=004096 comment="OPENROAMING5"
  
  # 802.11u Support
  /interface wireless set [find] interworking-profile=openroaming
  /interface wireless set [find] hotspot20-profile=openroaming
  
  :log info "OpenRoaming configuration complete"
} else={
  :log info "OpenRoaming is disabled"
}