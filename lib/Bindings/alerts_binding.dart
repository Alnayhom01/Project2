import 'package:get/get.dart';
import 'package:project_v1/Controller/alerts_controller.dart';

class AlertsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlertsController>(() => AlertsController());
  }
}
