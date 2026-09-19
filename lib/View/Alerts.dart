import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/alerts_controller.dart';
import 'package:project_v1/Routes/app_routes.dart';
import 'package:project_v1/Widgets/View_Widgets/AlertsWidgets.dart';
import 'package:project_v1/Widgets/app_drawer.dart';
import 'package:project_v1/Widgets/app_theme.dart';

class Alerts extends StatelessWidget {
  const Alerts({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlertsController>();

    return Obx(() {
      final allowed = controller.canOpen.value;

      if (allowed == null) {
        return const Scaffold(
          backgroundColor: desktopBackground,
          body: Center(
            child: CircularProgressIndicator(color: green),
          ),
        );
      }

      if (!allowed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute != AppRoutes.home) {
            Get.offAllNamed(AppRoutes.home);
          }
        });
        return const Scaffold(
          backgroundColor: desktopBackground,
          body: Center(
            child: CircularProgressIndicator(color: green),
          ),
        );
      }

      return Scaffold(
        backgroundColor: desktopBackground,
        drawer: const AppDrawer(),
        body: SafeArea(
          child: Column(
            children: [alertsPageHeader(context)],
          ),
        ),
      );
    });
  }
}
