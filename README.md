# Todo App with CI/CD Pipeline

A full-stack todo application with automated CI/CD deployment to AWS EC2.

## 🚀 Features

- **Frontend**: Modern React.js application with responsive design
- **Backend**: Node.js Express API with MongoDB
- **Database**: MongoDB with Docker
- **Authentication**: Ready for JWT implementation
- **CI/CD**: GitHub Actions pipeline
- **Deployment**: Automated AWS EC2 deployment
- **Monitoring**: Health checks and logging
- **Security**: Rate limiting, CORS, helmet security headers

## 📁 Project Structure

```
├── backend/              # Node.js Express API
│   ├── models/          # MongoDB models
│   ├── routes/          # API routes
│   ├── tests/           # Backend tests
│   └── Dockerfile       # Backend container
├── frontend/            # React application
│   ├── src/
│   │   ├── components/  # React components
│   │   └── services/    # API services
│   └── Dockerfile       # Frontend container
├── infrastructure/      # AWS deployment configs
├── .github/workflows/   # CI/CD pipeline
├── docker/             # Docker configurations
└── scripts/            # Deployment scripts
```

## 🛠️ Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- AWS account (for deployment)

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd todo-app
make setup
```

### 2. Start Development Environment

```bash
# Start all services with Docker
make dev

# Or start individually
cd backend && npm run dev
cd frontend && npm start
```

### 3. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **API Health**: http://localhost:5000/health

## 🐳 Docker Commands

```bash
# Development environment
make dev              # Start development containers
make dev-down         # Stop development containers

# Production environment  
make prod             # Start production containers
make prod-down        # Stop production containers

# Utilities
make logs             # View application logs
make health           # Check application health
make clean            # Clean up containers and images
```

## 🧪 Testing

```bash
# Run all tests
make test

# Run backend tests only
cd backend && npm test

# Run frontend tests only
cd frontend && npm test
```

## 🚀 Deployment

### AWS EC2 Setup

1. **Create EC2 Instance**:
   ```bash
   # Follow the guide in infrastructure/aws-setup.md
   ```

2. **Setup Instance**:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   curl -fsSL https://raw.githubusercontent.com/your-repo/main/scripts/setup-ec2.sh | bash
   ```

3. **Configure GitHub Secrets**:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `EC2_HOST`
   - `EC2_USER`
   - `EC2_PRIVATE_KEY`
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`

4. **Deploy**:
   ```bash
   git push origin main  # Triggers automatic deployment
   ```

## 🔧 Configuration

### Environment Variables

**Backend** (`.env`):
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://admin:password123@localhost:27017/todoapp?authSource=admin
FRONTEND_URL=http://localhost:3000
```

**Frontend** (`.env`):
```env
REACT_APP_API_URL=http://localhost:5000/api
```

## 📊 API Documentation

### Endpoints

- `GET /api/todos` - Get all todos
- `POST /api/todos` - Create new todo
- `GET /api/todos/:id` - Get specific todo
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Delete todo
- `PATCH /api/todos/:id/toggle` - Toggle completion
- `GET /health` - Health check

### Example Request

```bash
# Create a new todo
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Docker",
    "description": "Complete Docker tutorial",
    "priority": "high",
    "tags": ["learning", "devops"]
  }'
```

## 🔒 Security Features

- Rate limiting (100 requests per 15 minutes)
- CORS protection
- Helmet security headers
- Input validation with Joi
- MongoDB injection protection
- Environment variable protection

## 📈 Monitoring

### Health Checks
```bash
# Application health
curl http://localhost:5000/health

# Container health
docker ps
make health
```

### Logs
```bash
# Application logs
make logs

# Individual service logs
docker logs todo-backend
docker logs todo-frontend
docker logs todo-mongodb
```

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline automatically:

1. **Test Phase**:
   - Runs backend and frontend tests
   - Performs security scanning
   - Validates code quality

2. **Build Phase**:
   - Builds Docker images
   - Pushes to registry
   - Creates deployment artifacts

3. **Deploy Phase**:
   - Deploys to AWS EC2
   - Runs health checks
   - Sends notifications

## 🛠️ Development

### Adding New Features

1. Create feature branch
2. Develop and test locally
3. Run tests: `make test`
4. Create pull request
5. Merge triggers deployment

### Database Operations

```bash
# Backup database
make db-backup

# Restore database
make db-restore

# Access MongoDB shell
make db-shell
```

## 🚨 Troubleshooting

### Common Issues

1. **Port conflicts**: Change ports in docker-compose files
2. **MongoDB connection**: Check container status and credentials
3. **Build failures**: Clear Docker cache with `make clean`

### Debug Commands

```bash
# Check container status
docker ps -a

# View container logs
docker logs <container-name>

# Access container shell
make backend-shell
make frontend-shell
```

## 📚 Additional Resources

- [AWS Setup Guide](infrastructure/aws-setup.md)
- [API Documentation](docs/api.md)
- [Deployment Guide](docs/deployment.md)
- [Contributing Guidelines](CONTRIBUTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes and test
4. Submit pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.