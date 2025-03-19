import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionsController extends GetxController {
  final ApiClient _apiClient = Get.find();

  final versionData = VersionData(
    latestVersion: '',
    minRequiredVersion: '',
    isUpdateRequired: false,
    isUpdateAvailable: false,
    url: '',
  ).obs;

  @override
  void onInit() {
    checkVersion();
    super.onInit();
  }

  Future<void> checkVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      var response =
          await _apiClient.dio.get("/versions?version=${packageInfo.version}");
      if (response.statusCode == 200) {
        versionData.value = VersionData.fromJson(response.data);
        await handleUpdateDialog();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> handleUpdateDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastDismissedTime = prefs.getInt('last_update_dismissed');

    // Check if update is required
    if (versionData.value.isUpdateAvailable) {
      // If last dismissed time exists, check if 6 hours have passed
      if (lastDismissedTime != null) {
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - lastDismissedTime < 6 * 60 * 60 * 1000) {
          return; // Don't show dialog again yet
        }
      }

      // Show update dialog
      showUpdateDialog();
    }
  }

  void showUpdateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تحديث متاح'),
        content: const Text('يوجد تحديث جديد، هل ترغب في التحديث الآن؟'),
        actions: [
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setInt('last_update_dismissed',
                  DateTime.now().millisecondsSinceEpoch);
              Get.back(); // Close dialog
            },
            child: const Text('لاحقًا'),
          ),
          TextButton(
            onPressed: () async {
              if (await canLaunchUrl(Uri.parse(versionData.value.url))) {
                await launchUrl(Uri.parse(versionData.value.url),
                    mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
      barrierDismissible: false, // Prevent dismissal by tapping outside
    );
  }
}

class VersionData {
  String latestVersion;
  String minRequiredVersion;
  bool isUpdateRequired;
  bool isUpdateAvailable;
  String url;

  VersionData({
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.isUpdateRequired,
    required this.isUpdateAvailable,
    required this.url,
  });

  factory VersionData.fromJson(Map<String, dynamic> json) => VersionData(
        latestVersion: json['latestVersion'],
        minRequiredVersion: json['minRequiredVersion'],
        isUpdateRequired: json['isUpdateRequired'],
        isUpdateAvailable: json['isUpdateAvailable'],
        url: json['url'],
      );

  Map<String, dynamic> toJson() {
    return {
      'latestVersion': this.latestVersion,
      'minRequiredVersion': this.minRequiredVersion,
      'isUpdateRequired': this.isUpdateRequired,
      'isUpdateAvailable': this.isUpdateAvailable,
      'url': this.url,
    };
  }
}
