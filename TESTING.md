# Developer Testing Guide

## 🧪 Testing the Mock Implementation

This guide helps you test the app's UI and state machine using the mock signaling service.

## Quick Start

1. **Run the app:**
   ```bash
   flutter run -d windows  # or linux, or android device
   ```

2. **Login:**
   - Enter any username (e.g., "dad")
   - Click "Connect"
   - You'll see 4 family members online: mom, dad, sister, brother

## Test Scenarios

### ✅ Scenario 1: Outgoing Call Flow

1. On Contacts screen, tap **Call** button next to any contact
2. **Expected:** App navigates to Call screen showing "Calling..."
3. **Expected:** Call state transitions: IDLE → OUTGOING → RINGING
4. Click **End Call** button
5. **Expected:** Returns to Contacts screen, state back to IDLE

### ✅ Scenario 2: Incoming Call Flow (with Debug Button)

To enable the debug button, temporarily replace `contacts_screen.dart` with `contacts_screen_debug.dart`:

**Option A: Manual edit**
- Open [lib/main.dart](lib/main.dart)
- Change: `import 'screens/contacts_screen.dart';`
- To: `import 'screens/contacts_screen_debug.dart';`
- And change route: `'/contacts': (context) => const ContactsScreen(),` to use `ContactsScreenDebug()`

**Option B: Use the debug version (recommended for testing)**

1. Copy [lib/screens/contacts_screen_debug.dart](lib/screens/contacts_screen_debug.dart) content
2. Replace [lib/screens/contacts_screen.dart](lib/screens/contacts_screen.dart) with it
3. Hot reload the app

**Testing incoming call:**
1. On Contacts screen, look for **orange FAB** (floating action button) at bottom right
2. Tap the orange phone icon
3. **Expected:** Full-screen Incoming Call screen appears immediately
4. **Expected:** Shows first contact's name (e.g., "mom")
5. Tap **Accept** (green button)
6. **Expected:** Navigates to In-Call screen showing "00:00" timer
7. Timer should increment every second
8. Tap **End Call**
9. **Expected:** Returns to Contacts screen

### ✅ Scenario 3: Call Rejection

1. Trigger incoming call (orange FAB)
2. Tap **Decline** (red button)
3. **Expected:** Returns to Contacts screen immediately
4. **Expected:** Call state back to IDLE

### ✅ Scenario 4: In-Call Media Controls

1. Start a call (outgoing or accept incoming)
2. Wait for In-Call screen to appear
3. Test each button:
   - **Mute:** Icon toggles mic/mic_off, button turns red when muted
   - **Speaker:** Button turns blue when active
   - **Video:** Button turns blue when active
4. **Expected:** All toggles work smoothly, visual feedback immediate

### ✅ Scenario 5: Call Duration Timer

1. Accept an incoming call
2. Watch the timer at top of In-Call screen
3. **Expected:** Timer starts at 00:00 and increments every second (00:01, 00:02, etc.)
4. Let it run for 1 minute
5. **Expected:** Timer shows 01:00, 01:01, etc.

### ✅ Scenario 6: Navigation Flow

1. Login → Contacts
2. Initiate call → Call screen
3. End call → Back to Contacts
4. Incoming call appears → Incoming Call screen
5. Accept → In-Call screen
6. End → Back to Contacts

**Expected:** No navigation glitches, back button works correctly

### ✅ Scenario 7: Call Blocking (Single Active Call)

1. While in a call (any state except IDLE)
2. Go back to Contacts (if possible via navigation)
3. **Expected:** "Call" buttons should be disabled/hidden
4. **Expected:** Cannot initiate second call

## 🐛 Known Limitations (Mock Mode)

- ❌ No actual audio/video
- ❌ Outgoing calls don't auto-accept (you must manually end them)
- ❌ No ringing sound
- ❌ Presence updates are simulated only once on login
- ❌ Multiple app instances don't communicate

## 📊 State Verification

### How to verify state transitions:

Add this to any screen to see live state:
```dart
final callState = ref.watch(callStateProvider);
print('Call State: ${callState.status}');
```

### Expected State Flow:

**Outgoing call:**
```
IDLE → OUTGOING → RINGING → (manual end) → IDLE
```

**Incoming call accepted:**
```
IDLE → INCOMING → IN_CALL → (end) → IDLE
```

**Incoming call rejected:**
```
IDLE → INCOMING → IDLE
```

## 🔧 Troubleshooting

### Problem: No contacts appear
- **Solution:** Check that you logged in successfully. Look for username in top bar.

### Problem: Incoming call FAB not visible
- **Solution:** Ensure you're using `contacts_screen_debug.dart` version

### Problem: App crashes on navigation
- **Check:** Ensure all routes in [lib/main.dart](lib/main.dart) are defined
- **Check:** Verify no null values in CallState

### Problem: Timer doesn't update
- **Check:** Call state must be `IN_CALL` and `callStartTime` must be set
- **Solution:** Only accept incoming calls or manually set state in code

## ✨ Next: Real WebRTC Testing

Once mock testing passes, you can:
1. Replace `MockSignalingService` with real WebSocket client
2. Connect to actual signaling server
3. Test with real WebRTC peer connections
4. Test over Tailscale network

## 📝 Test Checklist

Before moving to WebRTC implementation, verify:

- [ ] Login works with any username
- [ ] Contacts list shows simulated users
- [ ] Can initiate outgoing call
- [ ] Incoming call screen appears on simulated call
- [ ] Accept button transitions to In-Call screen
- [ ] Reject button returns to Contacts
- [ ] Call duration timer increments correctly
- [ ] Media control buttons toggle state
- [ ] End call returns to Contacts from any call state
- [ ] Cannot start multiple calls simultaneously
- [ ] Navigation flows work without crashes
- [ ] Test passes: `flutter test`

---

**Ready to test?** Run `flutter run` and work through the scenarios above!
