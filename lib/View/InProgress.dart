import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/common_widgets.dart';
import 'package:project_v1/Widgets/app_drawer.dart';

class InProgress extends StatefulWidget {
  const InProgress({super.key});

  @override
  State<InProgress> createState() => _InProgressState();
}

class _InProgressState extends State<InProgress> {

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Scaffold(
      backgroundColor: desktopBackground,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            desktopPageHeader(
              context: context,
              title: 'قيد المعالجة',
              subtitle: 'البلاغات التي يجري التعامل معها',
            ),
            Expanded(
              child: Obx(
                () => desktopContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      filterBar(
                        selectedType: controller.selectedType.value,
                        types: controller.reportTypes,
                        onSearch: controller.setSearch,
                        onTypeChanged: controller.setType,
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final reports = controller.byStatus('قيد المعالجة');

                            if (controller.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(color: green),
                              );
                            }

                            if (reports.isEmpty) {
                              return _emptyState();
                            }

                            return ListView.builder(
                                primary: false,
                              itemCount: reports.length,
                              itemBuilder: (_, i) => reportCard(
                                context: context,
                                report: reports[i],
                                onOpen: () => showReportDetailsDialog(
                                  context: context,
                                  report: reports[i],
                                  controller: controller,
                                  canChangeStatus: controller.canChangeStatus,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'لا توجد بلاغات قيد المعالجة',
        style: TextStyle(
          color: mutedText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
