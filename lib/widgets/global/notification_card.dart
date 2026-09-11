import 'package:flutter/material.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

/// بطاقة إشعار: أيقونة ناعمة، العنوان والنص، ثم التاريخ الهجري وزر حذف اختياري.
///
/// تستقبل نصوصاً لا نموذجاً، لأن شاشتي الإدارة والمعلّم تستعملان نموذجين
/// مختلفين للإشعار.
class JNotificationCard extends StatelessWidget {
  const JNotificationCard({
    super.key,
    required this.title,
    required this.body,
    required this.hijriDate,
    required this.hijriTime,
    this.onDelete,
  });

  final String title;
  final String body;
  final String hijriDate;
  final String hijriTime;

  /// يظهر زر الحذف حين يُمرَّر.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return JCard(
      radius: AppRadii.lg,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const JIconBadge(
                icon: Icons.notifications_active_outlined,
                tone: JTone.gold,
                size: 42,
                iconSize: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppText.displayXSmall),
                    const SizedBox(height: 2),
                    Text(body, style: AppText.bodyMedium),
                  ],
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: AppSpacing.xxs),
                JIconAction(
                  icon: Icons.delete_outline_rounded,
                  tone: JTone.danger,
                  tooltip: 'حذف',
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.event_outlined,
                size: 14,
                color: AppColors.inkFaint,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(hijriDate, style: AppText.captionStrong),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.inkFaint,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  hijriTime,
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
