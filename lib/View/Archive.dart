import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Widgets/View_Widgets/common_widgets.dart';
import 'package:project_v1/Widgets/app_drawer.dart';

class Archive extends StatefulWidget {
  const Archive({super.key});

  @override
  State<Archive> createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  String _selectedStatus = 'الكل';
  final ScrollController _archiveScrollController = ScrollController();

  @override
  void dispose() {
    _archiveScrollController.dispose();
    super.dispose();
  }

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
              title: 'الأرشيف',
              subtitle: 'البلاغات المحلولة والمرفوضة فقط',
            ),
            Expanded(
              child: Obx(
                () => desktopContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // شريط واحد يجمع فلتر حالة الأرشيف + نوع البلاغ + البحث.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 260,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  isExpanded: true,
                                  alignment: Alignment.centerRight,
                                  dropdownColor: Colors.white,
                                  icon: const SizedBox.shrink(),
                                  decoration: const InputDecoration(
                                    labelText: 'حالة الأرشيف',
                                    prefixIcon: Icon(
                                      Icons.filter_alt_outlined,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: mutedText,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem<String>(
                                      value: 'الكل',
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'الكل',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'تم الحل',
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'تم الحل',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'تم الرفض',
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'تم الرفض',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;

                                    setState(() {
                                      _selectedStatus = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              SizedBox(
                                width: 360,
                                child: DropdownButtonFormField<String>(
                                  value: controller.selectedType.value,
                                  isExpanded: true,
                                  alignment: Alignment.centerRight,
                                  dropdownColor: Colors.white,
                                  icon: const SizedBox.shrink(),
                                  decoration: const InputDecoration(
                                    labelText: 'نوع البلاغ',
                                    prefixIcon: Icon(
                                      Icons.filter_alt_outlined,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: mutedText,
                                    ),
                                  ),
                                  items: controller.reportTypes
                                      .map(
                                        (type) => DropdownMenuItem<String>(
                                          value: type,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            type,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: controller.setType,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  onChanged: controller.setSearch,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'بحث برقم البلاغ أو رقم الهاتف أو الوصف',
                                    suffixIcon: Icon(
                                      Icons.search_rounded,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final reports =
                                controller.archiveReports.where((report) {
                              if (_selectedStatus == 'الكل') {
                                return true;
                              }
                              return report.status == _selectedStatus;
                            }).toList();

                            if (controller.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: green,
                                ),
                              );
                            }

                            if (reports.isEmpty) {
                              return const Center(
                                child: Text(
                                  'لا توجد بلاغات مؤرشفة',
                                  style: TextStyle(
                                    color: mutedText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }

                            return Scrollbar(
                              controller: _archiveScrollController,
                              thumbVisibility: true,
                              scrollbarOrientation: ScrollbarOrientation.right,
                              child: ListView.builder(
                                controller: _archiveScrollController,
                                primary: false,
                                itemCount: reports.length,
                                itemBuilder: (_, i) {
                                  final report = reports[i];

                                  return reportCard(
                                    context: context,
                                    report: report,
                                    showStatus: true,
                                    onOpen: () =>
                                        showReportDetailsDialog(
                                      context: context,
                                      report: report,
                                      controller: controller,
                                      canChangeStatus: false,
                                    ),
                                  );
                                },
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
}
