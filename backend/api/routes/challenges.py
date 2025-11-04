from fastapi import APIRouter, HTTPException, Depends, Query
from fastapi.responses import JSONResponse
from typing import Optional
from models.challenge import (
    Challenge, ChallengeCreate, ChallengeUpdate, ChallengeFilters, 
    ChallengeList, DifficultyLevel, ChallengeCategory
)
from services.challenge_service import ChallengeService

router = APIRouter()

def get_challenge_service() -> ChallengeService:
    return ChallengeService()

@router.get("/challenges", response_model=ChallengeList)
async def get_challenges(
    difficulty: Optional[DifficultyLevel] = Query(None, description="Filter by difficulty"),
    category: Optional[ChallengeCategory] = Query(None, description="Filter by category"),
    is_premium: Optional[bool] = Query(None, description="Filter by premium status"),
    search: Optional[str] = Query(None, description="Search in challenge titles"),
    page: int = Query(1, ge=1, description="Page number"),
    per_page: int = Query(10, ge=1, le=100, description="Items per page"),
    user_is_pro: bool = Query(False, description="User has pro access"),
    service: ChallengeService = Depends(get_challenge_service)
):
    """Get challenges with filtering and pagination"""
    filters = ChallengeFilters(
        difficulty=difficulty,
        category=category,
        is_premium=is_premium,
        search=search,
        page=page,
        per_page=per_page
    )
    
    try:
        result = await service.get_challenges(filters, user_is_pro)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch challenges: {str(e)}")

@router.get("/challenges/{challenge_id}", response_model=Challenge)
async def get_challenge(
    challenge_id: str,
    service: ChallengeService = Depends(get_challenge_service)
):
    """Get a specific challenge by ID"""
    try:
        challenge = await service.get_challenge_by_id(challenge_id)
        if not challenge:
            raise HTTPException(status_code=404, detail="Challenge not found")
        return challenge
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch challenge: {str(e)}")

@router.post("/challenges", response_model=Challenge)
async def create_challenge(
    challenge: ChallengeCreate,
    service: ChallengeService = Depends(get_challenge_service)
):
    """Create a new challenge (admin only)"""
    try:
        result = await service.create_challenge(challenge)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create challenge: {str(e)}")

@router.put("/challenges/{challenge_id}", response_model=Challenge)
async def update_challenge(
    challenge_id: str,
    challenge: ChallengeUpdate,
    service: ChallengeService = Depends(get_challenge_service)
):
    """Update a challenge (admin only)"""
    try:
        result = await service.update_challenge(challenge_id, challenge)
        if not result:
            raise HTTPException(status_code=404, detail="Challenge not found")
        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update challenge: {str(e)}")

@router.delete("/challenges/{challenge_id}")
async def delete_challenge(
    challenge_id: str,
    service: ChallengeService = Depends(get_challenge_service)
):
    """Delete a challenge (admin only)"""
    try:
        success = await service.delete_challenge(challenge_id)
        if not success:
            raise HTTPException(status_code=404, detail="Challenge not found")
        return JSONResponse(
            status_code=200,
            content={"message": "Challenge deleted successfully"}
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete challenge: {str(e)}")

@router.get("/challenges-stats")
async def get_challenge_statistics(
    service: ChallengeService = Depends(get_challenge_service)
):
    """Get challenge statistics"""
    try:
        stats = await service.get_challenge_statistics()
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch statistics: {str(e)}")

@router.get("/categories")
async def get_categories():
    """Get all available challenge categories"""
    return [{"value": cat.value, "label": cat.value.title()} for cat in ChallengeCategory]

@router.get("/difficulties")
async def get_difficulties():
    """Get all available difficulty levels"""
    return [{"value": diff.value, "label": diff.value.title()} for diff in DifficultyLevel]