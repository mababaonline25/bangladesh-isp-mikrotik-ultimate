###############################################################################
# TOOL: BULK-USER-CREATE.RSC
# Version: 5.0.0
# Description: Bulk user creation script
###############################################################################

:log info "================================================"
:log info "BULK USER CREATION"
:log info "================================================"

# ============================================================================
# Variables - CHANGE THESE
# ============================================================================

:local userPrefix "customer"
:local startNumber 1
:local endNumber 100
:local defaultPassword "secure-password"
:local defaultProfile "PKG-10-MBPS"
:local defaultService "pppoe"

# ============================================================================
# Bulk Create Users Script
# ============================================================================

/system script add name=bulk-create-users source={
    :local userPrefix $1
    :local startNum $2
    :local endNum $3
    :local password $4
    :local profile $5
    :local service $6
    
    :if ($startNum < 1 || $endNum < $startNum) do={
        :log error "Invalid number range"
        return
    }
    
    :local count 0
    :for i from=$startNum to=$endNum do={
        :local username "$userPrefix$i"
        /ppp secret add name=$username password=$password profile=$profile service=$service
        :set count ($count + 1)
        :if (($count % 10) = 0) do={
            :log info "Created $count users..."
        }
    }
    
    :log info "Bulk user creation completed: $count users created"
}

# ============================================================================
# Create Users with Different Profiles
# ============================================================================

/system script add name=bulk-create-profiles source={
    :local startNum $1
    :local endNum $2
    
    :local profiles { "PKG-5-MBPS"; "PKG-10-MBPS"; "PKG-20-MBPS"; "PKG-50-MBPS"; "PKG-100-MBPS" }
    :local profileIndex 0
    
    :for i from=$startNum to=$endNum do={
        :local username "user$i"
        :local password "pass$i"
        :local profile [:pick $profiles $profileIndex]
        
        /ppp secret add name=$username password=$password profile=$profile service=pppoe
        
        :set profileIndex ($profileIndex + 1)
        :if ($profileIndex >= [:len $profiles]) do={
            :set profileIndex 0
        }
    }
    
    :log info "Bulk users created with different profiles"
}

# ============================================================================
# Create Hotspot Users
# ============================================================================

/system script add name=bulk-create-hotspot source={
    :local startNum $1
    :local endNum $2
    :local password $3
    :local profile $4
    
    :for i from=$startNum to=$endNum do={
        :local username "hotspot$i"
        /ip hotspot user add name=$username password=$password profile=$profile
    }
    
    :log info "Hotspot users created: $startNum to $endNum"
}

# ============================================================================
# Create VPN Users
# ============================================================================

/system script add name=bulk-create-vpn source={
    :local startNum $1
    :local endNum $2
    :local password $3
    :local profile $4
    
    :for i from=$startNum to=$endNum do={
        :local username "vpnuser$i"
        /ppp secret add name=$username password=$password profile=$profile service=pptp,l2tp,sstp,ovpn
    }
    
    :log info "VPN users created: $startNum to $endNum"
}

# ============================================================================
# Execute Bulk Creation
# ============================================================================

:log info "Starting bulk user creation..."

# Create PPPoE users
:if ([:len $userPrefix] > 0 && $startNumber > 0 && $endNumber >= $startNumber) do={
    /system script run bulk-create-users $userPrefix $startNumber $endNumber $defaultPassword $defaultProfile $defaultService
    :log info "PPPoE users created from $userPrefix$startNumber to $userPrefix$endNumber"
}

# Create Hotspot users
:if ($enableHotspot = "yes") do={
    /system script run bulk-create-hotspot 1 50 "hotspot-pass" "basic-profile"
    :log info "Hotspot users created"
}

:log info "Bulk user creation complete"