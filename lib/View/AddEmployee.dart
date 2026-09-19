import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/employee_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/AddEmployeeWidgets.dart';
import 'package:project_v1/Widgets/app_theme.dart';
import 'package:project_v1/Widgets/app_drawer.dart';

class AddEmployee extends StatelessWidget {
  const AddEmployee({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployeeController>();

    return FutureBuilder<bool>(
      future: controller.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: desktopBackground,
            body: Center(child: CircularProgressIndicator(color: green)),
          );
        }

        if (snapshot.data == false) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => Get.offAllNamed('/home'),
          );
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
                Builder(
                  builder: (context) => addEmployeePageHeader(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: desktopContent(
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'بيانات الموظف الجديد',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'أدخل بيانات الحساب وحدد الصلاحية من القائمة.',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: mutedText, fontSize: 13),
                            ),
                            const SizedBox(height: 26),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final twoColumns = constraints.maxWidth >= 720;

                                final fields = [
                                  field(
                                    label: 'اسم الموظف',
                                    icon: Icons.person_outline_rounded,
                                    child: TextField(
                                      controller: controller.nameTextController,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,

                                      onChanged: (v) =>
                                          controller.nameController.value = v,
                                    ),
                                  ),
                                  field(
                                    label: 'رقم الهاتف',
                                    icon: Icons.phone_outlined,
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: TextField(
                                        controller:
                                            controller.phoneTextController,
                                        keyboardType: TextInputType.phone,
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        onChanged: (v) =>
                                            controller.phoneController.value =
                                                v,
                                      ),
                                    ),
                                  ),
                                  field(
                                    label: 'كلمة المرور',
                                    icon: Icons.lock_outline_rounded,
                                    child: TextField(
                                      controller:
                                          controller.passwordTextController,
                                      obscureText: true,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      onChanged: (v) =>
                                          controller.passwordController.value =
                                              v,
                                    ),
                                  ),
                                  field(
                                    label: 'الصلاحية',
                                    icon: Icons.admin_panel_settings_outlined,
                                    child: Obx(
                                      () => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: DropdownButtonFormField<String>(
                                          initialValue: controller.selectedRole.value,
                                          isExpanded: true,
                                          alignment: Alignment.centerRight,
                                          menuMaxHeight: 330,
                                          dropdownColor: Colors.white,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'admin',
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                'مدير',
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'employee',
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                'موظف (لا يمكنه إضافة موظف)',
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'simpleEmployee',
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                'موظف (لا يمكنه إضافة موظف، إنشاء تنبيه، تغيير حالة بلاغ)',
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                          onChanged: (v) {
                                            if (v != null) {
                                              controller.selectedRole.value = v;
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ];

                                if (!twoColumns) {
                                  return Column(
                                    children: [
                                      for (final field in fields) ...[
                                        field,
                                        const SizedBox(height: 18),
                                      ],
                                    ],
                                  );
                                }

                                return Wrap(
                                  textDirection: TextDirection.rtl,
                                  spacing: 20,
                                  runSpacing: 18,
                                  children: fields
                                      .map(
                                        (field) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                            top: 8,
                                            left: 70,
                                          ),
                                          child: SizedBox(
                                            width: 620,
                                            child: field,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 28),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Obx(
                                () => SizedBox(
                                  width: 190,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: controller.isSaving.value
                                        ? null
                                        : controller.addEmployee,
                                    icon: controller.isSaving.value
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person_add_alt_1_rounded,
                                            size: 19,
                                          ),
                                    label: const Text(
                                      'إضافة الموظف',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 34),
                            const Divider(color: borderColor),
                            const SizedBox(height: 24),
                            const Text(
                              'حذف موظف',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'اكتب رقم هاتف الموظف الذي تريد حذف حسابه.',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: mutedText, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 720,
                                child: field(
                                  label: 'رقم هاتف الموظف',
                                  icon: Icons.phone_outlined,
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: TextField(
                                      controller:
                                          controller.deletePhoneTextController,
                                      keyboardType: TextInputType.phone,
                                      textAlign: TextAlign.left,
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Obx(
                                () => SizedBox(
                                  width: 190,
                                  height: 48,
                                  child: SizedBox(
                                    width: 190,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: controller.isDeleting.value
                                          ? null
                                          : controller.deleteEmployeeByPhone,
                                      icon: controller.isDeleting.value
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person_remove_alt_1_rounded,
                                              size: 19,
                                              color: Colors.white,
                                            ),
                                      label: const Text(
                                        'حذف الموظف',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xffB63131,
                                        ),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: const Color(
                                          0xffB63131,
                                        ).withValues(alpha: 0.55),
                                        disabledForegroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
