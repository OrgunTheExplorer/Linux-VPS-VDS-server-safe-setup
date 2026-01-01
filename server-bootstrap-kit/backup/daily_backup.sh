#!/bin/bash
set -e

BACKUP_DIR="/opt/backups"
DATE=$(date +%F)
RETENTION_DAYS=7

TARGETS="/etc /home /var/www"

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/backup-$DATE.tar.gz" $TARGETS

find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete
