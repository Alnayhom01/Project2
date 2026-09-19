import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Widgets/app_drawer.dart';
import 'package:project_v1/Widgets/View_Widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Alerts extends StatelessWidget {
  const Alerts({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canOpen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: desktopBackground,
            body: Center(child: CircularProgressIndicator(color: green)),
          );
        }

        if (snapshot.data == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed('/home');
          });

          return const Scaffold(
            backgroundColor: desktopBackground,
            body: Center(child: CircularProgressIndicator(color: green)),
          );
        }

        return Scaffold(
          backgroundColor: desktopBackground,
          drawer: const AppDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                desktopPageHeader(
                  context: context,
                  title: 'إنشاء تنبيه',
                  subtitle: 'إنشاء تنبيهات وتخصيصها',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _canOpen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employeeRole') != 'simpleEmployee';
  }
}
