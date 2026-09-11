import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_button.dart';
import 'j_motif.dart';

/// حالة التحميل الموحّدة: نجمة نابضة ونص تحته.
///
/// تحل محل `CircularProgressIndicator` العاري المكرّر في الشاشات.
class JLoadingState extends StatelessWidget {
  const JLoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 36,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppText.bodyMedium.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// حالة القائمة الفارغة: نجمة ثمانية داخل دائرة ناعمة، عنوان، وشرح، وإجراء.
class JEmptyState extends StatelessWidget {
  const JEmptyState({
    super.key,
    this.title = 'لا توجد بيانات',
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: icon == null
                  ? const JStar(size: 40, color: AppColors.primarySoft)
                  : Icon(icon, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.displaySmall,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              JButton.soft(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
