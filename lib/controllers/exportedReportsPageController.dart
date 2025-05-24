import 'dart:io';
import 'package:get/get.dart';

class ExportedReportsModel {
  final File file;
  final DateTime createdAt;

  ExportedReportsModel({required this.file, required this.createdAt});
}

class ExportedReportsController extends GetxController {
  final int pageSize = 10;

  var totalFiles = <ExportedReportsModel>[]; // all loaded files
  var filteredFiles =
      <ExportedReportsModel>[]; // filtered files after filters applied
  var paginatedFiles = <ExportedReportsModel>[].obs; // currently displayed page

  var isLoading = false.obs;
  var isDeleting = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;

  // Filters
  var filterStartDate = Rxn<DateTime>();
  var filterEndDate = Rxn<DateTime>();
  var filterName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPdfFilesWithDate();
  }

  Future<void> loadPdfFilesWithDate() async {
    isLoading.value = true;
    try {
      final directory = Directory('/storage/emulated/0/Download/Reports');
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

      totalFiles
          .sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Descending

      applyFilters();
    } catch (e) {
      // Handle errors here
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

      // Filter by start date
      bool matchesDate = true;
      if (filterStartDate.value != null) {
        matchesDate = createdAt
            .isAfter(filterStartDate.value!.subtract(const Duration(days: 1)));
      }
      // Filter by end date
      if (matchesDate && filterEndDate.value != null) {
        matchesDate = createdAt
            .isBefore(filterEndDate.value!.add(const Duration(days: 1)));
      }

      // Filter by name
      final nameFilter = filterName.value.toLowerCase();
      bool matchesName = fileName.contains(nameFilter);

      return matchesDate && matchesName;
    }).toList();

    // Reset pagination
    paginatedFiles.clear();
    hasMore.value = filteredFiles.isNotEmpty;

    _loadPage(0);
  }

  void updateNameFilter(String value) {
    filterName.value = value;
    applyFilters();
  }

  void updateStartDate(DateTime? date) {
    filterStartDate.value = date;
    applyFilters();
  }

  void updateEndDate(DateTime? date) {
    filterEndDate.value = date;
    applyFilters();
  }

  void clearFilters() {
    filterStartDate.value = null;
    filterEndDate.value = null;
    filterName.value = '';
    applyFilters();
  }

  void _loadPage(int pageIndex) {
    final start = pageIndex * pageSize;
    if (start >= filteredFiles.length) {
      hasMore.value = false;
      return;
    }

    final end = (start + pageSize) > filteredFiles.length
        ? filteredFiles.length
        : (start + pageSize);

    paginatedFiles.addAll(filteredFiles.sublist(start, end));

    hasMore.value = end < filteredFiles.length;
  }

  Future<void> loadMoreFiles() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    // Calculate next page index by current loaded items count / pageSize
    final nextPage = paginatedFiles.length ~/ pageSize;
    await Future.delayed(const Duration(milliseconds: 300)); // simulate delay
    _loadPage(nextPage);

    isLoadingMore.value = false;
  }

  Future<void> deleteFile(File file) async {
    isDeleting.value = true;
    try {
      await file.delete();
      // Remove from lists
      totalFiles.removeWhere((e) => e.file.path == file.path);
      applyFilters();
    } catch (e) {
      // Handle delete error if needed
    }
    isDeleting.value = false;
  }

  void openFile(File file) {
    // Implement your file open logic here
  }
}
