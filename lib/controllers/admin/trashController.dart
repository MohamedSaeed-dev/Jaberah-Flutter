import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';

class TrashController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var groupsTrash = <GroupsTrashModel>[].obs;
  var studentsTrash = <StudentsTrashModel>[].obs;
  var teachersTrash = <TeachersTrashModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getGroupsTrashRecords();
  }

  Future getGroupsTrashRecords() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get("/$groupsURL/deleted")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groupsTrash.value =
            result.map((item) => GroupsTrashModel.fromJson(item)).toList();
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

  Future getStudentsTrashRecords() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get("/$studentsURL/deleted")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        studentsTrash.value =
            result.map((item) => StudentsTrashModel.fromJson(item)).toList();
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

  Future getTeachersTrashRecords() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get("/$teachersURL/deleted")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        teachersTrash.value =
            result.map((item) => TeachersTrashModel.fromJson(item)).toList();
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

  // Helper method to get records by type.
  List<dynamic> getTrashRecords(String type) {
    switch (type) {
      case 'students':
        return studentsTrash;
      case 'groups':
        return groupsTrash;
      case 'teachers':
        return teachersTrash;
      default:
        return [];
    }
  }

  // Wrapper for restore operation based on type.
  Future<void> restoreRecord({required int id, required String type}) async {
    switch (type) {
      case 'students':
        await restoreStudent(id: id);
        break;
      case 'groups':
        await restoreGroup(id: id);
        break;
      case 'teachers':
        await restoreTeacher(id: id);
        break;
    }
  }

  // Wrapper for permanent delete operation based on type.
  Future<void> deleteRecordPermanently(
      {required int id, required String type}) async {
    switch (type) {
      case 'students':
        await deleteStudentPermanently(id: id);
        break;
      case 'groups':
        await deleteGroupPermanently(id: id);
        break;
      case 'teachers':
        await deleteTeacherPermanently(id: id);
        break;
    }
  }

  Future<void> restoreStudent({required int id}) async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .patch("/$studentsURL/$id/restore")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        await getStudentsTrashRecords();
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

  Future<void> restoreGroup({required int id}) async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .patch("/$groupsURL/$id/restore")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        await getGroupsTrashRecords();
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

  Future<void> restoreTeacher({required int id}) async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .patch("/$teachersURL/$id/restore")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        await getTeachersTrashRecords();
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

  Future<void> deleteStudentPermanently({required int id}) async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .delete("/$studentsURL/$id/ever")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        await getStudentsTrashRecords();
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

  Future<void> deleteGroupPermanently({required int id}) async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .delete("/$groupsURL/$id/ever")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        await getGroupsTrashRecords();
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

  Future<void> deleteTeacherPermanently({required int id}) async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .delete("/$teachersURL/$id/ever")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        await getTeachersTrashRecords();
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
}

class GroupsTrashModel {
  int id;
  String groupName;
  String period;

  GroupsTrashModel({
    required this.id,
    required this.groupName,
    required this.period,
  });

  factory GroupsTrashModel.fromJson(Map<String, dynamic> json) {
    return GroupsTrashModel(
      id: json['id'],
      groupName: json['groupName'],
      period: json['period'],
    );
  }
}

class StudentsTrashModel {
  int id;
  String studentName;
  String phoneNumber;

  StudentsTrashModel({
    required this.id,
    required this.studentName,
    required this.phoneNumber,
  });

  factory StudentsTrashModel.fromJson(Map<String, dynamic> json) {
    return StudentsTrashModel(
      id: json['id'],
      studentName: json['studentName'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class TeachersTrashModel {
  int id;
  String teacherName;
  String phoneNumber;

  TeachersTrashModel({
    required this.id,
    required this.teacherName,
    required this.phoneNumber,
  });

  factory TeachersTrashModel.fromJson(Map<String, dynamic> json) {
    return TeachersTrashModel(
      id: json['id'],
      teacherName: json['teacherName'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
