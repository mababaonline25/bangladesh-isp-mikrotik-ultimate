###############################################################################
# TOOL: TRAFFIC-ANALYSIS.RSC
# Version: 5.0.0
# Description: Traffic analysis and reporting
###############################################################################

:log info "================================================"
:log info "TRAFFIC ANALYSIS"
:log info "================================================"

# ============================================================================
# Traffic Analysis Script
# ============================================================================

/system script add name=traffic-analysis source={
    :log info "=== TRAFFIC ANALYSIS ==="
    
    # Interface traffic
    :foreach interface in=[/interface find type!="loopback"] do={
        :local stats [/interface monitor-traffic $interface once as-value]
        :local rxRate ($stats->"rx-bits-per-second")
        :local txRate ($stats->"tx-bits-per-second")
        :local rxBytes ($stats->"rx-bytes-per-second")
        :local txBytes ($stats->"tx-bytes-per-second")
        
        :if ($rxRate > 0 || $txRate > 0) do={
            :log info "$interface: RX: [$rxRate bps] TX: [$txRate bps]"
        }
    }
    
    # PPPoE traffic
    :local pppoeTraffic [/ppp active print]
    :log info "PPPoE Users: $pppoeTraffic"
    
    # Firewall statistics
    :local fwStats [/ip firewall filter print]
    :log info "Firewall: $fwStats"
    
    :log info "========================"
}

# ============================================================================
# Top Talkers Script
# ============================================================================

/system script add name=top-talkers source={
    :log info "=== TOP TALKERS ==="
    
    # Get top PPPoE users by traffic
    :foreach user in=[/ppp active find] do={
        :local username [/ppp active get $user name]
        :local rx [/ppp active get $user rx]
        :local tx [/ppp active get $user tx]
        :log info "$username: RX: $rx TX: $tx"
    }
    
    :log info "==================="
}

# ============================================================================
# Traffic Summary Script
# ============================================================================

/system script add name=traffic-summary source={
    :log info "=== TRAFFIC SUMMARY ==="
    
    :local totalRX 0
    :local totalTX 0
    
    :foreach interface in=[/interface find type!="loopback"] do={
        :local stats [/interface monitor-traffic $interface once as-value]
        :set totalRX ($totalRX + ($stats->"rx-bytes-per-second"))
        :set totalTX ($totalTX + ($stats->"tx-bytes-per-second"))
    }
    
    :log info "Total RX: $totalRX bytes/sec"
    :log info "Total TX: $totalTX bytes/sec"
    
    :local activeUsers [/ppp active print count-only]
    :log info "Active Users: $activeUsers"
    
    :log info "====================="
}

# ============================================================================
# Traffic Analysis Scheduler
# ============================================================================

/system scheduler add name=traffic-analysis interval=1h on-event=traffic-analysis \
    comment="TRAFFIC_ANALYSIS"

/system scheduler add name=traffic-summary interval=1d on-event=traffic-summary \
    comment="TRAFFIC_SUMMARY"

:log info "Traffic analysis configuration complete"