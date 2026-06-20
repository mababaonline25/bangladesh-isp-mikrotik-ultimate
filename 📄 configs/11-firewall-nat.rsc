###############################################################################
# CONFIG: 11-FIREWALL-NAT.RSC
# Description: NAT configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 11: FIREWALL - NAT"
:log info "================================================"

/ip firewall nat

# Masquerade - WAN1
add action=masquerade chain=srcnat out-interface=$upstream1Interface comment="MASQ_WAN1"

# Masquerade - WAN2 (Failover)
:if ($enableFailover = "yes") do={
  add action=masquerade chain=srcnat out-interface=$upstream2Interface comment="MASQ_WAN2"
}

# Port Forwarding - Web Server (Example)
:if ($routerRole = "border" or $routerRole = "all-in-one") do={
  # HTTP Port Forwarding
  add action=dst-nat chain=dstnat protocol=tcp dst-port=80 to-addresses=10.99.0.10 to-ports=80 \
    comment="HTTP_TO_WEB_SERVER"
  
  # HTTPS Port Forwarding
  add action=dst-nat chain=dstnat protocol=tcp dst-port=443 to-addresses=10.99.0.10 to-ports=443 \
    comment="HTTPS_TO_WEB_SERVER"
  
  # SSH Port Forwarding
  add action=dst-nat chain=dstnat protocol=tcp dst-port=22 to-addresses=10.99.0.10 to-ports=22 \
    comment="SSH_TO_WEB_SERVER"
  
  # SMTP Port Forwarding
  add action=dst-nat chain=dstnat protocol=tcp dst-port=25 to-addresses=10.99.0.20 to-ports=25 \
    comment="SMTP_TO_MAIL_SERVER"
  
  # DNS Port Forwarding
  add action=dst-nat chain=dstnat protocol=udp dst-port=53 to-addresses=10.99.0.10 to-ports=53 \
    comment="DNS_TO_SERVER"
}

# NAT Exceptions
add action=accept chain=srcnat src-address=10.0.0.0/8 dst-address=10.0.0.0/8 comment="EXCEPT_INTERNAL"

# Port Forwarding for PPPoE
add action=dst-nat chain=dstnat dst-address=$upstream1IP protocol=tcp dst-port=1723 \
  to-addresses=10.10.0.1 comment="PPTP_VPN"

:log info "NAT configuration complete"