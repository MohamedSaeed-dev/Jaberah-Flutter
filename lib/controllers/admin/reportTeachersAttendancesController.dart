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
  var selectedDate = JDateModel(jhijri: JHijri.now()).obs;
  var filteredTeachersAttendancesForReportByMonth = [].obs;

  var filteredTeachersAttendancesForReportByDay =
      <TeacherAttendanceForDayReport>[].obs;

  Future<void> getTeachersAttendancesReportByDay() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$teachersAttendancesForReportByDayURL?date=${selectedDate.value.jhijri!.year}-${selectedDate.value.jhijri!.month}-${selectedDate.value.jhijri!.day}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final List<dynamic> result = response.data;
        filteredTeachersAttendancesForReportByDay.value = result
            .map((item) => TeacherAttendanceForDayReport.fromJson(item))
            .toList();
      } else {
        messageSnackBar(response.data['message']);
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

  Future getTeachersAttendancesReportByMonth() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$teachersAttendancesForReportByMonthURL?year=${selectedDate.value.jhijri!.year}&month=${selectedDate.value.jhijri!.month}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final List<dynamic> result = response.data;
        filteredTeachersAttendancesForReportByMonth.value = result
            .map((item) => TeacherAttendanceForMonthReport.fromJson(item))
            .toList();
      } else {
        messageSnackBar(response.data['message']);
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
}

class TeacherAttendanceForDayReport {
  final int id;
  final String teacherName;
  final bool? isExcuse;
  final bool? signature;

  TeacherAttendanceForDayReport({
    required this.id,
    required this.teacherName,
    this.isExcuse,
    this.signature,
  });

  // From JSON to Object
  factory TeacherAttendanceForDayReport.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceForDayReport(
      id: json['id'] as int,
      teacherName: json['teacherName'] as String,
      isExcuse: json['isExcuse'] as bool?,
      signature: json['signature'] as bool?,
    );
  }

  // From Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherName': teacherName,
      'isExcuse': isExcuse,
      'signature': signature,
    };
  }
}

class TeacherAttendanceForMonthReport {
  final String teacherName;
  final int isExcuseNo;
  final int signatureNo;

  TeacherAttendanceForMonthReport({
    required this.teacherName,
    required this.isExcuseNo,
    required this.signatureNo,
  });

  // From JSON to Object
  factory TeacherAttendanceForMonthReport.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceForMonthReport(
      teacherName: json['teacherName'] as String,
      isExcuseNo: json['isExcuseNo'] as int,
      signatureNo: json['signatureNo'] as int,
    );
  }

  // From Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'teacherName': teacherName,
      'isExcuseNo': isExcuseNo,
      'signatureNo': signatureNo,
    };
  }
}
