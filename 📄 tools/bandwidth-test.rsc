###############################################################################
# TOOL: BANDWIDTH-TEST.RSC
# Version: 5.0.0
# Description: Bandwidth test tools
###############################################################################

:log info "================================================"
:log info "BANDWIDTH TEST TOOLS"
:log info "================================================"

# ============================================================================
# Bandwidth Test Script
# ============================================================================

/system script add name=bandwidth-test source={
    :local target $1
    :local duration $2
    :local direction $3
    
    :if ([:len $target] = 0) do={
        :set target "8.8.8.8"
    }
    :if ([:len $duration] = 0) do={
        :set duration "10"
    }
    :if ([:len $direction] = 0) do={
        :set direction "both"
    }
    
    :log info "Starting bandwidth test to $target for $duration seconds ($direction)"
    /tool bandwidth-test address=$target duration=$duration direction=$direction
}

# ============================================================================
# Speed Test Script
# ============================================================================

/system script add name=speed-test source={
    :local target "8.8.8.8"
    :local duration 10
    
    :log info "=== SPEED TEST START ==="
    :log info "Testing upload speed..."
    /tool bandwidth-test address=$target duration=$duration direction=transmit
    
    :log info "Testing download speed..."
    /tool bandwidth-test address=$target duration=$duration direction=receive
    
    :log info "Testing full duplex..."
    /tool bandwidth-test address=$target duration=$duration direction=both
    :log info "=== SPEED TEST COMPLETE ==="
}

# ============================================================================
# Bandwidth Test Results
# ============================================================================

/system script add name=show-bandwidth-results source={
    :log info "=== BANDWIDTH TEST RESULTS ==="
    :local results [/tool bandwidth-test print]
    :log info $results
    :log info "==============================="
}

# ============================================================================
# Continuous Bandwidth Monitor
# ============================================================================

/system script add name=continuous-bandwidth source={
    :local target $1
    :local interval $2
    
    :if ([:len $target] = 0) do={
        :set target "8.8.8.8"
    }
    :if ([:len $interval] = 0) do={
        :set interval 60
    }
    
    :log info "Starting continuous bandwidth monitoring to $target (interval: $interval seconds)"
    
    :while (true) do={
        :local result [/tool bandwidth-test address=$target duration=5 direction=both]
        :log info "Bandwidth: $result"
        :delay $interval
    }
}

# ============================================================================
# Bandwidth Test Scheduler
# ============================================================================

/system scheduler add name=hourly-bandwidth-test interval=1h on-event={
    /system script run speed-test
} comment="HOURLY_BANDWIDTH_TEST"

:log info "Bandwidth test tools configuration complete"