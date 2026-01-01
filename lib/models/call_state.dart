enum CallStatus {
  idle,
  outgoing,
  ringing,
  incoming,
  inCall,
  rejected,
  ended,
}

class CallState {
  final CallStatus status;
  final String? callId;
  final String? remotePeer;
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isSpeakerOn;
  final DateTime? callStartTime;

  const CallState({
    required this.status,
    this.callId,
    this.remotePeer,
    this.isAudioEnabled = true,
    this.isVideoEnabled = false,
    this.isSpeakerOn = false,
    this.callStartTime,
  });

  CallState copyWith({
    CallStatus? status,
    String? callId,
    String? remotePeer,
    bool? isAudioEnabled,
    bool? isVideoEnabled,
    bool? isSpeakerOn,
    DateTime? callStartTime,
  }) {
    return CallState(
      status: status ?? this.status,
      callId: callId ?? this.callId,
      remotePeer: remotePeer ?? this.remotePeer,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      callStartTime: callStartTime ?? this.callStartTime,
    );
  }

  static const idle = CallState(status: CallStatus.idle);
}
