import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/monthlyReportController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SemesterStudentsReportsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var isLoadingUpdate = false.obs;
  var selectedFromDate = JDateModel(jhijri: JHijri.now()).obs;
  var selectedToDate = JDateModel(jhijri: JHijri.now()).obs;

  var groups = <GroupsGeneral>[].obs;
  var selectedGroupId = 0.obs;
  var selectedGroupName = ''.obs;

  var semesterReport = <SemesterReportModel>[];

  Future getSemesterReport() async {
    try {
      isLoading.value = true;
      var fromDate =
          "${selectedFromDate.value.jhijri!.year}-${selectedFromDate.value.jhijri!.month}-1";
      var toDate =
          "${selectedToDate.value.jhijri!.year}-${selectedToDate.value.jhijri!.month}-1";
      var response = await _apiClient.dio
          .get(
              "/$semesterReportURL?groupId=$selectedGroupId&fromDate=$fromDate&toDate=$toDate")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        semesterReport =
            result.map((item) => SemesterReportModel.fromJson(item)).toList();
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

  Future UpdateMidFinal({required int studentId, double? midFinalGrade}) async {
    try {
      isLoadingUpdate.value = true;
      var response = await _apiClient.dio.post(
          "/$midFinalExamURL?studentId=$studentId&fromDate=${selectedFromDate.value.jhijri!.year}-${selectedFromDate.value.jhijri!.month}-1&toDate=${selectedToDate.value.jhijri!.year}-${selectedToDate.value.jhijri!.month}-1",
          data: {"grade": midFinalGrade}).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar("تم تعديل النتيجة بنجاح");
        await getSemesterReport();
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
      isLoadingUpdate.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    subtractMonths(selectedFromDate, 4);
    getGroups();
  }

  Future getGroups() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var teacherId = sp.getString("id");
      var response = await _apiClient.dio
          .get("/$teachersURL/$teacherId/groups/for-general-use")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value =
            result.map((item) => GroupsGeneral.fromJson(item)).toList();
        if (groups.isNotEmpty) {
          selectedGroupId.value = groups[0].id;
          selectedGroupName.value = groups[0].groupName;
        }
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
    } finally {}
  }
}

// Function to subtract months and handle year changes
void subtractMonths(Rx<JDateModel> selectedDate, int months) {
  // Clone the current Hijri date to avoid modifying the original directly
  var currentHijri = selectedDate.value.jhijri!;

  // Calculate the new month and year
  int newMonth = currentHijri.month - months;
  int newYear = currentHijri.year;

  while (newMonth < 1) {
    newMonth += 12;
    newYear -= 1;
  }

  // Set the adjusted Hijri date
  selectedDate.value = JDateModel(
    jhijri: JHijri(fYear: newYear, fMonth: newMonth, fDay: currentHijri.day),
  );
}

class SemesterReportModel {
  int studentId;
  String studentName;
  double gradeSum;
  double attendanceSum;
  double behaviorSum;
  double oralGradeSum;
  double paperGradeSum;
  double midFinalGrade;
  double total;

  SemesterReportModel(
      {required this.studentId,
      required this.studentName,
      required this.gradeSum,
      required this.attendanceSum,
      required this.behaviorSum,
      required this.oralGradeSum,
      required this.paperGradeSum,
      required this.midFinalGrade,
      required this.total});

  factory SemesterReportModel.fromJson(Map<String, dynamic> json) {
    return SemesterReportModel(
        studentId: json["studentId"] as int,
        studentName: json["studentName"] as String,
        gradeSum: json["gradeSum"] is int
            ? (json["gradeSum"] as int).toDouble()
            : double.parse(json["gradeSum"].toString()),
        attendanceSum: (json["attendanceSum"] is int) ? 
            (json["attendanceSum"] as int).toDouble() :
            double.parse(json["attendanceSum"].toString()),
        behaviorSum: (json["behaviorSum"] is int) ? 
            (json["behaviorSum"] as int).toDouble() :
            double.parse(json["behaviorSum"].toString()),
        oralGradeSum: (json["oralGradeSum"] is int)
            ? (json["oralGradeSum"] as int).toDouble()
            : double.parse(json["oralGradeSum"].toString()),
        paperGradeSum: (json["paperGradeSum"] is int)
            ? (json["paperGradeSum"] as int).toDouble()
            : double.parse(json["paperGradeSum"].toString()),
        midFinalGrade: (json["midFinalGrade"] is int)
            ? (json["midFinalGrade"] as int).toDouble()
            : double.parse(json["midFinalGrade"].toString()),
        total: (json["total"] is int)
            ? (json["total"] as int).toDouble()
            : double.parse(json["total"].toString()));
  }
}
