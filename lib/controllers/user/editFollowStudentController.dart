import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/controllers/user/studentGroupsFollowStudentsController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class EditFollowStudentController extends GetxController {
  final ApiClient _apiClient = Get.find();
  List<DropdownMenuItem<String>> quranSurahsDropdown = [
    DropdownMenuItem(value: "", child: Text("---")),
    DropdownMenuItem(value: "الفاتحة", child: Text("الفاتحة")),
    DropdownMenuItem(value: "البقرة", child: Text("البقرة")),
    DropdownMenuItem(value: "ال عمران", child: Text("ال عمران")),
    DropdownMenuItem(value: "النساء", child: Text("النساء")),
    DropdownMenuItem(value: "المائدة", child: Text("المائدة")),
    DropdownMenuItem(value: "الأنعام", child: Text("الأنعام")),
    DropdownMenuItem(value: "الأعراف", child: Text("الأعراف")),
    DropdownMenuItem(value: "الأنفال", child: Text("الأنفال")),
    DropdownMenuItem(value: "التوبة", child: Text("التوبة")),
    DropdownMenuItem(value: "يونس", child: Text("يونس")),
    DropdownMenuItem(value: "هود", child: Text("هود")),
    DropdownMenuItem(value: "يوسف", child: Text("يوسف")),
    DropdownMenuItem(value: "الرعد", child: Text("الرعد")),
    DropdownMenuItem(value: "إبراهيم", child: Text("إبراهيم")),
    DropdownMenuItem(value: "الحجر", child: Text("الحجر")),
    DropdownMenuItem(value: "النحل", child: Text("النحل")),
    DropdownMenuItem(value: "الإسراء", child: Text("الإسراء")),
    DropdownMenuItem(value: "الكهف", child: Text("الكهف")),
    DropdownMenuItem(value: "مريم", child: Text("مريم")),
    DropdownMenuItem(value: "طه", child: Text("طه")),
    DropdownMenuItem(value: "الأنبياء", child: Text("الأنبياء")),
    DropdownMenuItem(value: "الحج", child: Text("الحج")),
    DropdownMenuItem(value: "المؤمنون", child: Text("المؤمنون")),
    DropdownMenuItem(value: "النور", child: Text("النور")),
    DropdownMenuItem(value: "الفرقان", child: Text("الفرقان")),
    DropdownMenuItem(value: "الشعراء", child: Text("الشعراء")),
    DropdownMenuItem(value: "النمل", child: Text("النمل")),
    DropdownMenuItem(value: "القصص", child: Text("القصص")),
    DropdownMenuItem(value: "العنكبوت", child: Text("العنكبوت")),
    DropdownMenuItem(value: "الروم", child: Text("الروم")),
    DropdownMenuItem(value: "لقمان", child: Text("لقمان")),
    DropdownMenuItem(value: "السجدة", child: Text("السجدة")),
    DropdownMenuItem(value: "الأحزاب", child: Text("الأحزاب")),
    DropdownMenuItem(value: "سبأ", child: Text("سبأ")),
    DropdownMenuItem(value: "فاطر", child: Text("فاطر")),
    DropdownMenuItem(value: "يس", child: Text("يس")),
    DropdownMenuItem(value: "الصافات", child: Text("الصافات")),
    DropdownMenuItem(value: "ص", child: Text("ص")),
    DropdownMenuItem(value: "الزمر", child: Text("الزمر")),
    DropdownMenuItem(value: "غافر", child: Text("غافر")),
    DropdownMenuItem(value: "فصلت", child: Text("فصلت")),
    DropdownMenuItem(value: "الشورى", child: Text("الشورى")),
    DropdownMenuItem(value: "الزخرف", child: Text("الزخرف")),
    DropdownMenuItem(value: "الدخان", child: Text("الدخان")),
    DropdownMenuItem(value: "الجاثية", child: Text("الجاثية")),
    DropdownMenuItem(value: "الأحقاف", child: Text("الأحقاف")),
    DropdownMenuItem(value: "محمد", child: Text("محمد")),
    DropdownMenuItem(value: "الفتح", child: Text("الفتح")),
    DropdownMenuItem(value: "الحجرات", child: Text("الحجرات")),
    DropdownMenuItem(value: "ق", child: Text("ق")),
    DropdownMenuItem(value: "الذاريات", child: Text("الذاريات")),
    DropdownMenuItem(value: "الطور", child: Text("الطور")),
    DropdownMenuItem(value: "النجم", child: Text("النجم")),
    DropdownMenuItem(value: "القمر", child: Text("القمر")),
    DropdownMenuItem(value: "الرحمن", child: Text("الرحمن")),
    DropdownMenuItem(value: "الواقعة", child: Text("الواقعة")),
    DropdownMenuItem(value: "الحديد", child: Text("الحديد")),
    DropdownMenuItem(value: "المجادلة", child: Text("المجادلة")),
    DropdownMenuItem(value: "الحشر", child: Text("الحشر")),
    DropdownMenuItem(value: "الممتحنة", child: Text("الممتحنة")),
    DropdownMenuItem(value: "الصف", child: Text("الصف")),
    DropdownMenuItem(value: "الجمعة", child: Text("الجمعة")),
    DropdownMenuItem(value: "المنافقون", child: Text("المنافقون")),
    DropdownMenuItem(value: "التغابن", child: Text("التغابن")),
    DropdownMenuItem(value: "الطلاق", child: Text("الطلاق")),
    DropdownMenuItem(value: "التحريم", child: Text("التحريم")),
    DropdownMenuItem(value: "الملك", child: Text("الملك")),
    DropdownMenuItem(value: "القلم", child: Text("القلم")),
    DropdownMenuItem(value: "الحاقة", child: Text("الحاقة")),
    DropdownMenuItem(value: "المعارج", child: Text("المعارج")),
    DropdownMenuItem(value: "نوح", child: Text("نوح")),
    DropdownMenuItem(value: "الجن", child: Text("الجن")),
    DropdownMenuItem(value: "المزمل", child: Text("المزمل")),
    DropdownMenuItem(value: "المدثر", child: Text("المدثر")),
    DropdownMenuItem(value: "القيامة", child: Text("القيامة")),
    DropdownMenuItem(value: "الإنسان", child: Text("الإنسان")),
    DropdownMenuItem(value: "المرسلات", child: Text("المرسلات")),
    DropdownMenuItem(value: "النبأ", child: Text("النبأ")),
    DropdownMenuItem(value: "النازعات", child: Text("النازعات")),
    DropdownMenuItem(value: "عبس", child: Text("عبس")),
    DropdownMenuItem(value: "التكوير", child: Text("التكوير")),
    DropdownMenuItem(value: "الإنفطار", child: Text("الإنفطار")),
    DropdownMenuItem(value: "المطففين", child: Text("المطففين")),
    DropdownMenuItem(value: "الإنشقاق", child: Text("الإنشقاق")),
    DropdownMenuItem(value: "البروج", child: Text("البروج")),
    DropdownMenuItem(value: "الطارق", child: Text("الطارق")),
    DropdownMenuItem(value: "الأعلى", child: Text("الأعلى")),
    DropdownMenuItem(value: "الغاشية", child: Text("الغاشية")),
    DropdownMenuItem(value: "الفجر", child: Text("الفجر")),
    DropdownMenuItem(value: "البلد", child: Text("البلد")),
    DropdownMenuItem(value: "الشمس", child: Text("الشمس")),
    DropdownMenuItem(value: "الليل", child: Text("الليل")),
    DropdownMenuItem(value: "الضحى", child: Text("الضحى")),
    DropdownMenuItem(value: "الشرح", child: Text("الشرح")),
    DropdownMenuItem(value: "التين", child: Text("التين")),
    DropdownMenuItem(value: "العلق", child: Text("العلق")),
    DropdownMenuItem(value: "القدر", child: Text("القدر")),
    DropdownMenuItem(value: "البينة", child: Text("البينة")),
    DropdownMenuItem(value: "الزلزلة", child: Text("الزلزلة")),
    DropdownMenuItem(value: "العاديات", child: Text("العاديات")),
    DropdownMenuItem(value: "القارعة", child: Text("القارعة")),
    DropdownMenuItem(value: "التكاثر", child: Text("التكاثر")),
    DropdownMenuItem(value: "العصر", child: Text("العصر")),
    DropdownMenuItem(value: "الهمزة", child: Text("الهمزة")),
    DropdownMenuItem(value: "الفيل", child: Text("الفيل")),
    DropdownMenuItem(value: "قريش", child: Text("قريش")),
    DropdownMenuItem(value: "الماعون", child: Text("الماعون")),
    DropdownMenuItem(value: "الكوثر", child: Text("الكوثر")),
    DropdownMenuItem(value: "الكافرون", child: Text("الكافرون")),
    DropdownMenuItem(value: "النصر", child: Text("النصر")),
    DropdownMenuItem(value: "المسد", child: Text("المسد")),
    DropdownMenuItem(value: "الإخلاص", child: Text("الإخلاص")),
    DropdownMenuItem(value: "الفلق", child: Text("الفلق")),
    DropdownMenuItem(value: "الناس", child: Text("الناس")),
  ];
  JDateModel date = JDateModel();
  var studentName = "";

  var selectedSurahFromSave = "".obs;
  var selectedSurahToSave = "".obs;
  var selectedSurahFromReview = "".obs;
  var selectedSurahToReview = "".obs;

  var selectedRateSave = "".obs;
  var selectedRateReview = "".obs;

  var verseFromSurah = TextEditingController().obs;
  var verseToSurah = TextEditingController().obs;
  var verseFromReview = TextEditingController().obs;
  var verseToReview = TextEditingController().obs;
  var pagesSave = TextEditingController().obs;
  var pageReview = TextEditingController().obs;

  var attendance = TextEditingController().obs;
  var behavior = TextEditingController().obs;

  var notes = TextEditingController().obs;

  var isLoading = false.obs;
  var isEdited = false.obs;

  final FollowStudent student = Get.arguments["student"];
  final JDateModel dateArgument = Get.arguments["date"];

  Future upsertFollowStudent() async {
    try {
      isLoading.value = true;
      var response = await _apiClient.dio.post(
          "/$followStudentsURL?date=${date.jhijri!.year}-${date.jhijri!.month}-${date.jhijri!.day}",
          data: {
            "studentId": student.studentId,
            "surahFromTeacher": selectedSurahFromSave.value,
            "surahToTeacher": selectedSurahToSave.value,
            "verseFromTeacher": int.parse(verseFromSurah.value.text),
            "verseToTeacher": int.parse(verseToSurah.value.text),
            "rateTeacher": selectedRateSave.value,
            "pagesTeacher": double.parse(pagesSave.value.text),
            "surahFromFriend": selectedSurahFromReview.value,
            "surahToFriend": selectedSurahToReview.value,
            "verseFromFriend": int.parse(verseFromReview.value.text),
            "verseToFriend": int.parse(verseToReview.value.text),
            "rateFriend": selectedRateReview.value,
            "pagesFriend": double.parse(pageReview.value.text),
            "attendance": double.parse(attendance.value.text),
            "behavior": double.parse(behavior.value.text),
            "notes": notes.value.text
          }).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        isEdited.value = true;
        successSnackBar("تم التعديل بنجاح");
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
  void onClose() {
    super.onClose();
    if (isEdited.value) {
      Get.find<StudentGroupsFollowStudentsController>().getStudents();
      isEdited.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    date = dateArgument;
    studentName = student.studentName;
    selectedSurahFromSave.value = student.surahFromTeacher;
    selectedSurahToSave.value = student.surahToTeacher;
    selectedSurahFromReview.value = student.surahFromFriend;
    selectedSurahToReview.value = student.surahToFriend;
    verseFromSurah.value.text = student.verseFromTeacher.toString();
    verseToSurah.value.text = student.verseToTeacher.toString();
    verseFromReview.value.text = student.verseFromFriend.toString();
    verseToReview.value.text = student.verseToFriend.toString();
    pagesSave.value.text = student.pagesTeacher.toString();
    pageReview.value.text = student.pagesFriend.toString();
    selectedRateSave.value = student.rateTeacher;
    selectedRateReview.value = student.rateFriend;

    attendance.value.text = student.attendance.toString();
    behavior.value.text = student.behavior.toString();
    notes.value.text = student.notes;
  }
}
