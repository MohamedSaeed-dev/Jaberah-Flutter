import 'package:flutter/widgets.dart';

/// سلّم المسافات (4pt base) كما في نظام التصميم:
/// 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// الهامش الجانبي الموحّد لمحتوى الشاشات.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: md);

  /// حشوة البطاقة القياسية.
  static const EdgeInsets card = EdgeInsets.all(md);
}

/// أنصاف الأقطار (RADII) كما في نظام التصميم: sm · md · lg · xl · pill
class AppRadii {
  const AppRadii._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
