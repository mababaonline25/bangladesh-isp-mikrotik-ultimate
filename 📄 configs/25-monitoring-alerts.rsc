###############################################################################
# CONFIG: 25-MONITORING-ALERTS.RSC
# Description: Monitoring and alerts configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 25: MONITORING & ALERTS"
:log info "================================================"

# Netwatch - Internet Monitoring
/tool netwatch add host=8.8.8.8 interval=10s timeout=2s \
  up-script=":log info \"INTERNET_UP\"" \
  down-script=":log warning \"INTERNET_DOWN\"" \
  comment="GOOGLE_DNS"

/tool netwatch add host=1.1.1.1 interval=10s timeout=2s \
  up-script="" down-script=":log warning \"CLOUDFLARE_DNS_DOWN\"" \
  comment="CLOUDFLARE_DNS"

/tool netwatch add host=$upstream1IP interval=10s timeout=2s \
  up-script=":log info \"UPSTREAM1_UP\"" \
  down-script=":log warning \"UPSTREAM1_DOWN\"" \
  comment="UPSTREAM1"

:if ($enableFailover = "yes") do={
  /tool netwatch add host=$upstream2IP interval=10s timeout=2s \
    up-script=":log info \"UPSTREAM2_UP\"" \
    down-script=":log warning \"UPSTREAM2_DOWN\"" \
    comment="UPSTREAM2"
}

# System Health Script
/system script add name=system-health source={
  :local cpu [/system resource get cpu-load]
  :local mem [/system resource get free-memory]
  :local disk [/system resource get free-hdd-space]
  :local uptime [/system resource get uptime]
  :local totalMem [/system resource get total-memory]
  :local usedMem ($totalMem - $mem)
  :local memPercent ($usedMem * 100 / $totalMem)
  :local temperature [/system health get temperature]
  
  :if ($cpu > 80) do={:log warning "HIGH_CPU: $cpu%"}
  :if ($memPercent > 90) do={:log warning "HIGH_MEMORY: $memPercent%"}
  :if ($disk < 100000000) do={:log warning "LOW_DISK: $disk bytes"}
  :if ($temperature > 70) do={:log warning "HIGH_TEMP: $temperature°C"}
  :if ($uptime > 30d) do={:log info "UPTIME: $uptime - Consider reboot"}
  
  :if ($cpu > 90 || $memPercent > 95 || $temperature > 75) do={
    /tool e-mail send to=$adminEmail subject="ALERT: Router $companyName" \
      body="CPU: $cpu%, Memory: $memPercent%, Temp: $temperature°C, Disk: $disk bytes"
  }
}

/system scheduler add name=health-check interval=5m on-event=system-health \
  comment="HEALTH_MONITOR"

# Session Monitor Script
/system script add name=session-monitor source={
  :local activeUsers [/ppp active print count-only]
  :local hotspotUsers [/ip hotspot active print count-only]
  :local maxUsers $maxUsers
  
  :if ($activeUsers > $maxUsers) do={
    :log warning "MAX_USERS_LIMIT: $activeUsers"
    /tool e-mail send to=$adminEmail subject="ALERT: Max Users Limit" \
      body="Active PPPoE Users: $activeUsers, Hotspot Users: $hotspotUsers"
  }
}

/system scheduler add name=session-check interval=5m on-event=session-monitor \
  comment="SESSION_MONITOR"

# Traffic Monitor Script
/system script add name=traffic-monitor source={
  :local rx [/interface monitor-traffic $upstream1Interface once as-value]
  :local tx [/interface monitor-traffic $upstream1Interface once as-value]
  :local rxRate ($rx->"rx-bits-per-second")
  :local txRate ($tx->"tx-bits-per-second")
  
  :if ($rxRate > 8000000000) do={
    :log warning "HIGH_RX: $rxRate bps"
  }
  :if ($txRate > 8000000000) do={
    :log warning "HIGH_TX: $txRate bps"
  }
}

/system scheduler add name=traffic-monitor interval=5m on-event=traffic-monitor \
  comment="TRAFFIC_MONITOR"

# PPPoE Session Monitor
/system script add name=pppoe-session-monitor source={
  :local total [/interface pppoe-server session print count-only]
  :local active [/interface pppoe-server session print count-only where caller-id!="0.0.0.0"]
  :log info "PPPoE Sessions: Active=$active, Total=$total"
}

/system scheduler add name=pppoe-monitor interval=10m on-event=pppoe-session-monitor \
  comment="PPPOE_MONITOR"

:log info "Monitoring and alerts configuration complete"