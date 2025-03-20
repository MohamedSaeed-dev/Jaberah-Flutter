import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';

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
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } on DioException catch (e) {
      messageSnackBar(e.response!.data["message"]);
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoading.value = false;
    }
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
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } on DioException catch (e) {
      messageSnackBar(e.response!.data["message"]);
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
            0, TeachersForGeneralUse(id: null,teacherName:  "بدون معلم"));
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

  Group(
      {required this.id,
      required this.groupName,
      this.teacherId,
      this.teacherName,
      required this.period,
      required this.studentsNo});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
        id: json["id"] as int,
        groupName: json["groupName"] as String,
        teacherId: json["teacherId"] != null ? json["teacherId"] as int : null,
        teacherName:
            json["teacherName"] != null ? json["teacherName"] as String : null,
        period: json["period"] as String,
        studentsNo: json["studentsNo"] as int);
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
