import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:jaberah/controllers/user/notificationsUserController.dart';
import 'dart:ui';

class NotificationsUser extends StatelessWidget {
  final controller = Get.put(NotificationsCRUDUserController());

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
                        final createdAt = notification.createdAt;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo[100],
                              child: Icon(
                                Icons.notifications,
                              ),
                            ),
                            title: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              notification.body,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    "${createdAt.year}-${createdAt.month}-${createdAt.day}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    )),
                                Text(
                                  "${createdAt.hour == 0 || createdAt.hour == 12 ? 12 : createdAt.hour % 12}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'مساءاً' : 'صباحاً'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: _buildPaginationControls(),
                    ))
              ],
            );
          }
        }),
      ),
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
