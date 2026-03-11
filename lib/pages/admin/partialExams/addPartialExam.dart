import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/addPartialExamController.dart';

class AddPartialExam extends StatelessWidget {
  final AddPartialExamController controller =
      Get.put(AddPartialExamController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEditMode ? 'تعديل تسميع جزئي' : 'إضافة تسميع جزئي',
          style: TextStyle(
            fontFamily: 'GE_SS_Two',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Name
            _buildInfoRow('اسم الطالب:', controller.studentName),
            Divider(),

            // Group Name
            _buildInfoRow('الحلقة:', controller.groupName),
            Divider(),

            // Date Display (Read-only)
            Obx(() => _buildDateDisplay()),
            Divider(),
            SizedBox(height: 20),

            // Questions Section - 5 rows × 2 questions
            Text(
              'الأسئلة (الدرجة من 1.5 لكل سؤال)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Row 1
            _buildQuestionRow(
              'السؤال الأول',
              controller.question1Controller.value,
              'السؤال الثاني',
              controller.question2Controller.value,
            ),

            // Row 2
            _buildQuestionRow(
              'السؤال الثالث',
              controller.question3Controller.value,
              'السؤال الرابع',
              controller.question4Controller.value,
            ),

            // Row 3
            _buildQuestionRow(
              'السؤال الخامس',
              controller.question5Controller.value,
              'السؤال السادس',
              controller.question6Controller.value,
            ),

            // Row 4
            _buildQuestionRow(
              'السؤال السابع',
              controller.question7Controller.value,
              'السؤال الثامن',
              controller.question8Controller.value,
            ),

            // Row 5
            _buildQuestionRow(
              'السؤال التاسع',
              controller.question9Controller.value,
              'السؤال العاشر',
              controller.question10Controller.value,
            ),

            SizedBox(height: 20),
            Divider(thickness: 2),
            SizedBox(height: 20),

            // Performance Section
            _buildScoreField(
              'الأداء',
              'الدرجة من 5',
              controller.performanceController.value,
              5.0,
            ),

            SizedBox(height: 15),

            // Total Section (Full Width)
            _buildTotalField(),

            SizedBox(height: 20),

            // tester and Part
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'المختبر',
                    'نص',
                    controller.testerController.value,
                    isNumber: false,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    'الجزء',
                    'نص',
                    controller.partController.value,
                    isNumber: false,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Rate Dropdown
            _buildRateDropdown(),

            SizedBox(height: 20),

            // Notes
            _buildTextField(
              'الملاحظات',
              'نص',
              controller.notesController.value,
              isNumber: false,
              maxLines: 3,
            ),

            SizedBox(height: 30),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ||
                            controller.totalScore.value == 0
                        ? null
                        : () {
                            controller.submitPartialExam();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 63, 181, 108),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            controller.isEditMode
                                ? 'تحديث التسميع الجزئي'
                                : 'حفظ التسميع الجزئي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            'التاريخ:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          Text(
            "${controller.selectedDate.value.jhijri!.day} - ${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionRow(
    String label1,
    TextEditingController controller1,
    String label2,
    TextEditingController controller2,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Expanded(
            child: _buildScoreField(label1, 'الدرجة من 1.5', controller1, 1.5),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildScoreField(label2, 'الدرجة من 1.5', controller2, 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreField(
    String label,
    String hint,
    TextEditingController controller,
    double maxValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hint,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    double? val = double.tryParse(value);
                    if (val != null && val > maxValue) {
                      controller.text = maxValue.toString();
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }
                  }
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المجموع الكلي',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue[50]!,
                Colors.blue[100]!,
              ],
            ),
            border: Border.all(color: Colors.blue[400]!, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 0.5,
                blurRadius: 3,
              ),
            ],
          ),
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grade,
                color: Colors.blue[700],
                size: 22,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'الدرجة الكلية',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Obx(() => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            controller.totalScore.value.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              ' / 20',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hint,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              TextField(
                controller: controller,
                keyboardType:
                    isNumber ? TextInputType.number : TextInputType.text,
                maxLines: maxLines,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقدير',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        Obx(() => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: DropdownButton<String>(
                value: controller.rateController.value,
                isExpanded: true,
                underline: SizedBox(),
                items: controller.rateOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.rateController.value = newValue;
                  }
                },
              ),
            )),
      ],
    );
  }
}
