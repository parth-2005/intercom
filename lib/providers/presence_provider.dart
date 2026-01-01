import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/signaling_message.dart';
import 'signaling_provider.dart';

final presenceProvider = StateNotifierProvider<PresenceNotifier, Map<String, User>>((ref) {
  return PresenceNotifier(ref);
});

class PresenceNotifier extends StateNotifier<Map<String, User>> {
  PresenceNotifier(this.ref) : super({}) {
    _attachInitialStream();
    _listenToSignaling();
  }

  final Ref ref;
  StreamSubscription<SignalingMessage>? _subscription;

  void _attachInitialStream() {
    final current = ref.read(signalingMessagesProvider);
    current.whenData((stream) {
      _attachStream(stream);
    });
  }

  void _listenToSignaling() {
    ref.listen<AsyncValue<Stream<SignalingMessage>?>>(
      signalingMessagesProvider,
      (previous, next) {
        next.whenData((stream) {
          _attachStream(stream);
        });
      },
    );
  }

  void _attachStream(Stream<SignalingMessage>? stream) {
    // Avoid duplicate listeners
    _subscription?.cancel();
    _subscription = null;

    if (stream == null) return;

    _subscription = stream.listen(_handleSignalingMessage);
  }

  void _handleSignalingMessage(SignalingMessage message) {
    if (message.type == 'presence' && message.user != null) {
      final username = message.user!;
      final isOnline = message.online ?? false;
      
      state = {
        ...state,
        username: User(username: username, isOnline: isOnline),
      };
    }
  }

  void updateUserStatus(String username, bool isOnline) {
    state = {
      ...state,
      username: User(username: username, isOnline: isOnline),
    };
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
