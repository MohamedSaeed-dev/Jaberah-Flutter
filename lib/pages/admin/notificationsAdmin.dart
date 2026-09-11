import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/notificationsAdminController.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:jaberah/widgets/global/notification_card.dart';

class NotificationsAdmin extends StatelessWidget {
  NotificationsAdmin({super.key});

  final controller = Get.put(NotificationsCRUDAdminController());

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      title: 'الإشعارات',
      subtitle: 'الإشعارات المرسلة للمعلمين',
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const JLoadingState(
                    message: 'جاري تحميل الاشعارات...',
                  );
                }
                if (controller.notifications.isEmpty) {
                  return const JEmptyState(
                    title: 'لا توجد إشعارات',
                    message: 'الإشعارات التي ترسلها للمعلمين تظهر هنا.',
                    icon: Icons.notifications_none_rounded,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: controller.notifications.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return JNotificationCard(
                      title: notification.title,
                      body: notification.body,
                      hijriDate: notification.getHijriDate(),
                      hijriTime: notification.getHijriTime(),
                      onDelete: () =>
                          _showDeleteConfirmation(context, notification.id),
                    );
                  },
                );
              }),
            ),
            Obx(
              () => JPaginationBar(
                fetchedCount: controller.fetchedCount.value,
                totalCount: controller.totalCount.value,
                onPrevious:
                    controller.hasPrevious.value && !controller.isLoading.value
                        ? () {
                            controller.pageNumber.value--;
                            controller.getNotifications();
                          }
                        : null,
                onNext: controller.hasNext.value && !controller.isLoading.value
                    ? () {
                        controller.pageNumber.value++;
                        controller.getNotifications();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تأكيد الحذف',
          message: 'هل أنت متأكد أنك تريد حذف هذا الاشعار؟',
          icon: Icons.delete_outline_rounded,
          tone: JTone.danger,
          confirmLabel: 'حذف',
          loading: controller.isLoadingOperation.value,
          loadingLabel: 'جاري الحذف...',
          onConfirm: () async => controller.deleteNotification(id: id),
        ),
      ),
    );
  }
}
