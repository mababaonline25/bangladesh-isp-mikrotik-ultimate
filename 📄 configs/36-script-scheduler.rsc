###############################################################################
# CONFIG: 36-SCRIPT-SCHEDULER.RSC
# Description: Script and scheduler configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 36: SCRIPT & SCHEDULER"
:log info "================================================"

# System Scripts

# Daily Status Script
/system script add name=daily-status source={
  :local date [/system clock get date]
  :local time [/system clock get time]
  :local uptime [/system resource get uptime]
  :local cpu [/system resource get cpu-load]
  :local mem [/system resource get free-memory]
  :local disk [/system resource get free-hdd-space]
  :local totalMem [/system resource get total-memory]
  :local usedMem ($totalMem - $mem)
  :local memPercent ($usedMem * 100 / $totalMem)
  
  :log info "=== DAILY STATUS REPORT ==="
  :log info "Date: $date"
  :log info "Time: $time"
  :log info "Uptime: $uptime"
  :log info "CPU: $cpu%"
  :log info "Memory: $memPercent% used"
  :log info "Disk: $disk bytes free"
  :log info "============================="
}

# Weekly Report Script
/system script add name=weekly-report source={
  :local activePPPoE [/ppp active print count-only]
  :local activeHotspot [/ip hotspot active print count-only]
  :local totalPPPoE [/ppp secret print count-only]
  :local totalHotspot [/ip hotspot user print count-only]
  
  :log info "=== WEEKLY REPORT ==="
  :log info "Active PPPoE Users: $activePPPoE"
  :log info "Total PPPoE Users: $totalPPPoE"
  :log info "Active Hotspot Users: $activeHotspot"
  :log info "Total Hotspot Users: $totalHotspot"
  :log info "======================"
}

# Monthly Cleanup Script
/system script add name=monthly-cleanup source={
  /file remove [find name="*.log" before=30d]
  /log info "Monthly cleanup completed"
}

# Schedulers
/system scheduler add name=daily-status interval=1d start-time=23:59:00 \
  on-event=daily-status comment="DAILY_STATUS"

/system scheduler add name=weekly-report interval=7d start-time=23:59:00 \
  on-event=weekly-report comment="WEEKLY_REPORT"

/system scheduler add name=monthly-cleanup interval=30d start-time=00:00:00 \
  on-event=monthly-cleanup comment="MONTHLY_CLEANUP"

# PPPoE Session Cleanup
/system script add name=cleanup-pppoe source={
  /ppp active remove [find uptime>30d]
  :log info "Cleaned up old PPPoE sessions"
}

/system scheduler add name=cleanup-pppoe interval=1d start-time=00:00:00 \
  on-event=cleanup-pppoe comment="CLEANUP_PPPOE"

:log info "Script and scheduler configuration complete"