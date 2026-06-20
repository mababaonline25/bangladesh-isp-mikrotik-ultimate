###############################################################################
# CONFIG: 29-ADDRESS-LISTS.RSC
# Description: Address list configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 29: ADDRESS LISTS"
:log info "================================================"

# Trusted Networks
/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.40.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.99.0.0/24 list=TRUSTED-NETWORKS
/ip firewall address-list add address=10.110.0.0/24 list=TRUSTED-NETWORKS

# BDIX Networks
/ip firewall address-list add address=103.0.0.0/8 list=BDIX-NETWORKS
/ip firewall address-list add address=202.0.0.0/8 list=BDIX-NETWORKS
/ip firewall address-list add address=110.0.0.0/8 list=BDIX-NETWORKS

# User Networks
/ip firewall address-list add address=10.10.0.0/16 list=PPPOE-USERS
/ip firewall address-list add address=10.20.0.0/16 list=VPN-USERS

# Guest Networks
/ip firewall address-list add address=10.50.0.0/24 list=GUEST-NETWORKS
/ip firewall address-list add address=10.120.0.0/24 list=IOT-NETWORKS

# Service Networks
/ip firewall address-list add address=10.30.0.0/24 list=VOICE-NETWORKS
/ip firewall address-list add address=10.60.0.0/24 list=IPTV-NETWORKS
/ip firewall address-list add address=10.70.0.0/24 list=STORAGE-NETWORKS
/ip firewall address-list add address=10.100.0.0/24 list=HOTSPOT-NETWORKS

# DNS Servers
/ip firewall address-list add address=8.8.8.8 list=DNS-SERVERS
/ip firewall address-list add address=1.1.1.1 list=DNS-SERVERS
/ip firewall address-list add address=8.8.4.4 list=DNS-SERVERS
/ip firewall address-list add address=208.67.222.222 list=DNS-SERVERS

# NTP Servers
/ip firewall address-list add address=time.google.com list=NTP-SERVERS
/ip firewall address-list add address=pool.ntp.org list=NTP-SERVERS
/ip firewall address-list add address=bd.pool.ntp.org list=NTP-SERVERS

# Blocked Countries (Optional)
/ip firewall address-list add address=1.0.0.0/8 list=BLOCKED-COUNTRIES
/ip firewall address-list add address=2.0.0.0/8 list=BLOCKED-COUNTRIES

# Malicious IPs (Update manually)
/ip firewall address-list add address=0.0.0.0/32 list=MALICIOUS-IPS

:log info "Address lists configuration complete"