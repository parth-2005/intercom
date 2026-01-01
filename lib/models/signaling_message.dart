import 'dart:convert';

class SignalingMessage {
  final String type;
  final String? to;
  final String? from;
  final String? callId;
  final Map<String, dynamic>? data;
  final bool? online;
  final String? user;

  const SignalingMessage({
    required this.type,
    this.to,
    this.from,
    this.callId,
    this.data,
    this.online,
    this.user,
  });

  factory SignalingMessage.fromJson(Map<String, dynamic> json) {
    return SignalingMessage(
      type: json['type'] as String,
      to: json['to'] as String?,
      from: json['from'] as String?,
      callId: json['call_id'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      online: json['online'] as bool?,
      user: json['user'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type};
    if (to != null) map['to'] = to;
    if (from != null) map['from'] = from;
    if (callId != null) map['call_id'] = callId;
    if (data != null) map['data'] = data;
    if (online != null) map['online'] = online;
    if (user != null) map['user'] = user;
    return map;
  }

  String toJsonString() => jsonEncode(toJson());
}
