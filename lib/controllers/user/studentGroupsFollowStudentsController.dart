import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class StudentGroupsFollowStudentsController extends GetxController {
  final ApiClient _apiClient = Get.find();
  final id = Get.arguments['id'];
  var name = '';

  var selectedDate = JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;

  var isLoading = false.obs;
  var students = <FollowStudent>[].obs;
  var filteredStudents = [].obs;
  var searchText = TextEditingController().obs;

  var totalCount = 0.obs;
  var totalPages = 0.obs;
  var hasNext = false.obs;
  var hasPrevious = false.obs;
  var pageNumber = 1.obs;
  var pageSize = 10.obs;
  var fetchedCount = 0.obs;

  Future<void> getStudents() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$followStudentsForGroup/$id/for-day?date=${selectedDate.value.dateTime!.year}-${selectedDate.value.dateTime!.month}-${selectedDate.value.dateTime!.day}&searchText=${searchText.value.text}")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;

        students.value =
            result.map((item) => FollowStudent.fromJson(item)).toList();
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

  @override
  void onInit() {
    super.onInit();
    name = Get.arguments['Name'];
    getStudents();
  }
}

class FollowStudent {
  int studentId;
  String studentName;

  String surahFromTeacher;
  int verseFromTeacher;
  String surahToTeacher;
  int verseToTeacher;
  String rateTeacher;
  double pagesTeacher;

  String surahFromFriend;
  int verseFromFriend;
  String surahToFriend;
  int verseToFriend;
  String rateFriend;
  double pagesFriend;

  double attendance;
  double behavior;

  String notes;

  FollowStudent({
    required this.studentId,
    required this.studentName,
    required this.surahFromTeacher,
    required this.verseFromTeacher,
    required this.surahToTeacher,
    required this.verseToTeacher,
    required this.rateTeacher,
    required this.pagesTeacher,
    required this.surahFromFriend,
    required this.verseFromFriend,
    required this.surahToFriend,
    required this.verseToFriend,
    required this.rateFriend,
    required this.pagesFriend,
    required this.attendance,
    required this.behavior,
    required this.notes,
  });

  factory FollowStudent.fromJson(Map<String, dynamic> json) {
    return FollowStudent(
      studentId: json["studentId"] as int,
      studentName: json["studentName"] ?? "",
      surahFromTeacher: json["surahFromTeacher"] ?? "",
      surahToTeacher: json["surahToTeacher"] ?? "",
      verseFromTeacher: json["verseFromTeacher"] as int,
      verseToTeacher: json["verseToTeacher"] as int,
      pagesTeacher: (json["pagesTeacher"] as num).toDouble(),
      rateTeacher: json["rateTeacher"] ?? "",
      surahFromFriend: json["surahFromFriend"] ?? "",
      surahToFriend: json["surahToFriend"] ?? "",
      verseFromFriend: json["verseFromFriend"] as int,
      verseToFriend: json["verseToFriend"] as int,
      pagesFriend: (json["pagesFriend"] as num).toDouble(),
      rateFriend: json["rateFriend"] ?? "",
      attendance: (json["attendance"] as num).toDouble(),
      behavior: (json["behavior"] as num).toDouble(),
      notes: json["notes"] ?? "",
    );
  }
}
