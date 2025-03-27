import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/reportTeachersAttendancesController.dart';
import 'package:jaberah/controllers/admin/teachersAttendancesController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class TeachersAttendancePage extends StatelessWidget {
  // Initialize the controller once at the top level
  final TeacherAttendancesController controller =
      Get.put(TeacherAttendancesController());

  TeachersAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الحضور المعلمين',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3FB56C),
        elevation: 2,
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    await controller.updateTeachersAttendances();
                  },
            label: const Text(
              "حـفـظ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            icon: const Icon(
              Icons.save,
              color: Colors.black,
            ),
            backgroundColor: const Color(0xFF3FB56C),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Picker Section inside a Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildHijriMonthDatePicker(context, "الشهر:"),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            // Attendance List: Wrap only the reactive part in Obx
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingIndicator();
                } else if (controller.filteredTeachersAttendances.isEmpty) {
                  return _buildEmptyDataIndicator();
                } else {
                  return ListView.separated(
                    itemCount: controller.filteredTeachersAttendances.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      int id = controller.filteredTeachersAttendances[index].id;
                      bool? signature = controller
                          .filteredTeachersAttendances[index].signature;
                      bool? isExcuse = controller
                          .filteredTeachersAttendances[index].isExcuse;
                      // Ensure an entry exists for this teacher.
                      // Here we check entries; make sure entries is reactive.
                      if (!controller.entries
                          .any((entry) => entry.teacherId == id)) {
                        controller.entries.add(EntryAttendance(
                          teacherId: id,
                          signature: signature,
                          isExcuse: isExcuse,
                        ));
                      }
                      return Obx(() => _buildAttendanceCard(context,
                          controller.filteredTeachersAttendances[index]));
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Date picker section with a label and the selected Hijri date.
  Widget _buildHijriMonthDatePicker(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Use Flexible to avoid overflow issues.
        Flexible(
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Obx(
                  () => Text(
                    "${controller.selectedDate.value.jhijri!.day}-${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _selectHijriDate(context),
          icon: const Icon(Icons.calendar_month, size: 28),
          color: const Color(0xFF3FB56C),
        ),
      ],
    );
  }

  /// Displays the Hijri date picker and updates the selected date.
  Future<void> _selectHijriDate(BuildContext context) async {
    var picked = await showGlobalDatePicker(
      locale: const Locale("ar", "SA"),
      context: context,
      pickerType: PickerType.JHijri,
      primaryColor: const Color(0xFF3FB56C),
      backgroundColor: Colors.white,
      cancelButtonText: "إلغاء",
      okButtonText: "تأكيد",
      selectedDate: controller.selectedDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedDate.value.jhijri) {
      controller.selectedDate.value = JDateModel(jhijri: picked.jhijri);
      controller.entries.clear();
      await controller.getTeachersAttendances();
    }
  }

  /// Loading indicator widget.
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            "جاري تحميل حضور المعلمين...",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  /// Widget to display when there is no attendance data.
  Widget _buildEmptyDataIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.hourglass_empty, size: 40),
          SizedBox(height: 10),
          Text("لا توجد بيانات", style: TextStyle(fontSize: 20))
        ],
      ),
    );
  }

  /// Builds an attendance card for a given teacher.
  Widget _buildAttendanceCard(
      BuildContext context, TeacherAttendanceForDayReport teacher) {
    final int id = teacher.id;
    // Get the entry for this teacher.
    final entry = controller.entries.firstWhere((x) => x.teacherId == id);
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Name Row
            Row(
              children: [
                Flexible(
                  child: Text(
                    "المعلم: ${teacher.teacherName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Attendance Options Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttendanceOption(
                  label: "حاضر",
                  value: entry.signature ?? false,
                  onChanged: (value) =>
                      controller.updateEntry(id, signature: value),
                ),
                _buildAttendanceOption(
                  label: "غائب بعذر",
                  value: entry.isExcuse ?? false,
                  onChanged: (value) =>
                      controller.updateEntry(id, isExcuse: value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single attendance option with its label and checkbox.
  Widget _buildAttendanceOption({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Checkbox(
          activeColor: const Color(0xFF3FB56C),
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
