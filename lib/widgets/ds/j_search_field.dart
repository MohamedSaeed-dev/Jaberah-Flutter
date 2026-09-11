import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// حقل البحث في نظام التصميم: سطح مرتفع، حدّ رفيع، أيقونة بحث في البداية،
/// وزر ترشيح اختياري في النهاية.
class JSearchField extends StatelessWidget {
  const JSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.onFilterTap,
    this.filterActive = false,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;

  /// زر الترشيح في طرف الحقل؛ يُخفى إن كان فارغاً.
  final VoidCallback? onFilterTap;

  /// يبرز زر الترشيح حين يكون هناك ترشيح مفعّل.
  final bool filterActive;

  final bool enabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        enabled: enabled,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        style: AppText.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: onFilterTap == null
              ? null
              : IconButton(
                  onPressed: onFilterTap,
                  tooltip: 'ترشيح',
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: filterActive
                        ? AppColors.primary
                        : AppColors.inkMuted,
                  ),
                ),
          border: const OutlineInputBorder(
            borderRadius: AppRadii.lgAll,
            borderSide: BorderSide(color: AppColors.line),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.lgAll,
            borderSide: BorderSide(color: AppColors.line),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadii.lgAll,
            borderSide: BorderSide(color: AppColors.primary, width: 1.6),
          ),
        ),
      ),
    );
  }
}

/// شريط تنقّل بين الصفحات: سابق · «المعروض من الإجمالي» · تالي.
class JPaginationBar extends StatelessWidget {
  const JPaginationBar({
    super.key,
    required this.fetchedCount,
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int fetchedCount;
  final int totalCount;

  /// يُمرَّر `null` حين لا توجد صفحة سابقة.
  final VoidCallback? onPrevious;

  /// يُمرَّر `null` حين لا توجد صفحة تالية.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
        color: AppColors.bgElev,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PageButton(
            icon: Icons.chevron_right_rounded,
            onPressed: onPrevious,
            tooltip: 'السابق',
          ),
          Text(
            '$fetchedCount من $totalCount',
            style: AppText.captionStrong,
          ),
          _PageButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onNext,
            tooltip: 'التالي',
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? AppColors.primaryTint : AppColors.bgSunken,
        borderRadius: AppRadii.smAll,
        child: InkWell(
          borderRadius: AppRadii.smAll,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 38,
            child: Icon(
              icon,
              size: 20,
              color: enabled ? AppColors.primary : AppColors.inkFaint,
            ),
          ),
        ),
      ),
    );
  }
}
