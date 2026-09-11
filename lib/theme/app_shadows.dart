import 'package:flutter/widgets.dart';

/// الظلال (ELEVATION) كما في نظام التصميم: card · cardHover · float
///
/// الظلال هنا دافئة لا رمادية — مشتقة من لون الحبر بشفافية منخفضة حتى
/// تبقى منسجمة مع الأسطح القماشية بدل أن تُتّسخ بالرمادي.
class AppShadows {
  const AppShadows._();

  /// shadow/card — البطاقات الساكنة.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F1C2A24),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// shadow/cardHover — البطاقة عند اللمس أو السحب.
  static const List<BoxShadow> cardHover = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A1C2A24),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
  ];

  /// shadow/float — الزر العائم والعناصر المرفوعة فوق المحتوى.
  static const List<BoxShadow> float = <BoxShadow>[
    BoxShadow(
      color: Color(0x2B0F5E4E),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}
