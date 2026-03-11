import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/notificationsAdminController.dart';
import 'dart:ui';

class NotificationsAdmin extends StatelessWidget {
  final controller = Get.put(NotificationsCRUDAdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Container(
        alignment: Alignment.topLeft,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    "جاري تحميل الاشعارات...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else if (controller.notifications.isEmpty &&
              !controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty),
                  SizedBox(
                    height: 10,
                  ),
                  Text("لاتوجد بيانات", style: TextStyle(fontSize: 20))
                ],
              ),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: ListView.builder(
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.indigo[100],
                                  child: const Icon(
                                    Icons.notifications,
                                    color: Colors
                                        .indigo, // Added color for better contrast
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Body content: will expand the card height dynamically
                                      Text(
                                        notification.body,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          notification.getHijriTime(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          notification.getHijriDate(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteConfirmation(
                                            context, notification.id);
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: _buildPaginationControls(),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا الاشعار؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              onPressed: controller.isLoadingOperation.value
                  ? null
                  : () async {
                      await controller.deleteNotification(id: id);
                    },
              child: Obx(() => Text(
                    controller.isLoadingOperation.value
                        ? 'جاري الحذف...'
                        : 'حذف',
                    style: TextStyle(color: Colors.red),
                  )),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: controller.hasPrevious.value && !controller.isLoading.value
              ? () {
                  controller.pageNumber.value--;
                  controller.getNotifications();
                }
              : null,
        ),
        Text(
            '${controller.fetchedCount.value} من ${controller.totalCount.value}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: controller.hasNext.value && !controller.isLoading.value
              ? () {
                  controller.pageNumber.value++;
                  controller.getNotifications();
                }
              : null,
        ),
      ],
    );
  }
}
