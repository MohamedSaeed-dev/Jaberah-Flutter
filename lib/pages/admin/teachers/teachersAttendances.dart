import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/reportTeachersAttendancesController.dart';
import 'package:jaberah/controllers/admin/teachersAttendancesController.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';

class TeachersAttendancePage extends StatelessWidget {
  // Initialize the controller once at the top level
  final TeacherAttendancesController controller =
      Get.put(TeacherAttendancesController());

  TeachersAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الحضور المعلمين',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3FB56C),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Picker Section inside a Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildHijriMonthDatePicker(context, "اليوم:"),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            // Attendance List: Wrap only the reactive part in Obx
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingIndicator();
                } else if (controller.filteredTeachersAttendances.isEmpty) {
                  return _buildEmptyDataIndicator();
                } else {
                  return ListView.separated(
                    itemCount: controller.filteredTeachersAttendances.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
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
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Date picker section with a label and the selected Hijri date.
  Widget _buildHijriMonthDatePicker(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Use Flexible to avoid overflow issues.
        Flexible(
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Obx(
                  () => Text(
                    "${controller.selectedDate.value.jhijri!.day}-${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _selectHijriDate(context),
          icon: const Icon(Icons.calendar_month, size: 28),
          color: const Color(0xFF3FB56C),
        ),
      ],
    );
  }

  /// Displays the Hijri date picker and updates the selected date.
  Future<void> _selectHijriDate(BuildContext context) async {
    var picked = await showGlobalDatePicker(
      locale: const Locale("ar", "SA"),
      context: context,
      pickerType: PickerType.JHijri,
      primaryColor: const Color(0xFF3FB56C),
      backgroundColor: Colors.white,
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

  /// Loading indicator widget.
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            "جاري تحميل حضور المعلمين...",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  /// Widget to display when there is no attendance data.
  Widget _buildEmptyDataIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.hourglass_empty, size: 40),
          SizedBox(height: 10),
          Text("لا توجد بيانات", style: TextStyle(fontSize: 20))
        ],
      ),
    );
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
    final savingKey = '${id}_${entryGroupId}';

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "المعلم: ${teacher.teacherName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Obx(() {
                  final saving = controller.savingEntryKey.value == savingKey;
                  return TextButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            await controller.updateTeacherAttendance(entryToSave);
                          },
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined, size: 20),
                    label: Text(saving ? "جاري..." : "تحديث"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3FB56C),
                    ),
                  );
                }),
              ],
            ),
            if (teacher.groupName != null && teacher.groupName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "الحلقة: ${teacher.groupName}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            if (teacher.status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Text(
                      "الحالة: ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(teacher.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _statusColor(teacher.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _statusToArabic(teacher.status),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(teacher.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (entryToSave.checkInTime != null &&
                entryToSave.checkOutTime != null &&
                entryToSave.checkInTime!.isNotEmpty &&
                entryToSave.checkOutTime!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Text(
                      "فارق الساعات: ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      _formatTimeDifference(
                          entryToSave.checkInTime!, entryToSave.checkOutTime!),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3FB56C),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // وقت الدخول (وقت فقط)
            Row(
              children: [
                const SizedBox(width: 8),
                const Text("وقت الدخول:", style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeField(
                    context: context,
                    value: entryToSave.checkInTime,
                    enabled: !isExcused,
                    onTap: () async {
                      final time = await _pickTime(context, entryToSave.checkInTime);
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
              ],
            ),
            const SizedBox(height: 8),
            // وقت الانصراف (وقت فقط)
            Row(
              children: [
                const SizedBox(width: 8),
                const Text("وقت الانصراف:", style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeField(
                    context: context,
                    value: entryToSave.checkOutTime,
                    enabled: !isExcused,
                    onTap: () async {
                      final time = await _pickTime(context, entryToSave.checkOutTime);
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
            const SizedBox(height: 8),
            // مستأذن: إذا صح، الأوقات = null. والعكس.
            Row(
              children: [
                const Text("مستأذن", style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Checkbox(
                  activeColor: const Color(0xFF3FB56C),
                  value: isExcused,
                  onChanged: (value) {
                    final excused = value == true;
                    // نحتفظ بأوقات الدخول/الانصراف في الـ entry عند التفعيل أو الإلغاء؛ للـ API نرسل null عند مستأذن (في toJson).
                    controller.updateEntry(id,
                        groupId: entryGroupId,
                        checkInTime: entryToSave.checkInTime,
                        checkOutTime: entryToSave.checkOutTime,
                        isExcused: excused ? true : false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required BuildContext context,
    required String? value,
    required bool enabled,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: enabled ? null : Colors.grey.shade200,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: enabled ? const Color(0xFF3FB56C) : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatTime12(value) ?? "—",
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (enabled && value != null && onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: "تفريغ",
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
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF3FB56C)),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  /// يحسب فارق الساعات بين وقتين بصيغة "HH:mm" ويعيد نصاً مثل "6 ساعات" أو "6 ساعات و 30 دقيقة".
  static String _formatTimeDifference(String checkIn, String checkOut) {
    int? minutesFromMidnight(String time) {
      final parts = time.trim().split(':');
      if (parts.length < 2) return null;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) return null;
      return h * 60 + m;
    }

    final inM = minutesFromMidnight(checkIn);
    final outM = minutesFromMidnight(checkOut);
    if (inM == null || outM == null) return '—';
    int diff = outM - inM;
    if (diff < 0) diff += 24 * 60;
    final hours = diff ~/ 60;
    final minutes = diff % 60;
    if (minutes == 0) return hours == 1 ? '1 ساعة' : '$hours ساعات';
    if (hours == 0) return minutes == 1 ? '1 دقيقة' : '$minutes دقيقة';
    final hStr = hours == 1 ? '1 ساعة' : '$hours ساعات';
    final mStr = minutes == 1 ? '1 دقيقة' : '$minutes دقيقة';
    return '$hStr و $mStr';
  }

  /// هل الحالة تعني مستأذن (من API أو محلياً).
  static bool _isExcusedStatus(String status) {
    if (status.isEmpty) return false;
    final s = status.trim().toLowerCase();
    if (s == 'excused') return true;
    if (status == 'مستأذن' || status == 'غائب بعذر' || status == 'بعذر') return true;
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

  static Color _statusColor(String status) {
    switch (status) {
      case 'حاضر':
      case 'Present':
        return Colors.green;
      case 'مستأذن':
      case 'غائب بعذر':
      case 'بعذر':
      case 'Excused':
        return Colors.orange;
      case 'غائب':
      case 'Absent':
      case 'متأخر':
      case 'Late':
        return status == 'متأخر' || status == 'Late' ? Colors.amber : Colors.red;
      default:
        return Colors.grey;
    }
  }
}
