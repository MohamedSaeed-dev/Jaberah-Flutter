import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

/// شريط تنبيه بلغة نظام التصميم: سطح داكن، حافة مستديرة، أيقونة بنغمة الحالة.
///
/// كانت كل دالة هنا تبني ألوانها بنفسها (أخضر/أحمر مادي بشفافية)؛ صارت كلها
/// تمر من [_snack] فتبقى منسجمة مع بقية الواجهة.
SnackbarController _snack({
  required String title,
  String? message,
  required IconData icon,
  required JTone tone,
}) {
  return Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.primaryDark,
    colorText: AppColors.onPrimary,
    margin: const EdgeInsets.all(AppSpacing.md),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    borderRadius: AppRadii.md,
    duration: const Duration(seconds: 3),
    isDismissible: true,
    titleText: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tone.solid,
            borderRadius: AppRadii.smAll,
          ),
          child: Icon(icon, size: 18, color: tone.onSolid),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: AppText.bodyLarge.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
    messageText: message == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Text(
              message,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
  );
}

SnackbarController successSnackBar(String message) {
  return _snack(
    title: message,
    icon: Icons.check_rounded,
    tone: JTone.primary,
  );
}

SnackbarController catchSnackBar() {
  return _snack(
    title: 'حدث خطأ ما',
    message: 'الرجاء المحاولة مرة أخرى',
    icon: Icons.error_outline_rounded,
    tone: JTone.danger,
  );
}

SnackbarController messageSnackBar(String message,
    {String title = 'حدث خطأ ما'}) {
  return _snack(
    title: title,
    message: message,
    icon: Icons.error_outline_rounded,
    tone: JTone.danger,
  );
}

SnackbarController socketSnackBar() {
  return _snack(
    title: 'حدث خطأ في الاتصال بالانترنت',
    message: 'الرجاء التأكد من الاتصال بالانترنت',
    icon: Icons.wifi_off_rounded,
    tone: JTone.danger,
  );
}

SnackbarController timeoutSnackBar() {
  return _snack(
    title: 'حدث خطأ في الخادم',
    message: 'الرجاء المحاولة مرة أخرى',
    icon: Icons.hourglass_disabled_rounded,
    tone: JTone.gold,
  );
}

/// يستخرج رسالة الخطأ من جسم رد الـ API بأمان.
///
/// جسم الرد قد يكون Map (‏`{message}` أو `{validationContent}`) أو نصًا (صفحة
/// خطأ 404 مثلًا) أو null. فهرسة النص بمفتاح نصي ترمي
/// `type 'String' is not a subtype of type 'int' of 'index'`، وإن حدث ذلك داخل
/// كتلة catch فلن يلتقطه أي catch لاحق ويخرج كاستثناء غير معالج.
String apiErrorMessage(dynamic data, {String fallback = 'حدث خطأ'}) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    final validation = data['validationContent'];
    if (validation is List) {
      final messages = validation
          .whereType<Map>()
          .map((item) => item['message'])
          .whereType<String>()
          .where((m) => m.trim().isNotEmpty)
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }
  }
  return fallback;
}
