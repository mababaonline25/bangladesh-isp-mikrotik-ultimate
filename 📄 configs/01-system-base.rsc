###############################################################################
# CONFIG: 01-SYSTEM-BASE.RSC
# Description: System base configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 1: SYSTEM BASE CONFIGURATION"
:log info "================================================"

# System Identity
/system identity set name="$companyName-$routerRole"

# System Clock
/system clock set time-zone-name=Asia/Dhaka

# Routerboard Settings
/system routerboard settings set boot-device=try-ethernet-once-then-nand
/system routerboard settings set cpu-frequency=auto

# NTP Configuration
/system ntp client set enabled=yes
/system ntp client servers add address=time.google.com
/system ntp client servers add address=pool.ntp.org
/system ntp client servers add address=bd.pool.ntp.org

# DNS Configuration
/ip dns set servers=8.8.8.8,1.1.1.1,8.8.4.4
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=20480KiB
/ip dns set max-concurrent-tcp-sessions=1000
/ip dns set max-concurrent-udp-sessions=1000

# DNS Static Entries
/ip dns static add name=router.local address=192.168.20.1
/ip dns static add name=hotspot.local address=10.100.0.1
/ip dns static add name=mail.local address=10.99.0.10
/ip dns static add name=radius.local address=10.1.200.2

# System Logging
/system logging set [find] action=memory
/system logging add topics=info,error,warning action=memory prefix="SYS-"
/system logging add topics=radius,info action=memory prefix="RADIUS-"
/system logging add topics=radius,debug action=memory prefix="RAD-DBG-"
/system logging add topics=ppp,info action=memory prefix="PPP-"
/system logging add topics=ppp,debug action=memory prefix="PPP-DBG-"
/system logging add topics=firewall,info action=memory prefix="FW-"
/system logging add topics=firewall,debug action=memory prefix="FW-DBG-"
/system logging add topics=hotspot,info action=memory prefix="HS-"
/system logging add topics=wireless,info action=memory prefix="WLAN-"
/system logging add topics=bgp,info action=memory prefix="BGP-"
/system logging add topics=ospf,info action=memory prefix="OSPF-"
/system logging add topics=system,info action=memory prefix="SYS-INFO-"
/system logging add topics=ipsec,info action=memory prefix="IPSEC-"
/system logging add topics=snmp,info action=memory prefix="SNMP-"

:log info "System base configuration complete"