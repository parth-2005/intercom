# Intercom - Private Family Calling App

A WhatsApp-style calling app for families, built with Flutter. Supports 1-to-1 audio/video calls over WebRTC with instant ringing UX. Designed to run over your private Tailscale network.

---

## 🎯 Quick Links

- **[BUILD_COMPLETE.md](BUILD_COMPLETE.md)** ← **START HERE** - What's built, how to run, what's next
- **[IMPLEMENTATION.md](IMPLEMENTATION.md)** - Architecture overview & setup guide
- **[TESTING.md](TESTING.md)** - Developer testing scenarios  
- **[ROADMAP.md](ROADMAP.md)** - Phase-by-phase development plan
- **[PROTOCOL.md](PROTOCOL.md)** - Signaling protocol specification
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture diagrams

---

## ✅ Current Status (v0.1)

**Phase 1 Complete:** Full UI, state machine, and mock signaling working!

### What Works Now
- ✅ Login screen with username input
- ✅ Contacts list with online/offline status
- ✅ Initiate outgoing calls
- ✅ Full-screen incoming call UI  
- ✅ Accept/Reject call buttons
- ✅ In-call screen with duration timer
- ✅ Media control toggles (mute, speaker, video)
- ✅ Proper state transitions (IDLE → OUTGOING → RINGING → IN_CALL)
- ✅ Single active call enforcement
- ✅ Mock signaling service for testing
- ✅ All tests passing, no compile errors

### What's Next
- 🚧 Real WebSocket signaling server (Go)
- 🚧 WebRTC integration for actual media
- 🚧 Android background notifications
- 🚧 Tailscale network integration

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10.4+
- Windows, Linux, or Android device

### Run It

```bash
# Install dependencies
flutter pub get

# Run on desktop
flutter run -d windows
flutter run -d linux

# Run on Android
flutter run
```

### Test It

1. Login with any username (e.g., "dad")
2. See simulated family members online
3. Tap "Call" next to a contact
4. See call screen with "Calling..." state
5. Tap "End Call"

**For incoming call testing:** See [TESTING.md](TESTING.md)

---

## 🧱 Tech Stack

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **flutter_webrtc** - WebRTC for P2P media
- **web_socket_channel** - WebSocket signaling
- **flutter_local_notifications** - Push notifications

**No Firebase. No analytics. No bloat.**

---

## 📦 Project Structure

```
lib/
├── main.dart                          # App entry point with routing
├── models/                            # Data models
│   ├── call_state.dart
│   ├── user.dart
│   └── signaling_message.dart
├── providers/                         # Riverpod state management
│   ├── call_state_provider.dart
│   ├── signaling_provider.dart
│   └── presence_provider.dart
├── screens/                           # UI screens
│   ├── login_screen.dart
│   ├── contacts_screen.dart
│   ├── incoming_call_screen.dart
│   └── call_screen.dart
└── services/                          # Business logic
    ├── mock_signaling_service.dart    # Mock WebSocket (for testing)
    └── notification_service.dart      # Push notifications
```

---

## 🎯 Design Goals

> **"WhatsApp calling for your family, over your private network"**

### Core Principles
- **Boring > Clever** - Simple, predictable code
- **Reliable > Feature-rich** - Core calling works perfectly
- **Family UX > Engineer ego** - Big buttons, clear states

### Target Experience
- Tap contact → ring instantly
- Accept call → connected immediately  
- Big buttons → easy for anyone
- No chat, no bloat → just calling

---

## 🛠 Development

### Run Tests
```bash
flutter test
```

### Code Analysis  
```bash
flutter analyze
```

### Build Release
```bash
# Windows
flutter build windows --release

# Android
flutter build apk --release
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [BUILD_COMPLETE.md](BUILD_COMPLETE.md) | **Start here** - Overview of what's built |
| [IMPLEMENTATION.md](IMPLEMENTATION.md) | Technical details & setup |
| [TESTING.md](TESTING.md) | Manual testing guide |
| [ROADMAP.md](ROADMAP.md) | Development phases & timeline |
| [PROTOCOL.md](PROTOCOL.md) | Signaling protocol spec |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System diagrams |

---

## 🎓 Next Steps (Choose Your Path)

### Option A: Build Signaling Server
Create a Go WebSocket server for message routing.  
**Time:** 1-2 days  
**See:** [PROTOCOL.md](PROTOCOL.md)

### Option B: Add WebRTC
Integrate `flutter_webrtc` for real media streams.  
**Time:** 2-3 days  
**See:** [ROADMAP.md](ROADMAP.md) Phase 2

### Option C: Polish UI
Add loading states, error handling, animations.  
**Time:** 1 day  
**See:** [IMPLEMENTATION.md](IMPLEMENTATION.md)

---

## ❌ Explicitly Out of Scope (v1)

- iOS support
- Web browser support  
- Group calls
- Text chat
- Public accounts / user discovery

---

## 📄 License

Private family use only.

---

**Status:** ✅ Phase 1 Complete  
**Next:** Real signaling + WebRTC integration  
**Est. Time to Working Calls:** ~1 week  

**Questions?** Read [BUILD_COMPLETE.md](BUILD_COMPLETE.md) first!

