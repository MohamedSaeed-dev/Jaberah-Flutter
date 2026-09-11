import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_card.dart';
import 'j_tone.dart';

/// بطاقة صفّية: عنصر قيادي (أفاتار أو أيقونة)، عنوان وسطر توضيحي،
/// عنصر في الطرف المقابل، وتذييل اختياري (شريط تقدّم، أزرار، إحصاءات).
///
/// هي الشكل المتكرر في قوائم الحلقات والمعلمين والطلاب.
class JListCard extends StatelessWidget {
  const JListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.footer,
    this.onTap,
    this.titleStyle,
    this.padding = const EdgeInsets.all(AppSpacing.sm + 2),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  /// محتوى يظهر أسفل الصف الأول (شريط تقدّم مثلاً).
  final Widget? footer;

  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return JCard(
      onTap: onTap,
      padding: padding,
      radius: AppRadii.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: titleStyle ?? AppText.displayXSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppText.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing!,
              ],
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// صف «تسمية: قيمة» داخل البطاقات التفصيلية.
class JDetailRow extends StatelessWidget {
  const JDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tone,
    this.maxLines = 2,
  });

  final String label;
  final String value;
  final IconData? icon;
  final JTone? tone;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: (tone ?? JTone.neutral).solid,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: AppText.captionStrong),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: AppText.bodyMedium,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// زرّا التعديل والحذف بالشكل الموحّد في نهاية بطاقات الإدارة.
class JCardActions extends StatelessWidget {
  const JCardActions({
    super.key,
    this.onEdit,
    this.onDelete,
    this.extra = const <Widget>[],
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// أزرار إضافية تُعرض قبل التعديل والحذف.
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...extra,
        if (onEdit != null)
          JIconAction(
            icon: Icons.edit_outlined,
            tone: JTone.primary,
            tooltip: 'تعديل',
            onPressed: onEdit,
          ),
        if (onEdit != null && onDelete != null)
          const SizedBox(width: AppSpacing.xs),
        if (onDelete != null)
          JIconAction(
            icon: Icons.delete_outline_rounded,
            tone: JTone.danger,
            tooltip: 'حذف',
            onPressed: onDelete,
          ),
      ],
    );
  }
}

/// زر أيقونة مربّع بسطح ناعم.
class JIconAction extends StatelessWidget {
  const JIconAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tone = JTone.primary,
    this.tooltip,
    this.size = 38,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final JTone tone;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: tone.soft,
      borderRadius: AppRadii.smAll,
      child: InkWell(
        borderRadius: AppRadii.smAll,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, size: size * 0.5, color: tone.onSoft),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
