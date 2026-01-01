
#!/bin/bash

STATE_DIR="/var/tmp/server_monitor_state"
LOGFILE="/var/log/server_alerts.log"

mkdir -p $STATE_DIR

DATE=$(date '+%Y-%m-%d %H:%M:%S')

# CPU (load avg normalized)
CPU_LOAD=$(awk '{print $1}' /proc/loadavg)
CPU_CORES=$(nproc)
CPU_PERCENT=$(awk "BEGIN {printf \"%d\", ($CPU_LOAD/$CPU_CORES)*100}")

# RAM
RAM_USED=$(free | awk '/Mem:/ { printf("%d"), $3/$2 * 100 }')

# Disk
DISK_USED=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

### CPU ALERT ###
CPU_STATE="$STATE_DIR/cpu_alert"

if [ "$CPU_PERCENT" -ge 80 ]; then
    if [ ! -f "$CPU_STATE" ]; then
        echo "$DATE | WARNING: CPU usage above 80% ($CPU_PERCENT%)" >> $LOGFILE
        touch $CPU_STATE
    fi
else
    if [ -f "$CPU_STATE" ]; then
        echo "$DATE | INFO: CPU usage back to normal ($CPU_PERCENT%)" >> $LOGFILE
        rm $CPU_STATE
    fi
fi

### RAM ALERT ###
RAM_STATE="$STATE_DIR/ram_alert"

if [ "$RAM_USED" -ge 80 ]; then
    if [ ! -f "$RAM_STATE" ]; then
        echo "$DATE | WARNING: RAM usage above 80% ($RAM_USED%)" >> $LOGFILE
        touch $RAM_STATE
    fi
else
    if [ -f "$RAM_STATE" ]; then
        echo "$DATE | INFO: RAM usage back to normal ($RAM_USED%)" >> $LOGFILE
        rm $RAM_STATE
    fi
fi

### DISK ALERT (one-time only) ###
DISK_STATE="$STATE_DIR/disk_alert"

if [ "$DISK_USED" -ge 80 ]; then
    if [ ! -f "$DISK_STATE" ]; then
        echo "$DATE | WARNING: Disk usage above 80% ($DISK_USED%)" >> $LOGFILE
        touch $DISK_STATE
    fi
fi
