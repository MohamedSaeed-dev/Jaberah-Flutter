import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/monthlyPartialExamReportController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class MonthlyPartialExamReportPage extends StatelessWidget {
  final MonthlyPartialExamReportController controller =
      Get.put(MonthlyPartialExamReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Column(children: [
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => FloatingActionButton.extended(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          await controller.getReport();
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
          ]),
        ),
        appBar: AppBar(
          title: const Text('تقرير الاختبارات الجزئية الشهري'),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
          actions: [
            Obx(() => IconButton(
                  onPressed: (controller.isLoading.value ||
                          controller.reportData.isEmpty)
                      ? null
                      : () async {
                          controller.exportAsPDF(
                            "تقرير الاختبارات الجزئية الشهري - ${controller.selectedGroupName.value} - ${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
                          );
                        },
                  icon: const Icon(Icons.save, color: Colors.black),
                  tooltip: 'تصدير PDF',
                )),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => _buildHijriDatePicker(context, 'التاريخ الهجري:'),
              ),
              const SizedBox(height: 10),
              _buildGroupDropdown(),
              const SizedBox(height: 10),
              const Divider(),
              Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingIndicator();
                } else if (controller.reportData.isEmpty) {
                  return _buildEmptyDataIndicator();
                } else {
                  return Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.reportData.length,
                      itemBuilder: (context, index) {
                        return _buildItemCard(
                            controller.reportData[index], context);
                      },
                    ),
                  );
                }
              }),
            ],
          ),
        ));
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 450,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Center(
              child: Obx(() => Text(
                    " جاري تحميل تقرير الاختبارات الجزئية لشهر ${controller.selectedDate.value.jhijri!.monthName}\n لـ ${controller.selectedGroupName.value}",
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDataIndicator() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty),
            SizedBox(height: 10),
            Text("لاتوجد بيانات", style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }

  Future<void> _selectHijriDate(BuildContext context) async {
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
      controller.updateMonthReportDates();
    }
  }

  Widget _buildHijriDatePicker(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(width: 20),
            Text(
              "${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
            onPressed: () => _selectHijriDate(context),
            icon: const Icon(Icons.calendar_month))
      ],
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
                value: controller.selectedGroupId.value == 0
                    ? "0,${controller.selectedGroupName.value}"
                    : "${controller.selectedGroupId.value},${controller.selectedGroupName.value}",
                onChanged: (value) {
                  var valueMap = value!.split(',');
                  controller.selectedGroupId.value = int.parse(valueMap[0]);
                  controller.selectedGroupName.value =
                      valueMap.length > 1 ? valueMap[1] : '';
                },
                items: [
                  const DropdownMenuItem(
                    value: "0,كل الحلقات",
                    child: Text("كل الحلقات"),
                  ),
                  ...controller.groups.map((group) {
                    return DropdownMenuItem(
                      value: '${group.id},${group.name}',
                      child: Text(group.name),
                    );
                  }),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildItemCard(MonthlyPartialExamItem item, BuildContext context) {
    return Card(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.studentName} - ${item.groupName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildSectionTitle('تفاصيل الاختبار الجزئي'),
            const SizedBox(height: 10),
            _buildStudentRow('التاريخ:', item.dateHijriFormatted),
            _buildStudentRow('التقييم:', item.rate),
            _buildStudentRow('الجزء:', item.part),
            _buildStudentRow('الأداء:', item.performance.toString()),
            _buildStudentRow('الدرجة:', item.score.toString()),
            const Divider(height: 24, thickness: 1),
            _buildStudentRow(
              'المجموع الكلي:',
              item.totalScore.toString(),
              valueStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
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
        color: Colors.grey,
      ),
    );
  }
}
