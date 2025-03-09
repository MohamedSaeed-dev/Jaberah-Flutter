import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/teacherInfoController.dart';
import 'package:jaberah/controllers/admin/userNameController.dart';

class TeacherInfo extends StatelessWidget {
  final TeacherInfoController teacherInfocontroller =
      Get.put(TeacherInfoController());
  final UserNameController userNameController = Get.put(UserNameController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Initialize controllers with the current values from the controller

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تغيير معلومات المعلم',
          style: TextStyle(
            fontFamily: 'GE_SS_Two',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(
                  () => TextFormField(
                    controller: teacherInfocontroller.username.value,
                    decoration: _inputDecoration('الاسم'),
                    validator: (value) {
                      final arabicRegex =
                          RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                      if (value!.length < 5 || value.length > 20) {
                        return 'يجب أن يكون اسم المستخدم بين 5 أحرف الى 20 حرفاً';
                      }
                      if (!arabicRegex.hasMatch(value)) {
                        return 'اسم المستخدم يجب ان يكون باللغة العربية فقط';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                      controller: teacherInfocontroller.phone.value,
                      decoration: _inputDecoration('رقم الهاتف'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        RegExp regExp = RegExp(r'^7[0-9]{8}$');
                        if (!regExp.hasMatch(value!)) {
                          return 'يرجى إدخال رقم هاتف صحيح';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                      controller: teacherInfocontroller.oldPassword.value,
                      decoration:
                          _inputDecorationwithEye('كلمة المرور القديمة'),
                      obscureText: teacherInfocontroller.isShowEye.value,
                      validator: (value) {
                        if (value!.isNotEmpty && value.length < 8) {
                          return 'يجب أن تكون كلمة المرور 8 أحرف أو أكثر';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                      controller: teacherInfocontroller.newPassword.value,
                      decoration:
                          _inputDecorationwithEye('كلمة المرور الجديدة'),
                      obscureText: teacherInfocontroller.isShowEye.value,
                      validator: (value) {
                        if (value!.isNotEmpty && value.length < 8) {
                          return 'يجب أن تكون كلمة المرور 8 أحرف أو أكثر';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 20),
                MaterialButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await teacherInfocontroller.updateTeacherInfo();
                    }
                  },
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20), // Adjust radius as needed
                  ),
                  height: 60,
                  color: const Color.fromARGB(255, 63, 181, 108),
                  child: Obx(() => Text(
                        teacherInfocontroller.isLoading.value
                            ? 'جاري التحديث...'
                            : 'تحديث المعلومات',
                        style: const TextStyle(color: Colors.black),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
    );
  }

  InputDecoration _inputDecorationwithEye(String label) {
    return InputDecoration(
      labelText: label,
      suffix: Obx(() => IconButton(
          onPressed: () {
            teacherInfocontroller.isShowEye.value =
                !teacherInfocontroller.isShowEye.value;
          },
          icon: teacherInfocontroller.isShowEye.value
              ? Icon(Icons.visibility)
              : Icon(Icons.visibility_off))),
      border: OutlineInputBorder(),
    );
  }
}
