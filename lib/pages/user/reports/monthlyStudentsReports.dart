import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/monthlyStudentsReports.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class MonthlyStudentsReports extends StatelessWidget {
  final MonthlyStudentsReportsController controller =
      Get.put(MonthlyStudentsReportsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Column(children: [
            SizedBox(
                width: double.infinity,
                child: Obx(
                  () => FloatingActionButton.extended(
                    onPressed: controller.selectedGroupId.value == 0 ||
                            controller.isLoading.value
                        ? null
                        : () async {
                            await controller.getMonthlyReport();
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
                )),
          ]),
        ),
        appBar: AppBar(
          title: const Text('التقرير الشهري'),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
          actions: [
            Obx(() => IconButton(
                  icon: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.black,
                  ),
                  onPressed: controller.isLoading.value ||
                          controller.selectedGroupId.value == 0
                      ? null
                      : () {
                          _showBooksPopup(Get.context!);
                        },
                ))
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
                } else if (controller.monthlyReport.value.data.isEmpty) {
                  return _buildEmptyDataIndicator();
                } else {
                  return Expanded(
                    // Wrap ListView with Expanded for scrollable area
                    child: ListView.builder(
                      // No need for `shrinkWrap` here since it's inside Expanded
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.monthlyReport.value.data.length,
                      itemBuilder: (context, index) {
                        return _buildStudentsCard(
                            controller.monthlyReport.value.data[index],
                            context);
                      },
                    ),
                  );
                }
              }),
            ],
          ),
        ));
  }

  void _showBooksPopup(BuildContext context) {
    final books = controller.monthlyReport.value.books;
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16), // Reduce side padding
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.95, // almost full width
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("كتب الحلقة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 400, // adjust if needed
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final book = books[index];
                      return ListTile(
                        leading: const Icon(Icons.book),
                        title: Text(
                          book.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "من ${book.from} إلى ${book.to} — الشهر: ${book.month.year}-${book.month.month.toString().padLeft(2, '0')}",
                          textAlign: TextAlign.right,
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Get.back();
                                _showAddOrEditBookDialog(context, book: book);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await controller.deleteBook(book.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _showAddOrEditBookDialog(context);
                      },
                      child: const Text("إضافة كتاب"),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("إغلاق"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }


  void _showAddOrEditBookDialog(BuildContext context, {BooksData? book}) {
    final titleController = TextEditingController(text: book?.title ?? '');
    final fromController = TextEditingController(text: book?.from ?? '');
    final toController = TextEditingController(text: book?.to ?? '');

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during loading
      builder: (_) => AlertDialog(
        title: Text(book == null ? "إضافة كتاب" : "تعديل كتاب"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "عنوان الكتاب"),
              ),
              TextField(
                controller: fromController,
                decoration: const InputDecoration(labelText: "من"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: toController,
                decoration: const InputDecoration(labelText: "إلى"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isLoading.value ? null : () => Get.back(),
                child: const Text("إلغاء"),
              )),
          Obx(() => TextButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        final from = fromController.text.trim();
                        final to = toController.text.trim();

                        if (title.isEmpty || from.isEmpty || to.isEmpty) {
                          Get.snackbar("خطأ", "يرجى تعبئة جميع الحقول");
                          return;
                        }

                        if (book == null) {
                          await controller.addBook(
                              title: title, from: from, to: to);
                        } else {
                          await controller.updateBook(
                            bookId: book.id,
                            title: title,
                            from: from,
                            to: to,
                          );
                        }
                      },
                child: Text(controller.isLoading.value
                    ? (book == null ? 'جاري الاضافة...' : 'جاري التحديث...')
                    : (book == null ? "إضافة" : "تحديث")),
              )),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 450,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Center(
              child: Obx(() => Text(
                    " جاري تحميل التقرير الشهري لشهر ${controller.selectedDate.value.jhijri!.monthName}\n لـ ${controller.selectedGroupName.value}",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )),
            ),
          ],
        ),
      ),
    );
  }

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

  // Builds the date picker for selecting the report date
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
      selectedDate: controller.selectedDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedDate.value.jhijri) {
      controller.selectedDate.value = JDateModel(jhijri: picked.jhijri);
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
            SizedBox(
              width: 20,
            ),
            Text(
              "${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
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
                value: controller.selectedGroupId.value != 0
                    ? "${controller.selectedGroupId.value},${controller.selectedGroupName.value}"
                    : controller.groups.isNotEmpty
                        ? "${controller.groups[0].id},${controller.groups[0].groupName}"
                        : null,
                onChanged: (value) {
                  var valueMap = value.toString().split(',');
                  controller.selectedGroupId.value = int.parse(valueMap[0]);
                  controller.selectedGroupName.value = valueMap[1];
                },
                items: controller.groups.map((group) {
                  return DropdownMenuItem(
                    value: '${group.id},${group.groupName}',
                    child: Text(group.groupName),
                  );
                }).toList(),
              ),
            ),
          )),
    );
  }

  Widget _buildStudentsCard(MonthlyReportModel student, BuildContext context) {
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
            // Student Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  student.studentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      final formKey = GlobalKey<FormState>();
                      var paperExamController = TextEditingController(
                          text: student.paperGrade.toString());
                      var oralExamController = TextEditingController(
                          text: student.oralGrade.toString());
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                "تعديل الاختبار الورقي والشفهي",
                                style: TextStyle(fontSize: 20),
                              ),
                              content: Form(
                                key: formKey,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: paperExamController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "الاختبار الورقي",
                                            prefixIcon: Icon(Icons.book)),
                                        validator: (value) {
                                          var val =
                                              double.tryParse(value ?? "");
                                          if (val != null &&
                                              (val > 20 || val < 0)) {
                                            return 'ادخل قيمه من 0 الى 20';
                                          } else if (val == null) {
                                            return 'ادخل قيمة صحيحه';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                        controller: oralExamController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "الاختبار الشفهي",
                                            prefixIcon: Icon(Icons.bookmark)),
                                        validator: (value) {
                                          var val =
                                              double.tryParse(value ?? "");
                                          if (val != null &&
                                              (val > 10 || val < 0)) {
                                            return 'ادخل قيمه من 0 الى 10';
                                          } else if (val == null) {
                                            return 'ادخل قيمة صحيحه';
                                          }
                                          return null;
                                        },
                                      ),
                                    ]),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text("الغاء")),
                                Obx(
                                  () => TextButton(
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          var oral = double.tryParse(
                                              oralExamController.text);

                                          var paper = double.tryParse(
                                              paperExamController.text);

                                          await controller.UpdateExams(
                                              followStudentId:
                                                  student.followStudentId,
                                              paperExam: paper,
                                              oralExam: oral);
                                        }
                                      },
                                      child: Text(
                                          controller.isLoadingUpdate.value
                                              ? 'جاري الحفظ...'
                                              : "حـفـظ")),
                                )
                              ],
                            );
                          });
                    },
                    icon: Icon(Icons.edit))
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            // Saving and Reviewing sections
            _buildSectionTitle('تفاصيل التسميع'),
            const SizedBox(height: 10),
            _buildStudentRowSaveReview('الحفظ:',
                " من سورة ${student.saveFromSurah} آيه ${student.saveFromVerse} إلى سورة ${student.saveToSurah} آيه ${student.saveToVerse}"),
            _buildStudentRowSaveReview('مراجعة:',
                " من سورة ${student.reviewFromSurah} آيه ${student.reviewFromVerse} إلى سورة ${student.reviewToSurah} آيه ${student.reviewToVerse}"),

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
    );
  }

// Builds each row for student details with custom styling
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

  Widget _buildStudentRowSaveReview(String label, String value,
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
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

// Section title styling
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
