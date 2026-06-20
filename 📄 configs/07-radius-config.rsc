###############################################################################
# CONFIG: 07-RADIUS-CONFIG.RSC
# Description: RADIUS server configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 7: RADIUS CONFIGURATION"
:log info "================================================"

:if ($useRadius = "yes") do={

  # Primary RADIUS Server
  /radius add address=$radiusPrimaryIP secret=$radiusPrimarySecret \
    service=ppp,hotspot,wireless authentication-port=$radiusAuthPort \
    accounting-port=$radiusAcctPort timeout=5s retries=3 \
    comment="PRIMARY_RADIUS"
  
  # Backup RADIUS Server
  /radius add address=$radiusBackupIP secret=$radiusBackupSecret \
    service=ppp,hotspot,wireless authentication-port=$radiusAuthPort \
    accounting-port=$radiusAcctPort timeout=5s retries=3 \
    comment="BACKUP_RADIUS"
  
  # RADIUS Incoming
  /radius incoming set accept=yes port=3799
  
  # RADIUS Timeout Settings
  /radius set [find] timeout=5s
  
  # RADIUS Retries
  /radius set [find] retries=3
  
  # RADIUS Dead Time
  /radius set [find] dead-time=5m
  
  # RADIUS NAS Configuration
  /radius set [find] nas-id=$radiusNasId
  
  # RADIUS Called ID
  /radius set [find] called-id=$radiusCalledId
  
  :log info "RADIUS configuration complete"
} else={
  :log info "RADIUS is disabled"
}