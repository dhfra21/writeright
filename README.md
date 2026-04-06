# Children's Handwriting Learning App

A Flutter mobile application that helps children practice handwriting using AI-powered evaluation, gamification, and progress tracking — with a Node.js/Supabase backend for cloud sync.

## Project Overview

Children practice writing letters and numbers on a drawing canvas. Their strokes are evaluated by an on-device distance-based algorithm and optionally by Groq Vision AI. A gamification system rewards progress with XP, levels, stars, and badges. Parents manage accounts and monitor progress via a parent dashboard.

## Project Structure

```
ISS PROJECT/
├── mobile_app/              # Flutter mobile application
│   ├── lib/
│   │   ├── core/            # Constants, theme, validators, route names
│   │   ├── features/        # Feature modules
│   │   │   ├── handwriting_practice/
│   │   │   ├── gamification/
│   │   │   ├── progress_tracking/
│   │   │   └── parent_controls/
│   │   ├── services/        # Business logic services
│   │   │   ├── ml_inference/  # DistanceBasedService + GroqVisionService
│   │   │   ├── auth/          # Supabase Auth via REST
│   │   │   ├── children/      # Child profile management
│   │   │   ├── gamification/  # XP, levels, badges
│   │   │   ├── progress/      # Practice session sync
│   │   │   ├── storage/       # Local SQLite + SharedPreferences
│   │   │   └── tts/           # Typecast cloud TTS
│   │   ├── models/          # Data models (badge, handwriting_result, user_progress)
│   │   ├── widgets/         # Reusable UI components
│   │   └── screens/         # Top-level screens (home, onboarding, parent dashboard)
│   └── assets/              # Images, animations, sounds, fonts
│
├── backend/                 # Express.js REST API
│   └── src/
│       ├── config/          # App config, Supabase client
│       ├── controllers/     # Route handlers (auth, children, progress, gamification)
│       ├── middleware/       # JWT auth, error handling
│       └── routes/          # API route definitions (/api/v1/*)
│
├── admin-dashboard/         # React web admin panel
│   └── src/
│       ├── pages/           # Dashboard, Users, Children, Analytics, Login
│       ├── components/      # Sidebar, StatCard, shadcn/ui components
│       ├── contexts/        # AuthContext
│       └── lib/             # Supabase client, API helpers
│
└── docs/                    # Architecture, database schema, privacy docs
```

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart), Provider state management |
| Local storage | SQLite (`sqflite`), SharedPreferences |
| ML evaluation | Distance-based (on-device) + Groq Vision API |
| Text-to-speech | Typecast cloud TTS API |
| Backend | Node.js, Express.js (ES modules) |
| Admin dashboard | React 19, Vite, Tailwind CSS, shadcn/ui, Recharts |
| Database | Supabase (PostgreSQL + RLS) |
| Auth | Supabase Auth (JWT) |

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Node.js (>=18)
- Android Studio (for Android development)
- A physical Android device or emulator

### 1. Backend setup

```bash
cd backend
npm install
```

Create `backend/.env`:
```
PORT=3000
NODE_ENV=development
API_VERSION=v1
SUPABASE_URL=<your-supabase-url>
SUPABASE_ANON_KEY=<your-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
ALLOWED_ORIGINS=http://localhost:3000
```

Start the backend:
```bash
npm run dev
```

### 2. Mobile app setup

```bash
cd mobile_app
flutter pub get
```

Create `mobile_app/.env`:
```
# For physical device: use your machine's local WiFi IP
API_BASE_URL=http://192.168.x.x:3000/api/v1

# For Android emulator only:
# API_BASE_URL=http://10.0.2.2:3000/api/v1

SUPABASE_URL=<your-supabase-url>
SUPABASE_ANON_KEY=<your-anon-key>
GROQ_API_KEY=<your-groq-key>          # optional, for AI handwriting evaluation
TYPECAST_API_KEY=<your-typecast-key>  # optional, for voice feedback
```

Run the app (env vars are passed via `--dart-define`):
```bash
bash run_dev.sh
```

Or manually:
```bash
flutter run -d <device-id> \
  --dart-define=API_BASE_URL=http://192.168.x.x:3000/api/v1 \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_ANON_KEY=<key> \
  --dart-define=GROQ_API_KEY=<key> \
  --dart-define=TYPECAST_API_KEY=<key>
```

## Features

- **Handwriting Practice** — Draw letters and numbers on an interactive canvas
- **AI Evaluation** — On-device distance-based scoring; optional Groq Vision for richer feedback
- **Gamification** — XP, levels, stars, and badge system
- **Progress Tracking** — Practice history synced to Supabase
- **Voice Feedback** — Encouraging audio feedback via Typecast TTS
- **Parent Dashboard** — Manage children, view progress, control settings
- **Offline-first** — Full functionality without internet; sync when connected

### 3. Admin dashboard setup

```bash
cd admin-dashboard
npm install
npm run dev
```

The dashboard runs at `http://localhost:5173` and connects directly to Supabase. It provides:
- User and parent account management
- Child profile overview
- Progress analytics with charts
- Practice session data

## Platform Support

- Android (API 21+)
- iOS (iOS 12+)

## Documentation

- [Architecture Overview](docs/architecture/ARCHITECTURE.md)
- [Database Schema](docs/database/DATABASE_SCHEMA.md)
- [Supabase Setup](docs/database/SUPABASE_SETUP.md)
- [Privacy & Child Safety](docs/privacy/PRIVACY.md)

## Privacy & Security

- Handwriting stroke data never leaves the device
- Only progress metadata (scores, XP, timestamps) syncs to the cloud
- All child data is managed through parent accounts — no PII collected from children
- COPPA-compliant by design
- Supabase RLS ensures parents can only access their own children's data
