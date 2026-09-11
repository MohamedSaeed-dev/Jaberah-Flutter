import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/pages/admin/reports/monthlyPartialExamReport.dart';
import 'package:jaberah/pages/admin/reports/monthlyReports.dart';
import 'package:jaberah/pages/admin/reports/cleaningLogReport.dart';
import 'package:jaberah/pages/admin/reports/prayersReport.dart';
import 'package:jaberah/pages/admin/reports/semesterReports.dart';
import 'package:jaberah/pages/admin/teachers/reportTeachersAttendances.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

class Reports extends StatelessWidget {
  const Reports({super.key});

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      title: 'التقارير',
      subtitle: 'أداء مسجد جابرة',
      body: SafeArea(
        top: false,
        child: GridView.count(
          padding: const EdgeInsets.all(AppSpacing.md),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.9,
          children: [
            JStatTile(
              title: 'التقرير الفصلي',
              icon: Icons.calendar_month_outlined,
              unit: 'أداء الفصل الدراسي',
              onTap: () => Get.to(() => SemesterReportPage()),
            ),
            JStatTile(
              title: 'التقرير الشهري',
              icon: Icons.calendar_view_month_outlined,
              tone: JTone.gold,
              unit: 'أداء الشهر',
              onTap: () => Get.to(() => MonthlyReportPage()),
            ),
            JStatTile(
              title: 'كشف الصلوات',
              icon: Icons.mosque_outlined,
              unit: 'متابعة الصلوات',
              onTap: () => Get.to(() => PrayersReportPage()),
            ),
            JStatTile(
              title: 'الاختبارات الجزئية',
              icon: Icons.quiz_outlined,
              tone: JTone.gold,
              unit: 'التقرير الشهري',
              onTap: () => Get.to(() => MonthlyPartialExamReportPage()),
            ),
            JStatTile(
              title: 'حضور المعلمين',
              icon: Icons.how_to_reg_outlined,
              unit: 'سجل الحضور',
              onTap: () => Get.to(() => TeachersAttendanceReport()),
            ),
            JStatTile(
              title: 'كشف النظافة',
              icon: Icons.cleaning_services_outlined,
              tone: JTone.danger,
              unit: 'متابعة النظافة',
              onTap: () => Get.to(() => CleaningLogReportPage()),
            ),
          ],
        ),
      ),
    );
  }
}
