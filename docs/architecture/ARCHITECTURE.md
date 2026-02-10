# Architecture Overview

## Project Structure

This is a monorepo-style project for a children's handwriting learning mobile application.

```
ISS PROJECT/
├── mobile_app/          # Flutter mobile application
├── ml_models/           # Pretrained ML models and templates
├── backend/             # Optional backend for sync (no ML)
├── docs/                # Documentation
└── scripts/             # Build and utility scripts
```

## Mobile App Architecture

### Layer Structure

1. **Presentation Layer** (`lib/screens/`, `lib/widgets/`)
   - UI screens and reusable widgets
   - Material Design components

2. **Feature Layer** (`lib/features/`)
   - Feature-based organization
   - Each feature contains its own screens, widgets, and logic

3. **Service Layer** (`lib/services/`)
   - ML Inference Service (abstracted)
   - Storage Services (local + optional cloud)
   - Gamification Service

4. **Core Layer** (`lib/core/`)
   - Constants, themes, utilities
   - Shared business logic

5. **Models Layer** (`lib/models/`)
   - Data models and entities

## ML Inference Architecture

### Design Principles

- **Abstraction**: ML logic is abstracted behind `MLInferenceService` interface
- **Offline-First**: All inference happens on-device
- **No Training**: Only pretrained models are used
- **Privacy**: No data collection for ML purposes

### Implementation Options

- **TensorFlow Lite**: `TFLiteService` implementation
- **ONNX Runtime**: `ONNXService` implementation

### Flow

1. User draws character on canvas
2. Stroke data is normalized
3. ML service evaluates handwriting
4. Score and feedback are returned
5. Gamification service processes results

## Data Flow

```
User Input → Drawing Canvas → Stroke Normalization → ML Inference → 
Score Calculation → Gamification → Progress Storage → UI Update
```

## Storage Strategy

- **Local-First**: All data stored locally using SQLite/SharedPreferences
- **Optional Sync**: Cloud sync for multi-device support
- **Privacy**: No handwriting data leaves device (only progress metadata)

## Gamification System

- XP points for practice
- Level progression
- Stars per character (1-3 stars)
- Badges for achievements
- Progress tracking

## Security & Privacy

- No handwriting data sent to servers
- Local-only storage by default
- Parent controls for data sharing
- COPPA compliance considerations

## Scalability Considerations

- Feature-based architecture allows easy feature additions
- Service abstraction allows ML framework switching
- Modular design supports future enhancements
