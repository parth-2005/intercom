# Signaling Protocol Reference

## Message Format

All messages are JSON over WebSocket.

```json
{
  "type": "message_type",
  "field1": "value1",
  "field2": "value2"
}
```

---

## Client → Server Messages

### 1. Register / Login
```json
{
  "type": "register",
  "username": "dad"
}
```
**Response:** `registered` or `error`

### 2. Call Request
```json
{
  "type": "call_request",
  "to": "mom",
  "call_id": "uuid-v4-string"
}
```
**Server Action:** Routes to target user → `incoming_call`

### 3. Call Accept
```json
{
  "type": "call_accept",
  "call_id": "uuid-v4-string"
}
```
**Server Action:** Notifies caller → `call_accepted`

### 4. Call Reject
```json
{
  "type": "call_reject",
  "call_id": "uuid-v4-string"
}
```
**Server Action:** Notifies caller → `call_rejected`

### 5. Call End
```json
{
  "type": "call_ended",
  "call_id": "uuid-v4-string"
}
```
**Server Action:** Notifies other peer → `call_ended`

### 6. WebRTC SDP Offer
```json
{
  "type": "sdp_offer",
  "call_id": "uuid-v4-string",
  "data": {
    "sdp": "v=0\r\no=- ...",
    "type": "offer"
  }
}
```
**Server Action:** Routes to other peer

### 7. WebRTC SDP Answer
```json
{
  "type": "sdp_answer",
  "call_id": "uuid-v4-string",
  "data": {
    "sdp": "v=0\r\no=- ...",
    "type": "answer"
  }
}
```
**Server Action:** Routes to other peer

### 8. ICE Candidate
```json
{
  "type": "ice_candidate",
  "call_id": "uuid-v4-string",
  "data": {
    "candidate": "candidate:1 ...",
    "sdpMid": "0",
    "sdpMLineIndex": 0
  }
}
```
**Server Action:** Routes to other peer

---

## Server → Client Messages

### 1. Registration Success
```json
{
  "type": "registered",
  "username": "dad"
}
```

### 2. Registration Error
```json
{
  "type": "error",
  "message": "Username already taken"
}
```

### 3. Presence Update
```json
{
  "type": "presence",
  "user": "mom",
  "online": true
}
```
**Sent:** When user connects/disconnects

### 4. Incoming Call
```json
{
  "type": "incoming_call",
  "from": "sister",
  "call_id": "uuid-v4-string"
}
```
**Client Action:** Show incoming call screen

### 5. Call Accepted
```json
{
  "type": "call_accepted",
  "call_id": "uuid-v4-string"
}
```
**Client Action:** Transition to IN_CALL state

### 6. Call Rejected
```json
{
  "type": "call_rejected",
  "call_id": "uuid-v4-string"
}
```
**Client Action:** Return to IDLE state

### 7. Call Ended
```json
{
  "type": "call_ended",
  "call_id": "uuid-v4-string",
  "reason": "user_hangup"
}
```
**Client Action:** End call, return to IDLE

### 8. User Busy
```json
{
  "type": "user_busy",
  "call_id": "uuid-v4-string",
  "user": "mom"
}
```
**Client Action:** Show "User is busy" message

### 9. User Offline
```json
{
  "type": "user_offline",
  "call_id": "uuid-v4-string",
  "user": "dad"
}
```
**Client Action:** Show "User is offline" message

### 10. WebRTC Messages (Relayed)
Same format as client sends, just routed to peer:
- `sdp_offer`
- `sdp_answer`
- `ice_candidate`

---

## Call Flow Examples

### Successful Call (Full Flow)

```
Caller (Dad)                Server                 Callee (Mom)
     |                        |                         |
     |---register: dad------->|                         |
     |<--registered-----------|                         |
     |                        |<----register: mom-------|
     |                        |-----registered--------->|
     |                        |                         |
     |---call_request-------->|                         |
     |   {to: "mom"}          |-----incoming_call------>|
     |                        |   {from: "dad"}         |
     |                        |                         |
     |                        |<----call_accept---------|
     |<--call_accepted--------|                         |
     |                        |                         |
     |---sdp_offer----------->|-----sdp_offer---------->|
     |                        |<----sdp_answer----------|
     |<--sdp_answer-----------|                         |
     |                        |                         |
     |---ice_candidate------->|-----ice_candidate------>|
     |<--ice_candidate--------|<----ice_candidate-------|
     |                        |                         |
     |      [WebRTC P2P connection established]         |
     |<==============================================>   |
     |                                                   |
     |---call_ended---------->|-----call_ended--------->|
     |                        |                         |
```

### Call Rejection

```
Caller                      Server                 Callee
     |---call_request-------->|-----incoming_call------>|
     |                        |<----call_reject---------|
     |<--call_rejected--------|                         |
```

### Call to Busy User

```
Caller                      Server                 Callee (already in call)
     |---call_request-------->|                         |
     |<--user_busy------------|                         |
```

---

## State Machine Integration

### Client Call States

```
IDLE
  ├─ Send call_request → OUTGOING
  └─ Receive incoming_call → INCOMING

OUTGOING
  └─ Auto-transition → RINGING

RINGING
  ├─ Receive call_accepted → IN_CALL
  ├─ Receive call_rejected → IDLE
  └─ Timeout (30s) → IDLE

INCOMING
  ├─ Send call_accept → IN_CALL
  └─ Send call_reject → IDLE

IN_CALL
  ├─ Send call_ended → IDLE
  └─ Receive call_ended → IDLE
```

### Server-Side Call States (per call)

```
PENDING
  ├─ Callee accepts → ACTIVE
  └─ Callee rejects → ENDED

ACTIVE
  └─ Either party ends → ENDED

ENDED
  └─ Clean up resources
```

---

## Error Handling

### Network Errors
If WebSocket connection drops:
1. Client attempts reconnect with exponential backoff
2. If in call, end call gracefully
3. Show "Connection lost" message
4. Clear call state to IDLE

### Timeout Handling
- **Call request timeout:** 30 seconds
- **Heartbeat/ping:** Every 30 seconds
- **Connection idle timeout:** 5 minutes

### Invalid Messages
Server responds with:
```json
{
  "type": "error",
  "message": "Invalid message format"
}
```

---

## Security Considerations (Future)

### v1 (Current Spec)
- ❌ No authentication
- ❌ No encryption (relying on Tailscale)
- ❌ No message validation

### v2 (Future)
- [ ] Username + password auth
- [ ] JWT tokens
- [ ] Message signing
- [ ] Rate limiting

---

## Implementation Notes

### Server Requirements
- Must handle concurrent WebSocket connections
- Must track user presence (online/offline)
- Must route messages efficiently
- Must clean up stale connections

### Client Requirements
- Must generate unique `call_id` (UUIDv4)
- Must handle out-of-order messages
- Must validate incoming messages
- Must dispose WebRTC connections properly

---

## Testing Messages

### Test Registration
```bash
# Using websocat
echo '{"type":"register","username":"test"}' | websocat ws://localhost:8080
```

### Test Call Flow
```bash
# Terminal 1 (Dad)
websocat ws://localhost:8080
> {"type":"register","username":"dad"}
> {"type":"call_request","to":"mom","call_id":"test-123"}

# Terminal 2 (Mom)
websocat ws://localhost:8080
> {"type":"register","username":"mom"}
< {"type":"incoming_call","from":"dad","call_id":"test-123"}
> {"type":"call_accept","call_id":"test-123"}
```

---

**Protocol Version:** 1.0  
**Last Updated:** January 1, 2026
