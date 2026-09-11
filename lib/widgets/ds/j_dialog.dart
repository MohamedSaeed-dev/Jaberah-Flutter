import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_button.dart';
import 'j_motif.dart';
import 'j_tone.dart';

/// حوار نظام التصميم: رأس مزخرف بنجمة، عنوان بخط العناوين، محتوى، ثم إجراءان.
///
/// يُبنى بـ[showJDialog] بدل تركيب [AlertDialog] في كل شاشة.
class JDialog extends StatelessWidget {
  const JDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmLabel,
    this.onConfirm,
    this.cancelLabel = 'إلغاء',
    this.onCancel,
    this.tone = JTone.primary,
    this.icon,
    this.loading = false,
    this.loadingLabel,
  });

  final String title;

  /// نص بسيط؛ يُتجاهل حين يُمرَّر [content].
  final String? message;

  /// محتوى مخصّص (نموذج مثلاً).
  final Widget? content;

  final String? confirmLabel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;

  /// نغمة زر التأكيد وحاوية الأيقونة.
  final JTone tone;

  final IconData? icon;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tone.soft,
                      borderRadius: AppRadii.mdAll,
                    ),
                    child: icon == null
                        ? JStar(size: 20, color: tone.onSoft)
                        : Icon(icon, size: 22, color: tone.onSoft),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(title, style: AppText.displaySmall),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (content != null)
                content!
              else if (message != null)
                Text(message!, style: AppText.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: JButton.ghost(
                      label: cancelLabel,
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                  if (confirmLabel != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: JButton(
                        label: confirmLabel!,
                        tone: tone,
                        loading: loading,
                        loadingLabel: loadingLabel,
                        onPressed: onConfirm,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// يعرض [JDialog] ويعيد ما أُغلق به.
Future<T?> showJDialog<T>({
  required BuildContext context,
  required Widget dialog,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: AppColors.ink.withValues(alpha: 0.32),
    builder: (_) => dialog,
  );
}
