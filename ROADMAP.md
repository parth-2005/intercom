# Intercom Project Status

## ✅ Phase 1: Foundation (COMPLETE)

### What's Built

**✅ Core Architecture**
- Clean project structure with separation of concerns
- Models: `CallState`, `User`, `SignalingMessage`
- Providers: State management with Riverpod (call state, presence, signaling)
- Services: Mock signaling for testing

**✅ Call State Machine**
- Full state machine implementation (IDLE → OUTGOING → RINGING → IN_CALL)
- Single active call enforcement
- Proper state transitions with timeout handling
- Media control toggles (mute, speaker, video)

**✅ Complete UI Screens**
1. Login Screen - username + server URL input
2. Contacts Screen - family members list with online indicators
3. Incoming Call Screen - full-screen with Accept/Reject
4. In-Call Screen - duration timer, media controls, end button

**✅ Mock Signaling**
- Simulates WebSocket behavior for testing
- Handles all message types (call_request, call_accept, call_reject, etc.)
- Presence simulation (4 family members online)
- Can simulate incoming calls for testing

**✅ Notification Foundation**
- Service skeleton created for incoming call alerts
- Android & Linux support prepared
- Ready for integration with call flow

**✅ Testing**
- Widget test suite passing
- Developer test guide with scenarios
- Debug version of contacts screen for manual testing

---

## 🚧 Phase 2: Real Signaling & WebRTC (NEXT)

### Priority Order

#### 1. Real WebSocket Signaling Service
**Files to create/modify:**
- `lib/services/websocket_signaling_service.dart` (new)
- Update `lib/providers/signaling_provider.dart` to use real service
- Add connection retry logic
- Add heartbeat/keepalive

**Implementation:**
```dart
class WebSocketSignalingService {
  WebSocketChannel? _channel;
  
  Future<void> connect(String username, String serverUrl) {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    // Send registration message
    // Listen to incoming messages
    // Handle disconnections
  }
}
```

#### 2. WebRTC Integration
**Files to create/modify:**
- `lib/services/webrtc_service.dart` (new)
- `lib/providers/webrtc_provider.dart` (new)
- Update `lib/providers/call_state_provider.dart` to wire WebRTC events

**Key Tasks:**
- Initialize `RTCPeerConnection` on call start
- Handle ICE candidate gathering/exchange
- Create and exchange SDP offer/answer
- Attach local/remote media streams
- Handle connection state changes
- Dispose peer connection on call end

**Integration Points:**
```dart
// In CallStateNotifier
void initiateCall(String remotePeer) async {
  // 1. Create peer connection
  final pc = await ref.read(webrtcProvider).createPeerConnection();
  
  // 2. Add local media tracks
  await ref.read(webrtcProvider).getUserMedia();
  
  // 3. Create offer
  final offer = await pc.createOffer();
  await pc.setLocalDescription(offer);
  
  // 4. Send offer via signaling
  ref.read(signalingService).sendMessage(
    SignalingMessage(type: 'sdp_offer', data: offer.toMap())
  );
  
  // 5. Update state
  state = state.copyWith(status: CallStatus.ringing);
}
```

#### 3. Media Stream UI
**Files to modify:**
- `lib/screens/call_screen.dart` - add `RTCVideoRenderer` widgets

**Changes:**
- Display local video preview (small corner)
- Display remote video (full screen when enabled)
- Audio-only mode by default
- Toggle video on/off

---

## 🔮 Phase 3: Production Features

### Android Background & Notifications
**Tasks:**
- Full-screen incoming call notification (high priority)
- Wake screen on incoming call
- Custom ringtone/vibration
- Foreground service for persistent connection
- Battery optimization handling

**Files to create:**
- `android/app/src/main/kotlin/.../ForegroundCallService.kt`
- `lib/services/notification_service.dart` (enhance existing)

### Desktop Wake/Focus
**Tasks:**
- Window focus on incoming call (Windows/Linux)
- System tray icon
- Desktop notifications with action buttons

### Persistence
**Tasks:**
- Save login credentials (SharedPreferences)
- Remember server URL
- Call history log
- Missed call tracking

**Dependencies to add:**
```yaml
shared_preferences: ^2.2.0
```

### Error Handling & Recovery
**Tasks:**
- Network error detection
- Automatic reconnection logic
- Graceful call failure handling
- User-friendly error messages
- Connection quality indicator

---

## 🎯 Phase 4: Tailscale Integration

### Tailscale Network Setup
**Tasks:**
- Verify Tailscale is running on devices
- Use Tailscale IPs in WebRTC ICE configuration
- Disable TURN servers (rely on Tailscale direct connection)
- Test NAT traversal over Tailscale mesh

**WebRTC Config Changes:**
```dart
final configuration = {
  'iceServers': [], // Empty - use Tailscale direct
  'iceTransportPolicy': 'all',
  'bundlePolicy': 'max-bundle',
  'rtcpMuxPolicy': 'require',
};
```

### Server URL Configuration
**Default format:**
```
ws://<tailscale-server-ip>:8080
```

---

## 📊 Metrics to Track

### Must Work
- [ ] Call setup time < 3 seconds
- [ ] Zero dropped calls on stable network
- [ ] Audio/video sync perfect
- [ ] App works when backgrounded (Android)
- [ ] Battery usage acceptable (< 5% per hour idle)

### Nice to Have
- [ ] Call setup time < 1 second
- [ ] Support 3+ hours continuous call
- [ ] Automatic quality adjustment on poor network

---

## 🛠 Go Server (Separate Project)

**Repository:** `intercom-server` (to be created)

**Features:**
- WebSocket signaling relay
- User registration/presence
- Message routing (peer-to-peer)
- No media processing (pure signaling)

**Tech Stack:**
- Go standard library `net/http`
- Gorilla WebSocket
- Simple JSON messages
- No database (in-memory for v1)

**See:** Separate server spec document

---

## 🧪 Testing Plan

### Phase 2 Tests
- [ ] Real WebSocket connects successfully
- [ ] Can register username
- [ ] Receives presence updates
- [ ] WebRTC peer connection established
- [ ] Audio flows both directions
- [ ] Video flows both directions
- [ ] ICE candidates exchanged correctly
- [ ] Call ends cleanly from either side

### Phase 3 Tests
- [ ] Incoming call wakes Android device
- [ ] Notification shows full-screen
- [ ] Desktop window focuses on call
- [ ] App survives background/foreground cycle
- [ ] Login persists across app restarts
- [ ] Network drop recovers gracefully

### Phase 4 Tests
- [ ] Call works over Tailscale network
- [ ] Direct P2P connection (no relay)
- [ ] Call quality perfect on Tailscale
- [ ] Multi-platform: Windows ↔ Android
- [ ] Multi-platform: Linux ↔ Android

---

## 📝 Known Issues (Current)

### Mock Mode Limitations
- Outgoing calls don't auto-accept (manual end only)
- No actual media streams
- Presence updates only on login
- No ringtone sound

### To Fix Before Phase 2
- None - mock mode is intentionally simplified

---

## 🚀 Next Immediate Steps

1. **Build Go signaling server** (1-2 days)
   - Basic WebSocket relay
   - User registration
   - Message routing

2. **Implement real signaling service** (1 day)
   - Replace mock service
   - Test with real server

3. **Add WebRTC integration** (2-3 days)
   - Peer connection setup
   - Media stream handling
   - ICE/SDP exchange

4. **Test end-to-end call** (1 day)
   - Desktop to desktop
   - Audio working both ways

**Estimated time to working calls:** ~1 week

---

## 🎓 Learning Resources

### WebRTC Basics
- [WebRTC for the Curious](https://webrtcforthecurious.com/)
- [flutter_webrtc Examples](https://github.com/flutter-webrtc/flutter-webrtc/tree/master/example)

### Signaling Patterns
- [Signaling and Video Calling](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Signaling_and_video_calling)

### Tailscale + WebRTC
- [Tailscale Documentation](https://tailscale.com/kb/)
- No special integration needed - just use Tailscale IPs

---

**Current Status:** ✅ Phase 1 complete, ready for Phase 2

**Last Updated:** January 1, 2026
