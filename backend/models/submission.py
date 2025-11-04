from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime

class SubmissionBase(BaseModel):
    challenge_id: str
    code: str = Field(..., min_length=1)
    result: Optional[Dict[str, Any]] = None
    is_successful: bool = False

class SubmissionCreate(SubmissionBase):
    pass

class Submission(SubmissionBase):
    id: str
    user_id: str
    created_at: datetime

    class Config:
        from_attributes = True

class CodeExecutionRequest(BaseModel):
    code: str = Field(..., min_length=1)
    test_script: Optional[str] = None

class CodeExecutionResponse(BaseModel):
    success: bool
    output: str
    errors: Optional[str] = None
    execution_time: float
    timestamp: datetime = Field(default_factory=datetime.utcnow)