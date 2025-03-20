import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/api/Dio.dart';
import 'package:jaberah/models/global/snackbars.dart';
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

  var currentVersion = ''.obs;

  Future<void> checkVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      currentVersion.value = packageInfo.version;
      var response =
          await _apiClient.dio.get("/versions?version=${packageInfo.version}");

      if (response.statusCode == 200) {
        versionData.value = VersionData.fromJson(response.data);
        await handleUpdateDialog();
      }
    } on SocketException catch (_) {
      socketSnackBar();
    } on TimeoutException catch (_) {
      timeoutSnackBar();
    } on DioException catch (e) {
      messageSnackBar(e.response!.data["message"] ?? "حدث خطأ ما");
    } catch (e) {
      catchSnackBar();
    }
  }

  Future<void> handleUpdateDialog() async {
    // If a required update is needed, force the user to update
    if (versionData.value.isUpdateRequired) {
      showRequiredUpdateDialog();
      return;
    }

    // If an optional update is available
    if (versionData.value.isUpdateAvailable) {
      showOptionalUpdateDialog();
    }
  }

  void showRequiredUpdateDialog() {
    Get.dialog(
      PopScope(
        canPop: false, // Prevent closing the dialog
        child: AlertDialog(
          title: const Text('تحديث مطلوب'),
          content: const Text(
              'يجب تحديث التطبيق للوصول إلى أحدث الميزات والتحسينات. لا يمكنك استخدام التطبيق بدون التحديث.'),
          actions: [
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
      ),
      barrierDismissible: false, // Prevent dismissal by tapping outside
    );
  }

  void showOptionalUpdateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تحديث متاح'),
        content: const Text('يوجد تحديث جديد، هل ترغب في التحديث الآن؟'),
        actions: [
          TextButton(
            onPressed: () async {
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
      'latestVersion': latestVersion,
      'minRequiredVersion': minRequiredVersion,
      'isUpdateRequired': isUpdateRequired,
      'isUpdateAvailable': isUpdateAvailable,
      'url': url,
    };
  }
}
