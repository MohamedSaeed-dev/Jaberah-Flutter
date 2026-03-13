import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthlyStudentsReportsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var isLoadingUpdate = false.obs;
  var selectedDate =
      JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

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
    final firstOfNextHijri =
        JHijri(fYear: nextYear, fMonth: nextMonth, fDay: 1);
    final toDateTime =
        firstOfNextHijri.dateTime.subtract(const Duration(days: 1));
    monthReportToDate.value =
        '${toDateTime.year}-${toDateTime.month.toString().padLeft(2, '0')}-${toDateTime.day.toString().padLeft(2, '0')}';
  }

  var groups = <GroupsGeneral>[].obs;
  var selectedGroupId = 0.obs;
  var selectedGroupName = ''.obs;

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
      var url =
          "/$monthlyReportURL?groupId=$selectedGroupId&fromDate=$fromDate&toDate=$toDate";
      var response =
          await _apiClient.dio.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Map<String, dynamic> result = response.data;

        monthlyReport.value = MonthlyReportResponse.fromJson(result);
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

  Future UpdateExams(
      {required int studentId,
      double? paperExam,
      double? oralExam}) async {
    try {
      isLoadingUpdate.value = true;
      var response = await _apiClient.dio
          .post("/$monthlyExamsURL", data: {
        "paperExam": paperExam,
        "oralExam": oralExam,
        "date": "${selectedDate.value.dateTime!.year}-${selectedDate.value.dateTime!.month.toString().padLeft(2, '0')}-${selectedDate.value.dateTime!.day.toString().padLeft(2, '0')}",
        "studentId": studentId
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        Get.back();
        successSnackBar("تم تعديل النتائج بنجاح");
        await getMonthlyReport();
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
      isLoadingUpdate.value = false;
    }
  }

  Future<void> addBook({
    required String title,
    required String from,
    required String to,
  }) async {
    isLoading.value = true;
    try {
      final body = {
        "title": title,
        "from": from,
        "to": to,
        "date":
            "${selectedDate.value.dateTime!.year}-${selectedDate.value.dateTime!.month.toString().padLeft(2, '0')}-${selectedDate.value.dateTime!.day.toString().padLeft(2, '0')}",
      };

      final response = await _apiClient.dio
          .post("/groups/${selectedGroupId.value}/books", data: body);

      if (response.statusCode == 200) {
        Get.back();
        await getMonthlyReport();
        successSnackBar("تمت إضافة الكتاب بنجاح");
      } else {
        messageSnackBar(response.data["message"]);
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBook({
    required int bookId,
    required String title,
    required String from,
    required String to,
  }) async {
    isLoading.value = true;
    try {
      final body = {
        "title": title,
        "from": from,
        "to": to,
        "date":
            "${selectedDate.value.dateTime!.year}-${selectedDate.value.dateTime!.month.toString().padLeft(2, '0')}-${selectedDate.value.dateTime!.day.toString().padLeft(2, '0')}",
      };

      final response =
          await _apiClient.dio.put("/groups/books/$bookId", data: body);

      if (response.statusCode == 200) {
        Get.back();
        await getMonthlyReport();
        successSnackBar("تم تعديل الكتاب بنجاح");
        Get.back();
      } else {
        messageSnackBar(response.data["message"]);
      }
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBook(int bookId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.delete("/groups/books/$bookId");

      if (response.statusCode == 200) {
        Get.back();
        await getMonthlyReport();
        successSnackBar("تم حذف الكتاب");
      } else {
        messageSnackBar(response.data["message"]);
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
}

class GroupsGeneral {
  int id;
  String name;

  GroupsGeneral({required this.id, required this.name});

  factory GroupsGeneral.fromJson(Map<String, dynamic> json) {
    return GroupsGeneral(id: json["id"] as int, name: json["name"] as String);
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
  DateTime date;

  BooksData({
    required this.id,
    required this.title,
    required this.from,
    required this.to,
    required this.date,
  });

  factory BooksData.fromJson(Map<String, dynamic> json) {
    return BooksData(
      id: json["id"] as int,
      title: json["title"] as String,
      from: json["from"].toString(),
      to: json["to"].toString(),
      date: DateTime.parse(json["date"]),
    );
  }
}
