import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/common_widgets.dart';
import 'package:project_v1/Widgets/app_drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
              title: 'الرئيسية',
              subtitle: 'البلاغات الجديدة الواردة',
            ),
            Expanded(
              child: Obx(() {
                final reports = controller.byStatus('جديد');

                return desktopContent(
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
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
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          const Text(
                            'البلاغات الجديدة',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffE7F7EB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${reports.length}',
                              style: const TextStyle(
                                color: green,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: controller.isLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(color: green),
                              )
                            : reports.isEmpty
                            ? _emptyState('لا توجد بلاغات جديدة')
                            : ListView.builder(
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
                              ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Center(
      child: Container(
        width: 430,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 46,
              color: Color(0xff95A1A5),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
