# CLAUDE.md - Project Guide for Claude Code

## Project Overview

Children's Handwriting Learning App — a monorepo containing a Flutter mobile app, an Express.js backend, ML model assets, and documentation. Children practice writing letters/numbers on a drawing canvas; an on-device ML model evaluates their handwriting; a gamification system rewards progress with XP, levels, stars, and badges.

## Tech Stack

### Mobile App (`mobile_app/`)
- **Language**: Dart
- **Framework**: Flutter (SDK >=3.0.0)
- **State Management**: Provider
- **Local Storage**: SQLite (`sqflite`), SharedPreferences
- **ML Inference**: TensorFlow Lite (`tflite_flutter`) or ONNX Runtime — abstracted behind `MLInferenceService` interface
- **Architecture**: Feature-based (features/, services/, models/, screens/, widgets/, core/)

### Backend (`backend/`)
- **Runtime**: Node.js (ES modules — `"type": "module"` in package.json)
- **Framework**: Express.js
- **Database**: Supabase (PostgreSQL with RLS)
- **Auth**: Supabase Auth (JWT-based, middleware in `src/middleware/auth.js`)
- **Security**: Helmet, CORS
- **API prefix**: `/api/v1`

### Database
- **Provider**: Supabase (PostgreSQL)
- **Tables**: accounts, children, game_progress, practice_sessions, character_mastery
- **Migrations**: `backend/supabase/migrations/` (numbered SQL files, run in order)
- **RLS**: Enabled on all tables — parents can only access their own children's data

## Project Structure

```
ISS PROJECT/
├── mobile_app/           # Flutter app
│   └── lib/
│       ├── core/         # Constants, theme, validators
│       ├── features/     # Feature modules (handwriting_practice, gamification, progress_tracking, parent_controls)
│       ├── services/     # ML inference, storage, gamification services
│       ├── models/       # Data models (badge, handwriting_result, user_progress)
│       ├── screens/      # Top-level screens (home, onboarding)
│       └── widgets/      # Reusable UI components
├── backend/              # Express.js API
│   └── src/
│       ├── config/       # App config, Supabase client
│       ├── controllers/  # Route handlers
│       ├── middleware/    # Auth, error handling
│       └── routes/       # API route definitions
├── ml_models/            # Pretrained ML models and character templates
├── docs/                 # Architecture, database, privacy docs
└── scripts/              # Setup scripts (setup.sh, setup.ps1)
```

## Common Commands

### Mobile App
```bash
cd mobile_app
flutter pub get          # Install dependencies
flutter run              # Run in debug mode
flutter test             # Run tests
flutter build apk --release   # Build Android release
flutter build ios --release    # Build iOS release
```

### Backend
```bash
cd backend
npm install              # Install dependencies
npm run dev              # Start with nodemon (development)
npm start                # Start server (production)
```

## Code Conventions

### Dart (Mobile App)
- Feature-based architecture: each feature has its own `screens/` and `widgets/` subdirectories
- Services use abstract interfaces for swappability (e.g., `MLInferenceService` base class with `TFLiteService`, `ONNXService`, `DistanceBasedService` implementations)
- Use `const` constructors where possible
- Models are plain Dart classes in `lib/models/`
- Validators live in `lib/core/utils/validators.dart`
- Route names defined in `lib/core/constants/route_names.dart`

### JavaScript (Backend)
- ES modules (`import`/`export`, not `require`)
- Controller pattern: routes delegate to controller functions
- Config loaded via `dotenv` in `src/config/index.js`
- Error handling through centralized middleware (`src/middleware/errorHandler.js`)
- Supabase client initialized in `src/config/supabase.js`

### SQL (Migrations)
- Migrations are numbered sequentially (001_, 002_, etc.)
- All tables have RLS policies
- Triggers auto-update `updated_at`, game progress, and character mastery

## Environment Variables

### Backend (`backend/.env`)
```
PORT=3000
NODE_ENV=development
API_VERSION=v1
ALLOWED_ORIGINS=http://localhost:3000
SUPABASE_URL=<supabase-project-url>
SUPABASE_ANON_KEY=<supabase-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<supabase-service-role-key>
```

## Key Design Decisions

- **Privacy-first**: No handwriting image data leaves the device. Only progress metadata syncs to the cloud.
- **Offline-first**: The app works fully offline. Cloud sync is optional and only covers progress data.
- **COPPA compliance**: All data is managed through parent accounts. No PII collected from children directly.
- **ML abstraction**: ML inference is behind an abstract service so the framework (TFLite, ONNX, or distance-based) can be swapped without changing consumers.
- **Immutable practice sessions**: `practice_sessions` rows cannot be updated (INSERT-only with RLS), ensuring data integrity.

## Important Files

- `mobile_app/lib/services/ml_inference/ml_inference_service.dart` — Abstract ML interface
- `mobile_app/lib/services/ml_inference/distance_based_service.dart` — MVP inference (no model needed)
- `mobile_app/lib/features/handwriting_practice/widgets/drawing_canvas.dart` — Core drawing widget
- `backend/src/server.js` — Express app entry point
- `backend/supabase/migrations/` — Database schema (run in order)
- `docs/architecture/ARCHITECTURE.md` — Full architecture overview
- `docs/database/DATABASE_SCHEMA.md` — Complete DB schema docs
