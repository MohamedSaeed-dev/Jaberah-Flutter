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

class DataFollowStudentController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var selectedDate = JDateModel(jhijri: JHijri.now(), dateTime: DateTime.now()).obs;
  var searchText = TextEditingController(text: "").obs;

  var dataFollowStudent = [].obs;
  var isLoading = false.obs;
  var totalCount = 0.obs;
  var totalPages = 0.obs;
  var hasNext = false.obs;
  var hasPrevious = false.obs;
  var pageNumber = 1.obs;
  var fetchedCount = 0.obs;

  Future<void> getStudents() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio
          .get(
              "/$studentsURL?searchText=${searchText.value.text}&pageNumber=${pageNumber.value}&pageSize=2")
          .timeout(const Duration(seconds: 20));
      var result = response.data;
      if (response.statusCode == 200) {
        totalCount.value = result["TotalCount"];
        totalPages.value = result["TotalPages"];
        hasNext.value = result["HasNext"];
        hasPrevious.value = result["HasPrevious"];
        fetchedCount.value =
            ((pageNumber.value - 1) * 2) + dataFollowStudent.length;
        dataFollowStudent.value = result["Data"];
      } else {
        messageSnackBar(result["message"]);
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
}
