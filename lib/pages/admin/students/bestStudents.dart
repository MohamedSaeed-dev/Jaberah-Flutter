import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/bestStudentsController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class BestStudentsReport extends StatelessWidget {
  final BestStudentsController controller = Get.put(BestStudentsController());

  BestStudentsReport({super.key});

  @override
  Widget build(BuildContext context) {
    BuildContext c = context;
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Builder(
            builder: (BuildContext newContext) {
              c = newContext;
              final tabController = DefaultTabController.of(newContext);
              return Obx(()=> FloatingActionButton.extended(
                    onPressed: controller.selectedGroupId.value.isEmpty || controller.isLoading.value
                        ? null
                        : () async {
                      if (tabController.index == 0) {
                        await controller.getBestStudentsForMonthByGroupReport();
                      } else if (tabController.index == 1) {
                        await controller.getBestStudentsForMonthReport();
                      }
                    },
                    label: Text(
                      "عـرض الـتـقـريـر",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(
                      Icons.document_scanner_outlined,
                      color: Colors.black,
                    ),
                    backgroundColor: const Color.fromARGB(255, 63, 181, 108),
                  ));
            },
          ),
        ),
        appBar: AppBar(
          actions: [
            Obx(() => IconButton(
                onPressed: (controller.isLoading.value ||
                        (controller.bestStudentsInMonthReport.isEmpty &&
                            controller
                                .bestStudentsInMonthOfGroupReport.isEmpty))
                    ? null
                    : () {
                        TabController tabController =
                            DefaultTabController.of(c);
                        if (tabController.index == 0) {
                          controller.exportAsPDF(
                              "تقرير الطلاب المتميزون لـ ${controller.selectedGroupName.value} لشهر ${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
                              controller.bestStudentsInMonthOfGroupReport);
                        } else if (tabController.index == 1) {
                          controller.exportAsPDF(
                              "تقرير الطلاب المتميزون على جميع الحلقات لشهر ${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
                              controller.bestStudentsInMonthReport);
                        }
                      },
                icon:const Icon(
                  Icons.save,
                  color: Colors.black,
                ))),
            PopupMenuButton(
              iconColor: Colors.black,
              icon: const Icon(Icons.numbers),
              onSelected: (value) {
              controller.take.value = value;
            }, itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text("5"),
                  value: 5,
                ),
                PopupMenuItem(
                  child: Text("6"),
                  value: 6,
                ),
                PopupMenuItem(
                  child: Text("7"),
                  value: 7,
                ),
                PopupMenuItem(
                  child: Text("8"),
                  value: 8,
                ),
                PopupMenuItem(
                  child: Text("9"),
                  value: 9,
                ),
                PopupMenuItem(
                  child: Text("10"),
                  value: 10,
                ),
              ];
            })
          ],
          title: const Text('تقرير الطلاب المتميزون'),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'بحسب حلقة معينة'),
              Tab(text: 'على جميع الحلقات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildClassAndMonthSearch(context),
            _buildMonthAcrossClassesSearch(context),
          ],
        ),
      ),
    );
  }

  // Tab: Best Students by Specific Class and Month
  Widget _buildClassAndMonthSearch(BuildContext context) {
    return Padding(
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
                  "جاري تحميل تقرير الطلاب المتميزين لحلقة ${controller.selectedGroupName.value}");
            } else if (controller.bestStudentsInMonthOfGroupReport.isEmpty) {
              return _buildEmptyDataIndicator();
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: controller.bestStudentsInMonthOfGroupReport.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildStudentsCard(
                          controller.bestStudentsInMonthOfGroupReport[index],
                          true);
                    }
                    return _buildStudentsCard(
                        controller.bestStudentsInMonthOfGroupReport[index],
                        false);
                  },
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  // Tab: Best Students Across All Classes by Month
  Widget _buildMonthAcrossClassesSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => _buildHijriMonthDatePicker(context, 'الشهر الهجري:')),
          const Divider(),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingIndicator(
                  "جاري تحميل تقرير الطلاب المتميزين على جميع الحلقات");
            } else if (controller.bestStudentsInMonthReport.isEmpty) {
              return _buildEmptyDataIndicator();
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: controller.bestStudentsInMonthReport.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildStudentsCard(
                          controller.bestStudentsInMonthReport[index], true);
                    }
                    return _buildStudentsCard(
                        controller.bestStudentsInMonthReport[index], false);
                  },
                ),
              );
            }
          }),
        ],
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
                  margin: EdgeInsets.only(top: 10),
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
            decoration: InputDecoration(
              labelText: 'الحلقة',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                value: controller.selectedGroupId.value.isNotEmpty
                    ? controller.selectedGroupId.value
                    : controller.groups.isNotEmpty
                        ? controller.groups[0]['id'].toString()
                        : null,
                onChanged: (value) {
                  controller.selectedGroupId.value = value.toString();
                },
                items: controller.groups.map((group) {
                  return DropdownMenuItem(
                    value: group["id"].toString(),
                    child: Text(group['name']),
                  );
                }).toList(),
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
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(fontSize: 20),
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
            SizedBox(width: 20),
            Text(
              "${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _selectHijriMonth(context),
          icon: Icon(Icons.calendar_month),
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
      controller.selectedDate.value = JDateModel(jhijri: picked.jhijri, dateTime: picked.date);
      // await controller.getBestStudentsByClassAndMonth();
    }
  }
}
