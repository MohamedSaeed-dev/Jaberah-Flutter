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
  var selectedFromDate = JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;
  var selectedToDate = JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  /// بداية ونهاية الفترة الهجرية المختارة بالميلادي (للـ API).
  var semesterReportFromDate = ''.obs;
  var semesterReportToDate = ''.obs;

  /// يحسب fromDate و toDate من أول يوم في شهر "من" الهجري وآخر يوم في شهر "إلى" الهجري (ميلادي). يُستدعى عند تحديد التواريخ.
  void updateSemesterReportDates() {
    final jFrom = selectedFromDate.value.jhijri;
    final jTo = selectedToDate.value.jhijri;
    if (jFrom == null || jTo == null) return;
    final firstFrom = JHijri(fYear: jFrom.year, fMonth: jFrom.month, fDay: 1);
    final fromDateTime = firstFrom.dateTime;
    semesterReportFromDate.value =
        '${fromDateTime.year}-${fromDateTime.month.toString().padLeft(2, '0')}-${fromDateTime.day.toString().padLeft(2, '0')}';
    final nextMonth = jTo.month == 12 ? 1 : jTo.month + 1;
    final nextYear = jTo.month == 12 ? jTo.year + 1 : jTo.year;
    final firstOfNextHijri = JHijri(fYear: nextYear, fMonth: nextMonth, fDay: 1);
    final toDateTime = firstOfNextHijri.dateTime.subtract(const Duration(days: 1));
    semesterReportToDate.value =
        '${toDateTime.year}-${toDateTime.month.toString().padLeft(2, '0')}-${toDateTime.day.toString().padLeft(2, '0')}';
  }

  var groups = <GroupsGeneral>[].obs;
  var selectedGroupId = 0.obs;
  var selectedGroupName = ''.obs;

  var semesterReport = <SemesterReportModel>[];

  Future getSemesterReport() async {
    try {
      isLoading.value = true;
      final fromDate = semesterReportFromDate.value;
      final toDate = semesterReportToDate.value;
      if (fromDate.isEmpty || toDate.isEmpty) {
        messageSnackBar('يرجى اختيار فترة التقرير (من - إلى)');
        isLoading.value = false;
        return;
      }
      var response = await _apiClient.dio
          .get(
              "/$semesterReportURL?groupId=$selectedGroupId&fromDate=$fromDate&toDate=$toDate")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        semesterReport =
            result.map((item) => SemesterReportModel.fromJson(item)).toList();
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

  Future UpdateMidFinal({required int studentId, double? midFinalGrade}) async {
    try {
      isLoadingUpdate.value = true;
      final fromDate = semesterReportFromDate.value;
      final toDate = semesterReportToDate.value;
      if (fromDate.isEmpty || toDate.isEmpty) {
        messageSnackBar('يرجى اختيار فترة التقرير (من - إلى)');
        isLoadingUpdate.value = false;
        return;
      }
      var response = await _apiClient.dio.post(
          "/$midFinalExamURL?studentId=$studentId&fromDate=$fromDate&toDate=$toDate",
          data: {"grade": midFinalGrade}).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar("تم تعديل النتيجة بنجاح");
        await getSemesterReport();
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
      isLoadingUpdate.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    subtractMonths(selectedFromDate, 3);
    updateSemesterReportDates();
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
          selectedGroupName.value = groups[0].name;
        }
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
    } finally {}
  }
}

// Function to subtract months and handle year changes
void subtractMonths(Rx<JDateModel> selectedDate, int months) {
  // Clone the current Hijri date to avoid modifying the original directly
  var currentHijri = selectedDate.value.jhijri!;
  var currentDateTime = selectedDate.value.dateTime!;

  // Calculate the new month and year
  int newMonth = currentHijri.month - months;
  int newYear = currentHijri.year;
  int newYearDateTime = currentDateTime.year;
  int newMonthDateTime = currentDateTime.month - months;

  while (newMonth < 1) {
    newMonth += 12;
    newYear -= 1;
  }
  while (newMonthDateTime < 1) {
    newMonthDateTime += 12;
    newYearDateTime -= 1;
  }

  // Set the adjusted Hijri date
  selectedDate.value = JDateModel(
    jhijri: JHijri(fYear: newYear, fMonth: newMonth, fDay: currentHijri.day),
    dateTime: DateTime(newYearDateTime, newMonthDateTime, currentDateTime.day),
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
