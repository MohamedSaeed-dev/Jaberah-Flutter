import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhijri_picker/_src/_src.dart';

import 'hijri_year_only_picker_controller.dart';

/// حوار شبكة السنوات الهجرية فقط (مكوّن [JYearPicker]) مع GetX.
class HijriYearOnlyPickerDialog extends StatelessWidget {
  const HijriYearOnlyPickerDialog({
    super.key,
    required this.tag,
    required this.onConfirm,
  });

  final String tag;
  final ValueChanged<int> onConfirm;

  static Future<void> show(
    BuildContext context, {
    required int initialYear,
    required ValueChanged<int> onConfirm,
  }) async {
    final tag = 'HijriYearPicker_${DateTime.now().microsecondsSinceEpoch}';
    Get.put(HijriYearOnlyPickerController(initialYear), tag: tag);
    await showDialog<void>(
      context: context,
      builder: (ctx) => HijriYearOnlyPickerDialog(
        tag: tag,
        onConfirm: onConfirm,
      ),
    );
    if (Get.isRegistered<HijriYearOnlyPickerController>(tag: tag)) {
      Get.delete<HijriYearOnlyPickerController>(tag: tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HijriYearOnlyPickerController>(tag: tag);

    return AlertDialog(
      title: const Text('اختر السنة الهجرية'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.42,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF3FB56C),
                ),
          ),
          child: Obx(() => JYearPicker(
                firstDate: c.firstDate,
                lastDate: c.lastDate,
                selectedDate: c.selectedHijri.value,
                initialDate: c.selectedHijri.value,
                onChanged: c.onYearSelected,
              )),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            onConfirm(c.selectedHijri.value.year);
            Navigator.of(context).pop();
          },
          child: const Text(
            'تأكيد',
            style: TextStyle(
              color: Color(0xFF3FB56C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
