#!/bin/bash

# restore.sh - Restore script for Strapi data

set -e

if [ -z "$1" ]; then
    echo "❌ Usage: $0 <backup_file.tar.gz>"
    echo ""
    echo "Available backups:"
    ls -1 backups/strapi_backup_*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file '$BACKUP_FILE' not found!"
    exit 1
fi

echo "🔄 Starting Strapi data restore..."
echo "📁 Restoring from: $BACKUP_FILE"

# Stop the application if running
echo "🛑 Stopping application..."
docker compose down 2>/dev/null || true

# Backup current data (safety measure)
if [ -d "../uploads" ] || [ -d "../data" ] || [ -d "../database" ]; then
    SAFETY_BACKUP="backups/pre_restore_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo "💾 Creating safety backup: $SAFETY_BACKUP"
    mkdir -p backups
    tar -czf "$SAFETY_BACKUP" -C .. uploads data database 2>/dev/null || echo "No existing data to backup"
fi

# Remove existing data
echo "🗑️ Removing existing data..."
rm -rf ../uploads ../data ../database

# Extract backup
echo "📦 Extracting backup..."
tar -xzf "$BACKUP_FILE" -C ..

echo "✅ Restore completed!"
echo ""
echo "🚀 Starting application..."
docker compose up -d

echo ""
echo "✅ Restore process completed!"
echo "🌐 Your application should be available shortly at http://localhost:1437"
