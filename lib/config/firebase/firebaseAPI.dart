import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/controllers/user/notificationsUserController.dart';
import 'package:jaberah/login.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/pages/admin/notificationsAdmin.dart';
import 'package:jaberah/pages/user/notificationsUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> handlerBackgroundMessage(RemoteMessage message) async {
  String? topic = message.data['topic'];
  if (topic == "public") {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt('notificationCount') ?? 0;
    await prefs.setInt('notificationCount', currentCount + 1);
  }
}

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final ApiClient _apiClient = Get.find();

  final _androidChannel = const AndroidNotificationChannel(
    'default_channel',
    'Default Channel',
    description: 'Used for general notifications',
    importance: Importance.defaultImportance,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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

    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      String? topic = message.data['topic'];

      if (topic != null) {
        if (topic == "public") {
          var notificationController = Get.find<NotificationsCountController>();
          notificationController.incrementNewNotification();
        }
        _localNotifications.show(
          notification.hashCode,
          notification?.title ?? 'اشعار جديد',
          notification?.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              importance: _androidChannel.importance,
              icon: 'ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
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
        messageSnackBar("الرجاء اعادة تشغيل التطبيق");
      }
    } catch (e) {
      messageSnackBar("الرجاء اعادة تشغيل التطبيق");
    }
  }
}
