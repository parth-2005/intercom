# 🚀 Quick Command Reference

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run app (auto-detect device)
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d linux
flutter run -d <android-device-id>

# List available devices
flutter devices

# Run tests
flutter test

# Code analysis
flutter analyze

# Format code
dart format lib/

# Clean build
flutter clean
flutter pub get

# Build release
flutter build windows --release
flutter build apk --release
```

---

## Common Tasks

### Test the Mock App
```bash
# 1. Run the app
flutter run -d windows

# 2. Login with username "dad"
# 3. See simulated contacts
# 4. Tap "Call" button
# 5. See call screen
```

### Debug Incoming Calls
```bash
# 1. Replace contacts_screen.dart with contacts_screen_debug.dart
# 2. Hot reload
# 3. Tap orange FAB button on contacts screen
# 4. See incoming call screen
```

### View Logs
```bash
# Run with verbose logging
flutter run -v

# Filter logs (PowerShell)
flutter run | Select-String "CallState"
```

---

## File Shortcuts

### Edit Main Entry Point
```bash
code lib/main.dart
```

### Edit State Machine
```bash
code lib/providers/call_state_provider.dart
```

### Edit UI Screens
```bash
code lib/screens/login_screen.dart
code lib/screens/contacts_screen.dart
code lib/screens/incoming_call_screen.dart
code lib/screens/call_screen.dart
```

### Edit Mock Service
```bash
code lib/services/mock_signaling_service.dart
```

---

## Hot Reload vs Hot Restart

**Hot Reload (r)** - Fast, preserves state
```bash
# While app is running, press 'r'
r
```

**Hot Restart (R)** - Slower, resets state
```bash
# While app is running, press 'R' or Shift+R
R
```

**When to use Hot Restart:**
- After changing state provider logic
- After adding new dependencies
- After modifying main.dart routes
- When hot reload fails

---

## Troubleshooting

### Dependencies not resolving
```bash
flutter clean
rm pubspec.lock
flutter pub get
```

### Desktop not showing as device
```bash
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

### Android device not detected
```bash
adb devices
adb kill-server
adb start-server
```

### Build errors after git pull
```bash
flutter clean
flutter pub get
flutter run
```

---

## Git Workflow (Future)

```bash
# Commit current work
git add .
git commit -m "Phase 1: Complete UI and mock signaling"

# Create branch for next feature
git checkout -b feature/webrtc-integration

# Push to remote
git push origin feature/webrtc-integration
```

---

## VS Code Shortcuts (Windows/Linux)

```
F5           - Run with debugging
Ctrl+F5      - Run without debugging
Ctrl+Shift+P - Command palette
Ctrl+`       - Toggle terminal
Ctrl+Shift+K - Delete line
Alt+Up/Down  - Move line up/down
Ctrl+D       - Select next occurrence
Ctrl+/       - Toggle line comment
```

---

## Flutter DevTools

```bash
# Open DevTools in browser
flutter pub global activate devtools
flutter pub global run devtools

# Then run app with:
flutter run --observatory-port=9200
```

**DevTools features:**
- Widget inspector
- Performance view
- Memory profiler
- Network monitor

---

## Testing Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## Build Variants

### Debug (Development)
```bash
flutter run
# Fast build, includes debug info, larger size
```

### Profile (Performance testing)
```bash
flutter run --profile
# Optimized, but with performance tools
```

### Release (Production)
```bash
flutter build windows --release
flutter build apk --release
# Fully optimized, smallest size, no debug info
```

---

## Environment Info

```bash
# Check Flutter version
flutter --version

# Check doctor (diagnose issues)
flutter doctor -v

# Check for outdated packages
flutter pub outdated

# Upgrade Flutter SDK
flutter upgrade
```

---

## Android Specific

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Install APK on device
flutter install

# View Android logs
flutter logs
adb logcat | grep Flutter
```

---

## Windows Specific

```bash
# Build Windows executable
flutter build windows --release

# Output location:
# build/windows/runner/Release/intercom.exe

# Run release build
./build/windows/runner/Release/intercom.exe
```

---

## Linux Specific

```bash
# Build Linux executable
flutter build linux --release

# Output location:
# build/linux/x64/release/bundle/intercom

# Run release build
./build/linux/x64/release/bundle/intercom
```

---

## Performance Analysis

```bash
# Run with performance overlay
flutter run --profile

# In app, press 'P' to toggle performance overlay
# Shows FPS, frame render time
```

---

## Quick Fixes

### "A RenderFlex overflowed"
- Add `SingleChildScrollView` wrapper
- Or reduce widget sizes

### "setState() called after dispose()"
- Add null checks
- Or use `if (mounted)` before setState

### "The method X isn't defined"
- Import missing package
- Or check for typos

### Hot reload not working
- Use Hot Restart (R) instead
- Or restart the app completely

---

## Useful Flutter Commands

```bash
# Create new widget
# (no command, just create file and class)

# Generate icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create

# Upgrade dependencies
flutter pub upgrade --major-versions

# Check unused dependencies
flutter pub deps
```

---

## Documentation Commands

```bash
# Generate Dart documentation
dart doc .

# Serve documentation locally
cd doc/api
python -m http.server 8000
# Open http://localhost:8000
```

---

## Next Steps Reference

| Task | Time | Command to Start |
|------|------|------------------|
| Test mock app | 10 min | `flutter run` |
| Build signaling server | 1-2 days | Create new Go project |
| Add WebRTC | 2-3 days | `code lib/services/webrtc_service.dart` |
| Deploy to device | 1 hour | `flutter build apk --release` |

---

**Updated:** January 1, 2026
