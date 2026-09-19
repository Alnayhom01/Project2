import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:project_v1/Model/report_model.dart';
import 'package:project_v1/Widgets/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportController extends GetxController {
  final allReports = <ReportModel>[].obs;
  final isLoading = false.obs;
  final searchText = ''.obs;
  final selectedType = 'الكل'.obs;
  final employeeRole = 'simpleEmployee'.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  Timer? _loadingTimer;

  final reportTypes = const [
    'الكل',
    'مشاكل متعلقة بالطرق',
    'مشاكل متعلقة بالإنارة',
    'مشاكل متعلقة بالمياه',
    'مشاكل متعلقة بالكهرباء',
    'مشاكل متعلقة بالنظافة',
    'غيرها من المشاكل',
  ];

  @override
  void onInit() {
    super.onInit();
    resetFilters();
    _loadEmployeeRole();
    loadReports();
  }

  Future<void> _loadEmployeeRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      employeeRole.value =
          prefs.getString('employeeRole') ?? 'simpleEmployee';
    } catch (_) {
      employeeRole.value = 'simpleEmployee';
    }
  }

  bool get canChangeStatus =>
      employeeRole.value == 'admin' || employeeRole.value == 'employee';

  void resetFilters() {
    selectedType.value = 'الكل';
    searchText.value = '';
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    await _subscription?.cancel();
    _subscription = null;
    _loadingTimer?.cancel();

    // حماية من بقاء دائرة التحميل إلى ما لا نهاية في حال تعذر وصول
    // أول Snapshot من Firestore.
    _loadingTimer = Timer(const Duration(seconds: 8), () {
      if (isLoading.value) {
        isLoading.value = false;
        if (allReports.isEmpty) {
          AppSnackbar.show(
            'تنبيه',
            'تعذر تحميل البلاغات حاليًا، حاول مرة أخرى',
          );
        }
      }
    });

    final ref = FirebaseFirestore.instance.collection('reports');

    try {
      _subscription = ref.snapshots().listen(
        (snapshot) {
          _applySnapshot(snapshot);
          isLoading.value = false;
          _loadingTimer?.cancel();
        },
        onError: (_) {
          isLoading.value = false;
          _loadingTimer?.cancel();
          AppSnackbar.show('خطأ', 'تعذر تحميل البلاغات');
        },
        cancelOnError: false,
      );
    } catch (_) {
      isLoading.value = false;
      _loadingTimer?.cancel();
      AppSnackbar.show('خطأ', 'تعذر تحميل البلاغات');
    }
  }

  void _applySnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = <ReportModel>[];

    for (final doc in snapshot.docs) {
      try {
        items.add(ReportModel.fromDoc(doc));
      } catch (_) {
        // تجاهل أي سجل غير صالح بدل إيقاف عرض بقية البلاغات.
      }
    }

    items.sort((a, b) {
      final at = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bt = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bt.compareTo(at);
    });

    allReports.assignAll(items);
  }

  List<ReportModel> byStatus(String status) {
    return filteredReports.where((r) => r.status == status).toList();
  }

  List<ReportModel> get archiveReports {
    return filteredReports
        .where(
          (r) => r.status == 'تم الحل' || r.status == 'تم الرفض',
        )
        .toList();
  }

  String categoryForReportType(String type) {
    final value = type.trim();

    if (reportTypes.contains(value) && value != 'الكل') {
      return value;
    }

    final normalized = value
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه');

    if (normalized.contains('طريق') ||
        normalized.contains('شارع') ||
        normalized.contains('حفر') ||
        normalized.contains('رصيف') ||
        normalized.contains('اسفلت')) {
      return 'مشاكل متعلقة بالطرق';
    }

    if (normalized.contains('اناره') ||
        normalized.contains('اضاءه') ||
        normalized.contains('مصباح') ||
        normalized.contains('عمود اناره')) {
      return 'مشاكل متعلقة بالإنارة';
    }

    if (normalized.contains('مياه') ||
        normalized.contains('ماء') ||
        normalized.contains('تسرب') ||
        normalized.contains('صرف صحي') ||
        normalized.contains('ماسوره')) {
      return 'مشاكل متعلقة بالمياه';
    }

    if (normalized.contains('كهرباء') ||
        normalized.contains('كهربائي') ||
        normalized.contains('اسلاك')) {
      return 'مشاكل متعلقة بالكهرباء';
    }

    if (normalized.contains('نظافه') ||
        normalized.contains('قمامه') ||
        normalized.contains('نفايات') ||
        normalized.contains('اوساخ') ||
        normalized.contains('مخلفات')) {
      return 'مشاكل متعلقة بالنظافة';
    }

    return 'غيرها من المشاكل';
  }

  List<ReportModel> get filteredReports {
    final query = searchText.value.trim().toLowerCase();

    return allReports.where((report) {
      final typeMatches =
          selectedType.value == 'الكل' ||
          categoryForReportType(report.type) == selectedType.value;

      if (!typeMatches) return false;
      if (query.isEmpty) return true;

      return report.id.toLowerCase().contains(query) ||
          report.userPhone.toLowerCase().contains(query) ||
          report.description.toLowerCase().contains(query) ||
          report.type.toLowerCase().contains(query);
    }).toList();
  }

  void setSearch(String value) => searchText.value = value;

  void setType(String? value) {
    selectedType.value = value == null || value.isEmpty ? 'الكل' : value;
  }

  Future<bool> changeStatus(
    ReportModel report,
    String newStatus,
  ) async {
    if (!canChangeStatus) {
      AppSnackbar.show(
        'غير مسموح',
        'لا تملك صلاحية تغيير حالة البلاغ',
      );
      return false;
    }

    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(report.id)
          .update({
        'status': newStatus,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });

      AppSnackbar.show(
        'تم التحديث',
        'تم تغيير حالة البلاغ إلى $newStatus',
      );
      return true;
    } catch (_) {
      AppSnackbar.show('خطأ', 'تعذر تغيير حالة البلاغ');
      return false;
    }
  }

  Future<void> openLocation(ReportModel report) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${report.latitude},${report.longitude}',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void onClose() {
    _loadingTimer?.cancel();
    _subscription?.cancel();
    super.onClose();
  }
}
