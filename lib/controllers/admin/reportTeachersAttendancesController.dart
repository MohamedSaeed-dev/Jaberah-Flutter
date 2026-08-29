import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/jhijri_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';

class TeachersAttendancesReportController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var selectedDate = JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;
  /// يُحسبان عند تحديد الشهر الهجري (وليس عند إرسال الطلب)
  var monthReportFromDate = ''.obs;
  var monthReportToDate = ''.obs;

  var filteredTeachersAttendancesForReportByMonth =
      <TeacherAttendanceForMonthReport>[].obs;

  var filteredTeachersAttendancesForReportByDay =
      <TeacherAttendanceForDayReport>[].obs;

  /// يحسب fromDate و toDate من أول/آخر يوم في الشهر الهجري المختار (ميلادي). يُستدعى عند تحديد التاريخ.
  void updateMonthReportDates() {
    final jhijri = selectedDate.value.jhijri;
    if (jhijri == null) return;
    final year = jhijri.year;
    final month = jhijri.month;
    final firstHijriDay = JHijri(fYear: year, fMonth: month, fDay: 1);
    final fromDateTime = firstHijriDay.dateTime;
    monthReportFromDate.value =
        '${fromDateTime.year}-${fromDateTime.month.toString().padLeft(2, '0')}-${fromDateTime.day.toString().padLeft(2, '0')}';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final firstOfNextHijri = JHijri(fYear: nextYear, fMonth: nextMonth, fDay: 1);
    final toDateTime = firstOfNextHijri.dateTime.subtract(const Duration(days: 1));
    monthReportToDate.value =
        '${toDateTime.year}-${toDateTime.month.toString().padLeft(2, '0')}-${toDateTime.day.toString().padLeft(2, '0')}';
  }

  Future<void> getTeachersAttendancesReportByDay() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$teachersAttendancesForReportByDayURL?date=${selectedDate.value.dateTime!.year}-${selectedDate.value.dateTime!.month}-${selectedDate.value.dateTime!.day}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final List<dynamic> result = response.data;
        filteredTeachersAttendancesForReportByDay.value = result
            .map((item) => TeacherAttendanceForDayReport.fromJson(item))
            .toList();
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

  Future getTeachersAttendancesReportByMonth() async {
    try {
      isLoading.value = true;
      final fromDate = monthReportFromDate.value;
      final toDate = monthReportToDate.value;
      if (fromDate.isEmpty || toDate.isEmpty) {
        messageSnackBar('يرجى اختيار الشهر أولاً');
        return;
      }
      var response = await _apiClient.dio
          .get(
              "/$teachersAttendancesForReportByMonthURL?fromDate=$fromDate&toDate=$toDate")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final List<dynamic> result = response.data;
        filteredTeachersAttendancesForReportByMonth.value = result
            .map((item) => TeacherAttendanceForMonthReport.fromJson(item))
            .toList();
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

  @override
  void onInit() {
    super.onInit();
    updateMonthReportDates();
  }
}

class TeacherAttendanceForDayReport {
  final int teacherId;
  final String teacherName;
  final int? groupId;
  final String? groupName;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;

  TeacherAttendanceForDayReport({
    required this.teacherId,
    required this.teacherName,
    this.groupId,
    this.groupName,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
  });

  // From JSON to Object
  factory TeacherAttendanceForDayReport.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceForDayReport(
      teacherId: json['teacherId'] as int,
      teacherName: json['teacherName'] as String,
      groupId: json['groupId'] as int?,
      groupName: json['groupName'] as String?,
      checkInTime: json['checkInTime'] != null ? json['checkInTime'] as String : null,
      checkOutTime: json['checkOutTime'] != null ? json['checkOutTime'] as String : null,
      status: json['status'] as String,
    );
  }

  // From Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'groupId': groupId,
      'groupName': groupName,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
    };
  }
}

class TeacherAttendanceForMonthReport {
  final String teacherName;
  final String groupName;
  final int excuseNo;
  final int presentNo;
  final int lateNo;
  final int absentNo;

  TeacherAttendanceForMonthReport({
    required this.teacherName,
    required this.groupName,
    required this.excuseNo,
    required this.presentNo,
    required this.lateNo,
    required this.absentNo,
  });

  // From JSON to Object
  factory TeacherAttendanceForMonthReport.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceForMonthReport(
      teacherName: json['teacherName'] as String,
      groupName: json['groupName'] as String,
      excuseNo: json['excuseNo'] as int,
      presentNo: json['presentNo'] as int,
      lateNo: json['lateNo'] as int,
      absentNo: json['absentNo'] as int,
    );
  }

  // From Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'teacherName': teacherName,
      'groupName': groupName,
      'excuseNo': excuseNo,
      'presentNo': presentNo,
      'lateNo': lateNo,
      'absentNo': absentNo,
    };
  }
}
