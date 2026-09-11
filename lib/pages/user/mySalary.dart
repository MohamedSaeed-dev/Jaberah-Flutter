import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/mySalaryController.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jhijri/jHijri.dart';
import 'package:jaberah/widgets/hijri_year_only_picker/hijri_year_only_picker_dialog.dart';
import 'package:jaberah/theme/theme.dart';

class MySalary extends StatelessWidget {
  final MySalaryController controller = Get.put(MySalaryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'راتبي',
        ),
        backgroundColor: AppColors.primary,
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
              color: AppColors.onPrimary,
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
                      onPressed: () => _openHijriCalendarForYear(context),
                      icon: const Icon(Icons.calendar_month, size: 28),
                      color: AppColors.primary,
                      tooltip: 'تقويم هجري',
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
                        Icon(Icons.payments_outlined, size: 64, color: AppColors.inkFaint),
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
                                color: AppColors.primary,
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
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPaid ? AppColors.primary : AppColors.gold,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  isPaid ? 'تم الاستلام' : 'لم يُستلم',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? AppColors.primary : AppColors.goldDark,
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
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
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
                label: Text(isMarking ? 'جاري التسجيل...' : 'تأكيد الاستلام'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
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

  Future<void> _openHijriCalendarForYear(BuildContext context) async {
    await HijriYearOnlyPickerDialog.show(
      context,
      initialYear: controller.selectedYear.value,
      onConfirm: controller.setYear,
    );
  }
}
