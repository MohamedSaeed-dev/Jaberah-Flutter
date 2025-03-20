import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/controllers/admin/userNameController.dart';
import 'package:jaberah/controllers/versionsController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/pages/user/notificationsUser.dart';
import 'package:jaberah/pages/admin/homeAdmin.dart';
import 'package:jaberah/pages/user/followStudents/groups_followStudents.dart';
import 'package:jaberah/pages/user/reports/StudentsReport.dart';
import 'package:jaberah/pages/admin/teachers/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageUser extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final UserNameController userNameController = Get.put(UserNameController());
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
            padding: EdgeInsets.only(bottom: 30),
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
                    if (!authController.isAdmin.value)
                      ListTile(
                        leading: const Icon(Icons.notification_important),
                        title: const Text('الإشعارات'),
                        onTap: () {
                          Get.to(() => NotificationsUser());
                        },
                      ),
                    if (authController.isAdmin.value)
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings_sharp),
                        title: const Text('قسم الإدارة'),
                        onTap: () {
                          Get.off(() => HomePageAdmin());
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('تسجيل الخروج'),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
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
                                Obx(() => TextButton(
                                      child: Text(
                                        authController.isLoadingLogout.value
                                            ? 'جاري تسجيل الخروج...'
                                            : 'تسجيل الخروج',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () async {
                                        await authController.logout();
                                      },
                                    )),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.bottomCenter,
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
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () async {
                            if (versionController
                                .versionData.value.isUpdateAvailable) {
                              if (await canLaunchUrl(Uri.parse(
                                  versionController.versionData.value.url))) {
                                await launchUrl(
                                    Uri.parse(
                                        versionController.versionData.value.url),
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
                                      color: versionController
                                              .versionData.value.isUpdateAvailable
                                          ? Colors.blue
                                          : Colors.black,
                                      fontWeight: versionController
                                              .versionData.value.isUpdateAvailable
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
            Center(
              child: Container(
                alignment: Alignment.topCenter,
                width: 400,
                height: 450,
                child: const Text(
                  "القوائم",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 200,
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
                        title: 'المتابعة اليومية',
                        icon: Icons.assignment_add,
                        color: Colors.red,
                        route: () => GroupsFollowStudents()),
                    _buildCard(
                        context: context,
                        title: 'تقارير الطلاب',
                        icon: Icons.event_note,
                        color: Colors.purple,
                        route: () => StudentsReport()),
                  ],
                ),
              ),
            ),
          ],
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
      shadowColor: color.withOpacity(0.5),
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
