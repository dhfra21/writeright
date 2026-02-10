# PowerShell setup script for Windows

Write-Host "Setting up Handwriting Learning App project..." -ForegroundColor Green

# Check Flutter installation
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Flutter is not installed. Please install Flutter first." -ForegroundColor Red
    exit 1
}

# Navigate to mobile app directory
Set-Location mobile_app

# Install Flutter dependencies
Write-Host "Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

# Create necessary directories if they don't exist
Write-Host "Creating asset directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path assets/images | Out-Null
New-Item -ItemType Directory -Force -Path assets/animations | Out-Null
New-Item -ItemType Directory -Force -Path assets/sounds | Out-Null
New-Item -ItemType Directory -Force -Path assets/fonts | Out-Null

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Add pretrained ML model to ..\ml_models\pretrained\" -ForegroundColor White
Write-Host "2. Update pubspec.yaml to include ML inference package" -ForegroundColor White
Write-Host "3. Run 'flutter run' to start the app" -ForegroundColor White
