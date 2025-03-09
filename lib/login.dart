import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/controllers/connectivity.dart';
import 'package:jaberah/firebase/firebaseAPI.dart';
import 'package:jaberah/pages/admin/homeAdmin.dart';
import 'package:jaberah/pages/user/homeUser.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ApiClient());
  await Firebase.initializeApp();
  await FirebaseAPI().initNotifications();
  Get.put(ConnectivityController());
  final authController = Get.put<AuthController>(AuthController());
  await authController
      .checkLoginStatus(); // Wait for checkLoginStatus to complete
  runApp(App());
}

class App extends StatelessWidget {
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'GE_SS_Two',
      ),
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: Obx(() {
        return authController.isLoggedIn.value
            ? authController.isAdmin.value
                ? HomePageAdmin()
                : HomePageUser()
            : Login();
      }),
    );
  }
}

class Login extends StatelessWidget {
  final key1 = GlobalKey<FormState>();

  final authController = Get.find<AuthController>();

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
        body: Stack(
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/أهل_القرآن-removebg-preview.png"),
                      Text(
                        textAlign: TextAlign.center,
                        "اهلا بك في تطبيق حلقات\n مسجد جابرة",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: key1,
                        child: Column(
                          children: [
                            TextFormField(
                              controller:
                                  authController.usernameController.value,
                              validator: (value) {
                                final arabicRegex = RegExp(
                                    r'^[\u0621-\u064A\u0660-\u0669\s]+$');

                                if (value!.length < 5 || value.length > 20) {
                                  return 'يجب أن يكون اسم المستخدم بين 5 أحرف الى 20 حرفاً';
                                }
                                if (!arabicRegex.hasMatch(value)) {
                                  return 'اسم المستخدم يجب ان يكون باللغة العربية فقط';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                labelText: 'الاسم',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Obx(
                              () => TextFormField(
                                controller:
                                    authController.passwordController.value,
                                obscureText: authController.isShowEye.value,
                                validator: (value) {
                                  if (value!.length < 8) {
                                    return 'يجب أن تكون كلمة المرور 8 أحرف أو أكثر';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        authController.isShowEye.value =
                                            !authController.isShowEye.value;
                                      },
                                      icon: authController.isShowEye.value
                                          ? Icon(Icons.visibility)
                                          : Icon(Icons.visibility_off)),
                                  labelText: 'كلمة المرور',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(() => MaterialButton(
                            color: const Color.fromARGB(255, 63, 181, 108),
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20), // Adjust radius as needed
                            ),
                            height: 60,
                            onPressed: authController.isLoading.value
                                ? () {}
                                : () async {
                                    if (key1.currentState!.validate()) {
                                      await authController.login();
                                    }
                                  },
                            child: Text(
                              '${authController.isLoading.value ? 'جاري التسجيل....' : 'تسجيل'}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
