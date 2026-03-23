import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/teachersController.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

class Teachers extends StatelessWidget {
  final TeachersController controller = Get.put(TeachersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
          color: Color(0xfef7ff),
          shape: const CircularNotchedRectangle(),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await controller.getGroups();
              _showAddTeacherDialog(context);
            },
            label: const Text(
              'إضافة معلم جديد',
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
                              value: controller.withoutGroups.value,
                              onChanged: (bool? value) async {
                                controller.withoutGroups.value = value!;
                                await controller.getTeachers();
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
          'المعلمين',
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
                    hintText: 'ابحث عن معلم...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: controller.isLoadingData.value
                      ? null
                      : (value) async {
                          controller.pageNumber.value = 1;
                          await controller.getTeachers();
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
                        "جاري تحميل المعلمين...",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              );
            } else if (controller.teachers.isEmpty &&
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
                  itemCount: controller.teachers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 5),
                      child: _buildTeacherCard(
                          context, controller.teachers[index]),
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
          onPressed:
              controller.hasPrevious.value && !controller.isLoadingData.value
                  ? () {
                      controller.pageNumber.value--;
                      controller.getTeachers();
                    }
                  : null,
        ),
        Text(
            '${controller.fetchedCount.value} من ${controller.totalCount.value}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: controller.hasNext.value && !controller.isLoadingData.value
              ? () async {
                  controller.pageNumber.value++;
                  await controller.getTeachers();
                }
              : null,
        ),
      ],
    );
  }

  // Method to build each teacher card
  Widget _buildTeacherCard(BuildContext context, Teacher teacher) {
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
            _buildDetailRow('الاسم:', teacher.teacherName),
            _buildDetailRow('رقم الجوال:', teacher.phoneNumber),
            _buildDetailRow(
                'الحلقات:',
                teacher.groups != null
                    ? teacher.groups!.map((group) => group.groupName).join("، ")
                    : ""),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    await controller.getGroupsSpecial(
                        id: teacher.id.toString());
                    _showEditDialog(context, teacher);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteTeacherConfirmation(
                      context, teacher.id.toString()),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller,
      String? Function(String?) valiadtor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        validator: valiadtor,
        keyboardType:
            label == 'رقم الجوال' ? TextInputType.phone : TextInputType.text,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteTeacherConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا المعلم؟'),
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
                      await controller.deleteTeacher(id: id);
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

  void _showEditDialog(BuildContext context, Teacher teacher) {
    controller.nameEditController.value.text = teacher.teacherName;
    controller.phoneEditController.value.text = teacher.phoneNumber;
    controller.selectedGroupsEdit.clear();
    final groupIds = teacher.groups?.map((g) => g.id).toList() ?? <int>[];
    controller.selectedGroupsEdit.addAll(groupIds);

    var key = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('تعديل معلومات المعلم'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: controller.nameEditController.value,
                  validator: (value) {
                    final arabicRegex =
                        RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                    if (!arabicRegex.hasMatch(value!))
                      return 'اسم المعلم يجب ان يكون عربياً';
                    else if (value.length < 7 || value.length > 20)
                      return 'اسم المعلم يجب ان يكون بين 7 و 20 حرفاً';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'اسم المعلم',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: controller.phoneEditController.value,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    RegExp regExp = RegExp(r'^7[0-9]{8}$');
                    if (!regExp.hasMatch(value!)) {
                      return 'يرجى إدخال رقم هاتف صحيح';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'رقم الجوال',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: SingleChildScrollView(
                    child: Obx(() => MultiSelectDialogField<int>(
                          cancelText: const Text("الغاء"),
                          confirmText: const Text("تأكيد"),
                          title: const Text("الحلقات المتاحة"),
                          items: controller.groupsSpecial
                              .map((group) => MultiSelectItem<int>(
                                  group.id, group.name))
                              .toList(),
                          initialValue: controller.selectedGroupsEdit.toList(),
                          listType: MultiSelectListType.CHIP,
                          onConfirm: (values) {
                            controller.selectedGroupsEdit.value =
                                values.cast<int>();
                          },
                          buttonText: Text(controller.isGroupLoading.value
                              ? "جاري التحميل..."
                              : "اختر الحلقات"),
                          chipDisplay: MultiSelectChipDisplay<int>(
                            items: controller.selectedGroupsEdit
                                .map((groupId) {
                                  final group =
                                      controller.groupsSpecial.firstWhere(
                                    (g) => g.id == groupId,
                                    orElse: () =>
                                        GroupsSpecial(id: groupId, name: ""),
                                  );
                                  return MultiSelectItem<int>(
                                      group.id, group.name);
                                }).toList(),
                          ),
                        )),
                  ),
                ),
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
                  if (key.currentState!.validate()) {
                    await controller.updateTeacher(
                      id: teacher.id.toString(),
                    );
                  }
                },
                child: Obx(() => Text(controller.isLoadingOperation.value
                    ? 'جاري التحديث...'
                    : 'حفظ'))),
          ],
        );
      },
    );
  }

  final _formKeyAddTeacher = GlobalKey<FormState>();

  void _showAddTeacherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إضافة معلم جديد'),
          content: Form(
            key: _formKeyAddTeacher,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                    'الاسم', controller.nameAddController.value, (value) {
                  final arabicRegex =
                      RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                  if (value!.isEmpty)
                    return 'يرجى إدخال اسم المعلم';
                  else if (!arabicRegex.hasMatch(value))
                    return 'اسم المعلم يجب ان يكون عربياً';
                  else if (value.length < 7 || value.length > 20)
                    return 'اسم المعلم يجب ان يكون بين 7 و 20 حرفاً';
                  return null;
                }),
                _buildDialogTextField(
                    'رقم الجوال', controller.phoneAddController.value, (value) {
                  RegExp regExp = RegExp(r'^7[0-9]{8}$');
                  if (value!.isEmpty) {
                    return 'يرجى إدخال رقم الجوال';
                  } else if (!regExp.hasMatch(value)) {
                    return 'يرجى إدخال رقم هاتف صحيح';
                  }
                  return null;
                }),
                Obx(() => MultiSelectDialogField(
                      cancelText: Text("الغاء"),
                      confirmText: Text("تأكيد"),
                      title: Text(" الحلقات المتاحة"),
                      items: controller.groups.length > 0
                          ? controller.groups
                              .map((group) => MultiSelectItem(
                                  group.id.toString(), group.name))
                              .toList()
                          : [],
                      initialValue: controller.selectedGroupsAdd,
                      listType: MultiSelectListType.CHIP,
                      onConfirm: (values) {
                        controller.selectedGroupsAdd.value =
                            values.cast<String>();
                      },
                      buttonText: const Text("اختر الحلقات"),
                      chipDisplay: MultiSelectChipDisplay(
                        items: controller.selectedGroupsAdd.map((groupId) {
                          final group = controller.groups.firstWhere(
                              (group) => group.id.toString() == groupId);
                          return MultiSelectItem(
                              group.id.toString(), group.name);
                        }).toList(),
                      ),
                    ))
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
              onPressed: () async {
                if (_formKeyAddTeacher.currentState!.validate()) {
                  await controller.addTeacher();
                }
              },
              child: Obx(() => Text(controller.isLoading.value
                  ? 'جاري الإضافة...'
                  : ' إضافة المعلم')),
            ),
          ],
        );
      },
    );
  }

}
