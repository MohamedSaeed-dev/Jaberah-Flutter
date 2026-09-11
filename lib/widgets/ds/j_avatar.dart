import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// أفاتار دائري يعرض أول حرف من الاسم فوق سطح ناعم.
///
/// اللون مشتق من الاسم نفسه، فيبقى لون الطالب أو المعلم ثابتاً في كل الشاشات.
class JAvatar extends StatelessWidget {
  const JAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.ring = true,
  });

  final String name;
  final double size;

  /// حلقة رفيعة حول الأفاتار كما في لوحة الأفاتار.
  final bool ring;

  /// أول حرف ذي معنى من الاسم (يتخطى المسافات و«ال» التعريف المفردة).
  static String initialOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '؟';
    return trimmed.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = AppColors.avatarPalette(name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: ring
            ? Border.all(color: foreground.withValues(alpha: 0.18), width: 1.2)
            : null,
      ),
      child: Text(
        initialOf(name),
        style: AppText.displayXSmall.copyWith(
          color: foreground,
          fontSize: size * 0.42,
          height: 1,
        ),
      ),
    );
  }
}
