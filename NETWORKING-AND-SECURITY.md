# Networking and Security Deep Dive

## 🌐 Network Architecture

### 1. External Network Flow
```
Internet Users
    ↓ (HTTP requests)
AWS Load Balancer (if configured)
    ↓
EC2 Security Group (Firewall)
    ↓ (Port 3000, 5000 allowed)
EC2 Instance (15.206.93.46)
    ↓
Docker Host Network
    ↓
Docker Bridge Network (todo-network)
    ↓
Individual Containers
```

### 2. Internal Container Communication
```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network: todo-network             │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Frontend   │    │   Backend   │    │  MongoDB    │     │
│  │  Container  │    │  Container  │    │  Container  │     │
│  │             │    │             │    │             │     │
│  │ nginx:80    │───▶│ node:5000   │───▶│ mongo:27017 │     │
│  │             │    │             │    │             │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. Port Mapping Explained
```
Host (EC2)          Container           Purpose
─────────────────────────────────────────────────────────
3000        →       80 (nginx)         Frontend web server
5000        →       5000 (node)        Backend API server
27017       →       27017 (mongo)      Database (internal only)
```

## 🔒 Security Layers

### 1. AWS Security Group (Network Firewall)
```yaml
Inbound Rules:
- Port 22 (SSH):    Your IP only        # Remote access
- Port 3000 (HTTP): 0.0.0.0/0          # Frontend access
- Port 5000 (HTTP): 0.0.0.0/0          # API access
- Port 27017:       DENY               # Database blocked

Outbound Rules:
- All traffic:      0.0.0.0/0          # Allow all outbound
```

### 2. Docker Network Isolation
```
┌─────────────────────────────────────────────────────────────┐
│                      Host Network                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Docker Bridge Network                  │   │
│  │                                                     │   │
│  │  Containers can communicate with each other         │   │
│  │  using service names (mongodb, backend, frontend)   │   │
│  │                                                     │   │
│  │  External access only through exposed ports         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 3. Application Security
```javascript
// Backend Security Middleware
app.use(helmet());                    // Security headers
app.use(cors({                       // Cross-origin requests
  origin: process.env.FRONTEND_URL,  // Only allow frontend
  credentials: true
}));
app.use(rateLimit({                  // Rate limiting
  windowMs: 15 * 60 * 1000,         // 15 minutes
  max: 100                          // 100 requests per IP
}));
```

## 🔐 Secrets Management

### 1. GitHub Secrets (Encrypted Storage)
```
Repository Settings → Secrets and Variables → Actions

DOCKER_USERNAME     = prashanttrivedi7991
DOCKER_PASSWORD     = [encrypted token]
EC2_HOST           = 15.206.93.46
EC2_USER           = ubuntu
EC2_PRIVATE_KEY    = [encrypted SSH key]
```

### 2. Environment Variables in Containers
```yaml
# docker-compose.prod.yml
environment:
  NODE_ENV: production
  MONGODB_URI: mongodb://admin:password123@mongodb:27017/todoapp
  FRONTEND_URL: http://15.206.93.46:3000
```

### 3. SSH Key Authentication
```bash
# GitHub Actions uses SSH key to connect to EC2
ssh -i ec2_key.pem ubuntu@15.206.93.46

# Key is stored as GitHub Secret (EC2_PRIVATE_KEY)
# Temporarily written to file during deployment
# Deleted after deployment completes
```

## 🛡️ Security Best Practices Implemented

### 1. Container Security
- **Non-root user**: Containers don't run as root
- **Minimal base images**: Alpine Linux (small attack surface)
- **No secrets in images**: Environment variables used instead
- **Read-only filesystem**: Where possible

### 2. Network Security
- **Firewall rules**: Only necessary ports open
- **Internal communication**: Containers use internal network
- **No direct database access**: MongoDB not exposed externally

### 3. Code Security
- **Vulnerability scanning**: Trivy scans for known issues
- **Dependency updates**: Regular updates to packages
- **Input validation**: API validates all inputs
- **Rate limiting**: Prevents abuse

### 4. Infrastructure Security
- **SSH key authentication**: No password login
- **Encrypted secrets**: GitHub encrypts all secrets
- **Least privilege**: Minimal permissions for all components

## 📊 Monitoring and Logging

### 1. Health Check Endpoints
```javascript
// Backend health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});
```

### 2. Docker Health Checks
```yaml
healthcheck:
  test: ["CMD", "node", "healthcheck.js"]
  interval: 30s      # Check every 30 seconds
  timeout: 10s       # Timeout after 10 seconds
  retries: 3         # Try 3 times before marking unhealthy
```

### 3. Container Logs
```bash
# View logs for specific container
docker logs todo-backend-prod

# Follow logs in real-time
docker logs -f todo-frontend-prod

# View logs with timestamps
docker logs -t todo-mongodb-prod
```

## 🔄 Data Flow Security

### 1. Frontend to Backend
```
User Browser → HTTPS (if SSL configured) → EC2:3000 → nginx → proxy_pass → Backend:5000
```

### 2. Backend to Database
```
Backend Container → Docker Network → MongoDB Container
(Internal network, not exposed to internet)
```

### 3. API Authentication Flow (if implemented)
```
1. User login → Backend validates → JWT token issued
2. Frontend stores token → Includes in API requests
3. Backend validates token → Processes request
4. Database operations → Return response
```

## 🚨 Security Considerations for Production

### Current Setup (Development/Demo)
- ✅ Basic firewall rules
- ✅ Container isolation
- ✅ Secrets management
- ❌ No SSL/HTTPS
- ❌ No authentication
- ❌ Database not encrypted
- ❌ No backup encryption

### Production Recommendations
1. **Add SSL Certificate**
   ```bash
   # Use Let's Encrypt for free SSL
   certbot --nginx -d yourdomain.com
   ```

2. **Implement Authentication**
   ```javascript
   // JWT-based authentication
   const jwt = require('jsonwebtoken');
   const bcrypt = require('bcrypt');
   ```

3. **Database Security**
   ```yaml
   # Enable MongoDB authentication
   environment:
     MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USERNAME}
     MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD}
   ```

4. **Network Security**
   ```yaml
   # Use VPC and private subnets
   # Implement WAF (Web Application Firewall)
   # Add load balancer with SSL termination
   ```

5. **Monitoring and Alerting**
   ```yaml
   # Add CloudWatch monitoring
   # Set up log aggregation (ELK stack)
   # Configure alerts for failures
   ```

This security setup provides a good foundation for a development/demo environment, but would need additional hardening for production use! 🔒