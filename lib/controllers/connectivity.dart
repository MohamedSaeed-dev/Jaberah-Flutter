import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/versionsController.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;
  var versionController = Get.put(VersionsController());

  @override
  void onInit() {
    super.onInit();

    // Transform Stream<List<ConnectivityResult>> into Stream<ConnectivityResult>
    _connectivityStream = _connectivity.onConnectivityChanged.map((results) =>
        results.isNotEmpty ? results.first : ConnectivityResult.none);

    _connectivityStream.listen((ConnectivityResult result) {
      bool hasInternet = result != ConnectivityResult.none;
      if (!hasInternet) {
        _showNoInternetDialog();
      }
    });
  }

  void _showNoInternetDialog() {
    if (Get.isDialogOpen == true)
      return; // Check properly if a dialog is already open

    Get.dialog(
      AlertDialog(
        title: const Text('غير متصل بالانترنت'),
        content: const Text('لقد فقدت الاتصال بالانترنت'),
        actions: [
          TextButton(
            onPressed: () async {
              var results = await _connectivity.checkConnectivity();
              if (results.isNotEmpty &&
                  results.any((result) => result != ConnectivityResult.none)) {
                if (Get.isDialogOpen == true) {
                  // Ensure Get.isDialogOpen is checked properly
                  Get.back();
                  await versionController.checkVersion();
                }
              }
            },
            child: const Text("تحديث"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
