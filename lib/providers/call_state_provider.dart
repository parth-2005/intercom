import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/call_state.dart';
import '../models/signaling_message.dart';
import 'signaling_provider.dart';

final callStateProvider = StateNotifierProvider<CallStateNotifier, CallState>((ref) {
  return CallStateNotifier(ref);
});

class CallStateNotifier extends StateNotifier<CallState> {
  CallStateNotifier(this.ref) : super(CallState.idle) {
    _listenToSignaling();
  }

  final Ref ref;
  final _uuid = const Uuid();

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
    switch (message.type) {
      case 'incoming_call':
        if (state.status == CallStatus.idle) {
          state = CallState(
            status: CallStatus.incoming,
            callId: message.callId,
            remotePeer: message.from,
          );
        }
        break;

      case 'call_ended':
        if (state.callId == message.callId) {
          endCall();
        }
        break;

      case 'call_accept':
        if (state.status == CallStatus.ringing && state.callId == message.callId) {
          state = state.copyWith(
            status: CallStatus.inCall,
            callStartTime: DateTime.now(),
          );
        }
        break;

      case 'call_reject':
        if (state.status == CallStatus.ringing && state.callId == message.callId) {
          state = CallState.idle;
        }
        break;
    }
  }

  void initiateCall(String remotePeer) {
    if (state.status != CallStatus.idle) return;

    final callId = _uuid.v4();
    state = CallState(
      status: CallStatus.outgoing,
      callId: callId,
      remotePeer: remotePeer,
    );

    // Send call request
    final signalingService = ref.read(signalingServiceProvider);
    signalingService.sendMessage(SignalingMessage(
      type: 'call_request',
      to: remotePeer,
      callId: callId,
    ));

    // Transition to ringing
    state = state.copyWith(status: CallStatus.ringing);

    // Simulate timeout after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (state.callId == callId && state.status == CallStatus.ringing) {
        endCall();
      }
    });
  }

  void acceptCall() {
    if (state.status != CallStatus.incoming) return;

    final signalingService = ref.read(signalingServiceProvider);
    signalingService.sendMessage(SignalingMessage(
      type: 'call_accept',
      callId: state.callId,
    ));

    state = state.copyWith(
      status: CallStatus.inCall,
      callStartTime: DateTime.now(),
    );
  }

  void rejectCall() {
    if (state.status != CallStatus.incoming) return;

    final signalingService = ref.read(signalingServiceProvider);
    signalingService.sendMessage(SignalingMessage(
      type: 'call_reject',
      callId: state.callId,
    ));

    state = CallState.idle;
  }

  void endCall() {
    if (state.status == CallStatus.idle) return;

    final signalingService = ref.read(signalingServiceProvider);
    if (state.callId != null) {
      signalingService.sendMessage(SignalingMessage(
        type: 'call_ended',
        callId: state.callId,
      ));
    }

    state = CallState.idle;
  }

  void toggleAudio() {
    if (state.status != CallStatus.inCall) return;
    state = state.copyWith(isAudioEnabled: !state.isAudioEnabled);
  }

  void toggleVideo() {
    if (state.status != CallStatus.inCall) return;
    state = state.copyWith(isVideoEnabled: !state.isVideoEnabled);
  }

  void toggleSpeaker() {
    if (state.status != CallStatus.inCall) return;
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }
}
