import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/partialExamsController.dart';
import 'package:jaberah/pages/admin/partialExams/students_partialExams.dart';

class GroupsPartialExams extends StatelessWidget {
  final GroupsPartialExamsController groupsController =
      Get.put(GroupsPartialExamsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.delete<GroupsPartialExamsController>();
              Get.back();
            },
            icon: Icon(Icons.arrow_back)),
        title: const Text(
          'اختبارات الجزئي',
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
              itemCount: groupsController.groups.length,
              itemBuilder: (context, index) {
                var data = groupsController.groups[index];
                return _buildGroupCard(
                  context: context,
                  title: data.groupName,
                  period: data.period,
                  studentsCount: data.studentsNo,
                  color: const Color.fromARGB(255, 63, 181, 108),
                  onTap: () {
                    Get.to(() => StudentsPartialExams(),
                        arguments: {"id": data.id, "Name": data.groupName});
                  },
                );
              },
            );
          }
        }),
      ),
    );
  }

  // Build Group Card
  Widget _buildGroupCard({
    required BuildContext context,
    required String title,
    required String period,
    required int studentsCount,
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
                "الفترة : $period",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'GE_SS_Two',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "عدد الطلاب : $studentsCount",
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
}
