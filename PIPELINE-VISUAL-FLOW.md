# Visual CI/CD Pipeline Flow

## 🔄 Complete Pipeline Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DEVELOPER WORKFLOW                                    │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────┐    git push    ┌─────────────────┐
│   Developer     │───────────────▶│   GitHub        │
│   Local Code    │                │   Repository    │
│   - Frontend    │                │   - Stores Code │
│   - Backend     │                │   - Triggers CI │
│   - Config      │                └─────────────────┘
└─────────────────┘                         │
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        GITHUB ACTIONS CI/CD PIPELINE                           │
│                                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │
│  │    TEST     │  │  SECURITY   │  │    BUILD    │  │   DEPLOY    │           │
│  │   PHASE     │  │    SCAN     │  │   IMAGES    │  │   TO EC2    │           │
│  │             │  │             │  │             │  │             │           │
│  │ • Backend   │  │ • Trivy     │  │ • Backend   │  │ • Copy      │           │
│  │   Tests     │  │   Scanner   │  │   Docker    │  │   Files     │           │
│  │ • Frontend  │  │ • Vuln      │  │ • Frontend  │  │ • Execute   │           │
│  │   Tests     │  │   Check     │  │   Docker    │  │   Script    │           │
│  │             │  │             │  │ • Push to   │  │ • Health    │           │
│  │             │  │             │  │   Hub       │  │   Checks    │           │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │
│         │                │                │                │                   │
│         ▼                ▼                ▼                ▼                   │
└─────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DOCKER HUB REGISTRY                                  │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  prashanttrivedi7991/todo-backend:latest                                │   │
│  │  prashanttrivedi7991/todo-frontend:latest                               │   │
│  │                                                                         │   │
│  │  • Stores built Docker images                                           │   │
│  │  • Versioned with git commit SHA                                        │   │
│  │  • Publicly accessible                                                  │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         AWS EC2 PRODUCTION SERVER                              │
│                              15.206.93.46                                      │
│                                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   FRONTEND      │  │    BACKEND      │  │    DATABASE     │                │
│  │   Container     │  │   Container     │  │   Container     │                │
│  │                 │  │                 │  │                 │                │
│  │ • Nginx Server  │  │ • Node.js API   │  │ • MongoDB       │                │
│  │ • React App     │  │ • Express       │  │ • Data Storage  │                │
│  │ • Port 3000     │  │ • Port 5000     │  │ • Port 27017    │                │
│  │                 │  │                 │  │                 │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
│           │                     │                     │                        │
│           └─────────────────────┼─────────────────────┘                        │
│                                 │                                              │
│                    ┌─────────────────┐                                         │
│                    │ Docker Network  │                                         │
│                    │ todo-network    │                                         │
│                    └─────────────────┘                                         │
└─────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              END USERS                                         │
│                                                                                 │
│  ┌─────────────────┐                    ┌─────────────────┐                   │
│  │   Web Browser   │                    │   API Clients   │                   │
│  │                 │                    │                 │                   │
│  │ • Frontend UI   │                    │ • Mobile Apps   │                   │
│  │ • Port 3000     │                    │ • Port 5000     │                   │
│  │                 │                    │                 │                   │
│  └─────────────────┘                    └─────────────────┘                   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🔍 Detailed Step-by-Step Flow

### 1. Code Push Event
```
Developer → git push → GitHub Repository
                    ↓
              Webhook Trigger
                    ↓
            GitHub Actions Runner
```

### 2. CI/CD Pipeline Execution
```
GitHub Actions Runner (Ubuntu VM)
├── Step 1: Checkout Code
├── Step 2: Setup Node.js Environment
├── Step 3: Install Dependencies
├── Step 4: Run Tests (Backend & Frontend)
├── Step 5: Security Vulnerability Scan
├── Step 6: Build Docker Images
│   ├── Backend: node:18-alpine + app code
│   └── Frontend: nginx:alpine + React build
├── Step 7: Push Images to Docker Hub
└── Step 8: Deploy to AWS EC2
```

### 3. Docker Image Build Process
```
Backend Dockerfile:
┌─────────────────┐
│ node:18-alpine  │ ← Base image
├─────────────────┤
│ npm install     │ ← Install dependencies
├─────────────────┤
│ Copy app code   │ ← Add application
├─────────────────┤
│ EXPOSE 5000     │ ← Open port
└─────────────────┘

Frontend Dockerfile:
┌─────────────────┐
│ node:18-alpine  │ ← Build stage
├─────────────────┤
│ npm install     │ ← Install all deps
├─────────────────┤
│ npm run build   │ ← Build React app
├─────────────────┤
│ nginx:alpine    │ ← Production stage
├─────────────────┤
│ Copy build/     │ ← Static files only
└─────────────────┘
```

### 4. Deployment Process on EC2
```
EC2 Server (15.206.93.46)
├── 1. Receive deployment files via SCP
├── 2. Pull latest Docker images
├── 3. Backup existing database
├── 4. Stop old containers
├── 5. Start new containers with docker-compose
├── 6. Wait for services to be ready
├── 7. Run health checks
└── 8. Report deployment status
```

### 5. Container Communication
```
Internet → EC2:3000 (Frontend) → Docker Network → Backend:5000 → MongoDB:27017
    ↓
User sees React app
    ↓
Makes API calls
    ↓
Backend processes
    ↓
Database operations
```

## 🎯 Key Technologies Explained

### GitHub Actions
- **Purpose**: Automation platform
- **Triggers**: Code push, PR, schedule
- **Runners**: Virtual machines (Ubuntu, Windows, macOS)
- **Workflows**: YAML files defining automation steps

### Docker
- **Images**: Read-only templates for containers
- **Containers**: Running instances of images
- **Volumes**: Persistent data storage
- **Networks**: Container communication

### Docker Compose
- **Purpose**: Multi-container application orchestration
- **Services**: Individual containers (frontend, backend, database)
- **Networks**: Internal communication between containers
- **Volumes**: Shared and persistent storage

### AWS EC2
- **Purpose**: Virtual server in the cloud
- **Instance**: t2.micro (1 vCPU, 1GB RAM)
- **Security Groups**: Firewall rules
- **Key Pairs**: SSH authentication

## 🔧 Configuration Files Explained

### `.github/workflows/ci-cd.yml`
```yaml
name: CI/CD Pipeline           # Workflow name
on:                           # Trigger conditions
  push:
    branches: [ main ]        # Run on push to main
jobs:                         # Individual tasks
  test-backend:               # Job name
    runs-on: ubuntu-latest    # Runner environment
    steps:                    # Individual commands
    - uses: actions/checkout@v4  # Pre-built action
    - run: npm install        # Custom command
```

### `docker-compose.prod.yml`
```yaml
services:                     # Define containers
  mongodb:                    # Service name
    image: mongo:7.0          # Docker image to use
    ports:                    # Port mapping
      - "27017:27017"         # host:container
    volumes:                  # Data persistence
      - mongodb_data:/data/db # volume:container_path
    networks:                 # Network connection
      - todo-network          # Custom network name
```

### `Dockerfile` (Backend)
```dockerfile
FROM node:18-alpine          # Base image
WORKDIR /app                 # Working directory
COPY package*.json ./        # Copy dependency files
RUN npm install              # Install dependencies
COPY . .                     # Copy application code
EXPOSE 5000                  # Document port usage
CMD ["npm", "start"]         # Default command
```

This comprehensive flow shows exactly how your code goes from your local machine to a live, running application accessible to users worldwide! 🚀