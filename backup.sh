#!/bin/bash

# backup.sh - Backup script for Strapi data (outside repository)

set -e

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="strapi_backup_${TIMESTAMP}.tar.gz"

echo "🗄️ Starting Strapi data backup..."

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Check if data directories exist
if [ ! -d "../uploads" ] || [ ! -d "../data" ] || [ ! -d "../database" ]; then
    echo "❌ Error: Data directories not found!"
    echo "Expected directories:"
    echo "  - ../uploads"
    echo "  - ../data"
    echo "  - ../database"
    exit 1
fi

echo "📁 Backing up directories:"
echo "   - Database: $(realpath ../database)"
echo "   - Uploads: $(realpath ../uploads)"
echo "   - Data: $(realpath ../data)"

# Create backup
echo "📦 Creating backup archive..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    -C .. \
    uploads \
    data \
    database

echo "✅ Backup completed!"
echo "📁 Backup saved as: $BACKUP_DIR/$BACKUP_FILE"
echo "📊 Backup size: $(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)"

# List recent backups
echo ""
echo "📋 Recent backups:"
ls -lah $BACKUP_DIR/strapi_backup_*.tar.gz 2>/dev/null | tail -5 || echo "No previous backups found"

echo ""
echo "To restore from this backup:"
echo "  1. Stop the application: docker compose down"
echo "  2. Extract backup: tar -xzf $BACKUP_DIR/$BACKUP_FILE -C .."
echo "  3. Start the application: docker compose up -d"
