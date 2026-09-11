import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/studentsController.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

class Students extends StatelessWidget {
  Students({super.key});

  final StudentsController controller = Get.put(StudentsController());

  /// المراحل الدراسية المسموح بها في القوائم المنسدلة.
  static const List<String> _schoolClasses = [
    'المرحلة الابتدائية',
    'المرحلة الاعدادية',
    'المرحلة الثانوية',
  ];

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      appBar: JAppBar(
        title: 'الطلاب',
        subtitle: 'بيانات الطلاب المسجّلين',
        actions: [
          Obx(
            () => JAppBarButton(
              icon: controller.withoutGroup.value
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              tooltip: 'بدون حلقات',
              onPressed: () async {
                controller.withoutGroup.value = !controller.withoutGroup.value;
                await controller.getStudents();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await controller.getGroups();
          _showAddStudentDialog(context);
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('طالب جديد'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Obx(
              () => JSearchField(
                controller: controller.searchText.value,
                hintText: 'ابحث عن طالب...',
                filterActive: controller.withoutGroup.value,
                enabled: !controller.isLoadingData.value,
                onSubmitted: (_) async {
                  controller.pageNumber.value = 1;
                  await controller.getStudents();
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
                    title: 'لا يوجد طلاب',
                    message: 'أضف أول طالب من الزر في أسفل الشاشة.',
                    icon: Icons.school_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xxxl + AppSpacing.xl,
                  ),
                  itemCount: controller.students.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) =>
                      _buildStudentCard(context, controller.students[index]),
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
                        ? () async {
                            controller.pageNumber.value++;
                            await controller.getStudents();
                          }
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Student student) {
    final group = student.groupName?.trim() ?? '';
    return JListCard(
      leading: JAvatar(name: student.studentName),
      title: student.studentName,
      subtitle: _studentSummary(student),
      trailing: JChip(
        label: group.isEmpty ? 'بدون حلقة' : group,
        tone: group.isEmpty ? JTone.danger : JTone.primary,
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
          JDetailRow(
            label: 'مقدار الحفظ:',
            value: '${student.memoRate}',
            icon: Icons.auto_stories_outlined,
            tone: JTone.gold,
          ),
          if ((student.notes ?? '').trim().isNotEmpty)
            JDetailRow(
              label: 'ملاحظات:',
              value: student.notes!,
              icon: Icons.sticky_note_2_outlined,
            ),
          const SizedBox(height: AppSpacing.xxs),
          JCardActions(
            onEdit: () async {
              await controller.getGroups();
              _showEditStudentDialog(context, student);
            },
            onDelete: () =>
                _showDeleteStudentConfirmation(context, student.id.toString()),
          ),
        ],
      ),
    );
  }

  /// «المرحلة · الصف · المستوى» متجاهلاً ما هو فارغ.
  static String _studentSummary(Student student) {
    final parts = [
      student.schoolClass,
      student.studyLevel,
      student.schoolLevel,
    ].whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty);
    return parts.isEmpty ? 'لا توجد بيانات دراسية' : parts.join(' · ');
  }

  final _formKeyAddStudent = GlobalKey<FormState>();

  void _showAddStudentDialog(BuildContext context) {
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'إضافة طالب جديد',
          icon: Icons.person_add_alt_1_rounded,
          confirmLabel: 'إضافة الطالب',
          loading: controller.isLoading.value,
          loadingLabel: 'جاري الإضافة...',
          onConfirm: () async {
            if (_formKeyAddStudent.currentState!.validate()) {
              await controller.addStudent();
            }
          },
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKeyAddStudent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(
                      'الاسم',
                      controller.nameAddController.value,
                      (value) {
                        if (value!.isEmpty) return 'يرجى إدخال اسم الطالب';
                        return _nameValidator(value);
                      },
                    ),
                    _field(
                      'رقم ولي الأمر',
                      controller.phoneAddController.value,
                      (value) {
                        if (value!.isEmpty) return 'يرجى إدخال رقم ولي الأمر';
                        return _phoneValidator(value);
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      'مقدار الحفظ',
                      controller.rateAddController.value,
                      _rateValidator,
                    ),
                    _field('المستوى', controller.levelAddController.value, null),
                    _field(
                      'الصف الدراسي',
                      controller.studyLevelAddController.value,
                      null,
                    ),
                    _field('ملاحظات', controller.notesAddController.value, null),
                    _schoolClassDropdown(
                      value: controller.selectedAddSchoolClass.value,
                      onChanged: (value) =>
                          controller.selectedAddSchoolClass.value = value ?? '',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _groupDropdown(
                      value: controller.selectedGroupAddId.value,
                      onChanged: (value) =>
                          controller.selectedGroupAddId.value = value,
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

  void _showEditStudentDialog(BuildContext context, Student student) {
    controller.nameEditController.value.text = student.studentName;
    controller.phoneEditController.value.text = student.phoneNumber;

    // قيمة المرحلة القادمة من الخادم قد لا تطابق خيارات القائمة، فتُفرَّغ حينها.
    final schoolClassValue = student.schoolClass ?? '';
    controller.selectedEditSchoolClass.value =
        _schoolClasses.contains(schoolClassValue) ? schoolClassValue : '';

    controller.rateEditController.value.text = student.memoRate.toString();
    controller.levelEditController.value.text = student.schoolLevel ?? '';
    controller.notesEditController.value.text = student.notes ?? '';
    controller.studyLevelEditController.value.text = student.studyLevel ?? '';
    controller.selectedGroupEditName.value = student.groupName ?? '';
    controller.selectedGroupEditId.value = student.groupId;

    final keyForm = GlobalKey<FormState>();
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تعديل معلومات الطالب',
          icon: Icons.edit_outlined,
          confirmLabel: 'حفظ',
          loading: controller.isLoadingOperation.value,
          loadingLabel: 'جاري التحديث...',
          onConfirm: () async {
            if (keyForm.currentState!.validate()) {
              await controller.updateStudent(id: student.id.toString());
            }
          },
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: keyForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(
                      'اسم الطالب',
                      controller.nameEditController.value,
                      _nameValidator,
                    ),
                    _field(
                      'رقم ولي الأمر',
                      controller.phoneEditController.value,
                      (value) {
                        if (value!.isEmpty) return 'يرجى إدخال رقم ولي الأمر';
                        return _phoneValidator(value);
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      'مقدار الحفظ',
                      controller.rateEditController.value,
                      _rateValidator,
                    ),
                    _field(
                      'المستوى',
                      controller.levelEditController.value,
                      null,
                    ),
                    _field(
                      'الصف الدراسي',
                      controller.studyLevelEditController.value,
                      null,
                    ),
                    _field(
                      'ملاحظات',
                      controller.notesEditController.value,
                      null,
                    ),
                    _schoolClassDropdown(
                      value: controller.selectedEditSchoolClass.value,
                      onChanged: (value) =>
                          controller.selectedEditSchoolClass.value = value ?? '',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _groupDropdown(
                      value: controller.selectedGroupEditId.value,
                      onChanged: (value) =>
                          controller.selectedGroupEditId.value = value,
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

  void _showDeleteStudentConfirmation(BuildContext context, String id) {
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تأكيد الحذف',
          message: 'هل أنت متأكد أنك تريد حذف هذا الطالب؟',
          icon: Icons.delete_outline_rounded,
          tone: JTone.danger,
          confirmLabel: 'حذف',
          loading: controller.isLoadingOperation.value,
          loadingLabel: 'جاري الحذف...',
          onConfirm: () async => controller.deleteStudent(id: id),
        ),
      ),
    );
  }

  // ------------------------------------------------------- عناصر النموذج
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

  Widget _schoolClassDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      isExpanded: true,
      hint: const Text('اختر المرحلة الدراسية'),
      onChanged: onChanged,
      decoration: const InputDecoration(labelText: 'المرحلة الدراسية'),
      items: [
        for (final item in _schoolClasses)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
    );
  }

  Widget _groupDropdown({
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int?>(
      value: value,
      isExpanded: true,
      onChanged: onChanged,
      decoration: const InputDecoration(labelText: 'الحلقة'),
      items: controller.groups
          .map(
            (group) => DropdownMenuItem<int?>(
              value: group.id,
              child: Text(group.groupName, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
    );
  }

  // ----------------------------------------------------------- التحقّقات
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
    if (!regExp.hasMatch(value ?? '')) return 'يرجى إدخال رقم هاتف صحيح';
    return null;
  }

  static String? _rateValidator(String? value) {
    if (value != null &&
        (int.tryParse(value) == null || int.parse(value) < 0)) {
      return 'يرجى إدخال مقدار حفظ صحيح';
    }
    return null;
  }
}
