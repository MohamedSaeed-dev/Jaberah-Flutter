import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_tone.dart';

/// شريط تقدّم مستدير: مسار غائر وتعبئة بلون النغمة.
///
/// [value] بين 0 و 1؛ القيم خارج المدى تُقصّ حتى لا ينكسر الرسم.
class JProgressBar extends StatelessWidget {
  const JProgressBar({
    super.key,
    required this.value,
    this.tone = JTone.primary,
    this.height = 8,
    this.trackColor = AppColors.bgSunken,
  });

  final double value;
  final JTone tone;
  final double height;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: AppRadii.pillAll,
      child: SizedBox(
        height: height,
        child: Stack(
          // بلا StackFit.expand تصل القيود فضفاضة إلى التعبئة فينعدم ارتفاعها
          // ولا يظهر الشريط أصلاً.
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackColor),
            Align(
              // البداية في اتجاه الكتابة: يمين الشاشة في الواجهة العربية.
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: clamped,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tone.solid,
                    borderRadius: AppRadii.pillAll,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// سطر تقدّم كامل: تسمية يمين، نسبة يسار، ثم الشريط تحتهما.
class JProgressRow extends StatelessWidget {
  const JProgressRow({
    super.key,
    required this.value,
    this.label,
    this.trailing,
    this.tone,
  });

  final double value;

  /// نص على جهة البداية (مثل: «١٢ طالب»).
  final String? label;

  /// نص على جهة النهاية (الافتراضي: النسبة المئوية).
  final String? trailing;

  /// النغمة؛ تُشتق من النسبة إن تُركت فارغة.
  final JTone? tone;

  @override
  Widget build(BuildContext context) {
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final resolved = tone ?? toneForRatio(clamped);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (label != null)
              Expanded(
                child: Text(
                  label!,
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
            Text(
              trailing ?? '${(clamped * 100).round()}٪',
              style: AppText.captionStrong.copyWith(color: resolved.onSoft),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        JProgressBar(value: clamped, tone: resolved),
      ],
    );
  }
}
