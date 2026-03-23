import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/bestStudentsController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class BestStudentsReport extends StatelessWidget {
  final BestStudentsController controller = Get.put(BestStudentsController());

  BestStudentsReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          width: double.infinity,
          child: Obx(
            () => FloatingActionButton.extended(
              onPressed: controller.isLoading.value
                  ? null
                  : () async {
                      await controller.fetchBestStudentsReport();
                    },
              label: const Text(
                "عـرض الـتـقـريـر",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(
                Icons.document_scanner_outlined,
                color: Colors.black,
              ),
              backgroundColor: const Color.fromARGB(255, 63, 181, 108),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        actions: [
          Obx(
            () => IconButton(
              onPressed: (controller.isLoading.value ||
                      controller.bestStudentsReport.isEmpty)
                  ? null
                  : () {
                      final monthName =
                          controller.selectedDate.value.jhijri!.monthName;
                      final year = controller.selectedDate.value.jhijri!.year;
                      final title = controller.isAllGroupsSelected
                          ? "تقرير الطلاب المتميزون على جميع الحلقات لشهر $monthName - $year"
                          : "تقرير الطلاب المتميزون لـ ${controller.selectedGroupName.value} لشهر $monthName - $year";
                      controller.exportAsPDF(
                          title, controller.bestStudentsReport.toList());
                    },
              icon: const Icon(
                Icons.save,
                color: Colors.black,
              ),
            ),
          ),
          PopupMenuButton<int>(
            iconColor: Colors.black,
            icon: const Icon(Icons.numbers),
            onSelected: (value) {
              controller.take.value = value;
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  child: Text("5"),
                  value: 5,
                ),
                const PopupMenuItem(
                  child: Text("6"),
                  value: 6,
                ),
                const PopupMenuItem(
                  child: Text("7"),
                  value: 7,
                ),
                const PopupMenuItem(
                  child: Text("8"),
                  value: 8,
                ),
                const PopupMenuItem(
                  child: Text("9"),
                  value: 9,
                ),
                const PopupMenuItem(
                  child: Text("10"),
                  value: 10,
                ),
              ];
            },
          )
        ],
        title: const Text('تقرير الطلاب المتميزون'),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => _buildHijriMonthDatePicker(context, 'الشهر الهجري:')),
            const SizedBox(height: 10),
            _buildGroupDropdown(),
            const SizedBox(height: 10),
            const Divider(),
            Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingIndicator(
                  controller.isAllGroupsSelected
                      ? "جاري تحميل تقرير الطلاب المتميزين على جميع الحلقات"
                      : "جاري تحميل تقرير الطلاب المتميزين لحلقة ${controller.selectedGroupName.value}",
                );
              } else if (controller.bestStudentsReport.isEmpty) {
                return _buildEmptyDataIndicator();
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.bestStudentsReport.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildStudentsCard(
                            controller.bestStudentsReport[index], true);
                      }
                      return _buildStudentsCard(
                          controller.bestStudentsReport[index], false);
                    },
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsCard(BestStudentsReportModel student, bool isBest) {
    return Stack(
      children: [
        // Card content
        Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Name
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    '${student.studentName} ${student.groupName != null ? '- ${student.groupName}' : ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Divider(height: 24, thickness: 1),

                // Grades and Exams
                _buildSectionTitle('التقييمات'),
                const SizedBox(height: 10),
                _buildStudentRow('درجة الحفظ:', "${student.saveGrade}"),
                _buildStudentRow('درجة المراجعة:', "${student.reviewGrade}"),
                _buildStudentRow('درجة الحضور:', "${student.attendanceGrade}"),
                _buildStudentRow('درجة السلوك:', "${student.behaviorGrade}"),
                _buildStudentRow('الاختبار الورقي:', "${student.paperGrade}"),
                _buildStudentRow('الاختبار الشفهي:', "${student.oralGrade}"),

                const Divider(height: 24, thickness: 1),

                // Total Score
                _buildStudentRow(
                  'المجموع الكلي:',
                  "${student.total}%",
                  valueStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Best Student Badge
        if (isBest)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                children: const [
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'أفضل طالب',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStudentRow(String label, String value,
      {TextStyle valueStyle = const TextStyle(fontSize: 14)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 83, 81, 81),
      ),
    );
  }

  Widget _buildGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() => InputDecorator(
            decoration: const InputDecoration(
              labelText: 'الحلقة',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedGroupId.value,
                onChanged: (value) {
                  if (value == null) return;
                  controller.selectedGroupId.value = value;
                  if (value == BestStudentsController.kAllGroupsId) {
                    controller.selectedGroupName.value = 'كل الحلقات';
                  } else {
                    for (final g in controller.groups) {
                      final map = g as Map<String, dynamic>;
                      if (map['id'].toString() == value) {
                        controller.selectedGroupName.value =
                            map['name']?.toString() ?? '';
                        break;
                      }
                    }
                  }
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: BestStudentsController.kAllGroupsId,
                    child: Text('كل الحلقات'),
                  ),
                  ...controller.groups.map((group) {
                    final g = group as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: g['id'].toString(),
                      child: Text(g['name']?.toString() ?? ''),
                    );
                  }),
                ],
              ),
            ),
          )),
    );
  }

  // Loading Indicator
  Widget _buildLoadingIndicator(String message) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Empty Data Indicator
  Widget _buildEmptyDataIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.hourglass_empty),
            SizedBox(height: 10),
            Text("لاتوجد بيانات", style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }

  // Hijri Month Picker for Month Search
  Widget _buildHijriMonthDatePicker(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 20),
            Text(
              "${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _selectHijriMonth(context),
          icon: const Icon(Icons.calendar_month),
        ),
      ],
    );
  }

  Future<void> _selectHijriMonth(BuildContext context) async {
    var picked = await showGlobalDatePicker(
      headerTitle: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Center(
          child: Text(
            "التقويم الهجري",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      locale: const Locale("ar", "SA"),
      context: context,
      pickerType: PickerType.JHijri,
      primaryColor: const Color(0xFF1976D2),
      backgroundColor: Colors.white,
      cancelButtonText: "إلغاء",
      okButtonText: "تأكيد",
      selectedDate: controller.selectedDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedDate.value.jhijri) {
      controller.selectedDate.value =
          JDateModel(jhijri: picked.jhijri, dateTime: picked.date);
    }
  }
}
