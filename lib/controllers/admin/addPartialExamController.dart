import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class AddPartialExamController extends GetxController {
  final ApiClient _apiClient = Get.find();
  var isLoading = false.obs;
  late Rx<JDateModel> selectedDate;

  // Controllers for questions (10 questions, 1.5 each)
  var question1Controller = TextEditingController(text: '0').obs;
  var question2Controller = TextEditingController(text: '0').obs;
  var question3Controller = TextEditingController(text: '0').obs;
  var question4Controller = TextEditingController(text: '0').obs;
  var question5Controller = TextEditingController(text: '0').obs;
  var question6Controller = TextEditingController(text: '0').obs;
  var question7Controller = TextEditingController(text: '0').obs;
  var question8Controller = TextEditingController(text: '0').obs;
  var question9Controller = TextEditingController(text: '0').obs;
  var question10Controller = TextEditingController(text: '0').obs;

  // Additional fields
  var performanceController =
      TextEditingController(text: '0').obs; // الأداء من 5
  var testerController = TextEditingController().obs; // المحتبر
  var partController = TextEditingController().obs; // الجزء
  var notesController = TextEditingController().obs; // الملاحظات

  // التقدير
  var rateController = 'ممتاز'.obs;
  final List<String> rateOptions = [
    'ممتاز',
    'جيد جداً',
    'جيد',
    'مقبول',
    'ضعيف'
  ];

  var totalScore = 0.0.obs;

  late int studentId;
  late String studentName;
  late String groupName;

  // للتعديل
  int? examId;
  bool isEditMode = false;

  @override
  void onInit() {
    super.onInit();
    studentId = Get.arguments["studentId"];
    studentName = Get.arguments["studentName"];
    groupName = Get.arguments["groupName"];
    selectedDate = (Get.arguments["selectedDate"] as JDateModel).obs;

    // التحقق من وجود بيانات للتعديل
    if (Get.arguments["examData"] != null) {
      isEditMode = true;
      _loadExamData(Get.arguments["examData"]);
    }

    // Add listeners to calculate total
    question1Controller.value.addListener(calculateTotal);
    question2Controller.value.addListener(calculateTotal);
    question3Controller.value.addListener(calculateTotal);
    question4Controller.value.addListener(calculateTotal);
    question5Controller.value.addListener(calculateTotal);
    question6Controller.value.addListener(calculateTotal);
    question7Controller.value.addListener(calculateTotal);
    question8Controller.value.addListener(calculateTotal);
    question9Controller.value.addListener(calculateTotal);
    question10Controller.value.addListener(calculateTotal);
    performanceController.value.addListener(calculateTotal);
  }

  void _loadExamData(Map<String, dynamic> examData) {
    examId = examData["examId"];
    question1Controller.value.text = examData["question1"]?.toString() ?? '0';
    question2Controller.value.text = examData["question2"]?.toString() ?? '0';
    question3Controller.value.text = examData["question3"]?.toString() ?? '0';
    question4Controller.value.text = examData["question4"]?.toString() ?? '0';
    question5Controller.value.text = examData["question5"]?.toString() ?? '0';
    question6Controller.value.text = examData["question6"]?.toString() ?? '0';
    question7Controller.value.text = examData["question7"]?.toString() ?? '0';
    question8Controller.value.text = examData["question8"]?.toString() ?? '0';
    question9Controller.value.text = examData["question9"]?.toString() ?? '0';
    question10Controller.value.text = examData["question10"]?.toString() ?? '0';
    performanceController.value.text =
        examData["performance"]?.toString() ?? '0';
    testerController.value.text = examData["tester"] ?? '';
    partController.value.text = examData["part"] ?? '';
    rateController.value = examData["rate"] ?? 'ممتاز';
    notesController.value.text = examData["notes"] ?? '';
    calculateTotal();
  }

  void calculateTotal() {
    double total = 0.0;
    total += double.tryParse(question1Controller.value.text) ?? 0.0;
    total += double.tryParse(question2Controller.value.text) ?? 0.0;
    total += double.tryParse(question3Controller.value.text) ?? 0.0;
    total += double.tryParse(question4Controller.value.text) ?? 0.0;
    total += double.tryParse(question5Controller.value.text) ?? 0.0;
    total += double.tryParse(question6Controller.value.text) ?? 0.0;
    total += double.tryParse(question7Controller.value.text) ?? 0.0;
    total += double.tryParse(question8Controller.value.text) ?? 0.0;
    total += double.tryParse(question9Controller.value.text) ?? 0.0;
    total += double.tryParse(question10Controller.value.text) ?? 0.0;
    total += double.tryParse(performanceController.value.text) ?? 0.0;

    totalScore.value = total;
  }

  // تحويل التاريخ الهجري إلى ميلادي
  DateTime convertHijriToGregorian() {
    var hijriDate = selectedDate.value.jhijri!;

    // استخدام مكتبة hijri للتحويل من هجري إلى ميلادي
    HijriCalendar hijri = HijriCalendar();
    hijri.hYear = hijriDate.year;
    hijri.hMonth = hijriDate.month;
    hijri.hDay = hijriDate.day;

    // hijriToGregorian يعطي DateTime الميلادي
    DateTime gregorianDate =
        hijri.hijriToGregorian(hijriDate.year, hijriDate.month, hijriDate.day);

    return gregorianDate;
  }

  // التحقق من صحة الدرجات
  bool validateScores() {
    // التحقق من درجات الأسئلة (0 - 1.5)
    List<double> questionScores = [
      double.tryParse(question1Controller.value.text) ?? 0.0,
      double.tryParse(question2Controller.value.text) ?? 0.0,
      double.tryParse(question3Controller.value.text) ?? 0.0,
      double.tryParse(question4Controller.value.text) ?? 0.0,
      double.tryParse(question5Controller.value.text) ?? 0.0,
      double.tryParse(question6Controller.value.text) ?? 0.0,
      double.tryParse(question7Controller.value.text) ?? 0.0,
      double.tryParse(question8Controller.value.text) ?? 0.0,
      double.tryParse(question9Controller.value.text) ?? 0.0,
      double.tryParse(question10Controller.value.text) ?? 0.0,
    ];

    for (int i = 0; i < questionScores.length; i++) {
      if (questionScores[i] < 0 || questionScores[i] > 1.5) {
        messageSnackBar("درجة السؤال ${i + 1} يجب أن تكون بين 0 و 1.5");
        return false;
      }
    }

    // التحقق من درجة الأداء (0 - 5)
    double performance =
        double.tryParse(performanceController.value.text) ?? 0.0;
    if (performance < 0 || performance > 5) {
      messageSnackBar("درجة الأداء يجب أن تكون بين 0 و 5");
      return false;
    }

    // التحقق من المجموع الكلي (0 - 20)
    if (totalScore.value < 0 || totalScore.value > 20) {
      messageSnackBar("المجموع الكلي يجب أن يكون بين 0 و 20");
      return false;
    }

    return true;
  }

  Future<void> submitPartialExam() async {
    // التحقق من صحة الدرجات
    if (!validateScores()) {
      return;
    }

    isLoading.value = true;

    if (isEditMode) {
      await _updatePartialExam();
    } else {
      await _createPartialExam();
    }
  }

  Future<void> _createPartialExam() async {
    try {
      // تحويل التاريخ الهجري إلى ميلادي
      DateTime gregorianDate = convertHijriToGregorian();
      var dateString =
          "${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}";

      var response = await _apiClient.dio.post("/$partialExamsURL", data: {
        "studentId": studentId,
        "examDate": dateString,
        "question1": double.tryParse(question1Controller.value.text) ?? 0.0,
        "question2": double.tryParse(question2Controller.value.text) ?? 0.0,
        "question3": double.tryParse(question3Controller.value.text) ?? 0.0,
        "question4": double.tryParse(question4Controller.value.text) ?? 0.0,
        "question5": double.tryParse(question5Controller.value.text) ?? 0.0,
        "question6": double.tryParse(question6Controller.value.text) ?? 0.0,
        "question7": double.tryParse(question7Controller.value.text) ?? 0.0,
        "question8": double.tryParse(question8Controller.value.text) ?? 0.0,
        "question9": double.tryParse(question9Controller.value.text) ?? 0.0,
        "question10": double.tryParse(question10Controller.value.text) ?? 0.0,
        "performance": double.tryParse(performanceController.value.text) ?? 0.0,
        "tester": testerController.value.text,
        "part": partController.value.text,
        "rate": rateController.value,
        "notes": notesController.value.text,
        "totalScore": totalScore.value,
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back(result: true);
        await Future.delayed(Duration(milliseconds: 300));
        successSnackBar("تم إضافة التسميع الجزئي بنجاح");
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

  Future<void> _updatePartialExam() async {
    try {
      var response = await _apiClient.dio.put("/$partialExamsURL", data: {
        "id": examId,
        "question1": double.tryParse(question1Controller.value.text) ?? 0.0,
        "question2": double.tryParse(question2Controller.value.text) ?? 0.0,
        "question3": double.tryParse(question3Controller.value.text) ?? 0.0,
        "question4": double.tryParse(question4Controller.value.text) ?? 0.0,
        "question5": double.tryParse(question5Controller.value.text) ?? 0.0,
        "question6": double.tryParse(question6Controller.value.text) ?? 0.0,
        "question7": double.tryParse(question7Controller.value.text) ?? 0.0,
        "question8": double.tryParse(question8Controller.value.text) ?? 0.0,
        "question9": double.tryParse(question9Controller.value.text) ?? 0.0,
        "question10": double.tryParse(question10Controller.value.text) ?? 0.0,
        "performance": double.tryParse(performanceController.value.text) ?? 0.0,
        "tester": testerController.value.text,
        "part": partController.value.text,
        "rate": rateController.value,
        "notes": notesController.value.text,
        "totalScore": totalScore.value,
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        Get.back(result: true);
        await Future.delayed(Duration(milliseconds: 300));
        successSnackBar("تم تعديل التسميع الجزئي بنجاح");
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
    question1Controller.value.dispose();
    question2Controller.value.dispose();
    question3Controller.value.dispose();
    question4Controller.value.dispose();
    question5Controller.value.dispose();
    question6Controller.value.dispose();
    question7Controller.value.dispose();
    question8Controller.value.dispose();
    question9Controller.value.dispose();
    question10Controller.value.dispose();
    performanceController.value.dispose();
    testerController.value.dispose();
    partController.value.dispose();
    notesController.value.dispose();
    super.onClose();
  }
}
