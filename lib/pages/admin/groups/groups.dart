import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/pages/admin/groups/groupsStudents.dart';

class Groups extends StatelessWidget {
  final GroupsController groupsController = Get.put(GroupsController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          title: Text('بدون معلمين'),
                          value: groupsController.withoutTeacher.value,
                          onChanged: (bool? value) async {
                            groupsController.withoutTeacher.value = value!;
                            await groupsController.getGroups();
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ));
                  },
                ),
              ),
            ];
          }),
        ],
        leading: IconButton(
            onPressed: () {
              Get.delete<GroupsController>();
              Get.back();
            },
            icon: Icon(Icons.arrow_back)),
        title: const Text(
          'الحلقات',
          style: TextStyle(
            fontFamily: 'GE_SS_Two',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() {
          if (groupsController.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(
                    "جاري تحميل الحلقات...",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            );
          } else if (groupsController.groups.isEmpty &&
              !groupsController.isLoading.value) {
            return Center(
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
            );
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10, // Horizontal spacing between cards
                mainAxisSpacing: 10, // Vertical spacing between cards
              ),
              itemCount: groupsController.groups.length, // Number of cards
              itemBuilder: (context, index) {
                var data = groupsController.groups[index];
                return _buildGroupCard(
                  context: context,
                  title: data.groupName,
                  teacher: data.teacherName ?? "بدون معلم",
                  period: data.period,
                  numberStd: data.studentsNo,
                  color: const Color.fromARGB(255, 63, 181, 108),
                  onTap: () {
                    Get.to(() => GroupStudents(), arguments: {
                      "Id": data.id,
                      "Name": data.groupName,
                      "teacherId": data.teacherId,
                      "period": data.period
                    });
                  },
                );
              },
            );
          }
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await groupsController.getTeachers();
          _showAddGroupDialog(context);
        },
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
        label: const Text(
          'إضافة حلقة',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  // Build Group Card
  Widget _buildGroupCard({
    required BuildContext context,
    required String title,
    required String teacher,
    required int numberStd,
    required String period,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GE_SS_Two',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "المعلم : $teacher",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'GE_SS_Two',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "الفترة : $period",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'GE_SS_Two',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "عدد الطلاب: $numberStd",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'GE_SS_Two',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog to add new group
  void _showAddGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إضافة حلقة جديدة'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: groupsController.groupNameController.value,
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
                      value: groupsController.period.value,
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
                        groupsController.period.value = value!;
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
              onPressed: groupsController.isLoading.value
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        await groupsController.addGroup();
                      }
                    },
              child: Obx(() => Text(groupsController.isLoading.value
                  ? 'جاري الإضافة...'
                  : ' إضافة الحلقة')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeachersDropdown() {
    groupsController.teachersForGeneralUse
        .insert(0,TeachersForGeneralUse(id: null, teacherName: "بدون معلم"));
    return Obx(() => InputDecorator(
          decoration: InputDecoration(
            labelText: 'المعلم',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              value: groupsController.selectedTeacherId.value,
              onChanged: (value) {
                groupsController.selectedTeacherId.value = value!;
              },
              items: groupsController.teachersForGeneralUse.map((teacher) {
                return DropdownMenuItem(
                  value: teacher.id,
                  child: Text(teacher.teacherName),
                );
              }).toList(),
            ),
          ),
        ));
  }
}
