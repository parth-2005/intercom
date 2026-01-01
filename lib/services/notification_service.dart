import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    // This will be used to navigate to the incoming call screen
  }

  Future<void> showIncomingCallNotification({
    required String callerName,
    required String callId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'incoming_calls',
      'Incoming Calls',
      channelDescription: 'Notifications for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
      category: LinuxNotificationCategory.imReceived,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      linux: linuxDetails,
    );

    await _notifications.show(
      callId.hashCode,
      'Incoming Call',
      'Call from $callerName',
      notificationDetails,
    );
  }

  Future<void> cancelNotification(String callId) async {
    await _notifications.cancel(callId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
