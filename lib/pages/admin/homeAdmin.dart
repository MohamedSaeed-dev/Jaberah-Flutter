import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/notificationsAdminController.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/controllers/admin/userNameController.dart';
import 'package:jaberah/controllers/versionsController.dart';
import 'package:jaberah/pages/admin/groups/groups.dart';
import 'package:jaberah/pages/admin/notificationsAdmin.dart';
import 'package:jaberah/pages/admin/reports/reports.dart';
import 'package:jaberah/pages/admin/students/Panel_Students.dart';
import 'package:jaberah/pages/admin/teachers/Panel_teachers.dart';
import 'package:jaberah/pages/admin/trash.dart';
import 'package:jaberah/pages/exportedReportsPage.dart';
import 'package:jaberah/pages/user/homeUser.dart';
import 'package:jaberah/pages/admin/partialExams/students_partialExams.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:jaberah/widgets/global/app_drawer.dart';
import 'package:jaberah/widgets/global/exit_confirmation.dart';
import 'package:jaberah/widgets/global/hijri_badge.dart';
import 'package:jaberah/widgets/global/home_header.dart';

class HomePageAdmin extends StatelessWidget {
  HomePageAdmin({super.key});

  final AuthController authController = Get.put(AuthController());
  final UserNameController userNameController = Get.put(UserNameController());
  final NotificationsAdminController notificationController =
      Get.put(NotificationsAdminController());
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
        subtitle: 'قسم الإدارة · مسجد جابرة',
        drawer: JAppDrawer(
          items: [
            JDrawerItem(
              icon: Icons.menu_book_rounded,
              label: 'قسم الحلقات',
              onTap: () => Get.off(() => HomePageUser()),
            ),
            JDrawerItem(
              icon: Icons.quiz_outlined,
              label: 'اختبارات الجزئي',
              tone: JTone.gold,
              onTap: () => Get.to(() => StudentsPartialExams()),
            ),
            JDrawerItem(
              icon: Icons.insert_chart_outlined_rounded,
              label: 'التقارير المصدرة',
              onTap: () => Get.to(() => ExportedReportsPage()),
            ),
            JDrawerItem(
              icon: Icons.notifications_none_rounded,
              label: 'الإشعارات',
              tone: JTone.gold,
              onTap: () => Get.to(() => NotificationsAdmin()),
            ),
            JDrawerItem(
              icon: Icons.auto_delete_outlined,
              label: 'سلة المحذوفات',
              tone: JTone.danger,
              onTap: () => Get.to(() => TrashPage()),
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
              // مساحة أسفل القائمة حتى لا يغطّي الزر العائم آخر بطاقة.
              AppSpacing.xxxl + AppSpacing.xxl,
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
              const JSectionHeader(title: 'أقسام الإدارة'),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.98,
                children: [
                  JStatTile(
                    title: 'الحلقات',
                    icon: Icons.hub_outlined,
                    unit: 'إدارة الحلقات والطلاب',
                    onTap: () => Get.to(() => Groups()),
                  ),
                  JStatTile(
                    title: 'المعلمين',
                    icon: Icons.menu_book_rounded,
                    tone: JTone.gold,
                    unit: 'البيانات والحضور والرواتب',
                    onTap: () => Get.to(() => TeachersPanelPage()),
                  ),
                  JStatTile(
                    title: 'الطلاب',
                    icon: Icons.school_outlined,
                    unit: 'بيانات الطلاب',
                    onTap: () => Get.to(() => Panel_Students()),
                  ),
                  JStatTile(
                    title: 'التقارير',
                    icon: Icons.insert_chart_outlined_rounded,
                    tone: JTone.danger,
                    unit: 'تقارير الأداء والحضور',
                    onTap: () => Get.to(() => Reports()),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showNotificationDialog(context),
          icon: const Icon(Icons.notifications_active_outlined),
          label: const Text('إرسال إشعار'),
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

  void _showNotificationDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'إرسال إشعار للمعلمين',
          icon: Icons.notifications_active_outlined,
          confirmLabel: 'إرسال',
          loading: notificationController.isLoading.value,
          loadingLabel: 'جاري الارسال...',
          onConfirm: () {
            if (formKey.currentState!.validate()) {
              notificationController.sendNotification();
            }
          },
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: notificationController.titleController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال عنوان الاشعار';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: notificationController.bodyController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'النص'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
