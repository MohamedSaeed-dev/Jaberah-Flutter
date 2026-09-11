import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/studentGroupsFollowStudentsController.dart';
import 'package:jaberah/pages/user/followStudents/editData_followStudent.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

class StudentGroupsFollowStudents extends StatelessWidget {
  StudentGroupsFollowStudents({super.key});

  final StudentGroupsFollowStudentsController controller =
      Get.put(StudentGroupsFollowStudentsController());

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      title: 'طلاب ${controller.name}',
      subtitle: 'المتابعة اليومية',
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
              child: Obx(() => _buildDateCard(context)),
            ),
            Obx(
              () => JSearchField(
                controller: controller.searchText.value,
                hintText: 'ابحث عن طالب...',
                enabled: !controller.isLoading.value,
                onSubmitted: (_) => controller.getStudents(),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const JLoadingState(message: 'جاري تحميل الطلاب...');
                }
                if (controller.students.isEmpty) {
                  return const JEmptyState(
                    title: 'لا يوجد طلاب',
                    message: 'لا توجد متابعة مسجّلة لهذا اليوم.',
                    icon: Icons.school_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  itemCount: controller.filteredStudents.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) => _buildStudentsCard(
                    controller.filteredStudents[index],
                    context,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة اليوم الهجري المختار.
  Widget _buildDateCard(BuildContext context) {
    return JCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      color: AppColors.primaryTint,
      borderColor: AppColors.primarySoft,
      onTap: () => _selectHijriDate(context),
      child: Row(
        children: [
          const JIconBadge(icon: Icons.event_outlined, size: 46, iconSize: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('التاريخ الهجري', style: AppText.caption),
                Text(
                  '${controller.selectedDate.value.jhijri!.day}'
                  ' ${controller.selectedDate.value.jhijri!.monthName}'
                  ' ${controller.selectedDate.value.jhijri!.year}',
                  style: AppText.displayXSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          JIconAction(
            icon: Icons.chevron_left_rounded,
            tooltip: 'اختيار اليوم',
            onPressed: () => _selectHijriDate(context),
          ),
        ],
      ),
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
        child: Center(
          child: Text(
            'التقويم الهجري',
            style: AppText.displaySmall.copyWith(color: AppColors.onPrimary),
          ),
        ),
      ),
      locale: const Locale("ar", "SA"),
      context: context,
      pickerType: PickerType.JHijri,
      primaryColor: AppColors.primary,
      backgroundColor: AppColors.bgElev,
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

  Widget _buildStudentsCard(FollowStudent student, BuildContext context) {
    return JCard(
      radius: AppRadii.lg,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              JAvatar(name: student.studentName, size: 42),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  student.studentName,
                  style: AppText.displayXSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              JIconAction(
                icon: Icons.edit_outlined,
                tooltip: 'تعديل المتابعة',
                onPressed: () {
                  Get.to(() => EditFollowStudent(), arguments: {
                    "student": student,
                    "date": controller.selectedDate.value,
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _RecitationBlock(
                    title: 'الحفظ',
                    tone: JTone.primary,
                    surahFrom: student.surahFromTeacher,
                    verseFrom: student.verseFromTeacher,
                    surahTo: student.surahToTeacher,
                    verseTo: student.verseToTeacher,
                    rate: student.rateTeacher,
                    pages: student.pagesTeacher,
                  ),
                ),
                const VerticalDivider(width: AppSpacing.md, thickness: 1),
                Expanded(
                  child: _RecitationBlock(
                    title: 'المراجعة',
                    tone: JTone.gold,
                    surahFrom: student.surahFromFriend,
                    verseFrom: student.verseFromFriend,
                    surahTo: student.surahToFriend,
                    verseTo: student.verseToFriend,
                    rate: student.rateFriend,
                    pages: student.pagesFriend,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              JChip(
                label: 'الحضور: ${student.attendance}',
                tone: JTone.primary,
                icon: Icons.how_to_reg_outlined,
                compact: true,
              ),
              JChip(
                label: 'السلوك: ${student.behavior}',
                tone: JTone.gold,
                icon: Icons.emoji_events_outlined,
                compact: true,
              ),
            ],
          ),
          if (student.notes.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            JDetailRow(
              label: 'ملاحظات:',
              value: student.notes,
              icon: Icons.sticky_note_2_outlined,
            ),
          ],
        ],
      ),
    );
  }
}

/// عمود الحفظ أو المراجعة داخل بطاقة المتابعة.
class _RecitationBlock extends StatelessWidget {
  const _RecitationBlock({
    required this.title,
    required this.tone,
    required this.surahFrom,
    required this.verseFrom,
    required this.surahTo,
    required this.verseTo,
    required this.rate,
    required this.pages,
  });

  final String title;
  final JTone tone;
  final String surahFrom;
  final int verseFrom;
  final String surahTo;
  final int verseTo;
  final String rate;
  final double pages;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        JChip(label: title, tone: tone, compact: true),
        const SizedBox(height: AppSpacing.xs),
        _line('من:', '$surahFrom · آية $verseFrom'),
        _line('إلى:', '$surahTo · آية $verseTo'),
        _line('التقدير:', rate),
        _line('الصفحات:', '$pages'),
      ],
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: AppText.caption,
          children: [
            TextSpan(text: '$label ', style: AppText.captionStrong),
            TextSpan(
              text: value.trim().isEmpty ? '—' : value,
              style: AppText.caption.copyWith(color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
