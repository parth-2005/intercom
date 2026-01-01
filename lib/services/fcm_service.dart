import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'call_helper.dart';

/// Background handler for FCM messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  await Firebase.initializeApp();
  await FCMService.instance._handleMessage(message);
}

class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;

  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) {
        debugPrint('FCM permission denied');
      }
      return;
    }

    _token = await _messaging.getToken();
    _messaging.onTokenRefresh.listen((token) => _token = token);

    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  Future<String?> getToken() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;
    _token ??= await _messaging.getToken();
    return _token;
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final data = message.data;
    if (data['type'] == 'call_initiate') {
      final callId = data['call_id'] ?? data['callId'] ?? const Uuid().v4();
      final caller = data['caller'] ?? 'Unknown Caller';
      await CallHelper().showIncomingCall(callId, caller);
    }
  }
}
