# Development Setup Guide

## Backend Connection for Physical Android Devices

### The Problem
When running your Flutter app on a physical device, it needs to connect to your backend server running on your computer. There are different approaches depending on your network setup.

---

## ✅ RECOMMENDED: ADB Reverse Tunneling

**This is the best approach for physical devices** - it works regardless of IP changes and doesn't require WiFi configuration.

### How it works:
ADB creates a tunnel so your phone's `localhost:3000` points to your computer's `localhost:3000`.

### Setup:

1. **Configure dart_defines.json** to use localhost:
```json
{
  "API_BASE_URL": "http://localhost:3000/api/v1",
  "SUPABASE_URL": "https://kitcsauipthxzhiripqb.supabase.co",
  "SUPABASE_ANON_KEY": "your_anon_key_here",
  "GROQ_API_KEY": "your_groq_api_key_here",
  "TYPECAST_API_KEY": "your_typecast_api_key_here"
}
```

2. **Set up ADB reverse tunnel** (do this each time you connect your phone):
```bash
"C:\Users\dhiaf\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:3000 tcp:3000
```

3. **Run your app**:
```bash
cd mobile_app
flutter run --dart-define-from-file=dart_defines.json
```

### ✅ Advantages:
- Works even if your computer's IP changes
- Works on any network
- Simpler configuration
- No need to check/update IP addresses

### ❌ Must do every time:
- Run the `adb reverse` command each time you reconnect your phone
- Requires USB debugging enabled

---

## Alternative: WiFi Network Connection

This uses your computer's local IP address. Only use this if ADB reverse doesn't work for you.

### Setup:

1. **Find your computer's IP address**:
```bash
ipconfig
```
Look for "IPv4 Address" under "Wireless LAN adapter WiFi" (e.g., `192.168.0.101`)

2. **Update dart_defines.json** with your IP:
```json
{
  "API_BASE_URL": "http://192.168.0.101:3000/api/v1",
  "SUPABASE_URL": "https://kitcsauipthxzhiripqb.supabase.co",
  "SUPABASE_ANON_KEY": "your_anon_key_here"
}
```

3. **Run your app**:
```bash
cd mobile_app
flutter run --dart-define-from-file=dart_defines.json
```

### ✅ When it works:
- Both devices are on the same WiFi network
- Your computer's IP doesn't change
- Your router allows device-to-device communication

### ❌ When it breaks:
- Your computer's IP changes (most routers use DHCP)
- You connect to a different WiFi network
- Your phone is on mobile data
- Public/corporate WiFi with device isolation

---

## For Android Emulators

Emulators use a special IP address to reach the host machine.

### Setup:

**dart_defines.json** for emulator:
```json
{
  "API_BASE_URL": "http://10.0.2.2:3000/api/v1",
  "SUPABASE_URL": "https://kitcsauipthxzhiripqb.supabase.co",
  "SUPABASE_ANON_KEY": "your_anon_key_here"
}
```

**Run:**
```bash
cd mobile_app
flutter run --dart-define-from-file=dart_defines.json
```

`10.0.2.2` is the Android emulator's alias for your computer's `localhost`.

---

## Quick Reference Table

| Device Type | API_BASE_URL | Additional Setup |
|------------|--------------|------------------|
| **Physical Device (RECOMMENDED)** | `http://localhost:3000/api/v1` | Run `adb reverse tcp:3000 tcp:3000` first |
| Physical Device (WiFi) | `http://YOUR_IP:3000/api/v1` | Both on same WiFi, IP may change |
| Android Emulator | `http://10.0.2.2:3000/api/v1` | None |
| iOS Simulator | `http://localhost:3000/api/v1` | None |

---

## Troubleshooting

### Connection Refused Error
1. Make sure backend is running: `cd backend && npm run dev`
2. Check backend is on port 3000: `netstat -ano | findstr :3000`
3. For physical devices with ADB: verify tunnel is active
4. For WiFi method: verify both devices are on same network

### "Lost connection to device"
- Normal when app backgrounds on physical devices
- Just reopen the app on your phone

### Hot Reload Not Picking Up Changes
- If you change `dart_defines.json`, you must do a **Hot Restart** (press `R`)
- Or stop and restart `flutter run`

---

## Development Workflow

### Daily Setup (Physical Device + ADB):
```bash
# 1. Start backend
cd backend
npm run dev

# 2. Connect phone via USB and run ADB reverse
"C:\Users\dhiaf\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:3000 tcp:3000

# 3. Run app
cd ../mobile_app
flutter run --dart-define-from-file=dart_defines.json
```

### When Backend IP Changes (WiFi method only):
```bash
# 1. Get new IP
ipconfig

# 2. Update mobile_app/dart_defines.json with new IP

# 3. Restart app (Hot Restart won't work for this)
flutter run --dart-define-from-file=dart_defines.json
```

---

## Summary

**For most developers**: Use **ADB reverse tunneling** (localhost method). It's more reliable and doesn't break when your IP changes.

**Current configuration**: Your `dart_defines.json` is set to `http://localhost:3000/api/v1` (ADB method).

Remember to run `adb reverse tcp:3000 tcp:3000` each time you connect your phone!
