import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class MonthlyReportController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var selectedDate = JDateModel(jhijri: JHijri.now()).obs;

  var groups = <GroupsGeneral>[].obs;
  var selectedGroupId = 0.obs;
  var selectedGroupName = ''.obs;

  var monthlyReport = <MonthlyReportModel>[];

  Future getMonthlyReport() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$monthlyReportURL?groupId=$selectedGroupId&year=${selectedDate.value.jhijri!.year}&month=${selectedDate.value.jhijri!.month}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        monthlyReport =
            result.map((item) => MonthlyReportModel.fromJson(item)).toList();
        ;
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

  void monthlyReportPage(String reportName,
      List<MonthlyReportModel> monthlyReport, Document pdf) async {
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
            // Table Header
            pw.Container(
              color: PdfColors.grey300,
              padding: pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                          child: pw.Text('الرقم', style: headerStyle))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('الاسم', style: headerStyle))),
                  pw.Expanded(
                      flex: 3,
                      child:
                          pw.Center(child: pw.Text('حفظ', style: headerStyle))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('درجة الحفظ', style: headerStyle))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Center(
                          child: pw.Text('مراجعة', style: headerStyle))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('درجة المراجعة', style: headerStyle))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('الحضور', style: headerStyle))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('السلوك', style: headerStyle))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('شفهي', style: headerStyle))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('تحريري', style: headerStyle))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('المجموع', style: headerStyle))),
                ],
              ),
            ),
            // Table Rows
            ...monthlyReport.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 5),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        flex: 1,
                        child: pw.Center(
                            child: pw.Text('${index + 1}', style: cellStyle))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child:
                                pw.Text(data.studentName, style: cellStyle))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Center(
                            child: pw.Text(
                          '${data.saveFromSurah} (${data.saveFromVerse}) - ${data.saveToSurah} (${data.saveToVerse})',
                          style: cellStyle,
                          maxLines: 2,
                          overflow: pw.TextOverflow.span,
                        ))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('${data.saveGrade}',
                                style: cellStyle))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Center(
                            child: pw.Text(
                          '${data.reviewFromSurah} (${data.reviewFromVerse}) - ${data.reviewToSurah} (${data.reviewToVerse})',
                          style: cellStyle,
                          maxLines: 2,
                          overflow: pw.TextOverflow.span,
                        ))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('${data.reviewGrade}',
                                style: cellStyle))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('${data.attendanceGrade}',
                                style: cellStyle))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('${data.behaviorGrade}',
                                style: cellStyle))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('${data.oralGrade}',
                                style: cellStyle))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('${data.paperGrade}',
                                style: cellStyle))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('${data.total}\u0025',
                                style: cellStyle))),
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
      final pdf = pw.Document();
      monthlyReportPage(reportName, monthlyReport, pdf);
      final directory = Directory('/storage/emulated/0/Download');
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

class GroupsGeneral {
  int id;
  String groupName;

  GroupsGeneral({required this.id, required this.groupName});

  factory GroupsGeneral.fromJson(Map<String, dynamic> json) {
    return GroupsGeneral(
        id: json["id"] as int, groupName: json["groupName"] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupName': groupName,
    };
  }
}

class MonthlyReportModel {
  String studentName;

  String saveFromSurah;
  int saveFromVerse;
  String saveToSurah;
  int saveToVerse;
  String saveRate;
  double savePages;

  String reviewFromSurah;
  int reviewFromVerse;
  String reviewToSurah;
  int reviewToVerse;
  String reviewRate;
  double reviewPages;

  double saveGrade;
  double reviewGrade;
  int attendanceGrade;
  int behaviorGrade;
  double paperGrade;
  double oralGrade;
  double total;

  MonthlyReportModel(
      {required this.studentName,
      required this.saveFromSurah,
      required this.saveFromVerse,
      required this.saveToSurah,
      required this.saveToVerse,
      required this.saveRate,
      required this.savePages,
      required this.reviewFromSurah,
      required this.reviewFromVerse,
      required this.reviewToSurah,
      required this.reviewToVerse,
      required this.reviewRate,
      required this.reviewPages,
      required this.saveGrade,
      required this.reviewGrade,
      required this.attendanceGrade,
      required this.behaviorGrade,
      required this.oralGrade,
      required this.paperGrade,
      required this.total});

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportModel(
      studentName: json["studentName"] as String,
      saveFromSurah: json["saveData"]["from"]["surahName"] as String,
      saveToSurah: json["saveData"]["to"]["surahName"] as String,
      saveFromVerse: json["saveData"]["from"]["verse"] as int,
      saveToVerse: json["saveData"]["to"]["verse"] as int,
      savePages: (json["saveData"]["pages"] is int)
          ? (json["saveData"]["pages"] as int).toDouble()
          : double.parse(json["saveData"]["pages"].toString()),
      saveRate: json["saveData"]["rate"]?.toString() ?? "",
      reviewFromSurah: json["reviewData"]["from"]["surahName"] as String,
      reviewToSurah: json["reviewData"]["to"]["surahName"] as String,
      reviewFromVerse: json["reviewData"]["from"]["verse"] as int,
      reviewToVerse: json["reviewData"]["to"]["verse"] as int,
      reviewPages: (json["reviewData"]["pages"] is int)
          ? (json["reviewData"]["pages"] as int).toDouble()
          : double.parse(json["reviewData"]["pages"].toString()),
      reviewRate: json["reviewData"]["rate"]?.toString() ?? "",
      saveGrade: (json["saveGrade"] is int)
          ? (json["saveGrade"] as int).toDouble()
          : double.parse(json["saveGrade"].toString()),
      reviewGrade: json["reviewGrade"] is int
          ? (json["reviewGrade"] as int).toDouble()
          : double.parse(json["reviewGrade"].toString()),
      attendanceGrade: json["attendanceGrade"] as int,
      behaviorGrade: json["behaviorGrade"] as int,
      oralGrade: (json["oralGrade"] is int)
          ? (json["oralGrade"] as int).toDouble()
          : double.parse(json["oralGrade"].toString()),
      paperGrade: (json["paperGrade"] is int)
          ? (json["paperGrade"] as int).toDouble()
          : double.parse(json["paperGrade"].toString()),
      total: (json["total"] is int)
          ? (json["total"] as int).toDouble()
          : double.parse(json["total"].toString()),
    );
  }
}
