import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Model/report_model.dart';

class InProgressController extends GetxController {
  final ReportController dataController = Get.find<ReportController>();

  List<ReportModel> get reports => dataController.byStatus('قيد المعالجة');
  bool get isLoading => dataController.isLoading.value;
  String get selectedType => dataController.selectedType.value;
  List<String> get reportTypes => dataController.reportTypes;
  bool get canChangeStatus => dataController.canChangeStatus;

  void setSearch(String value) => dataController.setSearch(value);
  void setType(String? value) => dataController.setType(value);
}
