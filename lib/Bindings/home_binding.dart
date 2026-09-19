import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReportController>()) {
      Get.put<ReportController>(ReportController(), permanent: true);
    }
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
