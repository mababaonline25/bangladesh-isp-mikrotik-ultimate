###############################################################################
# CONFIG: 35-EMAIL-ALERTS.RSC
# Description: Email alerts configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 35: EMAIL ALERTS"
:log info "================================================"

:if ($enableEmailAlerts = "yes") do={

  # Email Configuration
  /tool e-mail set server=10.99.0.10 port=25 from=noc@$companyName.com.bd
  /tool e-mail set starttls=yes user=noc password=email-password
  
  # Email Alert Scripts
  /system script add name=send-email-alert source={
    :local subject "ALERT: Router $companyName"
    :local body "Time: [/system clock get time]\nDate: [/system clock get date]\nLocation: $routerLocation"
    /tool e-mail send to=$adminEmail subject=$subject body=$body
  }
  
  # Critical Alerts
  /system script add name=critical-alert source={
    /tool e-mail send to=$adminEmail subject="CRITICAL: Router $companyName" \
      body="Critical event detected on router $companyName at $routerLocation"
  }
  
  # Alert Scheduler
  /system scheduler add name=email-status interval=1h on-event=send-email-alert \
    comment="EMAIL_STATUS_UPDATE"
  
  :log info "Email alerts configuration complete"
} else={
  :log info "Email alerts are disabled"
}