import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/home_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/HomeWidgets.dart';
import 'package:project_v1/Widgets/app_drawer.dart';
import 'package:project_v1/Widgets/app_theme.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: desktopBackground,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            homePageHeader(context),
            Expanded(
              child: Obx(() => homePageContent(context, controller)),
            ),
          ],
        ),
      ),
    );
  }
}
