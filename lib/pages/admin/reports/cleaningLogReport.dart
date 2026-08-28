import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/cleaningLogReportController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

const _primaryColor = Color.fromARGB(255, 63, 181, 108);

class CleaningLogReportPage extends StatelessWidget {
  final CleaningLogReportController controller =
      Get.put(CleaningLogReportController());

  CleaningLogReportPage({super.key});

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
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          await controller.getDailyReport();
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
                  backgroundColor: _primaryColor,
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
                      controller.report.value.rows.isEmpty)
                  ? null
                  : () async {
                      controller.exportAsPDF(
                        "تقرير كشف النظافة - ${controller.selectedGroupName.value} - ${controller.hijriDateLabel}",
                      );
                    },
              icon: const Icon(Icons.save, color: Colors.black),
            ),
          ),
        ],
        title: const Text(
          'تقرير كشف النظافة',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
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
              if (controller.report.value.rows.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildSummaryCard(controller.report.value);
            }),
            const Divider(),
            Obx(() {
              if (controller.isLoading.value) {
                return Expanded(child: _buildLoadingIndicator());
              }
              if (controller.report.value.rows.isEmpty) {
                return _buildEmptyDataIndicator();
              }
              return Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    ...controller.report.value.rows
                        .map((row) => _buildRowCard(row)),
                    if (controller.report.value.unassignedTasks.isNotEmpty)
                      _buildUnassignedCard(),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CleaningLogDailyReport report) {
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
            _buildSummaryItem('المهمات', '${report.totalTasks}'),
            _buildSummaryItem('المسندة', '${report.assignedCount}'),
            _buildSummaryItem('المنجزة', '${report.completedCount}'),
            _buildSummaryItem('لم تنجز', '${report.notCompletedCount}'),
            _buildSummaryItem('الإنجاز', '${report.completionPercentage}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
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
              "جاري تحميل تقرير كشف النظافة ليوم ${controller.hijriDateLabel}\nلـ ${controller.selectedGroupName.value}",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDataIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty),
            const SizedBox(height: 10),
            Obx(() => Text(
                  controller.hasLoadedOnce.value
                      ? "لاتوجد بيانات"
                      : "اختر التاريخ والحلقة ثم اعرض التقرير",
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                )),
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
      primaryColor: _primaryColor,
      backgroundColor: Colors.white,
      cancelButtonText: "إلغاء",
      okButtonText: "تأكيد",
      selectedDate: controller.selectedDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedDate.value.jhijri) {
      controller.selectedDate.value =
          JDateModel(jhijri: picked.jhijri, dateTime: picked.date);
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
              controller.hijriDateLabel,
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
            child: DropdownButton<int?>(
              isExpanded: true,
              value: controller.selectedGroupId.value,
              hint: const Text('كل الحلقات'),
              onChanged: (value) => controller.setGroupFilter(value),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('كل الحلقات')),
                ...controller.groups.map((group) => DropdownMenuItem<int?>(
                      value: group.id,
                      child: Text(group.name),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowCard(CleaningLogReportRow row) {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.studentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  row.isCompleted ? Icons.check_circle : Icons.cancel,
                  color: row.isCompleted ? _primaryColor : Colors.red,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              row.groupName ?? '-',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Divider(),
            _buildRowItem('نوع النظافة:', row.taskName),
            _buildRowItem('أنجزت:', row.isCompleted ? 'نعم' : 'لا'),
            if (row.notes != null && row.notes!.isNotEmpty)
              _buildRowItem('ملاحظات:', row.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String label, String value) {
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
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnassignedCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_outlined,
                    size: 20, color: Colors.orange),
                SizedBox(width: 6),
                Text(
                  'مهام غير مسندة اليوم',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: controller.report.value.unassignedTasks
                  .map((task) => Chip(
                        label: Text(
                          task.nameAr,
                          style: const TextStyle(fontSize: 12),
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
