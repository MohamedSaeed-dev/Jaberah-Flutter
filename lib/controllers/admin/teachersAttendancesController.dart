import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/reportTeachersAttendancesController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/jhijri_picker.dart';

class TeacherAttendancesController extends GetxController {
  final ApiClient _apiClient = Get.find();
  // A list to store attendance entries
  var entries = <EntryAttendance>[].obs;

  // Update or add an entry in the list
  void updateEntry(int teacherId, {bool? signature, bool? isExcuse}) {
    // Find existing entry
    var entry = entries.firstWhereOrNull((e) => e.teacherId == teacherId);

    if (entry != null) {
      // Update existing entry
      entry.signature = isExcuse == null ? signature : null;
      entry.isExcuse = signature == null ? isExcuse : null;
    } else {
      // Add new entry if it doesn't exist
      entries.add(EntryAttendance(
        teacherId: teacherId,
        signature: signature,
        isExcuse: isExcuse,
      ));
    }
    // Ensure reactive updates
    entries.refresh();
  }

  var teachersAttendances = [];

  var filteredTeachersAttendances = <TeacherAttendanceForDayReport>[].obs;

  var isLoading = false.obs;

  var pageNumber = 1.obs;
  var pageSize = 5.obs;

  var selectedDate = JDateModel(jhijri: JHijri.now()).obs;

  Future getTeachersAttendances() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$teachersAttendancesForReportByDayURL?date=${selectedDate.value.jhijri!.year}-${selectedDate.value.jhijri!.month}-${selectedDate.value.jhijri!.day}")
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<dynamic> result = response.data;
        filteredTeachersAttendances.value = result
            .map((item) => TeacherAttendanceForDayReport.fromJson(item))
            .toList();
      } else {
        messageSnackBar(response.data['message']);
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

  Future updateTeachersAttendances() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .post(
              "/$teachersAttendancesURL?date=${selectedDate.value.jhijri!.year}-${selectedDate.value.jhijri!.month}-${selectedDate.value.jhijri!.day}",
              data: entries.map((e) => e.toJson()).toList())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        entries.clear();
        successSnackBar(
            "تم تحديث حضور المعلمين ليوم ${selectedDate.value.jhijri!.day} في شهر ${selectedDate.value.jhijri!.monthName}");
        await getTeachersAttendances();
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getTeachersAttendances();
  }
}

class EntryAttendance {
  int teacherId;
  bool? signature;
  bool? isExcuse;

  EntryAttendance({required this.teacherId, this.signature, this.isExcuse});

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'signature': signature,
      'isExcuse': isExcuse
    };
  }
}
