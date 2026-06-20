###############################################################################
# TOOL: DDNS-CLOUDFLARE.RSC
# Version: 5.0.0
# Description: Cloudflare DDNS update script
###############################################################################

:log info "================================================"
:log info "CLOUDFLARE DDNS CONFIGURATION"
:log info "================================================"

# ============================================================================
# Configuration - CHANGE THESE VALUES
# ============================================================================

:local cfEmail "your-email@domain.com"
:local cfApiKey "YOUR_API_KEY"
:local cfZoneId "YOUR_ZONE_ID"
:local cfRecordId "YOUR_RECORD_ID"
:local cfDomain "yourdomain.com"
:local cfProxied "false"

# ============================================================================
# DDNS Update Script
# ============================================================================

/system script add name=cloudflare-ddns source={
    :local cfEmail "your-email@domain.com"
    :local cfApiKey "YOUR_API_KEY"
    :local cfZoneId "YOUR_ZONE_ID"
    :local cfRecordId "YOUR_RECORD_ID"
    :local cfDomain "yourdomain.com"
    :local cfProxied "false"
    
    # Get current public IP
    :local currentIP [/ip address get [find interface=$upstream1Interface] address]
    :local cleanIP [:pick $currentIP 0 [:find $currentIP "/"]]
    
    :log info "Current IP: $cleanIP"
    
    # Get current DNS record
    :local dnsResult [/tool fetch url="https://api.cloudflare.com/client/v4/zones/$cfZoneId/dns_records/$cfRecordId" \
        http-method=get \
        http-header-field="Authorization: Bearer $cfApiKey, Content-Type: application/json" \
        output=user]
    
    # Check if we need to update
    :local dnsIP ""
    :foreach i in=[:toarray $dnsResult] do={
        :if ([:find $i "\"content\":\""] >= 0) do={
            :local temp [:pick $i ([:find $i "\"content\":\""] + 11) [:len $i]]
            :set dnsIP [:pick $temp 0 [:find $temp "\""]]
        }
    }
    
    :if ($dnsIP != $cleanIP) do={
        :log info "IP changed from $dnsIP to $cleanIP - Updating DNS"
        
        # Update DNS record
        /tool fetch url="https://api.cloudflare.com/client/v4/zones/$cfZoneId/dns_records/$cfRecordId" \
            http-method=put \
            http-header-field="Authorization: Bearer $cfApiKey, Content-Type: application/json" \
            http-data="{\"type\":\"A\",\"name\":\"$cfDomain\",\"content\":\"$cleanIP\",\"ttl\":120,\"proxied\":$cfProxied}"
        
        :log info "DNS updated successfully"
    } else={
        :log info "IP unchanged, no update needed"
    }
}

# ============================================================================
# IPv6 DDNS Support
# ============================================================================

/system script add name=cloudflare-ddns-ipv6 source={
    :local cfEmail "your-email@domain.com"
    :local cfApiKey "YOUR_API_KEY"
    :local cfZoneId "YOUR_ZONE_ID"
    :local cfRecordId "YOUR_RECORD_ID"
    :local cfDomain "ipv6.yourdomain.com"
    :local cfProxied "false"
    
    # Get current IPv6
    :local currentIP [/ipv6 address get [find interface=$upstream1Interface] address]
    :local cleanIP [:pick $currentIP 0 [:find $currentIP "/"]]
    
    :log info "Current IPv6: $cleanIP"
    
    # Update IPv6 record
    /tool fetch url="https://api.cloudflare.com/client/v4/zones/$cfZoneId/dns_records/$cfRecordId" \
        http-method=put \
        http-header-field="Authorization: Bearer $cfApiKey, Content-Type: application/json" \
        http-data="{\"type\":\"AAAA\",\"name\":\"$cfDomain\",\"content\":\"$cleanIP\",\"ttl\":120,\"proxied\":$cfProxied}"
    
    :log info "IPv6 DNS updated successfully"
}

# ============================================================================
# DDNS Scheduler
# ============================================================================

/system scheduler add name=cloudflare-ddns interval=5m on-event=cloudflare-ddns \
    comment="CLOUDFLARE_DDNS"

/system scheduler add name=cloudflare-ddns-ipv6 interval=5m on-event=cloudflare-ddns-ipv6 \
    comment="CLOUDFLARE_DDNS_IPV6"

:log info "Cloudflare DDNS configuration complete"