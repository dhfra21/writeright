#!/bin/bash
# Setup script for the project

echo "Setting up Handwriting Learning App project..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Navigate to mobile app directory
cd mobile_app || exit

# Install Flutter dependencies
echo "Installing Flutter dependencies..."
flutter pub get

# Create necessary directories if they don't exist
echo "Creating asset directories..."
mkdir -p assets/images
mkdir -p assets/animations
mkdir -p assets/sounds
mkdir -p assets/fonts

echo "Setup complete!"
echo "Next steps:"
echo "1. Add pretrained ML model to ../ml_models/pretrained/"
echo "2. Update pubspec.yaml to include ML inference package"
echo "3. Run 'flutter run' to start the app"
