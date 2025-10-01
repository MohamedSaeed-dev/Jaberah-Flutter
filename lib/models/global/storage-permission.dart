import 'package:permission_handler/permission_handler.dart';
import 'package:jaberah/models/global/snackbars.dart';

Future<void> requestStoragePermission() async {
  final externalStatus = await Permission.manageExternalStorage.request();
  if (!externalStatus.isGranted) {
    final storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      await openAppSettings();
      messageSnackBar("يجب منح إذن الوصول إلى التخزين");
    }
  }
}
