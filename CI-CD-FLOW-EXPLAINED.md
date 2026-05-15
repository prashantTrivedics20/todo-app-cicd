# Complete CI/CD Flow Explanation

## 🎯 Overview
This document explains how our Todo App CI/CD pipeline works from code push to live deployment.

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Code Structure](#code-structure)
3. [CI/CD Pipeline Flow](#cicd-pipeline-flow)
4. [Docker Containerization](#docker-containerization)
5. [Deployment Process](#deployment-process)
6. [Monitoring & Health Checks](#monitoring--health-checks)
7. [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   GitHub        │    │   Docker Hub    │
│   Local Code    │───▶│   Repository    │───▶│   Image Store   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        │
                       ┌─────────────────┐             │
                       │  GitHub Actions │             │
                       │  CI/CD Pipeline │             │
                       └─────────────────┘             │
                              │                        │
                              ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   AWS EC2       │◀───│  Pull Images    │
                       │   Production    │    │  & Deploy       │
                       └─────────────────┘    └─────────────────┘
```

## 📁 Code Structure

```
todo-app-cicd/
├── .github/workflows/
│   └── ci-cd.yml                 # Main CI/CD pipeline
├── backend/                      # Node.js API
│   ├── models/Todo.js           # MongoDB data model
│   ├── routes/todos.js          # API endpoints
│   ├── server.js                # Express server
│   ├── healthcheck.js           # Health check script
│   ├── package.json             # Dependencies
│   └── Dockerfile               # Backend container config
├── frontend/                     # React App
│   ├── src/                     # React components
│   ├── public/                  # Static files
│   ├── package.json             # Dependencies
│   ├── nginx.conf               # Web server config
│   └── Dockerfile               # Frontend container config
├── scripts/
│   └── deploy.sh                # Deployment script
├── docker-compose.prod.yml      # Production container orchestration
└── docker-compose.dev.yml       # Development setup
```

---

## 🔄 CI/CD Pipeline Flow

### Step 1: Code Push Trigger
```yaml
on:
  push:
    branches: [ main, develop ]  # Triggers on push to these branches
  pull_request:
    branches: [ main ]           # Triggers on PR to main
```

**What happens:**
- Developer pushes code to GitHub
- GitHub detects the push event
- Triggers the CI/CD workflow automatically

### Step 2: Test Phase
```yaml
jobs:
  test-backend:
    runs-on: ubuntu-latest       # Runs on GitHub's servers
    steps:
    - name: Checkout code        # Downloads your code
    - name: Setup Node.js        # Installs Node.js
    - name: Install dependencies # npm install
    - name: Run tests           # npm test (currently skipped)
```

**What happens internally:**
1. GitHub spins up a fresh Ubuntu virtual machine
2. Downloads your repository code
3. Installs Node.js and dependencies
4. Runs tests to ensure code quality

### Step 3: Security Scanning
```yaml
security-scan:
  runs-on: ubuntu-latest
  steps:
  - name: Run Trivy vulnerability scanner  # Scans for security issues
```

**What happens:**
- Scans code for known vulnerabilities
- Checks dependencies for security issues
- Continues even if issues found (non-blocking)

### Step 4: Build Docker Images
```yaml
build-images:
  needs: [test-backend, test-frontend]  # Waits for tests to pass
  if: github.ref == 'refs/heads/main'   # Only on main branch
```

**What happens:**
1. **Backend Build:**
   ```bash
   cd backend
   docker build -t prashanttrivedi7991/todo-backend:latest .
   docker push prashanttrivedi7991/todo-backend:latest
   ```

2. **Frontend Build:**
   ```bash
   cd frontend
   docker build -t prashanttrivedi7991/todo-frontend:latest .
   docker push prashanttrivedi7991/todo-frontend:latest
   ```

### Step 5: Deploy to AWS EC2
```yaml
deploy:
  needs: [build-images]         # Waits for images to be built
  environment: production       # Uses production secrets
```

**What happens:**
1. Copies deployment files to EC2
2. Executes deployment script on EC2
3. Runs health checks
4. Notifies completion status

---

## 🐳 Docker Containerization

### Backend Dockerfile Explained
```dockerfile
FROM node:18-alpine              # Base image (lightweight Linux + Node.js)
WORKDIR /app                     # Set working directory inside container
COPY package*.json ./            # Copy dependency files first (for caching)
RUN npm install                  # Install dependencies
COPY . .                         # Copy application code
EXPOSE 5000                      # Tell Docker this app uses port 5000
CMD ["npm", "start"]             # Command to run when container starts
```

**Why this order?**
- Copy package.json first → Docker can cache the npm install step
- If code changes but dependencies don't, Docker reuses cached layers
- Makes builds faster!

### Frontend Dockerfile Explained
```dockerfile
# Build Stage
FROM node:18-alpine as build     # Multi-stage build
WORKDIR /app
COPY package*.json ./
RUN npm install                  # Install ALL dependencies (including dev)
COPY . .
ENV REACT_APP_API_URL=http://15.206.93.46:5000/api  # Set API URL
RUN npm run build               # Build React app for production

# Production Stage
FROM nginx:alpine               # Lightweight web server
RUN apk add --no-cache wget     # Add wget for health checks
COPY --from=build /app/build /usr/share/nginx/html  # Copy built files
COPY nginx.conf /etc/nginx/conf.d/default.conf      # Custom nginx config
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]  # Start web server
```

**Why multi-stage?**
- Build stage: Has all dev tools needed to compile React
- Production stage: Only has the compiled files + web server
- Final image is much smaller and more secure

---

## 🚀 Deployment Process

### 1. File Transfer to EC2
```bash
scp -i ec2_key.pem docker-compose.prod.yml ubuntu@15.206.93.46:/home/ubuntu/todo-app/
scp -i ec2_key.pem scripts/deploy.sh ubuntu@15.206.93.46:/home/ubuntu/todo-app/
```

### 2. Deployment Script Execution
The `deploy.sh` script runs on EC2 and does:

```bash
# 1. Create environment variables
cat > .env << EOF
DOCKER_REGISTRY=prashanttrivedi7991
IMAGE_TAG=latest
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=password123
FRONTEND_URL=http://15.206.93.46:3000
EOF

# 2. Pull latest images from Docker Hub
docker pull prashanttrivedi7991/todo-backend:latest
docker pull prashanttrivedi7991/todo-frontend:latest

# 3. Backup existing database
docker exec todo-mongodb-prod mongodump --archive | gzip > backup.gz

# 4. Stop old containers
docker stop $(docker ps -q --filter "name=todo-")
docker rm $(docker ps -aq --filter "name=todo-")

# 5. Start new containers
docker-compose -f docker-compose.prod.yml -p todo-app up -d

# 6. Health checks
curl http://localhost:5000/health  # Backend
wget http://localhost:3000         # Frontend
```

### 3. Container Orchestration
`docker-compose.prod.yml` defines how containers work together:

```yaml
services:
  mongodb:
    image: mongo:7.0
    ports: ["27017:27017"]        # Database port
    volumes: [mongodb_data:/data/db]  # Persistent storage
    
  backend:
    image: prashanttrivedi7991/todo-backend:latest
    ports: ["5000:5000"]          # API port
    depends_on: [mongodb]         # Wait for database
    environment:
      MONGODB_URI: mongodb://admin:password123@mongodb:27017/todoapp
      
  frontend:
    image: prashanttrivedi7991/todo-frontend:latest
    ports: ["3000:80"]            # Web server port
    depends_on: [backend]         # Wait for API
```

**Container Communication:**
- Frontend (port 3000) → Backend (port 5000) → MongoDB (port 27017)
- All containers share a Docker network
- Can communicate using service names (e.g., `http://backend:5000`)

---

## 🏥 Monitoring & Health Checks

### 1. Application Health Checks
```javascript
// backend/healthcheck.js
const http = require('http');
const options = {
  hostname: 'localhost',
  port: 5000,
  path: '/health',
  method: 'GET'
};

// Makes HTTP request to own health endpoint
// Exits with code 0 (success) or 1 (failure)
```

### 2. Docker Health Checks
```yaml
healthcheck:
  test: ["CMD", "node", "healthcheck.js"]  # Run health check script
  interval: 30s                           # Check every 30 seconds
  timeout: 10s                            # Timeout after 10 seconds
  retries: 3                              # Try 3 times before marking unhealthy
```

### 3. Deployment Health Checks
```bash
# Backend check
for i in {1..10}; do
  if curl -f http://localhost:5000/health; then
    echo "✅ Backend is healthy"
    break
  fi
  sleep 5
done

# Frontend check
for i in {1..10}; do
  if wget --spider http://localhost:3000; then
    echo "✅ Frontend is healthy"
    break
  fi
  sleep 5
done
```

---

## 🔧 How Each Component Works

### 1. GitHub Actions Runner
- **What:** Virtual machine provided by GitHub
- **When:** Triggered by code push/PR
- **Where:** GitHub's cloud infrastructure
- **Resources:** 2 CPU cores, 7GB RAM, 14GB SSD

### 2. Docker Hub
- **What:** Cloud registry for Docker images
- **Purpose:** Store and distribute container images
- **Access:** Public repository `prashanttrivedi7991/todo-backend`

### 3. AWS EC2 Instance
- **What:** Virtual server in Amazon's cloud
- **IP:** 15.206.93.46
- **OS:** Ubuntu Linux
- **Purpose:** Production environment

### 4. Docker Engine
- **What:** Container runtime on EC2
- **Purpose:** Run and manage containers
- **Network:** Creates isolated network for containers

### 5. MongoDB Container
- **What:** Database running in container
- **Data:** Stored in Docker volume (persistent)
- **Access:** Only accessible from other containers

---

## 🔍 Data Flow

### 1. User Request Flow
```
User Browser → EC2:3000 (Frontend) → EC2:5000 (Backend) → EC2:27017 (MongoDB)
```

### 2. API Request Example
```javascript
// Frontend makes API call
fetch('http://15.206.93.46:5000/api/todos')

// Nginx proxy forwards to backend
location /api {
  proxy_pass http://backend:5000;  // Internal Docker network
}

// Backend processes request
app.get('/api/todos', async (req, res) => {
  const todos = await Todo.find();  // Query MongoDB
  res.json(todos);
});
```

### 3. Database Connection
```javascript
// Backend connects to MongoDB
mongoose.connect('mongodb://admin:password123@mongodb:27017/todoapp')

// 'mongodb' resolves to MongoDB container IP
// Docker handles internal DNS resolution
```

---

## 🛠️ Troubleshooting Guide

### Common Issues & Solutions

1. **Build Fails**
   ```bash
   # Check logs in GitHub Actions
   # Look for npm install errors
   # Verify Dockerfile syntax
   ```

2. **Deployment Fails**
   ```bash
   # SSH to EC2
   ssh -i your-key.pem ubuntu@15.206.93.46
   
   # Check container status
   docker ps -a
   
   # Check logs
   docker logs todo-backend-prod
   docker logs todo-frontend-prod
   ```

3. **Health Check Fails**
   ```bash
   # Test endpoints manually
   curl http://localhost:5000/health
   curl http://localhost:3000
   
   # Check if ports are open
   netstat -tlnp | grep :5000
   netstat -tlnp | grep :3000
   ```

4. **Database Issues**
   ```bash
   # Check MongoDB logs
   docker logs todo-mongodb-prod
   
   # Connect to database
   docker exec -it todo-mongodb-prod mongo
   ```

---

## 🎓 Key Learning Points

### 1. **CI/CD Benefits**
- **Automation:** No manual deployment steps
- **Consistency:** Same process every time
- **Speed:** Fast feedback on code changes
- **Reliability:** Automated testing and health checks

### 2. **Docker Benefits**
- **Consistency:** Same environment everywhere
- **Isolation:** Containers don't interfere with each other
- **Scalability:** Easy to scale up/down
- **Portability:** Runs anywhere Docker runs

### 3. **Infrastructure as Code**
- **Version Control:** Infrastructure defined in files
- **Reproducibility:** Can recreate environment anytime
- **Documentation:** Code serves as documentation

### 4. **Security Best Practices**
- **Secrets Management:** Sensitive data in GitHub Secrets
- **Least Privilege:** Containers run with minimal permissions
- **Network Isolation:** Containers communicate through defined networks
- **Regular Updates:** Automated security scanning

---

## 🚀 Next Steps for Learning

1. **Monitor Your Application**
   - Set up logging with ELK stack
   - Add application metrics
   - Set up alerts for failures

2. **Improve the Pipeline**
   - Add more comprehensive tests
   - Implement blue-green deployments
   - Add staging environment

3. **Scale the Application**
   - Use Docker Swarm or Kubernetes
   - Add load balancing
   - Implement database clustering

4. **Security Enhancements**
   - Add SSL certificates
   - Implement authentication
   - Set up VPC and security groups

This pipeline gives you a solid foundation for modern application deployment! 🎉