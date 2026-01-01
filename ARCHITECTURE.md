# System Architecture Diagram

## 📐 High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App (Client)                    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │                   UI Layer                         │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │    │
│  │  │  Login   │  │ Contacts │  │  Call    │        │    │
│  │  │  Screen  │  │  Screen  │  │  Screen  │        │    │
│  │  └──────────┘  └──────────┘  └──────────┘        │    │
│  └────────────────────────────────────────────────────┘    │
│                         ↕ (watch/read)                      │
│  ┌────────────────────────────────────────────────────┐    │
│  │           State Management (Riverpod)              │    │
│  │  ┌─────────────┐  ┌──────────┐  ┌──────────┐     │    │
│  │  │ CallState   │  │ Presence │  │Connection│     │    │
│  │  │ Provider    │  │ Provider │  │ Provider │     │    │
│  │  └─────────────┘  └──────────┘  └──────────┘     │    │
│  └────────────────────────────────────────────────────┘    │
│                         ↕ (uses)                            │
│  ┌────────────────────────────────────────────────────┐    │
│  │                 Services Layer                      │    │
│  │  ┌─────────────┐  ┌──────────┐  ┌──────────┐     │    │
│  │  │ Signaling   │  │  WebRTC  │  │ Notific. │     │    │
│  │  │  Service    │  │  Service │  │ Service  │     │    │
│  │  └─────────────┘  └──────────┘  └──────────┘     │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                         ↕                    ↕
                    WebSocket           WebRTC P2P
                    Signaling             Media
                         ↕                    ↕
┌─────────────────────────────────────────────────────────────┐
│              Signaling Server (Go)                           │
│  - User Registration                                         │
│  - Presence Management                                       │
│  - Message Routing                                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Call Flow Sequence

### Outgoing Call

```
User                UI              CallState         Signaling        WebRTC
 │                  │                  │                  │               │
 │──Tap "Call"──────>│                  │                  │               │
 │                  │──initiateCall()──>│                  │               │
 │                  │                  │──send───────────>│               │
 │                  │                  │ call_request     │               │
 │                  │                  │                  │               │
 │                  │<─State: RINGING──│                  │               │
 │<─Show Call Screen│                  │                  │               │
 │                  │                  │                  │               │
 │                  │                  │<─call_accepted───│               │
 │                  │<─State: IN_CALL──│                  │               │
 │                  │                  │──create──────────────────────────>│
 │                  │                  │  PeerConnection  │               │
 │                  │                  │<─────────────────────────────────│
 │                  │                  │──send SDP offer─>│               │
 │                  │                  │<─receive answer──│               │
 │                  │                  │──exchange ICE────────────────────>│
 │                  │                  │                  │               │
 │<══════════════ Media flows P2P ══════════════════════════════════════>│
```

### Incoming Call

```
User                UI              CallState         Signaling        Server
 │                  │                  │                  │               │
 │                  │                  │<─incoming_call───│<──────────────│
 │                  │<─State: INCOMING─│                  │               │
 │<─Incoming Screen─│                  │                  │               │
 │                  │                  │                  │               │
 │──Tap "Accept"───>│                  │                  │               │
 │                  │──acceptCall()───>│                  │               │
 │                  │                  │──send───────────>│──────────────>│
 │                  │                  │ call_accept      │               │
 │                  │<─State: IN_CALL──│                  │               │
 │<─Call Screen─────│                  │                  │               │
```

---

## 🧩 Component Responsibilities

### UI Layer (Screens)
```
LoginScreen
├─ Purpose: Collect username & server URL
├─ Actions: Connect button
└─ Navigation: → ContactsScreen on success

ContactsScreen
├─ Purpose: Display family members
├─ Data: PresenceProvider (online/offline status)
├─ Actions: Call button per contact
└─ Navigation: → CallScreen on initiate
              → IncomingCallScreen on receive

IncomingCallScreen
├─ Purpose: Full-screen call notification
├─ Data: CallStateProvider (caller info)
├─ Actions: Accept / Reject buttons
└─ Navigation: → CallScreen on accept
              → back on reject

CallScreen
├─ Purpose: Active call interface
├─ Data: CallStateProvider (duration, media state)
├─ Actions: Mute, Speaker, Video, End
└─ Navigation: → ContactsScreen on end
```

### State Management (Providers)
```
CallStateProvider (StateNotifier<CallState>)
├─ Current Status: IDLE | OUTGOING | RINGING | INCOMING | IN_CALL
├─ Methods:
│   ├─ initiateCall(remotePeer)
│   ├─ acceptCall()
│   ├─ rejectCall()
│   ├─ endCall()
│   ├─ toggleAudio()
│   ├─ toggleVideo()
│   └─ toggleSpeaker()
└─ Listens: SignalingMessagesProvider

PresenceProvider (StateNotifier<Map<String, User>>)
├─ Tracks: Online/offline status per user
├─ Updates: On 'presence' signaling messages
└─ Used by: ContactsScreen

ConnectionStateProvider (StateNotifier<ConnectionState>)
├─ Current: isConnected, username, serverUrl
├─ Methods:
│   ├─ connect(username, serverUrl)
│   └─ disconnect()
└─ Used by: All screens for connection status
```

### Services Layer
```
MockSignalingService (Development)
├─ Simulates: WebSocket behavior
├─ Methods:
│   ├─ connect(username, serverUrl)
│   ├─ disconnect()
│   ├─ sendMessage(SignalingMessage)
│   ├─ simulateIncomingCall(from)  [debug]
│   └─ simulateCallEnded(callId)   [debug]
└─ Stream: messages (SignalingMessage)

WebSocketSignalingService (Production - TODO)
├─ Real: WebSocket connection
├─ Methods: [same as mock]
├─ Handles: Reconnection, heartbeat
└─ Stream: messages

WebRTCService (TODO)
├─ Manages: RTCPeerConnection
├─ Methods:
│   ├─ createPeerConnection()
│   ├─ getUserMedia(audio, video)
│   ├─ createOffer()
│   ├─ createAnswer()
│   ├─ setRemoteDescription(sdp)
│   ├─ addIceCandidate(candidate)
│   └─ close()
└─ Streams: localStream, remoteStream

NotificationService
├─ Platform: Android, Linux, Windows
├─ Methods:
│   ├─ initialize()
│   ├─ showIncomingCallNotification(caller)
│   ├─ cancelNotification(callId)
│   └─ cancelAllNotifications()
└─ Purpose: Wake device, show full-screen alert
```

---

## 🔐 Data Models

### CallState
```dart
{
  status: CallStatus,        // IDLE | OUTGOING | RINGING | INCOMING | IN_CALL
  callId: String?,           // UUID v4
  remotePeer: String?,       // Username of other person
  isAudioEnabled: bool,      // Mic on/off
  isVideoEnabled: bool,      // Camera on/off
  isSpeakerOn: bool,         // Speaker vs earpiece
  callStartTime: DateTime?   // For duration calculation
}
```

### User
```dart
{
  username: String,
  isOnline: bool
}
```

### SignalingMessage
```dart
{
  type: String,              // Message type (call_request, etc.)
  to: String?,               // Target user
  from: String?,             // Sender user
  callId: String?,           // Call UUID
  data: Map<String, dynamic>?, // Payload (SDP, ICE, etc.)
  online: bool?,             // Presence status
  user: String?              // User for presence updates
}
```

---

## 🌐 Network Flow

### Mock Mode (Current)
```
Flutter App
    │
    └─ MockSignalingService (in-memory)
         └─ Simulates server responses
```

### Production Mode (Phase 2)
```
Flutter App (Client A)                     Flutter App (Client B)
    │                                           │
    ├─ WebSocketSignalingService                ├─ WebSocketSignalingService
    │         │                                 │         │
    │         └─────────── WebSocket ───────────┘         │
    │                        │                            │
    │                   Go Server                         │
    │                   (Signaling)                       │
    │                                                     │
    └───────────── WebRTC P2P Media ────────────────────┘
              (Direct over Tailscale)
```

### Tailscale Integration (Phase 4)
```
Device A (100.64.x.x)  ←── Tailscale Mesh ──→  Device B (100.64.y.y)
    │                                                │
    ├─ Signaling: ws://server.tailscale-ip:8080    │
    └─ Media: WebRTC direct to Tailscale IP        │
```

---

## 📂 File Dependency Graph

```
main.dart
  ├─ screens/
  │   ├─ login_screen.dart
  │   │   └─ providers/signaling_provider.dart
  │   ├─ contacts_screen.dart
  │   │   ├─ providers/presence_provider.dart
  │   │   └─ providers/call_state_provider.dart
  │   ├─ incoming_call_screen.dart
  │   │   └─ providers/call_state_provider.dart
  │   └─ call_screen.dart
  │       └─ providers/call_state_provider.dart
  │
  ├─ providers/
  │   ├─ call_state_provider.dart
  │   │   ├─ models/call_state.dart
  │   │   ├─ models/signaling_message.dart
  │   │   └─ providers/signaling_provider.dart
  │   ├─ presence_provider.dart
  │   │   ├─ models/user.dart
  │   │   └─ providers/signaling_provider.dart
  │   └─ signaling_provider.dart
  │       └─ services/mock_signaling_service.dart
  │
  ├─ services/
  │   ├─ mock_signaling_service.dart
  │   │   └─ models/signaling_message.dart
  │   └─ notification_service.dart
  │
  └─ models/
      ├─ call_state.dart
      ├─ user.dart
      └─ signaling_message.dart
```

---

## 🔄 State Transition Diagram

```
                    ┌──────────────┐
                    │     IDLE     │ ◄─── Initial State
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              │                         │
      initiateCall()            incoming_call received
              │                         │
              ▼                         ▼
        ┌──────────┐            ┌──────────────┐
        │ OUTGOING │            │   INCOMING   │
        └────┬─────┘            └──────┬───────┘
             │                         │
     auto-transition          ┌────────┼────────┐
             │                │                 │
             ▼          acceptCall()      rejectCall()
        ┌──────────┐          │                 │
        │ RINGING  │          │                 │
        └────┬─────┘          │                 │
             │                │                 │
    ┌────────┼────────┐       │                 │
    │                 │       │                 │
call_accepted    call_rejected│                 │
    │             timeout     │                 │
    │                │        │                 │
    ▼                ▼        ▼                 ▼
 ┌──────────────────────────────────────────────┐
 │               IN_CALL                         │
 └────────────────┬──────────────────────────────┘
                  │
            endCall() or
         call_ended received
                  │
                  ▼
            ┌──────────┐
            │   IDLE   │
            └──────────┘
```

---

## 🔌 Signaling Protocol Flow

```
Client A                  Server                  Client B
   │                        │                        │
   │────register: A────────>│                        │
   │                        │<────register: B────────│
   │                        │                        │
   │───call_request────────>│───incoming_call───────>│
   │  {to: B, id: uuid}     │  {from: A, id: uuid}  │
   │                        │                        │
   │                        │<───call_accept─────────│
   │<──call_accepted────────│                        │
   │                        │                        │
   │───sdp_offer───────────>│───sdp_offer───────────>│
   │                        │<──sdp_answer───────────│
   │<──sdp_answer───────────│                        │
   │                        │                        │
   │───ice_candidate───────>│───ice_candidate───────>│
   │<──ice_candidate────────│<──ice_candidate────────│
   │                        │                        │
   │◄═══════════════ WebRTC P2P Media ══════════════►│
```

---

**Last Updated:** January 1, 2026  
**Architecture Version:** 1.0 (Mock Mode)
