###############################################################################
# CONFIG: 20-ROUTING-STATIC.RSC
# Description: Static routing configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 20: ROUTING - STATIC"
:log info "================================================"

:if ($routerRole != "access") do={

  # Default Routes
  /ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP distance=1 \
    check-gateway=ping comment="PRIMARY_DEFAULT"
  
  :if ($enableFailover = "yes") do={
    /ip route add dst-address=0.0.0.0/0 gateway=$upstream2IP distance=2 \
      check-gateway=ping comment="BACKUP_DEFAULT"
  }
  
  # BDIX Routes
  :if ($enableBDIX = "yes") do={
    /ip route add dst-address=103.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_103"
    /ip route add dst-address=202.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_202"
    /ip route add dst-address=110.0.0.0/8 gateway=$bdixPeerIP distance=1 \
      check-gateway=ping comment="BDIX_110"
  }
  
  # Local Networks
  /ip route add dst-address=10.0.0.0/8 gateway=bridge-local distance=0 \
    comment="LOCAL_NETWORK"
  /ip route add dst-address=192.168.20.0/24 gateway=bridge-local distance=0 \
    comment="MGMT_NETWORK"
  
  # Specific Routes for Services
  /ip route add dst-address=10.99.0.0/24 gateway=bridge-local distance=0 \
    comment="SERVICES_NETWORK"
  
  # Route to RADIUS Server
  :if ($useRadius = "yes") do={
    /ip route add dst-address=$radiusPrimaryIP/32 gateway=bridge-local distance=0 \
      comment="RADIUS_SERVER"
  }
  
  :log info "Static routing configuration complete"
} else={
  :log info "Access role - skipping static routing"
}