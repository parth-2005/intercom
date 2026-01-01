import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_state.dart';
import '../providers/call_state_provider.dart';
import '../providers/presence_provider.dart';
import '../providers/signaling_provider.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateProvider);
    final presenceMap = ref.watch(presenceProvider);
    final callState = ref.watch(callStateProvider);
    
    final contacts = presenceMap.values.toList()
      ..sort((a, b) {
        // Online first
        if (a.isOnline != b.isOnline) {
          return a.isOnline ? -1 : 1;
        }
        return a.username.compareTo(b.username);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${connectionState.username ?? "User"}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(connectionStateProvider.notifier).disconnect();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: contacts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No family members online',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isInCall = callState.status != CallStatus.idle;
                
                return ListTile(
                  leading: Stack(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      if (contact.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    contact.username,
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    contact.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: contact.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  trailing: contact.isOnline && !isInCall
                      ? ElevatedButton.icon(
                          onPressed: () {
                            ref.read(callStateProvider.notifier).initiateCall(contact.username);
                            Navigator.of(context).pushNamed('/call');
                          },
                          icon: const Icon(Icons.call),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        )
                      : null,
                );
              },
            ),
    );
  }
}
