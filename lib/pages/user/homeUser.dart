import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/controllers/admin/userNameController.dart';
import 'package:jaberah/controllers/user/notificationsUserController.dart';
import 'package:jaberah/controllers/versionsController.dart';
import 'package:jaberah/pages/user/myAttendances.dart';
import 'package:jaberah/pages/user/mySalary.dart';
import 'package:jaberah/pages/user/dailyPrayers.dart';
import 'package:jaberah/pages/user/cleaningLog.dart';
import 'package:jaberah/pages/user/notificationsUser.dart';
import 'package:jaberah/pages/admin/homeAdmin.dart';
import 'package:jaberah/pages/user/followStudents/groups_followStudents.dart';
import 'package:jaberah/pages/user/reports/StudentsReport.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:jaberah/widgets/global/app_drawer.dart';
import 'package:jaberah/widgets/global/exit_confirmation.dart';
import 'package:jaberah/widgets/global/hijri_badge.dart';
import 'package:jaberah/widgets/global/home_header.dart';

class HomePageUser extends StatelessWidget {
  HomePageUser({super.key});

  final AuthController authController = Get.put(AuthController());
  final UserNameController userNameController = Get.put(UserNameController());
  final VersionsController versionController = Get.find<VersionsController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await confirmExitApp()) {
          exit(0);
        }
      },
      child: JScaffold(
        title: 'حلقات مسجد جابرة',
        subtitle: 'قسم الحلقات · مسجد جابرة',
        actions: [
          if (!authController.isAdmin.value) const NotificationIcon(),
        ],
        drawer: JAppDrawer(
          items: [
            if (authController.isAdmin.value)
              JDrawerItem(
                icon: Icons.admin_panel_settings_outlined,
                label: 'قسم الإدارة',
                onTap: () => Get.off(() => HomePageAdmin()),
              ),
            JDrawerItem(
              icon: Icons.payments_outlined,
              label: 'راتبي',
              tone: JTone.gold,
              onTap: () {
                Get.back();
                Get.to(() => MySalary());
              },
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              const JHomeHeader(title: 'القوائم'),
              const SizedBox(height: AppSpacing.md),
              Obx(
                () => JTodayCard(
                  greeting: _greeting(userNameController.name.value),
                  caption: 'مسجد الجابرة · الرياض',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const JSectionHeader(title: 'مهام اليوم'),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.98,
                children: [
                  JStatTile(
                    title: 'المتابعة اليومية',
                    icon: Icons.fact_check_outlined,
                    unit: 'تسجيل حفظ الطلاب',
                    onTap: () => Get.to(() => GroupsFollowStudents()),
                  ),
                  JStatTile(
                    title: 'تقارير الطلاب',
                    icon: Icons.insert_chart_outlined_rounded,
                    tone: JTone.gold,
                    unit: 'الأداء والتقدّم',
                    onTap: () => Get.to(() => StudentsReport()),
                  ),
                  JStatTile(
                    title: 'حضوري',
                    icon: Icons.fingerprint_rounded,
                    unit: 'تسجيل الحضور والانصراف',
                    onTap: () => Get.to(() => MyAttendances()),
                  ),
                  JStatTile(
                    title: 'كشف الصلوات',
                    icon: Icons.mosque_outlined,
                    tone: JTone.gold,
                    unit: 'متابعة الصلوات',
                    onTap: () => Get.to(() => DailyPrayers()),
                  ),
                  JStatTile(
                    title: 'كشف النظافة',
                    icon: Icons.cleaning_services_outlined,
                    tone: JTone.danger,
                    unit: 'متابعة نظافة المسجد',
                    onTap: () => Get.to(() => CleaningLog()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty
        ? 'السلام عليكم ورحمة الله'
        : 'السلام عليكم، $trimmed';
  }
}

/// زر الإشعارات في الشريط العلوي مع عدّاد غير المقروء.
class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsCountController());

    return Obx(
      () => JAppBarButton(
        icon: Icons.notifications_none_rounded,
        tooltip: 'الإشعارات',
        badgeCount: controller.newNotificationCount.value,
        onPressed: () => Get.to(() => NotificationsUser()),
      ),
    );
  }
}
