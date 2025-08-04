#!/bin/bash

# deploy.sh - Production deployment script for Strapi application

set -e

echo "🚀 Starting Strapi deployment..."

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "❌ Error: .env.production file not found!"
    echo "Please copy .env.production.example to .env.production and configure your environment variables."
    exit 1
fi

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed!"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "❌ Error: Docker Compose is not installed!"
    exit 1
fi

# Create necessary directories for bind mounts outside the repo
echo "📁 Creating necessary directories outside repository..."
mkdir -p ../uploads
mkdir -p ../data/uploads
mkdir -p ../database

# Set proper permissions
chmod 755 ../uploads ../data ../database
chmod 755 ../data/uploads

echo "📁 Data directories created:"
echo "   - Database: $(realpath ../database)"
echo "   - Uploads: $(realpath ../uploads)"
echo "   - Data uploads: $(realpath ../data/uploads)"

# Choose deployment type
read -p "Use simple deployment without nginx? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    COMPOSE_FILE="docker-compose.simple.yml"
    echo "📝 Using simple deployment (docker-compose.simple.yml)"
else
    COMPOSE_FILE="docker-compose.yml"
    echo "📝 Using full deployment with nginx (docker-compose.yml)"
fi

# Build and start services
echo "🔨 Building Docker images..."
docker compose -f $COMPOSE_FILE build --no-cache

echo "🆙 Starting services..."
docker compose -f $COMPOSE_FILE up -d

# Wait for application to be ready
echo "⏳ Waiting for application to start..."
sleep 30

# Check if services are running
echo "🔍 Checking service status..."
docker compose -f $COMPOSE_FILE ps

# Test if Strapi is responding
echo "🧪 Testing application health..."
if curl -f http://localhost:1337/_health > /dev/null 2>&1; then
    echo "✅ Application is healthy!"
else
    echo "⚠️  Application might still be starting up..."
fi

# Show logs
echo "📝 Showing recent logs..."
docker compose -f $COMPOSE_FILE logs --tail=50

echo "✅ Deployment completed!"
echo ""
echo "🌐 Your Strapi application should be available at:"
echo "   - Application: http://localhost:1337"
echo "   - Admin Panel: http://localhost:1337/admin"
echo "   - API: http://localhost:1337/api"
echo ""
echo "📊 To view logs: docker compose -f $COMPOSE_FILE logs -f"
echo "🛑 To stop: docker compose -f $COMPOSE_FILE down"
echo "🔄 To restart: docker compose -f $COMPOSE_FILE restart"
echo ""
echo "📁 Data is stored in:"
echo "   - Database: $(realpath ../database)/"
echo "   - Uploads: $(realpath ../uploads)/"
echo "   - Data uploads: $(realpath ../data/uploads)/"
