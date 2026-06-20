###############################################################################
# CONFIG: 16-HOTSPOT-CAPTIVE-PORTAL.RSC
# Description: Hotspot captive portal configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 16: HOTSPOT - CAPTIVE PORTAL"
:log info "================================================"

:if ($enableHotspot = "yes") do={

  # Hotspot Profile
  /ip hotspot profile add name=hotspot-profile \
    hotspot-address=10.100.0.1 \
    dns-name="hotspot.$companyName.com.bd" \
    html-directory=hotspot \
    login-by=http-chap,http-pap,https,cookie,trial \
    radius-accounting=yes \
    radius-interim-update=2m \
    use-radius=yes \
    comment="HOTSPOT_PROFILE"
  
  # Hotspot Server
  /ip hotspot add name=hotspot1 interface="vlan$vlanHotspot-HOTSPOT" \
    address-pool=dhcp-pool-hotspot profile=hotspot-profile disabled=no \
    comment="HOTSPOT_MAIN"
  
  # Hotspot User Profiles
  /ip hotspot user profile add name=free-profile rate-limit="2M/2M" \
    comment="FREE_USER"
  /ip hotspot user profile add name=basic-profile rate-limit="5M/5M" \
    comment="BASIC_USER"
  /ip hotspot user profile add name=premium-profile rate-limit="10M/10M" \
    comment="PREMIUM_USER"
  /ip hotspot user profile add name=unlimited-profile rate-limit="0/0" \
    comment="UNLIMITED_USER"
  
  # Hotspot Users
  /ip hotspot user add name=guest1 password=guest123 profile=basic-profile \
    comment="GUEST_USER_1"
  /ip hotspot user add name=guest2 password=guest456 profile=free-profile \
    comment="GUEST_USER_2"
  /ip hotspot user add name=premium1 password=premium123 profile=premium-profile \
    comment="PREMIUM_USER_1"
  /ip hotspot user add name=vip1 password=vip123 profile=unlimited-profile \
    comment="VIP_USER"
  
  # Hotspot Limits
  /ip hotspot user profile set free-profile idle-timeout=1h
  /ip hotspot user profile set basic-profile idle-timeout=2h
  /ip hotspot user profile set premium-profile idle-timeout=4h
  /ip hotspot user profile set unlimited-profile idle-timeout=8h
  
  :log info "Hotspot captive portal configuration complete"
} else={
  :log info "Hotspot is disabled"
}