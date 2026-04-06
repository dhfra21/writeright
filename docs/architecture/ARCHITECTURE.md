# Architecture Overview

## Project Structure

Monorepo containing a Flutter mobile app, an Express.js backend, and a React admin dashboard — all backed by Supabase.

```
ISS PROJECT/
├── mobile_app/        # Flutter mobile application
├── backend/           # Express.js REST API
├── admin-dashboard/   # React web admin panel
└── docs/              # Documentation
```

## Mobile App Architecture

### Layer Structure

1. **Presentation Layer** (`lib/screens/`, `lib/widgets/`, `lib/features/*/screens/`, `lib/features/*/widgets/`)
   - UI screens and reusable widgets
   - Material Design components

2. **Feature Layer** (`lib/features/`)
   - `handwriting_practice/` — drawing canvas, character templates, practice flow
   - `gamification/` — XP bar, badge display, achievements screen
   - `progress_tracking/` — progress screen, history
   - `parent_controls/` — settings screen, child management

3. **Service Layer** (`lib/services/`)
   - `ml_inference/` — `MLInferenceService` abstract interface with `DistanceBasedService` (on-device DTW) and `GroqVisionService` (cloud AI) implementations
   - `auth/` — Supabase Auth via direct REST calls
   - `children/` — child profile CRUD via backend API
   - `gamification/` — XP, level, badge logic synced to backend
   - `progress/` — practice session sync to backend
   - `storage/` — local SQLite + SharedPreferences
   - `tts/` — Typecast cloud TTS for voice feedback

4. **Core Layer** (`lib/core/`)
   - Constants, themes, validators, route names

5. **Models Layer** (`lib/models/`)
   - `badge.dart`, `handwriting_result.dart`, `user_progress.dart`

## ML Inference Architecture

### Current Implementation

Two concrete implementations behind the `MLInferenceService` abstract interface:

| Service | How it works | Requires |
|---------|-------------|---------|
| `DistanceBasedService` | Dynamic Time Warping (DTW) comparing drawn strokes to reference templates | Nothing — fully on-device |
| `GroqVisionService` | Sends canvas snapshot to Groq Vision AI for evaluation | `GROQ_API_KEY` |

Both return a `HandwritingResult` with a similarity score (0.0–1.0), star rating, and feedback text.

### Evaluation Flow

```
User draws on canvas
  → Stroke data captured
  → DistanceBasedService scores on-device (always)
  → GroqVisionService scores via API (if key configured)
  → Score → Gamification service (XP, stars, badges)
  → Progress synced to backend
  → TTS speaks feedback to child
```

## Backend Architecture

Express.js REST API serving the mobile app and admin dashboard.

- **Prefix**: `/api/v1`
- **Auth**: Supabase JWT verified by middleware (`src/middleware/auth.js`)
- **Pattern**: Routes → Controllers → Supabase client

### Endpoints

| Resource | Routes |
|----------|--------|
| Auth | `POST /auth/register` |
| Children | `GET/POST/PUT/DELETE /children` |
| Progress | `GET/POST /progress` |
| Gamification | `GET/POST /gamification` |

## Admin Dashboard Architecture

React SPA (Vite + Tailwind + shadcn/ui) connecting directly to Supabase.

- **Pages**: Dashboard, Users, Children, Analytics, Login
- **Auth**: Supabase Auth (admin accounts only)
- **Charts**: Recharts for analytics visualisations
- **Dev server**: `http://localhost:5173`

## Data Flow

```
Mobile App ──HTTP──► Backend API ──► Supabase (PostgreSQL)
                                         ▲
Admin Dashboard ────────────────────────┘ (direct Supabase client)
```

## Storage Strategy

- **Local-first**: SQLite and SharedPreferences for offline operation
- **Optional sync**: Progress metadata synced to Supabase when online
- **Privacy**: Handwriting stroke data never leaves the device

## Gamification System

- XP awarded per practice session (based on score)
- Level = `FLOOR(total_xp / 100) + 1`
- Stars per session: 0–3 (based on score thresholds)
- Badges for achievements (stored as JSONB in `game_progress`)
- Streak tracking (consecutive practice days)

## Security & Privacy

- No handwriting images stored or transmitted
- RLS on all Supabase tables — parents can only access their own children's data
- JWT required for all backend routes
- COPPA compliant: all data managed via parent accounts
- API keys injected at build time via `--dart-define`, never hardcoded
