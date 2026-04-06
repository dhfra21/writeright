# Setup & Build Instructions

## Prerequisites

- Flutter SDK >= 3.0.0
- Node.js >= 18
- Android Studio (for Android builds)
- A physical Android device or emulator
- Git

## 1. Clone the Repository

```bash
git clone <repository-url>
cd "ISS PROJECT"
```

## 2. Backend Setup

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
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

Start the backend:
```bash
npm run dev     # development (nodemon)
npm start       # production
```

## 3. Admin Dashboard Setup

```bash
cd admin-dashboard
npm install
npm run dev     # runs at http://localhost:5173
```

Create `admin-dashboard/.env`:
```
VITE_SUPABASE_URL=<your-supabase-url>
VITE_SUPABASE_ANON_KEY=<your-anon-key>
```

## 4. Mobile App Setup

```bash
cd mobile_app
flutter pub get
```

Create `mobile_app/.env`:
```
# Physical device: use your machine's local WiFi IP
API_BASE_URL=http://192.168.x.x:3000/api/v1

# Android emulator only:
# API_BASE_URL=http://10.0.2.2:3000/api/v1

SUPABASE_URL=<your-supabase-url>
SUPABASE_ANON_KEY=<your-anon-key>
GROQ_API_KEY=<your-groq-key>           # optional
TYPECAST_API_KEY=<your-typecast-key>   # optional
```

> **Note:** `String.fromEnvironment` reads values injected via `--dart-define` at build time, not from `.env` at runtime. The `.env` file is a reference for the `run_dev.sh` script.

Run on a connected Android device:
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

Find your device ID:
```bash
flutter devices
```

## 5. Database Migrations

Run migrations in order via the Supabase dashboard SQL editor or CLI:

```
backend/supabase/migrations/001_accounts_table.sql
backend/supabase/migrations/002_children_table.sql
backend/supabase/migrations/003_game_progress_table.sql
backend/supabase/migrations/004_practice_sessions_table.sql
backend/supabase/migrations/005_character_mastery_table.sql
backend/supabase/migrations/006_rls_policies.sql
backend/supabase/migrations/007_functions_and_triggers.sql
```

See [SUPABASE_SETUP.md](../database/SUPABASE_SETUP.md) for full details.

## Building for Production

```bash
# Android APK
cd mobile_app
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-backend.com/api/v1 \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_ANON_KEY=<key> \
  --dart-define=GROQ_API_KEY=<key> \
  --dart-define=TYPECAST_API_KEY=<key>
# Output: build/app/outputs/flutter-apk/app-release.apk

# iOS
flutter build ios --release ...
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `nodemon not found` | Run `npm install` in `backend/` |
| `unable to find directory entry in pubspec.yaml: assets/...` | Run `mkdir -p assets/images assets/animations assets/sounds assets/fonts` in `mobile_app/` |
| Gradle `Access is denied` on `.bin` file | Run `taskkill //F //IM java.exe` then retry |
| `TimeoutException` on register/login | App is hitting wrong IP — update `API_BASE_URL` in `mobile_app/.env` to match your machine's current WiFi IP (`ipconfig`) |
| `flutter run` asks for Developer Mode | Run `start ms-settings:developers` and enable Developer Mode |
| TTS silent | `TYPECAST_API_KEY` not set — add to `.env` and re-run `bash run_dev.sh` |
| Groq evaluation not working | `GROQ_API_KEY` not set — add to `.env` and re-run `bash run_dev.sh` |
