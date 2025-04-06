import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/trashController.dart';

class TrashPage extends StatelessWidget {
  final TrashController controller = Get.put(TrashController());

  TrashPage({Key? key}) : super(key: key) {
    // Optionally load the first tab's data (students) when the widget is created.
    if (controller.studentsTrash.isEmpty) {
      controller.getStudentsTrashRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Three tabs: students, groups, and teachers
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سلة المحذوفات'),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
          bottom: TabBar(
            // onTap callback triggers loading data for the selected tab if not loaded already.
            onTap: (index) async {
              if (index == 0 && controller.groupsTrash.isEmpty) {
                await controller.getGroupsTrashRecords();
              } else if (index == 1 && controller.studentsTrash.isEmpty) {
                await controller.getStudentsTrashRecords();
              } else if (index == 2 && controller.teachersTrash.isEmpty) {
                await controller.getTeachersTrashRecords();
              }
            },
            tabs: const [
              Tab(text: 'الحلقات'),
              Tab(text: 'الطلاب'),
              Tab(text: 'المعلمون'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTrashTab('groups'),
            _buildTrashTab('students'),
            _buildTrashTab('teachers'),
          ],
        ),
      ),
    );
  }

  /// Builds the trash tab view based on the given [type]
  Widget _buildTrashTab(String type) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("جاري تحميل البيانات...")
            ],
          ),
        );
      } else if (controller.getTrashRecords(type).isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.hourglass_empty),
              SizedBox(height: 10),
              Text("لا توجد بيانات", style: TextStyle(fontSize: 20))
            ],
          ),
        );
      } else {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          itemCount: controller.getTrashRecords(type).length,
          itemBuilder: (context, index) {
            final record = controller.getTrashRecords(type)[index];

            // Set title and subtitle based on record type.
            String title;
            String subtitle;
            if (type == 'students') {
              title = record.studentName;
              subtitle = record.phoneNumber;
            } else if (type == 'groups') {
              title = record.groupName;
              subtitle = record.period;
            } else {
              title = record.teacherName;
              subtitle = record.phoneNumber;
            }

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: Icon(
                        type == 'students'
                            ? Icons.school
                            : type == 'groups'
                                ? Icons.group
                                : Icons.person,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showRestoreConfirmation(context, record.id, type);
                          },
                          icon: const Icon(Icons.restore, color: Colors.green),
                        ),
                        IconButton(
                          onPressed: () {
                            _showPermanentDeleteConfirmation(
                                context, record.id, type);
                          },
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }
    });
  }

  void _showRestoreConfirmation(BuildContext context, int id, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('تأكيد الاستعادة'),
          content: const Text('هل أنت متأكد أنك تريد استعادة هذا السجل؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Obx(
                () => Text(
                    controller.isLoading.value
                        ? 'جاري الاستعادة...'
                        : 'استعادة',
                    style: TextStyle(color: Colors.green)),
              ),
              onPressed: () async {
                await controller.restoreRecord(id: id, type: type);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermanentDeleteConfirmation(
      BuildContext context, int id, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('تأكيد الحذف الدائم'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا السجل بشكل دائم؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Obx(
                () => Text(controller.isLoading.value ? 'جاري الحذف...' : 'حذف',
                    style: TextStyle(color: Colors.red)),
              ),
              onPressed: () async {
                await controller.deleteRecordPermanently(id: id, type: type);
              },
            ),
          ],
        );
      },
    );
  }
}
