import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';

class AddTeacherController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var teacherNameController = TextEditingController().obs;
  var phoneController = TextEditingController().obs;
  var isLoading = false.obs;
  var groups = [].obs;
  var selectedGroups = [].obs;

  Future addTeacher() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio.post("/$teachersURL", data: {
        "teacherName": teacherNameController.value.text,
        "phoneNumber": phoneController.value.text,
        "groupsId": selectedGroups,
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201) {
        teacherNameController.value.text = "";
        phoneController.value.text = "";
        selectedGroups.value = [];
        successSnackBar("تم اضافة المعلم بنجاح");
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
    getGroups();
    selectedGroups.value = [];
  }

  Future getGroups() async {
    try {
      var response = await _apiClient.dio
          .get("/$groupsWithNoTeachers")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        groups.value = response.data;
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
}
