#!/bin/bash

# Configuration
LOG_FILE="/var/log/disk_monitor.log"
TO="your_mail@gmail.com"
THRESHOLD=80

# Automatically detect partition (uses sda2 if present, otherwise falls back to root partition)
TARGET_PARTITION="sda2"
if ! df -H | grep -q "$TARGET_PARTITION"; then
    TARGET_PARTITION=$(df / | awk 'NR==2 {print $1}' | sed 's/.*\/\|\/dev\///')
fi

# Monitor free space in disk
FU=$(df -H | egrep -v "Filesystem|tmpfs" | grep "$TARGET_PARTITION" | awk '{print $5}' | tr -d %)

# Generate timestamp for logging
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Send alert to mail and log the event if disk space is low
if [[ $FU -ge $THRESHOLD ]]
then
    ALERT_MSG="Warning, disk space is low - $FU % on $TARGET_PARTITION"
    
    # 1. Log the warning
    echo "[$TIMESTAMP] ALERT: $ALERT_MSG" >> "$LOG_FILE"
    
    # 2. Send the email alert
    echo "$ALERT_MSG" | mail -s "DISK SPACE ALERT IN SERVER" "$TO"
else
    # Log healthy status to keep a history
    echo "[$TIMESTAMP] OK: Disk space is sufficient - $FU % on $TARGET_PARTITION" >> "$LOG_FILE"
    echo "All Good"
fi

