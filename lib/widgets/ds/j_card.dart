import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_motif.dart';
import 'j_tone.dart';

/// البطاقة الأساسية: سطح مرتفع، حدّ رفيع بلون الخطوط، ظل دافئ خفيف.
///
/// تُستخدم لكل ما هو «بطاقة» في نظام التصميم بدل [Card] الافتراضية
/// حتى يبقى نصف القطر والحدّ والظل موحّداً في كل الشاشات.
class JCard extends StatelessWidget {
  const JCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.card,
    this.color = AppColors.bgElev,
    this.borderColor = AppColors.line,
    this.radius = AppRadii.xl,
    this.shadows = AppShadows.card,
    this.showMotif = false,
    this.motifColor = AppColors.gold,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final List<BoxShadow> shadows;

  /// نجمة ثمانية خفيفة في الزاوية العليا — كما في بطاقات الشاشة الرئيسية.
  final bool showMotif;
  final Color motifColor;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget content = Padding(padding: padding, child: child);

    if (showMotif) {
      content = Stack(
        children: [
          PositionedDirectional(
            top: AppSpacing.sm,
            start: AppSpacing.sm,
            child: JStar(
              size: 18,
              color: motifColor.withValues(alpha: 0.22),
            ),
          ),
          content,
        ],
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                splashColor: AppColors.primary.withValues(alpha: 0.06),
                highlightColor: AppColors.primary.withValues(alpha: 0.04),
                child: content,
              ),
      ),
    );
  }
}

/// حاوية أيقونة مربّعة بأطراف مستديرة وسطح ناعم — عنصر متكرر في كل البطاقات.
class JIconBadge extends StatelessWidget {
  const JIconBadge({
    super.key,
    required this.icon,
    this.tone = JTone.primary,
    this.size = 52,
    this.iconSize = 26,
    this.filled = false,
  });

  final IconData icon;
  final JTone tone;
  final double size;
  final double iconSize;

  /// تعبئة كاملة باللون القوي بدل السطح الناعم.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? tone.solid : tone.soft,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: filled ? tone.onSolid : tone.onSoft,
      ),
    );
  }
}

/// عنوان قسم: شريط ذهبي رفيع، عنوان بخط العناوين، وإجراء اختياري في الطرف.
class JSectionHeader extends StatelessWidget {
  const JSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(bottom: AppSpacing.sm),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              borderRadius: AppRadii.pillAll,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              title,
              style: AppText.displaySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                textStyle: AppText.captionStrong,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
