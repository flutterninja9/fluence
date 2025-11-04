# Fluence Backend

FastAPI backend for the Flutter learning platform.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Copy environment variables:
```bash
cp .env.example .env
```

3. Update `.env` with your Supabase credentials

4. Install Docker (required for code execution)

5. Run the development server:
```bash
python main.py
```

## API Endpoints

- `GET /api/health` - Health check
- `POST /api/execute` - Execute Dart code

## Docker

Build and run with Docker:
```bash
docker build -t fluence-backend .
docker run -p 8000:8000 fluence-backend
```

## Security

The code execution system uses Docker containers with:
- Memory limits
- CPU restrictions
- Network isolation
- Read-only filesystem
- Non-root user execution
- Capability dropping