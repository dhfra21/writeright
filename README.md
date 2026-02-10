# Children's Handwriting Learning App

A Flutter mobile application that helps children practice handwriting using pretrained machine learning models for on-device evaluation, combined with gamification and progress tracking.

## 🎯 Project Overview

This app enables children to practice writing letters and numbers with:
- **ML-Powered Evaluation**: On-device handwriting quality assessment
- **Gamification**: XP, levels, stars, and badges
- **Offline-First**: Works completely offline
- **Privacy-First**: No handwriting data leaves the device
- **Child-Safe**: Designed with child safety and privacy in mind

## 📁 Project Structure

```
ISS PROJECT/
├── mobile_app/              # Flutter mobile application
│   ├── lib/
│   │   ├── core/           # Core utilities, constants, themes
│   │   ├── features/        # Feature-based modules
│   │   │   ├── handwriting_practice/
│   │   │   ├── gamification/
│   │   │   ├── progress_tracking/
│   │   │   └── parent_controls/
│   │   ├── services/       # Business logic services
│   │   │   ├── ml_inference/
│   │   │   ├── storage/
│   │   │   └── gamification/
│   │   ├── models/         # Data models
│   │   ├── widgets/        # Reusable UI components
│   │   └── screens/        # App screens
│   └── assets/             # Images, animations, sounds, fonts
│
├── ml_models/              # Pretrained ML models
│   ├── pretrained/         # .tflite or .onnx model files
│   └── templates/          # Reference character templates
│
├── backend/                # Optional backend (no ML)
│   ├── api/                # API endpoints
│   └── config/             # Configuration files
│
├── docs/                   # Documentation
│   ├── architecture/       # Architecture docs
│   └── privacy/            # Privacy & safety docs
│
└── scripts/                # Build and utility scripts
```

## 🛠 Technology Stack

- **Frontend**: Flutter (Dart)
- **ML Inference**: TensorFlow Lite or ONNX Runtime
- **Storage**: SQLite (local), SharedPreferences
- **State Management**: Provider
- **Backend** (optional): Node.js/Python/Go

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Git

### Installation

1. Clone the repository
2. Navigate to `mobile_app/` directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Add pretrained ML model to `ml_models/pretrained/`
5. Update `pubspec.yaml` to include ML inference package:
   - For TensorFlow Lite: Uncomment `tflite_flutter`
   - For ONNX: Uncomment `onnxruntime`
6. Run the app:
   ```bash
   flutter run
   ```

## 📚 Documentation

- [Architecture Overview](docs/architecture/ARCHITECTURE.md)
- [Privacy & Child Safety](docs/privacy/PRIVACY.md)
- [ML Model Usage](docs/architecture/MODEL_USAGE.md)
- [Backend Documentation](backend/README.md)
- [ML Models Guide](ml_models/README.md)

## 🎮 Features

### Core Features

- **Handwriting Practice**: Draw letters and numbers on canvas
- **ML Evaluation**: Real-time handwriting quality assessment
- **Gamification**: Earn XP, level up, collect stars and badges
- **Progress Tracking**: View practice history and statistics
- **Parent Controls**: Settings and privacy controls

### Design Principles

- ✅ Offline-first architecture
- ✅ Privacy-by-default
- ✅ Child-safe UX
- ✅ Simple and intuitive interface
- ✅ Clear separation of concerns

## 🔒 Privacy & Security

- **No Data Collection**: Handwriting data never leaves the device
- **Local Storage**: All progress stored locally
- **Optional Sync**: Cloud sync only for progress metadata (with parent consent)
- **COPPA Compliant**: Child privacy protections built-in

## 🤖 ML Model Integration

### Supported Formats

- TensorFlow Lite (.tflite)
- ONNX (.onnx)
- Distance-based (no model required - MVP option)

### Model Requirements

- Input: Normalized stroke coordinates
- Output: Similarity score and correctness metrics
- Size: < 10MB recommended
- Latency: < 500ms inference time

### Model Recommendations

**See [ML Model Recommendations Guide](docs/architecture/ML_MODEL_RECOMMENDATIONS.md) for detailed suggestions.**

**Quick Start Options:**
1. **Distance-based approach** (no model) - Fastest to implement, good for MVP
2. **Lightweight CNN** (2-5MB) - Best balance of accuracy and size
3. **ML Kit Digital Ink** - Easy integration, but needs quality assessment layer

See [ML Model Usage Guide](docs/architecture/MODEL_USAGE.md) for implementation details.

## 📱 Platform Support

- Android (API 21+)
- iOS (iOS 12+)

## 🧪 Development

### Running Tests

```bash
cd mobile_app
flutter test
```

### Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🤝 Contributing

This is a private project. For contributions, please follow:
- Clean code principles
- Feature-based architecture
- Privacy-first approach
- Child safety considerations

## 📄 License

[Specify your license here]

## 🙏 Acknowledgments

- Flutter team
- TensorFlow Lite / ONNX Runtime communities
- Open-source handwriting recognition models

## 📞 Support

For issues or questions, please refer to the documentation or contact the development team.

---

**Note**: This project uses pretrained ML models only. No custom training or model retraining is performed. All ML inference happens on-device for privacy and offline functionality.
