#!/bin/bash

# Simple Manual Deployment Script
# Run this on your local machine

EC2_HOST="15.206.93.46"
EC2_USER="ubuntu"
KEY_FILE="your-key.pem"  # Update this path

echo "🚀 Starting manual deployment to EC2..."

# Copy files to EC2
echo "📁 Copying files to EC2..."
scp -i $KEY_FILE -r . $EC2_USER@$EC2_HOST:/home/$EC2_USER/todo-app/

# Deploy on EC2
echo "🔧 Setting up and deploying on EC2..."
ssh -i $KEY_FILE $EC2_USER@$EC2_HOST << 'EOF'
cd ~/todo-app

# Install Docker if needed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ubuntu
fi

# Install Docker Compose if needed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Setup environment files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# Stop existing containers
docker-compose -f docker-compose.dev.yml down || true

# Start new containers
echo "🐳 Starting containers..."
docker-compose -f docker-compose.dev.yml up --build -d

# Wait and check
sleep 30
echo "📊 Container status:"
docker ps

echo "✅ Deployment completed!"
echo "🌐 Access your app at: http://15.206.93.46:3000"
EOF

echo "🎉 Manual deployment finished!"