import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late Stream<List<ConnectivityResult>> _connectivityStream;
  var isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen((List<ConnectivityResult> results) {
      ConnectivityResult result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      bool hasInternet = result != ConnectivityResult.none;

      if (isConnected.value != hasInternet) {
        isConnected.value = hasInternet;

        if (!hasInternet) {
          Get.snackbar(
            '',
            '',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.7),
            colorText: Colors.white,
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 6),
            isDismissible: true,
            titleText: const Center(
              child: Text(
                'غير متصل بالانترنت',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            messageText: Center(
              child: Text(
                'لقد فقدت الاتصال بالانترنت',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        } else {
          Get.snackbar(
            '',
            '',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.7),
            colorText: Colors.white,
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 6),
            isDismissible: true,
            titleText: const Center(
              child: Text(
                'متصل بالانترنت',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            messageText: Center(
              child: Text(
                'تم استعادة الاتصال بالانترنت',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }
      }
    });
  }
}
