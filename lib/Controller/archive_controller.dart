import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Model/report_model.dart';

class ArchiveController extends GetxController {
  final ReportController dataController = Get.find<ReportController>();
  final selectedStatus = 'الكل'.obs;

  List<ReportModel> get reports => dataController.archiveReports.where((report) {
    if (selectedStatus.value == 'الكل') return true;
    return report.status == selectedStatus.value;
  }).toList();

  bool get isLoading => dataController.isLoading.value;
  String get selectedType => dataController.selectedType.value;
  List<String> get reportTypes => dataController.reportTypes;

  void setSearch(String value) => dataController.setSearch(value);
  void setType(String? value) => dataController.setType(value);
  void setStatus(String value) => selectedStatus.value = value;
}
