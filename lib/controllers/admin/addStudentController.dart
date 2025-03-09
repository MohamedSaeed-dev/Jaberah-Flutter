import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';

class AddStudentController extends GetxController {
  final ApiClient apiClient = Get.find();
  var studentNameController = TextEditingController().obs;
  var phoneController = TextEditingController().obs;
  var schoolClassController =
      TextEditingController(text: 'المرحلة الابتدائية').obs;
  var levelController = TextEditingController().obs;
  var memoRateController = TextEditingController().obs;
  var notesController = TextEditingController(text: '').obs;

  var isLoading = false.obs;
  var groups = <GroupsForGeneralUse>[].obs;
  Rxn<int> selectedGroup = Rxn<int>();
  var selectedSchoolLevel = 'المرحلة الابتدائية'.obs;

  Future addStudent() async {
    try {
      isLoading.value = true;
      var response = await apiClient.dio.post("/$studentsURL", data: {
        "studentName": studentNameController.value.text,
        "phoneNumber": phoneController.value.text,
        "schoolLevel": levelController.value.text,
        "memoRate": memoRateController.value.text,
        "schoolClass": schoolClassController.value.text,
        "notes": notesController.value.text,
        "groupId": selectedGroup.value,
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201) {
        studentNameController.value.text = "";
        levelController.value.text = "";
        memoRateController.value.text = "";
        phoneController.value.text = "";
        schoolClassController.value.text = "";
        selectedGroup.value = null;
        successSnackBar("تم اضافة الطالب بنجاح");
      } else {
        messageSnackBar(response.data["message"]);
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } catch (e) {
      print(e);
      catchSnackBar();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getGroups();
  }

  Future getGroups() async {
    try {
      var response = await apiClient.dio
          .get("/$groupsURL")
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        List<dynamic> result = response.data;
        groups.value =
            result.map((item) => GroupsForGeneralUse.fromJson(item)).toList();
        groups.insert(0, GroupsForGeneralUse(id: null, groupName: 'بدون حلقة'));
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

class GroupsForGeneralUse {
  int? id;
  String groupName;

  GroupsForGeneralUse({required this.id, required this.groupName});

  factory GroupsForGeneralUse.fromJson(Map<String, dynamic> json) {
    return GroupsForGeneralUse(
        id: json["id"] as int, groupName: json["groupName"] as String);
  }
}
