import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/reportTeachersAttendancesController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class TeachersAttendanceReport extends StatelessWidget {
  final TeachersAttendancesReportController controller =
      Get.put(TeachersAttendancesReportController());

  TeachersAttendanceReport({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Builder(
            builder: (BuildContext newContext) {
              return Obx(() => FloatingActionButton.extended(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final TabController tabController =
                                DefaultTabController.of(newContext);
                            if (tabController.index == 0) {
                              await controller
                                  .getTeachersAttendancesReportByDay();
                            } else if (tabController.index == 1) {
                              await controller
                                  .getTeachersAttendancesReportByMonth();
                            }
                          },
                    label: Text(
                      "عـرض الـتـقـريـر",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(
                      Icons.document_scanner_outlined,
                      color: Colors.black,
                    ),
                    backgroundColor: const Color.fromARGB(255, 63, 181, 108),
                  ));
            },
          ),
        ),
        appBar: AppBar(
          title: const Text('تقرير الحضور المعلمين'),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'بحث باليوم'),
              Tab(text: 'بحث بالشهر'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDaySearch(context),
            _buildMonthSearch(context),
          ],
        ),
      ),
    );
  }

  // Day Search Tab
  Widget _buildDaySearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildHijriDatePicker(context, "الشهر:"),
            ),
          ),
          const Divider(),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingDayIndicator();
            } else if (controller
                .filteredTeachersAttendancesForReportByDay.isEmpty) {
              return _buildEmptyDataIndicator();
            } else {
              return Expanded(
                  child: ListView.builder(
                itemCount:
                    controller.filteredTeachersAttendancesForReportByDay.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: _buildDayAttendanceCard(
                      context,
                      controller
                          .filteredTeachersAttendancesForReportByDay[index],
                    ),
                  );
                },
              ));
            }
          }),
        ],
      ),
    );
  }

  Widget _buildMonthAttendanceCard(
      BuildContext context, TeacherAttendanceForMonthReport teacher) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            const SizedBox(height: 16),

            // Attendance Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Excused Absences
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "بعذر",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${teacher.isExcuseNo}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                // Present
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "حاضر",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${teacher.signatureNo}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDayAttendanceCard(
      BuildContext context, TeacherAttendanceForDayReport teacher) {
    var key = teacher.signature == true
        ? 'حاضر'
        : teacher.isExcuse == true
            ? 'بعذر'
            : 'غائب';

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: key == "حاضر"
                        ? Colors.green
                        : key == "بعذر"
                            ? Colors.orange[200]
                            : Colors.redAccent[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    key == "حاضر"
                        ? Icons.check_circle
                        : key == "بعذر"
                            ? Icons.warning_amber_rounded
                            : Icons.cancel_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Attendance Options Row
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDayIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Center(
              child: Text(
                " جاري تحميل تقرير حضور المعلمين\n ليوم ${controller.selectedDate.value.jhijri!.day} لشهر ${controller.selectedDate.value.jhijri!.monthName}",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMonthIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Center(
              child: Text(
                " جاري تحميل تقرير حضور المعلمين\n لشهر ${controller.selectedDate.value.jhijri!.monthName}",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
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

  // Month Search Tab
  Widget _buildMonthSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Divider(),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingMonthIndicator();
            } else if (controller
                .filteredTeachersAttendancesForReportByMonth.isEmpty) {
              return _buildEmptyDataIndicator();
            } else {
              return Expanded(
                  child: ListView.builder(
                itemCount: controller
                    .filteredTeachersAttendancesForReportByMonth.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: _buildMonthAttendanceCard(
                      context,
                      controller
                          .filteredTeachersAttendancesForReportByMonth[index],
                    ),
                  );
                },
              ));
            }
          }),
        ],
      ),
    );
  }

  // Hijri Date Picker for Day Search
  Widget _buildHijriDatePicker(BuildContext context, String label) {
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
          onPressed: () => _selectHijriDayDate(context),
          icon: const Icon(Icons.calendar_month, size: 28),
          color: const Color(0xFF3FB56C),
        ),
      ],
    );
  }

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
                    "${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
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
          onPressed: () => _selectHijriMonthDate(context),
          icon: const Icon(Icons.calendar_month, size: 28),
          color: const Color(0xFF3FB56C),
        ),
      ],
    );
  }

  Future<void> _selectHijriDayDate(BuildContext context) async {
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
      await controller.getTeachersAttendancesReportByDay();
    }
  }

  Future<void> _selectHijriMonthDate(BuildContext context) async {
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
      await controller.getTeachersAttendancesReportByMonth();
    }
  }

  // Hijri Month Picker for Month Search
}
