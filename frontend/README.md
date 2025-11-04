# frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

# Flutter Frontend

Flutter web application for the Fluence learning platform.

## Setup

1. Install Flutter (if not already installed)
2. Install dependencies:
```bash
flutter pub get
```

3. Copy environment variables:
```bash
cp .env.example .env
```

4. Update `.env` with your Supabase credentials

5. Run the development server:
```bash
flutter run -d web-server --web-port 3000
```

## Environment Variables

Create a `.env` file with:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key
- `API_BASE_URL`: Backend API URL (default: http://localhost:8000/api)

## Features

- ✅ Authentication with Google/GitHub
- ✅ Challenge browsing and solving
- ✅ Code editor with syntax highlighting
- ✅ Real-time code execution
- ✅ Progress saving
- ✅ Responsive design

## Tech Stack

- Flutter Web
- Riverpod (State Management)
- Go Router (Navigation)
- Supabase (Backend/Auth)
- Code Text Field (Code Editor)
- Flutter Markdown (Rich Text)

## Development

Run with environment variables:
```bash
flutter run -d web-server --web-port 3000 --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```
