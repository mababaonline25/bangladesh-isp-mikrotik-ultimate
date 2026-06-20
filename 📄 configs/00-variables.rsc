###############################################################################
# CONFIG: 00-VARIABLES.RSC
# Description: Global variables for MikroTik ISP configuration
# Version: 5.0.0
###############################################################################

# ============================================================================
# SYSTEM VARIABLES
# ============================================================================

:global configVersion "5.0.0-ULTIMATE"
:global companyName "MY-ISP-BD"
:global routerLocation "Dhaka-Main-DC"
:global adminEmail "noc@myisp.com.bd"
:global adminPhone "+8801700000000"

# ============================================================================
# ROUTER ROLE
# ============================================================================

:global routerRole "all-in-one"
# Options: all-in-one | border | core | pop | service | access

# ============================================================================
# RADIUS CONFIGURATION
# ============================================================================

:global useRadius "yes"
:global radiusPrimaryIP "10.1.200.2"
:global radiusPrimarySecret "CHANGE-THIS-SECRET-2024!"
:global radiusBackupIP "10.1.200.3"
:global radiusBackupSecret "CHANGE-THIS-BACKUP-SECRET-2024!"
:global radiusAuthPort 1812
:global radiusAcctPort 1813
:global radiusNasId "NAS-DHAKA-MAIN"
:global radiusCalledId "BD-ISP-PPPoE"

# RadSec Configuration
:global useRadSec "no"
:global radSecServer "radsec.isp.com"
:global radSecPort 2083
:global clientCert "client.cert.pem_0"

# ============================================================================
# OPENROAMING / HOTSPOT 2.0
# ============================================================================

:global enableOpenRoaming "no"
:global hotspot2Operator "YourISP:eng"
:global hotspot2Domain "hotspot.isp.com.bd"

# ============================================================================
# UPSTREAM / IIG CONFIGURATION
# ============================================================================

:global upstream1Name "IIG-PRIMARY"
:global upstream1IP "103.xxx.xxx.1"
:global upstream1Interface "sfp-sfpplus1"
:global upstream1Bandwidth "10G"

:global upstream2Name "IIG-BACKUP"
:global upstream2IP "103.yyy.yyy.1"
:global upstream2Interface "sfp-sfpplus2"
:global upstream2Bandwidth "5G"

:global bdixPeerName "BDIX-PEER"
:global bdixPeerIP "172.16.100.1"
:global bdixPeerInterface "sfp-sfpplus3"
:global bdixBandwidth "10G"

# ============================================================================
# VLAN CONFIGURATION
# ============================================================================

:global vlanPPPoE 10
:global vlanManagement 20
:global vlanVoice 30
:global vlanB2B 40
:global vlanGuest 50
:global vlanIPTV 60
:global vlanStorage 70
:global vlanMgmt 99
:global vlanHotspot 100
:global vlanCCTV 110
:global vlanIoT 120

# ============================================================================
# IP NETWORKS
# ============================================================================

:global netPPPoE "10.10.0.0/16"
:global netManagement "192.168.20.0/24"
:global netVoice "10.30.0.0/24"
:global netB2B "10.40.0.0/24"
:global netGuest "10.50.0.0/24"
:global netIPTV "10.60.0.0/24"
:global netStorage "10.70.0.0/24"
:global netMgmt "10.99.0.0/24"
:global netHotspot "10.100.0.0/24"
:global netVPN "10.20.0.0/16"
:global netCCTV "10.110.0.0/24"
:global netIoT "10.120.0.0/24"

# ============================================================================
# IPv6 NETWORKS
# ============================================================================

:global ipv6Prefix "2001:db8:1000::/48"
:global ipv6PPPoE "2001:db8:1000:10::/64"
:global ipv6Management "2001:db8:1000:20::/64"

# ============================================================================
# SERVICE TOGGLES
# ============================================================================

:global enablePPPoE "yes"
:global enableHotspot "yes"
:global enableVPN "yes"
:global enableProxy "yes"
:global enableBGP "no"
:global enableOSPF "yes"
:global enableVRRP "no"
:global enableBDIX "yes"
:global enableFailover "yes"
:global enableWireGuard "yes"
:global enableContainer "no"
:global enableDDNS "no"
:global enableIPv6 "no"
:global enableIPsec "yes"
:global enableSNMP "yes"
:global enableEmailAlerts "no"
:global enableTelegramBot "no"
:global enableBonding "no"
:global enableMPLS "no"
:global enableVPLS "no"

# ============================================================================
# PERFORMANCE SETTINGS
# ============================================================================

:global maxUsers 10000
:global maxPPPoESessions 5000
:global maxVPNUsers 500
:global maxHotspotUsers 1000

# ============================================================================
# BANDWIDTH PROFILES
# ============================================================================

:global speeds { "5"; "10"; "20"; "30"; "40"; "50"; "60"; "70"; "80"; "90"; "100"; "120"; "140"; "160"; "180"; "200"; "300"; "500"; "700"; "1000" }
:global bdixSpeeds { "20"; "50"; "100" }