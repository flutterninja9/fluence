from fastapi import APIRouter, HTTPException, Depends, Header
from typing import List, Optional
from models.submission import Submission, SubmissionCreate
from services.submission_service import SubmissionService

router = APIRouter()

def get_submission_service() -> SubmissionService:
    return SubmissionService()

# For now, we'll use a simple header-based auth (in production, use proper JWT)
def get_current_user_id(x_user_id: str = Header(...)) -> str:
    """Extract user ID from header (temporary auth solution)"""
    return x_user_id

@router.post("/submissions", response_model=Submission)
async def create_submission(
    submission: SubmissionCreate,
    user_id: str = Depends(get_current_user_id),
    service: SubmissionService = Depends(get_submission_service)
):
    """Create a new code submission"""
    try:
        result = await service.create_submission(submission, user_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create submission: {str(e)}")

@router.get("/submissions", response_model=List[Submission])
async def get_user_submissions(
    challenge_id: Optional[str] = None,
    user_id: str = Depends(get_current_user_id),
    service: SubmissionService = Depends(get_submission_service)
):
    """Get submissions for the current user"""
    try:
        submissions = await service.get_user_submissions(user_id, challenge_id)
        return submissions
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch submissions: {str(e)}")

@router.get("/submissions/latest/{challenge_id}", response_model=Optional[Submission])
async def get_latest_submission(
    challenge_id: str,
    user_id: str = Depends(get_current_user_id),
    service: SubmissionService = Depends(get_submission_service)
):
    """Get the latest submission for a challenge"""
    try:
        submission = await service.get_latest_submission(user_id, challenge_id)
        return submission
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch submission: {str(e)}")

@router.get("/submissions/stats")
async def get_submission_stats(
    user_id: str = Depends(get_current_user_id),
    service: SubmissionService = Depends(get_submission_service)
):
    """Get submission statistics for the current user"""
    try:
        successful_count = await service.get_successful_submissions_count(user_id)
        return {
            "successful_submissions": successful_count,
            "user_id": user_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch stats: {str(e)}")