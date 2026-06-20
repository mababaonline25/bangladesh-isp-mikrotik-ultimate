###############################################################################
# TOOL: USER-MIGRATION.RSC
# Version: 5.0.0
# Description: User migration script for PPPoE users
###############################################################################

:log info "================================================"
:log info "USER MIGRATION SCRIPT"
:log info "================================================"

# ============================================================================
# Variables
# ============================================================================

:local sourceFile "old-users.rsc"
:local destFile "new-users.rsc"
:local backupFile "users-backup.rsc"

# ============================================================================
# Backup Existing Users
# ============================================================================

/system script add name=backup-users source={
    :local timestamp [/system clock get date]
    :local backupFile "users-backup-$timestamp.rsc"
    
    /export file=$backupFile
    :log info "Users backed up to $backupFile"
}

# ============================================================================
# Import Users from File
# ============================================================================

/system script add name=import-users source={
    :local importFile $1
    
    :if ([file find name=$importFile] != "") do={
        /import file=$importFile
        :log info "Users imported from $importFile"
    } else={
        :log error "Import file $importFile not found"
    }
}

# ============================================================================
# Bulk User Creation
# ============================================================================

/system script add name=bulk-create-users source={
    :local userPrefix $1
    :local startNum $2
    :local endNum $3
    :local password $4
    :local profile $5
    
    :for i from=$startNum to=$endNum do={
        :local username "$userPrefix$i"
        /ppp secret add name=$username password=$password profile=$profile service=pppoe
        :log info "User $username created"
    }
    
    :log info "Users $userPrefix$startNum to $userPrefix$endNum created"
}

# ============================================================================
# User Profile Migration
# ============================================================================

/system script add name=migrate-user-profile source={
    :local oldProfile $1
    :local newProfile $2
    
    /ppp secret set [find profile=$oldProfile] profile=$newProfile
    :log info "Users migrated from $oldProfile to $newProfile"
}

# ============================================================================
# User Password Update
# ============================================================================

/system script add name=update-user-passwords source={
    :local username $1
    :local newPassword $2
    
    /ppp secret set [find name=$username] password=$newPassword
    :log info "Password updated for user $username"
}

# ============================================================================
# Delete Expired Users
# ============================================================================

/system script add name=delete-expired-users source={
    :local expiryDate $1
    
    # This is a placeholder - actual implementation depends on how you track expiry
    :log info "Expired users deletion started"
    
    # Example: Delete users with specific comment
    /ppp secret remove [find comment="EXPIRED"]
    
    :log info "Expired users deleted"
}

# ============================================================================
# Export Users to CSV
# ============================================================================

/system script add name=export-users-csv source={
    :local filename "users-export.csv"
    
    # Create CSV header
    /file set $filename contents="Username,Password,Profile,Service,Comment\n"
    
    # Get all users
    :foreach user in=[/ppp secret find] do={
        :local username [/ppp secret get $user name]
        :local password [/ppp secret get $user password]
        :local profile [/ppp secret get $user profile]
        :local service [/ppp secret get $user service]
        :local comment [/ppp secret get $user comment]
        
        :local line "$username,$password,$profile,$service,$comment\n"
        /file set $filename contents=[/file get $filename contents] . $line
    }
    
    :log info "Users exported to $filename"
}

# ============================================================================
# Schedulers for Migration Tasks
# ============================================================================

/system scheduler add name=daily-user-backup start-time=01:00:00 interval=1d \
    on-event=backup-users comment="DAILY_USER_BACKUP"

:log info "User migration tools configuration complete"