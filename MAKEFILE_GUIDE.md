# Fluence Makefile - Quick Reference

## 🚀 Essential Commands

### First Time Setup
```bash
make quickstart        # Complete setup and show next steps
# OR step by step:
make setup            # Install dependencies + setup .env files
make db-setup         # Shows Supabase setup instructions
```

### Daily Development
```bash
make run              # Start both backend + frontend servers
make status           # Check if services are running
make health-check     # Test API endpoints
make stop             # Stop all services
make restart          # Restart everything
```

### Testing & Quality
```bash
make test             # Run all tests
make lint             # Check code quality
make format           # Auto-format code
make clean            # Clean build artifacts
```

### Useful Utilities
```bash
make logs             # View service logs
make deps-update      # Check for dependency updates
make git-setup        # Initialize git repo
make sprint-status    # Show current sprint progress
```

## 🎯 Quick Workflow

1. **First time**: `make quickstart`
2. **Update .env files** with your Supabase credentials
3. **Setup database**: Follow `make db-setup` instructions  
4. **Start coding**: `make run`
5. **Check status**: `make status`

## 🔧 Environment Files to Update

After running `make setup`, update these files:

### backend/.env
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### frontend/.env  
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_BASE_URL=http://localhost:8000/api
```

## 📊 Service URLs

When running `make run`:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

## 🆘 Troubleshooting

### Services won't start
```bash
make stop             # Stop everything
make clean            # Clean build artifacts  
make install          # Reinstall dependencies
make run              # Try again
```

### Docker issues
```bash
docker --version      # Check Docker is installed
make build-sandbox    # Rebuild execution environment
```

### Environment issues
```bash
make setup-env        # Recreate .env files
# Then manually update with your credentials
```

---

**💡 Tip**: Run `make help` to see all 30+ available commands!