import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Controller/reports_controller.dart';
import 'package:project_v1/Model/report_model.dart';
import 'package:project_v1/Widgets/app_theme.dart';

class _ReportDashboard extends StatelessWidget {
  final ReportController controller;
  final List<ReportModel> reports;

  const _ReportDashboard({required this.controller, required this.reports});

  int _count(String status) =>
      reports.where((report) => report.status == status).length;

  Map<String, _CategoryStats> _categoryStats() {
    final map = <String, _CategoryStats>{
      for (final type in controller.reportTypes.skip(1))
        if (type != 'غيرها من المشاكل') type: _CategoryStats(),
    };

    for (final report in reports) {
      final category = controller.categoryForReportType(report.type);

      if (category == 'غيرها من المشاكل') {
        continue;
      }

      final stats = map.putIfAbsent(category, _CategoryStats.new);
      stats.total++;

      switch (report.status) {
        case 'جديد':
          stats.newCount++;
          break;
        case 'قيد المعالجة':
          stats.inProgress++;
          break;
        case 'تم الحل':
          stats.solved++;
          break;
        case 'تم الرفض':
          stats.rejected++;
          break;
      }
    }

    return map;
  }

  List<_CategoryRow> _rankedCategories() {
    final map = _categoryStats();
    final rows = map.entries.map((entry) {
      final stats = entry.value;
      final closed = stats.solved + stats.rejected;
      final solutionRate = stats.total == 0
          ? 0.0
          : stats.solved / stats.total * 100;
      final closedRate = stats.total == 0 ? 0.0 : closed / stats.total * 100;

      return _CategoryRow(
        name: entry.key,
        stats: stats,
        solutionRate: solutionRate,
        closedRate: closedRate,
      );
    }).toList();

    rows.sort((a, b) {
      final byTotal = b.stats.total.compareTo(a.stats.total);
      if (byTotal != 0) return byTotal;
      return a.name.compareTo(b.name);
    });

    return rows;
  }

  List<_MonthPoint> _lastSixMonths() {
    final now = DateTime.now();
    final points = <_MonthPoint>[];

    for (int offset = 5; offset >= 0; offset--) {
      final monthDate = DateTime(now.year, now.month - offset, 1);
      final count = reports.where((report) {
        final date = report.createdAt;
        if (date == null) return false;
        return date.year == monthDate.year && date.month == monthDate.month;
      }).length;

      points.add(
        _MonthPoint(
          label:
              '${monthDate.month.toString().padLeft(2, '0')}/${monthDate.year}',
          count: count,
        ),
      );
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final total = reports.length;
    final solved = _count('تم الحل');
    final rejected = _count('تم الرفض');
    final inProgress = _count('قيد المعالجة');
    final newCount = _count('جديد');

    final solvedRate = total == 0 ? 0.0 : solved / total * 100;
    final rejectedRate = total == 0 ? 0.0 : rejected / total * 100;
    final closedRate = total == 0 ? 0.0 : (solved + rejected) / total * 100;

    final categories = _rankedCategories();
    final months = _lastSixMonths();
    final topCategory = categories.isEmpty || categories.first.stats.total == 0
        ? 'لا يوجد'
        : categories.first.name;

    return Scrollbar(
      interactive: true,
      scrollbarOrientation: ScrollbarOrientation.right,
      child: SingleChildScrollView(
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'لوحة التقارير والإحصائيات',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: textDark,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'مؤشرات ونسب وتوزيع البلاغات حسب الحالة والنوع والزمن',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                ElevatedButton.icon(
                  onPressed: () => _print(context),
                  icon: const Icon(Icons.print_outlined, size: 19),
                  label: const Text('طباعة التقرير'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Wrap(
              textDirection: TextDirection.rtl,
              spacing: 14,
              runSpacing: 14,
              children: [
                _KpiCard(
                  title: 'الأكثر ورودًا',
                  value: topCategory,
                  subtitle: 'أكثر نوع من حيث عدد البلاغات',
                  icon: Icons.trending_up_rounded,
                ),
                _KpiCard(
                  title: 'نسبة الرفض',
                  value: '${rejectedRate.toStringAsFixed(1)}%',
                  subtitle: '$rejected بلاغ مرفوض',
                  icon: Icons.block_outlined,
                ),
                _KpiCard(
                  title: 'نسبة الإغلاق',
                  value: '${closedRate.toStringAsFixed(1)}%',
                  subtitle: '${solved + rejected} بلاغ مغلق',
                  icon: Icons.task_alt_outlined,
                ),
                _KpiCard(
                  title: 'نسبة الحل',
                  value: '${solvedRate.toStringAsFixed(1)}%',
                  subtitle: '$solved بلاغ تم حله',
                  icon: Icons.verified_outlined,
                ),
                _KpiCard(
                  title: 'إجمالي البلاغات',
                  value: '$total',
                  subtitle: 'جميع البلاغات المسجلة في النظام',
                  icon: Icons.assignment_outlined,
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _Panel(
                    title: 'توزيع البلاغات حسب الحالة',
                    icon: Icons.pie_chart_outline_rounded,
                    child: _StatusBars(
                      total: total,
                      items: [
                        _StatusItem('جديد', newCount, green),
                        _StatusItem(
                          'قيد المعالجة',
                          inProgress,
                          const Color(0xffD99000),
                        ),
                        _StatusItem(
                          'تم الحل',
                          solved,
                          const Color(0xff2F9E44),
                        ),
                        _StatusItem(
                          'تم الرفض',
                          rejected,
                          const Color(0xffB63131),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 4,
                  child: _Panel(
                    title: 'البلاغات خلال آخر 6 أشهر',
                    icon: Icons.bar_chart_rounded,
                    child: _MonthChart(points: months),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _Panel(
              title: 'ترتيب أنواع البلاغات حسب عدد البلاغات',
              icon: Icons.leaderboard_outlined,
              child: _CategoryTable(rows: categories),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _print(BuildContext context) async {
    try {
      final regular = pw.Font.ttf(
        (await rootBundle.load(
          'asset/fonts/NotoSansArabic-Regular.ttf',
        )).buffer.asByteData(),
      );
      final bold = pw.Font.ttf(
        (await rootBundle.load(
          'asset/fonts/NotoSansArabic-Bold.ttf',
        )).buffer.asByteData(),
      );

      final total = reports.length;
      final solved = _count('تم الحل');
      final rejected = _count('تم الرفض');
      final inProgress = _count('قيد المعالجة');
      final newCount = _count('جديد');
      final solvedRate = total == 0 ? 0.0 : solved / total * 100;
      final closedRate = total == 0 ? 0.0 : (solved + rejected) / total * 100;

      final rows = _rankedCategories();
      final months = _lastSixMonths();
      final now = DateTime.now();

      final doc = pw.Document(
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
      );

      final categoryRows = rows
          .map(
            (row) => [
              row.name,
              '${row.stats.total}',
              '${row.stats.newCount}',
              '${row.stats.inProgress}',
              '${row.stats.solved}',
              '${row.stats.rejected}',
              '${row.solutionRate.toStringAsFixed(1)}%',
              '${row.closedRate.toStringAsFixed(1)}%',
            ],
          )
          .toList();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(28),
          build: (context) => [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    'تقرير البلاغات والإحصائيات',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: bold, fontSize: 22),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'تاريخ إعداد التقرير: '
                    '${now.day.toString().padLeft(2, '0')}/'
                    '${now.month.toString().padLeft(2, '0')}/'
                    '${now.year}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: regular, fontSize: 10),
                  ),
                  pw.SizedBox(height: 18),

                  pw.Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _pdfKpi('إجمالي البلاغات', '$total', bold, regular),
                      _pdfKpi(
                        'نسبة الحل',
                        '${solvedRate.toStringAsFixed(1)}%',
                        bold,
                        regular,
                      ),
                      _pdfKpi(
                        'نسبة الإغلاق',
                        '${closedRate.toStringAsFixed(1)}%',
                        bold,
                        regular,
                      ),
                      _pdfKpi(
                        'نسبة الرفض',
                        '${(total == 0 ? 0 : rejected / total * 100).toStringAsFixed(1)}%',
                        bold,
                        regular,
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 18),

                  pw.Text(
                    'توزيع البلاغات حسب الحالة',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: bold, fontSize: 15),
                  ),
                  pw.SizedBox(height: 8),

                  pw.Table.fromTextArray(
                    headers: const ['الحالة', 'العدد', 'النسبة'],
                    data: [
                      [
                        'جديد',
                        '$newCount',
                        '${(total == 0 ? 0 : newCount / total * 100).toStringAsFixed(1)}%',
                      ],
                      [
                        'قيد المعالجة',
                        '$inProgress',
                        '${(total == 0 ? 0 : inProgress / total * 100).toStringAsFixed(1)}%',
                      ],
                      [
                        'تم الحل',
                        '$solved',
                        '${(total == 0 ? 0 : solved / total * 100).toStringAsFixed(1)}%',
                      ],
                      [
                        'تم الرفض',
                        '$rejected',
                        '${(total == 0 ? 0 : rejected / total * 100).toStringAsFixed(1)}%',
                      ],
                    ],
                    headerStyle: pw.TextStyle(font: bold, fontSize: 10),
                    cellStyle: pw.TextStyle(font: regular, fontSize: 9),
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.center,
                    cellPadding: const pw.EdgeInsets.all(7),
                  ),

                  pw.SizedBox(height: 18),

                  pw.Text(
                    'ترتيب أنواع البلاغات',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: bold, fontSize: 15),
                  ),
                  pw.SizedBox(height: 8),

                  pw.Table.fromTextArray(
                    headers: const [
                      'نوع البلاغ',
                      'العدد',
                      'جديد',
                      'قيد المعالجة',
                      'تم الحل',
                      'تم الرفض',
                      'نسبة الحل',
                      'نسبة الإغلاق',
                    ],
                    data: categoryRows,
                    headerStyle: pw.TextStyle(font: bold, fontSize: 9),
                    cellStyle: pw.TextStyle(font: regular, fontSize: 8.5),
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.center,
                    cellPadding: const pw.EdgeInsets.all(6),
                  ),

                  pw.SizedBox(height: 18),

                  pw.Text(
                    'البلاغات خلال آخر 6 أشهر',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: bold, fontSize: 15),
                  ),
                  pw.SizedBox(height: 8),

                  pw.Table.fromTextArray(
                    headers: const ['الشهر', 'عدد البلاغات'],
                    data: months
                        .map((point) => [point.label, '${point.count}'])
                        .toList(),
                    headerStyle: pw.TextStyle(font: bold, fontSize: 9),
                    cellStyle: pw.TextStyle(font: regular, fontSize: 9),
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.center,
                    cellPadding: const pw.EdgeInsets.all(6),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      final pdfBytes = await doc.save();

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(18),
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.94,
              height: MediaQuery.of(dialogContext).size.height * 0.92,
              child: PdfPreview(
                build: (format) async => pdfBytes,
                allowPrinting: true,
                allowSharing: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
              ),
            ),
          );
        },
      );
    } catch (_) {
      Get.snackbar(
        'خطأ',
        'تعذر تجهيز التقرير للطباعة',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  pw.Widget _pdfKpi(String title, String value, pw.Font bold, pw.Font regular) {
    return pw.Container(
      width: 155,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFFDCE4E7)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              title,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(font: regular, fontSize: 9),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(font: bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 285,
      height: 118,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // الأيقونة على اليمين
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xffE7F7EB),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: green, size: 24),
            ),

            const SizedBox(width: 12),

            // النصوص من اليمين إلى اليسار
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        title,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          value,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: mutedText,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Panel({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Icon(icon, color: green, size: 21),
                const SizedBox(width: 9),
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _StatusItem {
  final String name;
  final int count;
  final Color color;

  const _StatusItem(this.name, this.count, this.color);
}

class _StatusBars extends StatelessWidget {
  final int total;
  final List<_StatusItem> items;

  const _StatusBars({required this.total, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final percentage = total == 0 ? 0.0 : item.count / total * 100;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${item.count}  •  ${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: total == 0 ? 0 : item.count / total,
                    backgroundColor: const Color(0xffEEF2F3),
                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MonthPoint {
  final String label;
  final int count;

  const _MonthPoint({required this.label, required this.count});
}

class _MonthChart extends StatelessWidget {
  final List<_MonthPoint> points;

  const _MonthChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxCount = points.fold<int>(
      0,
      (maxValue, item) => item.count > maxValue ? item.count : maxValue,
    );

    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.rtl,
        children: points.map((point) {
          final heightFactor = maxCount == 0 ? 0.0 : point.count / maxCount;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${point.count}',
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 30,
                    height: 150 * heightFactor + 4,
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    point.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: mutedText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryStats {
  int total = 0;
  int newCount = 0;
  int inProgress = 0;
  int solved = 0;
  int rejected = 0;
}

class _CategoryRow {
  final String name;
  final _CategoryStats stats;
  final double solutionRate;
  final double closedRate;

  const _CategoryRow({
    required this.name,
    required this.stats,
    required this.solutionRate,
    required this.closedRate,
  });
}

class _CategoryTable extends StatelessWidget {
  final List<_CategoryRow> rows;

  const _CategoryTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DataTable(
        headingRowHeight: 48,
        dataRowMinHeight: 54,
        dataRowMaxHeight: 62,
        columnSpacing: 34,
        columns: const [
          DataColumn(label: Text('الترتيب')),
          DataColumn(label: Text('نوع البلاغ')),
          DataColumn(label: Text('العدد')),
          DataColumn(label: Text('تم الحل')),
          DataColumn(label: Text('تم الرفض')),
          DataColumn(label: Text('نسبة الحل')),
          DataColumn(label: Text('نسبة الإغلاق')),
        ],
        rows: [
          for (int i = 0; i < rows.length; i++)
            DataRow(
              cells: [
                DataCell(
                  Text(
                    '${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                DataCell(
                  Text(
                    rows[i].name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                DataCell(Text('${rows[i].stats.total}')),
                DataCell(Text('${rows[i].stats.solved}')),
                DataCell(Text('${rows[i].stats.rejected}')),
                DataCell(Text('${rows[i].solutionRate.toStringAsFixed(1)}%')),
                DataCell(Text('${rows[i].closedRate.toStringAsFixed(1)}%')),
              ],
            ),
        ],
      ),
    );
  }
}

Widget reportsPageHeader(BuildContext context) {
  return Container(
    height: 78,
    padding: const EdgeInsets.symmetric(horizontal: 30),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: borderColor, width: 1)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Builder(
              builder: (context) => Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Scaffold.of(context).openDrawer(),
                  hoverColor: const Color(0xffF2F7F4),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.menu_rounded, color: textDark, size: 25),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Container(width: 1, height: 30, color: borderColor),
            const SizedBox(width: 18),
            const Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'التقارير',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                     SizedBox(height: 1),
                     Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'لوحة إحصائية وتحليلية شاملة للبلاغات',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: mutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    ),
  );
}

Widget reportsPageContent({
  required ReportsController controller,
  required List<ReportModel> reports,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: SizedBox(
          width: double.infinity,
          child: reports.isEmpty && controller.dataController.isLoading.value
              ? const Center(child: CircularProgressIndicator(color: green))
              : reports.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد بيانات لعرض التقرير',
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : _ReportDashboard(
                  controller: controller.dataController,
                  reports: reports,
                ),
        ),
      ),
    ),
  );
}
