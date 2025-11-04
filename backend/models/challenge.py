from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class DifficultyLevel(str, Enum):
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"

class ChallengeCategory(str, Enum):
    BASICS = "basics"
    STRINGS = "strings"
    LISTS = "lists"
    CLASSES = "classes"
    ALGORITHMS = "algorithms"
    UI = "ui"
    STATE = "state"
    LOGIC = "logic"
    ANIMATION = "animation"

class ChallengeBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1)
    starter_code: str = Field(..., min_length=1)
    test_script: Optional[str] = None
    is_premium: bool = False
    difficulty: DifficultyLevel = DifficultyLevel.EASY
    category: ChallengeCategory = ChallengeCategory.BASICS
    sort_order: int = 0

class ChallengeCreate(ChallengeBase):
    pass

class ChallengeUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, min_length=1)
    starter_code: Optional[str] = Field(None, min_length=1)
    test_script: Optional[str] = None
    is_premium: Optional[bool] = None
    difficulty: Optional[DifficultyLevel] = None
    category: Optional[ChallengeCategory] = None
    sort_order: Optional[int] = None

class Challenge(ChallengeBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ChallengeList(BaseModel):
    challenges: List[Challenge]
    total: int
    page: int
    per_page: int
    has_next: bool
    has_prev: bool

class ChallengeFilters(BaseModel):
    difficulty: Optional[DifficultyLevel] = None
    category: Optional[ChallengeCategory] = None
    is_premium: Optional[bool] = None
    search: Optional[str] = None
    page: int = Field(1, ge=1)
    per_page: int = Field(10, ge=1, le=100)