import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Controller/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReportController>()) {
      Get.put<ReportController>(ReportController(), permanent: true);
    }
    Get.lazyPut<ReportsController>(() => ReportsController());
  }
}
