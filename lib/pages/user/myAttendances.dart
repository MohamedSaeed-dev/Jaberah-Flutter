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
        actions: [
          IconButton(
            onPressed: () {
              final today = DateTime.now();
              controller.focusedDay.value = today;
              controller.selectedDay.value = today;
            },
            icon: Icon(Icons.today, color: Colors.black),
          )
        ],
        title: const Text('حضوري'),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        controller.focusedDay.value = DateTime(
                          controller.focusedDay.value.year,
                          controller.focusedDay.value.month - 1,
                        );
                      },
                    ),
                    Text(
                      controller.getHijriMonthName(controller.focusedDay.value),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        controller.focusedDay.value = DateTime(
                          controller.focusedDay.value.year,
                          controller.focusedDay.value.month + 1,
                        );
                      },
                    ),
                  ],
                )),
            const SizedBox(height: 10),
            Obx(() => TableCalendar(
                  locale: 'ar',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2050, 12, 31),
                  focusedDay: controller.focusedDay.value,
                  selectedDayPredicate: (day) =>
                      isSameDay(controller.selectedDay.value, day),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(color: Colors.black),
                    weekendTextStyle: const TextStyle(color: Colors.red),
                  ),
                  onDaySelected: controller.onDaySelected,
                  onPageChanged: (focusedDay) {
                    controller.focusedDay.value = focusedDay;
                  },
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
                    defaultBuilder: (context, date, focusedDay) {
                      final hijri = HijriCalendar.fromDate(date);
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${hijri.hDay}',
                                style: const TextStyle(
                                  fontSize: 14,
                                )),
                            Text('${date.day}',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                    selectedBuilder: (context, date, focusedDay) {
                      final hijri = HijriCalendar.fromDate(date);
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${hijri.hDay}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  )),
                              Text('${date.day}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                    todayBuilder: (context, date, focusedDay) {
                      final hijri = HijriCalendar.fromDate(date);
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${hijri.hDay}',
                                  style: const TextStyle(color: Colors.white)),
                              Text('${date.day}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white70)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )),
            const SizedBox(height: 20),
            Obx(() => Text(
                  'اليوم الهجري: ${controller.getHijriDay(controller.focusedDay.value)}',
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
      ),
    );
  }
}
