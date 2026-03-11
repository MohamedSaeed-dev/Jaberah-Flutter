import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/studentsPartialExamsController.dart';
import 'package:jaberah/pages/admin/partialExams/addPartialExam.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class StudentsPartialExams extends StatelessWidget {
  final StudentsPartialExamsController controller =
      Get.put(StudentsPartialExamsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختبارات الجزئي',
          style: TextStyle(
            fontFamily: 'GE_SS_Two',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
        actions: [
          Obx(() => IconButton(
              onPressed: (controller.isLoading.value ||
                      controller.students.where((s) => s.hasExam).isEmpty)
                  ? null
                  : () async {
                      var hijriDate = controller.selectedDate.value.jhijri!;
                      controller.exportAsPDF(
                          "تقرير الاختبار الجزئي لـ ${controller.name} - ${hijriDate.day} ${hijriDate.monthName} ${hijriDate.year}");
                    },
              icon: Icon(
                Icons.save,
                color: Colors.black,
              ))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Date Picker
            Obx(() => _buildHijriDatePicker(context)),
            SizedBox(height: 10),
            Obx(() => TextField(
                  controller: controller.searchText.value,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن طالب...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
            const Divider(
              height: 30,
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text(
                          "جاري تحميل الطلاب...",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (controller.students.isEmpty &&
                  !controller.isLoading.value) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty),
                        SizedBox(
                          height: 10,
                        ),
                        Text("لاتوجد بيانات", style: TextStyle(fontSize: 20))
                      ],
                    ),
                  ),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.filteredStudents.length,
                    itemBuilder: (context, index) {
                      return _buildStudentCard(
                          controller.filteredStudents[index], context);
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

  Widget _buildHijriDatePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'التاريخ الهجري:',
              style: const TextStyle(fontSize: 15),
            ),
            SizedBox(width: 20),
            Text(
              "${controller.selectedDate.value.jhijri!.day} - ${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
            onPressed: () => _selectHijriDate(context),
            icon: Icon(Icons.calendar_month))
      ],
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
      await controller.getStudents();
    }
  }

  Widget _buildStudentCard(PartialExamStudent student, BuildContext context) {
    return GestureDetector(
      onTap: student.hasExam
          ? () {
              _showExamDetails(context, student);
            }
          : null,
      child: Card(
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
              // Student Name and Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      student.studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> arguments = {
                        "studentId": student.studentId,
                        "studentName": student.studentName,
                        "groupName": controller.name,
                        "selectedDate": controller.selectedDate.value,
                      };

                      // إذا كان يوجد اختبار، أضف بياناته للتعديل
                      if (student.hasExam) {
                        arguments["examData"] = {
                          "examId": student.examId,
                          "question1": student.question1,
                          "question2": student.question2,
                          "question3": student.question3,
                          "question4": student.question4,
                          "question5": student.question5,
                          "question6": student.question6,
                          "question7": student.question7,
                          "question8": student.question8,
                          "question9": student.question9,
                          "question10": student.question10,
                          "performance": student.performance,
                          "tester": student.tester,
                          "part": student.part,
                          "rate": student.rate,
                          "notes": student.notes,
                        };
                      }

                      var result = await Get.to(() => AddPartialExam(),
                          arguments: arguments);

                      // إعادة تحميل البيانات بعد الإضافة أو التعديل
                      if (result == true) {
                        controller.isLoading.value = true;
                        await controller.getStudents();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: student.hasExam
                          ? Colors.blue[600]
                          : const Color.fromARGB(255, 63, 181, 108),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          student.hasExam ? Icons.edit : Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          student.hasExam ? 'تعديل' : 'إضافة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 20),

              // Questions Grid
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأسئلة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 5,
                      childAspectRatio: 1.3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        _buildQuestionBox('س1', student.question1 ?? 0),
                        _buildQuestionBox('س2', student.question2 ?? 0),
                        _buildQuestionBox('س3', student.question3 ?? 0),
                        _buildQuestionBox('س4', student.question4 ?? 0),
                        _buildQuestionBox('س5', student.question5 ?? 0),
                        _buildQuestionBox('س6', student.question6 ?? 0),
                        _buildQuestionBox('س7', student.question7 ?? 0),
                        _buildQuestionBox('س8', student.question8 ?? 0),
                        _buildQuestionBox('س9', student.question9 ?? 0),
                        _buildQuestionBox('س10', student.question10 ?? 0),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Performance and Total
              Row(
                children: [
                  Expanded(
                    child: _buildInfoBox('الأداء',
                        student.performance?.toString() ?? '0', '/ 5'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoBox('المجموع',
                        student.totalScore?.toString() ?? '0', '/ 20',
                        isTotal: true),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Additional Info (Rate, tester, Part)
              if (student.hasExam) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailBox(
                        'التقدير',
                        student.rate ?? 'ممتاز',
                        Icons.star,
                        _getRateColor(student.rate ?? 'ممتاز'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailBox(
                        'المختبر',
                        student.tester ?? '-',
                        Icons.book_outlined,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailBox(
                        'الجزء',
                        student.part ?? '-',
                        Icons.class_outlined,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'اضغط لعرض التفاصيل الكاملة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionBox(String label, double? value) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value?.toString() ?? '0',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, String suffix,
      {bool isTotal = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTotal ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: isTotal ? Colors.blue[200]! : Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isTotal ? Colors.blue[700] : Colors.black,
                ),
              ),
              Text(
                ' $suffix',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBox(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getRateColor(String rate) {
    switch (rate) {
      case 'ممتاز':
        return Colors.green[700]!;
      case 'جيد جداً':
        return Colors.green[500]!;
      case 'جيد':
        return Colors.blue[600]!;
      case 'مقبول':
        return Colors.orange[600]!;
      case 'ضعيف':
        return Colors.red[600]!;
      default:
        return Colors.grey[700]!;
    }
  }

  void _showExamDetails(BuildContext context, PartialExamStudent student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'تفاصيل التسميع الجزئي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[700]),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Name
                        Text(
                          student.studentName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Divider(height: 30, thickness: 1),

                        // Questions Section
                        Text(
                          'الأسئلة العشرة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              // الصف الأول: س1 - س5
                              Row(
                                children: [
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س1', student.question1 ?? 0)),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س2', student.question2 ?? 0)),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س3', student.question3 ?? 0)),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س4', student.question4 ?? 0)),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س5', student.question5 ?? 0)),
                                ],
                              ),
                              SizedBox(height: 12),
                              // الصف الثاني: س6 - س10
                              Row(
                                children: [
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س6', student.question6 ?? 0)),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س7', student.question7 ?? 0)),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س8', student.question8 ?? 0)),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س9', student.question9 ?? 0)),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: _buildQuestionDetail(
                                          'س10', student.question10 ?? 0)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),
                        Divider(thickness: 1),
                        SizedBox(height: 20),

                        // Scores and Info
                        _buildInfoRow(
                            'الأداء', '${student.performance ?? 0} / 5'),
                        SizedBox(height: 12),
                        _buildInfoRow(
                            'المجموع', '${student.totalScore ?? 0} / 20'),
                        SizedBox(height: 12),
                        _buildInfoRow('المختبر', student.tester ?? '-'),
                        SizedBox(height: 12),
                        _buildInfoRow('الجزء', student.part ?? '-'),
                        SizedBox(height: 12),
                        _buildInfoRow('التقدير', student.rate ?? 'ممتاز'),

                        SizedBox(height: 20),
                        Divider(thickness: 1),
                        SizedBox(height: 20),

                        // Notes Section
                        Text(
                          'الملاحظات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: 60,
                            maxHeight: 120,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              student.notes ?? 'لا توجد ملاحظات',
                              style: TextStyle(
                                fontSize: 14,
                                color: student.notes != null
                                    ? Colors.black87
                                    : Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionDetail(String label, double value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            '/ 1.5',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
