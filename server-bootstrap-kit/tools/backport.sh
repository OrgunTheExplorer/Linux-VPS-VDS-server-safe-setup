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
    ACTION="$1"   # tcp
    ARG1="$2"     # port | status | remove
    ARG2="$3"     # mode | index
    ARG3="$4"

    STATE_DIR="/var/lib/backport"
    DB="$STATE_DIR/tunnels.db"

    mkdir -p "$STATE_DIR"

    # ---------- STATUS ----------
    if [[ "$ARG1" == "status" ]]; then
        if [ ! -f "$DB" ]; then
            echo "No active tunnels."
            return
        fi

        echo "ID | PROTO | PORT | MODE | DESTINATION"
        echo "--------------------------------------"
        while IFS="|" read -r ID PROTO PORT MODE USER IP PID; do
            echo "$ID | $PROTO | $PORT | $MODE | $USER@$IP (PID $PID)"
        done < "$DB"
        return
    fi

    # ---------- REMOVE ----------
    if [[ "$ARG1" == "remove" ]]; then
        INDEX="$ARG2"

        if [ ! -f "$DB" ]; then
            echo "No tunnels to remove."
            exit 1
        fi

        LINE=$(sed -n "${INDEX}p" "$DB")
        [ -z "$LINE" ] && { echo "Invalid index"; exit 1; }

        IFS="|" read -r ID PROTO PORT MODE USER IP PID <<< "$LINE"

        if [[ "$MODE" == "sender" ]]; then
            kill "$PID" 2>/dev/null || true
        fi

        if [[ "$MODE" == "sender-receiver" ]]; then
            sed -i 's/^GatewayPorts yes/GatewayPorts no/' /etc/ssh/sshd_config
            sed -i 's/^AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config
            systemctl restart sshd
        fi

        sed -i "${INDEX}d" "$DB"
        echo "Tunnel removed."
        return
    fi

    # ---------- CREATE ----------
    PROTOCOL="$ACTION"
    PORT="$ARG1"
    MODE="$ARG2"

    if [[ "$PROTOCOL" != "tcp" ]]; then
        echo "Only tcp supported for SSH forwarding"
        exit 1
    fi

    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
        echo "Invalid port"
        exit 1
    fi

    # ---------- SENDER ----------
    if [[ "$MODE" == "sender" ]]; then

        if [ -f "$DB" ]; then
            echo "Saved destinations:"
            awk -F"|" '{print NR ") " $5 "@" $6}' "$DB"
            echo "0) New destination"
        else
            echo "0) New destination"
        fi

        read -p "Select destination: " CHOICE

        if [[ "$CHOICE" != "0" ]]; then
            LINE=$(sed -n "${CHOICE}p" "$DB")
            IFS="|" read -r _ _ _ _ USER IP _ <<< "$LINE"
        else
            read -p "VPS User: " USER
            read -p "VPS IP: " IP
        fi

        ssh -N -R "$PORT:127.0.0.1:$PORT" "$USER@$IP" &
        PID=$!

        ID=$(($(wc -l < "$DB" 2>/dev/null || echo 0) + 1))
        echo "$ID|tcp|$PORT|sender|$USER|$IP|$PID" >> "$DB"

        echo "SSH tunnel started (PID $PID)"
        return
    fi

    # ---------- SENDER-RECEIVER ----------
    if [[ "$MODE" == "sender-receiver" ]]; then
        sed -i 's/^#\?GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config
        sed -i 's/^#\?AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
        systemctl restart sshd

        ID=$(($(wc -l < "$DB" 2>/dev/null || echo 0) + 1))
        echo "$ID|tcp|$PORT|sender-receiver|local|localhost|0" >> "$DB"

        echo "Server forwarding enabled."
        return
    fi

    echo "Invalid mode"
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
    restore)
        restore_backup
        ;;
    tcp|udp)
        port_control "$COMMAND" "$ARG1" "$ARG2"
        ;;
    *)
        echo "Usage:"
        echo "  backport health"
        echo "  backport backup"
        echo "  backport restore"
        echo "  backport <tcp|udp> <port|status|remove> <sender|sender-receiver>"
        exit 1
        ;;
esac
