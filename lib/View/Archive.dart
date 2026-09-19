import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/archive_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/ArchiveWidgets.dart';
import 'package:project_v1/Widgets/app_drawer.dart';
import 'package:project_v1/Widgets/app_theme.dart';

class Archive extends StatelessWidget {
  const Archive({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArchiveController>();
    return Scaffold(
      backgroundColor: desktopBackground,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            archivePageHeader(context),
            Expanded(child: Obx(() => archivePageContent(context, controller))),
          ],
        ),
      ),
    );
  }
}
