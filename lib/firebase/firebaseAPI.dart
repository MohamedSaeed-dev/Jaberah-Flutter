import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/login.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/pages/admin/notificationsAdmin.dart';
import 'package:jaberah/pages/user/notificationsUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handlerBackgroundMessage(RemoteMessage message) async {
  // Handle data-only messages in background
  if (message.notification != null) {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await localNotifications.initialize(initializationSettings);

    final androidPlatform =
        localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.createNotificationChannel(androidChannel);

    localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'اشعار جديد',
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          importance: androidChannel.importance,
          icon: 'ic_launcher',
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
  }
}

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final ApiClient _apiClient = Get.find();
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message != null) {
      var auth = Get.find<AuthController>();
      auth.isLoggedIn.value
          ? auth.isAdmin.value
              ? Get.to(() => NotificationsAdmin())
              : Get.to(() => NotificationsUser())
          : Get.offAll(() => Login());
    }
  }

  Future<void> initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
          handleMessage(message);
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var id = prefs.getString("id");
      var accessToken = prefs.getString('accessToken');
      if (id != null && accessToken != null) await updateToken(id, token);
    });
    initPushNotification();
    initLocalNotifications();
  }

  Future<void> initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handlerBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
            notification.hashCode,
            notification.title ?? 'اشعار جديد',
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
                importance: _androidChannel.importance,
                icon: 'ic_launcher',
              ),
            ),
            payload: jsonEncode(message.toMap()));
      }
    });
  }

  Future<void> updateToken(String userId, String token) async {
    try {
      var response = await _apiClient.dio.patch("/$refreshFCMTokenURL", data: {
        "userId": userId,
        "token": token,
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        print(response.data);
        messageSnackBar("الرجاء اعادة تشغيل التطبيق");
      }
    } catch (e) {
      print(e);
      messageSnackBar("الرجاء اعادة تشغيل التطبيق");
    }
  }
}
