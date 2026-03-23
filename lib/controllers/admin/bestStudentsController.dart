import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/models/global/storage-permission.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/jhijri_picker.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class BestStudentsController extends GetxController {
  /// قيمة اختيار «كل الحلقات» في القائمة المنسدلة
  static const String kAllGroupsId = 'all';

  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var selectedDate = JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  var groups = [].obs;
  var selectedGroupId = kAllGroupsId.obs;
  var selectedGroupName = 'كل الحلقات'.obs;

  var take = 5.obs;

  final bestStudentsReport = <BestStudentsReportModel>[].obs;

  bool get isAllGroupsSelected => selectedGroupId.value == kAllGroupsId;

  /// يحمّل تقرير حلقة واحدة أو جميع الحلقات حسب الاختيار الحالي
  Future<void> fetchBestStudentsReport() async {
    if (isAllGroupsSelected) {
      await getBestStudentsForMonthReport();
    } else {
      await getBestStudentsForMonthByGroupReport();
    }
  }

  Future getBestStudentsForMonthByGroupReport() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$bestStudentForGroupReportURL?groupId=${selectedGroupId.value}&year=${selectedDate.value.dateTime!.year}&month=${selectedDate.value.dateTime!.month}&take=${take.value}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        bestStudentsReport.assignAll(result
            .map((item) => BestStudentsReportModel.fromJson(item))
            .toList());
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

  Future getBestStudentsForMonthReport() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$bestStudentReportURL?year=${selectedDate.value.dateTime!.year}&month=${selectedDate.value.dateTime!.month}&take=${take.value}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        bestStudentsReport.assignAll(result
            .map((item) => BestStudentsReportModel.fromJson(item))
            .toList());
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
        groups.value = response.data;
        selectedGroupId.value = kAllGroupsId;
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
    } finally {}
  }

  void bestStudentsReportPage(String reportName,
      List<BestStudentsReportModel> bestStudentsReport, Document pdf) async {
    final fontData = await rootBundle.load('fonts/GE_SS_Two_Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final headerStyle = pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        font: ttf,
        fontFallback: [Font.helvetica()]);

    final cellStyle =
        pw.TextStyle(fontSize: 9, font: ttf, fontFallback: [Font.helvetica()]);

    bool showGroupName = bestStudentsReport.any((x) => x.groupName != null);
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
                      child: pw.Text('اسم الطالب', style: headerStyle),
                    ),
                  ),
                  if (showGroupName)
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child: pw.Text('اسم الحلقة', style: headerStyle),
                      ),
                    ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text('الحفظ', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text('المراجعة', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text('الحضور', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text('السلوك', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text('شفهي', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text('تحريري', style: headerStyle),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text('المجموع', style: headerStyle),
                    ),
                  ),
                ],
              ),
            ),
            // Table Rows
            ...bestStudentsReport.asMap().entries.map((entry) {
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
                    if (showGroupName)
                      pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                          child: pw.Text(data.groupName!, style: cellStyle),
                        ),
                      ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text('${data.saveGrade}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text('${data.reviewGrade}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text('${data.attendanceGrade}',
                            style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child:
                            pw.Text('${data.behaviorGrade}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text('${data.oralGrade}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text('${data.paperGrade}', style: cellStyle),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
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

  Future<void> exportAsPDF(
      String reportName, List<BestStudentsReportModel> list) async {
    try {
      await requestStoragePermission();
      final pdf = pw.Document();
      bestStudentsReportPage(reportName, list, pdf);
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

class BestStudentsReportModel {
  String studentName;
  String? groupName;

  double saveGrade;
  double reviewGrade;
  double attendanceGrade;
  double behaviorGrade;
  double paperGrade;
  double oralGrade;
  double total;

  BestStudentsReportModel(
      {required this.studentName,
      this.groupName,
      required this.saveGrade,
      required this.reviewGrade,
      required this.attendanceGrade,
      required this.behaviorGrade,
      required this.oralGrade,
      required this.paperGrade,
      required this.total});

  factory BestStudentsReportModel.fromJson(Map<String, dynamic> json) {
    return BestStudentsReportModel(
      studentName: json["studentName"] as String,
      groupName: json["groupName"] != null ? json["groupName"] as String : null,
      saveGrade: json["saveGrade"] is int
          ? (json["saveGrade"] as int).toDouble()
          : double.parse(json["saveGrade"].toString()),
      reviewGrade: json["reviewGrade"] is int
          ? (json["reviewGrade"] as int).toDouble()
          : double.parse(json["reviewGrade"].toString()),
      attendanceGrade: (json["attendanceGrade"] is int)
          ? (json["attendanceGrade"] as int).toDouble()
          : double.parse(json["attendanceGrade"].toString()),
      behaviorGrade: json["behaviorGrade"] is int
          ? (json["behaviorGrade"] as int).toDouble()
          : double.parse(json["behaviorGrade"].toString()),
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
