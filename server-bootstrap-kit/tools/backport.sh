#!/bin/bash
set -e

# Must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "This command must be run as root."
    exit 1
fi

COMMAND="$1"
ARG1="$2"
ARG2="$3"
ARG3="$4"

# ---------------- HEALTH ----------------
health_check() {
    echo "===== SYSTEM HEALTH ====="
    echo "Date: $(date)"
    echo

    echo "CPU:"
    uptime
    echo

    echo "Memory:"
    free -h
    echo

    echo "Disk:"
    df -h /
    echo
}

# ---------------- BACKUP ----------------
run_backup() {
    BACKUP_SCRIPT="/opt/server-bootstrap-kit/backup/daily_backup.sh"

    if [ ! -x "$BACKUP_SCRIPT" ]; then
        echo "Backup script not found or not executable:"
        echo "$BACKUP_SCRIPT"
        exit 1
    fi

    echo "Running backup..."
    "$BACKUP_SCRIPT"
    echo "Backup completed."
}

# ---------------- PORT ----------------
port_control() {
    PROTOCOL="$1"
    PORT="$2"
    MODE="$3"

    if [[ "$PROTOCOL" != "tcp" && "$PROTOCOL" != "udp" ]]; then
        echo "Protocol must be tcp or udp"
        exit 1
    fi

    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -gt 65535 ]; then
        echo "Invalid port number"
        exit 1
    fi

    case "$MODE" in
        sender)
            ufw allow out "$PORT/$PROTOCOL"
            ;;
        receiver)
            ufw allow "$PORT/$PROTOCOL"
            ;;
        sender-receiver)
            ufw allow "$PORT/$PROTOCOL"
            ufw allow out "$PORT/$PROTOCOL"
            ;;
        *)
            echo "Mode must be sender, receiver or sender-receiver"
            exit 1
            ;;
    esac

    echo "Firewall rule applied successfully."
}
# ---------------- RESTORE ----------------
restore_backup() {
    BACKUP_DIR="/var/backups/server"

    if [ ! -d "$BACKUP_DIR" ]; then
        echo "❌ Backup directory not found: $BACKUP_DIR"
        exit 1
    fi

    mapfile -t BACKUPS < <(ls -1 "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null)

    if [ "${#BACKUPS[@]}" -eq 0 ]; then
        echo "❌ No backups found in $BACKUP_DIR"
        exit 1
    fi

    echo "===== AVAILABLE BACKUPS ====="
    for i in "${!BACKUPS[@]}"; do
        printf "%d) %s\n" "$((i+1))" "$(basename "${BACKUPS[$i]}")"
    done

    echo
    read -p "Select backup to restore (number): " CHOICE

    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#BACKUPS[@]}" ]; then
        echo "❌ Invalid selection"
        exit 1
    fi

    SELECTED_BACKUP="${BACKUPS[$((CHOICE-1))]}"

    echo
    echo "⚠️ WARNING: This will overwrite /etc and /home"
    read -p "Are you sure you want to restore? (yes/no): " CONFIRM

    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Restore cancelled."
        exit 0
    fi

    echo "▶ Restoring from: $(basename "$SELECTED_BACKUP")"

    tar -xpf "$SELECTED_BACKUP" -C /

    echo "✅ Restore completed successfully."
    echo "⚠️ A reboot is recommended."
}


# ---------------- MAIN ----------------
case "$COMMAND" in
    health)
        health_check
        ;;
    backup)
        run_backup
        ;;
    tcp|udp)
        port_control "$COMMAND" "$ARG1" "$ARG2"
        ;;
    *)
        echo "Usage:"
        echo "  backport health"
        echo "  backport backup"
        echo "  backport <tcp|udp> <port> <sender|receiver|sender-receiver>"
        exit 1
        ;;
esac
