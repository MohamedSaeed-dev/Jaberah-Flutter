import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/notificationsAdminController.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/controllers/admin/userNameController.dart';
import 'package:jaberah/controllers/versionsController.dart';
import 'package:jaberah/login.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/pages/admin/groups/groups.dart';
import 'package:jaberah/pages/admin/notificationsAdmin.dart';
import 'package:jaberah/pages/admin/reports/reports.dart';
import 'package:jaberah/pages/admin/students/Panel_Students.dart';
import 'package:jaberah/pages/admin/students/add_students.dart';
import 'package:jaberah/pages/admin/teachers/Panel_teachers.dart';
import 'package:jaberah/pages/admin/teachers/add_teacher.dart';
import 'package:jaberah/pages/admin/teachers/profile.dart';
import 'package:jaberah/pages/user/homeUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageAdmin extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final UserNameController userNameController = Get.put(UserNameController());
  final NotificationsAdminController notificationController =
      Get.put(NotificationsAdminController());
  final VersionsController versionController = Get.put(VersionsController());
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        bool exitApp = await Get.dialog(
              AlertDialog(
                title: Text('الخروج من التطبيق'),
                content: Text('هل أنت متأكد انك تريد الخروج من التطبيق؟'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text(
                      'الخروج',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
        if (exitApp) {
          exit(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'حلقات مسجد جابرة',
            style: TextStyle(
              fontFamily: 'GE_SS_Two',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
        ),
        drawer: Drawer(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 63, 181, 108),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/profile.png'),
                            radius: 40,
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                      userNameController.name.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    )),
                                IconButton(
                                  onPressed: () async {
                                    var result =
                                        await Get.to(() => TeacherInfo());
                                    if (result != null) {
                                      userNameController.name.value = result;
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString('name', result);
                                    }
                                  },
                                  icon: Icon(Icons.edit),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_add),
                      title: const Text('إضافة طالب'),
                      onTap: () {
                        Get.to(() => AddStudent());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_add),
                      title: const Text('إضافة معلم'),
                      onTap: () {
                        Get.to(() => AddTeacher());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notification_important),
                      title: const Text('الإشعارات'),
                      onTap: () {
                        Get.to(() => NotificationsAdmin());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.book_sharp),
                      title: const Text('قسم الحلقات'),
                      onTap: () {
                        Get.off(() => HomePageUser());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('تسجيل الخروج'),
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: const Text(
                              'تأكيد تسجيل الخروج؟',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                                'هل أنت متأكد أنك تريد تسجيل الخروج؟'),
                            actions: [
                              TextButton(
                                child: const Text(
                                  'إلغاء',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                              ),
                              TextButton(
                                child: Obx(() => Text(
                                      authController.isLoadingLogout.value
                                          ? 'جاري تسجيل الخروج...'
                                          : 'تسجيل الخروج',
                                      style: const TextStyle(color: Colors.red),
                                    )),
                                onPressed: () async {
                                  await authController.logout();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  // alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("للتواصل مع الدعم؟"),
                          IconButton(
                            onPressed: () async {
                              if (await canLaunchUrl(
                                  Uri.parse("https://wa.me/+966574195965"))) {
                                await launchUrl(
                                    Uri.parse("https://wa.me/+966574195965"),
                                    mode: LaunchMode.externalApplication);
                              } else {
                                messageSnackBar("حدث خطأ، اعد المحاولة");
                              }
                            },
                            icon: const Icon(Icons.phone),
                          ),
                        ],
                      ),
                      Container(
                        // alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () async {
                            if (versionController
                                .versionData.value.isUpdateAvailable) {
                              if (await canLaunchUrl(Uri.parse(
                                  versionController.versionData.value.url))) {
                                await launchUrl(
                                    Uri.parse(versionController
                                        .versionData.value.url),
                                    mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => Text(
                                    "الإصدار الحالي: ${versionController.currentVersion.value}",
                                    style: TextStyle(
                                      color: versionController.versionData.value
                                              .isUpdateAvailable
                                          ? Colors.blue
                                          : Colors.black,
                                      fontWeight: versionController.versionData
                                              .value.isUpdateAvailable
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  )),
                              Obx(() {
                                if (versionController
                                    .versionData.value.isUpdateAvailable) {
                                  return Icon(
                                    Icons.update,
                                    color: Colors.red,
                                  );
                                }
                                return SizedBox();
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Align(
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/background12.png',
                  height: double.infinity,
                  width: 500,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 100),
              alignment: Alignment.topCenter,
              child: const Text(
                "القوائم",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: GridView(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  children: [
                    _buildCard(
                        context: context,
                        title: "المعلمين",
                        icon: Icons.person,
                        color: Colors.blue,
                        route: () => TeachersPanelPage()),
                    _buildCard(
                        context: context,
                        title: "الحلقات",
                        icon: Icons.group,
                        color: Colors.red,
                        route: () => Groups()),
                    _buildCard(
                        context: context,
                        title: "التقارير",
                        icon: Icons.report,
                        color: Colors.green,
                        route: () => Reports()),
                    _buildCard(
                        context: context,
                        title: "الطلاب",
                        icon: Icons.school,
                        color: Colors.orange,
                        route: () => Panel_Students()),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final formKey = GlobalKey<FormState>();

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('إرسال إشعار للمعلمين'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: notificationController.titleController,
                          decoration: const InputDecoration(
                              labelText: 'العنوان',
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يجب إدخال عنوان الاشعار';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: notificationController.bodyController,
                          decoration: const InputDecoration(
                              labelText: 'النص', border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          notificationController.sendNotification();
                        }
                      },
                      child: Obx(() => Text(
                          notificationController.isLoading.value
                              ? 'جاري الارسال...'
                              : 'إرسال')),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(
            Icons.notification_add,
            color: Colors.black,
          ),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
          label:
              const Text("ارسال اشعار", style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}

Widget _buildCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Color color,
  required Widget Function() route,
}) {
  return GestureDetector(
    onTap: () {
      Get.to(route);
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      shadowColor: color.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE_SS_Two',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
