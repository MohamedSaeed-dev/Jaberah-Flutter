import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/addTeacherController.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddTeacher extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final AddTeacherController addTeacherController =
      Get.put(AddTeacherController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.delete<AddTeacherController>();
              Get.back();
            },
            icon: Icon(Icons.arrow_back)),
        title: const Text(
          'إضافة معلم جديد',
          style: TextStyle(
            fontFamily: 'GE_SS_Two',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal:  8.0),
                    child: TextFormField(
                      controller:
                          addTeacherController.teacherNameController.value,
                      decoration: const InputDecoration(labelText: 'اسم المعلم', border: OutlineInputBorder()),
                      validator: (value) {
                        final arabicRegex =
                            RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                        if (value!.isEmpty)
                          return 'يرجى إدخال اسم المعلم';
                        else if (!arabicRegex.hasMatch(value))
                          return 'اسم المعلم يجب ان يكون عربياً';
                        else if (value.length < 7 || value.length > 20)
                          return 'اسم المعلم يجب ان يكون بين 7 و 20 حرفاً';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: addTeacherController.phoneController.value,
                      decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        RegExp regExp = RegExp(r'^7[0-9]{8}$');
                        if (value!.isEmpty) {
                          return 'يرجى إدخال رقم الجوال';
                        } else if (!regExp.hasMatch(value)) {
                          return 'يرجى إدخال رقم هاتف صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Obx(() => Padding(
                  padding: const EdgeInsets.symmetric( horizontal: 8.0),
                  child: MultiSelectDialogField(
                        cancelText: Text("الغاء"),
                        confirmText: Text("تأكيد"),
                        title: Text(" الحلقات المتاحة"),
                        items: addTeacherController.groups
                            .map((group) =>
                                MultiSelectItem(group['id'], group['groupName']))
                            .toList(),
                        initialValue: addTeacherController.selectedGroups,
                        listType: MultiSelectListType.CHIP,
                        onConfirm: (values) {
                          addTeacherController.selectedGroups.value = values;
                        },
                        buttonText: const Text("اختر الحلقات"),
                        chipDisplay: MultiSelectChipDisplay(
                          items:
                              addTeacherController.selectedGroups.map((groupId) {
                            final group = addTeacherController.groups
                                .firstWhere((group) => group['id'] == groupId);
                            return MultiSelectItem(
                                group['id'], group['groupName']);
                          }).toList(),
                        ),
                      ),
                )),
                const SizedBox(height: 20),
                MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await addTeacherController.addTeacher();
                      }
                    },
                    minWidth: double.infinity,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 60,
                    color: const Color.fromARGB(255, 63, 181, 108),
                    child: Obx(
                      () => Text(addTeacherController.isLoading.value
                          ? 'جاري الإضافة...'
                          : 'إضافة المعلم'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
