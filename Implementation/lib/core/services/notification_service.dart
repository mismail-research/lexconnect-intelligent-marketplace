import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lexbid/core/services/navigation_services.dart'; // 🔥 Sync with your main navigation key file

class NotificationService {

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// LOCAL NOTIFICATION PLUGIN
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// ANDROID CHANNEL
  final AndroidNotificationChannel channel =
  const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  /// INITIALIZE NOTIFICATIONS
  Future<void> initializeNotifications() async {

    /// REQUEST PERMISSION
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    /// ANDROID INITIALIZATION
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    /// INITIALIZE LOCAL NOTIFICATION (Fixed with named parameters)
    await flutterLocalNotificationsPlugin.initialize(
      settings: settings, // ✅ Kept as named parameter to match library source code
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payloadString = response.payload;

        if (payloadString != null) {
          // Extract appointmentId and type from the payload string split
          final parts = payloadString.split('|');
          if (parts.length >= 2) {
            final appointmentId = parts[0];
            final type = parts[1];
            _handleNotificationNavigation(appointmentId, type);
          }
        }
      },
    );

    /// CREATE CHANNEL
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// IOS SETTINGS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    /// APP OPEN FROM TERMINATED
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleFirebaseMessage(message);
      }
    });

    /// APP OPEN FROM BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleFirebaseMessage(message);
    });

    /// FOREGROUND MESSAGE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        final appointmentId = message.data['appointmentId'] ?? '';
        final type = message.data['type'] ?? '';

        flutterLocalNotificationsPlugin.show(
          id: notification.hashCode, // ✅ Fixed: Passed explicitly as 'id' named parameter
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: android.smallIcon ?? '@mipmap/ic_launcher',
            ),
          ),
          // Store both variables in payload separated by a delimiter
          payload: "$appointmentId|$type",
        );
      }
    });
  }

  /// HANDLE FIREBASE MESSAGE
  void _handleFirebaseMessage(RemoteMessage message) {
    final appointmentId = message.data['appointmentId'];
    final type = message.data['type']; // 'appointment', 'appointment_cancellation', or 'appointment_status'

    if (appointmentId != null) {
      _handleNotificationNavigation(appointmentId, type ?? '');
    }
  }

  /// DYNAMIC NAVIGATION FOR BOTH SIDES
  void _handleNotificationNavigation(String appointmentId, String type) {
    // 1. Match the exact string token defined in your RouteGenerator ('/lawyer-appointments')
    String targetRoute = "/lawyer-appointments";

    if (type == "appointment_status") {
      // 2. Match your client appointments route token ('/clientAppointments')
      targetRoute = "/clientAppointments";
    }

    // Navigating seamlessly using the matching route configurations
    NavigationService.navigatorKey.currentState?.pushNamed(
      targetRoute,
      arguments: appointmentId,
    );
  }


  /// SAVE DEVICE TOKEN
  Future<void> saveDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    /// LAWYER
    final lawyerDoc = await FirebaseFirestore.instance
        .collection('lawyers')
        .doc(user.uid)
        .get();

    if (lawyerDoc.exists) {
      await FirebaseFirestore.instance
          .collection('lawyers')
          .doc(user.uid)
          .update({
        "deviceTokens": FieldValue.arrayUnion([token])
      });
      return;
    }

    /// CLIENT
    final clientDoc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(user.uid)
        .get();

    if (clientDoc.exists) {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .update({
        "deviceTokens": FieldValue.arrayUnion([token])
      });
    }
  }
}