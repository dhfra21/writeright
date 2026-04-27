# API Keys Configuration

This document explains all the API keys required by the mobile app and what they're used for.

## Required API Keys in dart_defines.json

### 1. Backend & Database

**API_BASE_URL**
- **Purpose**: Base URL for your Express.js backend API
- **Used in**: All service files (auth, children, progress, gamification)
- **Values**:
  - Physical device (ADB): `http://localhost:3000/api/v1`
  - Android emulator: `http://10.0.2.2:3000/api/v1`
  - WiFi connection: `http://YOUR_IP:3000/api/v1`

**SUPABASE_URL**
- **Purpose**: Your Supabase project URL
- **Used in**: Authentication service ([lib/services/auth/auth_service.dart](lib/services/auth/auth_service.dart))
- **Example**: `https://kitcsauipthxzhiripqb.supabase.co`
- **Get it from**: [Supabase Dashboard](https://supabase.com/dashboard) → Project Settings → API

**SUPABASE_ANON_KEY**
- **Purpose**: Public anonymous key for Supabase client-side authentication
- **Used in**: Authentication service ([lib/services/auth/auth_service.dart](lib/services/auth/auth_service.dart))
- **Get it from**: [Supabase Dashboard](https://supabase.com/dashboard) → Project Settings → API

### 2. AI Services

**GROQ_API_KEY**
- **Purpose**: Groq AI API for handwriting evaluation and feedback
- **Used in**: Practice screen ([lib/features/handwriting_practice/screens/practice_screen.dart](lib/features/handwriting_practice/screens/practice_screen.dart:48))
- **Get it from**: [Groq Console](https://console.groq.com/keys)
- **Functionality**: Provides AI-powered feedback on children's handwriting practice

**TYPECAST_API_KEY**
- **Purpose**: Typecast TTS (Text-to-Speech) API for voice feedback
- **Used in**: TTS service ([lib/services/tts/tts_service.dart](lib/services/tts/tts_service.dart:12))
- **Get it from**: [Typecast.ai](https://typecast.ai/)
- **Functionality**: Generates natural-sounding voice feedback for children

---

## Current Configuration

Your [dart_defines.json](dart_defines.json) is currently configured with:

```json
{
  "API_BASE_URL": "http://localhost:3000/api/v1",
  "SUPABASE_URL": "https://YOUR_PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "your-supabase-anon-key",
  "GROQ_API_KEY": "your-groq-api-key",
  "TYPECAST_API_KEY": "your-typecast-api-key"
}
```

---

## Security Notes

⚠️ **IMPORTANT**:

1. **dart_defines.json is gitignored** - It contains sensitive API keys and should never be committed to version control
2. **Keys are compile-time constants** - Changes require app restart (Hot Restart or full rebuild)
3. **Keep your .env file** - [mobile_app/.env](mobile_app/.env) is also gitignored and contains the same keys
4. **Production**: For production builds, use environment-specific keys and consider using a secrets manager

---

## How It Works

When you run:
```bash
flutter run --dart-define-from-file=dart_defines.json
```

Flutter compiles these values into the app as `String.fromEnvironment()` constants. They are:
- Available at compile time
- Type-safe
- Cannot be changed at runtime
- Not exposed in plain text in the compiled app (though they can be extracted with effort)

---

## Troubleshooting

### "Missing API key" or null errors
- Make sure you're running with `--dart-define-from-file=dart_defines.json`
- Try a Hot Restart (`R`) or full rebuild if you changed the file

### API call failures
- Verify your API keys are valid and not expired
- Check API service status (Groq, Typecast, Supabase)
- For backend connection issues, see [DEVELOPMENT_SETUP.md](../DEVELOPMENT_SETUP.md)

### Adding new API keys
1. Add the key to [dart_defines.json](dart_defines.json)
2. Access it in code: `String.fromEnvironment('YOUR_KEY_NAME')`
3. Restart the app (Hot Restart won't work for new keys)
