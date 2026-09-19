import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/in_progress_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/InProgressWidgets.dart';
import 'package:project_v1/Widgets/app_drawer.dart';
import 'package:project_v1/Widgets/app_theme.dart';

class InProgress extends StatelessWidget {
  const InProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InProgressController>();
    return Scaffold(
      backgroundColor: desktopBackground,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            inProgressPageHeader(context),
            Expanded(child: Obx(() => inProgressPageContent(context, controller))),
          ],
        ),
      ),
    );
  }
}
