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
  var selectedDate = JDateModel(jhijri: JHijri.now()).obs;

  var groups = <GroupsGeneral>[].obs;
  var selectedGroupId = 0.obs;
  var selectedGroupName = ''.obs;

  var monthlyReport =
      MonthlyReportResponse(books: [], data: []).obs;

  Future getMonthlyReport() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$monthlyReportURL?groupId=$selectedGroupId&year=${selectedDate.value.jhijri!.year}&month=${selectedDate.value.jhijri!.month}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Map<String, dynamic> result = response.data;
        print(result);
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
      print(e);
      catchSnackBar();
    } finally {
      isLoading.value = false;
    }
  }

  Future UpdateExams(
      {required int followStudentId,
      double? paperExam,
      double? oralExam}) async {
    try {
      isLoadingUpdate.value = true;
      var response = await _apiClient.dio
          .post("/$monthlyExamsURL?followStudentId=$followStudentId", data: {
        "paperExam": paperExam,
        "oralExam": oralExam
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
        "month":
            "${selectedDate.value.jhijri!.year}-${selectedDate.value.jhijri!.month.toString().padLeft(2, '0')}-01",
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
        "month":
            "${selectedDate.value.jhijri!.year}-${selectedDate.value.jhijri!.month.toString().padLeft(2, '0')}-01",
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
  int followStudentId;
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

  MonthlyReportModel({
    required this.followStudentId,
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
      followStudentId: json["followStudentId"] as int,
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
      attendanceGrade: json["attendanceGrade"] as int,
      behaviorGrade: json["behaviorGrade"] as int,
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
  DateTime month;

  BooksData({
    required this.id,
    required this.title,
    required this.from,
    required this.to,
    required this.month,
  });

  factory BooksData.fromJson(Map<String, dynamic> json) {
    return BooksData(
      id: json["id"] as int,
      title: json["title"] as String,
      from: json["from"].toString(),
      to: json["to"].toString(),
      month: DateTime.parse(json["month"]),
    );
  }
}
