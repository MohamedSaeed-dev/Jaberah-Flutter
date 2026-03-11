import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/groupStudentsController.dart';
import 'package:jaberah/controllers/user/studentGroupsFollowStudentsController.dart';
import 'package:jaberah/pages/user/followStudents/editData_followStudent.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class StudentGroupsFollowStudents extends StatelessWidget {
  final StudentGroupsFollowStudentsController controller =
      Get.put(StudentGroupsFollowStudentsController());
  final StudentsOfGroupController studentController =
      Get.put(StudentsOfGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'طلاب ${controller.name}',
          style: TextStyle(
            fontFamily: 'GE_SS_Two',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Obx(
              () => _buildHijriDatePicker(context, 'التاريخ الهجري:'),
            ),
            Obx(() => TextField(
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
                  onSubmitted: controller.isLoading.value
                      ? null
                      : (value) {
                          // controller.pageNumber.value = 1;
                          controller.getStudents();
                        },
                )),
            const Divider(
              height: 30,
            ),
            Obx(() {
              if (controller.isLoading.value) {
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
                  !controller.isLoading.value) {
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
                    itemCount: controller.filteredStudents.length,
                    itemBuilder: (context, index) {
                      return _buildStudentsCard(
                          controller.filteredStudents[index], context);
                    },
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHijriDatePicker(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              "${controller.selectedDate.value.jhijri!.day} - ${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
            onPressed: () => _selectHijriDate(context),
            icon: Icon(Icons.calendar_month))
      ],
    );
  }

  Future<void> _selectHijriDate(BuildContext context) async {
    var picked = await showGlobalDatePicker(
      headerTitle: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "التقويم الهجري",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // Smaller for cleaner appearance
              fontWeight: FontWeight.w600, // Slightly bold for emphasis
              letterSpacing: 1.2, // Adds a modern touch with spaced letters
            ),
          ),
        ),
      ),
      locale: const Locale("ar", "SA"),
      context: context,
      pickerType: PickerType.JHijri,
      primaryColor: const Color(0xFF1976D2), // Blue accent for primary color
      backgroundColor: Colors.white, // Light background for contrast
      cancelButtonText: "إلغاء",
      okButtonText: "تأكيد",
      selectedDate: controller.selectedDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedDate.value.jhijri) {
      controller.selectedDate.value = JDateModel(jhijri: picked.jhijri, dateTime: picked.date);
      await controller.getStudents();
    }
  }

  Widget _buildStudentsCard(FollowStudent student, BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  student.studentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.to(() => EditFollowStudent(), arguments: {
                      "student": student,
                      "date": controller.selectedDate.value
                    });
                  },
                  icon: Icon(Icons.edit),
                  color: Colors.blue,
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // حفظ ومراجعة Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "الحفظ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildInfoRow("من سورة:", student.surahFromTeacher),
                        _buildInfoRow(
                            "آيه:", student.verseFromTeacher.toString()),
                        _buildInfoRow("إلى سورة:", student.surahToTeacher),
                        _buildInfoRow(
                            "آيه:", student.verseToTeacher.toString()),
                        _buildInfoRow("التقدير:", student.rateTeacher),
                        _buildInfoRow(
                            "عدد الصفحات:", student.pagesTeacher.toString()),
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "المراجعة",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildInfoRow("من سورة:", student.surahFromFriend),
                        _buildInfoRow(
                            "آيه:", student.verseFromFriend.toString()),
                        _buildInfoRow("إلى سورة:", student.surahToFriend),
                        _buildInfoRow("آيه:", student.verseToFriend.toString()),
                        _buildInfoRow("التقدير:", student.rateFriend),
                        _buildInfoRow(
                            "عدد الصفحات:", student.pagesFriend.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24, thickness: 1),
            const SizedBox(height: 10),

            // الحضور والسلوك Section
            _buildStudentRow('الحضور:', student.attendance.toString()),
            _buildStudentRow('السلوك:', student.behavior.toString()),
            _buildInfoRow('ملاحظات:', student.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

// Helper to build student rows
  Widget _buildStudentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
