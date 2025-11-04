from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from models.submission import CodeExecutionRequest, CodeExecutionResponse
from utils.sandbox_runner import DartCodeRunner
from datetime import datetime

router = APIRouter()

@router.post("/execute", response_model=CodeExecutionResponse)
async def execute_code(request: CodeExecutionRequest):
    """Execute Dart/Flutter code in a secure sandbox environment"""
    try:
        runner = DartCodeRunner()
        result = await runner.run_code(request.code, request.test_script)
        
        return CodeExecutionResponse(
            success=result["success"],
            output=result["output"],
            errors=result.get("errors"),
            execution_time=result["execution_time"],
            timestamp=datetime.utcnow()
        )
    
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Code execution failed: {str(e)}"
        )