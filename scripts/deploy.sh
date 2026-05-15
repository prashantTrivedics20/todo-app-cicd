#!/bin/bash

# AWS EC2 Deployment Script
# Usage: ./deploy.sh [DOCKER_REGISTRY] [IMAGE_TAG]

set -e

DOCKER_REGISTRY=${1:-"your-registry"}
IMAGE_TAG=${2:-"latest"}
APP_DIR="/home/$(whoami)/todo-app"
BACKUP_DIR="/home/$(whoami)/backups"

echo "🚀 Starting deployment..."
echo "Registry: $DOCKER_REGISTRY"
echo "Image Tag: $IMAGE_TAG"

# Create directories
mkdir -p $APP_DIR
mkdir -p $BACKUP_DIR

# Navigate to app directory
cd $APP_DIR

# Create environment file
cat > .env << EOF
DOCKER_REGISTRY=$DOCKER_REGISTRY
IMAGE_TAG=$IMAGE_TAG
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=password123
FRONTEND_URL=http://15.206.93.46:3000
EOF

echo "📦 Pulling latest images..."
docker pull $DOCKER_REGISTRY/todo-backend:$IMAGE_TAG
docker pull $DOCKER_REGISTRY/todo-frontend:$IMAGE_TAG

# Backup current database if exists
if docker ps -q -f name=todo-mongodb-prod > /dev/null; then
    echo "💾 Creating database backup..."
    BACKUP_FILE="$BACKUP_DIR/mongodb-backup-$(date +%Y%m%d-%H%M%S).gz"
    docker exec todo-mongodb-prod mongodump --authenticationDatabase admin \
        -u admin -p $(grep MONGO_ROOT_PASSWORD .env | cut -d'=' -f2) \
        --archive | gzip > $BACKUP_FILE
    echo "Backup created: $BACKUP_FILE"
fi

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down --remove-orphans || true

# Clean up any dangling containers
docker container prune -f || true

# Remove old images (keep last 3)
echo "🧹 Cleaning up old images..."
docker images $DOCKER_REGISTRY/todo-backend --format "table {{.Tag}}\t{{.ID}}" | \
    tail -n +4 | awk '{print $2}' | xargs -r docker rmi || true
docker images $DOCKER_REGISTRY/todo-frontend --format "table {{.Tag}}\t{{.ID}}" | \
    tail -n +4 | awk '{print $2}' | xargs -r docker rmi || true

# Start new containers
echo "🚀 Starting new containers..."
echo "Current directory: $(pwd)"
echo "Files in directory:"
ls -la

# Check if docker-compose.prod.yml exists
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ docker-compose.prod.yml not found!"
    exit 1
fi

# Show the environment file
echo "Environment variables:"
cat .env

# Start containers with verbose output
docker-compose -f docker-compose.prod.yml up -d --remove-orphans

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Health checks
echo "🏥 Running health checks..."

# Check backend health
for i in {1..10}; do
    if curl -f http://localhost:5000/health > /dev/null 2>&1; then
        echo "✅ Backend is healthy"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ Backend health check failed"
        exit 1
    fi
    sleep 5
done

# Check frontend
for i in {1..10}; do
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        echo "✅ Frontend is healthy"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ Frontend health check failed"
        exit 1
    fi
    sleep 5
done

# Show container status
echo "📊 Container status:"
docker-compose -f docker-compose.prod.yml ps

# Show logs for debugging
echo "📝 Recent logs:"
docker-compose -f docker-compose.prod.yml logs --tail=20

# Cleanup old backups (keep last 7 days)
find $BACKUP_DIR -name "mongodb-backup-*.gz" -mtime +7 -delete || true

echo "✅ Deployment completed successfully!"
echo "🌐 Application is available at:"
echo "   Frontend: http://15.206.93.46:3000"
echo "   Backend API: http://15.206.93.46:5000"