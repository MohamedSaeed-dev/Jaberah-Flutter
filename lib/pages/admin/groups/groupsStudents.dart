import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/groupStudentsController.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jaberah/pages/user/followStudents/students_followStudents.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

class GroupStudents extends StatelessWidget {
  GroupStudents({super.key});

  final GroupStudentsController controller = Get.put(GroupStudentsController());
  final StudentsOfGroupController studentController =
      Get.put(StudentsOfGroupController());

  /// المراحل الدراسية المسموح بها في القائمة المنسدلة.
  static const List<String> _schoolClasses = [
    'المرحلة الابتدائية',
    'المرحلة الاعدادية',
    'المرحلة الثانوية',
  ];

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      appBar: JAppBar(
        title: 'تفاصيل الحلقة',
        subtitle: 'طلاب الحلقة وبياناتها',
        actions: [
          JAppBarButton(
            icon: Icons.visibility_outlined,
            tooltip: 'عرض كمعلم',
            onPressed: () {
              Get.to(
                () => StudentGroupsFollowStudents(),
                arguments: {
                  "id": controller.id,
                  "Name": controller.groupName.value,
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _ActionBar(
        onDelete: () => _showDeleteConfirmation(context),
        onEdit: () async {
          await controller.getTeachers();
          _showEditGroupDialog(context);
        },
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Obx(() => _GroupSummary(controller: controller)),
            ),
            Obx(
              () => JSearchField(
                controller: controller.searchText.value,
                hintText: 'ابحث عن طالب...',
                enabled: !controller.isLoadingData.value,
                onSubmitted: (_) {
                  controller.pageNumber.value = 1;
                  controller.getStudents();
                },
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingData.value) {
                  return const JLoadingState(message: 'جاري تحميل الطلاب...');
                }
                if (controller.students.isEmpty) {
                  return const JEmptyState(
                    title: 'لا يوجد طلاب في هذه الحلقة',
                    message: 'أضف الطلاب إلى الحلقة من شاشة الطلاب.',
                    icon: Icons.school_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  itemCount: controller.students.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) => _buildStudentCard(
                    context,
                    controller.students[index] as StudentGroup,
                  ),
                );
              }),
            ),
            Obx(
              () => JPaginationBar(
                fetchedCount: controller.fetchedCount.value,
                totalCount: controller.totalCount.value,
                onPrevious: controller.hasPrevious.value &&
                        !controller.isLoadingData.value
                    ? () {
                        controller.pageNumber.value--;
                        controller.getStudents();
                      }
                    : null,
                onNext:
                    controller.hasNext.value && !controller.isLoadingData.value
                        ? () {
                            controller.pageNumber.value++;
                            controller.getStudents();
                          }
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentGroup student) {
    return JListCard(
      leading: JAvatar(name: student.studentName),
      title: student.studentName,
      subtitle: _studentSummary(student),
      trailing: JChip(
        label: 'حفظ ${student.memoRate}',
        tone: JTone.gold,
        compact: true,
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JDetailRow(
            label: 'ولي الأمر:',
            value: student.phoneNumber,
            icon: Icons.phone_outlined,
          ),
          if ((student.notes ?? '').trim().isNotEmpty)
            JDetailRow(
              label: 'ملاحظات:',
              value: student.notes!,
              icon: Icons.sticky_note_2_outlined,
            ),
          const SizedBox(height: AppSpacing.xxs),
          JCardActions(
            onEdit: () => _showEditStudentDialog(context, student),
            onDelete: () => _showDeleteStudentConfirmation(context, student.id),
          ),
        ],
      ),
    );
  }

  static String _studentSummary(StudentGroup student) {
    final parts = [
      student.schoolClass,
      student.studyLevel,
      student.schoolLevel,
    ].whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty);
    return parts.isEmpty ? 'لا توجد بيانات دراسية' : parts.join(' · ');
  }

  // ----------------------------------------------------- حوارات الطلاب
  void _showEditStudentDialog(BuildContext context, StudentGroup student) {
    studentController.nameController.value.text = student.studentName;
    studentController.phoneController.value.text = student.phoneNumber;

    // قيمة المرحلة القادمة من الخادم قد لا تطابق خيارات القائمة، فتُفرَّغ حينها.
    final schoolClassValue = student.schoolClass ?? '';
    studentController.selectedSchoolClass.value =
        _schoolClasses.contains(schoolClassValue) ? schoolClassValue : '';

    studentController.rateController.value.text = student.memoRate.toString();
    studentController.levelController.value.text = student.schoolLevel ?? '';
    studentController.notesController.value.text = student.notes ?? '';
    studentController.studyLevelController.value.text = student.studyLevel ?? '';

    final key = GlobalKey<FormState>();
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تعديل معلومات الطالب',
          icon: Icons.edit_outlined,
          confirmLabel: 'حفظ',
          loading: studentController.isLoadingOperation.value,
          loadingLabel: 'جاري الحفظ...',
          onConfirm: () async {
            if (key.currentState!.validate()) {
              await studentController.updateStudent(id: student.id);
            }
          },
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(
                      'اسم الطالب',
                      studentController.nameController.value,
                      _nameValidator,
                    ),
                    _field(
                      'رقم ولي الأمر',
                      studentController.phoneController.value,
                      _phoneValidator,
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      'مقدار الحفظ',
                      studentController.rateController.value,
                      null,
                    ),
                    _field(
                      'الصف الدراسي',
                      studentController.studyLevelController.value,
                      null,
                    ),
                    _field(
                      'المستوى',
                      studentController.levelController.value,
                      null,
                    ),
                    _field(
                      'ملاحظات',
                      studentController.notesController.value,
                      null,
                    ),
                    DropdownButtonFormField<String>(
                      value: studentController.selectedSchoolClass.value.isEmpty
                          ? null
                          : studentController.selectedSchoolClass.value,
                      isExpanded: true,
                      hint: const Text('اختر المرحلة الدراسية'),
                      onChanged: (value) {
                        studentController.selectedSchoolClass.value =
                            value ?? '';
                      },
                      decoration: const InputDecoration(
                        labelText: 'المرحلة الدراسية',
                      ),
                      items: [
                        for (final item in _schoolClasses)
                          DropdownMenuItem(value: item, child: Text(item)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteStudentConfirmation(BuildContext context, int id) {
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تأكيد الحذف',
          message: 'هل أنت متأكد أنك تريد حذف هذا الطالب؟',
          icon: Icons.delete_outline_rounded,
          tone: JTone.danger,
          confirmLabel: 'حذف',
          loading: studentController.isLoadingOperation.value,
          loadingLabel: 'جاري الحذف...',
          onConfirm: () async => studentController.deleteStudent(id: id),
        ),
      ),
    );
  }

  // ----------------------------------------------------- حوارات الحلقة
  void _showDeleteConfirmation(BuildContext context) {
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تأكيد حذف الحلقة',
          message: 'هل أنت متأكد أنك تريد حذف هذه الحلقة؟\n'
              'ملاحظة: لن يؤدي ذلك إلى حذف الطلاب.',
          icon: Icons.delete_outline_rounded,
          tone: JTone.danger,
          confirmLabel: 'حذف الحلقة',
          loading: controller.isLoadingOperation.value,
          loadingLabel: 'جاري الحذف...',
          onConfirm: () async => controller.deleteGroup(),
        ),
      ),
    );
  }

  final formKeyGroupName = GlobalKey<FormState>();

  void _showEditGroupDialog(BuildContext context) {
    controller.groupNameText.value.text = controller.groupName.value;
    controller.selectedTeacherId.value = controller.teacherIdText;

    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تعديل الحلقة',
          icon: Icons.edit_outlined,
          confirmLabel: 'تعديل الحلقة',
          loading: controller.isLoadingOperation.value,
          loadingLabel: 'جاري التعديل...',
          onConfirm: () async {
            if (formKeyGroupName.currentState!.validate()) {
              await controller.updateGroup();
            }
          },
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKeyGroupName,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: controller.groupNameText.value,
                      decoration:
                          const InputDecoration(labelText: 'اسم الحلقة'),
                      validator: (value) {
                        final arabicRegex = RegExp(
                            r'^[\u0621-\u064A\u0660-\u0669\s]+$');
                        if (value!.isEmpty) {
                          return 'يرجى إدخال اسم الحلقة';
                        } else if (!arabicRegex.hasMatch(value)) {
                          return 'اسم الحلقة يجب ان يكون عربياً';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: controller.period.value,
                      hint: const Text('اختر الفترة'),
                      items: const [
                        DropdownMenuItem(
                            value: 'صباحية', child: Text('صباحية')),
                        DropdownMenuItem(
                            value: 'مسائية', child: Text('مسائية')),
                      ],
                      onChanged: (value) => controller.period.value = value!,
                      decoration: const InputDecoration(labelText: 'الفترة'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTeachersDropdown(),
                    const SizedBox(height: AppSpacing.md),
                    _buildTimeEditRow(
                      label: 'وقت بداية فترة الحلقة خلال اليوم',
                      value: controller.windowStartEdit.value,
                      onTap: () async {
                        final picked = await _pickTimeForGroup(
                          context,
                          controller.windowStartEdit.value,
                        );
                        if (picked != null) {
                          controller.windowStartEdit.value = picked;
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTimeEditRow(
                      label: 'وقت نهاية فترة الحلقة خلال اليوم',
                      value: controller.windowEndEdit.value,
                      onTap: () async {
                        final picked = await _pickTimeForGroup(
                          context,
                          controller.windowEndEdit.value,
                        );
                        if (picked != null) {
                          controller.windowEndEdit.value = picked;
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller:
                          controller.flexibleMinutesEditController.value,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الدقائق المرنة قبل احتساب التأخر',
                        hintText: 'مثال: 15',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeachersDropdown() {
    // خيار «بدون معلم» يُضاف مرة واحدة فقط حتى لا يتكرر مع كل إعادة بناء.
    if (controller.teachersForGeneralUse.isEmpty ||
        controller.teachersForGeneralUse.first.id != null) {
      controller.teachersForGeneralUse
          .insert(0, TeachersForGeneralUse(id: null, teacherName: 'بدون معلم'));
    }
    return DropdownButtonFormField<int?>(
      isExpanded: true,
      value: controller.selectedTeacherId.value,
      onChanged: (value) => controller.selectedTeacherId.value = value,
      decoration: const InputDecoration(labelText: 'المعلم'),
      items: controller.teachersForGeneralUse
          .map(
            (teacher) => DropdownMenuItem<int?>(
              value: teacher.id,
              child: Text(
                teacher.teacherName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTimeEditRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdAll,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time_rounded, size: 20),
        ),
        child: Text(
          value.isEmpty ? '—' : (formatTime12(value) ?? value),
          style: value.isEmpty
              ? AppText.bodyMedium.copyWith(color: AppColors.inkFaint)
              : AppText.bodyMedium,
        ),
      ),
    );
  }

  Future<String?> _pickTimeForGroup(
    BuildContext context, [
    String? initialStr,
  ]) async {
    var initial = TimeOfDay.now();
    if (initialStr != null && initialStr.contains(':')) {
      final parts = initialStr.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
          initial = TimeOfDay(hour: h, minute: m);
        }
      }
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
  }

  Widget _field(
    String label,
    TextEditingController fieldController,
    String? Function(String?)? validator, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        controller: fieldController,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  static String? _nameValidator(String? value) {
    final arabicRegex = RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
    final text = value ?? '';
    if (text.isNotEmpty && !arabicRegex.hasMatch(text)) {
      return 'اسم الطالب يجب ان يكون عربياً';
    }
    if (text.length < 7 || text.length > 20) {
      return 'اسم الطالب يجب ان يكون بين 7 و 20 حرفاً';
    }
    return null;
  }

  static String? _phoneValidator(String? value) {
    final regExp = RegExp(r'^7[0-9]{8}$');
    final text = value ?? '';
    if (text.isNotEmpty && !regExp.hasMatch(text)) {
      return 'يرجى إدخال رقم هاتف صحيح';
    }
    return null;
  }
}

/// رأس شاشة تفاصيل الحلقة: الاسم، الفترة والنافذة الزمنية، وعدد الطلاب.
class _GroupSummary extends StatelessWidget {
  const _GroupSummary({required this.controller});

  final GroupStudentsController controller;

  @override
  Widget build(BuildContext context) {
    final start = formatTime12(controller.windowStartEdit.value);
    final end = formatTime12(controller.windowEndEdit.value);
    final window = (start != null && end != null) ? '$start - $end' : null;

    return JCard(
      color: AppColors.primaryTint,
      borderColor: AppColors.primarySoft,
      padding: const EdgeInsets.all(AppSpacing.md),
      showMotif: true,
      motifColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const JIconBadge(icon: Icons.auto_stories_outlined),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.groupName.value,
                      style: AppText.displaySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      window == null
                          ? controller.period.value
                          : '${controller.period.value} · $window',
                      style: AppText.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.primarySoft),
          const SizedBox(height: AppSpacing.sm),
          JStatStrip(
            background: Colors.transparent,
            borderColor: AppColors.primarySoft,
            padding: EdgeInsets.zero,
            stats: [
              JStat(value: '${controller.totalCount.value}', label: 'طالب'),
              JStat(
                value: controller.period.value,
                label: 'الفترة',
                tone: JTone.gold,
              ),
              JStat(
                value: controller.flexibleMinutesEditController.value.text.isEmpty
                    ? '—'
                    : controller.flexibleMinutesEditController.value.text,
                label: 'دقائق مرنة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// شريط سفلي بإجراءي الحلقة: حذف وتعديل.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onDelete, required this.onEdit});

  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElev,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: JButton.ghost(
                  label: 'حذف الحلقة',
                  icon: Icons.delete_outline_rounded,
                  tone: JTone.danger,
                  onPressed: onDelete,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: JButton(
                  label: 'تعديل الحلقة',
                  icon: Icons.edit_outlined,
                  onPressed: onEdit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
