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
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class MonthlyPartialExamReportController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  /// القيمة الافتراضية: بداية الشهر الهجري الحالي.
  var selectedDate = JDateModel(
    jhijri: JHijri(
      fYear: JHijri.now().year,
      fMonth: JHijri.now().month,
      fDay: 1,
    ),
    dateTime: JHijri(
      fYear: JHijri.now().year,
      fMonth: JHijri.now().month,
      fDay: 1,
    ).dateTime,
  ).obs;

  /// بداية ونهاية الشهر الهجري المختار بالميلادي (للـ API).
  var reportFromDate = ''.obs;
  var reportToDate = ''.obs;

  /// يحسب fromDate و toDate من أول/آخر يوم في الشهر الهجري المختار (ميلادي).
  void updateMonthReportDates() {
    final jhijri = selectedDate.value.jhijri;
    if (jhijri == null) return;
    final year = jhijri.year;
    final month = jhijri.month;
    final firstHijriDay = JHijri(fYear: year, fMonth: month, fDay: 1);
    final fromDateTime = firstHijriDay.dateTime;
    reportFromDate.value =
        '${fromDateTime.year}-${fromDateTime.month.toString().padLeft(2, '0')}-${fromDateTime.day.toString().padLeft(2, '0')}';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final firstOfNextHijri =
        JHijri(fYear: nextYear, fMonth: nextMonth, fDay: 1);
    final toDateTime =
        firstOfNextHijri.dateTime.subtract(const Duration(days: 1));
    reportToDate.value =
        '${toDateTime.year}-${toDateTime.month.toString().padLeft(2, '0')}-${toDateTime.day.toString().padLeft(2, '0')}';
  }

  var groups = <GroupsGeneral>[].obs;
  var selectedGroupId = 0.obs;
  var selectedGroupName = ''.obs;

  var reportData = <MonthlyPartialExamItem>[].obs;

  Future<void> getReport() async {
    try {
      isLoading.value = true;
      final fromDate = reportFromDate.value;
      final toDate = reportToDate.value;
      if (fromDate.isEmpty || toDate.isEmpty) {
        messageSnackBar('يرجى اختيار الشهر أولاً');
        isLoading.value = false;
        return;
      }
      var url =
          "/$monthlyPartialExamReportURL?fromDate=$fromDate&toDate=$toDate";
      if (selectedGroupId.value > 0) {
        url =
            "/$monthlyPartialExamReportURL?groupId=${selectedGroupId.value}&fromDate=$fromDate&toDate=$toDate";
      }
      var response =
          await _apiClient.dio.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        reportData.value = result
            .map((item) =>
                MonthlyPartialExamItem.fromJson(item as Map<String, dynamic>))
            .toList();
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

  @override
  void onInit() {
    super.onInit();
    selectedGroupName.value = 'كل الحلقات';
    updateMonthReportDates();
    getGroups();
  }

  Future<void> getGroups() async {
    try {
      var response = await _apiClient.dio
          .get("/$groupsForGeneralUseURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value =
            result.map((item) => GroupsGeneral.fromJson(item)).toList();
        selectedGroupId.value = 0;
        selectedGroupName.value = 'كل الحلقات';
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

  Future<void> _monthlyPartialExamReportPdfPage(
    String reportName,
    List<MonthlyPartialExamItem> data,
    pw.Document pdf,
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
                fontSize: 18,
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
          return [
            pw.Container(
              color: PdfColors.grey300,
              padding: pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('الرقم', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Center(
                        child: pw.Text('الطالب - الحلقة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Center(
                        child: pw.Text('التاريخ', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                        child: pw.Text('التقييم', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('الجزء', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('الأداء', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text('الدرجة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                        child: pw.Text('المجموع الكلي', style: headerStyle)),
                  ),
                ],
              ),
            ),
            ...data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return pw.Container(
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
                          child: pw.Text('${index + 1}', style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Center(
                        child: pw.Text(
                          '${item.studentName} - ${item.groupName}',
                          style: cellStyle,
                          maxLines: 2,
                          overflow: pw.TextOverflow.span,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Center(
                          child: pw.Text(
                              item.dateHijriFormatted, style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text(item.rate, style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text(item.part, style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text(
                              item.performance.toString(),
                              style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text(
                              item.score.toString(), style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text(
                              item.totalScore.toString(),
                              style: cellStyle)),
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );
  }

  Future<void> exportAsPDF(String reportName) async {
    try {
      await requestStoragePermission();
      final pdf = pw.Document();
      await _monthlyPartialExamReportPdfPage(
          reportName, reportData.toList(), pdf);
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

class MonthlyPartialExamItem {
  String studentName;
  String groupName;
  String date;
  String rate;
  String part;
  num performance;
  num score;
  num totalScore;

  MonthlyPartialExamItem({
    required this.studentName,
    required this.groupName,
    required this.date,
    required this.rate,
    required this.part,
    required this.performance,
    required this.score,
    required this.totalScore,
  });

  /// عرض تاريخ الـ API بالهجري (مثال: 3 - رجب - 1446).
  String get dateHijriFormatted {
    if (date.isEmpty) return date;
    try {
      final dt = DateTime.parse(date);
      final h = JHijri(fDate: dt);
      return '${h.day} - ${h.monthName} - ${h.year}';
    } catch (_) {
      return date;
    }
  }

  factory MonthlyPartialExamItem.fromJson(Map<String, dynamic> json) {
    return MonthlyPartialExamItem(
      studentName: json["studentName"] as String? ?? '',
      groupName: json["groupName"] as String? ?? '',
      date: json["date"]?.toString() ?? '',
      rate: json["rate"]?.toString() ?? '',
      part: json["part"]?.toString() ?? '',
      performance: _toNum(json["performance"]),
      score: _toNum(json["score"]),
      totalScore: _toNum(json["totalScore"]),
    );
  }

  static num _toNum(dynamic val) {
    if (val is int) return val;
    if (val is double) return val;
    return num.tryParse(val.toString()) ?? 0;
  }
}
