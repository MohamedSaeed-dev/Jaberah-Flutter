import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/models/global/storage-permission.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class StudentsPartialExamsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var isLoadingGroups = false.obs;
  var groups = <Group>[].obs;
  Rxn<int> selectedGroupId = Rxn<int>();
  var selectedGroupName = ''.obs;

  var students = <PartialExamStudent>[].obs;
  var filteredStudents = <PartialExamStudent>[].obs;
  var searchText = TextEditingController().obs;
  var selectedDate =
      JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  @override
  void onInit() {
    super.onInit();
    _loadGroupsThenStudents();
  }

  Future<void> _loadGroupsThenStudents() async {
    await loadGroups();
    if (selectedGroupId.value != null) {
      await getStudents();
    }
  }

  Future<void> loadGroups() async {
    try {
      isLoadingGroups.value = true;
      var response = await _apiClient.dio
          .get("/$groupsURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value =
            result.map((item) => Group.fromJson(item as Map<String, dynamic>)).toList();
        await _applySavedOrder();
        if (groups.isNotEmpty) {
          selectedGroupId.value = groups.first.id;
          selectedGroupName.value = groups.first.groupName;
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
    } finally {
      isLoadingGroups.value = false;
    }
  }

  Future<void> _applySavedOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedOrderJson = prefs.getString('groups_order');

      if (savedOrderJson != null) {
        List<int> savedOrder = List<int>.from(json.decode(savedOrderJson));

        Map<int, Group> groupsMap = {for (var group in groups) group.id: group};

        List<Group> orderedGroups = [];
        for (int id in savedOrder) {
          if (groupsMap.containsKey(id)) {
            orderedGroups.add(groupsMap[id]!);
            groupsMap.remove(id);
          }
        }

        orderedGroups.addAll(groupsMap.values);

        groups.value = orderedGroups;
      }
    } catch (e) {
      // ignore
    }
  }

  void onGroupSelected(int? id) {
    if (id == null) return;
    for (final g in groups) {
      if (g.id == id) {
        selectedGroupId.value = id;
        selectedGroupName.value = g.groupName;
        getStudents();
        return;
      }
    }
  }

  void searchStudents() {
    if (searchText.value.text.isEmpty) {
      filteredStudents.value = students;
    } else {
      filteredStudents.value = students
          .where((student) => student.studentName
              .toLowerCase()
              .contains(searchText.value.text.toLowerCase()))
          .toList();
    }
  }

  Future<void> getStudents() async {
    final gid = selectedGroupId.value;
    if (gid == null) return;

    try {
      isLoading.value = true;

      // تحويل التاريخ الهجري إلى ميلادي
      var hijriDate = selectedDate.value.jhijri!;
      HijriCalendar hijri = HijriCalendar();
      hijri.hYear = hijriDate.year;
      hijri.hMonth = hijriDate.month;
      hijri.hDay = hijriDate.day;

      // hijriToGregorian يعطي DateTime الميلادي
      DateTime gregorianDate = hijri.hijriToGregorian(
          hijriDate.year, hijriDate.month, hijriDate.day);

      var dateString =
          "${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}";

      var response = await _apiClient.dio
          .get("/$partialExamsURL/group/$gid?date=$dateString")
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        students.value =
            result.map((item) => PartialExamStudent.fromJson(item)).toList();
        filteredStudents.value = students;
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

  void partialExamReportPage(String reportName, pw.Document pdf) async {
    final fontData = await rootBundle.load('fonts/GE_SS_Two_Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final headerStyle = pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        font: ttf,
        fontFallback: [pw.Font.helvetica()]);

    final cellStyle = pw.TextStyle(
        fontSize: 9, font: ttf, fontFallback: [pw.Font.helvetica()]);

    // التاريخ الهجري
    var hijriDate = selectedDate.value.jhijri!;
    String dateString =
        "${hijriDate.day} ${hijriDate.monthName} ${hijriDate.year} هـ";

    // فقط الطلاب الذين لديهم اختبارات
    var studentsWithExams = students.where((s) => s.hasExam).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: pw.ThemeData.withFont(base: ttf),
        textDirection: pw.TextDirection.rtl,
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              children: [
                pw.Text(
                  reportName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'التاريخ: $dateString',
                  style: pw.TextStyle(fontSize: 12, font: ttf),
                ),
              ],
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
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
              columnWidths: {
                0: pw.FixedColumnWidth(50), // التقدير
                1: pw.FixedColumnWidth(55), // الجزء
                2: pw.FixedColumnWidth(60), // المختبر
                3: pw.FixedColumnWidth(50), // المجموع
                4: pw.FixedColumnWidth(45), // الأداء
                5: pw.FixedColumnWidth(35), // س10
                6: pw.FixedColumnWidth(35), // س9
                7: pw.FixedColumnWidth(35), // س8
                8: pw.FixedColumnWidth(35), // س7
                9: pw.FixedColumnWidth(35), // س6
                10: pw.FixedColumnWidth(35), // س5
                11: pw.FixedColumnWidth(35), // س4
                12: pw.FixedColumnWidth(35), // س3
                13: pw.FixedColumnWidth(35), // س2
                14: pw.FixedColumnWidth(35), // س1
                15: pw.FlexColumnWidth(5), // اسم الطالب
                16: pw.FixedColumnWidth(40), // #
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey400,
                  ),
                  children: [
                    _buildTableCell('التقدير', headerStyle),
                    _buildTableCell('الجزء', headerStyle),
                    _buildTableCell('المختبر', headerStyle),
                    _buildTableCell('المجموع', headerStyle),
                    _buildTableCell('الأداء', headerStyle),
                    _buildTableCell('س10', headerStyle),
                    _buildTableCell('س9', headerStyle),
                    _buildTableCell('س8', headerStyle),
                    _buildTableCell('س7', headerStyle),
                    _buildTableCell('س6', headerStyle),
                    _buildTableCell('س5', headerStyle),
                    _buildTableCell('س4', headerStyle),
                    _buildTableCell('س3', headerStyle),
                    _buildTableCell('س2', headerStyle),
                    _buildTableCell('س1', headerStyle),
                    _buildTableCell('اسم الطالب', headerStyle),
                    _buildTableCell('#', headerStyle),
                  ],
                ),
                // Data Rows
                ...studentsWithExams.asMap().entries.map((entry) {
                  int index = entry.key;
                  PartialExamStudent student = entry.value;
                  // استخدام قيمة التقدير من البيانات أو حسابها من المجموع
                  String rateValue =
                      student.rate != null && student.rate!.isNotEmpty
                          ? student.rate!
                          : _calculateRate(student.totalScore);

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color:
                          index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
                      border: pw.Border(
                          bottom: pw.BorderSide(color: PdfColors.grey300)),
                    ),
                    children: [
                      _buildTableCell(rateValue, cellStyle),
                      _buildTableCell(student.part ?? '-', cellStyle),
                      _buildTableCell(student.tester ?? '-', cellStyle),
                      _buildTableCell(
                          student.totalScore?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.performance?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question10?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question9?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question8?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question7?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question6?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question5?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question4?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question3?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question2?.toString() ?? '-', cellStyle),
                      _buildTableCell(
                          student.question1?.toString() ?? '-', cellStyle),
                      _buildTableCell(student.studentName, cellStyle),
                      _buildTableCell('${index + 1}', cellStyle),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.TextStyle style) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      alignment: pw.Alignment.center,
      child: pw.Center(
        child: pw.Text(
          text,
          style: style,
          textAlign: pw.TextAlign.center,
          maxLines: 2,
          overflow: pw.TextOverflow.visible,
        ),
      ),
    );
  }

  // دالة لحساب التقدير بناءً على المجموع
  String _calculateRate(double? totalScore) {
    if (totalScore == null) return '-';
    if (totalScore >= 18) return 'ممتاز';
    if (totalScore >= 16) return 'جيد جداً';
    if (totalScore >= 14) return 'جيد';
    if (totalScore >= 12) return 'مقبول';
    return 'ضعيف';
  }

  Future<void> exportAsPDF(String reportName) async {
    try {
      await requestStoragePermission();
      final pdf = pw.Document();
      partialExamReportPage(reportName, pdf);
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

  @override
  void onClose() {
    searchText.value.dispose();
    super.onClose();
  }
}

class PartialExamStudent {
  int studentId;
  String studentName;
  int? examId;
  double? question1;
  double? question2;
  double? question3;
  double? question4;
  double? question5;
  double? question6;
  double? question7;
  double? question8;
  double? question9;
  double? question10;
  double? performance;
  String? tester;
  String? part;
  String? rate;
  String? notes;
  double? totalScore;

  PartialExamStudent({
    required this.studentId,
    required this.studentName,
    this.examId,
    this.question1,
    this.question2,
    this.question3,
    this.question4,
    this.question5,
    this.question6,
    this.question7,
    this.question8,
    this.question9,
    this.question10,
    this.performance,
    this.tester,
    this.part,
    this.rate,
    this.notes,
    this.totalScore,
  });

  bool get hasExam => examId != null;

  @override
  String toString() {
    return 'studentName: $studentName, question1: $question1, question2: $question2, question3: $question3, question4: $question4, question5: $question5, question6: $question6, question7: $question7, question8: $question8, question9: $question9, question10: $question10, performance: $performance, tester: $tester, part: $part, rate: $rate, notes: $notes, totalScore: $totalScore, hasExam: $hasExam';
  }

  factory PartialExamStudent.fromJson(Map<String, dynamic> json) {
    return PartialExamStudent(
      studentId: json["studentId"] as int,
      studentName: json["studentName"] as String,
      examId: json["examId"] as int?,
      question1: json["question1"] != null
          ? (json["question1"] as num).toDouble()
          : null,
      question2: json["question2"] != null
          ? (json["question2"] as num).toDouble()
          : null,
      question3: json["question3"] != null
          ? (json["question3"] as num).toDouble()
          : null,
      question4: json["question4"] != null
          ? (json["question4"] as num).toDouble()
          : null,
      question5: json["question5"] != null
          ? (json["question5"] as num).toDouble()
          : null,
      question6: json["question6"] != null
          ? (json["question6"] as num).toDouble()
          : null,
      question7: json["question7"] != null
          ? (json["question7"] as num).toDouble()
          : null,
      question8: json["question8"] != null
          ? (json["question8"] as num).toDouble()
          : null,
      question9: json["question9"] != null
          ? (json["question9"] as num).toDouble()
          : null,
      question10: json["question10"] != null
          ? (json["question10"] as num).toDouble()
          : null,
      performance: json["performance"] != null
          ? (json["performance"] as num).toDouble()
          : null,
      tester: json["tester"] as String?,
      part: json["part"] as String?,
      rate: json["rate"] as String?,
      notes: json["notes"] as String?,
      totalScore: json["totalScore"] != null
          ? (json["totalScore"] as num).toDouble()
          : null,
    );
  }
}
