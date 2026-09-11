import 'package:flutter/material.dart';

import 'app_colors.dart';

/// الخطوط (TYPOGRAPHY) كما في نظام التصميم:
///
/// * Display — Reem Kufi Fun (700 / 600) للعناوين، خط عربي عريض بنقاط ملوّنة.
/// * Body / Caption — IBM Plex Sans Arabic (500 / 400) محايد للنصوص.
/// * Mono — JetBrains Mono (500) للمعرّفات والأوقات والأرقام اللاتينية.
class AppFonts {
  const AppFonts._();

  static const String display = 'ReemKufiFun';
  static const String body = 'IBMPlexSansArabic';
  static const String mono = 'JetBrainsMono';

  /// ترتيب الاحتياط لكل نمط.
  ///
  /// ريم كوفي فن خط عناوين زخرفي لا يغطي كل المحارف (ينقصه ٪ و ﷽)،
  /// و JetBrains Mono لاتيني بحت لا عربية فيه. IBM Plex Sans Arabic يغطي
  /// الاثنين، فيُجعل احتياطاً لهما حتى لا يظهر مربّع فارغ مكان أي محرف.
  static const List<String> fallback = <String>[body];
}

/// أنماط النصوص الجاهزة. الشاشات تستهلك هذه الأنماط بدل بناء [TextStyle] يدوياً.
class AppText {
  const AppText._();

  // ------------------------------------------------------------- العناوين
  /// عنوان الشاشة الكبير (القوائم، العناوين البطلة).
  static const TextStyle displayLarge = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 30,
    height: 1.35,
    color: AppColors.ink,
  );

  /// عنوان قسم بارز.
  static const TextStyle displayMedium = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.35,
    color: AppColors.ink,
  );

  /// عنوان بطاقة أو عنصر قائمة.
  static const TextStyle displaySmall = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.4,
    color: AppColors.ink,
  );

  /// عنوان صغير داخل البطاقات المضغوطة.
  static const TextStyle displayXSmall = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.4,
    color: AppColors.ink,
  );

  /// عنوان الشريط العلوي.
  static const TextStyle appBarTitle = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.3,
    color: AppColors.onPrimary,
  );

  /// السطر التوضيحي تحت عنوان الشريط العلوي.
  static const TextStyle appBarSubtitle = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: Color(0xCCFDFAF2),
  );

  // --------------------------------------------------------------- النصوص
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.6,
    color: AppColors.ink,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.6,
    color: AppColors.ink,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.5,
    color: AppColors.ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
    color: AppColors.inkMuted,
  );

  static const TextStyle captionStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.5,
    color: AppColors.inkMuted,
  );

  /// تسمية صغيرة جداً (وحدات، تذييل الإحصاءات).
  static const TextStyle overline = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.inkFaint,
  );

  /// نص الأزرار.
  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.2,
  );

  // ---------------------------------------------------------------- أرقام
  /// رقم إحصائي كبير (النِسَب والأعداد في البطاقات).
  static const TextStyle metric = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 26,
    height: 1.2,
    color: AppColors.ink,
  );

  /// رقم إحصائي متوسط.
  static const TextStyle metricSmall = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.2,
    color: AppColors.ink,
  );

  /// معرّفات وأوقات لاتينية.
  static const TextStyle mono = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.mono,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.4,
    color: AppColors.inkMuted,
  );

  /// تسمية لاتينية صغيرة بتباعد حروف (كما في عناوين أقسام نظام التصميم).
  static const TextStyle monoLabel = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.mono,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.4,
    letterSpacing: 1.6,
    color: AppColors.inkFaint,
  );
}
