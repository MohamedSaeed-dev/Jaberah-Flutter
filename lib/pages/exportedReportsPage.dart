import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jaberah/controllers/exportedReportsPageController.dart';

class ExportedReportsPage extends StatelessWidget {
  final ExportedReportsController controller =
      Get.put(ExportedReportsController());
  final ScrollController _scrollController = ScrollController();

  ExportedReportsPage({Key? key}) : super(key: key) {
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.filterStartDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      controller.updateStartDate(picked);
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.filterEndDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      controller.updateEndDate(picked);
    }
  }

  void _showDeleteConfirmation(BuildContext context, File file) {
    final controller = Get.find<ExportedReportsController>();
    showDialog(
      context: context,
      builder: (context) => Obx(() => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: const Text("تأكيد الحذف"),
            content: const Text("هل أنت متأكد من حذف هذا التقرير؟"),
            actions: [
              TextButton(
                child: const Text("إلغاء"),
                onPressed: () => Get.back(),
              ),
              controller.isDeleting.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: CircularProgressIndicator(),
                    )
                  : TextButton(
                      child: const Text("حذف",
                          style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        await controller.deleteFile(file);
                        Get.back();
                      },
                    ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير المصدرة'),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File name filter
                TextField(
                  decoration: InputDecoration(
                    labelText: "بحث باسم الملف",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: controller.updateNameFilter,
                ),
                const SizedBox(height: 12),

                // Filters Row with X icon at the end
                Obx(() {
                  final start = controller.filterStartDate.value;
                  final end = controller.filterEndDate.value;
                  final anyFilterActive = start != null ||
                      end != null ||
                      controller.filterName.value.isNotEmpty;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date filters
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                start == null
                                    ? "تاريخ البداية"
                                    : DateFormat('yyyy-MM-dd', 'ar')
                                        .format(start),
                                style: const TextStyle(fontSize: 14),
                              ),
                              onPressed: () => _pickStartDate(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                end == null
                                    ? "تاريخ النهاية"
                                    : DateFormat('yyyy-MM-dd', 'ar')
                                        .format(end),
                                style: const TextStyle(fontSize: 14),
                              ),
                              onPressed: () => _pickEndDate(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Clear X icon at end of row
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: anyFilterActive
                              ? Colors.red.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'مسح الفلاتر',
                          color: anyFilterActive ? Colors.red : Colors.grey,
                          onPressed:
                              anyFilterActive ? controller.clearFilters : null,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // List expanded
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.paginatedFiles.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text(
                        "جاري تحميل التقارير المصدرة...",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.paginatedFiles.isEmpty) {
                return const Center(
                  child: Text(
                    "لاتوجد تقارير مصدرة حالياً",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.paginatedFiles.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == controller.paginatedFiles.length) {
                    
                      return const SizedBox.shrink();
                    
                  }

                  final fileWithDate = controller.paginatedFiles[index];
                  final file = fileWithDate.file;

                  final hijriDate =
                      HijriCalendar.fromDate(fileWithDate.createdAt);

                  final hijriDateStr =
                      '${hijriDate.hDay.toString().padLeft(2, '0')}-'
                      '${hijriDate.hMonth.toString().padLeft(2, '0')}-'
                      '${hijriDate.hYear} هـ';

                  final timeStr = DateFormat('hh:mm a', 'ar')
                      .format(fileWithDate.createdAt);

                  final createdAtStr = '$hijriDateStr \n $timeStr';

                  final fileName =
                      file.path.split('/').last.replaceAll(".pdf", ".");

                  return GestureDetector(
                      onTap: () => controller.openFile(file),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: const Icon(Icons.picture_as_pdf,
                              color: Colors.red, size: 30),
                          title: Text(
                            fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'تاريخ الإنشاء: $createdAtStr',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                tooltip: "حذف التقرير",
                                onPressed: () =>
                                    _showDeleteConfirmation(context, file),
                              ),
                            ],
                          ),
                        ),
                      ));
                },
              );
            }),
          ),
          Obx(() {
            final totalPages =
                (controller.paginatedFiles.length / controller.pageSize).ceil();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: controller.currentPage.value > 0
                      ? controller.prevPage
                      : null,
                ),
                Text(
                    '${controller.paginatedFiles.length} من ${controller.totalFiles.length}'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed:
                      controller.hasMore.value ? controller.nextPage : null,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
