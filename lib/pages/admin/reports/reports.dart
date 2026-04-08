import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/pages/admin/reports/monthlyPartialExamReport.dart';
import 'package:jaberah/pages/admin/reports/monthlyReports.dart';
import 'package:jaberah/pages/admin/reports/prayersReport.dart';
import 'package:jaberah/pages/admin/reports/semesterReports.dart';
import 'package:jaberah/pages/admin/teachers/reportTeachersAttendances.dart';

class Reports extends StatelessWidget {
  const Reports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التقارير',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.82,
          children: [
            _buildCard(
              context: context,
              title: 'التقرير الفصلي',
              icon: Icons.calendar_month,
              color: Colors.blue,
              onTap: () {
                Get.to(() => SemesterReportPage());
              },
            ),
            _buildCard(
              context: context,
              title: 'التقرير الشهري',
              icon: Icons.calendar_view_month,
              color: Colors.green,
              onTap: () {
                Get.to(() => MonthlyReportPage());
              },
            ),
            _buildCard(
              context: context,
              title: 'تقرير كشف الصلوات',
              icon: Icons.mosque,
              color: Colors.orange,
              onTap: () {
                Get.to(() => PrayersReportPage());
              },
            ),
            _buildCard(
              context: context,
              title: 'تقرير الاختبارات الجزئية الشهري',
              icon: Icons.quiz_outlined,
              color: Colors.amber,
              onTap: () {
                Get.to(() => MonthlyPartialExamReportPage());
              },
            ),
            _buildCard(
              context: context,
              title: 'تقرير حضور المعلمين',
              icon: Icons.assessment,
              color: Colors.teal,
              onTap: () {
                Get.to(() => TeachersAttendanceReport());
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to build each card
  Widget _buildCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GE_SS_Two',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
