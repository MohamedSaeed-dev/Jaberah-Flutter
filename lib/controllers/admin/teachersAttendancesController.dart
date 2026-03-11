import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/reportTeachersAttendancesController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/jhijri_picker.dart';

class TeacherAttendancesController extends GetxController {
  final ApiClient _apiClient = Get.find();
  // A list to store attendance entries
  var entries = <EntryAttendance>[].obs;

  // Update or add an entry (DTO: TeacherId, GroupId, CheckInTime, CheckOutTime, IsExcused)
  void updateEntry(int teacherId,
      {required int groupId,
      String? checkInTime,
      String? checkOutTime,
      bool? isExcused}) {
    var entry = entries.firstWhereOrNull((e) => e.teacherId == teacherId && e.groupId == groupId);

    if (entry != null) {
      entry.groupId = groupId;
      entry.checkInTime = checkInTime;
      entry.checkOutTime = checkOutTime;
      entry.isExcused = isExcused;
    } else {
      entries.add(EntryAttendance(
        teacherId: teacherId,
        groupId: groupId,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        isExcused: isExcused,
      ));
    }
    entries.refresh();
  }

  var teachersAttendances = [];

  var filteredTeachersAttendances = <TeacherAttendanceForDayReport>[].obs;

  var isLoading = false.obs;

  /// مفتاح السجل الذي يتم تحديثه حالياً (مثال: "teacherId_groupId") لعرض التحميل على زر التحديث فقط.
  var savingEntryKey = Rxn<String>();

  var pageNumber = 1.obs;
  var pageSize = 5.obs;

  var selectedDate = JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  Future getTeachersAttendances() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$teachersAttendancesForReportByDayURL?date=${selectedDate.value.dateTime!.year}-${selectedDate.value.dateTime!.month}-${selectedDate.value.dateTime!.day}")
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<dynamic> result = response.data;
        filteredTeachersAttendances.value = result
            .map((item) => TeacherAttendanceForDayReport.fromJson(item))
            .toList();
      } else {
        messageSnackBar(response.data['message']);
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

  /// تحديث حضور معلم واحد (الـ API يستقبل body لمعلم واحد فقط).
  Future<void> updateTeacherAttendance(EntryAttendance entry) async {
    final key = '${entry.teacherId}_${entry.groupId}';
    try {
      savingEntryKey.value = key;
      final response = await _apiClient.dio
          .post(
              "/$teachersAttendancesURL?date=${selectedDate.value.dateTime!.year}-${selectedDate.value.dateTime!.month}-${selectedDate.value.dateTime!.day}",
              data: entry.toJson())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        successSnackBar("تم تحديث حضور المعلم");
        await getTeachersAttendances();
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } catch (e) {
      catchSnackBar();
    } finally {
      savingEntryKey.value = null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getTeachersAttendances();
  }
}

/// Matches UpsertTeachersAttendancesDTO: TeacherId, GroupId, CheckInTime, CheckOutTime, IsExcused
class EntryAttendance {
  int teacherId;
  int groupId;
  String? checkInTime;  // "HH:mm" for TimeOnly
  String? checkOutTime;
  bool? isExcused;      // مستأذن

  EntryAttendance({
    required this.teacherId,
    required this.groupId,
    this.checkInTime,
    this.checkOutTime,
    this.isExcused,
  });

  Map<String, dynamic> toJson() {
    // عند مستأذن نرسل للأي بي أي أوقاتاً null، مع الإبقاء على القيم في الـ entry للواجهة
    return {
      'teacherId': teacherId,
      'groupId': groupId,
      'checkInTime': isExcused == true ? null : checkInTime,
      'checkOutTime': isExcused == true ? null : checkOutTime,
      'isExcused': isExcused,
    };
  }
}
