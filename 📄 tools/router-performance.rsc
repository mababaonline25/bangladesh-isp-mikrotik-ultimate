###############################################################################
# TOOL: ROUTER-PERFORMANCE.RSC
# Version: 5.0.0
# Description: Router performance monitoring
###############################################################################

:log info "================================================"
:log info "ROUTER PERFORMANCE MONITOR"
:log info "================================================"

# ============================================================================
# Performance Script
# ============================================================================

/system script add name=router-performance source={
    :log info "=== ROUTER PERFORMANCE ==="
    
    # CPU
    :local cpu [/system resource get cpu-load]
    :log info "CPU Load: $cpu%"
    
    # Memory
    :local totalMem [/system resource get total-memory]
    :local freeMem [/system resource get free-memory]
    :local usedMem ($totalMem - $freeMem)
    :local memPercent ($usedMem * 100 / $totalMem)
    :log info "Memory: $memPercent% used ($usedMem/$totalMem)"
    
    # Disk
    :local totalDisk [/system resource get total-hdd-space]
    :local freeDisk [/system resource get free-hdd-space]
    :local usedDisk ($totalDisk - $freeDisk)
    :local diskPercent ($usedDisk * 100 / $totalDisk)
    :log info "Disk: $diskPercent% used ($usedDisk/$totalDisk)"
    
    # Uptime
    :local uptime [/system resource get uptime]
    :log info "Uptime: $uptime"
    
    # Temperature
    :local temperature [/system health get temperature]
    :log info "Temperature: $temperature°C"
    
    # Voltage
    :local voltage [/system health get voltage]
    :log info "Voltage: $voltage V"
    
    # Sessions
    :local pppoeSessions [/ppp active print count-only]
    :log info "PPPoE Sessions: $pppoeSessions"
    
    :local hotspotUsers [/ip hotspot active print count-only]
    :log info "Hotspot Users: $hotspotUsers"
    
    :local firewallRules [/ip firewall filter print count-only]
    :log info "Firewall Rules: $firewallRules"
    
    :local routes [/ip route print count-only]
    :log info "Routes: $routes"
    
    :log info "=========================="
}

# ============================================================================
# Performance Scheduler
# ============================================================================

/system scheduler add name=performance-check interval=5m on-event=router-performance \
    comment="PERFORMANCE_CHECK"

:log info "Router performance monitor configuration complete"