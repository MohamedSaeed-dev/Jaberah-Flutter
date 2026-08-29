import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/monthlyReportController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/models/global/storage-permission.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class PrayersMonthlyReportController extends GetxController {
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
    getGroups();
  }

  Future<void> getGroups() async {
    try {
      final response = await _apiClient.dio
          .get("/$groupsForGeneralUseURL")
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
    }
  }

  Future<void> prayersReportPdfPage(
    String reportName,
    PrayersMonthlyReportResponse data,
    Document pdf,
  ) async {
    final fontData = await rootBundle.load('fonts/GE_SS_Two_Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final headerStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      font: ttf,
      fontFallback: [Font.helvetica()],
    );

    final cellStyle =
        pw.TextStyle(fontSize: 9, font: ttf, fontFallback: [Font.helvetica()]);

    final titleStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      font: ttf,
      fontFallback: [Font.helvetica()],
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: pw.ThemeData.withFont(base: ttf),
        textDirection: pw.TextDirection.rtl,
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              reportName,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                font: ttf,
              ),
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'صفحة ${context.pageNumber} من ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, font: ttf),
              ),
              pw.Text(
                'حلقات مسجد جابرة',
                style: pw.TextStyle(fontSize: 10, font: ttf),
              ),
            ],
          );
        },
        build: (pw.Context context) {
          final list = <pw.Widget>[];

          list.add(
            pw.Container(
              margin: pw.EdgeInsets.only(bottom: 15),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text(
                    'إجمالي  الممكنة للطالب: ${data.totalPossibleRakatsPerStudent}',
                    style: titleStyle,
                  ),
                  pw.Text(
                    'متوسط نسبة الالتزام في جماعة: ${(data.averageCommitmentPercentage)}٪',
                    style: titleStyle,
                  ),
                ],
              ),
            ),
          );

          list.add(
            pw.Container(
              color: PdfColors.grey300,
              padding: pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child:
                        pw.Center(child: pw.Text('الرقم', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child:
                        pw.Center(child: pw.Text('الاسم', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child:
                        pw.Center(child: pw.Text('الحلقة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child:
                        pw.Center(child: pw.Text('الصلوات المصلاة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('نسبة الصلوات', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('الركعات المصلاة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('صلوات الجماعة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('نسبة الجماعة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child:
                            pw.Text('الصلوات الفائتة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('نسبة الصلوات الفائتة',
                            style: headerStyle)),
                  ),
                ],
              ),
            ),
          );

          for (var i = 0; i < data.students.length; i++) {
            final s = data.students[i];
            list.add(
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 5),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text('${i + 1}', style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text(s.studentName, style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text(s.groupName, style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text('${s.totalPrayed}', style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text('${(s.totalPrayedPercentage)}٪',
                              style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text('${s.totalPrayedRakats}',
                              style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text('${s.totalGroupPrayed}',
                              style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text('${s.groupPercentage}٪',
                              style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child:
                              pw.Text('${s.missedPrayers}', style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text('${(s.missedPercentage)}٪',
                              style: cellStyle)),
                    ),
                  ],
                ),
              ),
            );
          }

          return list;
        },
      ),
    );
  }

  Future<void> exportAsPDF(String reportName) async {
    try {
      await requestStoragePermission();
      final pdf = pw.Document();
      await prayersReportPdfPage(reportName, prayersReport.value, pdf);
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

class PrayersMonthlyReportResponse {
  final int totalPossibleRakatsPerStudent;
  final double averageCommitmentPercentage;
  final List<PrayersReportStudent> students;

  PrayersMonthlyReportResponse({
    required this.totalPossibleRakatsPerStudent,
    required this.averageCommitmentPercentage,
    required this.students,
  });

  factory PrayersMonthlyReportResponse.fromJson(Map<String, dynamic> json) {
    final studentsList = json['students'] as List<dynamic>? ?? [];
    return PrayersMonthlyReportResponse(
      totalPossibleRakatsPerStudent:
          json['totalPossibleRakatsPerStudent'] as int? ?? 0,
      averageCommitmentPercentage:
          _toDouble(json['averageCommitmentPercentage']),
      students: studentsList
          .map((e) => PrayersReportStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PrayersReportStudent {
  final int studentId;
  final String studentName;
  final String groupName;
  final int totalPrayedRakats;
  final int totalPrayed;
  final double totalPrayedPercentage;
  final int totalGroupPrayed;
  final double groupPercentage;
  final int missedPrayers;
  final double missedPercentage;
  final int perfectDays;
  final int missedDays;

  PrayersReportStudent({
    required this.studentId,
    required this.studentName,
    required this.groupName,
    required this.totalPrayed,
    required this.totalPrayedRakats,
    required this.totalPrayedPercentage,
    required this.totalGroupPrayed,
    required this.groupPercentage,
    required this.missedPrayers,
    required this.missedPercentage,
    required this.perfectDays,
    required this.missedDays,
  });

  factory PrayersReportStudent.fromJson(Map<String, dynamic> json) {
    return PrayersReportStudent(
      studentId: json['studentId'] as int? ?? 0,
      studentName: json['studentName'] as String? ?? '',
      groupName: json['groupName'] as String? ?? '',
      totalPrayed: json['totalPrayed'] as int? ?? 0,
      totalPrayedRakats: json['totalPrayedRakats'] as int? ?? 0,
      totalPrayedPercentage: _toDouble(json['totalPrayedPercentage']),
      totalGroupPrayed: json['totalGroupPrayed'] as int? ?? 0,
      groupPercentage: _toDouble(json['groupPercentage']),
      missedPrayers: json['missedPrayers'] as int? ?? 0,
      missedPercentage: _toDouble(json['missedPercentage']),
      perfectDays: json['perfectDays'] as int? ?? 0,
      missedDays: json['missedDays'] as int? ?? 0,
    );
  }
}

double _toDouble(dynamic val) {
  if (val is int) return val.toDouble();
  if (val is double) return val;
  return double.tryParse(val.toString()) ?? 0.0;
}
