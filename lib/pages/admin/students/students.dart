import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/studentsController.dart';

class Students extends StatelessWidget {
  final StudentsController controller = Get.put(StudentsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
          color: Color(0xfef7ff),
          shape: const CircularNotchedRectangle(),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await controller.getGroups();
              _showAddStudentDialog(context);
            },
            label: const Text(
              'إضافة طالب جديد',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            backgroundColor: const Color.fromARGB(255, 63, 181, 108),
          )),
      appBar: AppBar(
        actions: [
          PopupMenuButton(
              iconColor: Colors.black,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Obx(() => CheckboxListTile(
                              title: Text('بدون حلقات'),
                              value: controller.withoutGroup.value,
                              onChanged: (bool? value) async {
                                controller.withoutGroup.value = value!;
                                await controller.getStudents();
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ));
                      },
                    ),
                  ),
                ];
              }),
        ],
        title: const Text(
          'الطلاب',
          style: TextStyle(
            fontFamily: 'GE_SS_Two',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() => TextField(
                  controller: controller.searchText.value,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن طالب...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: controller.isLoadingData.value
                      ? null
                      : (value) async {
                          controller.pageNumber.value = 1;
                          await controller.getStudents();
                        },
                )),
          ),
          Obx(() {
            if (controller.isLoadingData.value) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text(
                        "جاري تحميل الطلاب...",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              );
            } else if (controller.students.isEmpty &&
                !controller.isLoadingData.value) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty),
                      SizedBox(
                        height: 10,
                      ),
                      Text("لاتوجد بيانات", style: TextStyle(fontSize: 20))
                    ],
                  ),
                ),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: controller.students.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 5),
                      child: _buildStudentCard(
                          context, controller.students[index]),
                    );
                  },
                ),
              );
            }
          }),
          Obx(() => _buildPaginationControls()),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed:
              controller.hasPrevious.value && !controller.isLoadingData.value
                  ? () {
                      controller.pageNumber.value--;
                      controller.getStudents();
                    }
                  : null,
        ),
        Text(
            '${controller.fetchedCount.value} من ${controller.totalCount.value}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          color: Colors.black,
          onPressed: controller.hasNext.value && !controller.isLoadingData.value
              ? () async {
                  controller.pageNumber.value++;
                  await controller.getStudents();
                }
              : null,
        ),
      ],
    );
  }

  final _formKeyAddStudent = GlobalKey<FormState>();

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('إضافة طالب جديد'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Form(
              key: _formKeyAddStudent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                      'الاسم', controller.nameAddController.value, (value) {
                    final arabicRegex =
                        RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                    if (value!.isEmpty)
                      return 'يرجى إدخال اسم الطالب';
                    else if (!arabicRegex.hasMatch(value))
                      return 'اسم الطالب يجب ان يكون عربياً';
                    else if (value.length < 7 || value.length > 20)
                      return 'اسم الطالب يجب ان يكون بين 7 و 20 حرفاً';
                    return null;
                  }),
                  TextFormField(
                    controller: controller.phoneAddController.value,
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
                  _buildDialogTextField(
                      'مقدار الحفظ', controller.rateAddController.value,
                      (value) {
                    if (value != null &&
                        (int.tryParse(value) == null || int.parse(value) < 0)) {
                      return 'يرجى إدخال مقدار حفظ صحيح';
                    }
                    return null;
                  }),
                  _buildDialogTextField(
                      'المستوى', controller.levelAddController.value, (value) {
                    return null;
                  }),
                  _buildDialogTextField(
                      'الصف الدراسي', controller.studyLevelAddController.value,
                      (value) {
                    return null;
                  }),
                  _buildDialogTextField(
                      'ملاحظات', controller.notesAddController.value, (value) {
                    return null;
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText:
                            'المرحلة الدراسية', // Add label text similar to TextFormField
                        border: OutlineInputBorder(), // Outline border
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12), // Adjust padding
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Obx(() => DropdownButton<String>(
                              isExpanded: true,
                              value: controller.selectedAddSchoolClass.value.isEmpty
                                  ? null
                                  : controller.selectedAddSchoolClass.value,
                              hint: Text('اختر المرحلة الدراسية'),
                              onChanged: (value) {
                                controller.selectedAddSchoolClass.value =
                                    value ?? "";
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
                            )),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Obx(() => InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'الحلقة', // Add label text
                              border:
                                  OutlineInputBorder(), // Outline border like TextFormField
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12), // Adjust padding
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                isExpanded:
                                    true, // Ensures the dropdown expands to full width
                                value: controller
                                    .selectedGroupAddId.value, // Default value
                                onChanged: (int? value) {
                                  controller.selectedGroupAddId.value =
                                      value; // Update selected group
                                },
                                items: controller.groups.map((group) {
                                  return DropdownMenuItem<int?>(
                                    value: group.id, // Group ID as value
                                    child: Text(group
                                        .groupName), // Group name as the displayed text
                                  );
                                }).toList(),
                              ),
                            ),
                          )))
                  // Obx();
                ],
              ),
            ),
          ),
        ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKeyAddStudent.currentState!.validate()) {
                    await controller.addStudent();
                  }
                },
                child: Obx(() => Text(controller.isLoading.value
                    ? 'جاري الإضافة...'
                    : ' إضافة الطالب')),
              ),
            ],
          );
      },
    );
  }

  Widget _buildStudentCard(BuildContext context, Student student) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      shadowColor: Colors.indigo[300],
      color: Colors.indigo[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('اسم الطالب:', student.studentName),
            _buildDetailRow('رقم ولي الامر:', student.phoneNumber),
            _buildDetailRow('مقدار الحفظ:', student.memoRate.toString()),
            _buildDetailRow('المستوى:', student.schoolLevel),
            _buildDetailRow('المرحلة الدراسية:', student.schoolClass),
            _buildDetailRow('الصف الدراسي:', student.studyLevel),
            _buildDetailRow('ملاحظات:', student.notes),
            _buildDetailRow('الحلقة:', student.groupName ?? ""),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    await controller.getGroups();
                    _showEditStudentDialog(context, student);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteStudentConfirmation(
                      context, student.id.toString()),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? "",
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to edit student details
  void _showEditStudentDialog(BuildContext context, Student student) async {
    controller.nameEditController.value.text = student.studentName;
    controller.phoneEditController.value.text = student.phoneNumber;
    
    // Validate and map schoolClass value to match dropdown items
    final validSchoolClasses = [
      'المرحلة الابتدائية',
      'المرحلة الاعدادية',
      'المرحلة الثانوية'
    ];
    String schoolClassValue = student.schoolClass ?? "";
    if (!validSchoolClasses.contains(schoolClassValue)) {
      schoolClassValue = "";
    }
    controller.selectedEditSchoolClass.value = schoolClassValue;
    
    controller.rateEditController.value.text = student.memoRate.toString();
    controller.levelEditController.value.text = student.schoolLevel ?? "";
    controller.notesEditController.value.text = student.notes ?? "";
    controller.studyLevelEditController.value.text = student.studyLevel ?? "";
    controller.selectedGroupEditName.value = student.groupName ?? "";
    controller.selectedGroupEditId.value = student.groupId;
    var keyForm = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('تعديل معلومات الطالب'),
          content: SingleChildScrollView(
            child: Form(
              key: keyForm,
              child: Column(
                children: [
                  _buildDialogTextField(
                      'اسم الطالب', controller.nameEditController.value,
                      (value) {
                    final arabicRegex =
                        RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                    if (value!.isNotEmpty && !arabicRegex.hasMatch(value))
                      return 'اسم الطالب يجب ان يكون عربياً';
                    else if (value.length < 7 || value.length > 20)
                      return 'اسم الطالب يجب ان يكون بين 7 و 20 حرفاً';
                    return null;
                  }),
                  TextFormField(
                    controller: controller.phoneEditController.value,
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
                  _buildDialogTextField(
                      'مقدار الحفظ', controller.rateEditController.value,
                      (value) {
                        if(value != null && (int.tryParse(value) == null || int.parse(value) < 0)) {
                          return 'يرجى إدخال مقدار حفظ صحيح';
                        }
                    return null;
                  }),
                  _buildDialogTextField(
                      'المستوى', controller.levelEditController.value, (value) {
                    return null;
                  }),
                  _buildDialogTextField(
                      'الصف الدراسي', controller.studyLevelEditController.value, (value) {
                    return null;
                  }),
                  _buildDialogTextField(
                      'ملاحظات', controller.notesEditController.value, (value) {
                    return null;
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText:
                            'المرحلة الدراسية', // Add label text similar to TextFormField
                        border: OutlineInputBorder(), // Outline border
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12), // Adjust padding
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Obx(() => DropdownButton<String>(
                              isExpanded: true,
                              value: controller.selectedEditSchoolClass.value.isEmpty
                                  ? null
                                  : controller.selectedEditSchoolClass.value,
                              hint: Text('اختر المرحلة الدراسية'),
                              onChanged: (value) {
                                controller.selectedEditSchoolClass.value =
                                    value ?? "";
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
                            )),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Obx(() => InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'الحلقة', // Add label text
                              border:
                                  OutlineInputBorder(), // Outline border like TextFormField
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12), // Adjust padding
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                isExpanded:
                                    true, // Ensures the dropdown expands to full width
                                value: controller.selectedGroupEditId.value,
                                onChanged: (int? value) {
                                  controller.selectedGroupEditId.value =
                                      value; // Update selected group
                                },
                                items: controller.groups.map((group) {
                                  return DropdownMenuItem<int?>(
                                    value: group.id, // Group ID as value
                                    child: Text(group
                                        .groupName), // Group name as the displayed text
                                  );
                                }).toList(),
                              ),
                            ),
                          )))
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              onPressed: controller.isLoadingOperation.value
                  ? null
                  : () async {
                      if (keyForm.currentState!.validate()) {
                        await controller.updateStudent(
                            id: student.id.toString());
                      }
                    },
              child: Obx(() => Text(controller.isLoadingOperation.value
                  ? 'جاري التحديث...'
                  : 'حفظ')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller,
      String? Function(String?)? validatorFunction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validatorFunction,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteStudentConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا الطالب؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              onPressed: controller.isLoadingOperation.value
                  ? null
                  : () async {
                      await controller.deleteStudent(id: id);
                    },
              child: Obx(() => Text(
                    controller.isLoadingOperation.value
                        ? 'جاري الحذف...'
                        : 'حذف',
                    style: TextStyle(color: Colors.red),
                  )),
            ),
          ],
        );
      },
    );
  }
}
