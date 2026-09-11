import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/widgets/ds/ds.dart';

/// حوار تأكيد الخروج من التطبيق.
///
/// كان هذا الحوار مكرّراً حرفياً في شاشة الدخول والرئيسيتين؛ جُمع هنا حتى
/// يبقى شكله واحداً حين يتغيّر نظام التصميم.
Future<bool> confirmExitApp() async {
  final result = await Get.dialog<bool>(
    JDialog(
      title: 'الخروج من التطبيق',
      message: 'هل أنت متأكد أنك تريد الخروج من التطبيق؟',
      icon: Icons.logout_rounded,
      tone: JTone.danger,
      confirmLabel: 'الخروج',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    ),
  );
  return result ?? false;
}
