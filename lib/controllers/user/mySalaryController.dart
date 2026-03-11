import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/jHijri.dart';

class MySalaryController extends GetxController {
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

  var selectedYear = JHijri.now().year.obs;
  var yearName = '${JHijri.now().year} هـ'.obs;

  var salariesForYear = <MySalaryItem>[].obs;
  var isLoading = false.obs;
  var markingReceivedId = ''.obs; // "year-month-groupId" for loading state

  /// تجميع الرواتب حسب الشهر للعرض
  List<Map<String, dynamic>> get salariesByMonth {
    final map = <String, List<MySalaryItem>>{};
    for (final s in salariesForYear) {
      final key = '${s.year}-${s.month}';
      map.putIfAbsent(key, () => []).add(s);
    }
    final months = map.keys.toList()..sort((a, b) => a.compareTo(b));
    return months.map((k) => {'key': k, 'items': map[k]!}).toList();
  }

  Future<void> getSalariesForYear() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio
          .get("/$teachersSalariesURL/my-salaries?year=$selectedYear")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final list = response.data is List ? response.data as List : [];
        salariesForYear.value = list
            .map((e) => MySalaryItem.fromJson(e is Map<String, dynamic>
                ? e
                : Map<String, dynamic>.from(e as Map)))
            .toList();
      } else if (response.statusCode == 204) {
        salariesForYear.clear();
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

  Future<void> markAsPaid(int id) async {
    try {
      markingReceivedId.value = id.toString();
      final response = await _apiClient.dio
          .patch("/$teachersSalariesURL/my-salaries/$id/mark-as-paid").timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        successSnackBar("تم تسجيل دفع الراتب");
        await getSalariesForYear();
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
      markingReceivedId.value = '';
    }
  }

  void setYear(int year) {
    selectedYear.value = year;
    yearName.value = '$year هـ';
    getSalariesForYear();
  }

  String monthNameByValue(int value) {
    final m = hijriMonths.firstWhereOrNull((e) => e['value'] == value);
    return m?['month'] ?? '$value';
  }

  @override
  void onInit() {
    super.onInit();
    getSalariesForYear();
  }
}

class MySalaryItem {
  int id;
  int year;
  int month;
  int groupId;
  String groupName;
  double? salary;
  bool isPaid;
  DateTime? paidAt;

  MySalaryItem({
    required this.id,
    required this.year,
    required this.month,
    required this.groupId,
    required this.groupName,
    required this.salary,
    required this.isPaid,
    required this.paidAt,
  });

  factory MySalaryItem.fromJson(Map<String, dynamic> json) {
    return MySalaryItem(
      id: json["id"] as int,
      year: json["year"] as int? ?? 0,
      month: json["month"] as int? ?? 0,
      groupId: json["groupId"] as int,
      groupName: json["groupName"] as String? ?? '',
      salary: (json["salary"] is int)
          ? (json["salary"] as int).toDouble()
          : json["salary"] != null
              ? double.tryParse(json["salary"].toString())
              : null,
      isPaid: json["isPaid"] as bool? ?? false,
      paidAt: json["paidAt"] != null
          ? DateTime.tryParse(json["paidAt"].toString())
          : null,
    );
  }
}
