import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/cleaningLogController.dart';
import 'package:jaberah/models/global/snackbars.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

const _primaryColor = Color.fromARGB(255, 63, 181, 108);

class CleaningLog extends StatelessWidget {
  final CleaningLogController controller = Get.put(CleaningLogController());

  CleaningLog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'كشف النظافة',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildHijriDatePicker(context, 'التاريخ الهجري:'),
            const SizedBox(height: 10),
            _buildGroupDropdown(),
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
                          'جاري تحميل كشف النظافة...',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }
                if (controller.dailyTasks.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cleaning_services_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'لا توجد مهمات نظافة',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.dailyTasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(
                        context, controller.dailyTasks[index]);
                  },
                );
              }),
            ),
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
      primaryColor: _primaryColor,
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

  Widget _buildTaskCard(BuildContext context, DailyCleaningTask task) {
    final log = task.log;
    final isLocked = !task.isEditableByMe;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: isLocked ? null : () => _showAssignDialog(context, task),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLocked)
                    const Icon(Icons.lock_outline,
                        size: 18, color: Colors.grey)
                  else
                    const Icon(Icons.edit_outlined,
                        size: 18, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              if (log == null)
                const Row(
                  children: [
                    Icon(Icons.person_off_outlined,
                        size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'غير مسندة',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                )
              else ...[
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        log.studentName,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (log.groupName != null && log.groupName!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          log.groupName!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      log.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: log.isCompleted ? _primaryColor : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.isCompleted ? 'أنجزت' : 'لم تنجز',
                      style: TextStyle(
                        fontSize: 14,
                        color: log.isCompleted ? _primaryColor : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (log.notes != null && log.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'ملاحظات: ${log.notes}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ],
              if (isLocked) ...[
                const SizedBox(height: 8),
                const Text(
                  'هذه المهمة مسندة لحلقة أخرى',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, DailyCleaningTask task) {
    final notesController =
        TextEditingController(text: task.log?.notes ?? '');
    final selectedStudentId = Rxn<int>(task.log?.studentId);
    final isCompleted = (task.log?.isCompleted ?? false).obs;

    controller.searchText.value.clear();
    controller.studentsPageNumber.value = 1;
    controller.loadAssignableStudents();

    showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Text('${task.taskName} — إسناد الطالب'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: (screenWidth * 0.9).clamp(320.0, 520.0),
              maxWidth: 520,
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller.searchText.value,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن طالب...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => controller.searchStudents(),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Obx(() {
                      if (controller.isLoadingStudents.value) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (controller.assignableStudents.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'لا يوجد طلاب في حلقاتك',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.assignableStudents.length,
                        itemBuilder: (context, index) {
                          final student =
                              controller.assignableStudents[index];
                          final otherTasks = student.assignedTaskNames
                              .where((name) => name != task.taskName)
                              .toList();
                          return Obx(() => RadioListTile<int?>(
                                value: student.studentId,
                                groupValue: selectedStudentId.value,
                                onChanged: (v) => selectedStudentId.value = v,
                                activeColor: _primaryColor,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  student.studentName,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                subtitle: Text(
                                  otherTasks.isEmpty
                                      ? (student.groupName ?? '')
                                      : '${student.groupName ?? ''} • مُسند له اليوم: ${otherTasks.join('، ')}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ));
                        },
                      );
                    }),
                  ),
                  Obx(() {
                    if (!controller.studentsHasNext.value &&
                        !controller.studentsHasPrevious.value) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: controller.studentsHasPrevious.value &&
                                  !controller.isLoadingStudents.value
                              ? () => controller.prevStudentsPage()
                              : null,
                        ),
                        Text(
                          'من ${controller.studentsTotalCount.value}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: controller.studentsHasNext.value &&
                                  !controller.isLoadingStudents.value
                              ? () => controller.nextStudentsPage()
                              : null,
                        ),
                      ],
                    );
                  }),
                  const Divider(),
                  Obx(() => CheckboxListTile(
                        value: isCompleted.value,
                        onChanged: (v) => isCompleted.value = v ?? false,
                        activeColor: _primaryColor,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('أنجزت'),
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLength: 500,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (task.log != null)
              Obx(() => TextButton(
                    onPressed: controller.isUpserting.value
                        ? null
                        : () async {
                            final ok = await controller.upsertTask(
                              cleaningTaskId: task.cleaningTaskId,
                              studentId: null,
                              isCompleted: false,
                            );
                            if (ok && ctx.mounted) {
                              FocusScope.of(ctx).unfocus();
                              Navigator.of(ctx).pop();
                            }
                          },
                    child: const Text(
                      'إزالة الإسناد',
                      style: TextStyle(color: Colors.red),
                    ),
                  )),
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
                          if (selectedStudentId.value == null) {
                            messageSnackBar('اختر الطالب أولاً',
                                title: 'لم يتم اختيار طالب');
                            return;
                          }
                          final notes = notesController.text.trim();
                          final ok = await controller.upsertTask(
                            cleaningTaskId: task.cleaningTaskId,
                            studentId: selectedStudentId.value,
                            isCompleted: isCompleted.value,
                            notes: notes.isEmpty ? null : notes,
                          );
                          if (ok && ctx.mounted) {
                            FocusScope.of(ctx).unfocus();
                            Navigator.of(ctx).pop();
                          }
                        },
                  child: Text(
                      controller.isUpserting.value ? 'جاري الحفظ...' : 'حفظ'),
                )),
          ],
        );
      },
    ).then((_) {
      // انتظار إطارين حتى يُزال الحوار تماماً قبل التخلص من المتحكم
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notesController.dispose();
        });
      });
    });
  }
}
