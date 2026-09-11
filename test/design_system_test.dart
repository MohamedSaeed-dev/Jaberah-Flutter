import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:jaberah/widgets/global/notification_card.dart';

/// يلفّ الودجت بالسمة واتجاه الكتابة من اليمين إلى اليسار كما في التطبيق.
Widget _app(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: Directionality(textDirection: TextDirection.rtl, child: child),
  );
}

void main() {
  group('رموز نظام التصميم', () {
    test('لوحة الألوان تطابق قيم نظام التصميم', () {
      expect(AppColors.primary, const Color(0xFF0F5E4E));
      expect(AppColors.primaryDark, const Color(0xFF083E33));
      expect(AppColors.primarySoft, const Color(0xFFD8E8E1));
      expect(AppColors.primaryTint, const Color(0xFFEAF1EC));
      expect(AppColors.gold, const Color(0xFFB8924A));
      expect(AppColors.goldDark, const Color(0xFF7D5E2A));
      expect(AppColors.goldSoft, const Color(0xFFF1E7CF));
      expect(AppColors.danger, const Color(0xFFA33B2A));
      expect(AppColors.bg, const Color(0xFFF7F2E8));
      expect(AppColors.bgElev, const Color(0xFFFDFAF2));
      expect(AppColors.bgSunken, const Color(0xFFEFE8D8));
      expect(AppColors.line, const Color(0xFFE6DEC9));
      expect(AppColors.ink, const Color(0xFF1C2A24));
    });

    test('سلّم المسافات على أساس 4 نقاط', () {
      expect(
        [
          AppSpacing.xxs,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xxxl,
        ],
        [4, 8, 12, 16, 20, 24, 32, 40],
      );
    });

    test('السمة تستعمل خطوط نظام التصميم', () {
      final theme = AppTheme.light;
      expect(theme.textTheme.displayLarge!.fontFamily, 'ReemKufiFun');
      expect(theme.textTheme.bodyMedium!.fontFamily, 'IBMPlexSansArabic');
      expect(AppText.mono.fontFamily, 'JetBrainsMono');
      expect(theme.scaffoldBackgroundColor, AppColors.bg);
      expect(theme.colorScheme.primary, AppColors.primary);
    });

    test('لون الأفاتار ثابت لنفس الاسم', () {
      final first = AppColors.avatarPalette('سعد الحربي');
      final second = AppColors.avatarPalette('سعد الحربي');
      expect(first, second);
      expect(AppColors.avatarPalette(''), isNotNull);
    });

    test('النغمة تُشتق من نوع المنهج ومن النسبة', () {
      expect(toneForTrack('حفظ'), JTone.primary);
      expect(toneForTrack('تجويد'), JTone.gold);
      expect(toneForTrack('تأسيس'), JTone.danger);
      expect(toneForTrack(null), JTone.neutral);
      expect(toneForRatio(0.9), JTone.primary);
      expect(toneForRatio(0.5), JTone.gold);
      expect(toneForRatio(0.1), JTone.danger);
    });
  });

  group('مكوّنات نظام التصميم', () {
    testWidgets('الشريط العلوي يعرض العنوان والسطر التوضيحي', (tester) async {
      await tester.pumpWidget(
        _app(
          const JScaffold(
            title: 'الحلقات',
            subtitle: '١٢ حلقة · ١٤٦ طالب',
            body: SizedBox.shrink(),
          ),
        ),
      );
      expect(find.text('الحلقات'), findsOneWidget);
      expect(find.text('١٢ حلقة · ١٤٦ طالب'), findsOneWidget);
      expect(find.byIcon(Icons.mosque_rounded), findsOneWidget);
    });

    testWidgets('شريط التقدّم يقصّ القيم خارج المدى', (tester) async {
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: Column(
              children: [
                JProgressBar(value: 1.8),
                JProgressBar(value: -0.5),
                JProgressBar(value: double.nan),
              ],
            ),
          ),
        ),
      );
      final boxes = tester.widgetList<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(boxes.map((b) => b.widthFactor), [1.0, 0.0, 0.0]);
    });

    testWidgets('الزر يُعطَّل ويعرض نص التحميل أثناء العملية', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: JButton(
              label: 'إرسال',
              loading: true,
              loadingLabel: 'جاري الإرسال...',
              onPressed: () => pressed++,
            ),
          ),
        ),
      );
      expect(find.text('جاري الإرسال...'), findsOneWidget);
      await tester.tap(find.byType(JButton));
      await tester.pump();
      expect(pressed, 0);
    });

    testWidgets('الأفاتار يعرض أول حرف من الاسم', (tester) async {
      await tester.pumpWidget(
        _app(const Scaffold(body: JAvatar(name: 'سعد الحربي'))),
      );
      expect(find.text('س'), findsOneWidget);
      expect(JAvatar.initialOf('   '), '؟');
    });

    testWidgets('شرائح الترشيح تُبلّغ عن الاختيار', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: JFilterChips(
              labels: const ['الكل', 'حفظ', 'تجويد'],
              selectedIndex: 0,
              onSelected: (index) => selected = index,
            ),
          ),
        ),
      );
      await tester.tap(find.text('تجويد'));
      expect(selected, 2);
    });

    testWidgets('شريط الصفحات يختفي حين لا توجد بيانات', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: JPaginationBar(
              fetchedCount: 0,
              totalCount: 0,
              onPrevious: null,
              onNext: null,
            ),
          ),
        ),
      );
      expect(find.text('0 من 0'), findsNothing);
    });

    testWidgets('المكوّنات الأساسية تُبنى بلا استثناءات', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: ListView(
              children: [
                const JStatTile(
                  title: 'الحلقات',
                  icon: Icons.hub_outlined,
                  value: '12',
                  unit: 'حلقة نشطة',
                ),
                const JStatStrip(
                  stats: [
                    JStat(value: '١٢', label: 'طالب'),
                    JStat(value: '٪٧٢', label: 'التقدم'),
                    JStat(value: '٪٩١', label: 'الحضور'),
                  ],
                ),
                JListCard(
                  leading: const JAvatar(name: 'عبدالرحمن'),
                  title: 'حلقة الفجر الأولى',
                  subtitle: 'المعلم: سعد الحربي · بعد الفجر',
                  trailing: JChip.track('حفظ'),
                  footer: const JProgressRow(value: 0.72, label: '12 طالب'),
                ),
                const JNotificationCard(
                  title: 'تذكير بحلقة الفجر',
                  body: 'السلام عليكم، نذكركم بموعد حلقة الفجر اليوم.',
                  hijriDate: '١٧ شوال',
                  hijriTime: '٥:٣٠ ص',
                ),
                const JSectionHeader(title: 'الحلقات القادمة'),
                const JOrnamentDivider(),
                const JEmptyState(title: 'لا توجد بيانات'),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('حلقة الفجر الأولى'), findsOneWidget);
      expect(find.text('72٪'), findsOneWidget);
    });

    testWidgets('الحوار يعرض العنوان والإجراءين', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showJDialog(
                  context: context,
                  dialog: JDialog(
                    title: 'تأكيد الحذف',
                    message: 'هل أنت متأكد أنك تريد حذف هذه الحلقة؟',
                    tone: JTone.danger,
                    confirmLabel: 'حذف',
                    onConfirm: () {},
                  ),
                ),
                child: const Text('افتح'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('افتح'));
      await tester.pumpAndSettle();
      expect(find.text('تأكيد الحذف'), findsOneWidget);
      expect(find.text('حذف'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
    });
  });
}
