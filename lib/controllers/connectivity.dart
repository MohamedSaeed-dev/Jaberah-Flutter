import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;
  var isConnected = true.obs;
  bool _dialogShown = false;

  @override
  void onInit() {
    super.onInit();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen((ConnectivityResult result) {
      bool hasInternet = result != ConnectivityResult.none;
      if (isConnected.value != hasInternet) {
        isConnected.value = hasInternet;
        if (!hasInternet) {
          // When internet is lost, show the dialog if not already displayed.
          if (!_dialogShown) {
            _showNoInternetDialog();
          }
        } else {
          // When internet is back, dismiss the dialog if it is open.
          if (_dialogShown) {
            Get.back();
            _dialogShown = false;
          }
        }
      }
    });
  }

  void _showNoInternetDialog() {
    _dialogShown = true;
    Get.dialog(
      AlertDialog(
        title: Center(
          child: Text(
            'غير متصل بالانترنت',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: Center(
          child: Text(
            'لقد فقدت الاتصال بالانترنت',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Check connectivity when the reload button is pressed.
              var result = await _connectivity.checkConnectivity();
              if (result != ConnectivityResult.none) {
                if (_dialogShown) {
                  Get.back(); // Dismiss the dialog.
                  _dialogShown = false;
                }
              }
            },
            child: Text("تحديث"),
          ),
        ],
      ),
      barrierDismissible: false, // Prevent dismissing by tapping outside.
    );
  }
}
