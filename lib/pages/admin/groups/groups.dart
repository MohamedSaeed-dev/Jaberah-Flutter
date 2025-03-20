import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/pages/admin/groups/groupsStudents.dart';

class Groups extends StatelessWidget {
  final GroupsController groupsController = Get.put(GroupsController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
            },
          ),
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
                  SizedBox(height: 10),
                  Text("جاري تحميل الحلقات...", style: TextStyle(fontSize: 20)),
                ],
              ),
            );
          } else if (groupsController.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 50),
                  SizedBox(height: 10),
                  Text("لاتوجد بيانات", style: TextStyle(fontSize: 20)),
                ],
              ),
            );
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 3 : 2, // Adjust for tablets
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: screenWidth > 600 ? 1.2 : 1,
              ),
              itemCount: groupsController.groups.length,
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
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

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
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("المعلم : $teacher", textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text("الفترة : $period", textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text("عدد الطلاب: $numberStd", textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("إضافة حلقة جديدة",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: groupsController.groupNameController.value,
                      decoration: InputDecoration(
                          labelText: 'اسم الحلقة',
                          border: OutlineInputBorder()),
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
                    SizedBox(height: 20),
                    Obx(() => DropdownButtonFormField<String>(
                          value: groupsController.period.value,
                          items: [
                            DropdownMenuItem(
                              value: 'صباحية',
                              child: Text('صباحية'),
                            ),
                            DropdownMenuItem(
                              value: 'مسائية',
                              child: Text('مسائية'),
                            ),
                          ],
                          onChanged: (value) {
                            groupsController.period.value = value!;
                          },
                          decoration: InputDecoration(
                              labelText: 'الفترة',
                              border: OutlineInputBorder()),
                        )),
                    SizedBox(height: 20),
                    _buildTeachersDropdown(),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text('إلغاء'),
                        ),
                        Obx(() => TextButton(
                              onPressed: groupsController.isLoading.value
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        await groupsController.addGroup();
                                      }
                                    },
                              child: Text(groupsController.isLoading.value
                                  ? 'جاري الإضافة...'
                                  : ' إضافة الحلقة'),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeachersDropdown() {
    return Obx(() => DropdownButtonFormField(
          value: groupsController.selectedTeacherId.value,
          onChanged: (value) {
            groupsController.selectedTeacherId.value = value!;
          },
          items: groupsController.teachersForGeneralUse.map((teacher) {
            return DropdownMenuItem(
                value: teacher.id, child: Text(teacher.teacherName));
          }).toList(),
          decoration: InputDecoration(border: OutlineInputBorder()),
        ));
  }
}
