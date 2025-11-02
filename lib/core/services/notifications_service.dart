import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:socials_app/core/services/cache_service.dart';

import '../config/injection.dart';
// import 'package:huawei_push/huawei_push.dart' as huawei_push;

@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(RemoteMessage message) async {
  debugPrint("Title: ${message.notification?.title}");
  debugPrint("Body: ${message.notification?.body}");
  debugPrint("Payload: ${message.data}");
}

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(NotificationResponse details) {
  if (details.payload != null) {
    handleNotificationClick(jsonDecode(details.payload!));
  }
}

@singleton
class NotificationsService {
  NotificationsService() {
    _initialization = initialize();
  }

  late final Future<void> _initialization;
  Future<void> get whenInitialized => _initialization;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('[NotificationsService] Firebase not initialized. Skipping notifications setup.');
        await setupLocalNotification();
        return;
      }

      final firebaseMessaging = FirebaseMessaging.instance;

      final response = await firebaseMessaging.requestPermission();
    final status = response.authorizationStatus;
    if (status == AuthorizationStatus.authorized) {
      final fcmToken = await firebaseMessaging.getToken();

      debugPrint("FCM ==========> $fcmToken");

      //Register to all topics
      firebaseMessaging.subscribeToTopic("all");

      debugPrint("saving fcm in cache");
      await locator<CacheService>().storeFCMToken(fcmToken!);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          showNotification(
            message.notification!.title ?? "New notification",
            message.notification!.body ?? "Cannot show notification content",
            payload: jsonEncode({'payload': message.data}),
          );
        }
      });
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessageReceived);
      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        handleNotificationClick(event.data);
      });
      firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await locator<CacheService>().storeFCMToken(fcmToken);
        // usersRepo.updateTokens(); this is update token api from backend
      });

      if (locator<CacheService>().isLoggedIn()) {
        debugPrint("Sending FCM to server:========");
        // usersRepo.updateTokens();

        //Check if the app opened from FCM
        var terminatedMessage = await FirebaseMessaging.instance
            .getInitialMessage();
        if (terminatedMessage != null) {
          await Future.delayed(const Duration(seconds: 3));
          handleNotificationClick(terminatedMessage.data);
        }
      }
      setupLocalNotification();
    }
    } catch (e, stack) {
      debugPrint('[NotificationsService] Initialization failed: $e');
      debugPrint('$stack');
      await setupLocalNotification();
    }
  }

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> setupLocalNotification() async {
    const androidInitializationSetting = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosInitializationSetting = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInitializationSetting,
      iOS: iosInitializationSetting,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void showNotification(String title, String body, {String? payload}) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '0',
      'general',
      importance: Importance.max,
      playSound: true,
      //sound: AndroidNotificationSound,
      showProgress: true,
      priority: Priority.high,
      ticker: 'test ticker',
    );

    var iOSChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

void handleNotificationClick(Map<String, dynamic> data) {
  // Extract data from the message
  final payload = data['payload'];
  debugPrint("Message Data =======> $data");
  debugPrint("Message Payload =======> $payload");
  // _navigateNotification();
}
