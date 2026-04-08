import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/pages/user/reports/monthlyStudentsReports.dart';
import 'package:jaberah/pages/user/reports/prayersStudentsReport.dart';
import 'package:jaberah/pages/user/reports/semesterStudentsReports.dart';

class StudentsReport extends StatelessWidget {
  const StudentsReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تقارير الطلاب',
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
                Get.to(() => SemesterStudentsReports());
              },
            ),
            _buildCard(
              context: context,
              title: 'التقرير الشهري',
              icon: Icons.calendar_view_month,
              color: Colors.green,
              onTap: () {
                Get.to(() => MonthlyStudentsReports());
              },
            ),
            _buildCard(
              context: context,
              title: 'تقرير كشف الصلوات',
              icon: Icons.mosque,
              color: Colors.orange,
              onTap: () {
                Get.to(() => PrayersStudentsReportPage());
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
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
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
