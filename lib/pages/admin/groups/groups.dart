import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/groupsController.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jaberah/pages/admin/groups/groupsStudents.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class Groups extends StatelessWidget {
  Groups({super.key});

  final GroupsController groupsController = Get.put(GroupsController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return JScaffold(
      appBar: JAppBar(
        title: 'الحلقات',
        subtitle: 'حلقات مسجد جابرة',
        leading: JAppBarButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'رجوع',
          onPressed: () {
            Get.delete<GroupsController>();
            Get.back();
          },
        ),
        actions: [
          Obx(
            () => JAppBarButton(
              icon: groupsController.withoutTeacher.value
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              tooltip: 'بدون معلمين',
              onPressed: () async {
                groupsController.withoutTeacher.value =
                    !groupsController.withoutTeacher.value;
                await groupsController.getGroups();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await groupsController.getTeachers();
          _showAddGroupDialog(context);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('حلقة جديدة'),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (groupsController.isLoading.value) {
            return const JLoadingState(message: 'جاري تحميل الحلقات...');
          }
          if (groupsController.groups.isEmpty) {
            return const JEmptyState(
              title: 'لا توجد حلقات',
              message: 'أضف أول حلقة من الزر في أسفل الشاشة.',
              icon: Icons.hub_outlined,
            );
          }

          return Column(
            children: [
              if (groupsController.withoutTeacher.value)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: JChip(
                      label: 'الحلقات بدون معلمين',
                      tone: JTone.gold,
                      icon: Icons.filter_alt_rounded,
                    ),
                  ),
                ),
              Expanded(
                child: ReorderableGridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xxxl + AppSpacing.xl,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 600 ? 3 : 2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: screenWidth > 600 ? 1.15 : 0.86,
                  ),
                  itemCount: groupsController.groups.length,
                  onReorder: groupsController.reorderGroups,
                  dragWidgetBuilder: (index, child) => Transform.scale(
                    scale: 1.04,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        borderRadius: AppRadii.lgAll,
                        boxShadow: AppShadows.cardHover,
                      ),
                      child: child,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final data = groupsController.groups[index];
                    return _GroupCard(
                      key: ValueKey(data.id),
                      group: data,
                      onTap: () {
                        Get.to(() => GroupStudents(), arguments: {
                          "Id": data.id,
                          "Name": data.groupName,
                          "teacherId": data.teacherId,
                          "period": data.period,
                          "windowStart": data.windowStart,
                          "windowEnd": data.windowEnd,
                          "flexibleMinutes": data.flexibleMinutes,
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    showJDialog(
      context: context,
      dialog: Obx(
        () => JDialog(
          title: 'إضافة حلقة جديدة',
          icon: Icons.hub_outlined,
          confirmLabel: 'إضافة الحلقة',
          loading: groupsController.isLoading.value,
          loadingLabel: 'جاري الإضافة...',
          onConfirm: () async {
            if (_formKey.currentState!.validate()) {
              await groupsController.addGroup();
            }
          },
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: groupsController.groupNameController.value,
                  decoration: const InputDecoration(labelText: 'اسم الحلقة'),
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
                  value: groupsController.period.value,
                  items: const [
                    DropdownMenuItem(value: 'صباحية', child: Text('صباحية')),
                    DropdownMenuItem(value: 'مسائية', child: Text('مسائية')),
                  ],
                  onChanged: (value) {
                    groupsController.period.value = value!;
                  },
                  decoration: const InputDecoration(labelText: 'الفترة'),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<int>(
                  value: groupsController.selectedTeacherId.value,
                  onChanged: (value) {
                    groupsController.selectedTeacherId.value = value;
                  },
                  isExpanded: true,
                  items: groupsController.teachersForGeneralUse
                      .map(
                        (teacher) => DropdownMenuItem(
                          value: teacher.id,
                          child: Text(
                            teacher.teacherName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  decoration: const InputDecoration(labelText: 'المعلم'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة الحلقة في الشبكة: أيقونة، اسم الحلقة، المعلم والفترة، وعدد الطلاب.
class _GroupCard extends StatelessWidget {
  const _GroupCard({super.key, required this.group, required this.onTap});

  final Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = group.teacherName == null ? JTone.danger : JTone.primary;
    final window = _windowLabel();

    return JCard(
      onTap: onTap,
      radius: AppRadii.lg,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              JIconBadge(
                icon: Icons.auto_stories_outlined,
                tone: tone,
                size: 42,
                iconSize: 22,
              ),
              JChip(label: group.period, tone: JTone.neutral, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            group.groupName,
            style: AppText.displayXSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'المعلم: ${group.teacherName ?? 'بدون معلم'}',
            style: AppText.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (window != null)
            Text(
              window,
              style: AppText.mono.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 16,
                color: tone.solid,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${group.studentsNo} طالب',
                style: AppText.captionStrong.copyWith(color: tone.onSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// «٥:٣٠ ص - ٦:٤٥ ص» حين تكون نافذة الحلقة معرّفة.
  String? _windowLabel() {
    final start = formatTime12(group.windowStart);
    final end = formatTime12(group.windowEnd);
    if (start == null || end == null) return null;
    return '$start - $end';
  }
}
