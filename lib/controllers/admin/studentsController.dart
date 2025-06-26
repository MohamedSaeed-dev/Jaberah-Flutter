import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/addStudentController.dart';
import 'package:jaberah/models/global/snackbars.dart';

class StudentsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  final nameAddController = TextEditingController().obs;
  final phoneAddController = TextEditingController().obs;
  final rateAddController = TextEditingController().obs;
  final levelAddController = TextEditingController().obs;
  final notesAddController = TextEditingController().obs;
  var selectedAddSchoolClass = 'المرحلة الابتدائية'.obs;

  var searchText = TextEditingController().obs;

  var isLoading = false.obs;

  var isLoadingData = true.obs;
  var isLoadingOperation = false.obs;

  var data = new StudentsPagedData(
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
  var withoutGroup = false.obs;
  var fetchedCount = 0.obs;

  var students = <Student>[].obs;

  Future getStudents() async {
    try {
      isLoadingData.value = true;
      var response = await _apiClient.dio
          .get(
              "/$studentsURL?withoutGroup=${withoutGroup.value}&searchText=${searchText.value.text}&pageNumber=${pageNumber.value}&pageSize=${pageSize}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Map<String, dynamic> result = response.data;
        data.value = StudentsPagedData.fromJson(result);
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

  Rxn<int> selectedGroupAddId = Rxn();
  var selectedGroupEditName = "".obs;
  Rxn<int> selectedGroupEditId = Rxn();
  Future<dynamic> addStudent() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio.post("/$studentsURL", data: {
        "studentName": nameAddController.value.text,
        "phoneNumber": phoneAddController.value.text,
        "schoolLevel": levelAddController.value.text,
        "schoolClass": selectedAddSchoolClass.value,
        "memoRate": int.tryParse( rateAddController.value.text),
        "notes": notesAddController.value.text,
        "groupId": selectedGroupAddId.value
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201) {
        Get.back();
        successSnackBar('تم اضافة الطالب بنجاح');
        await getStudents();
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

  var groups = <GroupsForGeneralUse>[].obs;

  var isGroupLoading = false.obs;

  Future getGroups() async {
    try {
      isGroupLoading.value = true;
      var response = await _apiClient.dio
          .get("/$groupsURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value =
            result.map((item) => GroupsForGeneralUse.fromJson(item)).toList();
        groups.insert(0, GroupsForGeneralUse(id: null, groupName: "بدون حلقة"));
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

  // Future deleteStudent({required String id}) async {
  //   try {
  //     isLoadingOperation.value = true;
  //     var response = await http
  //         .delete(Uri.parse("$studentsURL/$id"))
  //         .timeout(const Duration(seconds: 15));
  //     if (response.statusCode == 200) {
  //       await getStudents();
  //     } else {
  //       var result = jsonDecode(response.body);
  //       messageSnackBar(result["message"]);
  //     }
  //   } on SocketException catch (_) {
  //     socketSnackBar();
  //   } on TimeoutException catch (_) {
  //     timeoutSnackBar();
  //   } catch (e) {
  //     catchSnackBar();
  //   } finally {
  //     isLoadingOperation.value = false;
  //   }
  // }

  // Future updateStudent({required String id}) async {
  //   try {
  //     isLoadingOperation.value = true;
  //     var response = await http.put(
  //       Uri.parse("$studentsURL/$id"),
  //       body: jsonEncode({
  //         "teacherName": nameEditController.value.text,
  //         "phone": phoneEditController.value.text,
  //         "groupId": selectedGroupsEdit,
  //       }),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     ).timeout(const Duration(seconds: 15));

  //     if (response.statusCode == 200) {
  //       getStudents();
  //     } else {
  //       var result = jsonDecode(response.body);
  //       messageSnackBar(result["message"]);
  //     }
  //   } on SocketException catch (_) {
  //     socketSnackBar();
  //   } on TimeoutException catch (_) {
  //     timeoutSnackBar();
  //   } catch (e) {
  //     catchSnackBar();
  //   } finally {
  //     isLoadingOperation.value = false;
  //   }
  // }

  @override
  void onInit() {
    getStudents();
    super.onInit();
  }

  var isStudentDeleted = false.obs;

  final nameEditController = TextEditingController().obs;
  final phoneEditController = TextEditingController().obs;
  final rateEditController = TextEditingController().obs;
  final levelEditController = TextEditingController().obs;
  final notesEditController = TextEditingController().obs;

  var selectedEditSchoolClass = 'المرحلة الابتدائية'.obs;

  Future<void> deleteStudent({required String id}) async {
    try {
      isLoadingOperation.value = true;
      var response = await _apiClient.dio
          .delete("/$studentsURL/$id")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar('تم حذف الطالب بنجاح');
        await getStudents();
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingOperation.value = false;
    }
  }

  Future<void> updateStudent({required String id}) async {
    try {
      isLoadingOperation.value = true;
      var response = await _apiClient.dio.put("/$studentsURL/$id", data: {
        "studentName": nameEditController.value.text,
        "phoneNumber": phoneEditController.value.text,
        "schoolLevel": levelEditController.value.text,
        "schoolClass": selectedEditSchoolClass.value,
        "memoRate": int.tryParse( rateEditController.value.text),
        "notes": notesEditController.value.text,
        "groupId": selectedGroupEditId.value
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar('تم تحديث بيانات الطالب بنجاح');
        await getStudents();
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingOperation.value = false;
    }
  }
}

class Student {
  int id;
  String studentName;
  String phoneNumber;
  String? schoolClass;
  int? memoRate;
  String? schoolLevel;
  int? groupId;
  String? groupName;
  String? notes;

  Student(
      {required this.id,
      required this.studentName,
      required this.phoneNumber,
      this.schoolClass,
      this.memoRate,
      this.groupId,
      this.groupName,
      this.schoolLevel,
      this.notes});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json["id"] as int,
      studentName: json["studentName"] as String,
      phoneNumber: json["phoneNumber"] as String,
      schoolClass:
          json["schoolClass"] != null ? json["schoolClass"] as String : null,
      memoRate: json["memoRate"] != null ? json["memoRate"] as int : null,
      groupId: json["groupId"] != null ? json["groupId"] as int : null,
      groupName: json["groupName"] != null ? json["groupName"] as String : null,
      schoolLevel:
          json["schoolLevel"] != null ? json["schoolLevel"] as String : null,
      notes: json["notes"] != null ? json["notes"] as String : null,
    );
  }
}

class StudentsPagedData {
  List<Student> data;
  int totalCount;
  int totalPages;
  bool hasNext;
  bool hasPrevious;

  StudentsPagedData(
      {required this.data,
      required this.totalCount,
      required this.totalPages,
      required this.hasNext,
      required this.hasPrevious});

  factory StudentsPagedData.fromJson(Map<String, dynamic> json) {
    return StudentsPagedData(
        data: (json["data"] as List<dynamic>)
            .map((item) => Student.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalCount: json["totalCount"] as int,
        totalPages: json["totalPages"] as int,
        hasNext: json["hasNext"] as bool,
        hasPrevious: json["hasPrevious"] as bool);
  }
}
