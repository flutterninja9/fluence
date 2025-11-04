# Fluence - Flutter Learning Platform
# Makefile for development automation

.PHONY: help install setup run clean test build deploy-local stop logs status

# Default target
help: ## Show this help message
	@echo "Fluence - Flutter Learning Platform"
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# =============================================================================
# SETUP & INSTALLATION
# =============================================================================

install: ## Install all dependencies for backend and frontend
	@echo "🔧 Installing dependencies..."
	$(MAKE) install-backend
	$(MAKE) install-frontend
	@echo "✅ All dependencies installed!"

install-backend: ## Install Python backend dependencies
	@echo "🐍 Installing backend dependencies..."
	cd backend && python3 -m pip install -r requirements.txt

install-frontend: ## Install Flutter frontend dependencies
	@echo "📱 Installing frontend dependencies..."
	cd frontend && flutter pub get

setup: ## Complete project setup (install + environment)
	@echo "🚀 Setting up Fluence development environment..."
	$(MAKE) install
	$(MAKE) setup-env
	@echo "✅ Setup complete! Run 'make run' to start development servers."

setup-env: ## Copy environment templates
	@echo "📝 Setting up environment files..."
	@if [ ! -f backend/.env ]; then \
		cp backend/.env.example backend/.env; \
		echo "⚠️  Please update backend/.env with your Supabase credentials"; \
	fi
	@if [ ! -f frontend/.env ]; then \
		cp frontend/.env.example frontend/.env; \
		echo "⚠️  Please update frontend/.env with your configuration"; \
	fi

# =============================================================================
# DEVELOPMENT SERVERS
# =============================================================================

run: ## Start both backend and frontend development servers
	@echo "🚀 Starting Fluence development servers..."
	$(MAKE) run-backend &
	sleep 3
	$(MAKE) run-frontend &
	@echo "✅ Servers starting..."
	@echo "📊 Backend: http://localhost:8000"
	@echo "🌐 Frontend: http://localhost:3000"
	@echo "📖 API Docs: http://localhost:8000/docs"

run-backend: ## Start FastAPI backend server
	@echo "🐍 Starting backend server..."
	cd backend && python3 main.py

run-frontend: ## Start Flutter web development server
	@echo "📱 Starting frontend server..."
	cd frontend && flutter run --dart-define-from-file .env -d web-server --web-port 3000

run-backend-bg: ## Start backend server in background
	@echo "🐍 Starting backend server in background..."
	cd backend && nohup python3 main.py > ../logs/backend.log 2>&1 & echo $$! > ../logs/backend.pid

run-frontend-bg: ## Start frontend server in background
	@echo "📱 Starting frontend server in background..."
	mkdir -p logs
	cd frontend && nohup flutter run -d web-server --web-port 3000 > ../logs/frontend.log 2>&1 & echo $$! > ../logs/frontend.pid

# =============================================================================
# TESTING
# =============================================================================

test: ## Run all tests
	@echo "🧪 Running all tests..."
	$(MAKE) test-backend
	$(MAKE) test-frontend

test-backend: ## Run backend tests
	@echo "🐍 Running backend tests..."
	cd backend && python3 -m pytest

test-frontend: ## Run frontend tests
	@echo "📱 Running frontend tests..."
	cd frontend && flutter test

test-backend-watch: ## Run backend tests in watch mode
	@echo "🐍 Running backend tests in watch mode..."
	cd backend && python3 -m pytest --watch

health-check: ## Check if services are running
	@echo "🏥 Checking service health..."
	@curl -s http://localhost:8000/api/health || echo "❌ Backend not running"
	@curl -s http://localhost:3000 || echo "❌ Frontend not running"

# =============================================================================
# DATABASE & SUPABASE
# =============================================================================

db-setup: ## Instructions for setting up Supabase database
	@echo "📊 Setting up Supabase database..."
	@echo "1. Create a new project at https://supabase.com"
	@echo "2. Copy the SQL from supabase/schema.sql and run it in SQL Editor"
	@echo "3. Copy the SQL from supabase/seed_data.sql and run it in SQL Editor"
	@echo "4. Update backend/.env with your Supabase credentials"
	@echo "5. Update frontend/.env with your Supabase credentials"

db-migrate: ## Apply database migrations (manual step)
	@echo "📊 Database migration instructions:"
	@echo "Go to your Supabase dashboard > SQL Editor"
	@echo "Copy and run the contents of: supabase/schema.sql"

db-seed: ## Seed database with sample data (manual step)
	@echo "🌱 Database seeding instructions:"
	@echo "Go to your Supabase dashboard > SQL Editor"
	@echo "Copy and run the contents of: supabase/seed_data.sql"

# =============================================================================
# CODE QUALITY
# =============================================================================

lint: ## Run linting for all code
	@echo "🔍 Running linters..."
	$(MAKE) lint-backend
	$(MAKE) lint-frontend

lint-backend: ## Run Python linting
	@echo "🐍 Linting backend code..."
	cd backend && python3 -m flake8 . || echo "⚠️  Install flake8: pip install flake8"

lint-frontend: ## Run Flutter linting
	@echo "📱 Analyzing frontend code..."
	cd frontend && flutter analyze

format: ## Format all code
	@echo "✨ Formatting code..."
	$(MAKE) format-backend
	$(MAKE) format-frontend

format-backend: ## Format Python code
	@echo "🐍 Formatting backend code..."
	cd backend && python3 -m black . || echo "⚠️  Install black: pip install black"

format-frontend: ## Format Flutter code
	@echo "📱 Formatting frontend code..."
	cd frontend && dart format .

# =============================================================================
# BUILD & DEPLOYMENT
# =============================================================================

build: ## Build production versions
	@echo "🏗️  Building production versions..."
	$(MAKE) build-backend
	$(MAKE) build-frontend

build-backend: ## Build backend Docker image
	@echo "🐍 Building backend Docker image..."
	cd backend && docker build -t fluence-backend .

build-frontend: ## Build frontend for production
	@echo "📱 Building frontend for production..."
	cd frontend && flutter build web

build-sandbox: ## Build Dart execution sandbox image
	@echo "🐳 Building Dart sandbox image..."
	cd backend && docker build -f Dockerfile.sandbox -t fluence-dart-sandbox .

deploy-local: ## Deploy locally with Docker
	@echo "🚀 Deploying locally with Docker..."
	$(MAKE) build-backend
	docker run -d --name fluence-backend -p 8000:8000 fluence-backend
	@echo "✅ Backend deployed on http://localhost:8000"

# =============================================================================
# UTILITIES
# =============================================================================

clean: ## Clean build artifacts and caches
	@echo "🧹 Cleaning build artifacts..."
	cd frontend && flutter clean
	find . -name "__pycache__" -type d -exec rm -rf {} + || true
	find . -name "*.pyc" -delete || true
	docker system prune -f || true

stop: ## Stop all development servers
	@echo "🛑 Stopping development servers..."
	@pkill -f "python3 main.py" || true
	@pkill -f "flutter run" || true
	@if [ -f logs/backend.pid ]; then kill `cat logs/backend.pid` && rm logs/backend.pid; fi
	@if [ -f logs/frontend.pid ]; then kill `cat logs/frontend.pid` && rm logs/frontend.pid; fi
	@docker stop fluence-backend || true
	@docker rm fluence-backend || true

logs: ## Show logs from background services
	@echo "📋 Service logs:"
	@echo "--- Backend Logs ---"
	@tail -n 20 logs/backend.log 2>/dev/null || echo "No backend logs found"
	@echo "--- Frontend Logs ---"
	@tail -n 20 logs/frontend.log 2>/dev/null || echo "No frontend logs found"

status: ## Show status of all services
	@echo "📊 Service Status:"
	@echo "Backend:  $(shell curl -s http://localhost:8000/api/health > /dev/null && echo '✅ Running' || echo '❌ Not running')"
	@echo "Frontend: $(shell curl -s http://localhost:3000 > /dev/null && echo '✅ Running' || echo '❌ Not running')"
	@echo "Docker:   $(shell docker --version > /dev/null && echo '✅ Available' || echo '❌ Not available')"

restart: ## Restart all services
	@echo "🔄 Restarting services..."
	$(MAKE) stop
	sleep 2
	$(MAKE) run

# =============================================================================
# DEVELOPMENT HELPERS
# =============================================================================

shell-backend: ## Open Python shell with backend context
	@echo "🐍 Opening backend Python shell..."
	cd backend && python3 -i -c "from main import app; from config import settings; print('Backend shell ready!')"

console-frontend: ## Open Dart console (if available)
	@echo "📱 Opening Flutter/Dart console..."
	cd frontend && dart

deps-update: ## Update all dependencies
	@echo "📦 Updating dependencies..."
	cd backend && pip list --outdated
	cd frontend && flutter pub outdated

docs: ## Open relevant documentation
	@echo "📚 Opening documentation..."
	@echo "Backend API: http://localhost:8000/docs"
	@echo "FastAPI: https://fastapi.tiangolo.com/"
	@echo "Flutter: https://flutter.dev/"
	@echo "Supabase: https://supabase.com/docs"

# =============================================================================
# GIT HELPERS
# =============================================================================

git-setup: ## Initialize git and make initial commit
	@if [ ! -d .git ]; then \
		git init; \
		git add .; \
		git commit -m "Initial commit - Sprint 1 complete"; \
		echo "✅ Git repository initialized"; \
	else \
		echo "📋 Git already initialized"; \
	fi

commit: ## Quick commit with timestamp
	@echo "💾 Making quick commit..."
	git add .
	git commit -m "Quick commit - $(shell date)"

# =============================================================================
# SPRINT MANAGEMENT
# =============================================================================

sprint-status: ## Show current sprint progress
	@echo "🎯 Sprint Progress:"
	@echo "Current Sprint: 1 (Foundation & Infrastructure)"
	@echo "Status: ✅ COMPLETED"
	@echo "Next: Sprint 2 (Core Challenge System)"

sprint-2: ## Show Sprint 2 todos
	@echo "🎯 Sprint 2 - Core Challenge System:"
	@echo "1. [ ] Challenge Management System"
	@echo "2. [ ] Code Editor Integration"  
	@echo "3. [ ] Code Execution System"
	@echo "4. [ ] Challenge Pages"
	@echo "5. [ ] End-to-end Testing"

# =============================================================================
# QUICK START
# =============================================================================

quickstart: ## Complete setup and start development (one command)
	@echo "🚀 Fluence Quick Start..."
	$(MAKE) setup
	@echo ""
	@echo "🎯 Next steps:"
	@echo "1. Update backend/.env with Supabase credentials"
	@echo "2. Update frontend/.env with configuration"
	@echo "3. Run 'make db-setup' to configure Supabase"
	@echo "4. Run 'make run' to start development servers"
	@echo ""
	@echo "📖 Run 'make help' to see all available commands"