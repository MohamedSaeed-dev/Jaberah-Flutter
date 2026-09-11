import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/notificationsUserController.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:jaberah/widgets/global/notification_card.dart';

class NotificationsUser extends StatelessWidget {
  NotificationsUser({super.key});

  final controller = Get.put(NotificationsCRUDUserController());
  final notificationCount = Get.find<NotificationsCountController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationCount.resetNewNotification();
    });
    return JScaffold(
      title: 'الإشعارات',
      subtitle: 'إشعارات إدارة المسجد',
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
                    message: 'ستظهر هنا الإشعارات الواردة من إدارة المسجد.',
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
}
