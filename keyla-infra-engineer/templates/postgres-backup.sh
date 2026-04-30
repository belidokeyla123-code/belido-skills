#!/usr/bin/env bash
# PostgreSQL backup script
set -euo pipefail

DB_NAME="${1:-terminal_cerebro}"
DB_USER="${2:-cerebro}"
BACKUP_DIR="/home/ubuntu/backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "Backing up $DB_NAME..."
PGPASSWORD=cerebro_belido_2026 pg_dump -h localhost -U "$DB_USER" "$DB_NAME" | \
  gzip > "$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"

# Keep only last 7 days
find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete

echo "Backup saved: $BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"
ls -lh "$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"
