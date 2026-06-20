###############################################################################
# TOOL: PPPOE-SESSION-KILL.RSC
# Version: 5.0.0
# Description: Kill PPPoE sessions
###############################################################################

:log info "================================================"
:log info "PPPoE SESSION MANAGEMENT"
:log info "================================================"

# ============================================================================
# Kill Session by Username
# ============================================================================

/system script add name=kill-user-session source={
    :local username $1
    
    :local sessions [/ppp active find name=$username]
    :if ([:len $sessions] > 0) do={
        /ppp active remove $sessions
        :log info "Session killed for user: $username"
    } else={
        :log info "No active session found for user: $username"
    }
}

# ============================================================================
# Kill Session by IP
# ============================================================================

/system script add name=kill-ip-session source={
    :local ipAddress $1
    
    :local sessions [/ppp active find address=$ipAddress]
    :if ([:len $sessions] > 0) do={
        /ppp active remove $sessions
        :log info "Sessions killed for IP: $ipAddress"
    } else={
        :log info "No active session found for IP: $ipAddress"
    }
}

# ============================================================================
# Kill All User Sessions
# ============================================================================

/system script add name=kill-all-sessions source={
    :local username $1
    
    :local sessions [/ppp active find name=$username]
    /ppp active remove $sessions
    :log info "All sessions killed for user: $username"
}

# ============================================================================
# Kill All Sessions
# ============================================================================

/system script add name=kill-all-pppoe source={
    /ppp active remove [find]
    :log warning "All PPPoE sessions killed"
}

# ============================================================================
# Kill Idle Sessions
# ============================================================================

/system script add name=kill-idle-sessions source={
    :local idleTime $1
    
    :foreach session in=[/ppp active find] do={
        :local idle [/ppp active get $session idle-time]
        :if ($idle > $idleTime) do={
            /ppp active remove $session
            :log info "Idle session killed: [$idle seconds]"
        }
    }
}

# ============================================================================
# Kill Old Sessions
# ============================================================================

/system script add name=kill-old-sessions source={
    :local maxAge $1
    
    :foreach session in=[/ppp active find] do={
        :local uptime [/ppp active get $session uptime]
        :if ($uptime > $maxAge) do={
            /ppp active remove $session
            :log info "Old session killed: [$uptime]"
        }
    }
}

# ============================================================================
# Session Management Commands
# ============================================================================

:log info "PPPoE session management tools ready"

# Example usage:
# /system script run kill-user-session username
# /system script run kill-ip-session 10.10.1.100
# /system script run kill-all-sessions username
# /system script run kill-all-pppoe
# /system script run kill-idle-sessions 3600  # Kill sessions idle for 1 hour
# /system script run kill-old-sessions 86400  # Kill sessions older than 24 hours