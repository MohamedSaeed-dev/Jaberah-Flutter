import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/userNameController.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/controllers/versionsController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/pages/admin/teachers/profile.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// عنصر واحد في القائمة الجانبية.
class JDrawerItem {
  const JDrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone = JTone.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final JTone tone;
}

/// القائمة الجانبية الموحّدة: ترويسة زمردية بزخرفة النجوم، ثم عناصر التنقّل،
/// ثم تذييل فيه الدعم ورقم الإصدار.
///
/// كانت مكرّرة بين شاشتي الإدارة والمعلّم؛ صارت مكوّناً واحداً يستقبل عناصره.
class JAppDrawer extends StatelessWidget {
  JAppDrawer({super.key, required this.items});

  final List<JDrawerItem> items;

  final AuthController authController = Get.find<AuthController>();
  final UserNameController userNameController = Get.put(UserNameController());
  final VersionsController versionController = Get.find<VersionsController>();

  static const String _supportUrl = 'https://wa.me/+966574195965';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const _DrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
              children: [
                for (final item in items) _DrawerTile(item: item),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: JOrnamentDivider(),
                ),
                _DrawerTile(
                  item: JDrawerItem(
                    icon: Icons.logout_rounded,
                    label: 'تسجيل الخروج',
                    tone: JTone.danger,
                    onTap: _confirmLogout,
                  ),
                ),
              ],
            ),
          ),
          _DrawerFooter(
            versionController: versionController,
            onSupportTap: _openSupport,
          ),
        ],
      ),
    );
  }

  Future<void> _openSupport() async {
    final uri = Uri.parse(_supportUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messageSnackBar('حدث خطأ، اعد المحاولة');
    }
  }

  void _confirmLogout() {
    Get.dialog(
      Obx(
        () => JDialog(
          title: 'تأكيد تسجيل الخروج',
          message: 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
          icon: Icons.logout_rounded,
          tone: JTone.danger,
          confirmLabel: 'تسجيل الخروج',
          loading: authController.isLoadingLogout.value,
          loadingLabel: 'جاري تسجيل الخروج...',
          onConfirm: () async => authController.logout(),
          onCancel: () => Get.back(),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final userNameController = Get.put(UserNameController());
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        border: Border(bottom: BorderSide(color: AppColors.gold, width: 2)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const JBrandMark(size: 54, iconSize: 30),
              const SizedBox(height: AppSpacing.md),
              Text(
                'حلقات مسجد جابرة',
                style: AppText.appBarTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        userNameController.name.value.trim().isEmpty
                            ? 'مرحباً بك'
                            : userNameController.name.value,
                        style: AppText.appBarSubtitle.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'تعديل الاسم',
                    onPressed: () async {
                      final result = await Get.to(() => TeacherInfo());
                      if (result != null) {
                        userNameController.name.value = result;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('name', result);
                      }
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.onPrimary,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.item});

  final JDrawerItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.mdAll,
        child: InkWell(
          borderRadius: AppRadii.mdAll,
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm - 2,
            ),
            child: Row(
              children: [
                JIconBadge(
                  icon: item.icon,
                  tone: item.tone,
                  size: 38,
                  iconSize: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppText.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: AppColors.inkFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({
    required this.versionController,
    required this.onSupportTap,
  });

  final VersionsController versionController;
  final VoidCallback onSupportTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgElev,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onSupportTap,
              borderRadius: AppRadii.smAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text('التواصل مع الدعم', style: AppText.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              final data = versionController.versionData.value;
              final updateAvailable = data.isUpdateAvailable;
              return InkWell(
                onTap: updateAvailable
                    ? () async {
                        final uri = Uri.parse(data.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    : null,
                borderRadius: AppRadii.smAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        updateAvailable
                            ? Icons.system_update_alt_rounded
                            : Icons.verified_outlined,
                        size: 20,
                        color: updateAvailable
                            ? AppColors.gold
                            : AppColors.inkFaint,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'الإصدار ${versionController.currentVersion.value}',
                          style: AppText.caption,
                        ),
                      ),
                      if (updateAvailable)
                        const JChip(
                          label: 'تحديث متاح',
                          tone: JTone.gold,
                          compact: true,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
