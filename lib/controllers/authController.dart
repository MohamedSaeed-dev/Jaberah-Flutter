import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/userNameController.dart';
import 'package:jaberah/login.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/pages/admin/homeAdmin.dart';
import 'package:jaberah/pages/user/homeUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final ApiClient apiClient = Get.find();
  final usernameController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;

  var isShowEye = true.obs;
  var isLoading = false.obs;

  var isLoggedIn = false.obs;
  var isAdmin = false.obs;

  final _firebaseMessaging = FirebaseMessaging.instance;
  Future login() async {
    try {
      isLoading.value = true;
      final fcmToken = await _firebaseMessaging.getToken();
      var response = await apiClient.dio.post("/$loginURL", data: {
        "username": usernameController.value.text,
        "password": passwordController.value.text,
        "fcmToken": fcmToken!
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final LoginModel data = LoginModel.fromJson(response.data);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data.accessToken);
        final UserNameController usernameC = Get.put(UserNameController());
        usernameC.saveValue(data.user.teacherName);
        await prefs.setString("id", data.user.id.toString());
        await prefs.setString("name", data.user.teacherName);
        await prefs.setString("phone", data.user.phoneNumber);
        await prefs.setString("role", data.user.role.toString());
        isAdmin.value = data.user.role == 1;

        await subscribeToTopics();

        isLoggedIn.value = true;
        Get.snackbar(
          '',
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.7),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
          isDismissible: true,
          titleText: const Center(
            child: Text(
              'تم تسجيل الدخول بنجاح',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          messageText: Center(
            child: Text(
              'مرحبًا بك يا ${data.user.teacherName}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
        if (data.user.role == 1) {
          Get.off(() => HomePageAdmin());
        } else if (data.user.role == 2) {
          Get.off(() => HomePageUser());
        } else {
          messageSnackBar("حدثت اخطاء غير متوقعه");
        }
      } else {
        messageSnackBar(response.data["message"]);
      }
      usernameController().clear();
      passwordController().clear();
    } on SocketException catch (_) {
      messageSnackBar('الرجاء التأكد من الاتصال بالانترنت',
          title: 'خطأ في تسجيل الدخول');
    } on TimeoutException catch (_) {
      messageSnackBar('خطأ في الخادم، حاول مرة أخرى لاحقاً',
          title: 'خطأ في تسجيل الدخول');
    } catch (e) {
      messageSnackBar('يرجى التحقق من بياناتك', title: 'خطأ في تسجيل الدخول');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> subscribeToTopics() async {
    if (isAdmin.value) {
      await _firebaseMessaging.subscribeToTopic("check-attendance");
    } else {
      await _firebaseMessaging.subscribeToTopic("public");
    }
    await _firebaseMessaging.subscribeToTopic("newVersion");
  }

  Future<void> unsubscribeFromTopics() async {
    await _firebaseMessaging.unsubscribeFromTopic("public");
    await _firebaseMessaging.unsubscribeFromTopic("newVersion");
    await _firebaseMessaging.unsubscribeFromTopic("check-attendance");
  }

  var isLoadingLogout = false.obs;
  Future<void> logout() async {
    isLoadingLogout.value = true;
    // يمنع مستمع onTokenRefresh من استدعاء الـ API أثناء تسجيل الخروج
    isLoggedIn.value = false;

    try {
      try {
        await _firebaseMessaging.deleteToken();
      } catch (_) {
        // تجاهل فشل حذف التوكن — نكمل تسجيل الخروج محلياً
      }
      try {
        await unsubscribeFromTopics();
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      usernameController.value.clear();
      passwordController.value.clear();

      isAdmin.value = false;
      try {
        Get.find<UserNameController>().name.value = '';
      } catch (_) {}
    } finally {
      isLoadingLogout.value = false;
    }

    // إغلاق نافذة التأكيد أولاً ثم استبدال المكدس (تجنّب بقاء الـ overlay / حالة التحميل)
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.offAll(() => Login());

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      titleText: const Center(
        child: Text(
          'تم تسجيل خروجك بنجاح',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  Future<AuthController> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('accessToken');
    var role = prefs.getString("role");
    if (accessToken != null && role != null) {
      isAdmin.value = role == "1";
      isLoggedIn.value = true;
    } else {
      isLoggedIn.value = false;
    }
    return this;
  }
}

class User {
  int id;
  String teacherName;
  String phoneNumber;
  int role;

  User({
    required this.id,
    required this.teacherName,
    required this.phoneNumber,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] as int,
      teacherName: json["teacherName"] as String,
      phoneNumber: json["phoneNumber"] as String,
      role: json["role"] as int,
    );
  }
}

class LoginModel {
  User user;
  String accessToken;

  LoginModel({required this.user, required this.accessToken});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
        user: User.fromJson(json["user"]),
        accessToken: json["accessToken"] as String);
  }
}
