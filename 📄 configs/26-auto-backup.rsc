###############################################################################
# CONFIG: 26-AUTO-BACKUP.RSC
# Description: Auto backup configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 26: AUTO BACKUP"
:log info "================================================"

# Daily Backup
/system scheduler add name=daily-backup start-time=02:00:00 interval=1d on-event={
  /export file=backup-([/system clock get date]).rsc
  /system backup save name=backup-([/system clock get date]).backup
  /file remove [find name="backup-*.backup" type=backup before=7d]
  /file remove [find name="backup-*.rsc" type=script before=7d]
  :log info ("Backup created: backup-" . [/system clock get date] . ".rsc")
} comment="DAILY_BACKUP"

# Weekly Backup
/system scheduler add name=weekly-backup start-time=03:00:00 interval=7d on-event={
  /export file=backup-weekly-([/system clock get date]).rsc
  /system backup save name=backup-weekly-([/system clock get date]).backup
  :log info ("Weekly backup created")
} comment="WEEKLY_BACKUP"

# User Backup (Local Users Only)
/system scheduler add name=user-backup start-time=04:00:00 interval=1d on-event={
  :if ($useRadius = "no") do={
    /export file=users-([/system clock get date]).rsc
    :log info ("User backup created: users-" . [/system clock get date] . ".rsc")
  }
} comment="USER_BACKUP"

# Email Backup
:if ($enableEmailAlerts = "yes") do={
  /system scheduler add name=email-backup start-time=05:00:00 interval=7d on-event={
    /export file=backup-email.rsc
    /tool e-mail send to=$adminEmail subject="Router Backup $companyName" \
      file=backup-email.rsc
    /file remove backup-email.rsc
    :log info "Email backup sent"
  } comment="EMAIL_BACKUP"
}

# Auto Cleanup
/system script add name=auto-cleanup source={
  /file remove [find name="*.rsc" type=script before=30d]
  /file remove [find name="*.backup" type=backup before=30d]
  /log info "Old backup files cleaned up"
}

/system scheduler add name=cleanup-backup start-time=06:00:00 interval=7d on-event=auto-cleanup \
  comment="CLEANUP_BACKUP"

:log info "Auto backup configuration complete"