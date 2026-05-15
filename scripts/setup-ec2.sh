#!/bin/bash

# EC2 Instance Setup Script
# Run this script on a fresh EC2 instance to prepare it for deployment

set -e

echo "🔧 Setting up EC2 instance for Todo App deployment..."

# Update system
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo "🐙 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
echo "👤 Adding user to docker group..."
sudo usermod -aG docker $USER

# Install additional tools
echo "🛠️ Installing additional tools..."
sudo apt-get install -y htop curl wget unzip jq

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 5000/tcp
sudo ufw --force enable

# Create application directories
echo "📁 Creating application directories..."
mkdir -p ~/todo-app
mkdir -p ~/backups
mkdir -p ~/logs

# Install AWS CLI (optional)
echo "☁️ Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Configure log rotation
echo "📝 Configuring log rotation..."
sudo tee /etc/logrotate.d/docker-containers << EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
EOF

# Create systemd service for automatic startup
echo "🔄 Creating systemd service..."
sudo tee /etc/systemd/system/todo-app.service << EOF
[Unit]
Description=Todo App
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/$USER/todo-app
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0
User=$USER

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable todo-app.service

# Configure monitoring (optional)
echo "📊 Setting up basic monitoring..."
sudo tee /usr/local/bin/system-monitor.sh << 'EOF'
#!/bin/bash
LOG_FILE="/home/$USER/logs/system-monitor.log"
echo "$(date): System Status" >> $LOG_FILE
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')" >> $LOG_FILE
echo "Memory Usage: $(free | grep Mem | awk '{printf("%.2f%%", $3/$2 * 100.0)}')" >> $LOG_FILE
echo "Disk Usage: $(df -h / | awk 'NR==2{printf "%s", $5}')" >> $LOG_FILE
echo "Docker Containers: $(docker ps --format 'table {{.Names}}\t{{.Status}}' | tail -n +2)" >> $LOG_FILE
echo "---" >> $LOG_FILE
EOF

sudo chmod +x /usr/local/bin/system-monitor.sh

# Add cron job for monitoring
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/system-monitor.sh") | crontab -

# Create health check script
tee ~/health-check.sh << 'EOF'
#!/bin/bash
echo "🏥 Todo App Health Check"
echo "========================"

# Check Docker
if systemctl is-active --quiet docker; then
    echo "✅ Docker is running"
else
    echo "❌ Docker is not running"
fi

# Check containers
echo "📦 Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check application endpoints
echo "🌐 Application Health:"
if curl -f http://localhost:5000/health > /dev/null 2>&1; then
    echo "✅ Backend API is healthy"
else
    echo "❌ Backend API is not responding"
fi

if curl -f http://localhost:80 > /dev/null 2>&1; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend is not responding"
fi

# System resources
echo "💻 System Resources:"
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')%"
echo "Memory: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
echo "Disk: $(df -h / | awk 'NR==2{printf "%s", $5}')"
EOF

chmod +x ~/health-check.sh

echo "✅ EC2 setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Log out and log back in to apply docker group membership"
echo "2. Configure your CI/CD secrets with this instance details"
echo "3. Run your first deployment"
echo ""
echo "🔧 Useful commands:"
echo "  ~/health-check.sh          - Check application health"
echo "  docker-compose logs -f     - View application logs"
echo "  sudo systemctl status todo-app - Check service status"
echo ""
echo "🌐 Your instance public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"