import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/reportTeachersAttendancesController.dart';
import 'package:jaberah/controllers/admin/teachersAttendancesController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class TeachersAttendancePage extends StatelessWidget {
  final TeacherAttendancesController controller =
      Get.put(TeacherAttendancesController());

  TeachersAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Obx(() => FloatingActionButton.extended(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        await controller.updateTeachersAttendances();
                      },
                label: Text(
                  "حـفـظ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                icon: Icon(
                  Icons.save,
                  color: Colors.black,
                ),
                backgroundColor: const Color.fromARGB(255, 63, 181, 108),
              )),
        ),
        appBar: AppBar(
          title: const Text(
            'الحضور للمعلمين',
            style:
                TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Obx(
                    () => _buildHijriMonthDatePicker(context, "الشهر الهجري:")),
              ),
            ),
            const Divider(),
            Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingIndicator();
              } else if (controller.filteredTeachersAttendances.isEmpty) {
                return _buildEmptyDataIndicator();
              } else {
                return Expanded(
                    child: ListView.builder(
                        itemCount:
                            controller.filteredTeachersAttendances.length,
                        itemBuilder: (context, index) {
                          int id =
                              controller.filteredTeachersAttendances[index].id;
                          bool? signature = controller
                              .filteredTeachersAttendances[index].signature;
                          bool? isExcuse = controller
                              .filteredTeachersAttendances[index].isExcuse;
                          if (!controller.entries
                              .any((entry) => entry.teacherId == id)) {
                            controller.entries.add(EntryAttendance(
                                teacherId: id,
                                signature: signature,
                                isExcuse: isExcuse));
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 5),
                            child: _buildAttendanceCard(context,
                                controller.filteredTeachersAttendances[index]),
                          );
                        }));
              }
            }),
          ],
        ));
  }

  Widget _buildHijriMonthDatePicker(BuildContext context, String label) {
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
              "${controller.selectedDate.value.jhijri!.day}-${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
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
      controller.selectedDate.value = JDateModel(jhijri: picked.jhijri);
      controller.entries.clear();
      await controller.getTeachersAttendances();
    }
  }

  // Hijri Month Picker for Month Search

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            Text(
              "جاري تحميل حضور المعلمين...",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDataIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.hourglass_empty),
            SizedBox(height: 10),
            Text("لاتوجد بيانات", style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(
      BuildContext context, TeacherAttendanceForDayReport teacher) {
    var id = teacher.id;
    return Container(
      height: 130,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: Colors.indigo[300], // Card shadow color
        color: Colors.indigo[50], // Card background color
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text("- المعلم: "),
                  Text(
                    '${teacher.teacherName}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        "حاضر : ",
                      ),
                      Obx(
                        () => Checkbox(
                            value: controller.entries
                                    .firstWhere((x) => x.teacherId == id)
                                    .signature ??
                                false,
                            onChanged: (value) {
                              controller.updateEntry(id, signature: value);
                            }),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("غائب بعذر :",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)),
                          Obx(
                            () => Checkbox(
                                value: controller.entries
                                        .firstWhere((x) => x.teacherId == id)
                                        .isExcuse ??
                                    false,
                                onChanged: (value) {
                                  controller.updateEntry(id, isExcuse: value);
                                }),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
