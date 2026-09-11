import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/controllers/authController.dart';
import 'package:jaberah/controllers/connectivity.dart';
import 'package:jaberah/config/firebase/firebaseAPI.dart';
import 'package:jaberah/pages/admin/homeAdmin.dart';
import 'package:jaberah/pages/user/homeUser.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:jaberah/widgets/global/exit_confirmation.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);
  Get.put(ApiClient());
  await Firebase.initializeApp();
  await FirebaseAPI().initNotifications();
  Get.put(ConnectivityController());
  // check version
  final authController = Get.put<AuthController>(AuthController());
  await authController
      .checkLoginStatus(); // Wait for checkLoginStatus to complete
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حلقات مسجد جابرة',
      theme: AppTheme.light,
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
  Login({super.key});

  final key1 = GlobalKey<FormState>();

  final authController = Get.find<AuthController>();

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
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: JMotifBackground(
          opacity: 0.05,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xxl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _LoginBrand(),
                      const SizedBox(height: AppSpacing.xxl),
                      JCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Form(
                          key: key1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'تسجيل الدخول',
                                style: AppText.displaySmall,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'أدخل اسمك وكلمة المرور للمتابعة',
                                style: AppText.caption,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TextFormField(
                                controller:
                                    authController.usernameController.value,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final arabicRegex =
                                      RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');

                                  if (value!.length < 5 || value.length > 20) {
                                    return 'يجب أن يكون اسم المستخدم بين 5 أحرف الى 20 حرفاً';
                                  }
                                  if (!arabicRegex.hasMatch(value)) {
                                    return 'اسم المستخدم يجب ان يكون باللغة العربية فقط';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline),
                                  labelText: 'الاسم',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Obx(
                                () => TextFormField(
                                  controller:
                                      authController.passwordController.value,
                                  obscureText: authController.isShowEye.value,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value!.length < 8) {
                                      return 'يجب أن تكون كلمة المرور 8 أحرف أو أكثر';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        authController.isShowEye.value =
                                            !authController.isShowEye.value;
                                      },
                                      tooltip: authController.isShowEye.value
                                          ? 'إظهار كلمة المرور'
                                          : 'إخفاء كلمة المرور',
                                      icon: Icon(
                                        authController.isShowEye.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                    labelText: 'كلمة المرور',
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Obx(
                                () => JButton(
                                  label: 'تسجيل الدخول',
                                  icon: Icons.login_rounded,
                                  loading: authController.isLoading.value,
                                  loadingLabel: 'جاري التسجيل...',
                                  onPressed: () async {
                                    if (key1.currentState!.validate()) {
                                      await authController.login();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const JOrnamentDivider(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'مسجد الجابرة · الرياض',
                        textAlign: TextAlign.center,
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ترويسة شاشة الدخول: شعار المسجد داخل مربّع زمردي، ثم الاسم والترحيب.
class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: AppShadows.float,
          ),
          child: const Icon(
            Icons.mosque_rounded,
            size: 44,
            color: AppColors.onPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'حلقات مسجد جابرة',
          textAlign: TextAlign.center,
          style: AppText.displayLarge,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'بسم الله الرحمن الرحيم',
          textAlign: TextAlign.center,
          style: AppText.displaySmall.copyWith(color: AppColors.gold),
        ),
      ],
    );
  }
}
