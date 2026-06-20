###############################################################################
# CONFIG: 37-USER-MANAGEMENT.RSC
# Description: User management configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 37: USER MANAGEMENT"
:log info "================================================"

# Local Users
/user add name=admin group=full password=secure-admin-password
/user add name=network-engineer group=write password=network-pass
/user add name=monitoring group=read password=monitor-pass
/user add name=billing group=read password=billing-pass
/user add name=support group=read password=support-pass

# User Groups
/user group add name=network-admin policy=local,ssh,reboot,read,write,policy,test,password,web,winbox,sniff
/user group add name=network-write policy=local,ssh,read,write,test,web,winbox
/user group add name=network-read policy=local,ssh,read,test,web
/user group add name=monitoring-group policy=local,read,test
/user group add name=billing-group policy=local,read

# SSH Keys
:if ([file find name="admin-key.pub"] != "") do={
  /user ssh-keys add user=admin public-key-file=admin-key.pub
}

:if ([file find name="engineer-key.pub"] != "") do={
  /user ssh-keys add user=network-engineer public-key-file=engineer-key.pub
}

# User Scripts
/system script add name=add-user source={
  :local username $1
  :local password $2
  :local profile $3
  
  /ppp secret add name=$username password=$password profile=$profile service=pppoe
  :log info "User $username added with profile $profile"
}

/system script add name=remove-user source={
  :local username $1
  /ppp secret remove [find name=$username]
  :log info "User $username removed"
}

/system script add name=list-users source={
  /ppp secret print
}

# Scheduler for User Reports
/system scheduler add name=user-report interval=1d start-time=06:00:00 on-event={
  :if ($useRadius = "no") do={
    :log info "Active PPPoE Users: [/ppp active print count-only]"
    :log info "Total PPPoE Users: [/ppp secret print count-only]"
  }
} comment="USER_REPORT"

:log info "User management configuration complete"