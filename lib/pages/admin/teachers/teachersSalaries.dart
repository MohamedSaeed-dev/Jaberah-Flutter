import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/teachersSalariesController.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jhijri/jHijri.dart';

class TeachersSalaries extends StatelessWidget {
  final TeachersSalariesController controller =
      Get.put(TeachersSalariesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'رواتب المعلمين',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
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
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingIndicator();
              } else if (controller.teachersSalaries.isEmpty) {
                return _buildEmptyDataIndicator();
              } else {
                return _buildTeachersSalariesList();
              }
            }),
          ],
        ),
      ),
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
                    "${controller.monthName.value} (${controller.selectedMonth.value})",
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
          onPressed: () => _showMonthDialog(context),
          icon: const Icon(Icons.calendar_month, size: 28),
          color: const Color(0xFF3FB56C),
        ),
      ],
    );
  }

  // Opens a dialog to display and select Hijri months.
  void _showMonthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("اختر الشهر"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.hijriMonths.length,
              itemBuilder: (context, index) {
                var monthData = controller.hijriMonths[index];
                return ListTile(
                  title: Text(monthData["month"]),
                  onTap: () async {
                    controller.selectedMonth.value = monthData["value"];
                    controller.monthName.value = monthData["month"];
                    controller.entries.clear();
                    await controller.getTeachersSalaries();
                    Navigator.of(context).pop(); // close the dialog
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            Text(
              "جاري تحميل رواتب المعلمين...",
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

  Widget _buildTeachersSalariesList() {
    return Expanded(
      child: ListView.builder(
        itemCount: controller.teachersSalaries.length,
        itemBuilder: (context, index) {
          final salaryData = controller.teachersSalaries[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: _buildSalaryCard(context, salaryData),
          );
        },
      ),
    );
  }

  Widget _buildSalaryCard(BuildContext context, TeacherSalaries salaryData) {
    final isPaid = salaryData.isPaid;
    final paidAtStr = salaryData.paidAt != null
        ? _formatPaidAt(salaryData.paidAt!)
        : null;

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    salaryData.teacherName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFF3FB56C).withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF3FB56C)
                          : Colors.orange,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    isPaid ? 'مسدّد' : 'غير مسدّد',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isPaid
                          ? const Color(0xFF3FB56C)
                          : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDetailRow('الحلقة:', salaryData.groupName),
            _buildDetailRow(
              'الراتب:',
              salaryData.salary != null
                  ? '${salaryData.salary!.toStringAsFixed(0)} ريال يمني'
                  : '—',
            ),
            if (isPaid && paidAtStr != null)
              _buildDetailRow('تاريخ الاستلام:', paidAtStr),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _editSalary(context, salaryData),
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('تعديل'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3FB56C),
                  side: const BorderSide(color: Color(0xFF3FB56C)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPaidAt(DateTime dateTime) {
    final h = JHijri(fDate: dateTime);
    final time24 = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final time12 = formatTime12(time24) ?? time24;
    return '${h.day} ${h.monthName} ${h.year} هـ — $time12';
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _editSalary(BuildContext context, TeacherSalaries salaryData) {
    final TextEditingController salaryController = TextEditingController(
      text: salaryData.salary?.toStringAsFixed(0) ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تعديل الراتب — ${salaryData.teacherName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (salaryData.groupName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'الحلقة: ${salaryData.groupName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                TextField(
                  controller: salaryController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'الراتب (ريال يمني)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final salary = double.tryParse(salaryController.text);
                if (salary == null || salary < 0) {
                  return;
                }
                await controller.updateTeachersSalaries(
                  salaryData.teacherId.toString(),
                  salaryData.groupId,
                  salary,
                  salaryData.isPaid,
                );
              },
              child: Obx(() => Text(
                  controller.isLoading.value ? 'جاري الحفظ...' : 'حفظ')),
            ),
          ],
        );
      },
    );
  }
}
