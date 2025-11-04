# Supabase Setup Instructions

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up/login and create a new project
3. Choose a project name: "fluence" or "flutter-learning-platform"
4. Select a region close to your users
5. Generate a strong database password

## 2. Set up Database Schema

1. Go to the SQL Editor in your Supabase dashboard
2. Copy and paste the contents of `schema.sql`
3. Run the query to create all tables, functions, and policies

## 3. Seed Initial Data

1. In the SQL Editor, run the contents of `seed_data.sql`
2. This will create 5 sample challenges (3 free, 2 premium)

## 4. Configure Authentication

1. Go to Authentication > Settings
2. Enable the providers you want:
   - **Google OAuth**: Add your Google OAuth credentials
   - **GitHub OAuth**: Add your GitHub OAuth credentials
3. Add your site URL to the allowed redirect URLs:
   - For development: `http://localhost:3000`
   - For production: `https://yourdomain.com`

## 5. Get API Keys

1. Go to Settings > API
2. Copy these values for your backend `.env` file:
   - **Project URL**: `SUPABASE_URL`
   - **Anon Key**: `SUPABASE_ANON_KEY`
   - **Service Role Key**: `SUPABASE_SERVICE_ROLE_KEY` (keep this secret!)

## 6. Set up Row Level Security

The schema already includes RLS policies, but verify:
- Users can only see their own data
- Free challenges are visible to all
- Premium challenges only visible to pro users
- Submissions and feedback are user-specific

## 7. Test the Setup

Run these queries to verify everything works:

```sql
-- Test challenges
SELECT title, difficulty, is_premium FROM challenges ORDER BY sort_order;

-- Test user creation (after first login)
SELECT id, email, is_pro FROM users;
```

## 8. Environment Variables

Add these to your backend `.env` file:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## Additional Notes

- The database uses UUID for all primary keys
- Timestamps are automatically managed
- RLS policies ensure data security
- Functions are provided for common operations
- The schema supports the freemium model with `is_premium` flags