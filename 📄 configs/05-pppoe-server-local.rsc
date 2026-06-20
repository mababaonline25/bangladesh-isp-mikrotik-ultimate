###############################################################################
# CONFIG: 05-PPPOE-SERVER-LOCAL.RSC
# Description: PPPoE server with local authentication
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 5: PPPOE SERVER - LOCAL"
:log info "================================================"

# PPPoE Pool
/ip pool add name=pppoe-pool ranges=10.10.1.2-10.10.255.254

# IPv6 Pool for PPPoE
:if ($enableIPv6 = "yes") do={
  /ipv6 pool add name=pppoe-ipv6-pool prefix=$ipv6PPPoE prefix-length=64
}

# Local Profiles (RADIUS Backup)
/ppp profile add name="pppoe-default" local-address=10.10.0.1 \
  remote-address=pppoe-pool dns-server=8.8.8.8,1.1.1.1 \
  use-encryption=yes comment="DEFAULT_PROFILE"

# All Speed Packages
:local speeds { "5"; "10"; "20"; "30"; "40"; "50"; "60"; "70"; "80"; "90"; "100"; "120"; "140"; "160"; "180"; "200"; "300"; "500"; "700"; "1000" }
:foreach speed in=$speeds do={
  :local speedLimit "$speed"
  /ppp profile add name="PKG-$speedLimit-MBPS" local-address=10.10.0.1 \
    remote-address=pppoe-pool rate-limit="$speedLimit"."M/$speedLimit"."M" \
    dns-server=8.8.8.8,1.1.1.1 use-encryption=yes \
    comment="SPEED_$speedLimit-MBPS"
}

# Unlimited Package
/ppp profile add name="PKG-UNLIMITED" local-address=10.10.0.1 \
  remote-address=pppoe-pool rate-limit="0/0" \
  dns-server=8.8.8.8,1.1.1.1 use-encryption=yes comment="UNLIMITED"

# BDIX Only Packages
/ppp profile add name="PKG-BDIX-20" local-address=10.10.0.1 \
  remote-address=pppoe-pool rate-limit="20M/20M" \
  dns-server=8.8.8.8,1.1.1.1 use-encryption=yes comment="BDIX_ONLY_20"
/ppp profile add name="PKG-BDIX-50" local-address=10.10.0.1 \
  remote-address=pppoe-pool rate-limit="50M/50M" \
  dns-server=8.8.8.8,1.1.1.1 use-encryption=yes comment="BDIX_ONLY_50"
/ppp profile add name="PKG-BDIX-100" local-address=10.10.0.1 \
  remote-address=pppoe-pool rate-limit="100M/100M" \
  dns-server=8.8.8.8,1.1.1.1 use-encryption=yes comment="BDIX_ONLY_100"

# Group Profiles
/ppp profile add name="GROUP-RESIDENTIAL" local-address=10.10.0.1 \
  remote-address=pppoe-pool comment="RESIDENTIAL_GROUP"
/ppp profile add name="GROUP-BUSINESS" local-address=10.10.0.1 \
  remote-address=pppoe-pool comment="BUSINESS_GROUP"
/ppp profile add name="GROUP-PREMIUM" local-address=10.10.0.1 \
  remote-address=pppoe-pool comment="PREMIUM_GROUP"

# PPPoE Server
/interface pppoe-server server add service-name="$companyName-PPPoE" \
  interface="vlan$vlanPPPoE-PPPoE" one-session-per-host=yes \
  default-profile=pppoe-default max-sessions=$maxPPPoESessions \
  max-mtu=1492 max-mru=1492 keepalive-timeout=30

# PPPoE Advanced Settings
/ppp pppoe-server set one-session-per-host=yes
/ppp pppoe-server set max-sessions=$maxPPPoESessions
/ppp pppoe-server set authentication=mschap1,mschap2

# IPv6 PPPoE
:if ($enableIPv6 = "yes") do={
  /ipv6 ppp profile add name=pppoe-ipv6 use-ipv6=yes ipv6-prefix=pppoe-ipv6-pool
}

# Sample Local Users (Without Radius)
:if ($useRadius = "no") do={
  /ppp secret add name=customer1 password=SecurePass123 profile=PKG-20-MBPS service=pppoe
  /ppp secret add name=customer2 password=SecurePass456 profile=PKG-50-MBPS service=pppoe
  /ppp secret add name=customer3 password=SecurePass789 profile=PKG-100-MBPS service=pppoe
  /ppp secret add name=customer4 password=SecurePassABC profile=PKG-UNLIMITED service=pppoe
  /ppp secret add name=testuser password=test123 profile=PKG-10-MBPS service=pppoe
}

:log info "PPPoE server configuration complete"