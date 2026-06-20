###############################################################################
# CONFIG: 28-SERVICE-HARDENING.RSC
# Description: Service hardening and security
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 28: SERVICE HARDENING"
:log info "================================================"

# Disable Unused Services
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes

# Secure Services - Restrict to Management Networks
/ip service set winbox address=192.168.20.0/24,10.99.0.0/24
/ip service set ssh address=192.168.20.0/24,10.99.0.0/24 port=22
/ip service set www-ssl address=192.168.20.0/24,10.99.0.0/24 port=443

# SSH Hardening
/ip ssh set strong-crypto=yes
/ip ssh set host-key-size=4096
/ip ssh set allow-none-crypto=no
/ip ssh set forwarding-enabled=no

# API Security
/ip api set disabled=yes
/ip api-ssl set disabled=yes

# MAC Telnet
/interface mac-telnet set allowed-interface-list=!dynamic

# MAC WinBox
/interface mac-winbox set allowed-interface-list=!dynamic

# Discovery
/ip neighbor discovery-settings set discover-interface-list=!dynamic

# Bandwidth Test Security
/tool bandwidth-server set enabled=yes authenticate=yes max-sessions=5

# SNMP Security
:if ($enableSNMP = "yes") do={
  /snmp set enabled=yes
  /snmp community add name=public addresses=10.99.0.0/24 read-only=yes
  /snmp community add name=private addresses=192.168.20.0/24 read-write=yes
}

# Web Proxy Security
:if ($enableProxy = "yes") do={
  /ip proxy set enabled=yes port=8080
  /ip proxy set src-address=10.0.0.0/8
}

:log info "Service hardening complete"