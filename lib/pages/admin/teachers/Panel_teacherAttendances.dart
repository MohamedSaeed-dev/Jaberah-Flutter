import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/pages/admin/teachers/reportTeachersAttendances.dart';
import 'package:jaberah/pages/admin/teachers/teachersAttendances.dart';

class TeachersAttendancePanel extends StatelessWidget {
  const TeachersAttendancePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة التحكم - الحضور',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Number of columns (2 cards in this case)
          crossAxisSpacing: 10, // Space between columns
          mainAxisSpacing: 10,
          children: [
            _buildCard1(context: context, title: "تسجيل الحضور اليومي", icon: Icons.person_add, color: Colors.blue, onTap: (){
              Get.to(() => TeachersAttendancePage());
            }),
            _buildCard1(context: context, title: "تقرير حضور المعلمين", icon: Icons.assessment, color: Colors.red, onTap: (){
              Get.to(() => TeachersAttendanceReport());
            }),
          ],
      ),
      )
    );
  }

  // Method to build each card
  Widget _buildCard1({
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


