import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/pages/user/followStudents/groups_followStudents.dart';


class FollowStudents extends StatelessWidget {
  const FollowStudents({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المتابعة اليومية',
          style:
              TextStyle(fontFamily: 'GE_SS_Two', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 181, 108),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 2, // Number of columns (2 cards in this case)
          crossAxisSpacing: 10, // Space between columns
          mainAxisSpacing: 10, // Space between rows
          children: [
            _buildCard(
              context: context,
              title: 'تحضير الطلاب',
              icon: Icons.calendar_month,
              color: Colors.green,
              onTap: () {
                Get.to(() => null);
              },
            ),
            _buildCard(
              context: context,
              title: 'تسميع الطلاب',
              icon: Icons.calendar_view_month,
              color: Colors.blue,
              onTap: () {
                Get.to(() => GroupsFollowStudents());
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
