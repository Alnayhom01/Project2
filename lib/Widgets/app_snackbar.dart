import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void show(String title, String message) {
    Get.snackbar(
      '',
      '',
      titleText: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      messageText: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15),
        ),
      ),
      backgroundColor: Colors.white,
      colorText: Colors.black,
      margin: const EdgeInsets.all(18),
      borderRadius: 13,
    );
  }
}
