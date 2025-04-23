import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/teachersSalariesController.dart';

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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      shadowColor: Colors.indigo[300],
      color: Colors.indigo[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('اسم المعلم:', salaryData.teacherName),
            _buildDetailRow('راتب:', salaryData.salary),
            _buildDetailRow('أيام الغياب:', salaryData.daysAbsence),
            _buildDetailRow('الراتب بعد الخصم:', salaryData.netSalary),
            _buildDetailRow(
                'استلم المبلغ؟', salaryData.signature ? 'نعم' : 'لا'),
            ElevatedButton(
              onPressed: () => _editSalary(context, salaryData),
              child: const Text('تعديل'),
            ),
          ],
        ),
      ),
    );
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
    final TextEditingController salaryController =
        TextEditingController(text: salaryData.salary.toString());
    controller.currentSignature.value = salaryData.signature;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تعديل معلومات الراتب لـ ${salaryData.teacherName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: salaryController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'الراتب',
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  children: [
                    const Text("استلم المبلغ؟"),
                    Obx(
                      () => Checkbox(
                        value: controller.currentSignature.value,
                        onChanged: (value) {
                          controller.currentSignature.value = value!;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                await controller.updateTeachersSalaries(
                  salaryData.teacherId.toString(),
                  double.parse(salaryController.text),
                  controller.currentSignature.value,
                );
              },
              child: Obx(() =>
                  Text(controller.isLoading.value ? 'جاري الحفظ...' : 'حفظ')),
            ),
          ],
        );
      },
    );
  }
}
