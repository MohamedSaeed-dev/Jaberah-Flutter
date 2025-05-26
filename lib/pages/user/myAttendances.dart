import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/myAttendancesController.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class MyAttendances extends StatelessWidget {
  final controller = Get.put(MyAttendancesController());

  MyAttendances({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حضوري'),
        backgroundColor: const Color(0xFF3FB56C),
        elevation: 2,
        actions: [
          Obx(() {
            final hijri = HijriCalendar.now();
            final today = DateTime(hijri.hYear, hijri.hMonth, hijri.hDay);

            final isTodayFocused =
                controller.focusedDay.value.day == today.day &&
                    controller.focusedDay.value.month == today.month &&
                    controller.focusedDay.value.year == today.year;

            return IconButton(
              icon: const Icon(Icons.today, color: Colors.black),
              onPressed: isTodayFocused
                  ? null
                  : () {
                      controller.selectedDay.value = today;
                      controller.focusedDay.value = today;
                      controller.getAttendanceForMonth();
                    },
              tooltip: 'العودة إلى اليوم',
            );
          }),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Builder(
          builder: (BuildContext newContext) {
            return Obx(() {
              return !controller.isAdmin.value ? FloatingActionButton.extended(
                onPressed: controller.isLoading.value ||
                        controller.selectedAttendance.value.signature == true
                    ? null
                    : () async {
                        print("a");
                      },
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
              ) : SizedBox();
            });
          },
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
    );
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
                onPressed: () {
                  controller.focusedDay.value = DateTime(
                      controller.focusedDay.value.year,
                      controller.focusedDay.value.month - 1,
                      controller.focusedDay.value.day);
                  controller.getAttendanceForMonth();
                },
              ),
              Text(
                controller.getHijriMonthName(controller.focusedDay.value),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  controller.focusedDay.value = DateTime(
                      controller.focusedDay.value.year,
                      controller.focusedDay.value.month + 1,
                      controller.focusedDay.value.day);
                  controller.getAttendanceForMonth();
                },
              ),
            ],
          ),
        ));
  }

  Widget _buildCalendar() {
    return Obx(() => TableCalendar(
          locale: 'ar',
          firstDay: DateTime.utc(1, 1, 1),
          lastDay: DateTime.utc(2999, 12, 31),
          focusedDay: controller.focusedDay.value,
          selectedDayPredicate: (day) =>
              isSameDay(controller.selectedDay.value, day),
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: Colors.black),
            weekendTextStyle: const TextStyle(color: Colors.red),
            selectedDecoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
          ),
          onPageChanged: (focusedDay) {
            controller.focusedDay.value = focusedDay;
            controller.getAttendanceForMonth();
          },
          onDaySelected: controller.onDaySelected,
          weekendDays: [DateTime.friday, DateTime.saturday],
          headerVisible: false,
          calendarFormat: CalendarFormat.month,
          daysOfWeekVisible: true,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          availableGestures: AvailableGestures.all,
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekendStyle: TextStyle(color: Colors.red),
            weekdayStyle: TextStyle(color: Colors.black),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, _) {
              final att = controller.getAttendanceForDate(date);
              Color color;
              if (att == null) {
                color = Colors.grey.shade300;
              } else if (att.signature == true) {
                color = Colors.green;
              } else if (att.signature == false) {
                color = Colors.red;
              } else if (att.isExcuse == true) {
                color = Colors.orange;
              } else {
                color = Colors.grey.shade400;
              }

              return Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: const TextStyle(color: Colors.black),
                ),
              );
            },
          ),
        ));
  }

  Widget _buildHijriDay() {
    return Obx(() {
      final date = controller.selectedDay.value;
      final attendance = controller.selectedAttendance.value;

      // Determine attendance status and color
      String statusText;
      Color statusColor;

      if (attendance.signature == true) {
        statusText = "حاضر";
        statusColor = Colors.green;
      } else if (attendance.isExcuse == true) {
        statusText = "معتذر";
        statusColor = Colors.orange;
      } else {
        statusText = "غائب";
        statusColor = Colors.red;
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            // Hijri Date
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  'اليوم: ${date.day} - ${date.month} - ${date.year} هـ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Creation time
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attendance.createdAt != null
                        ? "تم الإنشاء في ${controller.formatCreatedAt(attendance.createdAt!)}"
                        : "تاريخ الإنشاء غير متوفر",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
