import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/jHijri.dart';

class TeachersSalariesController extends GetxController {
  final ApiClient _apiClient = Get.find();
  final List<Map<String, dynamic>> hijriMonths = [
    {'month': 'محرم', 'value': 1},
    {'month': 'صفر', 'value': 2},
    {'month': 'ربيع الأول', 'value': 3},
    {'month': 'ربيع الآخر', 'value': 4},
    {'month': 'جمادى الأولى', 'value': 5},
    {'month': 'جمادى الآخرة', 'value': 6},
    {'month': 'رجب', 'value': 7},
    {'month': 'شعبان', 'value': 8},
    {'month': 'رمضان', 'value': 9},
    {'month': 'شوال', 'value': 10},
    {'month': 'ذو القعدة', 'value': 11},
    {'month': 'ذو الحجة', 'value': 12},
  ];

  var entries = <String, Entry>{}.obs;

  // Update the entry map with new values
  void updateEntry(String id,
      {double? salary, bool? signature, int? daysAbsence, int? hoursAbsence}) {
    if (entries.containsKey(id)) {
      var entry = entries[id]!;
      entries[id] = Entry(
          salary: salary ?? entry.salary,
          daysAbsence: daysAbsence ?? entry.daysAbsence,
          hoursAbsence: hoursAbsence ?? entry.hoursAbsence,
          signature: signature ?? entry.signature);
    }
  }

  var editedTeachersSalaries = {}.obs;

  var teachersSalaries = <TeacherSalaries>[].obs;

  var isLoading = false.obs;

  var currentYear = JHijri.now().year;

  var selectedMonth = JHijri.now().month.obs;
  var monthName = JHijri.now().monthName.obs;

  Future getTeachersSalaries() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$teachersSalariesURL/for-month?year=$currentYear&month=$selectedMonth")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        teachersSalaries.value =
            result.map((item) => TeacherSalaries.fromJson(item)).toList();
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

  Future updateTeachersSalaries(
      String teacherId, int groupId, double salary, bool isPaid) async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio.post(
          "/$teachersSalariesURL?year=$currentYear&month=$selectedMonth",
          data: {
            "teacherId": teacherId,
            "groupId": groupId,
            "salary": salary,
            "isPaid": isPaid
          }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar("تم تحديث رواتب المعلمين لشهر $monthName");
        await getTeachersSalaries();
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
    getTeachersSalaries();
  }
}

class Entry {
  double salary;
  int daysAbsence;
  int hoursAbsence;
  bool signature;

  Entry({
    required this.salary,
    required this.daysAbsence,
    required this.hoursAbsence,
    required this.signature,
  });
  Map<String, dynamic> toJson() {
    return {
      'salary': salary,
      'daysAbsence': daysAbsence,
      'hoursAbsence': hoursAbsence,
      'signature': signature,
    };
  }
}

class TeacherSalaries {
  int teacherId;
  String teacherName;
  int groupId;
  String groupName;
  double? salary;
  bool isPaid;
  DateTime? paidAt;

  TeacherSalaries(
      {required this.teacherId,
      required this.teacherName,
      required this.salary,
      required this.groupId,
      required this.groupName,
      required this.isPaid,
      required this.paidAt});

  factory TeacherSalaries.fromJson(Map<String, dynamic> json) {
    return TeacherSalaries(
        teacherId: json["teacherId"] as int,
        teacherName: json["teacherName"] as String,
        salary: (json["salary"] is int)
            ? (json["salary"] as int).toDouble()
            : json["salary"] != null ? double.parse(json["salary"].toString()) : null,
        groupId: json["groupId"] as int,
        groupName: json["groupName"] as String,
        isPaid: json["isPaid"] as bool,
        paidAt: json["paidAt"] != null ? DateTime.parse(json["paidAt"]) : null);
  }
}
