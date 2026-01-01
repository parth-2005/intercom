# Family Intercom App

A private family calling app built with Flutter. Supports 1-to-1 audio/video calls over WebRTC with instant ringing UX.

## 🎯 What's Been Built (v0.1 - Mock Mode)

### ✅ Completed Features

1. **Complete UI Screens**
   - Login Screen (username + server URL)
   - Contacts Screen (family members list with online status)
   - Incoming Call Screen (full-screen with Accept/Reject)
   - In-Call Screen (with duration timer and media controls)

2. **Call State Machine**
   - Fully implemented state transitions (IDLE → OUTGOING → RINGING → IN_CALL)
   - Proper state management with Riverpod
   - Single active call enforcement

3. **Mock Signaling Service**
   - Simulates WebSocket signaling
   - Handles all message types (call_request, call_accept, call_reject, etc.)
   - Presence simulation (family members online/offline)

4. **Notification Support**
   - Service skeleton ready for incoming call alerts
   - Android & Linux notification support prepared

### 📦 Project Structure

```
lib/
├── main.dart                          # App entry point with routing
├── models/
│   ├── call_state.dart                # Call state model & enums
│   ├── user.dart                      # User model
│   └── signaling_message.dart         # WebSocket message model
├── providers/
│   ├── call_state_provider.dart       # Call state management
│   ├── signaling_provider.dart        # Connection & signaling
│   └── presence_provider.dart         # User presence tracking
├── screens/
│   ├── login_screen.dart              # Username + server connection
│   ├── contacts_screen.dart           # Family members list
│   ├── incoming_call_screen.dart      # Full-screen incoming call UI
│   └── call_screen.dart               # Active call UI with controls
└── services/
    ├── mock_signaling_service.dart    # Mock WebSocket (for testing)
    └── notification_service.dart      # Push notification handler
```

## 🚀 How to Run

### Prerequisites
- Flutter 3.10.4 or higher
- Windows / Linux / Android development setup

### Steps

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   # On Windows/Linux desktop
   flutter run -d windows
   flutter run -d linux

   # On Android
   flutter run -d <device-id>
   ```

3. **Login:**
   - Enter any username (e.g., "dad", "mom", "sister")
   - Server URL is pre-filled (currently non-functional in mock mode)
   - Click "Connect"

4. **Test Call Flow:**
   - You'll see simulated family members online
   - Tap "Call" button next to any contact
   - Call screen appears with "Calling..." status
   - *Note: In mock mode, calls won't actually connect. Real WebRTC integration is next step.*

## 🧪 Testing the Mock Flow

The app currently runs in **mock mode** to validate the UI and state machine without needing a backend server.

### Simulated Features:
- ✅ Login connects instantly
- ✅ 4 family members appear online (mom, dad, sister, brother)
- ✅ Initiating a call transitions to "Calling..." state
- ✅ Call duration timer works
- ✅ Media controls (mute, speaker, video) toggle state
- ✅ End call returns to contacts

### To Simulate Incoming Call (Developer Mode):
Add this to test incoming calls:
```dart
// In contacts_screen.dart, add a debug button:
FloatingActionButton(
  onPressed: () {
    final service = ref.read(signalingServiceProvider);
    service.simulateIncomingCall('mom');
  },
  child: Icon(Icons.bug_report),
)
```

## 🛠 Next Steps

### Phase 2: Real WebRTC Integration
- [ ] Replace `MockSignalingService` with real WebSocket client
- [ ] Integrate `flutter_webrtc` for actual P2P media
- [ ] Implement ICE candidate exchange
- [ ] Handle SDP offer/answer negotiation
- [ ] Test over Tailscale network

### Phase 3: Notifications & Background
- [ ] Android full-screen incoming call notification
- [ ] Wake screen on incoming call
- [ ] Custom ringtone support
- [ ] Background service for always-on availability

### Phase 4: Production Hardening
- [ ] Persistent login (SharedPreferences)
- [ ] Network error handling & recovery
- [ ] Call timeout logic (30s no answer)
- [ ] Busy signal (reject when already in call)
- [ ] Missed call history

## 🧠 Architecture Principles

Following the spec's philosophy:
- **Boring > Clever**: Simple, predictable code
- **Reliable > Feature-rich**: Core calling works perfectly
- **Family UX > Engineer ego**: Big buttons, clear states

### State Management Rules:
1. Single source of truth: `CallState` in `callStateProvider`
2. No global variables
3. All state transitions go through `CallStateNotifier`
4. UI reacts to state, never modifies it directly

### Call Flow:
```
User taps Call
  → initiateCall(remotePeer)
  → State: OUTGOING
  → Send call_request
  → State: RINGING
  → Wait for accept/reject/timeout
  → On accept: State: IN_CALL
  → On reject/timeout: State: IDLE
```

## 📝 Dependencies

```yaml
flutter_webrtc: ^0.9.48          # WebRTC for P2P media
web_socket_channel: ^2.4.0       # WebSocket signaling
riverpod: ^2.5.0                 # State management
flutter_riverpod: ^2.5.0         # Flutter bindings
flutter_local_notifications: ^17.0.0  # Push notifications
uuid: ^4.3.3                     # Unique call IDs
```

## ❌ Explicitly Out of Scope (v1)
- iOS support
- Web browser support
- Group calls
- Text chat
- Public accounts / user discovery

## 📄 License
Private family use only.
