import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_card.dart';
import 'j_tone.dart';

/// بطاقة القائمة الرئيسية: حاوية أيقونة، عنوان بخط العناوين، ثم رقم + وحدة.
///
/// هي «البطاقات الرئيسية» في لوحة TILES & CARDS.
///
/// المحتوى يتقلّص بدل أن يفيض: البطاقة تعيش داخل خلية شبكة ذات ارتفاع ثابت،
/// والعناوين العربية تختلف أطوالها، فيُلفّ النص في [FittedBox] بمقياس تصغير
/// فقط — فلا يظهر شريط الفيضان مهما طال العنوان أو كبّر المستخدم خط النظام.
class JStatTile extends StatelessWidget {
  const JStatTile({
    super.key,
    required this.title,
    required this.icon,
    this.value,
    this.unit,
    this.tone = JTone.primary,
    this.onTap,
  });

  final String title;
  final IconData icon;

  /// الرقم البارز (مثل: 12).
  final String? value;

  /// وحدة الرقم أو وصف مختصر للقسم (مثل: «حلقة نشطة»).
  final String? unit;

  final JTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return JCard(
      onTap: onTap,
      showMotif: true,
      motifColor: tone.solid,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      // البطاقة قد توضع في خلية شبكة (ارتفاع محدود) أو في قائمة رأسية
      // (ارتفاع غير محدود). المرونة تحتاج ارتفاعاً محدوداً، فيُفحص أولاً.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bounded = constraints.hasBoundedHeight;
          final text = _TileText(
            title: title,
            value: value,
            unit: unit,
            tone: tone,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child:
                    JIconBadge(icon: icon, tone: tone, size: 46, iconSize: 24),
              ),
              if (bounded) ...[
                const Spacer(),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.bottomEnd,
                    child: ConstrainedBox(
                      // يمنع FittedBox من تمرير عرض غير محدود إلى النص.
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: text,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.md),
                text,
              ],
            ],
          );
        },
      ),
    );
  }
}

/// كتلة نص البطاقة: العنوان ثم الرقم والوحدة.
class _TileText extends StatelessWidget {
  const _TileText({
    required this.title,
    required this.value,
    required this.unit,
    required this.tone,
  });

  final String title;
  final String? value;
  final String? unit;
  final JTone tone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppText.displayXSmall,
          maxLines: 2,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
        if (value != null || unit != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (value != null)
                Text(
                  value!,
                  style: AppText.metricSmall.copyWith(color: tone.onSoft),
                ),
              if (value != null && unit != null)
                const SizedBox(width: AppSpacing.xxs),
              if (unit != null)
                Flexible(
                  child: Text(
                    unit!,
                    style: AppText.caption,
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// إحصاءة مفردة داخل شريط إحصاءات (رقم فوق تسمية).
class JStat {
  const JStat({required this.value, required this.label, this.tone});

  final String value;
  final String label;
  final JTone? tone;
}

/// شريط إحصاءات أفقي مقسّم بفواصل رأسية — كما في رأس تفاصيل الحلقة وملف الطالب.
class JStatStrip extends StatelessWidget {
  const JStatStrip({
    super.key,
    required this.stats,
    this.background = AppColors.primaryTint,
    this.borderColor = AppColors.primarySoft,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  });

  final List<JStat> stats;
  final Color background;
  final Color borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (var i = 0; i < stats.length; i++) {
      if (i > 0) {
        children.add(Container(width: 1, height: 34, color: borderColor));
      }
      final stat = stats[i];
      children.add(
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  stat.value,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: AppText.metricSmall.copyWith(
                    color: (stat.tone ?? JTone.primary).onSoft,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.label,
                textAlign: TextAlign.center,
                style: AppText.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
