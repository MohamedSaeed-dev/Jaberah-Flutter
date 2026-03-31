import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/dailyPrayersController.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class DailyPrayers extends StatelessWidget {
  final DailyPrayersController controller = Get.put(DailyPrayersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'كشف الصلوات',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildHijriDatePicker(context, 'التاريخ الهجري:'),
            const SizedBox(height: 10),
            _buildGroupDropdown(),
            Obx(() => TextField(
                  controller: controller.searchText.value,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  readOnly: controller.teacherGroups.isEmpty,
                  enabled: controller.teacherGroups.isNotEmpty,
                  decoration: InputDecoration(
                    hintText: controller.teacherGroups.isEmpty
                        ? 'تفعّل البحث بعد تعيينك في حلقة'
                        : 'ابحث عن طالب...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: controller.teacherGroups.isEmpty
                      ? null
                      : (_) => controller.applySearch(),
                )),
            const Divider(height: 30),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingDaily.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'جاري تحميل كشف الصلوات...',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }
                if (controller.dailyStudents.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mosque_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'لا يوجد طلاب لهذا اليوم أو لا توجد بيانات',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.dailyStudents.length,
                  itemBuilder: (context, index) {
                    final student = controller.dailyStudents[index];
                    return _buildStudentCard(context, student);
                  },
                );
              }),
            ),
            Obx(() => _buildPaginationControls()),
          ],
        ),
      ),
    );
  }

  Widget _buildHijriDatePicker(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 20),
            Obx(() => Text(
                  "${controller.selectedDate.value.jhijri!.day} - ${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )),
          ],
        ),
        IconButton(
          onPressed: () => _selectHijriDate(context),
          icon: const Icon(Icons.calendar_month),
        ),
      ],
    );
  }

  Future<void> _selectHijriDate(BuildContext context) async {
    var picked = await showGlobalDatePicker(
      headerTitle: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
      primaryColor: const Color.fromARGB(255, 63, 181, 108),
      backgroundColor: Colors.white,
      cancelButtonText: "إلغاء",
      okButtonText: "تأكيد",
      selectedDate: controller.selectedDate.value,
    );

    if (picked != null &&
        picked.jhijri != controller.selectedDate.value.jhijri) {
      controller.setSelectedDate(
          JDateModel(jhijri: picked.jhijri, dateTime: picked.date));
    }
  }

  Widget _buildGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Obx(() {
        if (controller.teacherGroups.isEmpty) {
          return InputDecorator(
            decoration: const InputDecoration(
              labelText: 'الحلقة',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              controller.isLoadingGroups.value ? '...' : 'لا توجد حلقات',
              style: TextStyle(
                fontSize: 16,
                color: controller.isLoadingGroups.value
                    ? Colors.grey
                    : Colors.black87,
              ),
            ),
          );
        }
        return InputDecorator(
          decoration: const InputDecoration(
            labelText: 'الحلقة',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: controller.selectedGroupId.value,
              isExpanded: true,
              hint: const Text('كل الحلقات'),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('كل الحلقات')),
                ...controller.teacherGroups.map((g) => DropdownMenuItem<int?>(
                    value: g.id, child: Text(g.groupName))),
              ],
              onChanged: (v) => controller.setGroupFilter(v),
            ),
          ),
        );
      }),
    );
  }

  String rakatWord(int n) {
    if (n == 0) return 'ف';
    if (n == 1) return 'ركعة';
    if (n == 2) return 'ركعتان';
    if (n >= 3 && n <= 10) return 'ركعات';
    return 'ركعة';
  }

  Widget _buildStudentCard(BuildContext context, StudentDailyPrayer student) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _showEditDialog(context, student),
        borderRadius: BorderRadius.circular(12.0),
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
                      student.studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (student.groupName != null &&
                      student.groupName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 63, 181, 108)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        student.groupName!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: student.prayers.map((p) {
                  final info = p.attendanceInfo;
                  final name = p.prayerName.isNotEmpty ? p.prayerName : 'صلاة';
                  final text = info.rakatsCount == null ? '-' : info.rakatsCount! > 0
                      ? '${info.rakatsCount} ${rakatWord(info.rakatsCount!)} / ${p.defaultRakat} ${rakatWord(p.defaultRakat)} ${info.isInGroup ? '(جماعة)' : ''}'
                      : 'فائتة';
                  return Chip(
                    label: Text(
                      '$name: $text',
                      style: const TextStyle(fontSize: 12),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final fetched = (controller.pageNumber.value - 1) * controller.pageSize +
        controller.dailyStudents.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.hasPrevious.value &&
                    !controller.isLoadingDaily.value
                ? () => controller.prevPage()
                : null,
          ),
          Text(
            '$fetched من ${controller.totalCount.value}',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: controller.hasNext.value &&
                    !controller.isLoadingDaily.value
                ? () => controller.nextPage()
                : null,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, StudentDailyPrayer student) {
    final rakatControllers = <int, TextEditingController>{};
    final inGroupByPrayerId = <int, bool>{};

    for (final p in controller.prayersList) {
      final sp = student.prayers.firstWhereOrNull((s) {
        if (s.prayerId != null && s.prayerId == p.id) return true;
        final pName = (p.nameAr).trim();
        final sName = (s.prayerName).trim();
        return pName.isNotEmpty &&
            sName.isNotEmpty &&
            (pName == sName || pName.contains(sName) || sName.contains(pName));
      });
      final rakats = sp?.attendanceInfo.rakatsCount ?? 0;
      final inGroup = sp?.attendanceInfo.isInGroup ?? false;
      rakatControllers[p.id] = TextEditingController(text: '$rakats');
      inGroupByPrayerId[p.id] = inGroup;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            return AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              title: Text('تعديل كشف الصلوات — ${student.studentName}'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: (screenWidth * 0.9).clamp(320.0, 520.0),
                  maxWidth: 520,
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: controller.prayersList.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: controller.prayersList.map((prayer) {
                                final ctrl = rakatControllers[prayer.id];
                                final ig =
                                    inGroupByPrayerId[prayer.id] ?? false;

                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side:
                                        const BorderSide(color: Colors.black12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                prayer.nameAr.isNotEmpty
                                                    ? prayer.nameAr
                                                    : '—',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              'عدد الركعات: ${prayer.defaultRakats}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: ctrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'ركعات',
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  errorMaxLines: 2,
                                                ),
                                                validator: (value) {
                                                  final v =
                                                      int.tryParse(value ?? '');
                                                  if (v == null) {
                                                    return 'رقم فقط';
                                                  }

                                                  if (v < 0) {
                                                    return 'يجب أن يكون\nأكبر من 0';
                                                  }

                                                  if (v >
                                                      prayer.defaultRakats) {
                                                    return 'يجب أن يكون أقل\nمن ${prayer.defaultRakats}';
                                                  }

                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Checkbox(
                                                  value: ig,
                                                  onChanged: (v) {
                                                    setState(() {
                                                      inGroupByPrayerId[prayer
                                                          .id] = v ?? false;
                                                      if (v == true) {
                                                        rakatControllers[prayer.id]
                                                            ?.text =
                                                            '${prayer.defaultRakats}';
                                                      }
                                                    });
                                                  },
                                                  activeColor:
                                                      const Color.fromARGB(
                                                          255, 63, 181, 108),
                                                ),
                                                const Text('جماعة'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FocusScope.of(ctx).unfocus();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('إلغاء'),
                ),
                Obx(() => ElevatedButton(
                      onPressed: controller.isUpserting.value
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final prayers = controller.prayersList.map((p) {
                                final rid = int.tryParse(
                                        rakatControllers[p.id]?.text ?? '') ??
                                    0;

                                final ig = inGroupByPrayerId[p.id] ?? false;

                                return PrayerUpdateDTO(
                                  prayerId: p.id,
                                  rakatCount: rid.clamp(0, p.defaultRakats),
                                  isInGroup: ig,
                                );
                              }).toList();

                              await controller.upsertDaily(
                                studentId: student.studentId,
                                prayers: prayers,
                              );

                              if (ctx.mounted) {
                                FocusScope.of(ctx).unfocus();
                                Navigator.of(ctx).pop();
                              }
                            },
                      child: Text(controller.isUpserting.value
                          ? 'جاري الحفظ...'
                          : 'حفظ'),
                    )),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Wait 2 frames so the dialog is fully removed before disposing controllers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final c in rakatControllers.values) {
            try {
              c.dispose();
            } catch (_) {}
          }
        });
      });
    });
  }
}
