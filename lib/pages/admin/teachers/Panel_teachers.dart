import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/pages/admin/teachers/Panel_teacherAttendances.dart';
import 'package:jaberah/pages/admin/teachers/teachers.dart';
import 'package:jaberah/pages/admin/teachers/teachersSalaries.dart';

class TeachersPanelPage extends StatelessWidget {
  const TeachersPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم المعلمين',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 10, // Space between columns
          mainAxisSpacing: 10, // Space between rows
          children: [
            _buildCard(
              context: context,
              title: 'حضور المعلمين',
              icon: Icons.schedule,
              color: Colors.blue,
              onTap: () {
                Get.to(() => TeachersAttendancePanel());
              },
            ),
            _buildCard(
              context: context,
              title: 'رواتب المعلمين',
              icon: Icons.attach_money,
              color: Colors.green,
              onTap: () {
                Get.to(() => TeachersSalaries());
              },
            ),
            _buildCard(
              context: context,
              title: 'معلومات المعلمين',
              icon: Icons.person,
              color: Colors.orange,
              onTap: () {
                Get.to(() => Teachers());
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

// Placeholder pages for the navigation
class TeachersAttendance extends StatelessWidget {
  const TeachersAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حضور المعلمين')),
      body: const Center(child: Text('صفحة حضور المعلمين')),
    );
  }
}

class TeachersInfoPage extends StatelessWidget {
  const TeachersInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('معلومات المعلمين')),
      body: const Center(child: Text('صفحة معلومات المعلمين')),
    );
  }
}
