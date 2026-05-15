#!/bin/bash

# Quick deployment script for EC2
echo "🚀 Quick deployment starting..."

# Clean up space first
echo "🧹 Cleaning up disk space..."
sudo docker system prune -a -f || true
sudo apt clean
sudo apt autoremove -y

# Install Node.js if not installed
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install PM2 for process management
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    sudo npm install -g pm2
fi

# Setup backend
echo "🔧 Setting up backend..."
cd ~/todo-app-cicd/backend
npm install --production

# Create simple .env
cat > .env << EOF
PORT=5000
NODE_ENV=production
MONGODB_URI=mongodb://localhost:27017/todoapp
FRONTEND_URL=http://15.206.93.46:3000
EOF

# Start backend with PM2
pm2 stop backend || true
pm2 start server.js --name backend

# Setup frontend (build locally)
echo "🔧 Setting up frontend..."
cd ~/todo-app-cicd/frontend
npm install --production

# Create .env
cat > .env << EOF
REACT_APP_API_URL=http://15.206.93.46:5000/api
EOF

# Build frontend
npm run build

# Serve frontend with PM2
pm2 stop frontend || true
pm2 serve build 3000 --name frontend --spa

# Install and start MongoDB
echo "🗄️ Setting up MongoDB..."
if ! command -v mongod &> /dev/null; then
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org
fi

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Show status
echo "📊 Application Status:"
pm2 status
sudo systemctl status mongod --no-pager

echo "✅ Deployment completed!"
echo "🌐 Frontend: http://15.206.93.46:3000"
echo "🔗 Backend: http://15.206.93.46:5000/health"