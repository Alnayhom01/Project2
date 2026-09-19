import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Model/report_model.dart';

class ReportsController extends GetxController {
  final ReportController dataController = Get.find<ReportController>();

  List<ReportModel> get reports => dataController.allReports.toList();

  int count(String status) =>
      reports.where((report) => report.status == status).length;
}
