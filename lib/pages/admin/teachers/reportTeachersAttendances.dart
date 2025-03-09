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
              return Obx(()=> FloatingActionButton.extended(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                      final TabController tabController =
                          DefaultTabController.of(newContext);
                      if (tabController.index == 0) {
                        await controller.getTeachersAttendancesReportByDay();
                      } else if (tabController.index == 1) {
                        await controller.getTeachersAttendancesReportByMonth();
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
          title: const Text('تقرير الحضور للمعلمين'),
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
          Obx(
            () => _buildHijriDatePicker(context, 'التاريخ الهجري:'),
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
    return SizedBox(
      height: 130,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: Colors.indigo[300], // Card shadow color
        color: Colors.indigo[50], // Card background color
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text("حاضر : ${teacher.signatureNo}"),
              Text("غائب بعذر : ${teacher.isExcuseNo}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayAttendanceCard(
      BuildContext context, TeacherAttendanceForDayReport teacher) {
    var key = teacher.signature != null && teacher.signature as bool
        ? 'حاضر'
        : teacher.isExcuse != null && teacher.isExcuse as bool
            ? 'غائب بعذر'
            : 'غائب';
    return SizedBox(
      height: 130,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: Colors.indigo[300], // Card shadow color
        color: Colors.indigo[50], // Card background color
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(key),
            ],
          ),
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
          Obx(
            () => _buildHijriMonthDatePicker(context, 'التاريخ الهجري:'),
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
              "${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
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
      await controller.getTeachersAttendancesReportByDay();
    }
  }

  // Hijri Month Picker for Month Search
}
