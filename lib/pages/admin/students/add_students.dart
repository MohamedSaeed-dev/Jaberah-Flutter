import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/addStudentController.dart';

class AddStudent extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final AddStudentController controller = Get.put(AddStudentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.delete<AddStudentController>();
              Get.back();
            },
            icon: Icon(Icons.arrow_back)),
        title: const Text(
          'إضافة طالب جديد',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller.studentNameController.value,
                    decoration: const InputDecoration(
                        labelText: 'اسم الطالب', border: OutlineInputBorder()),
                    validator: (value) {
                      final arabicRegex =
                          RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                      if (value!.isEmpty)
                        return 'يرجى إدخال اسم الطالب';
                      else if (!arabicRegex.hasMatch(value))
                        return 'اسم الطالب يجب ان يكون عربياً';
                      else if (value.length < 7 || value.length > 20)
                        return 'اسم الطالب يجب ان يكون بين 7 و 20 حرفاً';
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller.phoneController.value,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'رقم ولي الأمر',
                        border: OutlineInputBorder()),
                    validator: (value) {
                      RegExp regExp = RegExp(r'^7[0-9]{8}$');
                      if (value!.isEmpty) {
                        return 'يرجى إدخال رقم ولي الأمر';
                      } else if (!regExp.hasMatch(value)) {
                        return 'يرجى إدخال رقم هاتف صحيح';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller.levelController.value,
                    decoration: const InputDecoration(
                        labelText: 'المستوى', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'يرجى إدخال المستوى';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller.memoRateController.value,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'مقدار الحفظ', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value != null &&
                          (int.tryParse(value) == null ||
                              int.parse(value) < 0)) {
                        return 'يرجى إدخال مقدار حفظ صحيح';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller.studyLevelController.value,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'الصف الدراسي', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller.notesController.value,
                    decoration: const InputDecoration(
                        labelText: 'ملاحظات', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InputDecorator(
                        decoration: InputDecoration(
                          labelText:
                              'المرحلة الدراسية', // Add label text similar to TextFormField
                          border: OutlineInputBorder(), // Outline border
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12), // Adjust padding
                        ),
                        child: DropdownButtonHideUnderline(
                          child:Obx(()=> DropdownButton<String>(
                            isExpanded: true,
                            value: controller.selectedSchoolLevel.value,
                            onChanged: (value) {
                              controller.selectedSchoolLevel.value =
                                  value.toString();
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'المرحلة الابتدائية',
                                child: Text('المرحلة الابتدائية'),
                              ),
                              DropdownMenuItem(
                                value: 'المرحلة الاعدادية',
                                child: Text('المرحلة الاعدادية'),
                              ),
                              DropdownMenuItem(
                                value: 'المرحلة الثانوية',
                                child: Text('المرحلة الثانوية'),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() => InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'الحلقة', // Add label text
                          border:
                              OutlineInputBorder(), // Outline border like TextFormField
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12), // Adjust padding
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            isExpanded:
                                true, // Ensures the dropdown expands to full width
                            value:
                                controller.selectedGroup.value, // Default value
                            onChanged: (value) {
                              controller.selectedGroup.value =
                                  value; // Update selected group
                            },
                            items: controller.groups.map((group) {
                              return DropdownMenuItem(
                                value: group.id, // Group ID as value
                                child: Text(group
                                    .groupName), // Group name as the displayed text
                              );
                            }).toList(),
                          ),
                        ),
                      )),
                ),
                const SizedBox(height: 20),
                MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await controller.addStudent();
                      }
                    },
                    minWidth: double.infinity,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 60,
                    color: const Color.fromARGB(255, 63, 181, 108),
                    child: Obx(
                      () => Text(controller.isLoading.value
                          ? 'جاري الإضافة...'
                          : 'إضافة الطالب'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
