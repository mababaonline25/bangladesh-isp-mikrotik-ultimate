###############################################################################
# CONFIG: 31-FAILOVER-LOADBALANCE.RSC
# Description: Failover and load balancing configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 31: FAILOVER & LOAD BALANCING"
:log info "================================================"

:if ($enableFailover = "yes") do={

  # Routing Tables
  /routing table add name=to-wan1 fib comment="WAN1_ROUTING_TABLE"
  /routing table add name=to-wan2 fib comment="WAN2_ROUTING_TABLE"
  
  # Routes for Load Balancing
  /ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP routing-mark=to-wan1 distance=1 \
    comment="WAN1_LOADBALANCE"
  /ip route add dst-address=0.0.0.0/0 gateway=$upstream2IP routing-mark=to-wan2 distance=1 \
    comment="WAN2_LOADBALANCE"
  
  # Default Routes with Failover
  /ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP distance=1 \
    check-gateway=ping comment="PRIMARY_DEFAULT"
  /ip route add dst-address=0.0.0.0/0 gateway=$upstream2IP distance=2 \
    check-gateway=ping comment="BACKUP_DEFAULT"
  
  # Failover Script
  /system script add name=failover-check source={
    :local primaryStatus [/ping $upstream1IP count=3]
    :local backupStatus [/ping $upstream2IP count=3]
    
    :if ($primaryStatus = 0) do={
      /ip route set [find comment="PRIMARY_DEFAULT"] distance=10
      /log warning "PRIMARY_UPSTREAM_DOWN - Switching to backup"
      /tool e-mail send to=$adminEmail subject="ALERT: Primary Upstream Down" \
        body="Primary upstream $upstream1IP is down. Switching to backup."
    } else={
      /ip route set [find comment="PRIMARY_DEFAULT"] distance=1
    }
    
    :if ($backupStatus = 0 && $primaryStatus = 0) do={
      /log critical "BOTH_UPSTREAMS_DOWN"
      /tool e-mail send to=$adminEmail subject="CRITICAL: Both Upstreams Down" \
        body="Both upstreams are down!"
    }
  }
  
  /system scheduler add name=failover-scheduler interval=10s on-event=failover-check \
    comment="FAILOVER_MONITOR"
  
  # Load Balancing Mangle Rules
  /ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan1-conn per-connection-classifier=src-address-and-port:2/0 \
    comment="LOAD_BALANCE_WAN1"
  /ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan2-conn per-connection-classifier=src-address-and-port:2/1 \
    comment="LOAD_BALANCE_WAN2"
  /ip firewall mangle add chain=prerouting connection-mark=wan1-conn action=mark-routing new-routing-mark=to-wan1 \
    comment="ROUTE_WAN1"
  /ip firewall mangle add chain=prerouting connection-mark=wan2-conn action=mark-routing new-routing-mark=to-wan2 \
    comment="ROUTE_WAN2"
  
  # PCC Load Balancing (Per Connection Classifier)
  /ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan1-conn per-connection-classifier=src-address-and-port:2/0 \
    comment="PCC_WAN1"
  /ip firewall mangle add chain=prerouting in-interface=bridge-local dst-address=!10.0.0.0/8 \
    action=mark-connection new-connection-mark=wan2-conn per-connection-classifier=src-address-and-port:2/1 \
    comment="PCC_WAN2"
  
  # Bonding for Redundancy (if needed)
  :if ($enableBonding = "yes") do={
    /interface bonding add name=bond-main mode=balance-rr slaves=$upstream1Interface,$upstream2Interface \
      comment="BOND_MAIN"
    /ip route set [find comment="PRIMARY_DEFAULT"] gateway=bond-main
  }
  
  :log info "Failover and load balancing configuration complete"
} else={
  :log info "Failover is disabled"
}