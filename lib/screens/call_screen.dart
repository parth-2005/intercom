import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_state.dart';
import '../providers/call_state_provider.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  Timer? _durationTimer;
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startDurationTimer();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final callState = ref.read(callStateProvider);
      if (callState.status == CallStatus.inCall && callState.callStartTime != null) {
        setState(() {
          _callDuration = DateTime.now().difference(callState.callStartTime!);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callStateProvider);

    // Auto-navigate away if call ends
    ref.listen<CallState>(callStateProvider, (previous, next) {
      if (next.status == CallStatus.idle) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final isRinging = callState.status == CallStatus.ringing;
    final isInCall = callState.status == CallStatus.inCall;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),
            
            // Remote peer info
            Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  callState.remotePeer ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isRinging ? 'Calling...' : _formatDuration(_callDuration),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            // Control buttons
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  if (isInCall) ...[
                    // Media controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: callState.isAudioEnabled ? Icons.mic : Icons.mic_off,
                          label: callState.isAudioEnabled ? 'Mute' : 'Unmute',
                          onPressed: () => ref.read(callStateProvider.notifier).toggleAudio(),
                          backgroundColor: callState.isAudioEnabled ? Colors.white.withAlpha(51) : Colors.red,
                        ),
                        _buildControlButton(
                          icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                          label: 'Speaker',
                          onPressed: () => ref.read(callStateProvider.notifier).toggleSpeaker(),
                          backgroundColor: callState.isSpeakerOn ? Colors.blue : Colors.white.withAlpha(51),
                        ),
                        _buildControlButton(
                          icon: callState.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                          label: 'Video',
                          onPressed: () => ref.read(callStateProvider.notifier).toggleVideo(),
                          backgroundColor: callState.isVideoEnabled ? Colors.blue : Colors.white.withAlpha(51),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // End call button
                  FloatingActionButton(
                    onPressed: () {
                      ref.read(callStateProvider.notifier).endCall();
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.call_end,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'End Call',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
