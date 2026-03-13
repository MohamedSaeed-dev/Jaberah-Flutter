import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/mySalaryController.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jhijri/jHijri.dart';

class MySalary extends StatelessWidget {
  final MySalaryController controller = Get.put(MySalaryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'راتبي',
          style: TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'السنة الهجرية:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Obx(() => Text(
                          controller.yearName.value,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    IconButton(
                      onPressed: () => _showYearPicker(context),
                      icon: const Icon(Icons.calendar_month, size: 28),
                      color: const Color(0xFF3FB56C),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text("جاري تحميل الرواتب...", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }
                if (controller.salariesForYear.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payments_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text("لا توجد رواتب مسجّلة لهذه السنة", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.salariesByMonth.length,
                  itemBuilder: (context, index) {
                    final block = controller.salariesByMonth[index];
                    final items = block['items'] as List<MySalaryItem>;
                    final first = items.first;
                    final monthLabel = controller.monthNameByValue(first.month);
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$monthLabel ${first.year} هـ',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3FB56C),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...items.map((item) => _buildSalaryRow(context, item)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryRow(BuildContext context, MySalaryItem item) {
    final isPaid = item.isPaid;
    final paidAtStr = item.paidAt != null ? _formatPaidAt(item.paidAt!) : null;
    final isMarking = controller.markingReceivedId.value == item.id.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.groupName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFF3FB56C).withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPaid ? const Color(0xFF3FB56C) : Colors.orange,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  isPaid ? 'تم الاستلام' : 'لم يُستلم',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? const Color(0xFF3FB56C) : Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'الراتب: ${item.salary != null ? '${item.salary!.toStringAsFixed(0)} ريال يمني' : '—'}',
            style: const TextStyle(fontSize: 15),
          ),
          if (isPaid && paidAtStr != null) ...[
            const SizedBox(height: 4),
            Text(
              'تاريخ الاستلام: $paidAtStr',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
          if (!isPaid) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isMarking
                    ? null
                    : () => controller.confirmSalaryReceipt(item.id),
                icon: isMarking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.fingerprint, size: 22),
                label: Text(isMarking ? 'جاري التسجيل...' : 'تأكيد الاستلام (بصمة / زر)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FB56C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPaidAt(DateTime dateTime) {
    final h = JHijri(fDate: dateTime);
    final time24 =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final time12 = formatTime12(time24) ?? time24;
    return '${h.day} ${h.monthName} ${h.year} هـ — $time12';
  }

  void _showYearPicker(BuildContext context) {
    final currentYear = JHijri.now().year;
    final years = List.generate(5, (i) => currentYear - 2 + i);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("اختر السنة الهجرية"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: years.length,
              itemBuilder: (context, index) {
                final y = years[index];
                return ListTile(
                  title: Text('$y هـ'),
                  onTap: () {
                    controller.setYear(y);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
