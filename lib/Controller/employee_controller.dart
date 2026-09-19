import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Routes/app_routes.dart';
import 'package:project_v1/Widgets/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeController extends GetxController {
  final nameController = ''.obs;
  final phoneController = ''.obs;
  final passwordController = ''.obs;
  final selectedRole = 'simpleEmployee'.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;

  final nameTextController = TextEditingController();
  final phoneTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final deletePhoneTextController = TextEditingController();

  final roles = const ['admin', 'employee', 'simpleEmployee'];

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employeeRole') == 'admin';
  }

  Future<bool> addEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    final currentRole = prefs.getString('employeeRole');
    if (currentRole != 'admin') {
      AppSnackbar.show('غير مسموح', 'هذه الصفحة مخصصة للمدير فقط');
      return false;
    }

    final name = nameController.value.trim();
    final phone = phoneController.value.trim();
    final password = passwordController.value;

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      AppSnackbar.show('تنبيه', 'أكمل جميع بيانات الموظف');
      return false;
    }

    if (password.length < 6) {
      AppSnackbar.show('تنبيه', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return false;
    }

    try {
      isSaving.value = true;

      final ref = FirebaseFirestore.instance
          .collection('employees')
          .doc(phone);
      final existing = await ref.get();

      if (existing.exists) {
        AppSnackbar.show('تنبيه', 'رقم الهاتف مستخدم لموظف آخر');
        return false;
      }

      final passwordHash = sha256
          .convert(utf8.encode(password))
          .toString();

      await ref.set({
        'name': name,
        'phone': phone,
        'passwordHash': passwordHash,
        'role': selectedRole.value,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      clearForm();
      AppSnackbar.show('تمت الإضافة', 'تم إنشاء حساب الموظف بنجاح');
      return true;
    } catch (_) {
      AppSnackbar.show('خطأ', 'تعذر إضافة الموظف');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteEmployeeByPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final currentRole = prefs.getString('employeeRole');
    if (currentRole != 'admin') {
      AppSnackbar.show('غير مسموح', 'هذه الصفحة مخصصة للمدير فقط');
      return;
    }

    final phone = deletePhoneTextController.text.trim();

    if (phone.isEmpty) {
      AppSnackbar.show('تنبيه', 'أدخل رقم هاتف الموظف');
      return;
    }

    try {
      isDeleting.value = true;

      final ref = FirebaseFirestore.instance
          .collection('employees')
          .doc(phone);
      final doc = await ref.get();

      if (!doc.exists) {
        AppSnackbar.show('تنبيه', 'لا يوجد موظف بهذا الرقم');
        return;
      }

      final data = doc.data() ?? <String, dynamic>{};
      final employeeName = data['name']?.toString() ?? 'غير محدد';
      final employeePhone = data['phone']?.toString() ?? phone;

      final confirmed = await Get.dialog<bool>(
        Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'تأكيد حذف الموظف',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'هل أنت متأكد من حذف حساب الموظف التالي؟',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 18),
                _confirmInfo('اسم الموظف', employeeName),
                const SizedBox(height: 10),
                _confirmInfo('رقم الهاتف', employeePhone),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(result: false),
                child: const Text('إلغاء'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffB63131),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Get.back(result: true),
                child: const Text('نعم، احذف'),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      if (confirmed != true) return;

      await ref.delete();
      deletePhoneTextController.clear();
      AppSnackbar.show('تم الحذف', 'تم حذف حساب الموظف بنجاح');
    } catch (_) {
      AppSnackbar.show('خطأ', 'تعذر حذف الموظف');
    } finally {
      isDeleting.value = false;
    }
  }

  Widget _confirmInfo(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xffF7F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffDCE4E7)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff667378),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xff243033),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clearForm() {
    nameController.value = '';
    phoneController.value = '';
    passwordController.value = '';
    selectedRole.value = 'simpleEmployee';

    nameTextController.clear();
    phoneTextController.clear();
    passwordTextController.clear();
  }

  @override
  void onClose() {
    nameTextController.dispose();
    phoneTextController.dispose();
    passwordTextController.dispose();
    deletePhoneTextController.dispose();
    super.onClose();
  }

  void goBack() => Get.offAllNamed(AppRoutes.home);
}
