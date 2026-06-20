###############################################################################
# TOOL: HEALTH-CHECK.RSC
# Version: 5.0.0
# Description: System health monitoring script
###############################################################################

:log info "================================================"
:log info "HEALTH CHECK SCRIPT"
:log info "================================================"

# ============================================================================
# System Health Script
# ============================================================================

/system script add name=system-health source={
    # Get system resources
    :local cpu [/system resource get cpu-load]
    :local mem [/system resource get free-memory]
    :local disk [/system resource get free-hdd-space]
    :local uptime [/system resource get uptime]
    :local totalMem [/system resource get total-memory]
    :local usedMem ($totalMem - $mem)
    :local memPercent ($usedMem * 100 / $totalMem)
    :local temperature [/system health get temperature]
    :local voltage [/system health get voltage]
    
    # Log health status
    :log info "=== HEALTH STATUS ==="
    :log info "CPU: $cpu%"
    :log info "Memory: $memPercent% used ($usedMem/$totalMem)"
    :log info "Disk: $disk bytes free"
    :log info "Uptime: $uptime"
    :log info "Temperature: $temperature°C"
    :log info "Voltage: $voltage V"
    :log info "====================="
    
    # Check for issues
    :if ($cpu > 80) do={
        :log warning "HIGH CPU: $cpu%"
        :if ($cpu > 95) do={
            /tool e-mail send to=$adminEmail subject="CRITICAL: High CPU" \
                body="CPU usage is at $cpu% on router $companyName"
        }
    }
    
    :if ($memPercent > 90) do={
        :log warning "HIGH MEMORY: $memPercent%"
        :if ($memPercent > 95) do={
            /tool e-mail send to=$adminEmail subject="CRITICAL: High Memory" \
                body="Memory usage is at $memPercent% on router $companyName"
        }
    }
    
    :if ($disk < 100000000) do={
        :log warning "LOW DISK: $disk bytes"
        /tool e-mail send to=$adminEmail subject="WARNING: Low Disk Space" \
            body="Disk space is low on router $companyName: $disk bytes"
    }
    
    :if ($temperature > 70) do={
        :log warning "HIGH TEMP: $temperature°C"
        /tool e-mail send to=$adminEmail subject="WARNING: High Temperature" \
            body="Temperature is $temperature°C on router $companyName"
    }
    
    :if ($uptime > 30d) do={
        :log info "UPTIME: $uptime - Consider reboot"
    }
}

# ============================================================================
# Network Health Script
# ============================================================================

/system script add name=network-health source={
    # Test internet connectivity
    :local internetStatus [/ping 8.8.8.8 count=3]
    :if ($internetStatus = 0) do={
        :log warning "INTERNET CONNECTIVITY DOWN"
        /tool e-mail send to=$adminEmail subject="CRITICAL: Internet Down" \
            body="Internet connectivity is down on router $companyName"
    } else={
        :log info "Internet connectivity OK"
    }
    
    # Test upstream 1
    :local upstream1Status [/ping $upstream1IP count=3]
    :if ($upstream1Status = 0) do={
        :log warning "UPSTREAM1 DOWN: $upstream1IP"
        /tool e-mail send to=$adminEmail subject="CRITICAL: Upstream1 Down" \
            body="Upstream1 $upstream1IP is down on router $companyName"
    }
    
    # Test upstream 2 (if enabled)
    :if ($enableFailover = "yes") do={
        :local upstream2Status [/ping $upstream2IP count=3]
        :if ($upstream2Status = 0) do={
            :log warning "UPSTREAM2 DOWN: $upstream2IP"
            /tool e-mail send to=$adminEmail subject="CRITICAL: Upstream2 Down" \
                body="Upstream2 $upstream2IP is down on router $companyName"
        }
    }
    
    # Test DNS
    :local dnsStatus [/ping 8.8.8.8 count=3]
    :if ($dnsStatus = 0) do={
        :log warning "DNS RESOLUTION FAILED"
        /tool e-mail send to=$adminEmail subject="WARNING: DNS Issue" \
            body="DNS resolution is failing on router $companyName"
    }
}

# ============================================================================
# Service Health Script
# ============================================================================

/system script add name=service-health source={
    # Check PPPoE service
    :local pppoeStatus [/interface pppoe-server server get [find] running]
    :if ($pppoeStatus != "yes") do={
        :log warning "PPPoE SERVICE DOWN"
        /tool e-mail send to=$adminEmail subject="WARNING: PPPoE Service Down" \
            body="PPPoE service is down on router $companyName"
    }
    
    # Check Hotspot service
    :if ($enableHotspot = "yes") do={
        :local hotspotStatus [/ip hotspot get [find] disabled]
        :if ($hotspotStatus = "yes") do={
            :log warning "HOTSPOT SERVICE DOWN"
            /tool e-mail send to=$adminEmail subject="WARNING: Hotspot Service Down" \
                body="Hotspot service is down on router $companyName"
        }
    }
    
    # Check VPN services
    :if ($enableVPN = "yes") do={
        :local pptpStatus [/interface pptp-server server get [find] enabled]
        :local l2tpStatus [/interface l2tp-server server get [find] enabled]
        :local sstpStatus [/interface sstp-server server get [find] enabled]
        :local ovpnStatus [/interface ovpn-server server get [find] enabled]
        
        :if ($pptpStatus != "yes") do={
            :log warning "PPTP SERVICE DOWN"
        }
        :if ($l2tpStatus != "yes") do={
            :log warning "L2TP SERVICE DOWN"
        }
        :if ($sstpStatus != "yes") do={
            :log warning "SSTP SERVICE DOWN"
        }
        :if ($ovpnStatus != "yes") do={
            :log warning "OPENVPN SERVICE DOWN"
        }
    }
}

# ============================================================================
# Schedulers
# ============================================================================

/system scheduler add name=health-check interval=5m on-event=system-health \
    comment="SYSTEM_HEALTH_CHECK"

/system scheduler add name=network-health interval=1m on-event=network-health \
    comment="NETWORK_HEALTH_CHECK"

/system scheduler add name=service-health interval=10m on-event=service-health \
    comment="SERVICE_HEALTH_CHECK"

:log info "Health check configuration complete"