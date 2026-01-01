import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/signaling_message.dart';
import 'signaling_provider.dart';

final presenceProvider = StateNotifierProvider<PresenceNotifier, Map<String, User>>((ref) {
  return PresenceNotifier(ref);
});

class PresenceNotifier extends StateNotifier<Map<String, User>> {
  PresenceNotifier(this.ref) : super({}) {
    _listenToSignaling();
  }

  final Ref ref;

  void _listenToSignaling() {
    ref.listen<AsyncValue<Stream<SignalingMessage>?>>(
      signalingMessagesProvider,
      (previous, next) {
        next.whenData((stream) {
          if (stream != null) {
            stream.listen(_handleSignalingMessage);
          }
        });
      },
    );
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
}
