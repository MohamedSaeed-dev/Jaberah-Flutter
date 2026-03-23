import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var groupName = "".obs;
  var isLoading = false.obs;
  var groups = <Group>[].obs;
  var teachersForGeneralUse = <TeachersForGeneralUse>[].obs;
  var groupNameController = TextEditingController(text: 'حلقة ').obs;
  var withoutTeacher = false.obs;
  var period = 'صباحية'.obs;
  Rxn<int> selectedTeacherId = Rxn<int>();

  Future<void> getGroups() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get("/$groupsURL?withoutTeacher=${withoutTeacher.value}")
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

  Future<void> _saveOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<int> orderIds = groups.map((group) => group.id).toList();
      await prefs.setString('groups_order', json.encode(orderIds));
    } catch (e) {}
  }

  Future addGroup() async {
    try {
      isLoading.value = true;
      var periodNumber = period.value == "صباحية" ? 1 : 2;
      var response = await _apiClient.dio.post("/$groupsURL", data: {
        "groupName": groupNameController.value.text,
        "period": periodNumber,
        "teacherId": selectedTeacherId.value
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201) {
        Get.back();
        groupNameController.value.text = 'حلقة ';
        selectedTeacherId.value = null;
        await getGroups();
        successSnackBar("تم اضافة الحلقة بنجاح");
      } else {
        messageSnackBar(response.data["message"]);
      }
      return response;
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

  Future getTeachers() async {
    try {
      var response = await _apiClient.dio.get("/$teachersForGeneralUseURL");
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        teachersForGeneralUse.value =
            result.map((item) => TeachersForGeneralUse.fromJson(item)).toList();
        teachersForGeneralUse.insert(
            0, TeachersForGeneralUse(id: null, teacherName: "بدون معلم"));
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } catch (e) {
      catchSnackBar();
    }
  }

  void reorderGroups(int oldIndex, int newIndex) {
    // إنشاء نسخة من القائمة
    List<Group> newList = List<Group>.from(groups);

    // إزالة العنصر من موقعه القديم
    final Group item = newList.removeAt(oldIndex);

    // إدراج العنصر في الموقع الجديد
    newList.insert(newIndex, item);

    // تحديث القائمة الأصلية
    groups.value = newList;

    // Save the new order permanently
    _saveOrder();
  }

  @override
  void onInit() {
    super.onInit();
    getGroups();
  }
}

class Group {
  int id;
  String groupName;
  int? teacherId;
  String? teacherName;
  String period;
  int studentsNo;
  String? windowStart;
  String? windowEnd;
  int? flexibleMinutes;

  Group(
      {required this.id,
      required this.groupName,
      this.teacherId,
      this.teacherName,
      required this.period,
      required this.studentsNo,
      this.windowStart,
      this.windowEnd,
      this.flexibleMinutes});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
        id: json["id"] as int,
        groupName: json["groupName"] as String,
        teacherId: json["teacherId"] != null ? json["teacherId"] as int : null,
        teacherName:
            json["teacherName"] != null ? json["teacherName"] as String : null,
        period: Group.periodToUiString(json["period"]),
        studentsNo: json["studentsNo"] as int,
        windowStart: json["windowStart"]?.toString(),
        windowEnd: json["windowEnd"]?.toString(),
        flexibleMinutes: json["flexibleMinutes"] != null
            ? int.tryParse(json["flexibleMinutes"].toString())
            : null);
  }

  /// يدعم الفترة كرقم (1/2) أو نص من الـ API.
  static String periodToUiString(dynamic value) {
    if (value == null) return 'صباحية';
    if (value is int) return value == 1 ? 'صباحية' : 'مسائية';
    final s = value.toString().trim();
    if (s == '1' || s == 'صباحية') return 'صباحية';
    if (s == '2' || s == 'مسائية') return 'مسائية';
    return s;
  }
}

class TeachersForGeneralUse {
  int? id;
  String teacherName;

  TeachersForGeneralUse({required this.id, required this.teacherName});

  factory TeachersForGeneralUse.fromJson(Map<String, dynamic> json) {
    return TeachersForGeneralUse(
        id: json["id"] as int, teacherName: json["teacherName"] as String);
  }
}
