# Todo App Makefile

.PHONY: help install dev build test clean deploy

# Default target
help:
	@echo "Available commands:"
	@echo "  install     - Install all dependencies"
	@echo "  dev         - Start development environment"
	@echo "  build       - Build production images"
	@echo "  test        - Run all tests"
	@echo "  lint        - Run linting"
	@echo "  clean       - Clean up containers and images"
	@echo "  deploy      - Deploy to production"
	@echo "  logs        - Show application logs"
	@echo "  health      - Check application health"

# Install dependencies
install:
	@echo "Installing backend dependencies..."
	cd backend && npm install
	@echo "Installing frontend dependencies..."
	cd frontend && npm install

# Development environment
dev:
	@echo "Starting development environment..."
	docker-compose -f docker-compose.dev.yml up --build

dev-down:
	@echo "Stopping development environment..."
	docker-compose -f docker-compose.dev.yml down

# Production environment
prod:
	@echo "Starting production environment..."
	docker-compose -f docker-compose.yml up --build -d

prod-down:
	@echo "Stopping production environment..."
	docker-compose -f docker-compose.yml down

# Build production images
build:
	@echo "Building production images..."
	docker-compose -f docker-compose.yml build

# Run tests
test:
	@echo "Running backend tests..."
	cd backend && npm test
	@echo "Running frontend tests..."
	cd frontend && npm test -- --watchAll=false

# Run linting
lint:
	@echo "Running backend linting..."
	cd backend && npm run lint || true
	@echo "Running frontend linting..."
	cd frontend && npm run lint || true

# Clean up
clean:
	@echo "Cleaning up containers and images..."
	docker-compose -f docker-compose.yml down -v
	docker-compose -f docker-compose.dev.yml down -v
	docker system prune -f

# Deploy to production (requires proper setup)
deploy:
	@echo "Deploying to production..."
	./scripts/deploy.sh

# Show logs
logs:
	docker-compose -f docker-compose.yml logs -f

logs-dev:
	docker-compose -f docker-compose.dev.yml logs -f

# Health check
health:
	@echo "Checking application health..."
	@curl -f http://localhost:5000/health || echo "Backend not responding"
	@curl -f http://localhost:3000 || echo "Frontend not responding"

# Database operations
db-backup:
	@echo "Creating database backup..."
	docker exec todo-mongodb mongodump --archive | gzip > backup-$(shell date +%Y%m%d-%H%M%S).gz

db-restore:
	@echo "Restoring database from backup..."
	@read -p "Enter backup file path: " backup_file; \
	gunzip -c $$backup_file | docker exec -i todo-mongodb mongorestore --archive

# Development helpers
backend-shell:
	docker exec -it todo-backend-dev /bin/sh

frontend-shell:
	docker exec -it todo-frontend-dev /bin/sh

db-shell:
	docker exec -it todo-mongodb mongosh

# Quick setup for new developers
setup: install
	@echo "Setting up environment files..."
	cp backend/.env.example backend/.env
	cp frontend/.env.example frontend/.env || true
	@echo "Setup complete! Run 'make dev' to start development environment."