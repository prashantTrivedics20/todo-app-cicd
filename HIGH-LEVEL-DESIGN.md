# High-Level Design (HLD) - Todo App CI/CD System

## 📋 Document Overview

**System Name:** Todo Application with CI/CD Pipeline  
**Version:** 1.0  
**Date:** May 2026  
**Author:** DevOps Team  

## 🎯 System Purpose

This document describes the high-level architecture of a full-stack Todo application with automated CI/CD pipeline that enables:
- Continuous Integration and Deployment
- Containerized microservices architecture
- Cloud-based production deployment
- Automated testing and security scanning

---

## 🏗️ System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              SYSTEM ARCHITECTURE                               │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DEVELOPMENT   │    │   SOURCE CODE   │    │   CI/CD ENGINE  │    │   PRODUCTION    │
│   ENVIRONMENT   │    │   MANAGEMENT    │    │   (AUTOMATION)  │    │   ENVIRONMENT   │
│                 │    │                 │    │                 │    │                 │
│ • Local Setup   │───▶│ • GitHub Repo   │───▶│ • GitHub Actions│───▶│ • AWS EC2       │
│ • Docker Dev    │    │ • Version Ctrl  │    │ • Build/Test    │    │ • Docker Prod   │
│ • Hot Reload    │    │ • Branch Mgmt   │    │ • Deploy Auto   │    │ • Load Balanced │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🎨 Application Architecture

### 1. Three-Tier Architecture
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           APPLICATION LAYERS                                   │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ PRESENTATION    │    │   BUSINESS      │    │   DATA LAYER    │
│     LAYER       │    │     LAYER       │    │                 │
│                 │    │                 │    │                 │
│ • React.js      │───▶│ • Node.js       │───▶│ • MongoDB       │
│ • HTML/CSS/JS   │    │ • Express API   │    │ • Collections   │
│ • User Interface│    │ • Business Logic│    │ • Indexes       │
│ • Client State  │    │ • Validation    │    │ • Persistence   │
│                 │    │ • Authentication│    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
     Port 3000              Port 5000            Port 27017
```

### 2. Microservices Communication
```
Internet Users
      │
      ▼
┌─────────────────┐
│   Load Balancer │ (Future Enhancement)
│   (nginx/ALB)   │
└─────────────────┘
      │
      ▼
┌─────────────────┐    HTTP/REST API    ┌─────────────────┐
│   Frontend      │◀──────────────────▶│   Backend       │
│   Service       │                    │   Service       │
│                 │                    │                 │
│ • Static Files  │                    │ • API Endpoints │
│ • SPA Routing   │                    │ • Business Logic│
│ • State Mgmt    │                    │ • Data Validation│
└─────────────────┘                    └─────────────────┘
                                              │
                                              ▼
                                    ┌─────────────────┐
                                    │   Database      │
                                    │   Service       │
                                    │                 │
                                    │ • Data Storage  │
                                    │ • CRUD Ops      │
                                    │ • Transactions  │
                                    └─────────────────┘
```

---

## 🔄 CI/CD Pipeline Architecture

### 1. Pipeline Stages Overview
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            CI/CD PIPELINE FLOW                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

Developer Push
      │
      ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   SOURCE        │    │   CONTINUOUS    │    │   CONTINUOUS    │    │   DEPLOYMENT    │
│   CONTROL       │    │   INTEGRATION   │    │   DELIVERY      │    │   TARGET        │
│                 │    │                 │    │                 │    │                 │
│ • Git Push      │───▶│ • Code Checkout │───▶│ • Build Images  │───▶│ • AWS EC2       │
│ • Branch Merge  │    │ • Run Tests     │    │ • Push Registry │    │ • Container Orch│
│ • PR Creation   │    │ • Security Scan │    │ • Tag Versions  │    │ • Health Checks │
│ • Webhook       │    │ • Quality Gates │    │ • Artifact Store│    │ • Rollback      │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2. Detailed Pipeline Workflow
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         GITHUB ACTIONS WORKFLOW                                │
└─────────────────────────────────────────────────────────────────────────────────┘

Trigger Event (git push)
         │
         ▼
┌─────────────────┐
│  Job: test-     │    Parallel Execution
│  backend        │◀─────────────────────┐
└─────────────────┘                      │
         │                               │
         ▼                               │
┌─────────────────┐                      │
│  Job: test-     │                      │
│  frontend       │                      │
└─────────────────┘                      │
         │                               │
         ▼                               │
┌─────────────────┐                      │
│  Job: security- │                      │
│  scan           │                      │
└─────────────────┘                      │
         │                               │
         ▼                               │
┌─────────────────┐    Wait for All ─────┘
│  Job: build-    │    Jobs to Complete
│  images         │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  Job: deploy    │
│  to-ec2         │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  Job: notify    │
│  status         │
└─────────────────┘
```

---

## 🐳 Containerization Architecture

### 1. Docker Container Strategy
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          CONTAINER ARCHITECTURE                                │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   Container     │    │   Container     │    │   Container     │
│                 │    │                 │    │                 │
│ Base: nginx     │    │ Base: node      │    │ Base: mongo     │
│ Size: ~50MB     │    │ Size: ~200MB    │    │ Size: ~400MB    │
│ Ports: 80       │    │ Ports: 5000     │    │ Ports: 27017    │
│ Health: wget    │    │ Health: curl    │    │ Health: mongo   │
│ Restart: always │    │ Restart: always │    │ Restart: always │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │ Docker Network  │
                    │ "todo-network"  │
                    │ Bridge Driver   │
                    └─────────────────┘
```

### 2. Multi-Stage Build Process
```
Frontend Dockerfile:
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           MULTI-STAGE BUILD                                    │
└─────────────────────────────────────────────────────────────────────────────────┘

Stage 1: BUILD
┌─────────────────┐
│ node:18-alpine  │ ← Base image (500MB)
├─────────────────┤
│ npm install     │ ← Install ALL dependencies
├─────────────────┤
│ npm run build   │ ← Compile React → static files
├─────────────────┤
│ /app/build/     │ ← Generated artifacts
└─────────────────┘
         │
         ▼ (Copy artifacts only)
Stage 2: PRODUCTION
┌─────────────────┐
│ nginx:alpine    │ ← Lightweight base (15MB)
├─────────────────┤
│ Copy build/     │ ← Only static files
├─────────────────┤
│ nginx.conf      │ ← Web server config
└─────────────────┘
Final Size: ~50MB (vs 500MB single stage)
```

---

## ☁️ Cloud Infrastructure Architecture

### 1. AWS Infrastructure Layout
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            AWS CLOUD ARCHITECTURE                              │
└─────────────────────────────────────────────────────────────────────────────────┘

Internet Gateway
         │
         ▼
┌─────────────────┐
│   Route 53      │ (Future: DNS Management)
│   (DNS)         │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   CloudFront    │ (Future: CDN)
│   (CDN)         │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Application     │
│ Load Balancer   │ (Future: High Availability)
└─────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              VPC (Virtual Private Cloud)                       │
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │   Public        │    │   Private       │    │   Database      │             │
│  │   Subnet        │    │   Subnet        │    │   Subnet        │             │
│  │                 │    │                 │    │                 │             │
│  │ • EC2 Instance  │    │ • Future App    │    │ • Future RDS    │             │
│  │ • Public IP     │    │   Servers       │    │ • MongoDB       │             │
│  │ • Security Grp  │    │ • No Public IP  │    │ • Backups       │             │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘             │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 2. Current vs Future Architecture
```
CURRENT (Single EC2):
┌─────────────────┐
│   EC2 Instance  │
│ 15.206.93.46    │
│                 │
│ • All containers│
│ • Single point  │
│ • Manual scaling│
└─────────────────┘

FUTURE (Scalable):
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Tier      │    │   App Tier      │    │   Data Tier     │
│                 │    │                 │    │                 │
│ • Multiple EC2  │    │ • Auto Scaling  │    │ • RDS Multi-AZ  │
│ • Load Balancer │    │ • ECS/EKS       │    │ • Read Replicas │
│ • Auto Scaling  │    │ • Health Checks │    │ • Automated     │
│                 │    │                 │    │   Backups       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🔐 Security Architecture

### 1. Security Layers
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            SECURITY ARCHITECTURE                               │
└─────────────────────────────────────────────────────────────────────────────────┘

Layer 1: Network Security
┌─────────────────┐
│ AWS Security    │ • Firewall rules
│ Groups          │ • Port restrictions
│                 │ • IP whitelisting
└─────────────────┘

Layer 2: Application Security
┌─────────────────┐
│ Container       │ • Process isolation
│ Isolation       │ • Resource limits
│                 │ • Non-root users
└─────────────────┘

Layer 3: Data Security
┌─────────────────┐
│ Secrets         │ • GitHub Secrets
│ Management      │ • Environment vars
│                 │ • No hardcoded keys
└─────────────────┘

Layer 4: Code Security
┌─────────────────┐
│ Vulnerability   │ • Trivy scanning
│ Scanning        │ • Dependency check
│                 │ • SAST analysis
└─────────────────┘
```

### 2. Authentication & Authorization Flow
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        SECURITY FLOW (Future Enhancement)                      │
└─────────────────────────────────────────────────────────────────────────────────┘

User Request
     │
     ▼
┌─────────────────┐
│   WAF           │ • DDoS protection
│ (Web App        │ • SQL injection
│  Firewall)      │ • XSS prevention
└─────────────────┘
     │
     ▼
┌─────────────────┐
│   Load          │ • SSL termination
│   Balancer      │ • Rate limiting
└─────────────────┘
     │
     ▼
┌─────────────────┐
│   Application   │ • JWT validation
│   Gateway       │ • API throttling
└─────────────────┘
     │
     ▼
┌─────────────────┐
│   Backend       │ • Business logic
│   Services      │ • Data validation
└─────────────────┘
```

---

## 📊 Data Flow Architecture

### 1. Request-Response Flow
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              DATA FLOW DIAGRAM                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

User Action (Create Todo)
         │
         ▼
┌─────────────────┐    HTTP POST     ┌─────────────────┐
│   React App     │─────────────────▶│   Express API   │
│                 │  /api/todos      │                 │
│ • Form Submit   │                  │ • Route Handler │
│ • State Update  │                  │ • Validation    │
│ • UI Feedback   │                  │ • Business Logic│
└─────────────────┘                  └─────────────────┘
         ▲                                    │
         │                                    ▼
         │                          ┌─────────────────┐
         │                          │   MongoDB       │
         │                          │                 │
         │                          │ • Insert Doc    │
         │                          │ • Generate ID   │
         │                          │ • Return Result │
         │                          └─────────────────┘
         │                                    │
         │            JSON Response           │
         └────────────────────────────────────┘
                    (Todo Object)
```

### 2. Database Schema Design
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            DATABASE ARCHITECTURE                               │
└─────────────────────────────────────────────────────────────────────────────────┘

MongoDB Database: todoapp
│
├── Collection: todos
│   ├── Document Structure:
│   │   {
│   │     _id: ObjectId,
│   │     title: String (required),
│   │     description: String,
│   │     completed: Boolean (default: false),
│   │     priority: String (enum: low/medium/high),
│   │     tags: Array[String],
│   │     dueDate: Date,
│   │     createdAt: Date,
│   │     updatedAt: Date
│   │   }
│   │
│   ├── Indexes:
│   │   ├── Primary: _id (auto)
│   │   ├── Compound: {completed: 1, createdAt: -1}
│   │   ├── Single: {dueDate: 1}
│   │   └── Text: {title: "text", description: "text"}
│   │
│   └── Sample Data:
│       ├── Welcome Todo (completed: false)
│       ├── Setup Environment (completed: true)
│       └── Deploy to Production (completed: false)
│
└── Collection: users (Future)
    └── Authentication & user management
```

---

## 🚀 Deployment Architecture

### 1. Deployment Strategy
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DEPLOYMENT STRATEGY                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

Current: Rolling Deployment
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Step 1:       │    │   Step 2:       │    │   Step 3:       │
│   Backup Data   │───▶│   Stop Old      │───▶│   Start New     │
│                 │    │   Containers    │    │   Containers    │
│ • MongoDB dump  │    │ • Graceful stop │    │ • Health checks │
│ • Versioned     │    │ • Clean up      │    │ • Smoke tests   │
└─────────────────┘    └─────────────────┘    └─────────────────┘

Future: Blue-Green Deployment
┌─────────────────┐                    ┌─────────────────┐
│   Blue Env      │                    │   Green Env     │
│   (Current)     │                    │   (New)         │
│                 │                    │                 │
│ • Live Traffic  │                    │ • Deploy New    │
│ • Version N     │                    │ • Version N+1   │
│ • Stable        │                    │ • Testing       │
└─────────────────┘                    └─────────────────┘
         │                                      │
         └──────────── Switch Traffic ─────────┘
                    (After validation)
```

### 2. Rollback Strategy
```
Rollback Triggers:
├── Health Check Failures
├── High Error Rates
├── Performance Degradation
└── Manual Intervention

Rollback Process:
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Detect Issue  │───▶│   Stop New      │───▶│   Restore Old   │
│                 │    │   Deployment    │    │   Version       │
│ • Monitoring    │    │ • Kill containers│    │ • Previous image│
│ • Alerts        │    │ • Stop traffic  │    │ • Restore DB    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 📈 Monitoring & Observability

### 1. Monitoring Architecture
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          MONITORING ARCHITECTURE                               │
└─────────────────────────────────────────────────────────────────────────────────┘

Application Metrics
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Health        │    │   Performance   │    │   Business      │
│   Metrics       │    │   Metrics       │    │   Metrics       │
│                 │    │                 │    │                 │
│ • Uptime        │    │ • Response Time │    │ • Todo Created  │
│ • Error Rate    │    │ • Throughput    │    │ • User Activity │
│ • Status Codes  │    │ • CPU/Memory    │    │ • Feature Usage │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Monitoring    │
                    │   Dashboard     │
                    │                 │
                    │ • Real-time     │
                    │ • Alerts        │
                    │ • Historical    │
                    └─────────────────┘
```

### 2. Logging Strategy
```
Log Sources:
├── Application Logs (Backend API)
├── Web Server Logs (Nginx)
├── Database Logs (MongoDB)
├── Container Logs (Docker)
└── System Logs (EC2)

Log Aggregation:
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Collection    │───▶│   Processing    │───▶│   Storage &     │
│                 │    │                 │    │   Analysis      │
│ • Filebeat      │    │ • Logstash      │    │ • Elasticsearch │
│ • Fluentd       │    │ • Parsing       │    │ • Kibana        │
│ • Docker logs   │    │ • Filtering     │    │ • Dashboards    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🔧 Technology Stack

### 1. Development Stack
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            TECHNOLOGY STACK                                    │
└─────────────────────────────────────────────────────────────────────────────────┘

Frontend Technologies:
├── React 18.2.0 (UI Framework)
├── JavaScript ES6+ (Programming Language)
├── HTML5/CSS3 (Markup & Styling)
├── Axios (HTTP Client)
├── React Router (Client-side Routing)
└── React Query (State Management)

Backend Technologies:
├── Node.js 18 (Runtime Environment)
├── Express.js (Web Framework)
├── MongoDB (NoSQL Database)
├── Mongoose (ODM)
├── Helmet (Security Middleware)
└── CORS (Cross-Origin Resource Sharing)

DevOps Technologies:
├── Docker (Containerization)
├── Docker Compose (Orchestration)
├── GitHub Actions (CI/CD)
├── AWS EC2 (Cloud Computing)
├── Nginx (Web Server/Reverse Proxy)
└── Trivy (Security Scanning)
```

### 2. Infrastructure Stack
```
Cloud Provider: AWS
├── Compute: EC2 (t2.micro)
├── Storage: EBS (General Purpose SSD)
├── Network: VPC, Security Groups
├── DNS: Route 53 (Future)
├── CDN: CloudFront (Future)
└── Load Balancer: ALB (Future)

Container Platform: Docker
├── Base Images: Alpine Linux
├── Registry: Docker Hub
├── Orchestration: Docker Compose
├── Networking: Bridge Network
└── Storage: Named Volumes

CI/CD Platform: GitHub Actions
├── Runners: Ubuntu Latest
├── Workflows: YAML Configuration
├── Secrets: Encrypted Storage
├── Artifacts: Docker Images
└── Notifications: Status Updates
```

---

## 📋 System Requirements

### 1. Functional Requirements
```
User Management:
├── Create new todos
├── Read/List todos
├── Update todo status
├── Delete todos
└── Filter/Search todos

System Management:
├── Automated deployments
├── Health monitoring
├── Error handling
├── Data persistence
└── Backup/Recovery
```

### 2. Non-Functional Requirements
```
Performance:
├── Response Time: < 200ms (API)
├── Throughput: 100 req/sec
├── Availability: 99.9% uptime
└── Scalability: Horizontal scaling

Security:
├── Data encryption in transit
├── Input validation
├── Rate limiting
├── Security headers
└── Vulnerability scanning

Reliability:
├── Automated health checks
├── Graceful error handling
├── Data backup strategy
├── Rollback capability
└── Monitoring & alerting
```

---

## 🎯 Future Enhancements

### 1. Short-term (Next 3 months)
```
Security Improvements:
├── SSL/TLS certificates
├── User authentication (JWT)
├── API rate limiting
├── Input sanitization
└── Security headers

Performance Optimization:
├── Database indexing
├── API caching (Redis)
├── Image optimization
├── CDN integration
└── Compression (gzip)
```

### 2. Long-term (6-12 months)
```
Scalability:
├── Kubernetes migration
├── Microservices architecture
├── Auto-scaling groups
├── Load balancing
└── Multi-region deployment

Advanced Features:
├── Real-time notifications
├── Collaborative todos
├── Mobile application
├── Analytics dashboard
└── AI-powered suggestions
```

---

## 📊 Success Metrics

### 1. Technical KPIs
```
Deployment Metrics:
├── Deployment Frequency: Daily
├── Lead Time: < 30 minutes
├── Mean Time to Recovery: < 15 minutes
├── Change Failure Rate: < 5%
└── Deployment Success Rate: > 95%

Performance Metrics:
├── API Response Time: < 200ms
├── Page Load Time: < 3 seconds
├── Error Rate: < 1%
├── Uptime: > 99.9%
└── Database Query Time: < 50ms
```

### 2. Business KPIs
```
User Experience:
├── User Satisfaction Score
├── Feature Adoption Rate
├── Task Completion Rate
├── User Retention
└── Performance Feedback

Operational Efficiency:
├── Development Velocity
├── Bug Resolution Time
├── Infrastructure Costs
├── Team Productivity
└── System Reliability
```

---

This High-Level Design provides a comprehensive overview of the entire system architecture, from development to production deployment. It serves as a blueprint for understanding how all components work together to deliver a robust, scalable, and maintainable application with modern DevOps practices.