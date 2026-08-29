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
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class MonthlyReportController extends GetxController {
  /// قيمة اختيار «كل الحلقات» في قائمة الحلقات المنسدلة.
  /// تُرسل إلى الـ API كـ null ليتم جلب أفضل الطلاب على جميع الحلقات.
  static const int kAllGroupsId = -1;

  /// قيمة اختيار «كل الطلاب» في قائمة عدد الطلاب؛ عند اختيارها لا يُمرَّر معامل `take` للـ API.
  static const int kAllStudentsTake = -1;

  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var isLoadingUpdate = false.obs; // Add this for exam updates
  var selectedDate =
      JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  /// عدد الطلاب المراد عرضهم (يستخدم عند اختيار كل الحلقات لجلب أفضل الطلاب).
  var take = 5.obs;

  bool get isAllGroupsSelected => selectedGroupId.value == kAllGroupsId;

  bool get isAllStudentsTake => take.value == kAllStudentsTake;

  /// بداية ونهاية الشهر الهجري المختار بالميلادي (للـ API).
  var monthReportFromDate = ''.obs;
  var monthReportToDate = ''.obs;

  /// يحسب fromDate و toDate من أول/آخر يوم في الشهر الهجري المختار (ميلادي). يُستدعى عند تحديد التاريخ.
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
    final firstOfNextHijri = JHijri(fYear: nextYear, fMonth: nextMonth, fDay: 1);
    final toDateTime = firstOfNextHijri.dateTime.subtract(const Duration(days: 1));
    monthReportToDate.value =
        '${toDateTime.year}-${toDateTime.month.toString().padLeft(2, '0')}-${toDateTime.day.toString().padLeft(2, '0')}';
  }

  var groups = <GroupsGeneral>[].obs;
  var selectedGroupId = kAllGroupsId.obs;
  var selectedGroupName = 'كل الحلقات'.obs;

  var monthlyReport = MonthlyReportResponse(books: [], data: []).obs;

  Future getMonthlyReport() async {
    try {
      isLoading.value = true;
      final fromDate = monthReportFromDate.value;
      final toDate = monthReportToDate.value;
      if (fromDate.isEmpty || toDate.isEmpty) {
        messageSnackBar('يرجى اختيار الشهر أولاً');
        isLoading.value = false;
        return;
      }
      // عند اختيار «كل الحلقات» نرسل groupId كقيمة فارغة ليتم تمريرها null في السيرفر.
      final groupIdParam =
          isAllGroupsSelected ? null : '${selectedGroupId.value}';
      var url =
          "/$monthlyReportURL?fromDate=$fromDate&toDate=$toDate";
      if (!isAllStudentsTake) {
        url = "$url&take=${take.value}";
      }
      if (groupIdParam != null) {
        url = "$url&groupId=$groupIdParam";
      }
      var response =
          await _apiClient.dio.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Map<String, dynamic> result = response.data;
        monthlyReport.value = MonthlyReportResponse.fromJson(result);
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

  Future getGroups() async {
    try {
      var response = await _apiClient.dio
          .get("/$groupsForGeneralUseURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value =
            result.map((item) => GroupsGeneral.fromJson(item)).toList();
        // الاختيار الافتراضي هو «كل الحلقات».
        selectedGroupId.value = kAllGroupsId;
        selectedGroupName.value = 'كل الحلقات';
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

  void monthlyReportPage(String reportName,
      MonthlyReportResponse monthlyReportData, Document pdf) async {
    final fontData = await rootBundle.load('fonts/GE_SS_Two_Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final headerStyle = pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        font: ttf,
        fontFallback: [Font.helvetica()]);

    final cellStyle =
        pw.TextStyle(fontSize: 9, font: ttf, fontFallback: [Font.helvetica()]);

    final titleStyle = pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        font: ttf,
        fontFallback: [Font.helvetica()]);

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
          List<pw.Widget> content = [];

          // Add Books Section if books exist
          if (monthlyReportData.books.isNotEmpty) {
            content.addAll([
              pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: pw.EdgeInsets.only(bottom: 15),
                child: pw.Text(
                  'كتب الحلقة:',
                  style: titleStyle,
                ),
              ),
              // Books Table Header
              pw.Container(
                color: PdfColors.grey300,
                padding: pw.EdgeInsets.all(8),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        flex: 1,
                        child:
                            pw.Center(child: pw.Text('م', style: headerStyle))),
                    pw.Expanded(
                        flex: 4,
                        child: pw.Center(
                            child:
                                pw.Text('عنوان الكتاب', style: headerStyle))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('من صفحة', style: headerStyle))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Center(
                            child: pw.Text('إلى صفحة', style: headerStyle))),
                  ],
                ),
              ),
              // Books Rows
              ...monthlyReportData.books.asMap().entries.map((entry) {
                final index = entry.key;
                final book = entry.value;
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
                              child:
                                  pw.Text('${index + 1}', style: cellStyle))),
                      pw.Expanded(
                          flex: 4,
                          child: pw.Center(
                              child: pw.Text(book.title, style: cellStyle))),
                      pw.Expanded(
                          flex: 2,
                          child: pw.Center(
                              child: pw.Text(book.from, style: cellStyle))),
                      pw.Expanded(
                          flex: 2,
                          child: pw.Center(
                              child: pw.Text(book.to, style: cellStyle))),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 30), // Space between books and students
            ]);
          }

          // Add Students Section Title
          content.add(
            pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: pw.EdgeInsets.only(bottom: 15),
              child: pw.Text(
                'تقرير الطلاب:',
                style: titleStyle,
              ),
            ),
          );

          // Students Table Header
          content.add(
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
                      flex: 2,
                      child: pw.Center(
                          child: pw.Text('عدد صفحات الحفظ', style: headerStyle))),
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
                          child: pw.Text('عدد صفحات المراجعة', style: headerStyle))),
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
          );

          // Students Table Rows
          content.addAll(
            monthlyReportData.data.asMap().entries.map((entry) {
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
                          child: pw.Text('${data.savePages}',
                              style: cellStyle))),
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
                            child: pw.Text('${data.reviewPages}',
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
          );

          return content;
        },
      ),
    );
  }

  Future<void> exportAsPDF(String reportName) async {
    try {
      await requestStoragePermission();
      final pdf = pw.Document();
      monthlyReportPage(reportName, monthlyReport.value, pdf);
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

class GroupsGeneral {
  int id;
  String name;

  GroupsGeneral({required this.id, required this.name});

  factory GroupsGeneral.fromJson(Map<String, dynamic> json) {
    return GroupsGeneral(
        id: json["id"] as int, name: json["name"] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class MonthlyReportResponse {
  List<BooksData> books;
  List<MonthlyReportModel> data;

  MonthlyReportResponse({
    required this.books,
    required this.data,
  });

  factory MonthlyReportResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyReportResponse(
      books: (json['books'] as List).map((b) => BooksData.fromJson(b)).toList(),
      data: (json['data'] as List)
          .map((d) => MonthlyReportModel.fromJson(d))
          .toList(),
    );
  }
}

class MonthlyReportModel {
  int studentId;
  String studentName;
  String? groupName;

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
  double attendanceGrade;
  double behaviorGrade;
  double paperGrade;
  double oralGrade;
  double total;

  MonthlyReportModel({
    required this.studentId,
    required this.studentName,
    this.groupName,
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
    required this.paperGrade,
    required this.oralGrade,
    required this.total,
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportModel(
      studentId: json["studentId"] as int,
      studentName: json["studentName"] as String,
      groupName: json["groupName"] as String?,
      saveFromSurah: json["saveData"]["from"]["surahName"] as String,
      saveFromVerse: json["saveData"]["from"]["verse"] as int,
      saveToSurah: json["saveData"]["to"]["surahName"] as String,
      saveToVerse: json["saveData"]["to"]["verse"] as int,
      savePages: _toDouble(json["saveData"]["pages"]),
      saveRate: json["saveData"]["rate"]?.toString() ?? "",
      reviewFromSurah: json["reviewData"]["from"]["surahName"] as String,
      reviewFromVerse: json["reviewData"]["from"]["verse"] as int,
      reviewToSurah: json["reviewData"]["to"]["surahName"] as String,
      reviewToVerse: json["reviewData"]["to"]["verse"] as int,
      reviewPages: _toDouble(json["reviewData"]["pages"]),
      reviewRate: json["reviewData"]["rate"]?.toString() ?? "",
      saveGrade: _toDouble(json["saveGrade"]),
      reviewGrade: _toDouble(json["reviewGrade"]),
      attendanceGrade: _toDouble(json["attendanceGrade"]),
      behaviorGrade: _toDouble(json["behaviorGrade"]),
      paperGrade: _toDouble(json["paperGrade"]),
      oralGrade: _toDouble(json["oralGrade"]),
      total: _toDouble(json["total"]),
    );
  }

  static double _toDouble(dynamic val) {
    if (val is int) return val.toDouble();
    if (val is double) return val;
    return double.tryParse(val.toString()) ?? 0.0;
  }
}

class BooksData {
  int id;
  String title;
  String from;
  String to;

  BooksData({
    required this.id,
    required this.title,
    required this.from,
    required this.to,
  });

  factory BooksData.fromJson(Map<String, dynamic> json) {
    return BooksData(
      id: json["id"] as int,
      title: json["title"] as String,
      from: json["from"].toString(),
      to: json["to"].toString(),
    );
  }
}
