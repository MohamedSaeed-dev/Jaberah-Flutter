import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/jHijri.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// عنصر استجابة for-day: حضور المعلم للحلقة في يوم معين.
class AttendanceForDayItem {
  final int groupId;
  final String groupName;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;

  AttendanceForDayItem({
    required this.groupId,
    required this.groupName,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
  });

  factory AttendanceForDayItem.fromJson(Map<String, dynamic> json) {
    return AttendanceForDayItem(
      groupId: json['groupId'] is int ? json['groupId'] : int.tryParse(json['groupId'].toString()) ?? 0,
      groupName: json['groupName']?.toString() ?? '',
      checkInTime: json['checkInTime']?.toString(),
      checkOutTime: json['checkOutTime']?.toString(),
      status: json['status']?.toString() ?? 'Absent',
    );
  }
}

/// حلقة المعلم من استجابة for-month (groupsOfTeacher).
class TeacherGroup {
  final int id;
  final String name;
  TeacherGroup({required this.id, required this.name});
  factory TeacherGroup.fromJson(Map<String, dynamic> json) {
    return TeacherGroup(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

/// عنصر استجابة for-month: سجل حضور للحلقة في تاريخ معين.
class AttendanceForMonthItem {
  final int? groupId;
  final String groupName;
  final String status;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;

  AttendanceForMonthItem({
    this.groupId,
    required this.groupName,
    required this.status,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
  });

  factory AttendanceForMonthItem.fromJson(Map<String, dynamic> json) {
    return AttendanceForMonthItem(
      groupId: json['groupId'] is int ? json['groupId'] as int : int.tryParse(json['groupId']?.toString() ?? ''),
      groupName: json['groupName']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Absent',
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now(),
      checkInTime: json['checkInTime']?.toString(),
      checkOutTime: json['checkOutTime']?.toString(),
    );
  }
}

class MyAttendancesController extends GetxController {
  Rx<DateTime> focusedDay = DateTime.now().obs;
  Rx<DateTime> selectedDay = DateTime.now().obs;

  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  var isCheckInOutLoading = false.obs;

  var groupsOfTeacher = <TeacherGroup>[].obs;
  var dataForDay = <AttendanceForDayItem>[].obs;
  var dataForMonth = <AttendanceForMonthItem>[].obs;

  var isAdmin = false.obs;

  /// اسم الشهر الهجري للتاريخ المعطى (لعنوان التقويم).
  String getHijriMonthName(DateTime date) {
    final h = JHijri(fDate: date);
    return '${h.monthName} ${h.year} هـ';
  }

  /// عرض التاريخ بالميلادي كتاريخ هجري: يوم اسم_الشهر سنة هـ.
  String formatDateHijri(DateTime date) {
    final h = JHijri(fDate: date);
    return '${h.day} ${h.monthName} ${h.year} هـ';
  }

  /// يوم التاريخ المعطى بالتقويم الهجري (لعرض الرقم في خلية التقويم).
  int getHijriDay(DateTime date) {
    return JHijri(fDate: date).day;
  }

  /// أول يوم من الشهر الهجري المعروض (بالميلادي).
  DateTime getFirstDayOfFocusedHijriMonth() {
    final h = JHijri(fDate: focusedDay.value);
    return JHijri(fYear: h.year, fMonth: h.month, fDay: 1).dateTime;
  }

  /// آخر يوم من الشهر الهجري المعروض (بالميلادي).
  DateTime getLastDayOfFocusedHijriMonth() {
    final h = JHijri(fDate: focusedDay.value);
    final nextMonth = h.month == 12 ? 1 : h.month + 1;
    final nextYear = h.month == 12 ? h.year + 1 : h.year;
    final firstNext = JHijri(fYear: nextYear, fMonth: nextMonth, fDay: 1).dateTime;
    return firstNext.subtract(const Duration(days: 1));
  }

  /// الانتقال للشهر الهجري السابق وتحديث focusedDay إلى يوم 1 منه.
  void goToPrevHijriMonth() {
    final h = JHijri(fDate: focusedDay.value);
    int prevMonth = h.month - 1;
    int prevYear = h.year;
    if (prevMonth < 1) {
      prevMonth = 12;
      prevYear--;
    }
    final first = JHijri(fYear: prevYear, fMonth: prevMonth, fDay: 1).dateTime;
    focusedDay.value = first;
    selectedDay.value = first;
    getAttendanceForMonth();
  }

  /// الانتقال للشهر الهجري التالي وتحديث focusedDay إلى يوم 1 منه.
  void goToNextHijriMonth() {
    final h = JHijri(fDate: focusedDay.value);
    int nextMonth = h.month + 1;
    int nextYear = h.year;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }
    final first = JHijri(fYear: nextYear, fMonth: nextMonth, fDay: 1).dateTime;
    focusedDay.value = first;
    selectedDay.value = first;
    getAttendanceForMonth();
  }

  /// بيانات شبكة الشهر الهجري: ترتيب الأسبوع للأول (0=أحد)، وقائمة (يوم هجري، تاريخ ميلادي).
  ({int firstWeekday, List<({int day, DateTime date})> days}) getHijriMonthGrid() {
    final first = getFirstDayOfFocusedHijriMonth();
    final last = getLastDayOfFocusedHijriMonth();
    final h = JHijri(fDate: first);
    final year = h.year;
    final month = h.month;
    int nDays = last.difference(first).inDays + 1;
    final days = List<({int day, DateTime date})>.generate(
      nDays,
      (i) => (day: i + 1, date: JHijri(fYear: year, fMonth: month, fDay: i + 1).dateTime),
    );
    // 0 = Sunday (أحد) في TableCalendar
    final firstWeekday = first.weekday == 7 ? 0 : first.weekday;
    return (firstWeekday: firstWeekday, days: days);
  }

  /// الانتقال لليوم الحالي. لا يرسل طلباً إن كنا نعرض شهر اليوم الهجري.
  void goToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstOfTodayMonth = getFirstDayOfHijriMonthContaining(today);
    final firstOfFocused = getFirstDayOfFocusedHijriMonth();
    final alreadyShowingThisMonth = firstOfFocused.year == firstOfTodayMonth.year &&
        firstOfFocused.month == firstOfTodayMonth.month &&
        firstOfFocused.day == firstOfTodayMonth.day;
    selectedDay.value = today;
    focusedDay.value = firstOfTodayMonth;
    if (alreadyShowingThisMonth) {
      _updateDataForDayFromMonth();
    } else {
      getAttendanceForMonth();
    }
  }

  /// أول يوم من الشهر الهجري الذي يضم التاريخ المعطى (بالميلادي).
  DateTime getFirstDayOfHijriMonthContaining(DateTime date) {
    final h = JHijri(fDate: date);
    return JHijri(fYear: h.year, fMonth: h.month, fDay: 1).dateTime;
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    _updateDataForDayFromMonth();
  }

  /// يملأ dataForDay من dataForMonth + groupsOfTeacher: لكل حلقة يُعرض سجل ذلك اليوم أو سطر بدون حضور/انصراف.
  void _updateDataForDayFromMonth() {
    final d = selectedDay.value;
    final dayRecords = dataForMonth
        .where((att) =>
            att.date.year == d.year &&
            att.date.month == d.month &&
            att.date.day == d.day)
        .toList();
    if (groupsOfTeacher.isEmpty) {
      dataForDay.value = dayRecords
          .map((att) => AttendanceForDayItem(
                groupId: att.groupId ?? 0,
                groupName: att.groupName,
                checkInTime: att.checkInTime,
                checkOutTime: att.checkOutTime,
                status: att.status,
              ))
          .toList();
      return;
    }
    final list = <AttendanceForDayItem>[];
    for (final group in groupsOfTeacher) {
      final record = dayRecords.firstWhereOrNull(
        (att) => (att.groupId ?? 0) == group.id || att.groupName == group.name,
      );
      if (record != null) {
        list.add(AttendanceForDayItem(
          groupId: record.groupId ?? group.id,
          groupName: record.groupName,
          checkInTime: record.checkInTime,
          checkOutTime: record.checkOutTime,
          status: record.status,
        ));
      } else {
        list.add(AttendanceForDayItem(
          groupId: group.id,
          groupName: group.name,
          checkInTime: null,
          checkOutTime: null,
          status: 'Absent',
        ));
      }
    }
    dataForDay.value = list;
  }

  /// تاريخ ميلادي بصيغة yyyy-MM-dd للإرسال للباكند.
  String _gregorianDateString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future getAttendanceForMonth() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var teacherId = sp.getString("id");
      isLoading.value = true;
      final fromDt = getFirstDayOfFocusedHijriMonth();
      final toDt = getLastDayOfFocusedHijriMonth();
      final fromDate = _gregorianDateString(fromDt);
      final toDate = _gregorianDateString(toDt);
      final url =
          "/$teachersAttendancesURL/$teacherId/for-month?fromDate=$fromDate&toDate=$toDate";

      var response =
          await _apiClient.dio.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final raw = response.data;
        if (raw is Map<String, dynamic>) {
          final groupsRaw = raw['groupsOfTeacher'] is List ? raw['groupsOfTeacher'] as List : [];
          groupsOfTeacher.value = groupsRaw
              .map((e) => TeacherGroup.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
              .toList();
          final result = raw['result'] is List ? raw['result'] as List : [];
          dataForMonth.value = result
              .map((e) => AttendanceForMonthItem.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
              .toList();
        } else {
          groupsOfTeacher.clear();
          final result = raw is List ? raw : [];
          dataForMonth.value = result
              .map((e) => AttendanceForMonthItem.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        _updateDataForDayFromMonth();
      } else if (response.statusCode == 204) {
        groupsOfTeacher.clear();
        dataForMonth.clear();
        dataForDay.clear();
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

  /// قائمة سجلات الحضور للتاريخ المحدد (للتقويم).
  List<AttendanceForMonthItem> getAttendancesForDate(DateTime date) {
    return dataForMonth
        .where((att) =>
            att.date.year == date.year &&
            att.date.month == date.month &&
            att.date.day == date.day)
        .toList();
  }

  /// لون اليوم في التقويم حسب الحالة: Present -> أخضر، Excused -> برتقالي، Late -> كهرماني، Absent -> أحمر.
  String? getStatusForDate(DateTime date) {
    final list = getAttendancesForDate(date);
    if (list.isEmpty) return null;
    if (list.any((e) => e.status == 'Present')) return 'Present';
    if (list.any((e) => e.status == 'Excused')) return 'Excused';
    if (list.any((e) => e.status == 'Late')) return 'Late';
    return 'Absent';
  }

  /// تنسيق وقت من النص (مثل 07:04:00) للعرض بصيغة 12 ساعة.
  String formatTime(String? time) => formatTime12(time) ?? '—';

  Future<void> checkIn(int groupId) async {
    try {
      isCheckInOutLoading.value = true;
      await _apiClient.dio.post(
        "/$teachersAttendancesURL/check-in",
        data: {"groupId": groupId},
      ).timeout(const Duration(seconds: 15));
      successSnackBar("تم تسجيل الحضور");
      await getAttendanceForMonth();
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
      isCheckInOutLoading.value = false;
    }
  }

  Future<void> checkOut(int groupId) async {
    try {
      isCheckInOutLoading.value = true;
      await _apiClient.dio.post(
        "/$teachersAttendancesURL/check-out",
        data: {"groupId": groupId},
      ).timeout(const Duration(seconds: 15));
      successSnackBar("تم تسجيل الانصراف");
      await getAttendanceForMonth();
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
      isCheckInOutLoading.value = false;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    selectedDay = today.obs;
    focusedDay = getFirstDayOfHijriMonthContaining(today).obs;
    var sp = await SharedPreferences.getInstance();
    isAdmin.value = sp.getString("role") == "1";

    getAttendanceForMonth();
  }
}
