import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/signaling_message.dart';

/// Real WebSocket signaling service that communicates with the backend server.
class WebSocketSignalingService {
  WebSocketSignalingService();

  WebSocketChannel? _channel;
  final _messageController = StreamController<SignalingMessage>.broadcast();

  String? _username;
  bool _isConnected = false;
  Timer? _heartbeatTimer;

  Stream<SignalingMessage> get messages => _messageController.stream;
  bool get isConnected => _isConnected;
  String? get username => _username;

  Future<void> connect(String username, String serverUrl, {String? fcmToken}) async {
    try {
      _username = username;

      // Validate and normalize server URL
      String normalizedUrl = serverUrl.trim();
      if (normalizedUrl.isEmpty) {
        throw Exception('Server URL cannot be empty');
      }

      // Convert HTTP/HTTPS schemes to WS/WSS
      if (normalizedUrl.startsWith('https://')) {
        normalizedUrl = normalizedUrl.replaceFirst('https://', 'wss://');
      } else if (normalizedUrl.startsWith('http://')) {
        normalizedUrl = normalizedUrl.replaceFirst('http://', 'ws://');
      } else if (!normalizedUrl.startsWith('ws://') && !normalizedUrl.startsWith('wss://')) {
        // No scheme provided, default to ws://
        normalizedUrl = 'ws://$normalizedUrl';
      }

      // Build WebSocket URL with query parameters
      final uri = Uri.parse(normalizedUrl);
      if (uri.scheme.isEmpty) {
        throw Exception('Invalid server URL scheme: $normalizedUrl');
      }

      final params = Map<String, String>.from(uri.queryParameters);
      params['user'] = username;
      if (fcmToken != null && fcmToken.isNotEmpty) {
        params['fcm_token'] = fcmToken;
      }

      final wsUrl = uri.replace(queryParameters: params);

      if (kDebugMode) {
        debugPrint('[WebSocket] Connecting to: $wsUrl');
      }

      _channel = WebSocketChannel.connect(wsUrl);

      // Listen to incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );

      _isConnected = true;
      _startHeartbeat();

      if (kDebugMode) {
        debugPrint('[WebSocket] Connected as $username');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebSocket] Connection error: $e');
      }
      _isConnected = false;
      rethrow;
    }
  }

  void disconnect() {
    if (kDebugMode) {
      debugPrint('[WebSocket] Disconnecting...');
    }
    _stopHeartbeat();
    _channel?.sink.close();
    _isConnected = false;
    _username = null;
  }

  void sendMessage(SignalingMessage message) {
    if (!_isConnected || _channel == null) {
      if (kDebugMode) {
        debugPrint('[WebSocket] Not connected, cannot send message: $message');
      }
      return;
    }

    try {
      final payload = <String, dynamic>{
        'type': message.type,
      };

      final from = message.from ?? _username;
      if (from != null) payload['from'] = from;
      if (message.to != null) payload['to'] = message.to;
      if (message.callId != null) payload['call_id'] = message.callId;
      if (message.data != null) payload['data'] = message.data;
      if (message.online != null) payload['online'] = message.online;
      if (message.user != null) payload['user'] = message.user;

      final json = jsonEncode(payload);

      _channel!.sink.add(json);

      if (kDebugMode) {
        debugPrint('[WebSocket] Sent: $json');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebSocket] Error sending message: $e');
      }
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (message is! String) return;

      if (kDebugMode) {
        debugPrint('[WebSocket] Received: $message');
      }

      final json = jsonDecode(message) as Map<String, dynamic>;
      final signalingMessage = SignalingMessage(
        type: json['type'] as String? ?? 'unknown',
        from: json['from'] as String?,
        to: json['to'] as String?,
        callId: json['callId'] as String? ?? json['call_id'] as String?,
        data: json['data'] as Map<String, dynamic>?,
        online: json['online'] as bool?,
        user: json['user'] as String?,
      );

      _messageController.add(signalingMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebSocket] Error parsing message: $e');
      }
    }
  }

  void _handleError(dynamic error) {
    if (kDebugMode) {
      debugPrint('[WebSocket] Error: $error');
    }
    _isConnected = false;
    _stopHeartbeat();
  }

  void _handleDone() {
    if (kDebugMode) {
      debugPrint('[WebSocket] Connection closed');
    }
    _isConnected = false;
    _stopHeartbeat();
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected) {
        try {
          _channel?.sink.add(jsonEncode({'type': 'ping'}));
          if (kDebugMode) {
            debugPrint('[WebSocket] Heartbeat sent');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[WebSocket] Heartbeat error: $e');
          }
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void dispose() {
    _stopHeartbeat();
    _channel?.sink.close();
    _messageController.close();
  }
}
