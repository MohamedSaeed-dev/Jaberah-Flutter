import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/semesterReportController.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class SemesterReportPage extends StatelessWidget {
  final SemesterReportController controller =
      Get.put(SemesterReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Column(children: [
            SizedBox(
              width: double.infinity,
              child: Obx(()=> FloatingActionButton.extended(
                    onPressed: controller.selectedGroupId.value == 0 || controller.isLoading.value
                        ? null
                        : () async {
                      await controller.getSemesterReport();
                    },
                    label: const Text(
                      "عـرض الـتـقـريـر",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(
                      Icons.document_scanner_outlined,
                      color: Colors.black,
                    ),
                    backgroundColor: const Color.fromARGB(255, 63, 181, 108),
                  )),
            ),
          ]),
        ),
        appBar: AppBar(
          actions: [
            Obx(() => IconButton(
                onPressed: (controller.isLoading.value ||
                        controller.semesterReport.isEmpty)
                    ? null
                    : () async {
                        controller.exportAsPDF(
                            "التقرير الفصلي لـ ${controller.selectedGroupName.value} بين شهري ${controller.selectedFromDate.value.jhijri!.monthName} و ${controller.selectedToDate.value.jhijri!.monthName} - ${controller.selectedToDate.value.jhijri!.year}");
                      },
                icon: Icon(
                  Icons.save,
                  color: Colors.black,
                )))
          ],
          title: const Text('التقارير الفصلية'),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => _buildFromHijriDatePicker(context, 'من تاريخ:'),
              ),
              Obx(
                () => _buildToHijriDatePicker(context, 'إلى تاريخ:'),
              ),
              const SizedBox(height: 10),
              _buildGroupDropdown(),
              const SizedBox(height: 10),
              const Divider(),
              Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingIndicator();
                } else if (controller.semesterReport.isEmpty) {
                  return _buildEmptyDataIndicator();
                } else {
                  return Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.semesterReport.length,
                      itemBuilder: (context, index) {
                        return _buildStudentsCard(
                          controller.semesterReport[index],
                        );
                      },
                    ),
                  );
                }
              }),
            ],
          ),
        ));
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 450,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Center(
              child: Obx(() => Text(
                    " جاري تحميل التقرير الفصلي من شهر ${controller.selectedFromDate.value.jhijri!.monthName} الى شهر ${controller.selectedToDate.value.jhijri!.monthName}\n لـ ${controller.selectedGroupName.value}",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )),
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

  // Builds the date picker for selecting the report date
  Future<void> _selectFromHijriDate(BuildContext context) async {
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
      selectedDate: controller.selectedFromDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedFromDate.value.jhijri) {
      controller.selectedFromDate.value = JDateModel(jhijri: picked.jhijri, dateTime: picked.date);

      final fromDateHijri = picked.jhijri;
      var newToYear = fromDateHijri.year;
      var newToMonth = fromDateHijri.month + 3;

      if (newToMonth > 12) {
        newToYear += 1;
        newToMonth -= 12;
      }

      final maxDayTo = getDaysInAMonth(newToYear, newToMonth);
      final dayTo =
          fromDateHijri.day > maxDayTo ? maxDayTo : fromDateHijri.day;

      final newToDateHijri = JHijri(
        fYear: newToYear,
        fMonth: newToMonth,
        fDay: dayTo,
      );

      controller.selectedToDate.value = JDateModel(
          jhijri: newToDateHijri, dateTime: newToDateHijri.dateTime);
      controller.updateSemesterReportDates();
    }

  }

  Future<void> _selectToHijriDate(BuildContext context) async {
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
      selectedDate: controller.selectedToDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedToDate.value.jhijri) {
      controller.selectedToDate.value = JDateModel(jhijri: picked.jhijri, dateTime: picked.date);

      final toDateHijri = picked.jhijri;
      var newFromYear = toDateHijri.year;
      var newFromMonth = toDateHijri.month - 3;

      if (newFromMonth < 1) {
        newFromYear -= 1;
        newFromMonth += 12;
      }

      final maxDayFrom = getDaysInAMonth(newFromYear, newFromMonth);
      final dayFrom =
          toDateHijri.day > maxDayFrom ? maxDayFrom : toDateHijri.day;

      final newFromDateHijri = JHijri(
        fYear: newFromYear,
        fMonth: newFromMonth,
        fDay: dayFrom,
      );

      controller.selectedFromDate.value = JDateModel(
          jhijri: newFromDateHijri, dateTime: newFromDateHijri.dateTime);
      controller.updateSemesterReportDates();
    }

  }

  Widget _buildFromHijriDatePicker(BuildContext context, String label) {
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
              "${controller.selectedFromDate.value.jhijri!.monthName} - ${controller.selectedFromDate.value.jhijri!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
            onPressed: () => _selectFromHijriDate(context),
            icon: Icon(Icons.calendar_month))
      ],
    );
  }

  Widget _buildToHijriDatePicker(BuildContext context, String label) {
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
              "${controller.selectedToDate.value.jhijri!.monthName} - ${controller.selectedToDate.value.jhijri!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
            onPressed: () => _selectToHijriDate(context),
            icon: Icon(Icons.calendar_month))
      ],
    );
  }

  Widget _buildGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() => InputDecorator(
            decoration: InputDecoration(
              labelText: 'الحلقة',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                value: controller.selectedGroupId.value != 0
                    ? "${controller.selectedGroupId.value},${controller.selectedGroupName.value}"
                    : controller.groups.isNotEmpty
                        ? "${controller.groups[0].id},${controller.groups[0].name}"
                        : null,
                onChanged: (value) {
                  var valueMap = value.toString().split(',');
                  controller.selectedGroupId.value = int.parse( valueMap[0]);
                  controller.selectedGroupName.value = valueMap[1];
                },
                items: controller.groups.map((group) {
                  return DropdownMenuItem(
                    value: '${group.id},${group.name}',
                    child: Text(group.name),
                  );
                }).toList(),
              ),
            ),
          )),
    );
  }

  Widget _buildStudentsCard(SemesterReportModel student) {

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
            Text(student.studentName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Grades and Exams
            _buildSectionTitle('التقييمات'),
            const SizedBox(height: 10),
            _buildStudentRow('درجة الحفظ:', "${student.gradeSum}"),
            _buildStudentRow('الحضور:', "${student.attendanceSum}"),
            _buildStudentRow('السلوك', "${student.behaviorSum}"),
            _buildStudentRow('درجة الشفهي:', "${student.oralGradeSum}"),
            _buildStudentRow('درجة الورقي:', "${student.paperGradeSum}"),
            _buildStudentRow('درجة الامتحان النصفي:', "${student.midFinalGrade}"),

            const Divider(height: 24, thickness: 1),

            // Total Score
            _buildStudentRow(
              'المجموع الكلي:',
              "${student.total}%",
              valueStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Builds each row for student details with custom styling
  Widget _buildStudentRow(String label, String value,
      {TextStyle valueStyle = const TextStyle(fontSize: 14)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

// Section title styling
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }
}
