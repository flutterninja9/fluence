from typing import List, Optional, Dict, Any
from supabase import create_client, Client
from config import settings
from models.challenge import Challenge, ChallengeCreate, ChallengeUpdate, ChallengeFilters, ChallengeList

class ChallengeService:
    def __init__(self):
        self.supabase: Client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_SERVICE_ROLE_KEY
        )

    async def get_challenges(
        self, 
        filters: ChallengeFilters,
        user_is_pro: bool = False
    ) -> ChallengeList:
        """Get challenges with filtering and pagination"""
        
        # Build query
        query = self.supabase.table("challenges").select("*")
        
        # Apply filters
        if filters.difficulty:
            query = query.eq("difficulty", filters.difficulty)
        
        if filters.category:
            query = query.eq("category", filters.category)
        
        if filters.is_premium is not None:
            query = query.eq("is_premium", filters.is_premium)
        elif not user_is_pro:
            # If user is not pro, only show free challenges
            query = query.eq("is_premium", False)
        
        if filters.search:
            query = query.ilike("title", f"%{filters.search}%")
        
        # Get total count
        total_response = query.execute()
        total = len(total_response.data)
        
        # Apply pagination
        offset = (filters.page - 1) * filters.per_page
        query = query.order("sort_order").range(offset, offset + filters.per_page - 1)
        
        response = query.execute()
        
        challenges = [Challenge(**item) for item in response.data]
        
        return ChallengeList(
            challenges=challenges,
            total=total,
            page=filters.page,
            per_page=filters.per_page,
            has_next=offset + filters.per_page < total,
            has_prev=filters.page > 1
        )

    async def get_challenge_by_id(self, challenge_id: str) -> Optional[Challenge]:
        """Get a single challenge by ID"""
        response = self.supabase.table("challenges").select("*").eq("id", challenge_id).execute()
        
        if not response.data:
            return None
        
        return Challenge(**response.data[0])

    async def create_challenge(self, challenge: ChallengeCreate) -> Challenge:
        """Create a new challenge"""
        challenge_data = challenge.dict()
        response = self.supabase.table("challenges").insert(challenge_data).execute()
        
        return Challenge(**response.data[0])

    async def update_challenge(self, challenge_id: str, challenge: ChallengeUpdate) -> Optional[Challenge]:
        """Update an existing challenge"""
        # Only include non-None fields
        update_data = {k: v for k, v in challenge.dict().items() if v is not None}
        
        if not update_data:
            # Nothing to update
            return await self.get_challenge_by_id(challenge_id)
        
        response = self.supabase.table("challenges").update(update_data).eq("id", challenge_id).execute()
        
        if not response.data:
            return None
        
        return Challenge(**response.data[0])

    async def delete_challenge(self, challenge_id: str) -> bool:
        """Delete a challenge"""
        response = self.supabase.table("challenges").delete().eq("id", challenge_id).execute()
        return len(response.data) > 0

    async def get_challenge_statistics(self) -> Dict[str, Any]:
        """Get challenge statistics"""
        # Total challenges
        total_response = self.supabase.table("challenges").select("id").execute()
        total_challenges = len(total_response.data)
        
        # By difficulty
        difficulty_stats = {}
        for difficulty in ["easy", "medium", "hard"]:
            response = self.supabase.table("challenges").select("id").eq("difficulty", difficulty).execute()
            difficulty_stats[difficulty] = len(response.data)
        
        # By category
        category_response = self.supabase.table("challenges").select("category").execute()
        category_stats = {}
        for item in category_response.data:
            category = item["category"]
            category_stats[category] = category_stats.get(category, 0) + 1
        
        # Premium vs Free
        premium_response = self.supabase.table("challenges").select("id").eq("is_premium", True).execute()
        premium_count = len(premium_response.data)
        free_count = total_challenges - premium_count
        
        return {
            "total_challenges": total_challenges,
            "difficulty_breakdown": difficulty_stats,
            "category_breakdown": category_stats,
            "premium_count": premium_count,
            "free_count": free_count
        }