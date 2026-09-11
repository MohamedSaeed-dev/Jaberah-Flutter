import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/admin/reportTeachersAttendancesController.dart';
import 'package:jaberah/helpers/timeHelpers.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:jhijri_picker/_src/_jWidgets.dart';
import 'package:jaberah/theme/theme.dart';

class TeachersAttendanceReport extends StatelessWidget {
  final TeachersAttendancesReportController controller =
      Get.put(TeachersAttendancesReportController());

  TeachersAttendanceReport({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Builder(
            builder: (BuildContext newContext) {
              return Obx(() => FloatingActionButton.extended(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final TabController tabController =
                                DefaultTabController.of(newContext);
                            if (tabController.index == 0) {
                              await controller
                                  .getTeachersAttendancesReportByDay();
                            } else if (tabController.index == 1) {
                              await controller
                                  .getTeachersAttendancesReportByMonth();
                            }
                          },
                    label: Text(
                      "عـرض الـتـقـريـر",
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(
                      Icons.document_scanner_outlined,
                      color: AppColors.onPrimary,
                    ),
                    backgroundColor: AppColors.primary,
                  ));
            },
          ),
        ),
        appBar: AppBar(
          title: const Text('تقرير الحضور المعلمين'),
          backgroundColor: AppColors.primary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'بحث باليوم'),
              Tab(text: 'بحث بالشهر'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDaySearch(context),
            _buildMonthSearch(context),
          ],
        ),
      ),
    );
  }

  // Day Search Tab
  Widget _buildDaySearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.bgElev,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildHijriDatePicker(context, "اليوم:"),
            ),
          ),
          const Divider(),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingDayIndicator();
            } else if (controller
                .filteredTeachersAttendancesForReportByDay.isEmpty) {
              return _buildEmptyDataIndicator();
            } else {
              return Expanded(
                  child: ListView.builder(
                itemCount:
                    controller.filteredTeachersAttendancesForReportByDay.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: _buildDayAttendanceCard(
                      context,
                      controller
                          .filteredTeachersAttendancesForReportByDay[index],
                    ),
                  );
                },
              ));
            }
          }),
        ],
      ),
    );
  }

  Widget _buildMonthAttendanceCard(
      BuildContext context, TeacherAttendanceForMonthReport teacher) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.bgElev,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Name Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "المعلم: ${teacher.teacherName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (teacher.groupName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "الحلقة: ${teacher.groupName}",
                  style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                ),
              ),
            // Attendance Summary (new shape: excuseNo, presentNo, lateNo, absentNo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.goldSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "بعذر",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${teacher.excuseNo}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "حاضر",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${teacher.presentNo}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "متأخر",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${teacher.lateNo}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "غائب",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${teacher.absentNo}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDayAttendanceCard(
      BuildContext context, TeacherAttendanceForDayReport teacher) {
    final status = teacher.status;
    final statusAr = _dayStatusToArabic(status);
    final statusColor = _dayStatusColor(status);
    final hasTimes = teacher.checkInTime != null &&
        teacher.checkOutTime != null &&
        teacher.checkInTime!.isNotEmpty &&
        teacher.checkOutTime!.isNotEmpty;
    final durationStr = hasTimes
        ? _formatDayReportDuration(teacher.checkInTime!, teacher.checkOutTime!)
        : null;

    return Card(
      elevation: 3,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: AppColors.bgElev,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_dayStatusIcon(status), size: 18, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusAr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (durationStr != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      durationStr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              teacher.teacherName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (teacher.groupName != null && teacher.groupName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                "الحلقة: ${teacher.groupName}",
                style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
              ),
            ],
            if (teacher.checkInTime != null || teacher.checkOutTime != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.login, size: 18, color: AppColors.inkMuted),
                  const SizedBox(width: 6),
                  Text(
                    "دخول: ${formatTime12(teacher.checkInTime) ?? '—'}",
                    style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.logout, size: 18, color: AppColors.inkMuted),
                  const SizedBox(width: 6),
                  Text(
                    "خروج: ${formatTime12(teacher.checkOutTime) ?? '—'}",
                    style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _dayStatusToArabic(String status) {
    switch (status) {
      case 'Present':
        return 'حاضر';
      case 'Excused':
        return 'مستأذن';
      case 'Absent':
        return 'غائب';
      case 'Late':
        return 'متأخر';
      default:
        return status.isNotEmpty ? status : '—';
    }
  }

  static Color _dayStatusColor(String status) {
    switch (status) {
      case 'حاضر':
      case 'Present':
        return AppColors.primary;
      case 'مستأذن':
      case 'غائب بعذر':
      case 'بعذر':
      case 'Excused':
        return AppColors.gold;
      case 'متأخر':
      case 'Late':
        return AppColors.gold;
      case 'غائب':
      case 'Absent':
        return AppColors.danger;
      default:
        return AppColors.inkFaint;
    }
  }

  static IconData _dayStatusIcon(String status) {
    switch (status) {
      case 'حاضر':
      case 'Present':
        return Icons.check_circle;
      case 'مستأذن':
      case 'غائب بعذر':
      case 'بعذر':
      case 'Excused':
        return Icons.warning_amber_rounded;
      case 'متأخر':
      case 'Late':
        return Icons.schedule;
      default:
        return Icons.cancel_outlined;
    }
  }

  static String _formatDayReportDuration(String checkIn, String checkOut) {
    int? minFromMidnight(String time) {
      final parts = time.trim().split(':');
      if (parts.length < 2) return null;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) return null;
      return h * 60 + m;
    }

    final inM = minFromMidnight(checkIn);
    final outM = minFromMidnight(checkOut);
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

  Widget _buildLoadingDayIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Center(
              child: Text(
                " جاري تحميل تقرير حضور المعلمين\n ليوم ${controller.selectedDate.value.jhijri!.day} لشهر ${controller.selectedDate.value.jhijri!.monthName}",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMonthIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Center(
              child: Text(
                " جاري تحميل تقرير حضور المعلمين\n لشهر ${controller.selectedDate.value.jhijri!.monthName}",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDataIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.hourglass_empty),
            SizedBox(height: 10),
            Text("لاتوجد بيانات", style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }

  // Month Search Tab
  Widget _buildMonthSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.bgElev,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildHijriMonthDatePicker(context, "الشهر:"),
            ),
          ),
          const Divider(),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingMonthIndicator();
            } else if (controller
                .filteredTeachersAttendancesForReportByMonth.isEmpty) {
              return _buildEmptyDataIndicator();
            } else {
              return Expanded(
                  child: ListView.builder(
                itemCount: controller
                    .filteredTeachersAttendancesForReportByMonth.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: _buildMonthAttendanceCard(
                      context,
                      controller
                          .filteredTeachersAttendancesForReportByMonth[index],
                    ),
                  );
                },
              ));
            }
          }),
        ],
      ),
    );
  }

  // Hijri Date Picker for Day Search
  Widget _buildHijriDatePicker(BuildContext context, String label) {
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
          onPressed: () => _selectHijriDayDate(context),
          icon: const Icon(Icons.calendar_month, size: 28),
          color: AppColors.primary,
        ),
      ],
    );
  }

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
                    "${controller.selectedDate.value.jhijri!.monthName} - ${controller.selectedDate.value.jhijri!.year}",
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
          onPressed: () => _selectHijriMonthDate(context),
          icon: const Icon(Icons.calendar_month, size: 28),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Future<void> _selectHijriDayDate(BuildContext context) async {
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
      controller.selectedDate.value = JDateModel(jhijri: picked.jhijri, dateTime: picked.date);
      await controller.getTeachersAttendancesReportByDay();
    }
  }

  Future<void> _selectHijriMonthDate(BuildContext context) async {
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
      final firstHijriDay = JHijri(fYear: picked.jhijri.year, fMonth: picked.jhijri.month, fDay: 1);
      final firstGregorianDay = firstHijriDay.dateTime;
      controller.selectedDate.value = JDateModel(jhijri: firstHijriDay, dateTime: firstGregorianDay);
      controller.updateMonthReportDates();
      await controller.getTeachersAttendancesReportByMonth();
    }
  }

  // Hijri Month Picker for Month Search
}
