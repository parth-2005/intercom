import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:window_manager/window_manager.dart';

/// Handles platform-specific incoming call presentation.
class CallHelper {
  CallHelper._();
  static final CallHelper _instance = CallHelper._();
  factory CallHelper() => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _isRinging = false;

  Future<void> showIncomingCall(String callId, String callerName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _showCallkitIncoming(callId, callerName);
      return;
    }

    if (Platform.isWindows) {
      await _showWindowsIncoming(callId, callerName);
    }
  }

  Future<void> endCall() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await FlutterCallkitIncoming.endAllCalls();
    }

    if (Platform.isWindows) {
      await _stopRingtone();
    }
  }

  Future<void> _showCallkitIncoming(String callId, String callerName) async {
    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      handle: callerName,
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{'call_id': callId, 'caller': callerName},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        backgroundColor: '#0a84ff',
        actionColor: '#ffffff',
        ringtonePath: 'system_ringtone_default',
      ),
      ios: const IOSParams(
        iconName: 'CallKitIcon',
        handleType: 'generic',
        supportsVideo: true,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> _showWindowsIncoming(String callId, String callerName) async {
    // Bring the window forward and start the ringtone loop.
    await windowManager.ensureInitialized();
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);

    await _playRingtone();
  }

  Future<void> _playRingtone() async {
    if (_isRinging) return;
    _isRinging = true;
    await _player.setReleaseMode(ReleaseMode.loop);
    // Ensure you have an asset at assets/sounds/ringtone.mp3 declared in pubspec.yaml.
    await _player.play(AssetSource('sounds/ringtone.mp3'));
  }

  Future<void> _stopRingtone() async {
    if (!_isRinging) return;
    _isRinging = false;
    await _player.stop();
  }
}
