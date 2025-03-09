import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/admin/userNameController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherInfoController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var id = '';

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  var isLoading = false.obs;

  var username = TextEditingController().obs;
  var phone = TextEditingController().obs;
  var oldPassword = TextEditingController().obs;
  var newPassword = TextEditingController().obs;

  var isShowEye = false.obs;

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tName = prefs.getString("name");
    var tId = prefs.getString("id");
    var tPhone = prefs.getString("phone");
    id = tId ?? '';

    username.value.text = tName ?? '';
    phone.value.text = tPhone ?? '';
    oldPassword.value.text = '';
    newPassword.value.text = '';
  }

  Future updateTeacherInfo() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio.put("/$teachersURL/$id", data: {
        "teacherName": username.value.text,
        "phoneNumber": phone.value.text,
        "newPassword": newPassword.value.text,
        "oldPassword": oldPassword.value.text
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Get.find<UserNameController>().saveValue(username.value.text);
        await prefs.setString("id", id);
        await prefs.setString("phone", phone.value.text);
        successSnackBar("تم تحديث بياناتك بنجاح");
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
}
