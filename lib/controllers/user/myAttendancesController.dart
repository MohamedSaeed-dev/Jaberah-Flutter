// unchanged imports
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAttendancesController extends GetxController {
  Rx<DateTime> focusedDay = DateTime.now().obs;
  Rx<DateTime> selectedDay = DateTime.now().obs;

  var selectedAttendance =
      MyAttendance(isExcuse: null, signature: null, date: null, createdAt: null)
          .obs;

  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;

  Rx<MyAttendance> dataForDay =
      MyAttendance(isExcuse: null, signature: null, date: null, createdAt: null)
          .obs;
  var dataForMonth = <MyAttendance>[].obs;

  var isAdmin = false.obs;

  final Map<int, String> hijriMonthNames = {
    1: 'محرم',
    2: 'صفر',
    3: 'ربيع الأول',
    4: 'ربيع الآخر',
    5: 'جمادى الأولى',
    6: 'جمادى الآخرة',
    7: 'رجب',
    8: 'شعبان',
    9: 'رمضان',
    10: 'شوال',
    11: 'ذو القعدة',
    12: 'ذو الحجة',
  };

  String getHijriMonthName(DateTime date) {
    return '${hijriMonthNames[date.month]} ${date.year} هـ';
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;

    final foundAttendance = dataForMonth.firstWhereOrNull((att) {
      if (att.date == null) return false;
      return att.date!.year == selected.year &&
          att.date!.month == selected.month &&
          att.date!.day == selected.day;
    });

    selectedAttendance.value = foundAttendance ??
        MyAttendance(
            isExcuse: null, signature: null, date: null, createdAt: null);
  }

  Future getAttendanceForDay() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var teacherId = sp.getString("id");

      isLoading.value = true;
      final url =
          "/$teachersAttendancesURL/$teacherId/for-day?date=${focusedDay.value.year}-${focusedDay.value.month}-${focusedDay.value.day}";

      var response =
          await _apiClient.dio.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        dataForDay.value = MyAttendance.fromJson(response.data);
      } else if (response.statusCode == 204) {
        dataForDay.value = MyAttendance(
            isExcuse: null, signature: null, date: null, createdAt: null);
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

  Future getAttendanceForMonth() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var teacherId = sp.getString("id");
      isLoading.value = true;
      final url =
          "/$teachersAttendancesURL/$teacherId/for-month?date=${focusedDay.value.year}-${focusedDay.value.month}-${focusedDay.value.day}";

      var response =
          await _apiClient.dio.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        dataForMonth.value =
            result.map((e) => MyAttendance.fromJson(e)).toList();
        selectedAttendance.value = dataForMonth.firstWhereOrNull((att) {
              final attDate = att.date;
              if (attDate == null) return false;
              return attDate.year == focusedDay.value.year &&
                  attDate.month == focusedDay.value.month &&
                  attDate.day == focusedDay.value.day;
            }) ??
            MyAttendance(
                isExcuse: null, signature: null, date: null, createdAt: null);
      } else if (response.statusCode == 204) {
        dataForMonth.clear();
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

  MyAttendance? getAttendanceForDate(DateTime date) {
    return dataForMonth.firstWhereOrNull((att) {
      if (att.date == null) return false;
      return att.date!.year == date.year &&
          att.date!.month == date.month &&
          att.date!.day == date.day;
    });
  }

  String formatCreatedAt(DateTime? dateTime) {
    if (dateTime == null) return 'تاريخ الإنشاء غير متوفر';

    // Include time zone abbreviation (e.g., GMT, AST)
    final formatted =
        DateFormat('yyyy-MM-dd hh:mm:ss a', 'ar').format(dateTime);
    return formatted;
  }

  @override
  void onInit() async {
    super.onInit();
    final date = HijriCalendar.now();
    focusedDay = DateTime(date.hYear, date.hMonth, date.hDay).obs;
    selectedDay = DateTime(date.hYear, date.hMonth, date.hDay).obs;
    var sp = await SharedPreferences.getInstance();
    isAdmin.value = sp.getString("role") == "1";

    getAttendanceForDay();
    getAttendanceForMonth();
  }
}

class MyAttendance {
  bool? isExcuse;
  bool? signature;
  DateTime? date;
  DateTime? createdAt;

  MyAttendance({
    required this.isExcuse,
    required this.signature,
    required this.date,
    required this.createdAt,
  });

  factory MyAttendance.fromJson(Map<String, dynamic> json) {
    return MyAttendance(
      isExcuse: json['isExcuse'],
      signature: json['signature'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'isExcuse': isExcuse,
      'signature': signature,
      'date': date?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
