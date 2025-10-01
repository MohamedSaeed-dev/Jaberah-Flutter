import 'dart:io';
import 'package:get/get.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jaberah/models/global/storage-permission.dart';
import 'package:jhijri_picker/jhijri_picker.dart';
import 'package:open_file/open_file.dart';

class ExportedReportsModel {
  final File file;
  final DateTime createdAt;

  ExportedReportsModel({required this.file, required this.createdAt});
}

class ExportedReportsController extends GetxController {
  final int pageSize = 10;

  var totalFiles = <ExportedReportsModel>[];
  var filteredFiles = <ExportedReportsModel>[];
  var paginatedFiles = <ExportedReportsModel>[].obs;

  var isLoading = false.obs;
  var isDeleting = false.obs;
  var hasMore = false.obs;

  var currentPage = 0.obs;

  var filterStartDate = Rxn<JDateModel>();
  var filterEndDate = Rxn<JDateModel>();
  var filterName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPdfFilesWithDate();
  }

  Future<void> loadPdfFilesWithDate() async {
    isLoading.value = true;
    try {
      await requestStoragePermission();
      final directory = Directory(appFolder);
      final files = directory.existsSync() ? directory.listSync() : [];
      final pdfFiles = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.pdf'))
          .toList();

      totalFiles = pdfFiles
          .map((file) => ExportedReportsModel(
                file: file,
                createdAt: file.lastModifiedSync(),
              ))
          .toList();

      totalFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      applyFilters();
    } catch (e) {
      totalFiles = [];
      filteredFiles = [];
      paginatedFiles.clear();
      hasMore.value = false;
    }
    isLoading.value = false;
  }

  void applyFilters() {
    filteredFiles = totalFiles.where((fileModel) {
      final fileName = fileModel.file.path.split('/').last.toLowerCase();
      final createdAt = fileModel.createdAt;

      bool matchesDate = true;
      if (filterStartDate.value != null) {
        matchesDate = createdAt.isAfter(
            filterStartDate.value!.dateTime!.subtract(const Duration(days: 1)));
      }
      if (matchesDate && filterEndDate.value != null) {
        matchesDate = createdAt.isBefore(
            filterEndDate.value!.dateTime!.add(const Duration(days: 1)));
      }

      bool matchesName = fileName.contains(filterName.value.toLowerCase());

      return matchesDate && matchesName;
    }).toList();

    currentPage.value = 0;
    paginate();
  }

  void paginate() {
    final start = currentPage.value * pageSize;
    final end = start + pageSize;

    if (start >= filteredFiles.length) {
      paginatedFiles.value = [];
    } else {
      paginatedFiles.value =
          filteredFiles.sublist(start, end.clamp(0, filteredFiles.length));
    }

    hasMore.value = (currentPage.value + 1) * pageSize < filteredFiles.length;
  }

  void nextPage() {
    if (hasMore.value) {
      currentPage.value++;
      paginate();
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      paginate();
    }
  }

  void updateStartDate(JDateModel date) {
    filterStartDate.value = date;
    applyFilters();
  }

  void updateEndDate(JDateModel date) {
    filterEndDate.value = date;
    applyFilters();
  }

  void updateNameFilter(String name) {
    filterName.value = name;
    applyFilters();
  }

  void clearFilters() {
    filterStartDate.value = null;
    filterEndDate.value = null;
    filterName.value = '';
    applyFilters();
  }

  Future<void> deleteFile(File file) async {
    isDeleting.value = true;
    try {
      if (await file.exists()) {
        await file.delete();
        loadPdfFilesWithDate();
      }
    } catch (e) {
      messageSnackBar("حدث خطأ أثناء الحذف");
    }
    isDeleting.value = false;
  }

  Future<void> openFile(File file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      messageSnackBar("تعذر فتح التقرير");
    }
  }
}
