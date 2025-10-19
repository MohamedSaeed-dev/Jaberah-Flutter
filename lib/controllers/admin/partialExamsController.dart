import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsPartialExamsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var groupName = "".obs;
  var isLoading = false.obs;
  var groups = <Group>[].obs;

  Future<void> getGroups() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get("/$groupsURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value = result.map((item) => Group.fromJson(item)).toList();

        // Apply saved order
        await _applySavedOrder();
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

  Future<void> _applySavedOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedOrderJson = prefs.getString('groups_order');

      if (savedOrderJson != null) {
        List<int> savedOrder = List<int>.from(json.decode(savedOrderJson));

        // Create a map for quick lookup
        Map<int, Group> groupsMap = {for (var group in groups) group.id: group};

        // Reorder based on saved order
        List<Group> orderedGroups = [];
        for (int id in savedOrder) {
          if (groupsMap.containsKey(id)) {
            orderedGroups.add(groupsMap[id]!);
            groupsMap.remove(id);
          }
        }

        // Add any new groups that weren't in the saved order
        orderedGroups.addAll(groupsMap.values);

        groups.value = orderedGroups;
      }
    } catch (e) {
      // If there's any error loading saved order, just use the original order
    }
  }

  @override
  void onInit() {
    super.onInit();
    getGroups();
  }
}
