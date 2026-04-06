# Complete Folder Structure

```
ISS PROJECT/
│
├── mobile_app/                              # Flutter Mobile Application
│   ├── .env                                 # API keys & URLs (not committed)
│   ├── run_dev.sh                           # Launch script (loads .env → --dart-define)
│   ├── pubspec.yaml                         # Flutter dependencies
│   │
│   ├── lib/
│   │   ├── main.dart                        # App entry point
│   │   │
│   │   ├── core/                            # Shared utilities
│   │   │   ├── constants/
│   │   │   │   ├── app_constants.dart
│   │   │   │   └── route_names.dart
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart
│   │   │   └── utils/
│   │   │       └── validators.dart
│   │   │
│   │   ├── features/                        # Feature modules
│   │   │   ├── handwriting_practice/
│   │   │   │   ├── screens/
│   │   │   │   │   └── practice_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── drawing_canvas.dart
│   │   │   │       └── character_template.dart
│   │   │   │
│   │   │   ├── gamification/
│   │   │   │   ├── screens/
│   │   │   │   │   └── achievements_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── xp_bar.dart
│   │   │   │       └── badge_display.dart
│   │   │   │
│   │   │   ├── progress_tracking/
│   │   │   │   └── screens/
│   │   │   │       └── progress_screen.dart
│   │   │   │
│   │   │   └── parent_controls/
│   │   │       └── screens/
│   │   │           └── settings_screen.dart
│   │   │
│   │   ├── services/                        # Business logic
│   │   │   ├── ml_inference/
│   │   │   │   ├── ml_inference_service.dart     # Abstract interface
│   │   │   │   ├── distance_based_service.dart   # On-device DTW (default)
│   │   │   │   └── groq_vision_service.dart      # Groq Vision AI (cloud)
│   │   │   │
│   │   │   ├── auth/
│   │   │   │   └── auth_service.dart             # Supabase Auth REST
│   │   │   │
│   │   │   ├── children/
│   │   │   │   └── children_service.dart         # Child profile CRUD
│   │   │   │
│   │   │   ├── gamification/
│   │   │   │   └── gamification_service.dart     # XP, levels, badges
│   │   │   │
│   │   │   ├── progress/
│   │   │   │   └── progress_service.dart         # Session sync
│   │   │   │
│   │   │   ├── storage/
│   │   │   │   └── local_storage_service.dart    # SQLite + SharedPrefs
│   │   │   │
│   │   │   └── tts/
│   │   │       └── tts_service.dart              # Typecast cloud TTS
│   │   │
│   │   ├── models/
│   │   │   ├── badge.dart
│   │   │   ├── handwriting_result.dart
│   │   │   └── user_progress.dart
│   │   │
│   │   ├── widgets/
│   │   │   └── common/
│   │   │       ├── app_button.dart
│   │   │       └── app_card.dart
│   │   │
│   │   └── screens/
│   │       ├── home_screen.dart
│   │       ├── onboarding_screen.dart
│   │       └── parent_dashboard_screen.dart
│   │
│   ├── assets/
│   │   ├── images/
│   │   ├── animations/
│   │   ├── sounds/
│   │   └── fonts/
│   │
│   └── android/                             # Android platform config
│
├── backend/                                 # Express.js REST API
│   ├── .env                                 # Server config & secrets (not committed)
│   ├── package.json
│   └── src/
│       ├── server.js                        # Entry point
│       ├── config/
│       │   ├── index.js                     # Config loader (dotenv)
│       │   └── supabase.js                  # Supabase client
│       ├── controllers/
│       │   ├── authController.js
│       │   ├── childrenController.js
│       │   ├── progressController.js
│       │   └── gamificationController.js
│       ├── middleware/
│       │   ├── auth.js                      # JWT verification
│       │   └── errorHandler.js
│       ├── routes/
│       │   ├── auth.js
│       │   ├── children.js
│       │   ├── progress.js
│       │   └── gamification.js
│       └── supabase/
│           └── migrations/                  # SQL migration files (001–007)
│
├── admin-dashboard/                         # React Admin Panel
│   ├── .env                                 # Supabase keys (not committed)
│   ├── package.json
│   └── src/
│       ├── main.jsx
│       ├── App.jsx
│       ├── pages/
│       │   ├── Login.jsx
│       │   ├── Dashboard.jsx
│       │   ├── Users.jsx
│       │   ├── Children.jsx
│       │   └── Analytics.jsx
│       ├── components/
│       │   ├── Sidebar.jsx
│       │   ├── StatCard.jsx
│       │   └── ui/                          # shadcn/ui components
│       ├── contexts/
│       │   └── AuthContext.jsx
│       └── lib/
│           ├── supabase.js
│           ├── api.js
│           └── utils.js
│
└── docs/                                    # Documentation
    ├── architecture/
    │   ├── ARCHITECTURE.md
    │   ├── FOLDER_STRUCTURE.md              # This file
    │   ├── MODEL_USAGE.md
    │   └── SETUP.md
    ├── database/
    │   ├── DATABASE_SCHEMA.md
    │   └── SUPABASE_SETUP.md
    ├── privacy/
    │   └── PRIVACY.md
    └── use_case_diagram.puml
```

## Key Design Decisions

1. **Monorepo** — mobile, backend, and admin in one repository
2. **Feature-based mobile architecture** — each feature is self-contained
3. **ML abstraction** — `MLInferenceService` interface allows swapping inference engines without touching consumers
4. **Offline-first** — local SQLite storage with optional cloud sync
5. **Privacy-first** — no handwriting data leaves the device; only scores and metadata sync
6. **`--dart-define` for secrets** — API keys injected at build time, never hardcoded
