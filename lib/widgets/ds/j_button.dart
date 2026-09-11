import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_tone.dart';

/// أنماط الأزرار الأربعة في نظام التصميم:
/// أساسي (أخضر ممتلئ) · ثانوي (ذهبي ممتلئ) · ناعم (سطح فاتح) · شفاف (حدّ فقط).
enum JButtonVariant { primary, secondary, soft, ghost }

/// زر موحّد يغطي الأنماط الأربعة، مع حالة تحميل مدمجة.
///
/// حين [loading] يُعطَّل الضغط ويظهر مؤشّر دائري مكان الأيقونة، فلا تحتاج
/// كل شاشة أن تكتب منطق «جاري الإرسال...» بنفسها.
class JButton extends StatelessWidget {
  const JButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = JButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = true,
    this.tone,
  });

  const JButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = true,
    this.tone,
  }) : variant = JButtonVariant.secondary;

  const JButton.soft({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = true,
    this.tone,
  }) : variant = JButtonVariant.soft;

  const JButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = true,
    this.tone,
  }) : variant = JButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final JButtonVariant variant;
  final IconData? icon;
  final bool loading;

  /// نص يحل محل [label] أثناء التحميل.
  final String? loadingLabel;

  /// يملأ عرض الأب.
  final bool expand;

  /// يتجاوز لون النمط (مثلاً زر أساسي بنغمة الخطر للحذف).
  final JTone? tone;

  @override
  Widget build(BuildContext context) {
    final resolved = tone ?? _defaultTone;
    final (background, foreground, border) = switch (variant) {
      JButtonVariant.primary => (resolved.solid, resolved.onSolid, null),
      JButtonVariant.secondary => (AppColors.gold, AppColors.onPrimary, null),
      JButtonVariant.soft => (resolved.soft, resolved.onSoft, null),
      JButtonVariant.ghost => (
          AppColors.bgElev,
          resolved.onSoft,
          const BorderSide(color: AppColors.line),
        ),
    };

    final enabled = onPressed != null && !loading;
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: foreground),
        if (loading || icon != null) const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            loading ? (loadingLabel ?? label) : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.button.copyWith(color: foreground),
          ),
        ),
      ],
    );

    final button = FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: variant == JButtonVariant.primary
            ? AppColors.primarySoft
            : background.withValues(alpha: 0.6),
        disabledForegroundColor: AppColors.inkFaint,
        elevation: 0,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        side: border,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      ),
      child: child,
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  JTone get _defaultTone => switch (variant) {
        JButtonVariant.secondary => JTone.gold,
        _ => JTone.primary,
      };
}
