import 'package:flutter/material.dart';

/// ألوان نظام تصميم حلقات جابرة.
///
/// القيم مأخوذة حرفياً من لوحة نظام التصميم (PALETTE · الألوان الأساسية):
/// أخضر زمردي عميق، ذهب عتيق، وأسطح قماشية كريمية.
/// لا تُكتب ألوان مباشرة في الشاشات — كل لون يمر من هنا.
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------- الأساسي
  /// emerald · اللون الرئيسي للهوية.
  static const Color primary = Color(0xFF0F5E4E);

  /// 800 · درجة أغمق تُستخدم للتدرجات والنصوص فوق الأسطح الفاتحة.
  static const Color primaryDark = Color(0xFF083E33);

  /// 100 · سطح أخضر ناعم (أزرار ناعمة، شرائح، حاويات أيقونات).
  static const Color primarySoft = Color(0xFFD8E8E1);

  /// 50 · أخف درجة خضراء، للخلفيات الهادئة.
  static const Color primaryTint = Color(0xFFEAF1EC);

  // ------------------------------------------------------------------ الذهب
  /// accent · الذهب العتيق، لون التمييز الثانوي.
  static const Color gold = Color(0xFFB8924A);

  /// 800 · ذهب غامق يُقرأ فوق الأسطح الفاتحة.
  static const Color goldDark = Color(0xFF7D5E2A);

  /// 100 · سطح ذهبي ناعم.
  static const Color goldSoft = Color(0xFFF1E7CF);

  // ------------------------------------------------------------------ تنبيه
  /// alert · الأحمر الطيني للحذف والأخطاء.
  static const Color danger = Color(0xFFA33B2A);

  /// سطح أحمر ناعم مشتق من الأحمر الطيني (للشرائح وحاويات الأيقونات).
  static const Color dangerSoft = Color(0xFFF2E0DB);

  // ------------------------------------------------- الأسطح والمحايدات
  /// bg · خلفية الصفحة القماشية.
  static const Color bg = Color(0xFFF7F2E8);

  /// bg elev · سطح مرتفع (بطاقات، حقول).
  static const Color bgElev = Color(0xFFFDFAF2);

  /// bg sunken · سطح غائر (مسارات التقدم، الحقول الهادئة).
  static const Color bgSunken = Color(0xFFEFE8D8);

  /// line · لون الحدود والفواصل.
  static const Color line = Color(0xFFE6DEC9);

  /// ink · لون النص الأساسي.
  static const Color ink = Color(0xFF1C2A24);

  /// نص ثانوي — حبر مخفف يحافظ على تباين مقروء فوق الأسطح الكريمية.
  static const Color inkMuted = Color(0xFF5E6B64);

  /// نص خافت جداً (تسميات، وحدات).
  static const Color inkFaint = Color(0xFF8A948E);

  /// النص فوق الأسطح الداكنة (الشريط العلوي، الأزرار الممتلئة).
  static const Color onPrimary = Color(0xFFFDFAF2);

  /// لون الظل — حبر بشفافية منخفضة، يبقي الظلال دافئة لا رمادية.
  static const Color shadow = Color(0x141C2A24);

  // ------------------------------------------------------- حالات إضافية
  /// حاضر — يستخدم الأخضر الأساسي.
  static const Color success = primary;

  /// متأخر — يستخدم الذهب.
  static const Color warning = gold;

  // ------------------------------------------------------- لوحة الأفاتار
  /// خلفيات الأفاتار الدوّارة (نفس ترتيب لوحة نظام التصميم).
  static const List<Color> avatarBackgrounds = <Color>[
    primarySoft,
    goldSoft,
    primaryTint,
    dangerSoft,
    Color(0xFFE2EBE6),
  ];

  /// ألوان الحروف داخل الأفاتار، بالترتيب نفسه لخلفياتها.
  static const List<Color> avatarForegrounds = <Color>[
    primaryDark,
    goldDark,
    primary,
    danger,
    primaryDark,
  ];

  /// يختار زوج (خلفية، حرف) ثابتاً لنص معيّن حتى لا يتغير لون الطالب بين الشاشات.
  static (Color background, Color foreground) avatarPalette(String seed) {
    if (seed.isEmpty) {
      return (avatarBackgrounds.first, avatarForegrounds.first);
    }
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    final index = hash % avatarBackgrounds.length;
    return (avatarBackgrounds[index], avatarForegrounds[index]);
  }
}
