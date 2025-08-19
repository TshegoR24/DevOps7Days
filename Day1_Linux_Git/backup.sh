#!/bin/bash
# Simple backup script
DATE=$(date +%F)
BACKUP_DIR="$HOME/backup_$DATE"

mkdir -p $BACKUP_DIR
cp *.txt $BACKUP_DIR 2>/dev/null

echo "Backup completed to $BACKUP_DIR"
