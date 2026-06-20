###############################################################################
# TOOL: SECURITY-AUDIT.RSC
# Version: 5.0.0
# Description: Security audit and compliance checker
###############################################################################

:log info "================================================"
:log info "SECURITY AUDIT"
:log info "================================================"

# ============================================================================
# Security Audit Script
# ============================================================================

/system script add name=security-audit source={
    :log info "=== SECURITY AUDIT START ==="
    
    # Check services
    :log info "Checking services..."
    :local services { "telnet"; "ftp"; "www"; "api"; "api-ssl" }
    :foreach service in=$services do={
        :local status [/ip service get $service disabled]
        :if ($status = "no") do={
            :log warning "Service $service is enabled (should be disabled)"
        } else={
            :log info "Service $service is disabled (OK)"
        }
    }
    
    # Check secure services
    :local secureServices { "winbox"; "ssh"; "www-ssl" }
    :foreach service in=$secureServices do={
        :local address [/ip service get $service address]
        :if ($address = "0.0.0.0/0") do={
            :log warning "Service $service is accessible from any IP"
        } else={
            :log info "Service $service is restricted to $address (OK)"
        }
    }
    
    # Check firewall rules
    :log info "Checking firewall rules..."
    :local fwRules [/ip firewall filter print count-only]
    :log info "Firewall rules count: $fwRules"
    
    # Check for DDoS protection
    :local ddosRules [/ip firewall raw find comment~"DDOS"]
    :if ([:len $ddosRules] > 0) do={
        :log info "DDoS protection is enabled (OK)"
    } else={
        :log warning "DDoS protection is not configured"
    }
    
    # Check passwords
    :log info "Checking user security..."
    :local users [/user find]
    :foreach user in=$users do={
        :local username [/user get $user name]
        :local password [/user get $user password]
        :if ([:len $password] < 8) do={
            :log warning "User $username has weak password"
        }
    }
    
    # Check SSH settings
    :local sshCrypto [/ip ssh get strong-crypto]
    :if ($sshCrypto = "yes") do={
        :log info "SSH strong crypto is enabled (OK)"
    } else={
        :log warning "SSH strong crypto is disabled"
    }
    
    # Check logging
    :local logging [/system logging print count-only]
    :if ($logging > 10) do={
        :log info "Logging is properly configured (OK)"
    } else={
        :log warning "Logging might be insufficient"
    }
    
    :log info "=== SECURITY AUDIT COMPLETE ==="
}

# ============================================================================
# Security Audit Scheduler
# ============================================================================

/system scheduler add name=security-audit interval=1d start-time=00:00:00 \
    on-event=security-audit comment="SECURITY_AUDIT"

:log info "Security audit configuration complete"