import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaberah/controllers/user/groupsFollowStudentsController.dart';
import 'package:jaberah/pages/user/followStudents/students_followStudents.dart';
import 'package:jaberah/theme/theme.dart';
import 'package:jaberah/widgets/ds/ds.dart';

class GroupsFollowStudents extends StatelessWidget {
  GroupsFollowStudents({super.key});

  final GroupsFollowStudentsController groupsController =
      Get.put(GroupsFollowStudentsController());

  @override
  Widget build(BuildContext context) {
    return JScaffold(
      appBar: JAppBar(
        title: 'الحلقات',
        subtitle: 'المتابعة اليومية',
        leading: JAppBarButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'رجوع',
          onPressed: () {
            Get.delete<GroupsFollowStudentsController>();
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (groupsController.isLoading.value) {
            return const JLoadingState(message: 'جاري تحميل الحلقات...');
          }
          if (groupsController.groups.isEmpty) {
            return const JEmptyState(
              title: 'لا توجد حلقات',
              message: 'لم تُسند إليك أي حلقة بعد.',
              icon: Icons.hub_outlined,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.98,
            ),
            itemCount: groupsController.groups.length,
            itemBuilder: (context, index) {
              final data = groupsController.groups[index];
              return JStatTile(
                title: data.groupName,
                icon: Icons.auto_stories_outlined,
                tone: index.isEven ? JTone.primary : JTone.gold,
                value: '${data.studentsNo}',
                unit: 'طالب · ${data.period}',
                onTap: () {
                  Get.to(
                    () => StudentGroupsFollowStudents(),
                    arguments: {"id": data.id, "Name": data.groupName},
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}
