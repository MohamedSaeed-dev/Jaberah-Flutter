import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/teachersController.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

class Teachers extends StatelessWidget {
  Teachers({super.key});

  final TeachersController controller = Get.put(TeachersController());

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      appBar: JAppBar(
        title: 'المعلمين',
        subtitle: 'بيانات المعلمين المعتمدين',
        actions: [
          Obx(
            () => JAppBarButton(
              icon: controller.withoutGroups.value
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              tooltip: 'بدون حلقات',
              onPressed: () async {
                controller.withoutGroups.value = !controller.withoutGroups.value;
                await controller.getTeachers();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await controller.getGroups();
          _showAddTeacherDialog(context);
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('معلم جديد'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Obx(
              () => JSearchField(
                controller: controller.searchText.value,
                hintText: 'ابحث عن معلم...',
                filterActive: controller.withoutGroups.value,
                enabled: !controller.isLoadingData.value,
                onSubmitted: (_) async {
                  controller.pageNumber.value = 1;
                  await controller.getTeachers();
                },
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingData.value) {
                  return const JLoadingState(message: 'جاري تحميل المعلمين...');
                }
                if (controller.teachers.isEmpty) {
                  return const JEmptyState(
                    title: 'لا يوجد معلمون',
                    message: 'أضف أول معلم من الزر في أسفل الشاشة.',
                    icon: Icons.person_outline_rounded,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xxxl + AppSpacing.xl,
                  ),
                  itemCount: controller.teachers.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) =>
                      _buildTeacherCard(context, controller.teachers[index]),
                );
              }),
            ),
            Obx(
              () => JPaginationBar(
                fetchedCount: controller.fetchedCount.value,
                totalCount: controller.totalCount.value,
                onPrevious:
                    controller.hasPrevious.value && !controller.isLoadingData.value
                        ? () {
                            controller.pageNumber.value--;
                            controller.getTeachers();
                          }
                        : null,
                onNext:
                    controller.hasNext.value && !controller.isLoadingData.value
                        ? () async {
                            controller.pageNumber.value++;
                            await controller.getTeachers();
                          }
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCard(BuildContext context, Teacher teacher) {
    final groups = teacher.groups ?? const <TeacherGroups>[];
    return JListCard(
      leading: JAvatar(name: teacher.teacherName),
      title: teacher.teacherName,
      subtitle: teacher.phoneNumber,
      trailing: JChip(
        label: groups.isEmpty ? 'بدون حلقات' : '${groups.length} حلقة',
        tone: groups.isEmpty ? JTone.danger : JTone.primary,
        compact: true,
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (groups.isNotEmpty)
            Wrap(
              spacing: AppSpacing.xxs,
              runSpacing: AppSpacing.xxs,
              children: [
                for (final group in groups)
                  JChip(
                    label: group.groupName,
                    tone: JTone.neutral,
                    compact: true,
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.xs),
          JCardActions(
            onEdit: () async {
              await controller.getGroupsSpecial(id: teacher.id.toString());
              _showEditDialog(context, teacher);
            },
            onDelete: () =>
                _showDeleteTeacherConfirmation(context, teacher.id.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(
    String label,
    TextEditingController controller,
    String? Function(String?) validator,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        validator: validator,
        keyboardType:
            label == 'رقم الجوال' ? TextInputType.phone : TextInputType.text,
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _showDeleteTeacherConfirmation(BuildContext context, String id) {
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تأكيد الحذف',
          message: 'هل أنت متأكد أنك تريد حذف هذا المعلم؟',
          icon: Icons.delete_outline_rounded,
          tone: JTone.danger,
          confirmLabel: 'حذف',
          loading: controller.isLoadingOperation.value,
          loadingLabel: 'جاري الحذف...',
          onConfirm: () async => controller.deleteTeacher(id: id),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Teacher teacher) {
    controller.nameEditController.value.text = teacher.teacherName;
    controller.phoneEditController.value.text = teacher.phoneNumber;
    controller.selectedGroupsEdit.clear();
    final groupIds = teacher.groups?.map((g) => g.id).toList() ?? <int>[];
    controller.selectedGroupsEdit.addAll(groupIds);

    final key = GlobalKey<FormState>();
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'تعديل معلومات المعلم',
          icon: Icons.edit_outlined,
          confirmLabel: 'حفظ',
          loading: controller.isLoadingOperation.value,
          loadingLabel: 'جاري التحديث...',
          onConfirm: () async {
            if (key.currentState!.validate()) {
              await controller.updateTeacher(id: teacher.id.toString());
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
                    TextFormField(
                      controller: controller.nameEditController.value,
                      validator: _nameValidator,
                      decoration: const InputDecoration(labelText: 'اسم المعلم'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: controller.phoneEditController.value,
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                      decoration: const InputDecoration(labelText: 'رقم الجوال'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    MultiSelectDialogField<int>(
                      cancelText: const Text('الغاء'),
                      confirmText: const Text('تأكيد'),
                      title: const Text('الحلقات المتاحة'),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.mdAll,
                        border: Border.all(color: AppColors.line),
                        color: AppColors.bgElev,
                      ),
                      items: controller.groupsSpecial
                          .map((group) =>
                              MultiSelectItem<int>(group.id, group.name))
                          .toList(),
                      initialValue: controller.selectedGroupsEdit.toList(),
                      listType: MultiSelectListType.CHIP,
                      onConfirm: (values) {
                        controller.selectedGroupsEdit.value = values.cast<int>();
                      },
                      buttonText: Text(
                        controller.isGroupLoading.value
                            ? 'جاري التحميل...'
                            : 'اختر الحلقات',
                        style: AppText.bodyMedium,
                      ),
                      chipDisplay: MultiSelectChipDisplay<int>(
                        chipColor: AppColors.primarySoft,
                        textStyle: AppText.captionStrong.copyWith(
                          color: AppColors.primaryDark,
                        ),
                        items: controller.selectedGroupsEdit.map((groupId) {
                          final group = controller.groupsSpecial.firstWhere(
                            (g) => g.id == groupId,
                            orElse: () => GroupsSpecial(id: groupId, name: ''),
                          );
                          return MultiSelectItem<int>(group.id, group.name);
                        }).toList(),
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

  final _formKeyAddTeacher = GlobalKey<FormState>();

  void _showAddTeacherDialog(BuildContext context) {
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'إضافة معلم جديد',
          icon: Icons.person_add_alt_1_rounded,
          confirmLabel: 'إضافة المعلم',
          loading: controller.isLoading.value,
          loadingLabel: 'جاري الإضافة...',
          onConfirm: () async {
            if (_formKeyAddTeacher.currentState!.validate()) {
              await controller.addTeacher();
            }
          },
          content: Form(
            key: _formKeyAddTeacher,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  'الاسم',
                  controller.nameAddController.value,
                  (value) {
                    if (value!.isEmpty) return 'يرجى إدخال اسم المعلم';
                    return _nameValidator(value);
                  },
                ),
                _buildDialogTextField(
                  'رقم الجوال',
                  controller.phoneAddController.value,
                  (value) {
                    if (value!.isEmpty) return 'يرجى إدخال رقم الجوال';
                    return _phoneValidator(value);
                  },
                ),
                MultiSelectDialogField(
                  cancelText: const Text('الغاء'),
                  confirmText: const Text('تأكيد'),
                  title: const Text('الحلقات المتاحة'),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.mdAll,
                    border: Border.all(color: AppColors.line),
                    color: AppColors.bgElev,
                  ),
                  items: controller.groups.isNotEmpty
                      ? controller.groups
                          .map((group) =>
                              MultiSelectItem(group.id.toString(), group.name))
                          .toList()
                      : [],
                  initialValue: controller.selectedGroupsAdd,
                  listType: MultiSelectListType.CHIP,
                  onConfirm: (values) {
                    controller.selectedGroupsAdd.value = values.cast<String>();
                  },
                  buttonText: Text('اختر الحلقات', style: AppText.bodyMedium),
                  chipDisplay: MultiSelectChipDisplay(
                    chipColor: AppColors.primarySoft,
                    textStyle: AppText.captionStrong.copyWith(
                      color: AppColors.primaryDark,
                    ),
                    items: controller.selectedGroupsAdd.map((groupId) {
                      final group = controller.groups
                          .firstWhere((group) => group.id.toString() == groupId);
                      return MultiSelectItem(group.id.toString(), group.name);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// اسم المعلم: عربي فقط وبين 7 و 20 حرفاً.
  static String? _nameValidator(String? value) {
    final arabicRegex = RegExp(r'^[\u0621-\u064A\u0660-\u0669\s]+$');
    if (!arabicRegex.hasMatch(value ?? '')) {
      return 'اسم المعلم يجب ان يكون عربياً';
    }
    if (value!.length < 7 || value.length > 20) {
      return 'اسم المعلم يجب ان يكون بين 7 و 20 حرفاً';
    }
    return null;
  }

  /// رقم الجوال: يبدأ بـ7 ويتبعه ثمانية أرقام.
  static String? _phoneValidator(String? value) {
    final regExp = RegExp(r'^7[0-9]{8}$');
    if (!regExp.hasMatch(value ?? '')) {
      return 'يرجى إدخال رقم هاتف صحيح';
    }
    return null;
  }
}
