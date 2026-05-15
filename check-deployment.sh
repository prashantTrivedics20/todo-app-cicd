#!/bin/bash

# Quick deployment status check script
EC2_HOST="15.206.93.46"
EC2_USER="ubuntu"

echo "🔍 Checking deployment status on $EC2_HOST..."

# Check if we can SSH to the server
if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST "echo 'SSH connection successful'" 2>/dev/null; then
    echo "❌ Cannot SSH to EC2 server"
    exit 1
fi

echo "✅ SSH connection successful"

# Check container status
echo "📊 Container Status:"
ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

# Check if services are responding
echo ""
echo "🏥 Health Checks:"

# Backend health check
echo -n "Backend (port 5000): "
if curl -f -s http://$EC2_HOST:5000/health > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Not responding"
fi

# Frontend check
echo -n "Frontend (port 3000): "
if curl -f -s http://$EC2_HOST:3000 > /dev/null 2>&1; then
    echo "✅ Accessible"
else
    echo "❌ Not accessible"
fi

# Check if ports are open
echo ""
echo "🔌 Port Status:"
echo -n "Port 5000: "
if nc -z -w5 $EC2_HOST 5000 2>/dev/null; then
    echo "✅ Open"
else
    echo "❌ Closed"
fi

echo -n "Port 3000: "
if nc -z -w5 $EC2_HOST 3000 2>/dev/null; then
    echo "✅ Open"
else
    echo "❌ Closed"
fi

# Show recent logs
echo ""
echo "📝 Recent Container Logs:"
ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST "cd /home/ubuntu/todo-app && docker-compose -f docker-compose.prod.yml -p todo-app logs --tail=10"

echo ""
echo "🌐 Application URLs:"
echo "   Frontend: http://$EC2_HOST:3000"
echo "   Backend API: http://$EC2_HOST:5000"
echo "   Backend Health: http://$EC2_HOST:5000/health"