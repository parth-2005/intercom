import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/signaling_message.dart';
import '../services/websocket_signaling_service.dart';

final signalingServiceProvider = Provider<WebSocketSignalingService>((ref) {
  final service = WebSocketSignalingService();
  ref.onDispose(() => service.dispose());
  return service;
});

final signalingMessagesProvider = StreamProvider<Stream<SignalingMessage>?>((ref) async* {
  final service = ref.watch(signalingServiceProvider);
  yield service.messages;
});

final connectionStateProvider = StateNotifierProvider<ConnectionStateNotifier, ConnectionState>((ref) {
  return ConnectionStateNotifier(ref);
});

class ConnectionState {
  final bool isConnected;
  final String? username;
  final String serverUrl;

  const ConnectionState({
    this.isConnected = false,
    this.username,
    this.serverUrl = 'ws://localhost:8080',
  });

  ConnectionState copyWith({
    bool? isConnected,
    String? username,
    String? serverUrl,
  }) {
    return ConnectionState(
      isConnected: isConnected ?? this.isConnected,
      username: username ?? this.username,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }
}

class ConnectionStateNotifier extends StateNotifier<ConnectionState> {
  ConnectionStateNotifier(this.ref) : super(const ConnectionState());

  final Ref ref;

  Future<void> connect(String username, String serverUrl, {String? fcmToken}) async {
    final service = ref.read(signalingServiceProvider);
    
    try {
      await service.connect(username, serverUrl, fcmToken: fcmToken);
      state = ConnectionState(
        isConnected: true,
        username: username,
        serverUrl: serverUrl,
      );
    } catch (e) {
      state = ConnectionState(
        isConnected: false,
        username: null,
        serverUrl: serverUrl,
      );
      rethrow;
    }
  }

  void disconnect() {
    final service = ref.read(signalingServiceProvider);
    service.disconnect();
    state = const ConnectionState();
  }
}
