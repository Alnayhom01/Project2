import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/reports_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/ReportsWidgets.dart';
import 'package:project_v1/Widgets/app_drawer.dart';
import 'package:project_v1/Widgets/app_theme.dart';

class Reports extends StatelessWidget {
  const Reports({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();

    return Scaffold(
      backgroundColor: desktopBackground,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            reportsPageHeader(context),
            Expanded(
              child: Obx(() {
                final reports = controller.reports;
                return reportsPageContent(
                  controller: controller,
                  reports: reports,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
