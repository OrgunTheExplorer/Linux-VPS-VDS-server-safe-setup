#!/bin/bash
set -e

BACKUP_DIR="/var/backups/server"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_$TIMESTAMP.tar.gz"

# What to back up
INCLUDE_DIRS=(
    "/etc"
    "/home"
)

# Create backup directory if missing
mkdir -p "$BACKUP_DIR"

echo "[$(date)] Backup started"

tar -czpf "$BACKUP_DIR/$ARCHIVE_NAME" \
    --exclude=/proc \
    --exclude=/sys \
    --exclude=/dev \
    --exclude=/tmp \
    "${INCLUDE_DIRS[@]}"

echo "[$(date)] Backup completed: $BACKUP_DIR/$ARCHIVE_NAME"
