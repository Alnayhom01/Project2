import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/login_controller.dart';
import 'package:project_v1/Routes/app_routes.dart';
import 'package:project_v1/Widgets/View_Widgets/common_widgets.dart';

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: desktopBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: IntrinsicHeight(
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(54, 52, 54, 52),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'تسجيل الدخول',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: textDark,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'ادخل إلى لوحة تحكم البلدية',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: mutedText,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'رقم الهاتف',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: textDark,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: TextField(
                                  keyboardType: TextInputType.phone,
                                  textAlign: TextAlign.left,
                                  textDirection: TextDirection.ltr,
                                  onChanged: (v) =>
                                      controller.phoneController.value = v,
                                  decoration: const InputDecoration(
                                    hintText: '09xxxxxxxx',
                                    prefixIcon: Icon(
                                      Icons.phone_outlined,
                                      color: mutedText,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'كلمة المرور',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: textDark,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                obscureText: true,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                onChanged: (v) =>
                                    controller.passwordController.value = v,
                                onSubmitted: (_) async {
                                  if (await controller.login()) {
                                    Get.offAllNamed(AppRoutes.home);
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: 'أدخل كلمة المرور',
                                  suffixIconConstraints: BoxConstraints(
                                    minWidth: 44,
                                    maxWidth: 44,
                                    minHeight: 44,
                                    maxHeight: 44,
                                  ),
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.all(11),
                                    child: Icon(
                                      Icons.lock_outline_rounded,
                                      color: mutedText,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Obx(
                                () => SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () async {
                                            final success =
                                                await controller.login();
                                            if (success) {
                                              Get.offAllNamed(AppRoutes.home);
                                            }
                                          },
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'تسجيل الدخول',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: borderColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
