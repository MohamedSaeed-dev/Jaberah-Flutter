import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';

/// نغمة لونية موحّدة للمكوّنات (شرائح، أشرطة تقدّم، حاويات أيقونات، أزرار).
///
/// بدل تمرير ثلاثة ألوان لكل مكوّن، يمرَّر [JTone] واحد فيشتق منه
/// اللون القوي والسطح الناعم ولون النص.
enum JTone {
  /// الأخضر الزمردي — الحالة الأساسية والإيجابية.
  primary,

  /// الذهب العتيق — التمييز والتنبيه اللطيف.
  gold,

  /// الأحمر الطيني — الحذف والخطأ والغياب.
  danger,

  /// محايد قماشي — الحالات الساكنة.
  neutral;

  /// اللون القوي: تعبئة الأزرار والشرائح المحددة وأشرطة التقدّم.
  Color get solid => switch (this) {
        JTone.primary => AppColors.primary,
        JTone.gold => AppColors.gold,
        JTone.danger => AppColors.danger,
        JTone.neutral => AppColors.inkMuted,
      };

  /// السطح الناعم: خلفية الشرائح وحاويات الأيقونات.
  Color get soft => switch (this) {
        JTone.primary => AppColors.primarySoft,
        JTone.gold => AppColors.goldSoft,
        JTone.danger => AppColors.dangerSoft,
        JTone.neutral => AppColors.bgSunken,
      };

  /// أخف درجة من السطح الناعم.
  Color get tint => switch (this) {
        JTone.primary => AppColors.primaryTint,
        JTone.gold => AppColors.goldSoft,
        JTone.danger => AppColors.dangerSoft,
        JTone.neutral => AppColors.bgSunken,
      };

  /// لون النص فوق السطح الناعم — يحافظ على تباين مقروء.
  Color get onSoft => switch (this) {
        JTone.primary => AppColors.primaryDark,
        JTone.gold => AppColors.goldDark,
        JTone.danger => AppColors.danger,
        JTone.neutral => AppColors.ink,
      };

  /// لون النص فوق اللون القوي.
  Color get onSolid => AppColors.onPrimary;
}

/// يستنبط نغمة الحلقة من نوع منهجها (حفظ / تجويد / مراجعة / تأسيس)
/// كما في لوحة الشرائح في نظام التصميم.
JTone toneForTrack(String? track) {
  final value = (track ?? '').trim();
  if (value.contains('تجويد') || value.contains('متميز')) return JTone.gold;
  if (value.contains('تأسيس')) return JTone.danger;
  if (value.contains('حفظ') ||
      value.contains('مراجعة') ||
      value.contains('نشط')) {
    return JTone.primary;
  }
  return JTone.neutral;
}

/// يشتق نغمة من نسبة مئوية: مرتفعة خضراء، متوسطة ذهبية، منخفضة حمراء.
JTone toneForRatio(double ratio) {
  if (ratio >= 0.75) return JTone.primary;
  if (ratio >= 0.45) return JTone.gold;
  return JTone.danger;
}
