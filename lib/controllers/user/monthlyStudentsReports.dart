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

  var monthlyReport = <MonthlyReportModel>[];

  Future getMonthlyReport() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$monthlyReportURL?groupId=$selectedGroupId&year=${selectedDate.value.jhijri!.year}&month=${selectedDate.value.jhijri!.month}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        monthlyReport =
            result.map((item) => MonthlyReportModel.fromJson(item)).toList();
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
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } on DioException catch (e) {
      messageSnackBar(e.response!.data["message"]);
    } catch (e) {
      catchSnackBar();
    } finally {
      isLoadingUpdate.value = false;
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
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } on DioException catch (e) {
      messageSnackBar(e.response!.data["message"]);
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

  MonthlyReportModel(
      {required this.followStudentId,
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
      required this.oralGrade,
      required this.paperGrade,
      required this.total});

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportModel(
      followStudentId: json["followStudentId"] as int,
      studentName: json["studentName"] as String,
      saveFromSurah: json["saveData"]["from"]["surahName"] as String,
      saveToSurah: json["saveData"]["to"]["surahName"] as String,
      saveFromVerse: json["saveData"]["from"]["verse"] as int,
      saveToVerse: json["saveData"]["to"]["verse"] as int,
      savePages: (json["saveData"]["pages"] is int)
          ? (json["saveData"]["pages"] as int).toDouble()
          : double.parse(json["saveData"]["pages"].toString()),
      saveRate: json["saveData"]["rate"]?.toString() ?? "",
      reviewFromSurah: json["reviewData"]["from"]["surahName"] as String,
      reviewToSurah: json["reviewData"]["to"]["surahName"] as String,
      reviewFromVerse: json["reviewData"]["from"]["verse"] as int,
      reviewToVerse: json["reviewData"]["to"]["verse"] as int,
      reviewPages: (json["reviewData"]["pages"] is int)
          ? (json["reviewData"]["pages"] as int).toDouble()
          : double.parse(json["reviewData"]["pages"].toString()),
      reviewRate: json["reviewData"]["rate"]?.toString() ?? "",
      saveGrade: (json["saveGrade"] is int)
          ? (json["saveGrade"] as int).toDouble()
          : double.parse(json["saveGrade"].toString()),
      reviewGrade: json["reviewGrade"] is int
          ? (json["reviewGrade"] as int).toDouble()
          : double.parse(json["reviewGrade"].toString()),
      attendanceGrade: json["attendanceGrade"] as int,
      behaviorGrade: json["behaviorGrade"] as int,
      oralGrade: (json["oralGrade"] is int)
          ? (json["oralGrade"] as int).toDouble()
          : double.parse(json["oralGrade"].toString()),
      paperGrade: (json["paperGrade"] is int)
          ? (json["paperGrade"] as int).toDouble()
          : double.parse(json["paperGrade"].toString()),
      total: (json["total"] is int)
          ? (json["total"] as int).toDouble()
          : double.parse(json["total"].toString()),
    );
  }
}
