# Setup & Build Instructions

## Initial Setup

### 1. Prerequisites

- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio** or **Xcode**: For mobile development
- **Git**: For version control

### 2. Clone Repository

```bash
git clone <repository-url>
cd "ISS PROJECT"
```

### 3. Run Setup Script

**Windows:**
```powershell
.\scripts\setup.ps1
```

**Linux/Mac:**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 4. Add ML Model

1. Obtain a pretrained handwriting recognition model:
   - TensorFlow Lite (.tflite) format, OR
   - ONNX (.onnx) format

2. Place the model file in `ml_models/pretrained/`

3. Recommended models:
   - TensorFlow Hub handwriting models
   - ONNX Model Zoo models
   - Custom trained models converted to TFLite/ONNX

### 5. Configure ML Inference

Edit `mobile_app/pubspec.yaml`:

**For TensorFlow Lite:**
```yaml
dependencies:
  tflite_flutter: ^0.10.0
```

**For ONNX Runtime:**
```yaml
dependencies:
  onnxruntime: ^1.0.0
```

Then run:
```bash
cd mobile_app
flutter pub get
```

### 6. Implement ML Service

Choose and implement one of:
- `lib/services/ml_inference/tflite_service.dart` (TensorFlow Lite)
- `lib/services/ml_inference/onnx_service.dart` (ONNX Runtime)

## Building the App

### Development Build

```bash
cd mobile_app
flutter run
```

### Android Release Build

```bash
cd mobile_app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS Release Build

```bash
cd mobile_app
flutter build ios --release
```

## Project Configuration

### Android Configuration

1. Update `mobile_app/android/app/build.gradle`:
   - Set `minSdkVersion` to 21 or higher
   - Configure signing for release builds

2. Update `mobile_app/android/app/src/main/AndroidManifest.xml`:
   - Add required permissions
   - Configure app metadata

### iOS Configuration

1. Update `mobile_app/ios/Runner/Info.plist`:
   - Add required permissions
   - Configure app metadata

2. Update `mobile_app/ios/Podfile` if needed for ML dependencies

## Troubleshooting

### Flutter Not Found

- Ensure Flutter is in your PATH
- Run `flutter doctor` to check installation

### ML Model Not Loading

- Verify model file is in correct location
- Check model format matches selected inference engine
- Review model loading code in service implementation

### Build Errors

- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter version compatibility

## Next Steps

After setup:
1. Implement ML inference service
2. Create UI screens
3. Add gamification logic
4. Test on physical devices
5. Configure backend (if using)
