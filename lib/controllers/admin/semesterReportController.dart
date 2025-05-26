import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/monthlyReportController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class SemesterReportController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
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

  @override
  void onInit() {
    super.onInit();
    subtractMonths(selectedFromDate, 4);
    getGroups();
  }

  Future getGroups() async {
    try {
      var response = await _apiClient.dio
          .get("/$groupsForGeneralUseURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value =
            result.map((item) => GroupsGeneral.fromJson(item)).toList();
        ;
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

  void semesterReportPage(String reportName,
      List<SemesterReportModel> semesterReport, Document pdf) async {
    final fontData = await rootBundle.load('fonts/GE_SS_Two_Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final headerStyle = pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        font: ttf,
        fontFallback: [Font.helvetica()]);

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
                style: cellStyle.copyWith(fontSize: 10),
              ),
              pw.Text(
                'حلقات مسجد جابرة',
                style: cellStyle.copyWith(fontSize: 10),
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // Table Header
            pw.Container(
              color: PdfColors.grey300,
              padding: pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text('الرقم', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text('الاسم', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text('مجموع الدرجات', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text('الحضور', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text('السلوك', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text('شفهي', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text('تحريري', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text('النصفي', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text('المجموع', style: headerStyle),
                    ),
                  ),
                ],
              ),
            ),
            // Table Rows
            ...semesterReport.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
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
                        child: pw.Text('${index + 1}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child: pw.Text(data.studentName, style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child: pw.Text('${data.gradeSum}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child:
                            pw.Text('${data.attendanceSum}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child: pw.Text('${data.behaviorSum}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child:
                            pw.Text('${data.oralGradeSum}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child:
                            pw.Text('${data.paperGradeSum}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child:
                            pw.Text('${data.midFinalGrade}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child: pw.Text('${data.total}\u0025', style: cellStyle),
                      ),
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
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        messageSnackBar("يجب منح الإذن للوصول إلى التخزين");
        return;
      }
      final pdf = pw.Document();
      semesterReportPage(reportName, semesterReport, pdf);
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

class SemesterReportModel {
  String studentName;
  double gradeSum;
  int attendanceSum;
  int behaviorSum;
  double oralGradeSum;
  double paperGradeSum;
  double midFinalGrade;
  double total;

  SemesterReportModel(
      {required this.studentName,
      required this.gradeSum,
      required this.attendanceSum,
      required this.behaviorSum,
      required this.oralGradeSum,
      required this.paperGradeSum,
      required this.midFinalGrade,
      required this.total});

  factory SemesterReportModel.fromJson(Map<String, dynamic> json) {
    return SemesterReportModel(
        studentName: json["studentName"] as String,
        gradeSum: json["gradeSum"] is int
            ? (json["gradeSum"] as int).toDouble()
            : double.parse(json["gradeSum"].toString()),
        attendanceSum: json["attendanceSum"] as int,
        behaviorSum: json["behaviorSum"] as int,
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
