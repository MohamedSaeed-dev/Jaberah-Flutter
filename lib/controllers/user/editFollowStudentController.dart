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
    DropdownMenuItem(child: Text("---"), value: ""),
    DropdownMenuItem(child: Text("الفاتحة"), value: "الفاتحة"),
    DropdownMenuItem(child: Text("البقرة"), value: "البقرة"),
    DropdownMenuItem(child: Text("ال عمران"), value: "ال عمران"),
    DropdownMenuItem(child: Text("النساء"), value: "النساء"),
    DropdownMenuItem(child: Text("المائدة"), value: "المائدة"),
    DropdownMenuItem(child: Text("الأنعام"), value: "الأنعام"),
    DropdownMenuItem(child: Text("الأعراف"), value: "الأعراف"),
    DropdownMenuItem(child: Text("الأنفال"), value: "الأنفال"),
    DropdownMenuItem(child: Text("التوبة"), value: "التوبة"),
    DropdownMenuItem(child: Text("يونس"), value: "يونس"),
    DropdownMenuItem(child: Text("هود"), value: "هود"),
    DropdownMenuItem(child: Text("يوسف"), value: "يوسف"),
    DropdownMenuItem(child: Text("الرعد"), value: "الرعد"),
    DropdownMenuItem(child: Text("إبراهيم"), value: "إبراهيم"),
    DropdownMenuItem(child: Text("الحجر"), value: "الحجر"),
    DropdownMenuItem(child: Text("النحل"), value: "النحل"),
    DropdownMenuItem(child: Text("الإسراء"), value: "الإسراء"),
    DropdownMenuItem(child: Text("الكهف"), value: "الكهف"),
    DropdownMenuItem(child: Text("مريم"), value: "مريم"),
    DropdownMenuItem(child: Text("طه"), value: "طه"),
    DropdownMenuItem(child: Text("الأنبياء"), value: "الأنبياء"),
    DropdownMenuItem(child: Text("الحج"), value: "الحج"),
    DropdownMenuItem(child: Text("المؤمنون"), value: "المؤمنون"),
    DropdownMenuItem(child: Text("النور"), value: "النور"),
    DropdownMenuItem(child: Text("الفرقان"), value: "الفرقان"),
    DropdownMenuItem(child: Text("الشعراء"), value: "الشعراء"),
    DropdownMenuItem(child: Text("النمل"), value: "النمل"),
    DropdownMenuItem(child: Text("القصص"), value: "القصص"),
    DropdownMenuItem(child: Text("العنكبوت"), value: "العنكبوت"),
    DropdownMenuItem(child: Text("الروم"), value: "الروم"),
    DropdownMenuItem(child: Text("لقمان"), value: "لقمان"),
    DropdownMenuItem(child: Text("السجدة"), value: "السجدة"),
    DropdownMenuItem(child: Text("الأحزاب"), value: "الأحزاب"),
    DropdownMenuItem(child: Text("سبأ"), value: "سبأ"),
    DropdownMenuItem(child: Text("فاطر"), value: "فاطر"),
    DropdownMenuItem(child: Text("يس"), value: "يس"),
    DropdownMenuItem(child: Text("الصافات"), value: "الصافات"),
    DropdownMenuItem(child: Text("ص"), value: "ص"),
    DropdownMenuItem(child: Text("الزمر"), value: "الزمر"),
    DropdownMenuItem(child: Text("غافر"), value: "غافر"),
    DropdownMenuItem(child: Text("فصلت"), value: "فصلت"),
    DropdownMenuItem(child: Text("الشورى"), value: "الشورى"),
    DropdownMenuItem(child: Text("الزخرف"), value: "الزخرف"),
    DropdownMenuItem(child: Text("الدخان"), value: "الدخان"),
    DropdownMenuItem(child: Text("الجاثية"), value: "الجاثية"),
    DropdownMenuItem(child: Text("الأحقاف"), value: "الأحقاف"),
    DropdownMenuItem(child: Text("محمد"), value: "محمد"),
    DropdownMenuItem(child: Text("الفتح"), value: "الفتح"),
    DropdownMenuItem(child: Text("الحجرات"), value: "الحجرات"),
    DropdownMenuItem(child: Text("ق"), value: "ق"),
    DropdownMenuItem(child: Text("الذاريات"), value: "الذاريات"),
    DropdownMenuItem(child: Text("الطور"), value: "الطور"),
    DropdownMenuItem(child: Text("النجم"), value: "النجم"),
    DropdownMenuItem(child: Text("القمر"), value: "القمر"),
    DropdownMenuItem(child: Text("الرحمن"), value: "الرحمن"),
    DropdownMenuItem(child: Text("الواقعة"), value: "الواقعة"),
    DropdownMenuItem(child: Text("الحديد"), value: "الحديد"),
    DropdownMenuItem(child: Text("المجادلة"), value: "المجادلة"),
    DropdownMenuItem(child: Text("الحشر"), value: "الحشر"),
    DropdownMenuItem(child: Text("الممتحنة"), value: "الممتحنة"),
    DropdownMenuItem(child: Text("الصف"), value: "الصف"),
    DropdownMenuItem(child: Text("الجمعة"), value: "الجمعة"),
    DropdownMenuItem(child: Text("المنافقون"), value: "المنافقون"),
    DropdownMenuItem(child: Text("التغابن"), value: "التغابن"),
    DropdownMenuItem(child: Text("الطلاق"), value: "الطلاق"),
    DropdownMenuItem(child: Text("التحريم"), value: "التحريم"),
    DropdownMenuItem(child: Text("الملك"), value: "الملك"),
    DropdownMenuItem(child: Text("القلم"), value: "القلم"),
    DropdownMenuItem(child: Text("الحاقة"), value: "الحاقة"),
    DropdownMenuItem(child: Text("المعارج"), value: "المعارج"),
    DropdownMenuItem(child: Text("نوح"), value: "نوح"),
    DropdownMenuItem(child: Text("الجن"), value: "الجن"),
    DropdownMenuItem(child: Text("المزمل"), value: "المزمل"),
    DropdownMenuItem(child: Text("المدثر"), value: "المدثر"),
    DropdownMenuItem(child: Text("القيامة"), value: "القيامة"),
    DropdownMenuItem(child: Text("الإنسان"), value: "الإنسان"),
    DropdownMenuItem(child: Text("المرسلات"), value: "المرسلات"),
    DropdownMenuItem(child: Text("النبأ"), value: "النبأ"),
    DropdownMenuItem(child: Text("النازعات"), value: "النازعات"),
    DropdownMenuItem(child: Text("عبس"), value: "عبس"),
    DropdownMenuItem(child: Text("التكوير"), value: "التكوير"),
    DropdownMenuItem(child: Text("الإنفطار"), value: "الإنفطار"),
    DropdownMenuItem(child: Text("المطففين"), value: "المطففين"),
    DropdownMenuItem(child: Text("الإنشقاق"), value: "الإنشقاق"),
    DropdownMenuItem(child: Text("البروج"), value: "البروج"),
    DropdownMenuItem(child: Text("الطارق"), value: "الطارق"),
    DropdownMenuItem(child: Text("الأعلى"), value: "الأعلى"),
    DropdownMenuItem(child: Text("الغاشية"), value: "الغاشية"),
    DropdownMenuItem(child: Text("الفجر"), value: "الفجر"),
    DropdownMenuItem(child: Text("البلد"), value: "البلد"),
    DropdownMenuItem(child: Text("الشمس"), value: "الشمس"),
    DropdownMenuItem(child: Text("الليل"), value: "الليل"),
    DropdownMenuItem(child: Text("الضحى"), value: "الضحى"),
    DropdownMenuItem(child: Text("الشرح"), value: "الشرح"),
    DropdownMenuItem(child: Text("التين"), value: "التين"),
    DropdownMenuItem(child: Text("العلق"), value: "العلق"),
    DropdownMenuItem(child: Text("القدر"), value: "القدر"),
    DropdownMenuItem(child: Text("البينة"), value: "البينة"),
    DropdownMenuItem(child: Text("الزلزلة"), value: "الزلزلة"),
    DropdownMenuItem(child: Text("العاديات"), value: "العاديات"),
    DropdownMenuItem(child: Text("القارعة"), value: "القارعة"),
    DropdownMenuItem(child: Text("التكاثر"), value: "التكاثر"),
    DropdownMenuItem(child: Text("العصر"), value: "العصر"),
    DropdownMenuItem(value: "الهمزة", child: Text("الهمزة")),
    DropdownMenuItem(child: Text("الفيل"), value: "الفيل"),
    DropdownMenuItem(child: Text("قريش"), value: "قريش"),
    DropdownMenuItem(child: Text("الماعون"), value: "الماعون"),
    DropdownMenuItem(child: Text("الكوثر"), value: "الكوثر"),
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
            "pagesTeacher": int.parse(pagesSave.value.text),
            "surahFromFriend": selectedSurahFromReview.value,
            "surahToFriend": selectedSurahToReview.value,
            "verseFromFriend": int.parse(verseFromReview.value.text),
            "verseToFriend": int.parse(verseToReview.value.text),
            "rateFriend": selectedRateReview.value,
            "pagesFriend": int.parse(pageReview.value.text),
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
