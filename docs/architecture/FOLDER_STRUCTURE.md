# Complete Folder Structure

```
ISS PROJECT/
│
├── 📱 mobile_app/                          # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart                       # App entry point
│   │   │
│   │   ├── core/                           # Core utilities & shared code
│   │   │   ├── constants/
│   │   │   │   ├── app_constants.dart      # App-wide constants
│   │   │   │   └── route_names.dart        # Route name constants
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart          # Theme configuration
│   │   │   └── utils/
│   │   │       └── validators.dart         # Input validators
│   │   │
│   │   ├── features/                       # Feature-based modules
│   │   │   ├── handwriting_practice/       # Handwriting practice feature
│   │   │   │   ├── screens/
│   │   │   │   │   └── practice_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── drawing_canvas.dart
│   │   │   │       └── character_template.dart
│   │   │   │
│   │   │   ├── gamification/               # Gamification feature
│   │   │   │   ├── screens/
│   │   │   │   │   └── achievements_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── xp_bar.dart
│   │   │   │       └── badge_display.dart
│   │   │   │
│   │   │   ├── progress_tracking/          # Progress tracking feature
│   │   │   │   └── screens/
│   │   │   │       └── progress_screen.dart
│   │   │   │
│   │   │   └── parent_controls/            # Parent controls feature
│   │   │       └── screens/
│   │   │           └── settings_screen.dart
│   │   │
│   │   ├── services/                       # Business logic services
│   │   │   ├── ml_inference/               # ML Inference layer
│   │   │   │   ├── ml_inference_service.dart    # Abstract interface
│   │   │   │   ├── tflite_service.dart         # TensorFlow Lite impl
│   │   │   │   └── onnx_service.dart           # ONNX Runtime impl
│   │   │   │
│   │   │   ├── storage/                     # Storage services
│   │   │   │   ├── local_storage_service.dart
│   │   │   │   └── cloud_sync_service.dart
│   │   │   │
│   │   │   └── gamification/               # Gamification logic
│   │   │       └── gamification_service.dart
│   │   │
│   │   ├── models/                         # Data models
│   │   │   ├── user_progress.dart
│   │   │   ├── handwriting_result.dart
│   │   │   └── badge.dart
│   │   │
│   │   ├── widgets/                        # Reusable UI components
│   │   │   └── common/
│   │   │       ├── app_button.dart
│   │   │       └── app_card.dart
│   │   │
│   │   └── screens/                        # App-level screens
│   │       ├── home_screen.dart
│   │       └── onboarding_screen.dart
│   │
│   ├── assets/                             # App assets
│   │   ├── images/                         # Images & icons
│   │   ├── animations/                     # Lottie/animations
│   │   ├── sounds/                         # Sound effects
│   │   └── fonts/                          # Custom fonts
│   │
│   ├── pubspec.yaml                        # Flutter dependencies
│   └── .gitignore                          # Git ignore rules
│
├── 🤖 ml_models/                          # Pretrained ML Models
│   ├── pretrained/                         # Model files (.tflite, .onnx)
│   │   └── .gitkeep
│   ├── templates/                          # Reference templates
│   │   └── .gitkeep
│   └── README.md                           # Model documentation
│
├── 🌐 backend/                             # Optional Backend (No ML)
│   ├── api/                                # API endpoints
│   │   └── .gitkeep
│   ├── config/                             # Configuration
│   │   └── .gitkeep
│   └── README.md                           # Backend documentation
│
├── 📚 docs/                                # Documentation
│   ├── architecture/
│   │   ├── ARCHITECTURE.md                 # Architecture overview
│   │   ├── MODEL_USAGE.md                  # ML model usage guide
│   │   ├── SETUP.md                        # Setup instructions
│   │   └── FOLDER_STRUCTURE.md             # This file
│   └── privacy/
│       └── PRIVACY.md                      # Privacy & safety docs
│
├── 🔧 scripts/                             # Utility scripts
│   ├── setup.sh                            # Linux/Mac setup
│   └── setup.ps1                           # Windows setup
│
├── README.md                               # Project README
└── .gitignore                              # Root git ignore
```

## Folder Descriptions

### mobile_app/
The Flutter mobile application. Organized with:
- **Feature-based architecture**: Each feature is self-contained
- **Clear separation**: UI, business logic, and data models are separated
- **Scalable structure**: Easy to add new features

### ml_models/
Contains pretrained ML models and reference templates:
- **pretrained/**: Model files for on-device inference
- **templates/**: Reference images/templates for characters

### backend/
Optional backend service (no ML):
- **api/**: REST/GraphQL endpoints
- **config/**: Environment and configuration files
- Used only for progress sync and app configuration

### docs/
Comprehensive documentation:
- Architecture decisions
- Privacy and safety policies
- Setup and usage guides

### scripts/
Utility scripts for project setup and maintenance

## Key Design Decisions

1. **Monorepo Structure**: All related code in one repository
2. **Feature-Based**: Mobile app organized by features, not layers
3. **Service Abstraction**: ML inference abstracted behind interface
4. **Offline-First**: Local storage prioritized
5. **Privacy-First**: No handwriting data in backend

## Scalability Notes

- **Adding Features**: Create new folder in `lib/features/`
- **Adding ML Models**: Place in `ml_models/pretrained/`
- **Backend Expansion**: Add endpoints in `backend/api/`
- **New Platforms**: Flutter supports web/desktop if needed
