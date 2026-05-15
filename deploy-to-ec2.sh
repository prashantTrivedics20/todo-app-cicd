#!/bin/bash

# Manual deployment script for AWS EC2
# Usage: ./deploy-to-ec2.sh

set -e

EC2_HOST="15.206.93.46"
EC2_USER="ubuntu"
DOCKER_REGISTRY="prashanttrivedi7991"

echo "🚀 Deploying Todo App to AWS EC2..."
echo "Host: $EC2_HOST"
echo "Registry: $DOCKER_REGISTRY"

# Check if SSH key exists
if [ ! -f "~/.ssh/your-ec2-key.pem" ]; then
    echo "⚠️  Please ensure your EC2 private key is available"
    echo "   You can use: ssh -i your-key.pem ubuntu@15.206.93.46"
fi

# Copy files to EC2
echo "📁 Copying deployment files..."
scp -o StrictHostKeyChecking=no docker-compose.prod.yml scripts/deploy.sh $EC2_USER@$EC2_HOST:/home/$EC2_USER/

# Execute deployment
echo "🚀 Executing deployment on EC2..."
ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << 'EOF'
    # Install Docker if not installed
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker ubuntu
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
    
    # Install Docker Compose if not installed
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    # Make deploy script executable and run it
    chmod +x deploy.sh
    ./deploy.sh prashanttrivedi7991 latest
EOF

echo "✅ Deployment completed!"
echo "🌐 Your application should be available at:"
echo "   Frontend: http://15.206.93.46:3000"
echo "   Backend: http://15.206.93.46:5000"
echo "   Health Check: http://15.206.93.46:5000/health"