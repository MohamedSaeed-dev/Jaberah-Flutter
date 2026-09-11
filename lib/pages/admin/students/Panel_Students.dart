import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/pages/admin/students/students.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

class Panel_Students extends StatelessWidget {
  const Panel_Students({super.key});

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      title: 'الطلاب',
      subtitle: 'بيانات الطلاب المسجّلين',
      body: SafeArea(
        top: false,
        child: GridView.count(
          padding: const EdgeInsets.all(AppSpacing.md),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.98,
          children: [
            JStatTile(
              title: 'بيانات الطلاب',
              icon: Icons.school_outlined,
              unit: 'إضافة وتعديل وحذف',
              onTap: () => Get.to(() => Students()),
            ),
          ],
        ),
      ),
    );
  }
}
