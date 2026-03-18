import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/myAttendancesController.dart';

class MyAttendances extends StatelessWidget {
  final controller = Get.put(MyAttendancesController());

  MyAttendances({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: const Text('حضوري'),
        backgroundColor: const Color(0xFF3FB56C),
        elevation: 2,
        actions: [
          Obx(() {
            final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
            final sel = controller.selectedDay.value;
            final isTodaySelected = sel.year == today.year &&
                sel.month == today.month &&
                sel.day == today.day;

            return IconButton(
              icon: const Icon(Icons.today, color: Colors.black),
              onPressed: isTodaySelected ? null : () => controller.goToToday(),
              tooltip: 'العودة إلى اليوم',
            );
          }),
        ],
      ),
      bottomNavigationBar: controller.isAdmin.value
          ? null
          : BottomAppBar(
              child: FloatingActionButton.extended(
                onPressed: controller.isLoading.value ? null : () async {},
                label: Text(
                  "رفع طلب",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: Icon(
                  Icons.cloud_upload_rounded,
                  color: Colors.black,
                ),
                backgroundColor: const Color.fromARGB(255, 63, 181, 108),
              ),
            ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text(
                  "جاري تحميل الحضور...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthNavigation(),
              const SizedBox(height: 16),
              _buildCalendar(),
              const SizedBox(height: 24),
              _buildHijriDay(),
            ],
          ),
        );
      }),
    ));
  }

  Widget _buildMonthNavigation() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF7F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => controller.goToPrevHijriMonth(),
              ),
              Text(
                controller.getHijriMonthName(controller.focusedDay.value),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => controller.goToNextHijriMonth(),
              ),
            ],
          ),
        ));
  }

  static Widget _dayCell(
      MyAttendancesController controller, DateTime date, Color? selectedColor, bool isToday) {
    final status = controller.getStatusForDate(date);
    Color color;
    if (selectedColor != null) {
      color = selectedColor;
    } else {
      switch (status) {
        case 'Present':
          color = Colors.green;
          break;
        case 'Excused':
          color = Colors.orange;
          break;
        case 'Late':
          color = Colors.amber;
          break;
        case 'Absent':
          color = Colors.red;
          break;
        default:
          color = Colors.grey.shade300;
      }
    }
    return SizedBox(
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isToday
              ? Border.all(color: Colors.black87, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${controller.getHijriDay(date)}',
            style: TextStyle(
              color: selectedColor != null ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  static const _weekDays = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  Widget _buildCalendar() {
    return Obx(() {
      final grid = controller.getHijriMonthGrid();
      final sel = controller.selectedDay.value;
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final cells = <({int? day, DateTime? date})>[
        ...List.filled(grid.firstWeekday, (day: null, date: null)),
        ...grid.days.map((d) => (day: d.day, date: d.date)),
      ];
      const rowLength = 7;
      final rows = <List<({int? day, DateTime? date})>>[];
      for (var i = 0; i < cells.length; i += rowLength) {
        var row = cells.skip(i).take(rowLength).toList();
        while (row.length < rowLength) row.add((day: null, date: null));
        rows.add(row);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(7, (i) => Expanded(
              child: Center(
                child: Text(
                  _weekDays[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: (i == 5 || i == 6) ? Colors.red : Colors.black,
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 8),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: row.map((cell) {
                    return Expanded(
                      child: SizedBox(
                        height: 44,
                        child: Center(
                          child: (cell.day == null || cell.date == null)
                              ? const SizedBox.shrink()
                              : GestureDetector(
                                  onTap: () => controller.onDaySelected(cell.date!, cell.date!),
                                  child: _dayCell(
                                    controller,
                                    cell.date!,
                                    (cell.date!.year == sel.year &&
                                            cell.date!.month == sel.month &&
                                            cell.date!.day == sel.day)
                                        ? Colors.blue.shade700
                                        : null,
                                    cell.date!.year == today.year &&
                                        cell.date!.month == today.month &&
                                        cell.date!.day == today.day,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ],
      );
    });
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'Present':
        return 'حاضر';
      case 'Excused':
        return 'معتذر';
      case 'Late':
        return 'متأخر';
      case 'Absent':
      default:
        return 'غائب';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Excused':
        return Colors.orange;
      case 'Late':
        return Colors.amber;
      case 'Absent':
      default:
        return Colors.red;
    }
  }

  Widget _buildHijriDay() {
    return Obx(() {
      final date = controller.selectedDay.value;
      final dayItems = controller.dataForDay;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  controller.formatDateHijri(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dayItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('لا توجد بيانات حضور لهذا اليوم', style: TextStyle(color: Colors.grey)),
              )
            else
              ...dayItems.map((item) {
                final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final hasGroupId = item.groupId != 0;
                final showCheckIn = isToday && item.checkInTime == null && hasGroupId;
                final showCheckOut = isToday && item.checkOutTime == null;
                final canCheckOut = item.checkInTime != null && hasGroupId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.groupName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(item.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusLabel(item.status),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(item.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.login_rounded, size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  'حضور',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  controller.formatTime(item.checkInTime),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout_rounded, size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  'انصراف',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  controller.formatTime(item.checkOutTime),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (showCheckIn || showCheckOut) ...[
                        const SizedBox(height: 8),
                        Obx(() {
                          final loading = controller.isCheckInOutLoading.value;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (showCheckIn)
                                ElevatedButton.icon(
                                  onPressed: loading ? null : () => controller.confirmCheckIn(item.groupId),
                                  icon: const Icon(Icons.fingerprint, size: 18),
                                  label: const Text('تسجيل الحضور'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3FB56C),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              if (showCheckOut)
                                OutlinedButton.icon(
                                  onPressed: (loading || !canCheckOut) ? null : () => controller.confirmCheckOut(item.groupId),
                                  icon: const Icon(Icons.fingerprint, size: 18),
                                  label: const Text('تسجيل الانصراف'),
                                ),
                            ],
                          );
                        }),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}
