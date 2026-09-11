import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/reportTeachersAttendancesController.dart';
import 'package:jaberah/controllers/admin/teachersAttendancesController.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

class TeachersAttendancePage extends StatelessWidget {
  // Initialize the controller once at the top level
  final TeacherAttendancesController controller =
      Get.put(TeacherAttendancesController());

  TeachersAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      title: 'حضور المعلمين',
      subtitle: 'تسجيل الحضور اليومي',
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: _buildDateCard(context),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const JLoadingState(
                    message: 'جاري تحميل حضور المعلمين...',
                  );
                }
                if (controller.filteredTeachersAttendances.isEmpty) {
                  return const JEmptyState(
                    title: 'لا توجد بيانات حضور',
                    message: 'اختر يوماً آخر أو تأكد من إسناد المعلمين للحلقات.',
                    icon: Icons.how_to_reg_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  itemCount: controller.filteredTeachersAttendances.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final t = controller.filteredTeachersAttendances[index];
                    final id = t.teacherId;
                    final gId = t.groupId ?? 0;
                    final hasEntry = controller.entries
                        .any((e) => e.teacherId == id && e.groupId == gId);
                    if (!hasEntry) {
                      final isExcused = t.status == 'مستأذن' ||
                          t.status == 'غائب بعذر' ||
                          t.status == 'بعذر';
                      controller.entries.add(EntryAttendance(
                        teacherId: id,
                        groupId: gId,
                        checkInTime: t.checkInTime,
                        checkOutTime: t.checkOutTime,
                        isExcused: isExcused ? true : null,
                      ));
                    }
                    return Obx(() => _buildAttendanceCard(context, t));
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة اليوم: التاريخ الهجري المختار وزر تغييره.
  Widget _buildDateCard(BuildContext context) {
    return JCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      color: AppColors.primaryTint,
      borderColor: AppColors.primarySoft,
      onTap: () => _selectHijriDate(context),
      child: Row(
        children: [
          const JIconBadge(
            icon: Icons.event_outlined,
            size: 46,
            iconSize: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('اليوم', style: AppText.caption),
                Obx(
                  () => Text(
                    '${controller.selectedDate.value.jhijri!.day}'
                    ' ${controller.selectedDate.value.jhijri!.monthName}'
                    ' ${controller.selectedDate.value.jhijri!.year}',
                    style: AppText.displayXSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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

  /// Displays the Hijri date picker and updates the selected date.
  Future<void> _selectHijriDate(BuildContext context) async {
    var picked = await showGlobalDatePicker(
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
      controller.entries.clear();
      await controller.getTeachersAttendances();
    }
  }

  /// Builds an attendance card: وقت الدخول، وقت الانصراف، مستأذن، وزر تحديث لكل معلم.
  /// إذا مستأذن: checkInTime و checkOutTime = null. والعكس صحيح.
  Widget _buildAttendanceCard(
      BuildContext context, TeacherAttendanceForDayReport teacher) {
    final int id = teacher.teacherId;
    final groupId = teacher.groupId ?? 0;
    var entry = controller.entries
        .firstWhereOrNull((x) => x.teacherId == id && x.groupId == groupId);
    final isExcusedFromApi = _isExcusedStatus(teacher.status);
    if (entry == null) {
      controller.entries.add(EntryAttendance(
        teacherId: id,
        groupId: groupId,
        checkInTime: teacher.checkInTime,
        checkOutTime: teacher.checkOutTime,
        isExcused: isExcusedFromApi ? true : null,
      ));
      entry = controller.entries
          .firstWhere((x) => x.teacherId == id && x.groupId == groupId);
    }
    final entryToSave = entry;
    final entryGroupId = entryToSave.groupId;
    // عرض علامة الصح: من الـ entry إن وُجدت، وإلا من الحالة القادمة من الـ API
    final isExcused = entryToSave.isExcused == true ||
        (entryToSave.isExcused != false && isExcusedFromApi);
    final savingKey = '${id}_$entryGroupId';
    final hasBothTimes = entryToSave.checkInTime != null &&
        entryToSave.checkOutTime != null &&
        entryToSave.checkInTime!.isNotEmpty &&
        entryToSave.checkOutTime!.isNotEmpty;

    return JCard(
      radius: AppRadii.lg,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              JAvatar(name: teacher.teacherName, size: 42),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      teacher.teacherName,
                      style: AppText.displayXSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (teacher.groupName != null &&
                        teacher.groupName!.isNotEmpty)
                      Text(
                        teacher.groupName!,
                        style: AppText.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (teacher.status.isNotEmpty)
                JChip(
                  label: _statusToArabic(teacher.status),
                  tone: _statusTone(teacher.status),
                  compact: true,
                ),
            ],
          ),
          if (hasBothTimes) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.timelapse_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text('فارق الساعات:', style: AppText.captionStrong),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  formatAttendanceTimeDifference(
                      entryToSave.checkInTime!, entryToSave.checkOutTime!),
                  style: AppText.captionStrong.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  context: context,
                  label: 'وقت الدخول',
                  value: entryToSave.checkInTime,
                  enabled: !isExcused,
                  onTap: () async {
                    final time =
                        await _pickTime(context, entryToSave.checkInTime);
                    if (time != null) {
                      controller.updateEntry(id,
                          groupId: entryGroupId,
                          checkInTime: time,
                          checkOutTime: entryToSave.checkOutTime,
                          isExcused: false);
                    }
                  },
                  onClear: () {
                    controller.updateEntry(id,
                        groupId: entryGroupId,
                        checkInTime: null,
                        checkOutTime: entryToSave.checkOutTime,
                        isExcused: false);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildTimeField(
                  context: context,
                  label: 'وقت الانصراف',
                  value: entryToSave.checkOutTime,
                  enabled: !isExcused,
                  onTap: () async {
                    final time =
                        await _pickTime(context, entryToSave.checkOutTime);
                    if (time != null) {
                      controller.updateEntry(id,
                          groupId: entryGroupId,
                          checkInTime: entryToSave.checkInTime,
                          checkOutTime: time,
                          isExcused: false);
                    }
                  },
                  onClear: () {
                    controller.updateEntry(id,
                        groupId: entryGroupId,
                        checkInTime: entryToSave.checkInTime,
                        checkOutTime: null,
                        isExcused: false);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              // مستأذن: إذا صح، الأوقات = null. والعكس.
              Expanded(
                child: _ExcusedToggle(
                  value: isExcused,
                  onChanged: (excused) {
                    // نحتفظ بأوقات الدخول/الانصراف في الـ entry عند التفعيل أو
                    // الإلغاء؛ للـ API نرسل null عند مستأذن (في toJson).
                    controller.updateEntry(id,
                        groupId: entryGroupId,
                        checkInTime: entryToSave.checkInTime,
                        checkOutTime: entryToSave.checkOutTime,
                        isExcused: excused);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Obx(() {
                final saving = controller.savingEntryKey.value == savingKey;
                return JButton(
                  label: 'تحديث',
                  icon: Icons.save_outlined,
                  expand: false,
                  loading: saving,
                  loadingLabel: 'جاري...',
                  onPressed: () async {
                    await controller.updateTeacherAttendance(entryToSave);
                  },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required BuildContext context,
    required String label,
    required String? value,
    required bool enabled,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: AppRadii.mdAll,
        color: enabled ? AppColors.bgElev : AppColors.bgSunken,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: AppRadii.smAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: AppText.overline),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: enabled ? AppColors.primary : AppColors.inkFaint,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Flexible(
                        child: Text(
                          formatTime12(value) ?? '—',
                          style: AppText.bodyStrong.copyWith(
                            color: value != null
                                ? AppColors.ink
                                : AppColors.inkFaint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (enabled && value != null && onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(
                Icons.clear_rounded,
                size: 18,
                color: AppColors.inkFaint,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'تفريغ',
            ),
        ],
      ),
    );
  }

  /// يفتح منتقي الوقت ويعيد "HH:mm" أو null.
  Future<String?> _pickTime(BuildContext context, String? initialStr) async {
    TimeOfDay initial = TimeOfDay.now();
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
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  /// هل الحالة تعني مستأذن (من API أو محلياً).
  static bool _isExcusedStatus(String status) {
    if (status.isEmpty) return false;
    final s = status.trim().toLowerCase();
    if (s == 'excused') return true;
    if (status == 'مستأذن' || status == 'غائب بعذر' || status == 'بعذر') {
      return true;
    }
    return false;
  }

  /// ترجمة الحالة من الإنجليزي أو أي صيغة إلى العربي للعرض.
  static String _statusToArabic(String status) {
    switch (status) {
      case 'Present':
        return 'حاضر';
      case 'Excused':
        return 'مستأذن';
      case 'Absent':
        return 'غائب';
      case 'Late':
        return 'متأخر';
      case 'حاضر':
      case 'مستأذن':
      case 'غائب بعذر':
      case 'بعذر':
      case 'غائب':
      case 'متأخر':
        return status; // already Arabic
      default:
        return status.isNotEmpty ? status : '—';
    }
  }

  /// نغمة الشريحة: حاضر أخضر، مستأذن/متأخر ذهبي، غائب أحمر.
  static JTone _statusTone(String status) {
    switch (status) {
      case 'حاضر':
      case 'Present':
        return JTone.primary;
      case 'مستأذن':
      case 'غائب بعذر':
      case 'بعذر':
      case 'Excused':
      case 'متأخر':
      case 'Late':
        return JTone.gold;
      case 'غائب':
      case 'Absent':
        return JTone.danger;
      default:
        return JTone.neutral;
    }
  }
}

/// مفتاح «مستأذن»: سطح ناعم يتلوّن حين يُفعَّل.
class _ExcusedToggle extends StatelessWidget {
  const _ExcusedToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tone = value ? JTone.gold : JTone.neutral;
    return Material(
      color: value ? tone.soft : AppColors.bgSunken,
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        borderRadius: AppRadii.mdAll,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: value ? tone.onSoft : AppColors.inkFaint,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'مستأذن',
                style: AppText.bodyStrong.copyWith(
                  color: value ? tone.onSoft : AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
