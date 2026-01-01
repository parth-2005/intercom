import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_state.dart';
import '../providers/call_state_provider.dart';

class IncomingCallScreen extends ConsumerWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callStateProvider);

    // Auto-navigate away if call state changes
    ref.listen<CallState>(callStateProvider, (previous, next) {
      if (next.status != CallStatus.incoming) {
        if (next.status == CallStatus.inCall) {
          Navigator.of(context).pushReplacementNamed('/call');
        } else if (next.status == CallStatus.idle) {
          Navigator.of(context).pop();
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),
            
            // Caller info
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
                const Text(
                  'Incoming call...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            // Ringing animation
            const Column(
              children: [
                Icon(
                  Icons.phone_in_talk,
                  size: 48,
                  color: Colors.white70,
                ),
                SizedBox(height: 16),
                Text(
                  'Ringing',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'reject',
                        onPressed: () {
                          ref.read(callStateProvider.notifier).rejectCall();
                        },
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.call_end,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Decline',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  // Accept button
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'accept',
                        onPressed: () {
                          ref.read(callStateProvider.notifier).acceptCall();
                        },
                        backgroundColor: Colors.green,
                        child: const Icon(
                          Icons.call,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
