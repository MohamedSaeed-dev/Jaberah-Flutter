import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/pages/admin/teachers/teachers.dart';
import 'package:jaberah/pages/admin/teachers/teachersAttendances.dart';
import 'package:jaberah/pages/admin/teachers/teachersSalaries.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

class TeachersPanelPage extends StatelessWidget {
  const TeachersPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      title: 'المعلمين',
      subtitle: 'بيانات المعلمين والحضور والرواتب',
      body: SafeArea(
        top: false,
        child: GridView.count(
          padding: const EdgeInsets.all(AppSpacing.md),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.98,
          children: [
            JStatTile(
              title: 'بيانات المعلمين',
              icon: Icons.badge_outlined,
              unit: 'إضافة وتعديل وحذف',
              onTap: () => Get.to(() => Teachers()),
            ),
            JStatTile(
              title: 'الحضور اليومي',
              icon: Icons.schedule_rounded,
              tone: JTone.gold,
              unit: 'تسجيل حضور المعلمين',
              onTap: () => Get.to(() => TeachersAttendancePage()),
            ),
            JStatTile(
              title: 'رواتب المعلمين',
              icon: Icons.payments_outlined,
              unit: 'الرواتب والمستحقات',
              onTap: () => Get.to(() => TeachersSalaries()),
            ),
          ],
        ),
      ),
    );
  }
}
