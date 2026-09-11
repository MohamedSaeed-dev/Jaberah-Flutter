import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_tone.dart';

/// شريحة حالة (حفظ · تجويد · مراجعة · تأسيس · نشط · متميز).
///
/// ممتلئة باللون القوي حين [solid]، وإلا فسطح ناعم بنص داكن من النغمة نفسها.
class JChip extends StatelessWidget {
  const JChip({
    super.key,
    required this.label,
    this.tone = JTone.primary,
    this.solid = false,
    this.icon,
    this.compact = false,
  });

  /// شريحة مشتقة من نوع منهج الحلقة (حفظ / تجويد / مراجعة / تأسيس).
  JChip.track(String track, {super.key, this.solid = false, this.compact = false})
      : label = track,
        tone = toneForTrack(track),
        icon = null;

  final String label;
  final JTone tone;
  final bool solid;
  final IconData? icon;

  /// نسخة أضيق للاستعمال داخل صفوف مزدحمة.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = solid ? tone.onSolid : tone.onSoft;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: compact ? 3 : AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: solid ? tone.solid : tone.soft,
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: foreground),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: (compact ? AppText.overline : AppText.captionStrong).copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// صف شرائح ترشيح أفقي (الكل · حفظ · تجويد · مراجعة · تأسيس).
class JFilterChips extends StatelessWidget {
  const JFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return _FilterChip(
            label: labels[index],
            selected: selected,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.primaryTint,
      borderRadius: AppRadii.pillAll,
      child: InkWell(
        borderRadius: AppRadii.pillAll,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.pillAll,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.primarySoft,
            ),
          ),
          child: Text(
            label,
            style: AppText.captionStrong.copyWith(
              color: selected ? AppColors.onPrimary : AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
