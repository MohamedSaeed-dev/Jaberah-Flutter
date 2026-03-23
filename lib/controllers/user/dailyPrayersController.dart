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

class DailyPrayersController extends GetxController {
  final ApiClient _apiClient = Get.find();

  var selectedDate =
      JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;
  var searchText = TextEditingController().obs;
  Rxn<int> selectedGroupId = Rxn<int>();

  var teacherGroups = <Group>[].obs;
  var prayersList = <PrayerItem>[].obs;
  var dailyStudents = <StudentDailyPrayer>[].obs;

  var isLoadingGroups = false.obs;
  var isLoadingPrayers = false.obs;
  var isLoadingDaily = false.obs;
  var isUpserting = false.obs;

  var pageNumber = 1.obs;
  final pageSize = 10;
  var totalCount = 0.obs;
  var totalPages = 0.obs;
  var hasNext = false.obs;
  var hasPrevious = false.obs;

  /// التاريخ الميلادي بصيغة yyyy-MM-dd للإرسال للـ API
  String get dateStr {
    final d = selectedDate.value.dateTime;
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void setSelectedDate(JDateModel model) {
    selectedDate.value = model;
    pageNumber.value = 1;
    loadDailyPrayers();
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
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else {
        messageSnackBar(e.response?.data['message'] ?? 'حدث خطأ');
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingGroups.value = false;
    }
  }

  Future<void> loadPrayers() async {
    try {
      isLoadingPrayers.value = true;
      final response = await _apiClient.dio
          .get('/$prayersURL?pageNumber=1&pageSize=50')
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final body = response.data;
        final list = body is List
            ? body
            : (body is Map && body['data'] != null)
                ? body['data'] as List
                : [];
        prayersList.value = list
            .map((e) => PrayerItem.fromJson(e is Map<String, dynamic>
                ? e
                : Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else {
        messageSnackBar(e.response?.data['message'] ?? 'حدث خطأ');
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingPrayers.value = false;
    }
  }

  Future<void> loadDailyPrayers() async {
    try {
      isLoadingDaily.value = true;

      // // عند «كل الحلقات» يجب إرسال GroupsId لكل حلقات المعلم، وإلا الـ API يعيد كل الطلاب
      // if (selectedGroupId.value == null && teacherGroups.isEmpty) {
      //   await loadTeacherGroups();
      //   if (teacherGroups.isEmpty) {
      //     dailyStudents.clear();
      //     totalCount.value = 0;
      //     totalPages.value = 0;
      //     hasNext.value = false;
      //     hasPrevious.value = false;
      //     return;
      //   }
      // }

      final queryParts = <String>[
        'Date=$dateStr',
        'pageNumber=${pageNumber.value}',
        'pageSize=$pageSize',
      ];
      if (selectedGroupId.value != null) {
        queryParts.add('GroupsId=${selectedGroupId.value}');
      } else {
        for (final g in teacherGroups) {
          queryParts.add('GroupsId=${g.id}');
        }
      }
      var path = '/$prayersURL/daily?${queryParts.join('&')}';
      if (searchText.value.text.trim().isNotEmpty) {
        path += '&search=${Uri.encodeComponent(searchText.value.text.trim())}';
      }
      final response =
          await _apiClient.dio.get(path).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final list = data['data'] is List ? data['data'] as List : [];
          dailyStudents.value = list
              .map((e) => StudentDailyPrayer.fromJson(e is Map<String, dynamic>
                  ? e
                  : Map<String, dynamic>.from(e as Map)))
              .toList();
          totalCount.value = data['totalCount'] is int
              ? data['totalCount'] as int
              : list.length;
          totalPages.value =
              data['totalPages'] is int ? data['totalPages'] as int : 1;
          hasNext.value = data['hasNext'] == true;
          hasPrevious.value = data['hasPrevious'] == true;
        } else if (data is List) {
          dailyStudents.value = data
              .map((e) => StudentDailyPrayer.fromJson(e is Map<String, dynamic>
                  ? e
                  : Map<String, dynamic>.from(e as Map)))
              .toList();
          totalCount.value = dailyStudents.length;
          totalPages.value = 1;
          hasNext.value = false;
          hasPrevious.value = false;
        }
      } else if (response.statusCode == 204) {
        dailyStudents.clear();
        totalCount.value = 0;
        totalPages.value = 0;
        hasNext.value = false;
        hasPrevious.value = false;
      } else {
        messageSnackBar(response.data['message'] ?? 'حدث خطأ');
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        socketSnackBar();
      } else {
        messageSnackBar(e.response?.data['message'] ?? 'حدث خطأ');
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingDaily.value = false;
    }
  }

  Future<void> upsertDaily({
    required int studentId,
    required List<PrayerUpdateDTO> prayers,
  }) async {
    try {
      isUpserting.value = true;
      await _apiClient.dio.post(
        '/$prayersURL/upsert-daily',
        data: {
          'studentId': studentId,
          'date': dateStr,
          'prayers': prayers.map((e) => e.toJson()).toList(),
        },
      ).timeout(const Duration(seconds: 20));
      successSnackBar('تم حفظ كشف الصلوات');
      await loadDailyPrayers();
    } on DioException catch (e) {
      messageSnackBar(e.response?.data['message'] ?? 'فشل الحفظ');
    } catch (e) {
      catchSnackBar();
    } finally {
      isUpserting.value = false;
    }
  }

  void setGroupFilter(int? groupId) {
    selectedGroupId.value = groupId;
    pageNumber.value = 1;
    loadDailyPrayers();
  }

  void applySearch() {
    pageNumber.value = 1;
    loadDailyPrayers();
  }

  void nextPage() {
    if (hasNext.value) {
      pageNumber.value++;
      loadDailyPrayers();
    }
  }

  void prevPage() {
    if (hasPrevious.value) {
      pageNumber.value--;
      loadDailyPrayers();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadPrayers();
    Future.microtask(() async {
      await loadTeacherGroups();
      await loadDailyPrayers();
    });
  }

  @override
  void onClose() {
    searchText.value.dispose();
    super.onClose();
  }
}

class PrayerItem {
  int id;
  String nameAr;
  String nameEn;
  int defaultRakats;

  PrayerItem(
      {required this.id,
      required this.nameAr,
      required this.nameEn,
      required this.defaultRakats});

  factory PrayerItem.fromJson(Map<String, dynamic> json) {
    return PrayerItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nameAr: json['nameAr']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      defaultRakats: json['defaultRakats'] is int
          ? json['defaultRakats'] as int
          : int.tryParse(json['defaultRakats']?.toString() ?? '0') ?? 0,
    );
  }
}

class StudentDailyPrayer {
  int studentId;
  String studentName;
  String? groupName;
  List<PrayerStatusDto> prayers;

  StudentDailyPrayer({
    required this.studentId,
    required this.studentName,
    this.groupName,
    required this.prayers,
  });

  factory StudentDailyPrayer.fromJson(Map<String, dynamic> json) {
    final list = json['prayers'] is List ? json['prayers'] as List : [];
    return StudentDailyPrayer(
      studentId: json['studentId'] is int
          ? json['studentId'] as int
          : int.tryParse(json['studentId']?.toString() ?? '0') ?? 0,
      studentName: json['studentName']?.toString() ?? '',
      groupName: json['groupName']?.toString(),
      prayers: list
          .map((e) => PrayerStatusDto.fromJson(e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class PrayerStatusDto {
  int? prayerId;
  String prayerName;
  int defaultRakat;
  PrayerAttendanceInfo attendanceInfo;

  PrayerStatusDto({
    this.prayerId,
    required this.prayerName,
    required this.defaultRakat,
    required this.attendanceInfo,
  });

  factory PrayerStatusDto.fromJson(Map<String, dynamic> json) {
    final att = json['attendanceInfo'];
    return PrayerStatusDto(
      prayerId: json['prayerId'] is int
          ? json['prayerId'] as int
          : (json['PrayerId'] is int ? json['PrayerId'] as int : null),
      prayerName: (json['prayerName'] ?? json['PrayerName'])?.toString() ?? '',
      defaultRakat:
          json['defaultRakat'] is int ? json['defaultRakat'] as int : 0,
      attendanceInfo: att != null && att is Map
          ? PrayerAttendanceInfo.fromJson(att is Map<String, dynamic>
              ? att
              : Map<String, dynamic>.from(att))
          : PrayerAttendanceInfo(rakatsCount: 0, isInGroup: false),
    );
  }
}

class PrayerAttendanceInfo {
  int? rakatsCount;
  bool isInGroup;

  PrayerAttendanceInfo({this.rakatsCount, required this.isInGroup});

  factory PrayerAttendanceInfo.fromJson(Map<String, dynamic> json) {
    final rakats = json['rakatsCount'] is int ? json['rakatsCount'] : null;
    final inGroup = json['isInGroup'] ?? json['isInGroup'];
    return PrayerAttendanceInfo(
      rakatsCount: rakats is int ? rakats : null,
      isInGroup: inGroup == true || inGroup == 'true',
    );
  }
}

class PrayerUpdateDTO {
  int prayerId;
  int rakatCount;
  bool isInGroup;

  PrayerUpdateDTO({
    required this.prayerId,
    required this.rakatCount,
    required this.isInGroup,
  });

  Map<String, dynamic> toJson() => {
        'prayerId': prayerId,
        'rakatCount': rakatCount,
        'isInGroup': isInGroup,
      };
}
