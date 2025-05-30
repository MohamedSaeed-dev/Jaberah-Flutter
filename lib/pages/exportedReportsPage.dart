import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jaberah/controllers/exportedReportsPageController.dart';
import 'package:jhijri_picker/jhijri_picker.dart';

class ExportedReportsPage extends StatelessWidget {
  final ExportedReportsController controller =
      Get.put(ExportedReportsController());
  final ScrollController _scrollController = ScrollController();

  ExportedReportsPage({super.key});

Future<void> _pickHijriStartDate(BuildContext context) async {
  var picked = await showGlobalDatePicker(
      headerTitle: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "التقويم الهجري",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // Smaller for cleaner appearance
              fontWeight: FontWeight.w600, // Slightly bold for emphasis
              letterSpacing: 1.2, // Adds a modern touch with spaced letters
            ),
          ),
        ),
      ),
      locale: const Locale("ar", "SA"),
      context: context,
      pickerType: PickerType.JHijri,
      primaryColor: const Color(0xFF1976D2), // Blue accent for primary color
      backgroundColor: Colors.white, // Light background for contrast
      cancelButtonText: "إلغاء",
      okButtonText: "تأكيد",
      selectedDate: controller.filterStartDate.value,
    );

  if (picked != null) {
    controller.updateStartDate(JDateModel(
        jhijri: picked.jhijri,
        dateTime: picked.date
      ));

  }
}

Future<void> _pickHijriEndDate(BuildContext context) async {
  var picked = await showGlobalDatePicker(
      headerTitle: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "التقويم الهجري",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // Smaller for cleaner appearance
              fontWeight: FontWeight.w600, // Slightly bold for emphasis
              letterSpacing: 1.2, // Adds a modern touch with spaced letters
            ),
          ),
        ),
      ),
      locale: const Locale("ar", "SA"),
      context: context,
      pickerType: PickerType.JHijri,
      primaryColor: const Color(0xFF1976D2), // Blue accent for primary color
      backgroundColor: Colors.white, // Light background for contrast
      cancelButtonText: "إلغاء",
      okButtonText: "تأكيد",
      selectedDate: controller.filterEndDate.value,
    );

    if (picked != null) {
      controller.updateEndDate(JDateModel(jhijri: picked.jhijri, dateTime: picked.date));
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
      TextField(
        decoration: InputDecoration(
          labelText: "بحث باسم التقرير",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: controller.updateNameFilter,
      ),
      const SizedBox(height: 16),

      Obx(() {
        final start = controller.filterStartDate.value;
        final end = controller.filterEndDate.value;
        final anyFilterActive = start != null || end != null || controller.filterName.value.isNotEmpty;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      start == null
                          ? "تاريخ البداية"
                          : HijriCalendar.fromDate(start.dateTime!).toFormat("dd - mm - yyyy هـ"),
                      style: const TextStyle(fontSize: 13),
                    ),
                    onPressed: () => _pickHijriStartDate(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      end == null
                          ? "تاريخ النهاية"
                          : HijriCalendar.fromDate(end.dateTime!).toFormat("dd - mm - yyyy هـ"),
                      style: const TextStyle(fontSize: 13),
                    ),
                    onPressed: () => _pickHijriEndDate(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            IconButton(
              tooltip: 'مسح الفلاتر',
              onPressed: anyFilterActive ? controller.clearFilters : null,
              icon: Icon(Icons.clear),
              color: anyFilterActive ? Colors.red : Colors.grey,
              style: IconButton.styleFrom(
                backgroundColor: anyFilterActive ? Colors.red.shade100 : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      }),
      const SizedBox(height: 10),
      const Divider(),
    ],
  ),
)
,

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

                  return InkWell(
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
