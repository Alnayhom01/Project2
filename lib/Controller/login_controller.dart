import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:project_v1/Routes/app_routes.dart';
import 'package:project_v1/Widgets/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final phoneController = ''.obs;
  final passwordController = ''.obs;
  final isLoading = false.obs;

  Future<bool> login() async {
    final phone = phoneController.value.trim();
    final password = passwordController.value;

    if (phone.isEmpty || password.isEmpty) {
      AppSnackbar.show('تنبيه', 'أدخل رقم الهاتف وكلمة المرور');
      return false;
    }

    try {
      isLoading.value = true;

      final doc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(phone)
          .get();

      if (!doc.exists) {
        AppSnackbar.show('خطأ', 'بيانات الموظف غير صحيحة');
        return false;
      }

      final data = doc.data();
      if (data == null) {
        AppSnackbar.show('خطأ', 'تعذر قراءة بيانات الموظف');
        return false;
      }

      if (data['active'] == false) {
        AppSnackbar.show('تنبيه', 'هذا الحساب غير مفعل');
        return false;
      }

      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      if (data['passwordHash']?.toString() != passwordHash) {
        AppSnackbar.show('خطأ', 'رقم الهاتف أو كلمة المرور غير صحيحة');
        return false;
      }

      final role = data['role']?.toString() ?? 'simpleEmployee';
      final name = data['name']?.toString() ?? '';
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('employeePhone', phone);
      await prefs.setString('employeeRole', role);
      await prefs.setString('employeeName', name);

      return true;
    } catch (e) {
      AppSnackbar.show('خطأ', 'تعذر الاتصال بقاعدة البيانات');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('employeePhone');
    await prefs.remove('employeeRole');
    await prefs.remove('employeeName');
    Get.offAllNamed(AppRoutes.login);
  }
}
