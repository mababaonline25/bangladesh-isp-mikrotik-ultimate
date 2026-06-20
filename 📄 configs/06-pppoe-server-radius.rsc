###############################################################################
# CONFIG: 06-PPPOE-SERVER-RADIUS.RSC
# Description: PPPoE server with RADIUS authentication
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 6: PPPOE SERVER - RADIUS"
:log info "================================================"

:if ($useRadius = "yes") do={

  # Radius Profiles
  /ppp profile add name="radius-default" use-radius=yes comment="RADIUS_CONTROLLED"
  /ppp profile add name="radius-premium" use-radius=yes comment="RADIUS_PREMIUM"
  /ppp profile add name="radius-business" use-radius=yes comment="RADIUS_BUSINESS"
  /ppp profile add name="radius-residential" use-radius=yes comment="RADIUS_RESIDENTIAL"
  /ppp profile add name="radius-enterprise" use-radius=yes comment="RADIUS_ENTERPRISE"
  
  # PPP AAA
  /ppp aaa set use-radius=yes accounting=yes interim-update=5m
  /ppp aaa set use-radius=yes accounting=yes interim-update=5m default-profile=radius-default
  
  # RADIUS NAS ID
  /radius set [find] nas-id=$radiusNasId
  
  # RADIUS Called ID
  /radius set [find] called-id=$radiusCalledId
  
  # RADIUS Attributes
  /radius add attribute comment="Framed-IP-Address" value=10.10.0.1
  /radius add attribute comment="Framed-IP-Netmask" value=255.255.0.0
  
  # CoA (Change of Authorization)
  /radius coa set enabled=yes port=1700
  /radius coa add address=$radiusPrimaryIP secret=$radiusPrimarySecret
  /radius coa add address=$radiusBackupIP secret=$radiusBackupSecret
  
  :log info "RADIUS configuration for PPPoE complete"
} else={
  :log info "RADIUS is disabled, using local authentication"
}