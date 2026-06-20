###############################################################################
# TOOL: MAC-BINDING.RSC
# Version: 5.0.0
# Description: MAC address binding for PPPoE users
###############################################################################

:log info "================================================"
:log info "MAC BINDING CONFIGURATION"
:log info "================================================"

# ============================================================================
# Add MAC Binding to User
# ============================================================================

/system script add name=add-mac-binding source={
    :local username $1
    :local macAddress $2
    
    :local user [/ppp secret find name=$username]
    :if ([:len $user] > 0) do={
        /ppp secret set $user calling-station-id=$macAddress
        :log info "MAC binding added for $username: $macAddress"
    } else={
        :log error "User $username not found"
    }
}

# ============================================================================
# Remove MAC Binding from User
# ============================================================================

/system script add name=remove-mac-binding source={
    :local username $1
    
    :local user [/ppp secret find name=$username]
    :if ([:len $user] > 0) do={
        /ppp secret set $user calling-station-id=""
        :log info "MAC binding removed for $username"
    } else={
        :log error "User $username not found"
    }
}

# ============================================================================
# List MAC Bindings
# ============================================================================

/system script add name=list-mac-bindings source={
    :local users [/ppp secret find calling-station-id!=""]
    :log info "=== MAC BINDINGS ==="
    :foreach user in=$users do={
        :local username [/ppp secret get $user name]
        :local mac [/ppp secret get $user calling-station-id]
        :log info "$username -> $mac"
    }
    :log info "===================="
}

# ============================================================================
# MAC Binding Enforcement
# ============================================================================

/system script add name=enforce-mac-binding source={
    :local username $1
    :local macAddress $2
    :local userMac [/ppp secret get [find name=$username] calling-station-id]
    
    :if ([:len $userMac] > 0 && $userMac != $macAddress) do={
        /ppp active remove [find name=$username]
        :log warning "MAC mismatch - session killed for $username"
    }
}

# ============================================================================
# Bulk Add MAC Bindings
# ============================================================================

/system script add name=bulk-add-mac source={
    :local filename $1
    
    :if ([file find name=$filename] != "") do={
        /import file=$filename
        :log info "Bulk MAC bindings imported from $filename"
    } else={
        :log error "File $filename not found"
    }
}

# ============================================================================
# MAC Binding Scheduler
# ============================================================================

/system scheduler add name=mac-binding-check interval=5m on-event={
    :log info "Checking MAC bindings..."
    :local users [/ppp active find]
    :foreach user in=$users do={
        :local username [/ppp active get $user name]
        :local userMac [/ppp active get $user calling-station-id]
        :local storedMac [/ppp secret get [find name=$username] calling-station-id]
        
        :if ([:len $storedMac] > 0 && $storedMac != $userMac) do={
            /ppp active remove $user
            :log warning "MAC mismatch - session killed for $username"
        }
    }
} comment="MAC_BINDING_CHECK"

:log info "MAC binding configuration complete"