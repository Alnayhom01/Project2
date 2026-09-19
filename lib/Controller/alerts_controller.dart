import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertsController extends GetxController {
  final canOpen = RxnBool();

  @override
  void onInit() {
    super.onInit();
    loadPermission();
  }

  Future<void> loadPermission() async {
    final prefs = await SharedPreferences.getInstance();
    canOpen.value = prefs.getString('employeeRole') != 'simpleEmployee';
  }
}
