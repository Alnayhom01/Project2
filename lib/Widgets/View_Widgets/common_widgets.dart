import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_v1/Controller/report_controller.dart';
import 'package:project_v1/Model/report_model.dart';

const green = Color(0xff32B94B);
const lightBlue = Color(0xFFDDF4FC);
const darkGrey = Color(0xff4A5052);
const desktopBackground = Color(0xffF4F7F8);
const borderColor = Color(0xffDCE4E7);
const textDark = Color(0xff243033);
const mutedText = Color(0xff667378);

String formatDate(DateTime? date) {
  if (date == null) return 'غير محدد';
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

Color statusBackground(String status) {
  switch (status) {
    case 'جديد':
      return const Color(0xffe7f7eb);
    case 'قيد المعالجة':
      return const Color(0xfffff4df);
    case 'تم الحل':
      return const Color(0xffe7f7eb);
    case 'تم الرفض':
      return const Color(0xffffe9e9);
    default:
      return const Color(0xffeeeeee);
  }
}

Color statusForeground(String status) {
  switch (status) {
    case 'جديد':
      return const Color(0xff20883a);
    case 'قيد المعالجة':
      return const Color(0xffa56a00);
    case 'تم الحل':
      return const Color(0xff20883a);
    case 'تم الرفض':
      return const Color(0xffb63131);
    default:
      return const Color(0xff555555);
  }
}

Widget statusBadge(String status) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: statusBackground(status),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: statusForeground(status),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
  );
}

Widget desktopPageHeader({
  required BuildContext context,
  required String title,
  String? subtitle,
}) {
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    ),
  );
}

Widget desktopContent({
  required Widget child,
  EdgeInsets padding = const EdgeInsets.fromLTRB(30, 24, 30, 30),
}) {
  return Padding(
    padding: padding,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: SizedBox(width: double.infinity, child: child),
      ),
    ),
  );
}

Widget filterBar({
  required String selectedType,
  required List<String> types,
  required ValueChanged<String> onSearch,
  required ValueChanged<String?> onTypeChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      textDirection: TextDirection.rtl,
      children: [
        SizedBox(
          width: 360,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: DropdownButtonFormField<String>(
              value: selectedType,
              isExpanded: true,
              menuMaxHeight: 360,
              alignment: Alignment.centerRight,
              icon: const SizedBox.shrink(),
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                labelText: 'نوع البلاغ',
                prefixIcon: Icon(Icons.filter_alt_outlined),
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: mutedText,
                ),
              ),
              items: types
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
              onChanged: onTypeChanged,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextField(
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            onChanged: onSearch,
            decoration: const InputDecoration(
              hintText: 'بحث برقم البلاغ أو رقم الهاتف أو الوصف',
              suffixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget reportCard({
  required BuildContext context,
  required ReportModel report,
  required VoidCallback onOpen,
  bool showStatus = false,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      hoverColor: const Color(0xffF8FBFC),
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 5,
              height: 46,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Text(
                report.type,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _cardMeta(
                icon: Icons.confirmation_number_outlined,
                value: report.id,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _cardMeta(
                icon: Icons.calendar_today_outlined,
                value: formatDate(report.createdAt),
              ),
            ),
            if (showStatus) ...[
              const SizedBox(width: 24),
              statusBadge(report.status),
            ],
            const SizedBox(width: 14),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: mutedText,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _cardMeta({required IconData icon, required String value}) {
  return Row(
    textDirection: TextDirection.rtl,
    children: [
      Icon(icon, size: 18, color: mutedText),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: mutedText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

Future<void> showReportDetailsDialog({
  required BuildContext context,
  required ReportModel report,
  required ReportController controller,
  bool canChangeStatus = false,
}) async {
  final isNew = report.status == 'جديد';
  final isInProgress = report.status == 'قيد المعالجة';

  Future<void> requestStatusChange(String newStatus) async {
    final confirmed = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تأكيد تغيير الحالة',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'هل أنت متأكد من تغيير حالة البلاغ رقم ${report.id} إلى "$newStatus"؟',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('نعم، متأكد'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    final success = await controller.changeStatus(report, newStatus);
    if (success && (Get.isDialogOpen ?? false)) {
      Get.back();
    }
  }

  await Get.dialog(
    Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 34),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050, maxHeight: 760),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(34, 28, 34, 22),
            child: Column(
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تفاصيل البلاغ',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'معلومات البلاغ الكاملة',
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xffB63131),
                          width: 1.6,
                        ),
                      ),
                      child: IconButton(
                        tooltip: 'إغلاق',
                        padding: EdgeInsets.zero,
                        onPressed: Get.back,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: Color(0xffB63131),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.end,
                          textDirection: TextDirection.rtl,
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            _dialogInfo(
                              'نوع البلاغ',
                              report.type,
                              Icons.category_outlined,
                            ),
                            _dialogInfo(
                              'رقم البلاغ',
                              report.id,
                              Icons.confirmation_number_outlined,
                            ),
                            _dialogInfo(
                              'رقم المواطن',
                              "0${report.userPhone}",
                              Icons.phone_outlined,
                            ),
                            _dialogInfo(
                              'تاريخ الإنشاء',
                              formatDate(report.createdAt),
                              Icons.calendar_today_outlined,
                            ),
                            _dialogInfo(
                              'الحالة',
                              report.status,
                              Icons.flag_outlined,
                            ),
                            _dialogInfo(
                              'الإحداثيات',
                              '${report.latitude}, ${report.longitude}',
                              Icons.location_on_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _dialogSection(
                          title: 'الوصف',
                          icon: Icons.description_outlined,
                          child: Text(
                            report.description.isEmpty
                                ? 'لا يوجد وصف'
                                : report.description,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 15,
                              height: 1.7,
                            ),
                          ),
                        ),
                        if (report.imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _dialogSection(
                            title: 'الصور',
                            icon: Icons.photo_library_outlined,
                            child: SizedBox(
                              height: 190,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: report.imageUrls.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (_, i) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      report.imageUrls[i],
                                      width: 250,
                                      height: 185,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 250,
                                        height: 185,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF3F5F6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                          size: 42,
                                          color: mutedText,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => controller.openLocation(report),
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text('فتح الموقع'),
                    ),
                    const Spacer(),
                    if (canChangeStatus && isNew)
                      ElevatedButton.icon(
                        onPressed: () => requestStatusChange('قيد المعالجة'),
                        icon: const Icon(Icons.engineering_outlined),
                        label: const Text('معالجة'),
                      ),
                    if (canChangeStatus && isInProgress) ...[
                      ElevatedButton.icon(
                        onPressed: () => requestStatusChange('تم الحل'),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('تم الحل'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => requestStatusChange('تم الرفض'),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'تم الرفض',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffB63131),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

Widget _dialogInfo(String title, String value, IconData icon) {
  return Container(
    width: 315,
    constraints: const BoxConstraints(minHeight: 76),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xffF8FAFB),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      children: [
        // الأيقونة في أقصى اليمين
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: green, size: 19),
        ),

        const SizedBox(width: 10),

        // النص مباشرة بعد الأيقونة
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _dialogSection({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: green, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: textDark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

Widget field({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, size: 18, color: mutedText),
            const SizedBox(width: 7),
            Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: textDark,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
