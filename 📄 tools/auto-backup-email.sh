#!/bin/bash
###############################################################################
# Auto Backup with Email Script
# Version: 5.0.0
# Description: Automatically backup MikroTik configuration and email it
# ============================================================================

# Configuration
MIKROTIK_IP="192.168.20.1"
MIKROTIK_USER="admin"
MIKROTIK_PASS="your-password"
BACKUP_DIR="/var/backups/mikrotik"
EMAIL_TO="admin@yourdomain.com"
EMAIL_FROM="backup@yourdomain.com"
RETENTION_DAYS=30

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="mikrotik_backup_$TIMESTAMP.backup"
RSC_FILE="mikrotik_export_$TIMESTAMP.rsc"

# Connect to MikroTik and create backup
echo "Connecting to MikroTik router..."
sshpass -p "$MIKROTIK_PASS" ssh -o StrictHostKeyChecking=no "$MIKROTIK_USER@$MIKROTIK_IP" \
    "/system backup save name=$BACKUP_FILE; /export file=$RSC_FILE; /file print" > /tmp/router_files.txt

# Download backup files
echo "Downloading backup files..."
scp "$MIKROTIK_USER@$MIKROTIK_IP":"/$BACKUP_FILE" "$BACKUP_DIR/"
scp "$MIKROTIK_USER@$MIKROTIK_IP":"/$RSC_FILE" "$BACKUP_DIR/"

# Remove files from router
sshpass -p "$MIKROTIK_PASS" ssh -o StrictHostKeyChecking=no "$MIKROTIK_USER@$MIKROTIK_IP" \
    "/file remove $BACKUP_FILE; /file remove $RSC_FILE"

# Compress backup
cd $BACKUP_DIR
tar -czf "mikrotik_backup_$TIMESTAMP.tar.gz" "$BACKUP_FILE" "$RSC_FILE"

# Send email with backup
echo "Sending email with backup..."
echo "MikroTik Router Backup - $TIMESTAMP" | \
    mail -s "MikroTik Router Backup - $TIMESTAMP" \
         -a "mikrotik_backup_$TIMESTAMP.tar.gz" \
         $EMAIL_TO

# Cleanup old backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.backup" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.rsc" -mtime +$RETENTION_DAYS -delete

echo "Backup completed successfully!"
echo "Backup location: $BACKUP_DIR/mikrotik_backup_$TIMESTAMP.tar.gz"