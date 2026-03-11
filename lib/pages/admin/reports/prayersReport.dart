import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/prayersMonthlyReportController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class PrayersReportPage extends StatelessWidget {
  final PrayersMonthlyReportController controller =
      Get.put(PrayersMonthlyReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => FloatingActionButton.extended(
                  onPressed: controller.selectedGroupId.value == 0 ||
                          controller.isLoading.value
                      ? null
                      : () async {
                          await controller.getPrayersMonthlyReport();
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
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        actions: [
          Obx(
            () => IconButton(
              onPressed: (controller.isLoading.value ||
                      controller.prayersReport.value.students.isEmpty)
                  ? null
                  : () async {
                      controller.exportAsPDF(
                        "تقرير كشف الصلوات - ${controller.selectedGroupName.value} - ${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
                      );
                    },
              icon: const Icon(Icons.save, color: Colors.black),
            ),
          ),
        ],
        title: const Text('تقرير كشف الصلوات'),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => _buildHijriDatePicker(context, 'التاريخ الهجري:')),
            const SizedBox(height: 10),
            _buildGroupDropdown(),
            const SizedBox(height: 10),
            Obx(() {
              final report = controller.prayersReport.value;
              if (report.students.isNotEmpty) return _buildSummaryCard(report);
              return const SizedBox.shrink();
            }),
            const Divider(),
            Obx(() {
              if (controller.isLoading.value) {
                return Expanded(child: _buildLoadingIndicator());
              } else if (controller.prayersReport.value.students.isEmpty) {
                return _buildEmptyDataIndicator();
              } else {
                return Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.prayersReport.value.students.length,
                    itemBuilder: (context, index) {
                      return _buildStudentCard(
                        controller.prayersReport.value.students[index],
                      );
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

  Widget _buildSummaryCard(PrayersMonthlyReportResponse report) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Text(
                'إجمالي الصلوات الممكنة للطالب: ${report.totalPossiblePrayersPerStudent}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'متوسط نسبة الالتزام في جماعة: ${(report.averageCommitmentPercentage)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Obx(
            () => Text(
              "جاري تحميل تقرير كشف الصلوات لشهر ${controller.selectedDate.value.jhijri!.monthName}\nلـ ${controller.selectedGroupName.value}",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDataIndicator() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty),
            SizedBox(height: 10),
            Text("لاتوجد بيانات", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
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
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      locale: const Locale("ar", "SA"),
      context: context,
      pickerType: PickerType.JHijri,
      primaryColor: const Color(0xFF1976D2),
      backgroundColor: Colors.white,
      cancelButtonText: "إلغاء",
      okButtonText: "تأكيد",
      selectedDate: controller.selectedDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedDate.value.jhijri) {
      controller.selectedDate.value =
          JDateModel(jhijri: picked.jhijri, dateTime: picked.date);
      controller.updateMonthReportDates();
    }
  }

  Widget _buildHijriDatePicker(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 20),
            Text(
              "${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _selectHijriDate(context),
          icon: const Icon(Icons.calendar_month),
        ),
      ],
    );
  }

  Widget _buildGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () => InputDecorator(
          decoration: const InputDecoration(
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
                final valueMap = value.toString().split(',');
                controller.selectedGroupId.value = int.parse(valueMap[0]);
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
        ),
      ),
    );
  }

  Widget _buildStudentCard(PrayersReportStudent student) {
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
            Text(
              student.studentName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              student.groupName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildSectionTitle('كشف الصلوات'),
            const SizedBox(height: 10),
            _buildStudentRow('عدد الصلوات المصلاة:', '${student.totalPrayed}'),
            _buildStudentRow(
              'نسبة الالتزام بالصلوات:',
              '${(student.totalPrayedPercentage)}%',
            ),
            _buildStudentRow(
                'عدد صلوات الجماعة:', '${student.totalGroupPrayed}'),
            _buildStudentRow(
              'نسبة الالتزام بالجماعة:',
              '${student.groupPercentage}%',
            ),
            _buildStudentRow(
                'عدد الصلوات الفائتة:', '${student.missedPrayers}'),
            _buildStudentRow(
              'نسبة الصلوات الفائتة:',
              '${(student.missedPercentage)}%',
            ),
          ],
        ),
      ),
    );
  }

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
