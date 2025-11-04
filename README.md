# Fluence - Flutter Learning Platform

> A Flutter-based coding platform like LeetCode, focused on learning and experimentation rather than competition.

## 🚀 Quick Start

```bash
# Complete setup in one command
make quickstart

# Or step by step:
make setup              # Install dependencies & setup environment
make run               # Start both backend and frontend servers
```

## 📋 Development Commands

The project includes a comprehensive Makefile for easy development. Run `make help` to see all available commands:

### Essential Commands
```bash
make help              # Show all available commands
make setup             # Complete project setup
make run               # Start development servers
make test              # Run all tests
make clean             # Clean build artifacts
make stop              # Stop all servers
```

### Quick Development
```bash
make status            # Check service status
make logs              # View service logs
make health-check      # Test API endpoints
make restart           # Restart all services
```

### Code Quality
```bash
make lint              # Run linting
make format            # Format all code
make test-watch        # Run tests in watch mode
```

## 🏗️ Project Structure

```
fluence/
├── backend/           # FastAPI server
│   ├── main.py       # Application entry point
│   ├── api/          # API routes
│   ├── utils/        # Utilities (sandbox runner)
│   └── requirements.txt
├── frontend/         # Flutter web app
│   ├── lib/          # Dart source code
│   ├── web/          # Web-specific files
│   └── pubspec.yaml  # Dependencies
├── supabase/         # Database schema & seeds
│   ├── schema.sql    # Database schema
│   └── seed_data.sql # Sample challenges
├── logs/             # Development logs
└── Makefile          # Development automation
```

## 🔧 Environment Setup

### Prerequisites
- Python 3.12+
- Flutter 3.9+
- Docker (for code execution sandbox)
- Supabase account

### Configuration
1. **Backend**: Update `backend/.env` with Supabase credentials
2. **Frontend**: Update `frontend/.env` with API endpoints
3. **Database**: Follow `make db-setup` instructions

## 🌐 Services

When running `make run`:
- **Backend API**: http://localhost:8000
- **Frontend App**: http://localhost:3000  
- **API Documentation**: http://localhost:8000/docs

## 🎯 Sprint Progress

- ✅ **Sprint 1**: Foundation & Infrastructure (COMPLETED)
- 🔄 **Sprint 2**: Core Challenge System (Next)

## 📚 Documentation

- [Sprint 1 Completion](SPRINT_1_COMPLETION.md)
- [Detailed Sprint Plan](detailed_4_sprint_plan.md)
- [MVP Plan](mvp_plan.md)

## 🛠️ Technology Stack

- **Backend**: FastAPI, Docker, Supabase
- **Frontend**: Flutter Web, Riverpod, go_router
- **Database**: PostgreSQL (Supabase)
- **Authentication**: Supabase OAuth
- **UI**: forui component library

## 📞 Common Issues

### Backend won't start
```bash
make install-backend   # Reinstall dependencies
make setup-env        # Check environment files
```

### Frontend build errors
```bash
make clean            # Clean Flutter cache
make install-frontend # Reinstall dependencies
```

### Docker issues
```bash
docker --version      # Check Docker installation
make build-sandbox    # Rebuild sandbox image
```

---

**Quick Start**: `make quickstart` → Update `.env` files → `make run`