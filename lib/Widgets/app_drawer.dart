import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Routes/app_routes.dart';
import 'package:project_v1/Widgets/View_Widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 360,
      backgroundColor: Colors.white,
      elevation: 18,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: green),
                );
              }

              final prefs = snapshot.data!;
              final role = prefs.getString('employeeRole') ?? 'simpleEmployee';
              final name = prefs.getString('employeeName') ?? 'الموظف';

              final items = <_DrawerItem>[
                const _DrawerItem(
                  Icons.dashboard_rounded,
                  'الرئيسية',
                  AppRoutes.home,
                ),
                const _DrawerItem(
                  Icons.pending_actions_rounded,
                  'قيد المعالجة',
                  AppRoutes.inProgress,
                ),
                const _DrawerItem(
                  Icons.assessment_rounded,
                  'التقارير',
                  AppRoutes.reports,
                ),
                if (role != 'simpleEmployee')
                  const _DrawerItem(
                    Icons.notifications_active_outlined,
                    'إنشاء تنبيه',
                    AppRoutes.alerts,
                  ),
                const _DrawerItem(
                  Icons.archive_rounded,
                  'الأرشيف',
                  AppRoutes.archive,
                ),
              ];

              if (role == 'admin') {
                items.add(
                  const _DrawerItem(
                    Icons.person_add_rounded,
                    'إضافة موظف',
                    AppRoutes.addEmployee,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 18, 16),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'asset/image/icon.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'بلاغ',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: textDark,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'إغلاق',
                          onPressed: Get.back,
                          icon: const Icon(Icons.close_rounded, size: 22),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: borderColor),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF7F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          const CircleAvatar(
                            radius: 21,
                            backgroundColor: Color(0xffE8F7EC),
                            child: Icon(
                              Icons.person_rounded,
                              color: green,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              name,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 3),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return _item(context, item.icon, item.title, () {
                          Get.back();
                          Get.offNamed(item.route);
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1, color: borderColor),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: _item(
                      context,
                      Icons.logout_rounded,
                      'تسجيل الخروج',
                      () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('isLoggedIn');
                        await prefs.remove('employeePhone');
                        await prefs.remove('employeeRole');
                        await prefs.remove('employeeName');
                        Get.offAllNamed(AppRoutes.login);
                      },
                      danger: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: danger ? const Color(0xfffff2f2) : const Color(0xffF1F8F3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                icon,
                size: 21,
                color: danger ? const Color(0xffB63131) : textDark,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: danger ? const Color(0xffB63131) : textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String title;
  final String route;

  const _DrawerItem(this.icon, this.title, this.route);
}
