import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsFollowStudentsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var groupName = "".obs;
  var isLoading = false.obs;
  var groups = <Group>[].obs;

  Future<void> getGroups() async {
    var sp = await SharedPreferences.getInstance();
    var teacherId = sp.getString("id");
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get("/$teachersURL/$teacherId/groups")
          .timeout(const Duration(seconds: 20));
      List<dynamic> result = response.data;
      if (response.statusCode == 200) {
        groups.value = result.map((item) => Group.fromJson(item)).toList();
      } else {
        messageSnackBar(apiErrorMessage(response.data));
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        timeoutSnackBar();
      } else {
        messageSnackBar(apiErrorMessage(e.response?.data, fallback: "حدث خطأ غير متوقع"));
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
    getGroups();
  }
}
