from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
from config import settings
from api.routes import health, execute_code, challenges, submissions

def create_app() -> FastAPI:
    app = FastAPI(
        title="Fluence API",
        description="Backend API for Flutter Learning Platform",
        version="1.0.0",
        debug=settings.DEBUG
    )
    
    # Add CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Include routers
    app.include_router(health.router, prefix="/api", tags=["Health"])
    app.include_router(execute_code.router, prefix="/api", tags=["Code Execution"])
    app.include_router(challenges.router, prefix="/api", tags=["Challenges"])
    app.include_router(submissions.router, prefix="/api", tags=["Submissions"])
    
    return app

app = create_app()

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )