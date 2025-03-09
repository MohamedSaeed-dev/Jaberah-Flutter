import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/teachersSalariesController.dart';
import 'package:jhijri/_src/_jHijri.dart';

class TeachersSalaries extends StatelessWidget {
  final TeachersSalariesController controller =
      Get.put(TeachersSalariesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              controller.selectedMonth.value = JHijri.now().month;
              controller.monthName.value = JHijri.now().monthName;
              controller.entries.clear();
              await controller.getTeachersSalaries();
            },
            icon: const Icon(
              Icons.refresh_outlined,
              color: Colors.black,
            ),
          ),
        ],
        title: const Text(
          'رواتب المعلمين',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 63, 181, 108).withOpacity(0.2),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Obx(() => DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down,
                        color: const Color.fromARGB(255, 63, 181, 108)),
                    hint: Text(
                      'اختر شهرًا',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    value: controller.selectedMonth.value,
                    items: controller.hijriMonths.map((month) {
                      return DropdownMenuItem<int>(
                        value: month['value'],
                        child: Text(
                          month['month'],
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) async {
                      if (newValue != null &&
                          newValue != controller.selectedMonth.value) {
                        controller.selectedMonth.value = newValue;
                        controller.monthName.value = controller.hijriMonths
                            .firstWhere(
                                (month) => month['value'] == newValue)['month'];
                        controller.entries.clear();
                        await controller.getTeachersSalaries();
                      }
                    },
                  )),
            ),
          ),
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
            child: _buildSalaryCard(
                context,
                salaryData),
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
            _buildDetailRow('استلم المبلغ؟', salaryData.signature ? 'نعم' : 'لا'),
            ElevatedButton(
              onPressed: () =>
                  _editSalary(context, salaryData),
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'الراتب', border: OutlineInputBorder()),
                ),
                Row(
                  children: [
                    Text("استلم المبلغ؟"),
                    Obx(() => Checkbox(
                          value: controller.currentSignature.value,
                          onChanged: (value) {
                            controller.currentSignature.value = value!;
                          },
                        )),
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
              child: Obx(()=> Text(controller.isLoading.value ? 'جاري الحفظ...' : 'حفظ')),
            ),
          ],
        );
      },
    );
  }
}
