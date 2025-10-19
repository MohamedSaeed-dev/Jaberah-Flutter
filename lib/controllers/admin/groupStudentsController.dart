import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/models/global/snackbars.dart';

class GroupStudentsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  final id = Get.arguments['Id'];
  final name = Get.arguments['Name'];
  final teacherId = Get.arguments['teacherId'];
  final period1 = Get.arguments["period"];
  var period = "1".obs;

  var searchText = TextEditingController(text: "").obs;

  var groupNameText = TextEditingController(text: '').obs;
  var groupName = ''.obs;

  int? teacherIdText;

  var isGroupChanged = false.obs;
  var isGroupDeleted = false.obs;

  var isLoadingData = true.obs;
  var isLoadingOperation = false.obs;

  var data = new StudentGroupPagedData(
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

  var students = [].obs;

  Future<void> getStudents() async {
    try {
      isLoadingData.value = true;
      var response = await _apiClient.dio
          .get(
              "/$groupsURL/$id/students?searchText=${searchText.value.text}&pageNumber=${pageNumber.value}&pageSize=$pageSize")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Map<String, dynamic> result = response.data;
        data.value = StudentGroupPagedData.fromJson(result);

        totalCount.value = data.value.totalCount;
        totalPages.value = data.value.totalPages;
        hasNext.value = data.value.hasNext;
        hasPrevious.value = data.value.hasPrevious;
        fetchedCount.value =
            ((pageNumber.value - 1) * pageSize) + data.value.data.length;

        students.value = data.value.data;
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

  Future<void> updateGroup() async {
    try {
      isLoadingOperation.value = true;
      var periodNumber = period.value == 'صباحية' ? 1 : 2;
      var response = await _apiClient.dio.put("/$groupsURL/$id", data: {
        "groupName": groupNameText.value.text,
        "period": periodNumber,
        "teacherId": selectedTeacherId.value
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        groupName.value = groupNameText.value.text;
        selectedTeacherId.value = null;
        isGroupChanged.value = true;
        Get.back();
        successSnackBar("تم تحديث الحلقة بنجاح");
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

  Future<void> deleteGroup() async {
    try {
      isLoadingOperation.value = true;
      var response = await _apiClient.dio
          .delete("/$groupsURL/$id")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        isGroupDeleted.value = true;
        isLoadingOperation.value = false;
        Get.back();
        Get.back();
        successSnackBar("تم حذف الحلقة بنجاح");
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

  var teachersForGeneralUse = <TeachersForGeneralUse>[].obs;
  Rxn<int> selectedTeacherId = Rxn<int>();
  Future getTeachers() async {
    try {
      var response = await _apiClient.dio
          .get("/$teachersForGeneralUseURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        teachersForGeneralUse.value =
            result.map((item) => TeachersForGeneralUse.fromJson(item)).toList();
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
    }
  }

  @override
  void onInit() {
    super.onInit();
    groupName.value = name;
    teacherIdText = teacherId;
    period.value = period1.toString();
    getStudents();
  }

  @override
  void onClose() {
    super.onClose();
    if (isGroupChanged.value || isGroupDeleted.value) {
      Get.find<GroupsController>().getGroups();
      isGroupChanged.value = false;
      isGroupDeleted.value = false;
    }
  }
}

class StudentsOfGroupController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoadingOperation = false.obs;
  var isStudentDeleted = false.obs;

  final nameController = TextEditingController().obs;
  final phoneController = TextEditingController().obs;
  final rateController = TextEditingController().obs;
  final levelController = TextEditingController().obs;
  final notesController = TextEditingController().obs;
  final studyLevelController = TextEditingController().obs;
  var selectedSchoolClass = 'المرحلة الابتدائية'.obs;

  Future<void> deleteStudent({required int id}) async {
    try {
      isLoadingOperation.value = true;
      var response = await _apiClient.dio
          .delete("/$studentsURL/$id")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar('تم حذف الطالب بنجاح');
        Get.find<GroupStudentsController>().getStudents();
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

  Future<void> updateStudent({required int id}) async {
    try {
      isLoadingOperation.value = true;
      var response = await _apiClient.dio.put("/$studentsURL/$id", data: {
        "studentName": nameController.value.text,
        "phoneNumber": phoneController.value.text,
        "schoolLevel": levelController.value.text,
        "schoolClass": selectedSchoolClass.value,
        "memoRate": rateController.value.text,
        "notes": notesController.value.text,
        "studyLevel": studyLevelController.value.text,
        "groupId": Get.find<GroupStudentsController>().id
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar('تم تحديث بيانات الطالب بنجاح');
        Get.find<GroupStudentsController>().getStudents();
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
}

class StudentGroup {
  int id;
  String studentName;
  String phoneNumber;
  String? schoolClass;
  int? memoRate;
  String? schoolLevel;
  String? notes;
  String? studyLevel;
  StudentGroup(
      {required this.id,
      required this.studentName,
      required this.phoneNumber,
      this.schoolClass,
      this.memoRate,
      this.schoolLevel,
      this.notes,
      this.studyLevel});

  factory StudentGroup.fromJson(Map<String, dynamic> json) {
    return StudentGroup(
      id: json["id"] as int,
      studentName: json["studentName"] as String,
      phoneNumber: json["phoneNumber"] as String,
      schoolClass:
          json["schoolClass"] != null ? json["schoolClass"] as String : null,
      memoRate: json["memoRate"] != null ? json["memoRate"] as int : null,
      schoolLevel:
          json["schoolLevel"] != null ? json["schoolLevel"] as String : null,
      notes: json["notes"] != null ? json["notes"] as String : null,
      studyLevel: json["studyLevel"] != null ? json["studyLevel"] as String : null,
    );
  }
}

class StudentGroupPagedData {
  List<StudentGroup> data;
  int totalCount;
  int totalPages;
  bool hasNext;
  bool hasPrevious;

  StudentGroupPagedData(
      {required this.data,
      required this.totalCount,
      required this.totalPages,
      required this.hasNext,
      required this.hasPrevious});

  factory StudentGroupPagedData.fromJson(Map<String, dynamic> json) {
    return StudentGroupPagedData(
        data: (json["data"] as List<dynamic>)
            .map((item) => StudentGroup.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalCount: json["totalCount"] as int,
        totalPages: json["totalPages"] as int,
        hasNext: json["hasNext"] as bool,
        hasPrevious: json["hasPrevious"] as bool);
  }
}
