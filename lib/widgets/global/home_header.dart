import 'package:flutter/material.dart';
import 'package:jaberah/theme/theme.dart';

/// ترويسة الشاشة الرئيسية: عنوان كبير بخط العناوين وبجانبه البسملة بالذهب،
/// كما في شاشة HOME في نظام التصميم.
class JHomeHeader extends StatelessWidget {
  const JHomeHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(title, style: AppText.displayLarge),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'بسم الله الرحمن الرحيم',
                style: AppText.displaySmall.copyWith(color: AppColors.gold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
