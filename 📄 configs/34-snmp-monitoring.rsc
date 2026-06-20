###############################################################################
# CONFIG: 34-SNMP-MONITORING.RSC
# Description: SNMP monitoring configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 34: SNMP MONITORING"
:log info "================================================"

:if ($enableSNMP = "yes") do={

  # SNMP Enable
  /snmp set enabled=yes
  /snmp set contact=$adminEmail
  /snmp set location=$routerLocation
  
  # SNMP Communities
  /snmp community add name=public addresses=10.99.0.0/24 read-only=yes \
    comment="PUBLIC_READ_ONLY"
  /snmp community add name=private addresses=192.168.20.0/24 read-write=yes \
    comment="PRIVATE_READ_WRITE"
  
  # SNMPv3 Users
  /snmp user add name=admin group=full authentication-protocol=sha \
    authentication-passphrase=SNMPv3-AUTH-PASS privacy-protocol=aes \
    privacy-passphrase=SNMPv3-PRIV-PASS comment="ADMIN_USER"
  /snmp user add name=monitor group=read authentication-protocol=md5 \
    authentication-passphrase=SNMPv3-MONITOR-PASS comment="MONITOR_USER"
  
  # SNMP Trap Configuration
  /snmp set trap-community=public
  /snmp set trap-target=10.99.0.10
  /snmp set trap-version=2c
  
  # SNMP Trap Interfaces
  /snmp set trap-generators=ppp,hotspot,interface
  /snmp set trap-interfaces=$upstream1Interface,gre1,l2tp-in1,ovpn-server
  
  # SNMP System OID
  /snmp set sysname="$companyName-$routerRole"
  
  # SNMP Location
  /snmp set syslocation=$routerLocation
  
  # SNMP Contact
  /snmp set syscontact=$adminEmail
  
  # SNMP MIBs
  /snmp set engine-id=000000000000000000000000
  
  # SNMP Store (for persistent data)
  /snmp set store-in-disk=yes
  
  :log info "SNMP monitoring configuration complete"
} else={
  :log info "SNMP monitoring is disabled"
}