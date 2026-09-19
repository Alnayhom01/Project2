import 'package:get/get.dart';
import 'package:project_v1/Bindings/employee_binding.dart';
import 'package:project_v1/Bindings/login_binding.dart';
import 'package:project_v1/Bindings/report_binding.dart';
import 'package:project_v1/Routes/app_routes.dart';
import 'package:project_v1/View/AddEmployee.dart';
import 'package:project_v1/View/Alerts.dart';
import 'package:project_v1/View/Archive.dart';
import 'package:project_v1/View/Home.dart';
import 'package:project_v1/View/InProgress.dart';
import 'package:project_v1/View/LogIn.dart';
import 'package:project_v1/View/Reports.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LogIn(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const Home(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.inProgress,
      page: () => const InProgress(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const Reports(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.archive,
      page: () => const Archive(),
      binding: ReportBinding(),
    ),
    GetPage(name: AppRoutes.alerts, page: () => const Alerts()),
    GetPage(
      name: AppRoutes.addEmployee,
      page: () => const AddEmployee(),
      binding: EmployeeBinding(),
    ),
  ];
}
