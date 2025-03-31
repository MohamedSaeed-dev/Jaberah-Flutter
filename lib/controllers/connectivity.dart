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
    
    // Transform Stream<List<ConnectivityResult>> into Stream<ConnectivityResult>
    _connectivityStream = _connectivity.onConnectivityChanged.map((results) => 
        results.isNotEmpty ? results.first : ConnectivityResult.none);

    _connectivityStream.listen((ConnectivityResult result) {
      bool hasInternet = result != ConnectivityResult.none;
      if (isConnected.value != hasInternet) {
        isConnected.value = hasInternet;
        if (!hasInternet) {
          if (!_dialogShown) {
            _showNoInternetDialog();
          }
        } else {
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
        title: const Center(
          child: Text(
            'غير متصل بالانترنت',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: const Center(
          child: Text(
            'لقد فقدت الاتصال بالانترنت',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              var result = await _connectivity.checkConnectivity();
              if (result != ConnectivityResult.none) {
                if (_dialogShown) {
                  Get.back();
                  _dialogShown = false;
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
