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

class CleaningLogReportController extends GetxController {
  final ApiClient _apiClient = Get.find();

  var isLoading = false.obs;
  var selectedDate =
      JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  var groups = <GroupsGeneral>[].obs;

  /// null = كل الحلقات
  Rxn<int> selectedGroupId = Rxn<int>();
  var selectedGroupName = 'كل الحلقات'.obs;

  var report = CleaningLogDailyReport.empty().obs;
  var hasLoadedOnce = false.obs;

  /// التاريخ الميلادي بصيغة yyyy-MM-dd للإرسال للـ API
  String get dateStr {
    final d = selectedDate.value.dateTime;
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get hijriDateLabel {
    final h = selectedDate.value.jhijri;
    if (h == null) return '';
    return '${h.day} - ${h.monthName} - ${h.year}';
  }

  Future<void> getDailyReport() async {
    if (dateStr.isEmpty) {
      messageSnackBar('يرجى اختيار التاريخ أولاً');
      return;
    }
    try {
      isLoading.value = true;

      final query = <String, dynamic>{'date': dateStr};
      if (selectedGroupId.value != null) {
        query['groupId'] = selectedGroupId.value;
      }

      final response = await _apiClient.dio
          .get('/$cleaningLogsDailyReportURL', queryParameters: query)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        report.value = CleaningLogDailyReport.fromJson(
            response.data as Map<String, dynamic>);
        hasLoadedOnce.value = true;
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

  Future<void> getGroups() async {
    try {
      final response = await _apiClient.dio
          .get("/$groupsForGeneralUseURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final result = response.data as List<dynamic>;
        groups.value =
            result.map((item) => GroupsGeneral.fromJson(item)).toList();
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
    }
  }

  void setGroupFilter(int? groupId) {
    selectedGroupId.value = groupId;
    selectedGroupName.value = groupId == null
        ? 'كل الحلقات'
        : groups.firstWhereOrNull((g) => g.id == groupId)?.name ??
            'كل الحلقات';
  }

  @override
  void onInit() {
    super.onInit();
    getGroups();
  }

  Future<void> cleaningReportPdfPage(
    String reportName,
    CleaningLogDailyReport data,
    Document pdf,
  ) async {
    final fontData = await rootBundle.load('fonts/GE_SS_Two_Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final headerStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      font: ttf,
      fontFallback: [Font.helvetica()],
    );

    final cellStyle =
        pw.TextStyle(fontSize: 10, font: ttf, fontFallback: [Font.helvetica()]);

    final titleStyle = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      font: ttf,
      fontFallback: [Font.helvetica()],
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf),
        textDirection: pw.TextDirection.rtl,
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 10),
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
              margin: const pw.EdgeInsets.only(bottom: 15),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text('إجمالي المهمات: ${data.totalTasks}',
                      style: titleStyle),
                  pw.Text('المسندة: ${data.assignedCount}', style: titleStyle),
                  pw.Text('المنجزة: ${data.completedCount}',
                      style: titleStyle),
                  pw.Text('نسبة الإنجاز: ${data.completionPercentage}%',
                      style: titleStyle),
                ],
              ),
            ),
          );

          list.add(
            pw.Container(
              color: PdfColors.grey300,
              padding: const pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child:
                        pw.Center(child: pw.Text('الرقم', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Center(
                        child: pw.Text('اسم الطالب', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child:
                        pw.Center(child: pw.Text('الحلقة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Center(
                        child: pw.Text('نوع النظافة', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                        child: pw.Text('أُنجزت', style: headerStyle)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Center(
                        child: pw.Text('ملاحظات', style: headerStyle)),
                  ),
                ],
              ),
            ),
          );

          for (var i = 0; i < data.rows.length; i++) {
            final row = data.rows[i];
            list.add(
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                decoration: const pw.BoxDecoration(
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
                      flex: 4,
                      child: pw.Center(
                          child: pw.Text(row.studentName, style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Center(
                          child:
                              pw.Text(row.groupName ?? '-', style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Center(
                          child: pw.Text(row.taskName, style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text(row.isCompleted ? 'نعم' : 'لا',
                              style: cellStyle)),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Center(
                          child: pw.Text(row.notes ?? '-', style: cellStyle)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (data.unassignedTasks.isNotEmpty) {
            list.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 15),
                child: pw.Text(
                  'مهام غير مسندة اليوم: ${data.unassignedTasks.map((t) => t.nameAr).join('، ')}',
                  style: titleStyle,
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
      await cleaningReportPdfPage(reportName, report.value, pdf);
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

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

int? _asNullableInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

double _asDouble(dynamic value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

class CleaningLogDailyReport {
  final int totalTasks;
  final int assignedCount;
  final int completedCount;
  final int notCompletedCount;
  final double completionPercentage;
  final List<CleaningLogReportRow> rows;
  final List<CleaningTaskItem> unassignedTasks;

  CleaningLogDailyReport({
    required this.totalTasks,
    required this.assignedCount,
    required this.completedCount,
    required this.notCompletedCount,
    required this.completionPercentage,
    required this.rows,
    required this.unassignedTasks,
  });

  factory CleaningLogDailyReport.empty() => CleaningLogDailyReport(
        totalTasks: 0,
        assignedCount: 0,
        completedCount: 0,
        notCompletedCount: 0,
        completionPercentage: 0,
        rows: [],
        unassignedTasks: [],
      );

  factory CleaningLogDailyReport.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] is List ? json['rows'] as List : [];
    final unassigned =
        json['unassignedTasks'] is List ? json['unassignedTasks'] as List : [];
    return CleaningLogDailyReport(
      totalTasks: _asInt(json['totalTasks']),
      assignedCount: _asInt(json['assignedCount']),
      completedCount: _asInt(json['completedCount']),
      notCompletedCount: _asInt(json['notCompletedCount']),
      completionPercentage: _asDouble(json['completionPercentage']),
      rows: rows
          .map((e) => CleaningLogReportRow.fromJson(e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map)))
          .toList(),
      unassignedTasks: unassigned
          .map((e) => CleaningTaskItem.fromJson(e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class CleaningLogReportRow {
  final int cleaningTaskId;
  final String taskName;
  final int studentId;
  final String studentName;
  final int? groupId;
  final String? groupName;
  final bool isCompleted;
  final String? notes;

  CleaningLogReportRow({
    required this.cleaningTaskId,
    required this.taskName,
    required this.studentId,
    required this.studentName,
    this.groupId,
    this.groupName,
    required this.isCompleted,
    this.notes,
  });

  factory CleaningLogReportRow.fromJson(Map<String, dynamic> json) {
    return CleaningLogReportRow(
      cleaningTaskId: _asInt(json['cleaningTaskId']),
      taskName: json['taskName']?.toString() ?? '',
      studentId: _asInt(json['studentId']),
      studentName: json['studentName']?.toString() ?? '',
      groupId: _asNullableInt(json['groupId']),
      groupName: json['groupName']?.toString(),
      isCompleted: json['isCompleted'] == true,
      notes: json['notes']?.toString(),
    );
  }
}

class CleaningTaskItem {
  final int id;
  final String nameAr;

  CleaningTaskItem({required this.id, required this.nameAr});

  factory CleaningTaskItem.fromJson(Map<String, dynamic> json) {
    return CleaningTaskItem(
      id: _asInt(json['id']),
      nameAr: json['nameAr']?.toString() ?? '',
    );
  }
}
