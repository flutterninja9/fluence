Core Goal

“Let users build and experiment with Flutter challenges easily — focused on learning, not competition.”

🚀 Core MVP Features (Just the Essentials)
Feature	Purpose	Tool
Auth (Google/GitHub)	Identify users, save progress	Supabase Auth
Challenge List Page	Show all available challenges with difficulty tags	Supabase DB
Challenge Details Page	Contain: description, starter code, Monaco editor, “Run” button, output view	Flutter Web
Code Execution (Backend)	Run Dart/Flutter test scripts safely and return results	Cloud Run or Render.com container
Save Submission	Save last attempt per challenge	Supabase
Stripe Checkout (Pro)	Unlock advanced/premium challenges	Stripe + Supabase
Feedback Modal	“Was this challenge helpful?” → text feedback stored	Supabase table

That’s it.
No leaderboard, no timers, no streaks — just flow and learning.

🧠 Experience Philosophy

Keep it calm, beautiful, and educational.

Principle	Implementation
🧩 Curiosity over Competition	Remove rank-based UX. Add “Next Challenge” button instead.
💬 Supportive Tone	Use gentle success/error messages like “Good try! You’re close ✨”
🧘 No Timer / Anxiety	No “attempts” counter. Focus on “last saved attempt.”
📈 Progressive Unlocking	Free users get 3–4 open challenges, then hit paywall for deeper ones.
💡 Guided Hints	After 2 failed runs → show a soft hint or relevant Flutter doc link.
🧱 Architecture (Slimmed Down)
frontend/
 ├── lib/
 │   ├── main.dart
 │   ├── screens/
 │   │   ├── challenge_list.dart
 │   │   ├── challenge_detail.dart
 │   │   ├── profile.dart
 │   ├── widgets/
 │   └── services/
 │       ├── supabase_service.dart
 │       └── api_service.dart
backend/
 ├── api/
 │   ├── main.py (FastAPI)
 │   ├── routes/
 │   │   └── execute_code.py
 │   ├── utils/
 │       └── sandbox_runner.py (runs Flutter/Dart test)
supabase/
 ├── schema.sql
 ├── triggers/
 │   └── on_payment_success.sql

 Frontend dependencies:
 - supabase for auth + db
 - flutter_monaco for code editing
 - forui for UI components to give shadcn like feel
 - dio for HTTP requests
 - json_serializable for data models
 - go_router for navigation (it has nice redirects bound to a changenotifier we can use that wisely)

🧾 Database Schema (MVP)

Simplified version without gamification:

users
Field	Type	Notes
id	uuid	Supabase auth id
email	text	
name	text	
is_pro	boolean	via Stripe webhook
challenges
Field	Type	Notes
id	uuid	
title	text	
description	text	markdown supported
starter_code	text	default Dart code
test_script	text	what backend runs
is_premium	boolean	true for pro-only
submissions
Field	Type	Notes
id	uuid	
user_id	uuid	fk users
challenge_id	uuid	fk challenges
code	text	latest attempt
result	json	test output
created_at	timestamp	
feedback
Field	Type	Notes
id	uuid	
user_id	uuid	
challenge_id	uuid	
message	text	
🧭 Product Flow

1️⃣ Landing Page

“Master Flutter by solving bite-sized challenges.”

“Try Free” → no signup needed (anonymous access for 1 challenge).

“Sign in” for saving progress.

2️⃣ Challenge List

Free ones visible, premium ones blurred with lock icon.

Tag chips: “UI”, “State”, “Logic”, “Animation”.

3️⃣ Challenge Detail

Markdown-based description.

Monaco editor (with syntax highlighting).

“Run” button triggers backend execution.

Output box below.

Feedback emoji + text field at bottom.

4️⃣ Upgrade Page

Clean CTA with Stripe Checkout.

Maybe a line like: “Get deeper hands-on Flutter mastery — ₹299 early access”

⚡ Deployment Plan
Component	Host
Flutter Web frontend	Vercel / Netlify
Backend (FastAPI or Node)	Render / Cloud Run
Database + Auth	Supabase
Payments	Stripe
CI/CD	GitHub Actions (optional at MVP stage)
📈 MVP Validation Goals (First 30 days)

✅ 50 signups (auth via Supabase)

✅ 10 active daily users running code

✅ 2+ paying users (Stripe)

✅ >20 feedback submissions