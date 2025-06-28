import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/editFollowStudentController.dart';

class EditFollowStudent extends StatelessWidget {
  final controller = Get.put(EditFollowStudentController());
  final formKey = GlobalKey<FormState>();
  EditFollowStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: FloatingActionButton.extended(
            icon: Icon(
              Icons.save,
              color: Colors.black,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                controller.upsertFollowStudent();
              }
            },
            label: Obx(() => Text(
                  controller.isLoading.value ? "جاري الحفظ..." : "حـفـظ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
            backgroundColor: const Color.fromARGB(255, 63, 181, 108),
          ),
        ),
        appBar: AppBar(
          title: Text(
            'تعديل بيانات التسميع',
            style: TextStyle(
              fontFamily: 'GE_SS_Two',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 63, 181, 108),
        ),
        body: Container(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.studentName,
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${controller.date.jhijri!.year}- ${controller.date.jhijri!.monthName} - ${controller.date.jhijri!.day}",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الحـفـظ",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: Obx(
                              () => DropdownButtonFormField<String>(
                                items: controller.quranSurahsDropdown,
                                value: controller.selectedSurahFromSave.value,
                                onChanged: (value) {
                                  controller.selectedSurahFromSave.value =
                                      value!;
                                      controller.selectedSurahToSave.value = value;
                                },
                                decoration: InputDecoration(
                                  labelText: "من سورة",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: controller.verseFromSurah.value,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "آية",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "برجاء إدخال رقم الآية";
                                  }
                                  if (int.tryParse(value) == null) {
                                    return "يجب إدخال رقم صحيح";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Obx(
                              () => DropdownButtonFormField<String>(
                                items: controller.quranSurahsDropdown,
                                value: controller.selectedSurahToSave.value,
                                onChanged: (value) {
                                  controller.selectedSurahToSave.value = value!;
                                },
                                decoration: InputDecoration(
                                  labelText: "الى سورة",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: controller.verseToSurah.value,
                                decoration: InputDecoration(
                                  labelText: "آية",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "يرجاء إدخال رقم الآية";
                                  }
                                  if (int.tryParse(value) == null) {
                                    return "يجب إدخال رقم صحيح";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                items: const [
                                  DropdownMenuItem(
                                    child: Text("---"),
                                    value: "",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("ممتاز"),
                                    value: "ممتاز",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("جيد جداً"),
                                    value: "جيد جداً",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("جيد"),
                                    value: "جيد",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("مقبول"),
                                    value: "مقبول",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("ضعيف"),
                                    value: "ضعيف",
                                  ),
                                ],
                                value: controller.selectedRateSave.value,
                                onChanged: (value) {
                                  controller.selectedRateSave.value = value!;
                                },
                                decoration: InputDecoration(
                                  labelText: "التقدير",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: controller.pagesSave.value,
                                decoration: InputDecoration(
                                  labelText: "عدد الصفحات",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  var num = double.tryParse(value!);
                                  if (num! < 0) {
                                    return "يجب إدخال عدد صفحات صحيح ";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(),
                        Text(
                          "المراجعة",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Obx(
                              () => DropdownButtonFormField<String>(
                                items: controller.quranSurahsDropdown,
                                value: controller.selectedSurahFromReview.value,
                                onChanged: (value) {
                                  controller.selectedSurahFromReview.value =
                                      value!;
                                      controller.selectedSurahToReview.value =
                                      value;
                                },
                                decoration: InputDecoration(
                                  labelText: "من سورة",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: controller.verseFromReview.value,
                                decoration: InputDecoration(
                                  labelText: "آية",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  var num = int.tryParse(value!);
                                  if (num! < 0) {
                                    return "يجب إدخال ايه صحيحه ";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Obx(
                              () => DropdownButtonFormField<String>(
                                items: controller.quranSurahsDropdown,
                                value: controller.selectedSurahToReview.value,
                                onChanged: (value) {
                                  controller.selectedSurahToReview.value =
                                      value!;
                                },
                                decoration: InputDecoration(
                                  labelText: "الى سورة",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: controller.verseToReview.value,
                                decoration: InputDecoration(
                                  labelText: "آية",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  var num = int.tryParse(value!);
                                  if (num! < 0) {
                                    return "يجب إدخال ايه صحيحه ";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                items: const [
                                  DropdownMenuItem(
                                    child: Text("---"),
                                    value: "",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("ممتاز"),
                                    value: "ممتاز",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("جيد جداً"),
                                    value: "جيد جداً",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("جيد"),
                                    value: "جيد",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("مقبول"),
                                    value: "مقبول",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("ضعيف"),
                                    value: "ضعيف",
                                  ),
                                ],
                                value: controller.selectedRateReview.value,
                                onChanged: (value) {
                                  controller.selectedRateReview.value = value!;
                                },
                                decoration: InputDecoration(
                                  labelText: "التقدير",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: controller.pageReview.value,
                                decoration: InputDecoration(
                                  labelText: "عدد الصفحات",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  var num = double.tryParse(value!);
                                  if (num! < 0) {
                                    return "يجب إدخال عدد صفحات صحيح ";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: controller.attendance.value,
                              decoration: InputDecoration(
                                labelText: "الحضور",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                var num = double.tryParse(value!);
                                if (num! < 0 || num > 1) {
                                  return "يجب إدخال حضور صحيح ";
                                }
                                return null;
                              },
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                                child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: controller.behavior.value,
                              decoration: InputDecoration(
                                labelText: "السلوك",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                var num = double.tryParse(value!);
                                if (num! < 0 || num > 1) {
                                  return "يجب إدخال سلوك صحيح ";
                                }
                                return null;
                              },
                            ))
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.notes.value,
                          decoration: InputDecoration(
                            labelText: "ملاحظات",
                            border: OutlineInputBorder(),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
