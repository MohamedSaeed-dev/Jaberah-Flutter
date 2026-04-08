import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/prayersMonthlyReportController.dart';
import 'package:jaberah/controllers/user/monthlyStudentsReports.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/models/global/storage-permission.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class PrayersStudentsReportsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var selectedDate =
      JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  var monthReportFromDate = ''.obs;
  var monthReportToDate = ''.obs;

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
    final firstOfNextHijri =
        JHijri(fYear: nextYear, fMonth: nextMonth, fDay: 1);
    final toDateTime =
        firstOfNextHijri.dateTime.subtract(const Duration(days: 1));
    monthReportToDate.value =
        '${toDateTime.year}-${toDateTime.month.toString().padLeft(2, '0')}-${toDateTime.day.toString().padLeft(2, '0')}';
  }

  int get daysInMonth {
    final from = monthReportFromDate.value;
    final to = monthReportToDate.value;
    if (from.isEmpty || to.isEmpty) return 0;
    final partsFrom = from.split('-');
    final partsTo = to.split('-');
    if (partsFrom.length != 3 || partsTo.length != 3) return 0;
    final fromDt = DateTime(int.parse(partsFrom[0]), int.parse(partsFrom[1]),
        int.parse(partsFrom[2]));
    final toDt = DateTime(
        int.parse(partsTo[0]), int.parse(partsTo[1]), int.parse(partsTo[2]));
    return toDt.difference(fromDt).inDays + 1;
  }

  var groups = <GroupsGeneral>[].obs;
  var selectedGroupId = 0.obs;
  var selectedGroupName = ''.obs;

  var prayersReport = PrayersMonthlyReportResponse(
    totalPossibleRakatsPerStudent: 0,
    averageCommitmentPercentage: 0,
    students: [],
  ).obs;

  Future<void> getPrayersMonthlyReport() async {
    try {
      isLoading.value = true;
      final date = monthReportFromDate.value;
      final days = daysInMonth;
      if (date.isEmpty || days == 0) {
        messageSnackBar('يرجى اختيار الشهر أولاً');
        isLoading.value = false;
        return;
      }
      const pageSize = 500;
      final url =
          "/$prayersMonthlyReportURL?date=$date&daysInMonth=$days&groupId=${selectedGroupId.value}&pageNumber=1&pageSize=$pageSize";
      final response =
          await _apiClient.dio.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final result = response.data as Map<String, dynamic>;
        prayersReport.value = PrayersMonthlyReportResponse.fromJson(result);
      } else {
        messageSnackBar(response.data["message"] ?? "حدث خطأ");
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

  @override
  void onInit() {
    super.onInit();
    updateMonthReportDates();
    getGroups();
  }

  Future<void> getGroups() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var teacherId = sp.getString("id");
      final response = await _apiClient.dio
          .get("/$teachersURL/$teacherId/groups/for-general-use")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final result = response.data as List<dynamic>;
        groups.value =
            result.map((item) => GroupsGeneral.fromJson(item)).toList();
        if (groups.isNotEmpty) {
          selectedGroupId.value = groups[0].id;
          selectedGroupName.value = groups[0].name;
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
    }
  }

  Future<void> exportAsPDF(String reportName) async {
    try {
      await requestStoragePermission();
      final pdf = pw.Document();
      final adminCtrl = PrayersMonthlyReportController();
      await adminCtrl.prayersReportPdfPage(
        reportName,
        prayersReport.value,
        pdf,
      );
      final directory = Directory(appFolder);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final filePath = '${directory.path}/$reportName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      successSnackBar("تم تصدير $reportName");
    } catch (e) {
      catchSnackBar();
    }
  }
}
