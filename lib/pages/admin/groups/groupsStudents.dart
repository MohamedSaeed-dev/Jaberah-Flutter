import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/groupStudentsController.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';

class GroupStudents extends StatelessWidget {
  final GroupStudentsController controller = Get.put(GroupStudentsController());
  final StudentsOfGroupController studentController =
      Get.put(StudentsOfGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Color(0xfef7ff),
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBottomButton(
                icon: Icons.delete_outline,
                label: 'حذف الحلقة',
                color: Colors.red,
                onPressed: () => _showDeleteConfirmation(context),
              ),
              _buildBottomButton(
                icon: Icons.edit_outlined,
                label: 'تعديل الحلقة',
                color: Colors.blue,
                onPressed: () async {
                  await controller.getTeachers();
                  _showEditGroupDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Obx(() => Text(
              'طلاب ${controller.groupName.value}',
              style: TextStyle(
                fontFamily: 'GE_SS_Two',
                fontWeight: FontWeight.bold,
              ),
            )),
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
                      : (value) {
                          controller.pageNumber.value = 1;
                          controller.getStudents();
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

  // Paginated list

  // Pagination controls
  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
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
          onPressed: controller.hasNext.value && !controller.isLoadingData.value
              ? () {
                  controller.pageNumber.value++;
                  controller.getStudents();
                }
              : null,
        ),
      ],
    );
  }

  // Method to build each student card
  Widget _buildStudentCard(BuildContext context, StudentGroup student) {
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
            _buildDetailRow('مقدار الحفظ:', student.memoRate),
            _buildDetailRow('المستوى:', student.schoolLevel),
            _buildDetailRow('المرحلة الدراسية:', student.schoolClass),
            _buildDetailRow('ملاحظات:', student.notes),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditStudentDialog(context, student),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _showDeleteStudentConfirmation(context, student.id),
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
  void _showEditStudentDialog(BuildContext context, StudentGroup student) {
    studentController.nameController.value.text = student.studentName;
    studentController.phoneController.value.text = student.phoneNumber;
    studentController.selectedSchoolClass.value = student.schoolClass ?? "";
    studentController.rateController.value.text = student.memoRate ?? "";
    studentController.levelController.value.text = student.schoolLevel ?? "";
    studentController.notesController.value.text = student.notes ?? "";
    var key = GlobalKey<FormState>();
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
              key: key,
              child: Column(
                children: [
                  _buildDialogTextField(
                      'اسم الطالب', studentController.nameController.value,
                      (value) {
                    final arabicRegex =
                        RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                    if (value!.isNotEmpty && !arabicRegex.hasMatch(value))
                      return 'اسم الطالب يجب ان يكون عربياً';
                    else if (value.length < 7 || value.length > 20)
                      return 'اسم الطالب يجب ان يكون بين 7 و 20 حرفاً';
                    return null;
                  }),
                  _buildDialogTextField(
                      'رقم ولي الأمر', studentController.phoneController.value,
                      (value) {
                    RegExp regExp = RegExp(r'^7[0-9]{8}$');
                    if (value!.isNotEmpty && !regExp.hasMatch(value)) {
                      return 'يرجى إدخال رقم هاتف صحيح';
                    }
                    return null;
                  }),
                  _buildDialogTextField(
                      'مقدار الحفظ', studentController.rateController.value,
                      (value) {
                    return null;
                  }),
                  _buildDialogTextField(
                      'المستوى', studentController.levelController.value,
                      (value) {
                    return null;
                  }),
                  _buildDialogTextField(
                      'ملاحظات', studentController.notesController.value,
                      (value) {
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
                              value:
                                  studentController.selectedSchoolClass.value,
                              onChanged: (value) {
                                studentController.selectedSchoolClass.value =
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
                            )),
                      ),
                    ),
                  ),
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
              onPressed: studentController.isLoadingOperation.value
                  ? null
                  : () async {
                      if (key.currentState!.validate()) {
                        await studentController.updateStudent(id: student.id);
                      }
                    },
              child: Obx(() => Text(studentController.isLoadingOperation.value
                  ? 'جاري الحفظ...'
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
  void _showDeleteStudentConfirmation(BuildContext context, int id) {
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
              onPressed: studentController.isLoadingOperation.value
                  ? null
                  : () async {
                      await studentController.deleteStudent(id: id);
                    },
              child: Obx(() => Text(
                    studentController.isLoadingOperation.value
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

  // Placeholder for delete confirmation for the group
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('تأكيد الحذف'),
          content: const Text(
              'هل أنت متأكد أنك تريد حذف هذه الحلقة؟\n ملاحظة: لن يؤدي إلى حذف الطلاب. '),
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
                      await controller.deleteGroup();
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

  // Placeholder for edit dialog for the group
  final formKeyGroupName = GlobalKey<FormState>();

  void _showEditGroupDialog(BuildContext context) {
    controller.groupNameText.value.text = controller.groupName.value;

    controller.selectedTeacherId.value = controller.teacherIdText;

    controller.period.value = controller.period.value;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل الحلقة '),
          content: Form(
            key: formKeyGroupName,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller.groupNameText.value,
                  decoration: const InputDecoration(
                      labelText: 'اسم الحلقة', border: OutlineInputBorder()),
                  validator: (value) {
                    final arabicRegex =
                        RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                    if (value!.isEmpty)
                      return 'يرجى إدخال اسم الحلقة';
                    else if (!arabicRegex.hasMatch(value))
                      return 'اسم الحلقة يجب ان يكون عربياً';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Obx(() => DropdownButtonFormField<String>(
                      value: controller.period.value,
                      hint: Text(
                        'اختر الفترة',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'صباحية',
                          child: Text('صباحية', style: TextStyle(fontSize: 16)),
                        ),
                        DropdownMenuItem(
                          value: 'مسائية',
                          child: Text('مسائية', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                      onChanged: (value) {
                        controller.period.value = value!;
                      },
                      decoration: InputDecoration(
                          labelText: 'الفترة', border: OutlineInputBorder()),
                    )),
                const SizedBox(height: 20),
                _buildTeachersDropdown(),
              ],
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
              onPressed: controller.isLoadingOperation.value
                  ? null
                  : () async {
                      if (formKeyGroupName.currentState!.validate()) {
                        await controller.updateGroup();
                      }
                    },
              child: Obx(() => Text(controller.isLoadingOperation.value
                  ? 'جاري التعديل...'
                  : ' تعديل الحلقة')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeachersDropdown() {
    controller.teachersForGeneralUse
        .insert(0, TeachersForGeneralUse(id: null, teacherName: "بدون معلم"));
    return Obx(() => InputDecorator(
          decoration: InputDecoration(
            labelText: 'المعلم',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              value: controller.selectedTeacherId.value,
              onChanged: (value) {
                controller.selectedTeacherId.value = value;
              },
              items: controller.teachersForGeneralUse.map((teacher) {
                return DropdownMenuItem(
                  value: teacher.id,
                  child: Text(teacher.teacherName),
                );
              }).toList(),
            ),
          ),
        ));
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color), // Consistent color border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Modern rounded corners
        ),
      ),
    );
  }
}
