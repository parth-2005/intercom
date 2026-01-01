import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:window_manager/window_manager.dart';

import 'models/call_state.dart';
import 'providers/call_state_provider.dart';
import 'screens/call_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/incoming_call_screen.dart';
import 'screens/login_screen.dart';
import 'services/call_helper.dart';
import 'services/fcm_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FCMService.instance.initialize();
  }

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        title: 'Family Intercom',
        center: true,
      ),
      () async {
        await windowManager.show();
      },
    );
  }

  _setupCallKitListeners();

  runApp(const ProviderScope(child: IntercomApp()));
}

void _setupCallKitListeners() {
  if (!Platform.isAndroid && !Platform.isIOS) return;

  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
    if (event == null) return;
    final nav = navigatorKey.currentState;
    switch (event.event) {
      case Event.actionCallAccept:
        CallHelper().endCall();
        nav?.pushNamed('/call');
        break;
      case Event.actionCallDecline:
      case Event.actionCallEnded:
      case Event.actionCallTimeout:
        CallHelper().endCall();
        break;
      default:
        break;
    }
  });
}

class IntercomApp extends ConsumerWidget {
  const IntercomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for incoming calls globally
    ref.listen<CallState>(callStateProvider, (previous, next) {
      if (next.status == CallStatus.incoming && previous?.status != CallStatus.incoming) {
        navigatorKey.currentState?.pushNamed('/incoming-call');
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
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
