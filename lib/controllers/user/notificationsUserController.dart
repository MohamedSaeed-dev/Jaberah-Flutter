import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsCountController extends GetxController {
  var newNotificationCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotificationCount(); // Load count when controller is initialized
  }

  void incrementNewNotification() async {
    newNotificationCount.value++;
    await saveNotificationCount(); // Save to storage
  }

  void resetNewNotification() async {
    newNotificationCount.value = 0;
    await saveNotificationCount(); // Reset in storage
  }

  Future<void> saveNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationCount', newNotificationCount.value);
  }

  Future<void> loadNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    newNotificationCount.value = prefs.getInt('notificationCount') ?? 0;
  }
}

class NotificationsCRUDUserController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  var data = NotificationPagedData(
          data: [],
          totalCount: 0,
          totalPages: 0,
          hasNext: false,
          hasPrevious: false)
      .obs;

  var totalCount = 0.obs;
  var totalPages = 0.obs;
  var hasNext = false.obs;
  var hasPrevious = false.obs;
  var pageNumber = 1.obs;
  var pageSize = 10;
  var fetchedCount = 0.obs;
  Future getNotifications() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$notificationsURL?pageNumber=${pageNumber.value}&pageSize=$pageSize")
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        Map<String, dynamic> result = response.data;
        data.value = NotificationPagedData.fromJson(result);

        totalCount.value = data.value.totalCount;
        totalPages.value = data.value.totalPages;
        hasNext.value = data.value.hasNext;
        hasPrevious.value = data.value.hasPrevious;
        fetchedCount.value =
            ((pageNumber.value - 1) * pageSize) + data.value.data.length;
        notifications.value = data.value.data;
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        timeoutSnackBar();
      } else {
        messageSnackBar(e.response?.data["message"] ?? "حدث خطأ غير متوقع");
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }
}

class NotificationModel {
  int id;
  String title;
  String body;
  DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"] as int,
      title: json["title"] as String,
      body: json["body"] as String,
      createdAt: DateTime.parse(json["createdAt"] as String),
    );
  }
}

class NotificationPagedData {
  List<NotificationModel> data;
  int totalCount;
  int totalPages;
  bool hasNext;
  bool hasPrevious;

  NotificationPagedData({
    required this.data,
    required this.totalCount,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory NotificationPagedData.fromJson(Map<String, dynamic> json) {
    return NotificationPagedData(
        data: (json["data"] as List<dynamic>)
            .map((item) =>
                NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalCount: json["totalCount"] as int,
        totalPages: json["totalPages"] as int,
        hasNext: json["hasNext"] as bool,
        hasPrevious: json["hasPrevious"] as bool);
  }
}
