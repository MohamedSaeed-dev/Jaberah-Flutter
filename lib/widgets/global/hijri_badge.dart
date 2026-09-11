import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

/// بطاقة الترحيب أعلى الشاشات الرئيسية: شارة التاريخ الهجري لليوم،
/// وسطر التحية، واسم المسجد.
class JTodayCard extends StatelessWidget {
  const JTodayCard({super.key, required this.greeting, this.caption});

  /// سطر التحية (مثل: «السلام عليكم، الشيخ عبدالله»).
  final String greeting;

  /// سطر ثانوي تحت التحية.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    // setLocal تضبط لغة أسماء الأشهر (ثابتة على مستوى الصنف) ثم نقرأ تاريخ اليوم.
    HijriCalendar.setLocal('ar');
    final today = HijriCalendar.now();

    return JCard(
      color: AppColors.primaryTint,
      borderColor: AppColors.primarySoft,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _HijriBadge(
            day: today.hDay,
            monthName: _monthName(today),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: AppText.displayXSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    style: AppText.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// اسم الشهر الهجري بالعربية؛ يقع على رقم الشهر إن تعذّر جلب الاسم.
  static String _monthName(HijriCalendar today) {
    try {
      final name = today.getLongMonthName();
      if (name.trim().isNotEmpty) return name;
    } catch (_) {
      // الحزمة ترمي حين لا يوجد اسم للشهر في اللغة المضبوطة؛ الرقم بديل آمن.
    }
    return 'شهر ${today.hMonth}';
  }
}

class _HijriBadge extends StatelessWidget {
  const _HijriBadge({required this.day, required this.monthName});

  final int day;
  final String monthName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            monthName,
            style: AppText.overline.copyWith(
              color: AppColors.goldSoft,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$day',
            style: AppText.metricSmall.copyWith(color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }
}
