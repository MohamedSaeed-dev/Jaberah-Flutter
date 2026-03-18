import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhijri/jHijri.dart';

import '../hijri_year_only_picker/hijri_year_only_picker_dialog.dart';
import 'hijri_month_only_picker_controller.dart';

typedef HijriMonthConfirmed = void Function(int hijriYear, int hijriMonth);

/// اختيار شهر هجري فقط (سنة + شبكة الأشهر الاثنا عشر) مع GetX.
class HijriMonthOnlyPickerDialog extends StatelessWidget {
  const HijriMonthOnlyPickerDialog({
    super.key,
    required this.tag,
    required this.onConfirm,
  });

  final String tag;
  final HijriMonthConfirmed onConfirm;

  static Future<void> show(
    BuildContext context, {
    required int initialYear,
    required int initialMonth,
    required HijriMonthConfirmed onConfirm,
  }) async {
    final tag = 'HijriMonthPicker_${DateTime.now().microsecondsSinceEpoch}';
    Get.put(
      HijriMonthOnlyPickerController(
        initialYear: initialYear,
        initialMonth: initialMonth,
      ),
      tag: tag,
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => HijriMonthOnlyPickerDialog(
        tag: tag,
        onConfirm: onConfirm,
      ),
    );
    if (Get.isRegistered<HijriMonthOnlyPickerController>(tag: tag)) {
      Get.delete<HijriMonthOnlyPickerController>(tag: tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HijriMonthOnlyPickerController>(tag: tag);
    const primary = Color(0xFF3FB56C);

    final h = MediaQuery.sizeOf(context).height;
    final gridHeight = (h * 0.52).clamp(380.0, 520.0);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      title: const Text(
        'اختر الشهر الهجري',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width.clamp(320.0, 400.0),
        height: gridHeight,
        child: Column(
          children: [
            Obx(() {
              final y = c.selectedYear.value;
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => c.stepYear(-1),
                      icon: const Icon(Icons.chevron_right, size: 28),
                      tooltip: 'السنة السابقة',
                      style: IconButton.styleFrom(
                        foregroundColor: primary,
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await HijriYearOnlyPickerDialog.show(
                              context,
                              initialYear: y,
                              onConfirm: c.setYear,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              '$y هـ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => c.stepYear(1),
                      icon: const Icon(Icons.chevron_left, size: 28),
                      tooltip: 'السنة التالية',
                      style: IconButton.styleFrom(
                        foregroundColor: primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final year = c.selectedYear.value;
                final sel = c.selectedMonth.value;
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final selected = sel == month;
                    final name =
                        JHijri(fYear: year, fMonth: month, fDay: 1).monthName;
                    return Material(
                      elevation: selected ? 4 : 1,
                      shadowColor: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => c.selectMonth(month),
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: selected
                                ? primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? primary
                                  : const Color(0xFFE0E0E0),
                              width: selected ? 2 : 1.2,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Text(
                                name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  height: 1.25,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF1B1B1B),
                                ),
                              ),
                            ),
                          ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            onConfirm(c.selectedYear.value, c.selectedMonth.value);
            Navigator.of(context).pop();
          },
          child: const Text(
            'تأكيد',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
