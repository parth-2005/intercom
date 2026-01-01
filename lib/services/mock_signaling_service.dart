import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/signaling_message.dart';

/// Mock signaling service for development
/// Simulates WebSocket signaling behavior
class MockSignalingService {
  final _messageController = StreamController<SignalingMessage>.broadcast();
  final _uuid = const Uuid();
  
  String? _username;
  bool _isConnected = false;

  Stream<SignalingMessage> get messages => _messageController.stream;
  bool get isConnected => _isConnected;
  String? get username => _username;

  Future<void> connect(String username, String serverUrl) async {
    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 500));
    _username = username;
    _isConnected = true;
    
    // Simulate other users being online
    _simulatePresence();
  }

  void disconnect() {
    _isConnected = false;
    _username = null;
  }

  void sendMessage(SignalingMessage message) {
    if (!_isConnected) return;
    
    // In mock mode, simulate responses
    _simulateResponse(message);
  }

  void _simulatePresence() {
    // Simulate a few family members being online
    final familyMembers = ['mom', 'dad', 'sister', 'brother'];
    
    for (final member in familyMembers) {
      if (member != _username) {
        _messageController.add(SignalingMessage(
          type: 'presence',
          user: member,
          online: true,
        ));
      }
    }
  }

  void _simulateResponse(SignalingMessage message) {
    switch (message.type) {
      case 'call_request':
        // Simulate ringing state
        Future.delayed(const Duration(milliseconds: 500), () {
          // For now, just echo back that we're calling
          // In real app, the other peer would respond
        });
        break;
      
      case 'call_accept':
      case 'call_reject':
      case 'ice_candidate':
      case 'sdp_offer':
      case 'sdp_answer':
        // Just log, no response needed in mock
        break;
    }
  }

  // Simulate receiving an incoming call (for testing)
  void simulateIncomingCall(String from) {
    final callId = _uuid.v4();
    _messageController.add(SignalingMessage(
      type: 'incoming_call',
      from: from,
      callId: callId,
    ));
  }

  // Simulate call ended (for testing)
  void simulateCallEnded(String callId) {
    _messageController.add(SignalingMessage(
      type: 'call_ended',
      callId: callId,
    ));
  }

  void dispose() {
    _messageController.close();
  }
}
