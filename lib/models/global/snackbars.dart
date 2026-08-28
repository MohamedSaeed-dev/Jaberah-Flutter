import 'package:flutter/material.dart';
import 'package:get/get.dart';

SnackbarController successSnackBar(String message) {
  return Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green.withOpacity(0.7),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    isDismissible: true,
    titleText: Center(
      child: Text(
        message,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
  );
}

SnackbarController catchSnackBar() {
  return Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.withOpacity(0.7),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    isDismissible: true,
    titleText: const Center(
      child: Text(
        'حدث خطأ ما',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
    messageText: const Center(
      child: Text(
        'الرجاء المحاولة مرة أخرى',
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

SnackbarController messageSnackBar(String message,
    {String title = 'حدث خطأ ما'}) {
  return Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.withValues(alpha: 0.7),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    isDismissible: true,
    titleText: Center(
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
    messageText: Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

SnackbarController socketSnackBar() {
  return Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.withOpacity(0.7),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    isDismissible: true,
    titleText: const Center(
      child: Text(
        'حدث خطأ في الاتصال بالانترنت',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
    messageText: const Center(
      child: Text(
        'الرجاء التأكد من الاتصال بالانترنت',
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

SnackbarController timeoutSnackBar() {
  return Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.withOpacity(0.7),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    isDismissible: true,
    titleText: const Center(
      child: Text(
        'حدث خطأ في الخادم',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
    messageText: const Center(
      child: Text(
        'الرجاء المحاولة مرة أخرى',
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

/// يستخرج رسالة الخطأ من جسم رد الـ API بأمان.
///
/// جسم الرد قد يكون Map (‏`{message}` أو `{validationContent}`) أو نصًا (صفحة
/// خطأ 404 مثلًا) أو null. فهرسة النص بمفتاح نصي ترمي
/// `type 'String' is not a subtype of type 'int' of 'index'`، وإن حدث ذلك داخل
/// كتلة catch فلن يلتقطه أي catch لاحق ويخرج كاستثناء غير معالج.
String apiErrorMessage(dynamic data, {String fallback = 'حدث خطأ'}) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    final validation = data['validationContent'];
    if (validation is List) {
      final messages = validation
          .whereType<Map>()
          .map((item) => item['message'])
          .whereType<String>()
          .where((m) => m.trim().isNotEmpty)
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }
  }
  return fallback;
}
