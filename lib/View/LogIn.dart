import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/login_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/LoginWidgets.dart';

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    return loginPageContent(context, controller);
  }
}
