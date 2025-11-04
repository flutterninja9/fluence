from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class UserProfile(BaseModel):
    id: str
    email: str
    name: Optional[str] = None
    is_pro: bool = False
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class FeedbackBase(BaseModel):
    challenge_id: str
    rating: int = Field(..., ge=1, le=5)
    message: Optional[str] = None

class FeedbackCreate(FeedbackBase):
    pass

class Feedback(FeedbackBase):
    id: str
    user_id: str
    created_at: datetime

    class Config:
        from_attributes = True