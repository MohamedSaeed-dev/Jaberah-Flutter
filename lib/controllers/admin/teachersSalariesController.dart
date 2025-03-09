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

  var currentSignature = false.obs;

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
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } on DioException catch (e) {
      messageSnackBar(e.response!.data["message"]);
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoading.value = false;
    }
  }

  Future updateTeachersSalaries(
      String teacherId, double salary, bool signature) async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio.post(
          "/$teachersSalariesURL?year=$currentYear&month=$selectedMonth",
          data: {
            "teacherId": teacherId,
            "salary": salary,
            "signature": signature
          }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        Get.back();
        successSnackBar("تم تحديث رواتب المعلمين لشهر $monthName");
        await getTeachersSalaries();
        currentSignature.value = false;
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } on DioException catch (e) {
      messageSnackBar(e.response!.data["message"]);
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
  double salary;
  double netSalary;
  int daysAbsence;
  bool signature;

  TeacherSalaries(
      {required this.teacherId,
      required this.teacherName,
      required this.salary,
      required this.netSalary,
      required this.daysAbsence,
      required this.signature});

  factory TeacherSalaries.fromJson(Map<String, dynamic> json) {
    return TeacherSalaries(
        teacherId: json["teacherId"] as int,
        teacherName: json["teacherName"] as String,
        salary: (json["salary"] is int)
            ? (json["salary"] as int).toDouble()
            : double.parse(json["salary"].toString()),
        netSalary: (json["netSalary"] is int)
            ? (json["netSalary"] as int).toDouble()
            : double.parse(json["netSalary"].toString()),
        daysAbsence: json["daysAbsence"] as int,
        signature: json["signature"] as bool);
  }
}
