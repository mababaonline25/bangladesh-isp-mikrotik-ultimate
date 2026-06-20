###############################################################################
# TOOL: BANDWIDTH-MONITOR.RSC
# Version: 5.0.0
# Description: Bandwidth monitoring and reporting script
###############################################################################

:log info "================================================"
:log info "BANDWIDTH MONITOR STARTING"
:log info "================================================"

# Global variables
:global bandwidthDataFile "bandwidth-data.txt"
:global reportInterval 5

# Function to get interface stats
:local getStats do={
    :local interface $1
    :local stats [/interface monitor-traffic $interface once as-value]
    :return $stats
}

# Function to format bytes
:local formatBytes do={
    :local bytes $1
    :if ($bytes > 1000000000) do={
        :return ($bytes / 1000000000 . " Gbps")
    } else={
        :if ($bytes > 1000000) do={
            :return ($bytes / 1000000 . " Mbps")
        } else={
            :if ($bytes > 1000) do={
                :return ($bytes / 1000 . " Kbps")
            } else={
                :return ($bytes . " bps")
            }
        }
    }
}

# Function to write to file
:local writeData do={
    :local filename $1
    :local data $2
    
    /file print file=$filename
    /file set $filename contents="$data"
}

# Main monitoring loop
:local interfaces { $upstream1Interface; $upstream2Interface; "vlan$vlanPPPoE-PPPoE"; "vlan$vlanManagement-MGMT" }

:log info "Monitoring interfaces: $interfaces"

:foreach interface in=$interfaces do={
    :local stats [$getStats $interface]
    :local rxRate ($stats->"rx-bits-per-second")
    :local txRate ($stats->"tx-bits-per-second")
    :local rxBytes ($stats->"rx-bytes-per-second")
    :local txBytes ($stats->"tx-bytes-per-second")
    
    :local rxFormatted [$formatBytes $rxRate]
    :local txFormatted [$formatBytes $txRate]
    
    :local timestamp [/system clock get time]
    :local date [/system clock get date]
    
    :local logLine "$date $timestamp | $interface | RX: $rxFormatted | TX: $txFormatted"
    :log info $logLine
    
    # Write to file
    /file print file=$bandwidthDataFile
    /file set $bandwidthDataFile contents="$logLine"
}

# Check for high bandwidth usage
:local highRxThreshold 8000000000
:local highTxThreshold 8000000000

:foreach interface in=$interfaces do={
    :local stats [$getStats $interface]
    :local rxRate ($stats->"rx-bits-per-second")
    :local txRate ($stats->"tx-bits-per-second")
    
    :if ($rxRate > $highRxThreshold) do={
        :log warning "HIGH RX BANDWIDTH on $interface: [$formatBytes $rxRate]"
    }
    
    :if ($txRate > $highTxThreshold) do={
        :log warning "HIGH TX BANDWIDTH on $interface: [$formatBytes $txRate]"
    }
}

:log info "Bandwidth monitoring complete"

# ============================================================================
# Bandwidth Report Script
# ============================================================================

/system script add name=bandwidth-report source={
    :local report "/tmp/bandwidth-report.txt"
    
    :log info "Generating bandwidth report..."
    
    # Header
    /file set $report contents="========================================\n"
    /file set $report contents="$reportBANDWIDTH REPORT\n"
    /file set $report contents="$reportDate: [/system clock get date]\n"
    /file set $report contents="$reportTime: [/system clock get time]\n"
    /file set $report contents="========================================\n\n"
    
    # Interface stats
    :foreach interface in=$interfaces do={
        :local stats [$getStats $interface]
        :local rxRate ($stats->"rx-bits-per-second")
        :local txRate ($stats->"tx-bits-per-second")
        :local rxBytes ($stats->"rx-bytes-per-second")
        :local txBytes ($stats->"tx-bytes-per-second")
        
        /file set $report contents="$reportInterface: $interface\n"
        /file set $report contents="$report  RX: [$formatBytes $rxRate] ($rxBytes bytes/sec)\n"
        /file set $report contents="$report  TX: [$formatBytes $txRate] ($txBytes bytes/sec)\n"
        /file set $report contents="$report  \n"
    }
    
    # PPPoE sessions
    :local activePPPoE [/ppp active print count-only]
    /file set $report contents="$reportActive PPPoE Sessions: $activePPPoE\n"
    
    :local activeHotspot [/ip hotspot active print count-only]
    /file set $report contents="$reportActive Hotspot Users: $activeHotspot\n"
    
    /file set $report contents="$report========================================\n"
    
    :log info "Bandwidth report generated: $report"
}

# Schedule bandwidth report
/system scheduler add name=bandwidth-report interval=1h on-event=bandwidth-report \
    comment="BANDWIDTH_REPORT"

:log info "Bandwidth monitor setup complete"