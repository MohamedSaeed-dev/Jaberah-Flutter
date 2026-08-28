import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CleaningLogController extends GetxController {
  final ApiClient _apiClient = Get.find();

  var selectedDate =
      JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  /// الحلقة المستخدمة لتصفية قائمة الطلاب عند الإسناد (null = كل حلقاتي)
  Rxn<int> selectedGroupId = Rxn<int>();

  var teacherGroups = <Group>[].obs;
  var dailyTasks = <DailyCleaningTask>[].obs;
  var assignableStudents = <AssignableStudent>[].obs;

  var searchText = TextEditingController().obs;

  var isLoadingGroups = false.obs;
  var isLoadingDaily = false.obs;
  var isLoadingStudents = false.obs;
  var isUpserting = false.obs;

  var studentsPageNumber = 1.obs;
  final studentsPageSize = 10;
  var studentsTotalCount = 0.obs;
  var studentsHasNext = false.obs;
  var studentsHasPrevious = false.obs;

  /// التاريخ الميلادي بصيغة yyyy-MM-dd للإرسال للـ API
  String get dateStr {
    final d = selectedDate.value.dateTime;
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void setSelectedDate(JDateModel model) {
    selectedDate.value = model;
    loadDailyTasks();
  }

  void setGroupFilter(int? groupId) {
    selectedGroupId.value = groupId;
    studentsPageNumber.value = 1;
  }

  Future<void> loadTeacherGroups() async {
    try {
      isLoadingGroups.value = true;
      final prefs = await SharedPreferences.getInstance();
      final teacherId = prefs.getString('id');
      if (teacherId == null) return;
      final response = await _apiClient.dio
          .get('/$teachersURL/$teacherId/groups')
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final list = response.data is List ? response.data as List : [];
        teacherGroups.value =
            list.map((e) => Group.fromJson(e as Map<String, dynamic>)).toList();
        if (teacherGroups.isEmpty) {
          selectedGroupId.value = null;
        }
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else {
        messageSnackBar(apiErrorMessage(e.response?.data));
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingGroups.value = false;
    }
  }

  Future<void> loadDailyTasks() async {
    if (dateStr.isEmpty) return;
    try {
      isLoadingDaily.value = true;
      final response = await _apiClient.dio
          .get('/$cleaningLogsDailyURL?date=$dateStr')
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final list = response.data is List ? response.data as List : [];
        dailyTasks.value = list
            .map((e) => DailyCleaningTask.fromJson(e is Map<String, dynamic>
                ? e
                : Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        dailyTasks.clear();
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        timeoutSnackBar();
      } else {
        messageSnackBar(apiErrorMessage(e.response?.data));
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingDaily.value = false;
    }
  }

  Future<void> loadAssignableStudents() async {
    if (dateStr.isEmpty) return;
    try {
      isLoadingStudents.value = true;

      final query = <String, dynamic>{
        'date': dateStr,
        'pageNumber': studentsPageNumber.value,
        'pageSize': studentsPageSize,
      };
      if (selectedGroupId.value != null) {
        query['groupId'] = selectedGroupId.value;
      }
      final search = searchText.value.text.trim();
      if (search.isNotEmpty) query['search'] = search;

      final response = await _apiClient.dio
          .get('/$cleaningLogsAssignableStudentsURL', queryParameters: query)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] is List ? data['data'] as List : [];
        assignableStudents.value = list
            .map((e) => AssignableStudent.fromJson(e is Map<String, dynamic>
                ? e
                : Map<String, dynamic>.from(e as Map)))
            .toList();
        studentsTotalCount.value =
            data['totalCount'] is int ? data['totalCount'] as int : list.length;
        studentsHasNext.value = data['hasNext'] == true;
        studentsHasPrevious.value = data['hasPrevious'] == true;
      } else {
        assignableStudents.clear();
        studentsTotalCount.value = 0;
        studentsHasNext.value = false;
        studentsHasPrevious.value = false;
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        timeoutSnackBar();
      } else {
        messageSnackBar(apiErrorMessage(e.response?.data));
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingStudents.value = false;
    }
  }

  void searchStudents() {
    studentsPageNumber.value = 1;
    loadAssignableStudents();
  }

  void nextStudentsPage() {
    if (studentsHasNext.value) {
      studentsPageNumber.value++;
      loadAssignableStudents();
    }
  }

  void prevStudentsPage() {
    if (studentsHasPrevious.value) {
      studentsPageNumber.value--;
      loadAssignableStudents();
    }
  }

  /// تحديث جزئي لمهمة واحدة، و studentId = null تعني إلغاء الإسناد.
  Future<bool> upsertTask({
    required int cleaningTaskId,
    required int? studentId,
    required bool isCompleted,
    String? notes,
  }) async {
    try {
      isUpserting.value = true;
      await _apiClient.dio.post(
        '/$cleaningLogsUpsertDailyURL',
        data: {
          'date': dateStr,
          'logs': [
            {
              'cleaningTaskId': cleaningTaskId,
              'studentId': studentId,
              'isCompleted': isCompleted,
              'notes': notes,
            }
          ],
        },
      ).timeout(const Duration(seconds: 20));
      successSnackBar(studentId == null
          ? 'تم إلغاء إسناد المهمة'
          : 'تم حفظ كشف النظافة');
      await loadDailyTasks();
      return true;
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        timeoutSnackBar();
      } else {
        messageSnackBar(
            apiErrorMessage(e.response?.data, fallback: 'فشل الحفظ'));
      }
      return false;
    } catch (e) {
      catchSnackBar();
      return false;
    } finally {
      isUpserting.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async {
      await loadTeacherGroups();
      await loadDailyTasks();
    });
  }

  @override
  void onClose() {
    searchText.value.dispose();
    super.onClose();
  }
}

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

int? _asNullableInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

class DailyCleaningTask {
  final int cleaningTaskId;
  final String taskName;
  final int displayOrder;
  final bool isEditableByMe;
  final CleaningLogInfo? log;

  DailyCleaningTask({
    required this.cleaningTaskId,
    required this.taskName,
    required this.displayOrder,
    required this.isEditableByMe,
    this.log,
  });

  factory DailyCleaningTask.fromJson(Map<String, dynamic> json) {
    final log = json['log'];
    return DailyCleaningTask(
      cleaningTaskId: _asInt(json['cleaningTaskId']),
      taskName: json['taskName']?.toString() ?? '',
      displayOrder: _asInt(json['displayOrder']),
      isEditableByMe: json['isEditableByMe'] != false,
      log: log is Map
          ? CleaningLogInfo.fromJson(
              log is Map<String, dynamic> ? log : Map<String, dynamic>.from(log))
          : null,
    );
  }
}

class CleaningLogInfo {
  final int logId;
  final int studentId;
  final String studentName;
  final int? groupId;
  final String? groupName;
  final bool isCompleted;
  final String? notes;

  CleaningLogInfo({
    required this.logId,
    required this.studentId,
    required this.studentName,
    this.groupId,
    this.groupName,
    required this.isCompleted,
    this.notes,
  });

  factory CleaningLogInfo.fromJson(Map<String, dynamic> json) {
    return CleaningLogInfo(
      logId: _asInt(json['logId']),
      studentId: _asInt(json['studentId']),
      studentName: json['studentName']?.toString() ?? '',
      groupId: _asNullableInt(json['groupId']),
      groupName: json['groupName']?.toString(),
      isCompleted: json['isCompleted'] == true,
      notes: json['notes']?.toString(),
    );
  }
}

class AssignableStudent {
  final int studentId;
  final String studentName;
  final int? groupId;
  final String? groupName;
  final List<String> assignedTaskNames;

  AssignableStudent({
    required this.studentId,
    required this.studentName,
    this.groupId,
    this.groupName,
    required this.assignedTaskNames,
  });

  factory AssignableStudent.fromJson(Map<String, dynamic> json) {
    final names = json['assignedTaskNames'];
    return AssignableStudent(
      studentId: _asInt(json['studentId']),
      studentName: json['studentName']?.toString() ?? '',
      groupId: _asNullableInt(json['groupId']),
      groupName: json['groupName']?.toString(),
      assignedTaskNames: names is List
          ? names.map((e) => e?.toString() ?? '').toList()
          : <String>[],
    );
  }
}
