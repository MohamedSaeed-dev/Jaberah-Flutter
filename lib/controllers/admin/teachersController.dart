import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';

class TeachersController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var nameAddController = TextEditingController().obs;
  var phoneAddController = TextEditingController().obs;

  var nameEditController = TextEditingController().obs;
  var phoneEditController = TextEditingController().obs;

  var searchText = TextEditingController().obs;

  var isLoading = false.obs;

  var isLoadingData = true.obs;
  var isLoadingOperation = false.obs;

  var data = new TeachersPagedData(
          data: [],
          totalCount: 0,
          totalPages: 0,
          hasNext: false,
          hasPrevious: false)
      .obs;

  var teachers = <Teacher>[].obs;
  var totalCount = 0.obs;
  var totalPages = 0.obs;
  var hasNext = false.obs;
  var hasPrevious = false.obs;
  var pageNumber = 1.obs;
  var pageSize = 10;
  var withoutGroups = false.obs;
  var fetchedCount = 0.obs;

  Future getTeachers() async {
    try {
      isLoadingData.value = true;
      var response = await _apiClient.dio
          .get(
              "/$teachersURL?withoutGroups=$withoutGroups&searchText=${searchText.value.text}&pageNumber=${pageNumber.value}&pageSize=$pageSize")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Map<String, dynamic> result = response.data;
        data.value = TeachersPagedData.fromJson(result);
        totalCount.value = data.value.totalCount;
        totalPages.value = data.value.totalPages;
        hasNext.value = data.value.hasNext;
        hasPrevious.value = data.value.hasPrevious;
        fetchedCount.value =
            ((pageNumber.value - 1) * pageSize) + data.value.data.length;
        teachers.value = data.value.data;
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
      isLoadingData.value = false;
    }
  }

  Future<dynamic> addTeacher() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio.post("/$teachersURL", data: {
        "teacherName": nameAddController.value.text,
        "phoneNumber": phoneAddController.value.text,
        "groupsId": selectedGroupsAdd
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201) {
        Get.back();
        successSnackBar('تم اضافة المعلم بنجاح');
        nameAddController.value.text = "";
        phoneAddController.value.text = "";
        selectedGroupsAdd.clear();
        await getTeachers();
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

  var groups = <GroupsSpecial>[].obs;
  var selectedGroupsAdd = [].obs;
  var selectedGroupsEdit = [].obs;

  var isGroupLoading = false.obs;

  Future getGroups() async {
    try {
      isGroupLoading.value = true;
      var response = await _apiClient.dio
          .get("/$groupsWithNoTeachers")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value =
            result.map((item) => GroupsSpecial.fromJson(item)).toList();
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
      isGroupLoading.value = false;
    }
  }

  var groupsSpecial = <GroupsSpecial>[].obs;
  Future getGroupsSpecial({required String id}) async {
    try {
      isGroupLoading.value = true;
      var response = await _apiClient.dio
          .get("/$groupsURL/teachers/$id/has-no-teacher-or-has-teacher")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groupsSpecial.value =
            result.map((item) => GroupsSpecial.fromJson(item)).toList();
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
      isGroupLoading.value = false;
    }
  }

  Future deleteTeacher({required String id}) async {
    try {
      isLoadingOperation.value = true;
      var response = await _apiClient.dio
          .delete("/$teachersURL/$id")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar('تم حذف المعلم بنجاح');
        await getTeachers();
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
      isLoadingOperation.value = false;
    }
  }

  Future updateTeacher({required String id}) async {
    try {
      isLoadingOperation.value = true;
      var response = await _apiClient.dio.put("/$teachersURL/$id", data: {
        "teacherName": nameEditController.value.text,
        "phoneNumber": phoneEditController.value.text,
        "groupsId": selectedGroupsEdit,
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar('تم تحديث بيانات المعلم بنجاح');
        selectedGroupsEdit.clear();
        await getTeachers();
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
      isLoadingOperation.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getTeachers();
  }
}

class Teacher {
  int id;
  String teacherName;
  String phoneNumber;
  List<TeacherGroups>? groups;

  Teacher(
      {required this.id,
      required this.teacherName,
      required this.phoneNumber,
      this.groups});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json["id"] as int,
      teacherName: json["teacherName"] as String,
      phoneNumber: json["phoneNumber"] as String,
      groups: (json["groups"] as List<dynamic>?)
          ?.map((item) => TeacherGroups.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TeacherGroups {
  int id;
  String groupName;

  TeacherGroups({required this.id, required this.groupName});

  factory TeacherGroups.fromJson(Map<String, dynamic> json) {
    return TeacherGroups(
      id: json["groupId"] as int,
      groupName: json["groupName"] as String,
    );
  }
}

class GroupsSpecial {
  int id;
  String groupName;

  GroupsSpecial({required this.id, required this.groupName});

  factory GroupsSpecial.fromJson(Map<String, dynamic> json) {
    return GroupsSpecial(
      id: json["id"] as int,
      groupName: json["groupName"] as String,
    );
  }
}

class TeachersPagedData {
  List<Teacher> data;
  int totalCount;
  int totalPages;
  bool hasNext;
  bool hasPrevious;

  TeachersPagedData(
      {required this.data,
      required this.totalCount,
      required this.totalPages,
      required this.hasNext,
      required this.hasPrevious});

  factory TeachersPagedData.fromJson(Map<String, dynamic> json) {
    return TeachersPagedData(
        data: (json["data"] as List<dynamic>)
            .map((item) => Teacher.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalCount: json["totalCount"] as int,
        totalPages: json["totalPages"] as int,
        hasNext: json["hasNext"] as bool,
        hasPrevious: json["hasPrevious"] as bool);
  }
}
