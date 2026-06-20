###############################################################################
# CONFIG: 38-INTERFACE-BONDING.RSC
# Description: Interface bonding (LACP) configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 38: INTERFACE BONDING"
:log info "================================================"

:if ($enableBonding = "yes") do={

  # Bonding Interfaces
  /interface bonding add name=bond1 mode=802.3ad slaves=sfp-sfpplus1,sfp-sfpplus2 \
    comment="LACP_BOND_1" lacp-rate=1s link-monitoring=arp
  
  /interface bonding add name=bond2 mode=balance-rr slaves=sfp-sfpplus3,sfp-sfpplus4 \
    comment="BOND_BALANCE_RR" link-monitoring=arp
  
  /interface bonding add name=bond3 mode=active-backup slaves=sfp-sfpplus5,sfp-sfpplus6 \
    comment="BOND_ACTIVE_BACKUP" primary=sfp-sfpplus5 link-monitoring=arp
  
  /interface bonding add name=bond4 mode=broadcast slaves=sfp-sfpplus7,sfp-sfpplus8 \
    comment="BOND_BROADCAST" link-monitoring=arp
  
  # Bonding Settings
  /interface bonding set bond1 link-monitoring=arp arp-interval=100ms
  /interface bonding set bond2 link-monitoring=arp arp-interval=100ms
  /interface bonding set bond3 link-monitoring=arp arp-interval=100ms
  
  # Add Bonds to Bridge
  /interface bridge port add bridge=bridge-local interface=bond1
  /interface bridge port add bridge=bridge-local interface=bond2
  
  # Bonding Monitoring Script
  /system script add name=bond-status source={
    :local bond1Status [/interface bonding get bond1 running]
    :local bond2Status [/interface bonding get bond2 running]
    :local bond3Status [/interface bonding get bond3 running]
    
    :if ($bond1Status != "yes") do={
      :log warning "BOND1_DOWN"
    }
    :if ($bond2Status != "yes") do={
      :log warning "BOND2_DOWN"
    }
    :if ($bond3Status != "yes") do={
      :log warning "BOND3_DOWN"
    }
  }
  
  /system scheduler add name=bond-monitor interval=1m on-event=bond-status \
    comment="BOND_MONITOR"
  
  :log info "Interface bonding configuration complete"
} else={
  :log info "Interface bonding is disabled"
}