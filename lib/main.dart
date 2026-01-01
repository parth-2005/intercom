import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/call_state.dart';
import 'providers/call_state_provider.dart';
import 'screens/call_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/incoming_call_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: IntercomApp()));
}

class IntercomApp extends ConsumerWidget {
  const IntercomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for incoming calls globally
    ref.listen<CallState>(callStateProvider, (previous, next) {
      if (next.status == CallStatus.incoming && previous?.status != CallStatus.incoming) {
        // Navigate to incoming call screen
        final navigator = Navigator.of(context);
        navigator.pushNamed('/incoming-call');
      }
    });

    return MaterialApp(
      title: 'Family Intercom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/contacts': (context) => const ContactsScreen(),
        '/incoming-call': (context) => const IncomingCallScreen(),
        '/call': (context) => const CallScreen(),
      },
    );
  }
}
