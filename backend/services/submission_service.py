from typing import List, Optional
from supabase import create_client, Client
from config import settings
from models.submission import Submission, SubmissionCreate

class SubmissionService:
    def __init__(self):
        self.supabase: Client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_SERVICE_ROLE_KEY
        )

    async def create_submission(self, submission: SubmissionCreate, user_id: str) -> Submission:
        """Create a new submission"""
        submission_data = submission.dict()
        submission_data["user_id"] = user_id
        
        response = self.supabase.table("submissions").insert(submission_data).execute()
        return Submission(**response.data[0])

    async def get_user_submissions(self, user_id: str, challenge_id: Optional[str] = None) -> List[Submission]:
        """Get submissions for a user, optionally filtered by challenge"""
        query = self.supabase.table("submissions").select("*").eq("user_id", user_id)
        
        if challenge_id:
            query = query.eq("challenge_id", challenge_id)
        
        response = query.order("created_at", desc=True).execute()
        return [Submission(**item) for item in response.data]

    async def get_latest_submission(self, user_id: str, challenge_id: str) -> Optional[Submission]:
        """Get the latest submission for a user and challenge"""
        response = (
            self.supabase.table("submissions")
            .select("*")
            .eq("user_id", user_id)
            .eq("challenge_id", challenge_id)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
        
        if not response.data:
            return None
        
        return Submission(**response.data[0])

    async def get_successful_submissions_count(self, user_id: str) -> int:
        """Get count of successful submissions for a user"""
        response = (
            self.supabase.table("submissions")
            .select("id")
            .eq("user_id", user_id)
            .eq("is_successful", True)
            .execute()
        )
        
        return len(response.data)