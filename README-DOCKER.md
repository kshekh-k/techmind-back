# TechMind Strapi Backend - Docker Deployment Guide

This repository contains a Strapi application configured for Docker deployment with SQLite database.

## 📋 Prerequisites

- Docker (version 24.0 or higher)
- Docker Compose V2 (version 2.20 or higher) - comes with modern Docker installations
- Git
- Node.js 20+ (for local development)

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd techmind-back
```

> **Note**: This project uses Node.js 20+ and Docker Compose V2 (modern syntax with `docker compose` instead of `docker-compose`)

### 2. Environment Configuration

Copy the environment file and configure it:

```bash
# For production
cp .env.production.example .env.production

# Edit the production environment file
nano .env.production
```

**Important**: Update the following values in `.env.production`:
- `APP_KEYS`: Generate 4 random keys (use tools like `openssl rand -base64 32`)
- `API_TOKEN_SALT`: Generate random salt
- `ADMIN_JWT_SECRET`: Generate random secret
- `JWT_SECRET`: Generate random secret
- `TRANSFER_TOKEN_SALT`: Generate random salt
- `ENCRYPTION_KEY`: Generate random encryption key

### 3. Deploy

Make the deployment script executable and run it:

```bash
chmod +x deploy.sh
./deploy.sh
```

The script will ask if you want to use simple deployment (recommended for existing nginx setups).

## 🐳 Docker Deployment Options

### Option 1: Simple Deployment (Recommended)

Use this if you already have nginx running on your server:

```bash
docker compose -f docker-compose.simple.yml up -d
```

This will:
- Start Strapi on port 1337
- Use SQLite database
- Store data in local directories
- No nginx container (use your existing nginx)

### Option 2: Full Deployment with Nginx

Use this for a complete setup with nginx included:

```bash
docker compose up -d
```

### Option 3: Development Mode

For development with hot reloading:

```bash
docker compose -f docker-compose.dev.yml up -d
```

## 🌐 Nginx Configuration

If you're using your existing nginx server, add this configuration to your nginx setup:

### Add to your nginx.conf or create a new site config:

```nginx
# Include the configuration from nginx/nginx.conf
include /path/to/your/project/nginx/nginx.conf;
```

### Update the nginx configuration:

1. Edit `nginx/nginx.conf`
2. Replace `your-domain.com` with your actual domain
3. Update the uploads path: `/path/to/your/strapi/uploads/`
4. Reload nginx: `sudo nginx -s reload`

## 📁 Directory Structure

```
techmind-back/
├── docker-compose.yml              # Full deployment with nginx
├── docker-compose.simple.yml       # Simple deployment (no nginx)
├── docker-compose.dev.yml          # Development deployment
├── Dockerfile                      # Production Docker image
├── Dockerfile.dev                  # Development Docker image
├── deploy.sh                       # Deployment script
├── .env.production.example         # Production environment template
├── nginx/
│   └── nginx.conf                  # Nginx configuration
├── uploads/                        # Upload files (created automatically)
├── data/                          # Data uploads (created automatically)
└── database/                      # SQLite database (created automatically)
```

## 🔧 Environment Variables

### Required Variables (Production)

```bash
NODE_ENV=production
HOST=0.0.0.0
PORT=1337

# Generate these securely for production
APP_KEYS=key1,key2,key3,key4
API_TOKEN_SALT=your-salt
ADMIN_JWT_SECRET=your-secret
JWT_SECRET=your-jwt-secret
TRANSFER_TOKEN_SALT=your-transfer-salt
ENCRYPTION_KEY=your-encryption-key

# Database (SQLite)
DATABASE_CLIENT=sqlite
DATABASE_FILENAME=.tmp/data.db
```

### Optional Variables

```bash
# AWS S3 for file uploads
AWS_ACCESS_KEY_ID=your-key
AWS_ACCESS_SECRET=your-secret
AWS_REGION=us-east-1
AWS_BUCKET=your-bucket

# Email configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-password

# Security
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Logging
STRAPI_LOG_LEVEL=info
```

## 🛠 Management Commands

### Start the application

```bash
# Simple deployment
docker compose -f docker-compose.simple.yml up -d

# Full deployment
docker compose up -d

# Development
docker compose -f docker-compose.dev.yml up -d
```

### Stop the application

```bash
docker compose down
```

### View logs

```bash
# All logs
docker compose logs -f

# Strapi logs only
docker compose logs -f strapi
```

### Restart services

```bash
docker compose restart
```

### Rebuild and restart

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## 📊 Monitoring and Health Checks

### Health Check Endpoint

The application provides a health check endpoint:

```bash
curl http://localhost:1337/_health
```

### Container Status

Check if containers are running:

```bash
docker compose ps
```

### Resource Usage

Monitor resource usage:

```bash
docker stats
```

## 💾 Data Management

### Backup

Your data is stored in local directories:

```bash
# Backup script
tar -czf backup-$(date +%Y%m%d).tar.gz uploads/ data/ database/
```

### Restore

```bash
# Stop the application
docker compose down

# Restore from backup
tar -xzf backup-YYYYMMDD.tar.gz

# Start the application
docker compose up -d
```

### Database Location

SQLite database is stored in: `./database/data.db`

## 🔒 Security Considerations

1. **Environment Variables**: Never commit `.env.production` to version control
2. **Secrets**: Generate strong, unique secrets for production
3. **File Permissions**: Ensure proper permissions on data directories
4. **Nginx**: Use SSL/TLS in production
5. **Updates**: Regularly update Docker images and dependencies

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**:
   ```bash
   # Check what's using port 1337
   sudo lsof -i :1337
   
   # Kill the process or change the port in docker-compose.yml
   ```

2. **Permission denied errors**:
   ```bash
   # Fix permissions
   sudo chmod -R 755 uploads/ data/ database/
   sudo chown -R $USER:$USER uploads/ data/ database/
   ```

3. **Database connection issues**:
   ```bash
   # Check if SQLite file exists and is writable
   ls -la database/
   ```

4. **Application not starting**:
   ```bash
   # Check logs
   docker-compose logs strapi
   
   # Check environment variables
   docker-compose exec strapi env
   ```

### Logs and Debugging

```bash
# View all logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# View specific service logs
docker compose logs strapi

# Enter container for debugging
docker compose exec strapi sh
```

## 📈 Scaling and Performance

### For high-traffic scenarios:

1. **Use PostgreSQL**: Switch from SQLite to PostgreSQL for better performance
2. **File Storage**: Use S3 or similar for file uploads
3. **Load Balancing**: Use multiple Strapi instances behind a load balancer
4. **Caching**: Implement Redis caching
5. **CDN**: Use a CDN for static assets

## 📞 Support

- **Strapi Documentation**: https://docs.strapi.io/
- **Docker Documentation**: https://docs.docker.com/
- **Project Issues**: Create an issue in this repository

## 📝 License

[Your License Here]

---

**Note**: This setup uses SQLite which is perfect for small to medium applications. For larger applications, consider switching to PostgreSQL by modifying the docker-compose files and environment variables.
