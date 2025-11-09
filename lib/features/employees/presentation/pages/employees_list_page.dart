import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/shared/widgets/custom_app_bar.dart';
import 'package:tamgaci/shared/widgets/responsive_scaffold.dart';
import 'package:tamgaci/shared/widgets/drawer_menu.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:tamgaci/core/services/utils/exchange_rate_service.dart';
import 'package:tamgaci/core/services/utils/export_service.dart';
import 'package:intl/intl.dart';

class EmployeesListPage extends StatefulWidget {
  const EmployeesListPage({super.key});

  @override
  State<EmployeesListPage> createState() => _EmployeesListPageState();
}

class _EmployeesListPageState extends State<EmployeesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filters (dinamik)
  List<String> _departments = const [];
  List<String> _categories = const [];
  List<String> _positions = const [];
  String _selectedDepartment = 'Tümü';
  String _selectedCategory = 'Tümü';

  // Sorting
  final List<String> _sortOptions = const [
    'Ad Soyad',
    'Departman',
    'Kategori',
    'Bakiye'
  ];
  String _sortBy = 'Ad Soyad';
  bool _sortAscending = true;

  // Multitenant
  String? _tenantId;
  StreamSubscription? _deptMetaSub;
  StreamSubscription? _catMetaSub;
  StreamSubscription? _posMetaSub;
  Timer? _transactionCheckTimer;

  CollectionReference<Map<String, dynamic>> _tenantCol(String name) {
    if (_tenantId != null && _tenantId!.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('tenants')
          .doc(_tenantId)
          .collection(name);
    }
    return FirebaseFirestore.instance.collection(name);
  }

  Future<void> _loadTenantId() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final tid = userDoc.data()?['tenantId'] as String?;
      if (tid != null && tid.isNotEmpty && tid != _tenantId) {
        setState(() {
          _tenantId = tid;
        });
        // Yeniden meta koleksiyonları dinle (tenant değiştiyse)
        _listenToMetaCollections(restart: true);
      }
    } catch (_) {
      // Sessiz geç: tenantId yoksa üst seviye koleksiyonlara düşer
    }
  }

  Future<bool> _ensureTenant() async {
    if (_tenantId == null || _tenantId!.isEmpty) {
      await _loadTenantId();
    }
    return _tenantId != null && _tenantId!.isNotEmpty;
  }

  // Date range kaldırıldı (bu modülde kullanılmıyor)

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // TenantId yükle ve meta koleksiyonları dinle
    _loadTenantId().then((_) {
      _listenToMetaCollections();
      // Gerçek zamanlı otomatik alacaklandırma kontrolü
      _checkAndCreatePendingTransactions();
      // Her 6 saatte bir kontrol et (uygulama açıkken)
      _transactionCheckTimer =
          Timer.periodic(const Duration(hours: 6), (timer) {
        _checkAndCreatePendingTransactions();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _deptMetaSub?.cancel();
    _catMetaSub?.cancel();
    _posMetaSub?.cancel();
    _transactionCheckTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Gerçek zamanlı otomatik alacaklandırma - eksik transaction'ları kontrol et ve oluştur
  Future<void> _checkAndCreatePendingTransactions() async {
    try {
      if (_tenantId == null || _tenantId!.isEmpty) {
        await _loadTenantId();
      }
      if (_tenantId == null || _tenantId!.isEmpty) return;

      final employeesCol = _tenantCol('employees');
      final employeesSnapshot = await employeesCol.get();

      if (employeesSnapshot.docs.isEmpty) return;

      final transactionsCol = _tenantCol('employee_transactions');
      final now = DateTime.now();

      for (final empDoc in employeesSnapshot.docs) {
        final empData = empDoc.data();
        final employeeId = empDoc.id;
        final salary = empData['salary'] as Map<String, dynamic>?;
        final entitlement = empData['entitlement'] as Map<String, dynamic>?;
        final startDate = empData['startDate'];
        final autoEntitlementEnabled =
            empData['autoEntitlementEnabled'] as bool? ?? true;

        if (salary == null || entitlement == null || startDate == null) {
          continue;
        }

        // Otomatik hak ediş kapalıysa atla
        if (!autoEntitlementEnabled) continue;

        final salaryAmount = (salary['amount'] as num?)?.toDouble() ?? 0;
        if (salaryAmount <= 0) continue;

        final entitlementType = entitlement['type'] as String?;
        if (entitlementType == null) continue;

        // Saatlik maaş için otomatik hak ediş oluşturma (çalışılan saat bilinmediği için)
        if (entitlementType == 'Saatlik') continue;

        // Start date'i DateTime'a çevir
        DateTime? startDateTime;
        if (startDate is Timestamp) {
          startDateTime = startDate.toDate();
        } else if (startDate is DateTime) {
          startDateTime = startDate;
        }
        if (startDateTime == null) continue;

        // Personelin kaydedildiği tarihi al (createdAt)
        DateTime? createdAt;
        final createdAtField = empData['createdAt'];
        if (createdAtField is Timestamp) {
          createdAt = createdAtField.toDate();
        } else if (createdAtField is DateTime) {
          createdAt = createdAtField;
        }

        // Eğer createdAt yoksa, doc'un oluşturulma zamanını kullan (Firestore metadata)
        createdAt ??= DateTime.now();

        // Otomatik hak ediş başlangıç tarihi: personelin kaydedildiği tarih ile işe başlama tarihinden daha geç olan
        // Eğer personel gelecekte başlayacaksa (startDate > createdAt), startDate kullan
        // Eğer geriye dönük kayıt yapılıyorsa (startDate < createdAt), createdAt kullan
        final effectiveStartDate =
            startDateTime.isAfter(createdAt) ? startDateTime : createdAt;

        // Son transaction tarihini bul - Index gerektirmeyen sorgu
        final lastTransactionQuery = await transactionsCol
            .where('employeeId', isEqualTo: employeeId)
            .where('direction', isEqualTo: 'in')
            .get();

        // Client-side sıralama
        DateTime? lastTransDate;
        for (final doc in lastTransactionQuery.docs) {
          final data = doc.data();
          final date = data['date'];
          DateTime? docDate;

          if (date is Timestamp) {
            docDate = date.toDate();
          } else if (date is DateTime) {
            docDate = date;
          }

          if (docDate != null) {
            if (lastTransDate == null || docDate.isAfter(lastTransDate)) {
              lastTransDate = docDate;
            }
          }
        }

        // Son ödeme tarihini belirle: effectiveStartDate'den önceki tarihleri dikkate alma
        DateTime lastPaymentDate = effectiveStartDate;
        if (lastTransDate != null &&
            lastTransDate.isAfter(effectiveStartDate)) {
          lastPaymentDate = lastTransDate;
        }

        // Eksik transaction'ları hesapla ve oluştur (sadece kayıt tarihinden itibaren)
        await _createMissingTransactions(
          employeeId: employeeId,
          entitlementType: entitlementType,
          entitlement: entitlement,
          salaryAmount: salaryAmount,
          lastPaymentDate: lastPaymentDate,
          startDateTime: effectiveStartDate,
          now: now,
          transactionsCol: transactionsCol,
        );
      }
    } catch (e) {
      debugPrint('Otomatik alacaklandırma kontrolü hatası: $e');
      // Hata olursa sessizce geç, kullanıcıyı rahatsız etme
    }
  }

  // Eksik transaction'ları oluştur
  Future<void> _createMissingTransactions({
    required String employeeId,
    required String entitlementType,
    required Map<String, dynamic> entitlement,
    required double salaryAmount,
    required DateTime lastPaymentDate,
    required DateTime startDateTime,
    required DateTime now,
    required CollectionReference<Map<String, dynamic>> transactionsCol,
  }) async {
    final List<DateTime> missingDates = [];

    // Son ödeme tarihinden itibaren bugüne kadar eksik tüm ödeme tarihlerini bul
    // Ancak sadece kayıt tarihinden (startDateTime) itibaren olanları oluştur
    DateTime current = lastPaymentDate;
    const maxIterations = 100; // Sonsuz döngüyü önlemek için
    int iterations = 0;

    while (current.isBefore(now) && iterations < maxIterations) {
      final nextPayment = _getNextPaymentDate(
        fromDate: current,
        entitlementType: entitlementType,
        entitlement: entitlement,
      );

      if (nextPayment == null) break;

      // Sadece kayıt tarihinden sonraki ve bugüne kadar olan ödeme tarihlerini ekle
      // Ödeme tarihi bugünden önce veya bugün olmalı (gelecekteki tarihler eklenmemeli)
      if (nextPayment.isAfter(lastPaymentDate) &&
          nextPayment.isAfter(startDateTime) &&
          (nextPayment.isBefore(now) || nextPayment.isAtSameMomentAs(now))) {
        missingDates.add(nextPayment);
        current = nextPayment;
      } else if (nextPayment.isAfter(now)) {
        // Gelecekteki tarih bulundu, döngüden çık
        break;
      } else {
        break;
      }
      iterations++;
    }

    // Eksik transaction'ları oluştur
    for (int i = 0; i < missingDates.length; i++) {
      final paymentDate = missingDates[i];
      try {
        // Aynı tarihli transaction var mı kontrol et (duplicate önleme)
        final existing = await transactionsCol
            .where('employeeId', isEqualTo: employeeId)
            .where('date', isEqualTo: Timestamp.fromDate(paymentDate))
            .where('direction', isEqualTo: 'in')
            .limit(1)
            .get();

        if (existing.docs.isEmpty) {
          final transactionNote = _getTransactionNoteForEmployee(
            entitlementType: entitlementType,
            paymentDate: paymentDate,
          );

          // İlk ödeme kontrolü: lastPaymentDate startDateTime'dan önceyse veya eşitse, bu ilk ödemedir
          final isFirstPayment = lastPaymentDate.isBefore(startDateTime) ||
              lastPaymentDate.isAtSameMomentAs(startDateTime) ||
              (i == 0 && paymentDate.isAfter(startDateTime));

          // İlk ödeme için orantılı maaş hesapla
          double transactionAmount = _calculateProRataAmount(
            entitlementType: entitlementType,
            entitlement: entitlement,
            salaryAmount: salaryAmount,
            startDate: startDateTime,
            paymentDate: paymentDate,
            isFirstPayment: isFirstPayment,
          );

          await transactionsCol.add({
            'employeeId': employeeId,
            'amount': transactionAmount,
            'direction': 'in',
            'note': transactionNote,
            'date': Timestamp.fromDate(paymentDate),
            'tenantId': _tenantId,
            'createdBy': FirebaseAuth.instance.currentUser?.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('Transaction oluşturma hatası: $e');
        // Devam et, diğer transaction'ları oluşturmaya çalış
      }
    }
  }

  // Belirli bir tarihten sonraki bir sonraki ödeme tarihini hesapla
  DateTime? _getNextPaymentDate({
    required DateTime fromDate,
    required String entitlementType,
    required Map<String, dynamic> entitlement,
  }) {
    int getWeekdayNumber(String weekday) {
      const weekdays = {
        'Pazartesi': 1,
        'Salı': 2,
        'Çarşamba': 3,
        'Perşembe': 4,
        'Cuma': 5,
        'Cumartesi': 6,
        'Pazar': 7,
      };
      return weekdays[weekday] ?? 1;
    }

    DateTime findNextWeekday(DateTime from, int targetWeekday) {
      DateTime current = from;
      // Eğer bugün hedef günse, bir sonraki haftaya geç
      if (current.weekday == targetWeekday) {
        current = current.add(const Duration(days: 7));
      } else {
        // Bir sonraki hedef günü bul
        current = current.add(const Duration(days: 1));
        while (current.weekday != targetWeekday) {
          current = current.add(const Duration(days: 1));
        }
      }
      return current;
    }

    switch (entitlementType) {
      case 'Aylık':
        final monthlyDay = entitlement['monthlyDayOfMonth'] as int?;
        if (monthlyDay == null) return null;

        // Geçersiz değerleri düzelt (1-31 arasında olmalı)
        final validDay = monthlyDay >= 1 && monthlyDay <= 31 ? monthlyDay : 31;

        // Önce aynı ayın ödeme gününü kontrol et
        try {
          final sameMonthPayment =
              DateTime(fromDate.year, fromDate.month, validDay);
          if (sameMonthPayment.isAfter(fromDate)) {
            return sameMonthPayment;
          }
        } catch (_) {
          // Geçersiz tarih (örn: 31 Şubat), devam et
        }

        // Aynı ayın ödeme günü geçmişse, bir sonraki ayın ödeme gününe git
        DateTime next = DateTime(fromDate.year, fromDate.month + 1, validDay);
        // Eğer ayın günü ayın sonundan büyükse, ayın sonunu kullan
        try {
          return next;
        } catch (_) {
          // Geçersiz tarih (örn: 31 Şubat), ayın sonunu kullan
          next = DateTime(fromDate.year, fromDate.month + 2, 0);
          return next;
        }

      case 'Aylık (İki Kere)':
        final days = entitlement['semiMonthlyDays'] as List?;
        if (days == null || days.length < 2) return null;
        final day1 = (days[0] as num?)?.toInt();
        final day2 = (days[1] as num?)?.toInt();
        if (day1 == null || day2 == null) return null;

        DateTime next;

        // Önce aynı ayın ilk ödeme gününü kontrol et
        try {
          next = DateTime(fromDate.year, fromDate.month, day1);
          if (next.isAfter(fromDate)) {
            return next;
          }
        } catch (_) {
          // Geçersiz tarih, devam et
        }

        // Sonra aynı ayın ikinci ödeme gününü kontrol et
        try {
          next = DateTime(fromDate.year, fromDate.month, day2);
          if (next.isAfter(fromDate)) {
            return next;
          }
        } catch (_) {
          // Geçersiz tarih, devam et
        }

        // Eğer aynı ayın ödeme günleri geçmişse, bir sonraki ayın ilk ödeme gününe git
        try {
          next = DateTime(fromDate.year, fromDate.month + 1, day1);
          return next;
        } catch (_) {
          // Geçersiz tarih (örn: 31 Şubat), ayın sonunu kullan
          next = DateTime(fromDate.year, fromDate.month + 2, 0);
          return next;
        }

      case 'Haftalık':
        final weekday = entitlement['weeklyWeekday'] as String?;
        if (weekday == null) return null;
        final targetWeekday = getWeekdayNumber(weekday);
        return findNextWeekday(fromDate, targetWeekday);

      case 'Günlük':
        final weeklyDays = entitlement['weeklyDays'] as List?;
        if (weeklyDays == null || weeklyDays.isEmpty) return null;

        DateTime current = fromDate.add(const Duration(days: 1));
        int maxDays = 14; // 2 hafta içinde bul
        int checked = 0;
        while (checked < maxDays) {
          final weekdayName = [
            'Pazartesi',
            'Salı',
            'Çarşamba',
            'Perşembe',
            'Cuma',
            'Cumartesi',
            'Pazar'
          ][current.weekday - 1];
          if (weeklyDays.contains(weekdayName)) {
            return current;
          }
          current = current.add(const Duration(days: 1));
          checked++;
        }
        return null;

      case 'Saatlik':
        // Önce aynı ayın sonunu kontrol et
        final sameMonthEnd = DateTime(fromDate.year, fromDate.month + 1, 0);
        if (sameMonthEnd.isAfter(fromDate)) {
          return sameMonthEnd;
        }
        // Aynı ayın sonu geçmişse, bir sonraki ayın sonuna git
        return DateTime(fromDate.year, fromDate.month + 2, 0);

      default:
        return null;
    }
  }

  // Orantılı (pro-rata) maaş hesaplama fonksiyonu
  double _calculateProRataAmount({
    required String entitlementType,
    required Map<String, dynamic> entitlement,
    required double salaryAmount,
    required DateTime startDate,
    required DateTime paymentDate,
    required bool isFirstPayment,
  }) {
    // İlk ödeme değilse tam maaş
    if (!isFirstPayment) {
      if (entitlementType == 'Aylık (İki Kere)') {
        final amounts =
            entitlement['semiMonthlyAmounts'] as Map<String, dynamic>?;
        if (amounts != null) {
          final paymentDay = paymentDate.day.toString();
          final dayAmount = amounts[paymentDay];
          if (dayAmount != null) {
            return (dayAmount as num).toDouble();
          }
        }
        // Geriye dönük uyumluluk: yarıya böl
        return salaryAmount / 2;
      }
      return salaryAmount;
    }

    // İlk ödeme için orantılı hesaplama
    switch (entitlementType) {
      case 'Aylık':
        // Çalışılan gün sayısını hesapla
        final daysWorked = paymentDate.difference(startDate).inDays;
        if (daysWorked <= 0) return 0;

        // Eğer başlangıç ve ödeme aynı aydaysa, o ayın gün sayısını kullan
        // Eğer farklı aylardaysa, ödeme ayının gün sayısını kullan
        final daysInMonth = (startDate.year == paymentDate.year &&
                startDate.month == paymentDate.month)
            ? DateTime(startDate.year, startDate.month + 1, 0).day
            : DateTime(paymentDate.year, paymentDate.month + 1, 0).day;

        // Orantılı maaş: (Çalışılan gün / Ayın toplam günü) * Aylık Maaş
        return (daysWorked / daysInMonth) * salaryAmount;

      case 'Aylık (İki Kere)':
        // İlk ödeme gününe kadar çalışılan gün sayısı
        final daysWorked = paymentDate.difference(startDate).inDays;
        if (daysWorked <= 0) return 0;

        // Ödeme gününe kadar olan gün sayısı (ayın başından itibaren)
        final daysUntilPayment = paymentDate.day;

        // İlgili ödeme gününün tutarını al
        final amounts =
            entitlement['semiMonthlyAmounts'] as Map<String, dynamic>?;
        double baseAmount = salaryAmount / 2; // Varsayılan
        if (amounts != null) {
          final paymentDay = paymentDate.day.toString();
          final dayAmount = amounts[paymentDay];
          if (dayAmount != null) {
            baseAmount = (dayAmount as num).toDouble();
          }
        }

        // Orantılı maaş: (Çalışılan gün / Ödeme gününe kadar olan gün) * Ödeme günü tutarı
        return (daysWorked / daysUntilPayment) * baseAmount;

      case 'Haftalık':
        // Çalışılan gün sayısını hesapla
        final daysWorked = paymentDate.difference(startDate).inDays;
        if (daysWorked <= 0) return 0;

        // Haftada çalışılan gün sayısını al
        final daysPerWeek = entitlement['daysPerWeek'] as int? ?? 5;

        // Eğer çalışılan gün sayısı haftada çalışılan gün sayısına eşitse tam maaş
        if (daysWorked == daysPerWeek) {
          return salaryAmount;
        }

        // Değilse orantılı maaş: (Çalışılan gün / Haftada çalışılan gün) * Haftalık Maaş
        return (daysWorked / daysPerWeek) * salaryAmount;

      case 'Günlük':
        // Günlük maaş için çalışılan gün sayısı
        // paymentDate dahil değil, sadece startDate'den paymentDate'e kadar (paymentDate hariç)
        final daysWorked = paymentDate.difference(startDate).inDays;
        if (daysWorked <= 0) return 0;

        // Günlük maaş * çalışılan gün sayısı
        // Ancak sadece çalışma günlerini saymalıyız
        final weeklyDays = entitlement['weeklyDays'] as List?;
        if (weeklyDays != null && weeklyDays.isNotEmpty) {
          int workingDaysCount = 0;
          DateTime current = startDate;
          // paymentDate hariç, sadece startDate'den paymentDate'e kadar olan günleri say
          while (current.isBefore(paymentDate)) {
            final weekdayName = [
              'Pazartesi',
              'Salı',
              'Çarşamba',
              'Perşembe',
              'Cuma',
              'Cumartesi',
              'Pazar'
            ][current.weekday - 1];
            if (weeklyDays.contains(weekdayName)) {
              workingDaysCount++;
            }
            current = current.add(const Duration(days: 1));
          }
          return workingDaysCount * salaryAmount;
        }
        // Çalışma günleri bilgisi yoksa, tüm günleri say (paymentDate hariç)
        return daysWorked * salaryAmount;

      case 'Saatlik':
        // Saatlik maaş için orantılı hesaplama yapılmaz (çalışılan saat bilinmiyor)
        return salaryAmount;

      default:
        return salaryAmount;
    }
  }

  // Transaction note oluştur (employee context için)
  String _getTransactionNoteForEmployee({
    required String entitlementType,
    required DateTime paymentDate,
  }) {
    final dateStr =
        '${paymentDate.day.toString().padLeft(2, '0')}.${paymentDate.month.toString().padLeft(2, '0')}.${paymentDate.year}';

    switch (entitlementType) {
      case 'Aylık':
        return 'Aylık Maaş - $dateStr';
      case 'Aylık (İki Kere)':
        return 'Aylık Maaş (Yarı Dönem) - $dateStr';
      case 'Haftalık':
        return 'Haftalık Maaş - $dateStr';
      case 'Günlük':
        return 'Günlük Maaş - $dateStr';
      case 'Saatlik':
        return 'Saatlik Maaş - $dateStr';
      default:
        return 'Maaş Ödemesi - $dateStr';
    }
  }

  void _openManageCategoriesPage() {
    final TextEditingController catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kategoriler'),
          content: SizedBox(
            width: 480,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: catCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Yeni kategori adı',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final name = catCtrl.text.trim();
                          if (name.isEmpty) return;
                          final exists = await _tenantCol('employee_categories')
                              .where('name', isEqualTo: name)
                              .limit(1)
                              .get();
                          if (exists.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bu kategori zaten var')),
                            );
                            return;
                          }
                          await _tenantCol('employee_categories').add({
                            'name': name,
                            'createdAt': FieldValue.serverTimestamp()
                          });
                          catCtrl.clear();
                        },
                        child: const Text('Ekle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('employee_categories')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snap) {
                      if (!context.mounted) {
                        return const SizedBox.shrink();
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Kategori Düzenle'),
                                        content: TextField(
                                            controller: editCtrl,
                                            decoration: const InputDecoration(
                                                labelText: 'Ad')),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('İptal')),
                                          FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Kaydet')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Kategori Sil'),
                                        content: Text('"$name" silinsin mi?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('Vazgeç')),
                                          FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Sil')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) await d.reference.delete();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'))
          ],
        );
      },
    );
  }

  void _listenToMetaCollections({bool restart = false}) {
    if (restart) {
      _deptMetaSub?.cancel();
      _catMetaSub?.cancel();
      _posMetaSub?.cancel();
    }
    _deptMetaSub = _tenantCol('departments')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      final names = snapshot.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _departments = ['Tümü', ...names];
        if (!_departments.contains(_selectedDepartment)) {
          _selectedDepartment = 'Tümü';
        }
      });
    });

    _catMetaSub = _tenantCol('employee_categories')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      final names = snapshot.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _categories = ['Tümü', ...names];
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'Tümü';
        }
      });
    });

    _posMetaSub =
        _tenantCol('positions').orderBy('name').snapshots().listen((snapshot) {
      final names = snapshot.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _positions = names;
      });
    });
  }

  void _openManagePositions() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pozisyonlar'),
          content: SizedBox(
            width: 520,
            height: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pozisyonlar',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Yeni pozisyon adı',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          if (!await _ensureTenant()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Tenant yüklenmedi. Lütfen tekrar deneyin.')),
                            );
                            return;
                          }
                          final exists = await _tenantCol('positions')
                              .where('name', isEqualTo: name)
                              .limit(1)
                              .get();
                          if (exists.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bu pozisyon zaten var')),
                            );
                            return;
                          }
                          await _tenantCol('positions').add({
                            'name': name,
                            'tenantId': _tenantId,
                            'createdBy': FirebaseAuth.instance.currentUser?.uid,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          controller.clear();
                        },
                        child: const Text('Ekle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _tenantCol('positions').orderBy('name').snapshots(),
                    builder: (context, snap) {
                      if (!context.mounted) {
                        return const SizedBox.shrink();
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Pozisyon Düzenle'),
                                        content: TextField(
                                          controller: editCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Ad'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('İptal'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Kaydet'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    // Bu pozisyona ait personel var mı kontrol et
                                    if (!await _ensureTenant()) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tenant yüklenmedi. Lütfen tekrar deneyin.',
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    final employeesWithPos =
                                        await _tenantCol('employees')
                                            .where('position', isEqualTo: name)
                                            .limit(1)
                                            .get();

                                    if (employeesWithPos.docs.isNotEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '"$name" pozisyonuna ait personel bulunduğu için silinemez. Önce personelleri başka bir pozisyona aktarın.',
                                            ),
                                            backgroundColor: Colors.orange,
                                            duration:
                                                const Duration(seconds: 4),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Pozisyon Sil'),
                                        content: Text('"$name" silinsin mi?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Vazgeç'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Sil'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      // Tekrar kontrol et (güvenlik için)
                                      final recheck =
                                          await _tenantCol('employees')
                                              .where('position',
                                                  isEqualTo: name)
                                              .limit(1)
                                              .get();

                                      if (recheck.docs.isNotEmpty) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '"$name" pozisyonuna ait personel bulunduğu için silinemez.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      await d.reference.delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _openManageDepartments() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Departmanlar'),
          content: SizedBox(
            width: 420,
            height: 420,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Yeni departman adı',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        try {
                          if (!await _ensureTenant()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Tenant yüklenmedi. Lütfen tekrar deneyin.')),
                            );
                            return;
                          }
                          await _tenantCol('departments').add({
                            'name': name,
                            'tenantId': _tenantId,
                            'createdBy': FirebaseAuth.instance.currentUser?.uid,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          controller.clear();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ekleme hatası: $e')),
                          );
                        }
                      },
                      child: const Text('Ekle'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream:
                        _tenantCol('departments').orderBy('name').snapshots(),
                    builder: (context, snap) {
                      if (!context.mounted) {
                        return const SizedBox.shrink();
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title:
                                              const Text('Departman Düzenle'),
                                          content: TextField(
                                            controller: editCtrl,
                                            decoration: const InputDecoration(
                                                labelText: 'Ad'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('İptal'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Kaydet'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Departman Sil'),
                                        content: Text('"$name" silinsin mi?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Vazgeç'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Sil'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      await d.reference.delete();
                                      if (_selectedDepartment == name) {
                                        setState(
                                            () => _selectedDepartment = 'Tümü');
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _showExportOptions() {
    final parentContext = context;
    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel Olarak İndir'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportEmployeesToExcel(parentContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Olarak İndir'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportEmployeesToPDF(parentContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Tarih aralığı kaldırıldı

  Future<void> _exportEmployeesToExcel(BuildContext context) async {
    bool dialogShown = false;
    Object? error;
    String? fileName;
    try {
      // Loading göster
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      dialogShown = true;

      // Personel listesini çek
      Query<Map<String, dynamic>> query = _tenantCol('employees');

      if (_selectedDepartment != 'Tümü' && _selectedDepartment.isNotEmpty) {
        query = query.where('department', isEqualTo: _selectedDepartment);
      }
      if (_selectedCategory != 'Tümü' && _selectedCategory.isNotEmpty) {
        query = query.where('category', isEqualTo: _selectedCategory);
      }

      String orderField;
      switch (_sortBy) {
        case 'Ad Soyad':
          orderField = 'name';
          break;
        case 'Departman':
          orderField = 'department';
          break;
        case 'Kategori':
          orderField = 'category';
          break;
        case 'Bakiye':
          orderField = 'name';
          break;
        default:
          orderField = 'createdAt';
      }
      query = query.orderBy(orderField, descending: !_sortAscending);

      final snapshot = await query.get();
      var docs = snapshot.docs;

      // Arama sorgusu varsa filtrele
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        docs = docs.where((d) {
          final data = d.data();
          final name = (data['name'] as String?)?.toLowerCase() ?? '';
          final department =
              (data['department'] as String?)?.toLowerCase() ?? '';
          final category = (data['category'] as String?)?.toLowerCase() ?? '';
          return name.contains(q) ||
              department.contains(q) ||
              category.contains(q);
        }).toList();
      }

      if (docs.isEmpty) {
        if (dialogShown && context.mounted) {
          try {
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            dialogShown = false;
          } catch (_) {}
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export edilecek personel bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Headers
      final headers = [
        'Ad Soyad',
        'Departman',
        'Kategori',
        'Pozisyon',
        'Maaş',
        'Para Birimi',
        'Durum',
      ];

      // Data
      final exportData = <List<dynamic>>[];

      for (final doc in docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '-';
        final department = data['department'] as String? ?? '-';
        final category = data['category'] as String? ?? '-';
        final position = data['position'] as String? ?? '-';
        final salary = (data['salary'] as Map?) ?? {};
        final salaryAmount = (salary['amount'] as num?)?.toDouble() ?? 0.0;
        final salaryCurrency = salary['currency']?.toString() ?? 'TRY';
        final isActive = data['isActive'] as bool? ?? true;
        final status = isActive ? 'Aktif' : 'Arşiv';

        // Format amount in Turkish format
        String formatAmount(double amount) {
          final parts = amount.abs().toStringAsFixed(2).split('.');
          final intPart = parts[0];
          final decPart = parts[1];
          final formattedInt = intPart.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
          return '$formattedInt,$decPart';
        }

        exportData.add([
          name,
          department,
          category,
          position,
          formatAmount(salaryAmount),
          salaryCurrency,
          status,
        ]);
      }

      // Export service kullan
      final exportService = ExportService();
      final fileBytes = await exportService.exportToExcel(
        title: 'Personel Listesi',
        headers: headers,
        data: exportData,
        sheetName: 'Personeller',
      );

      // Dosyayı kaydet
      fileName =
          'Personel_Listesi_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

      if (kIsWeb) {
        final blob = web.Blob([fileBytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.HTMLAnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';
        web.document.body?.appendChild(anchor);
        anchor.click();
        anchor.remove();
        web.URL.revokeObjectURL(url);
      } else {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final filePath = path.join(directory.path, fileName);
          final file = File(filePath);
          await file.writeAsBytes(fileBytes);
        }
      }
    } catch (e) {
      error = e;
    } finally {
      // Dialog'u mutlaka kapat ve SnackBar göster
      if (dialogShown) {
        final finalError = error;
        final finalFileName = fileName;

        // Dialog'u kapat
        Future.microtask(() {
          try {
            if (context.mounted) {
              final navigator = Navigator.of(context, rootNavigator: true);
              if (navigator.canPop()) {
                navigator.pop();
              }
            }
          } catch (_) {
            // Context dispose edilmiş olabilir
          }
        });

        // SnackBar'ı göster (dialog kapandıktan sonra)
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            if (context.mounted) {
              if (finalError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Export hatası: $finalError'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (finalFileName != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Excel dosyası indirildi: $finalFileName'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (_) {
            // Context dispose edilmiş olabilir
          }
        });
      }
    }
  }

  Future<void> _exportEmployeesToPDF(BuildContext context) async {
    bool dialogShown = false;
    Object? error;
    String? fileName;
    try {
      // Loading göster
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      dialogShown = true;

      // Personel listesini çek
      Query<Map<String, dynamic>> query = _tenantCol('employees');

      if (_selectedDepartment != 'Tümü' && _selectedDepartment.isNotEmpty) {
        query = query.where('department', isEqualTo: _selectedDepartment);
      }
      if (_selectedCategory != 'Tümü' && _selectedCategory.isNotEmpty) {
        query = query.where('category', isEqualTo: _selectedCategory);
      }

      String orderField;
      switch (_sortBy) {
        case 'Ad Soyad':
          orderField = 'name';
          break;
        case 'Departman':
          orderField = 'department';
          break;
        case 'Kategori':
          orderField = 'category';
          break;
        case 'Bakiye':
          orderField = 'name';
          break;
        default:
          orderField = 'createdAt';
      }
      query = query.orderBy(orderField, descending: !_sortAscending);

      final snapshot = await query.get();
      var docs = snapshot.docs;

      // Arama sorgusu varsa filtrele
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        docs = docs.where((d) {
          final data = d.data();
          final name = (data['name'] as String?)?.toLowerCase() ?? '';
          final department =
              (data['department'] as String?)?.toLowerCase() ?? '';
          final category = (data['category'] as String?)?.toLowerCase() ?? '';
          return name.contains(q) ||
              department.contains(q) ||
              category.contains(q);
        }).toList();
      }

      if (docs.isEmpty) {
        if (dialogShown && context.mounted) {
          try {
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            dialogShown = false;
          } catch (_) {}
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export edilecek personel bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Headers
      final headers = [
        'Ad Soyad',
        'Departman',
        'Kategori',
        'Pozisyon',
        'Maaş',
        'Para Birimi',
        'Durum',
      ];

      // Data
      final exportData = <List<dynamic>>[];
      int activeCount = 0;
      int archivedCount = 0;

      for (final doc in docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '-';
        final department = data['department'] as String? ?? '-';
        final category = data['category'] as String? ?? '-';
        final position = data['position'] as String? ?? '-';
        final salary = (data['salary'] as Map?) ?? {};
        final salaryAmount = (salary['amount'] as num?)?.toDouble() ?? 0.0;
        final salaryCurrency = salary['currency']?.toString() ?? 'TRY';
        final isActive = data['isActive'] as bool? ?? true;
        final status = isActive ? 'Aktif' : 'Arşiv';

        if (isActive) {
          activeCount++;
        } else {
          archivedCount++;
        }

        // Format amount in Turkish format
        String formatAmount(double amount) {
          final parts = amount.abs().toStringAsFixed(2).split('.');
          final intPart = parts[0];
          final decPart = parts[1];
          final formattedInt = intPart.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
          return '$formattedInt,$decPart';
        }

        exportData.add([
          name,
          department,
          category,
          position,
          formatAmount(salaryAmount),
          salaryCurrency,
          status,
        ]);
      }

      // Özet bilgileri
      final summary = <String, dynamic>{
        'Toplam Personel': docs.length,
        'Aktif Personel': activeCount,
        'Arşiv Personel': archivedCount,
      };

      // Export service kullan
      final exportService = ExportService();
      final fileBytes = await exportService.exportToPDF(
        title: 'Personel Listesi',
        subtitle: 'Personel raporu',
        headers: headers,
        data: exportData,
        summary: summary,
        tenantId: _tenantId,
      );

      // Dosyayı kaydet
      fileName =
          'Personel_Listesi_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = web.Blob([fileBytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.HTMLAnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';
        web.document.body?.appendChild(anchor);
        anchor.click();
        anchor.remove();
        web.URL.revokeObjectURL(url);
      } else {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final filePath = path.join(directory.path, fileName);
          final file = File(filePath);
          await file.writeAsBytes(fileBytes);
        }
      }
    } catch (e) {
      error = e;
    } finally {
      // Dialog'u mutlaka kapat ve SnackBar göster
      if (dialogShown) {
        final finalError = error;
        final finalFileName = fileName;

        // Dialog'u kapat
        Future.microtask(() {
          try {
            if (context.mounted) {
              final navigator = Navigator.of(context, rootNavigator: true);
              if (navigator.canPop()) {
                navigator.pop();
              }
            }
          } catch (_) {
            // Context dispose edilmiş olabilir
          }
        });

        // SnackBar'ı göster (dialog kapandıktan sonra)
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            if (context.mounted) {
              if (finalError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Export hatası: $finalError'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (finalFileName != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PDF dosyası indirildi: $finalFileName'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (_) {
            // Context dispose edilmiş olabilir
          }
        });
      }
    }
  }

  void _onAddEmployee() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.6,
          maxChildSize: 0.98,
          expand: false,
          builder: (context, scrollController) {
            return _AddEmployeeForm(
              departments: _departments,
              categories: _categories,
              positions: _positions,
              onManagePositions: _openManagePositions,
              scrollController: scrollController,
              tenantId: _tenantId,
            );
          },
        );
      },
    );
  }

  // _onAddDepartment kaldırıldı; departman yönetimi form içinden açılan diyalogda yapılır

  Widget _buildSearchAndFilters() {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isNarrow = width < 900;

    if (isNarrow) {
      return Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Personel ara...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: 'Departman',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  isExpanded: true,
                  items: _departments
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDepartment = v!),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Departman Ekle',
                onPressed: _openManageDepartments,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Kategori Ekle',
                onPressed: _openManageCategoriesPage,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'Sırala',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: _sortOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sortBy = v!),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    setState(() => _sortAscending = !_sortAscending),
                icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                tooltip: _sortAscending ? 'Artan' : 'Azalan',
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _showExportOptions,
                icon: const Icon(Icons.file_download),
                tooltip: 'Dışa Aktar',
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Personel ara...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: 'Departman',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                isExpanded: true,
                items: _departments
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(
                            d,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDepartment = v!),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Departman Ekle',
              onPressed: _openManageDepartments,
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Kategori Ekle',
              onPressed: _openManageCategoriesPage,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _sortBy,
                decoration: InputDecoration(
                  labelText: 'Sırala',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _sortOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sortBy = v!),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => setState(() => _sortAscending = !_sortAscending),
              icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
              tooltip: _sortAscending ? 'Artan' : 'Azalan',
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _showExportOptions,
              icon: const Icon(Icons.file_download),
              tooltip: 'Dışa Aktar',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Personeller',
        showDrawer: true,
      ),
      drawerContent: const TamgaciDrawerMenu(),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _EmployeesHeader(tenantId: _tenantId),
                ),
                // FİLTRE/ARAMA/SIRALAMA/EXPORT BLOĞU
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSearchAndFilters(),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: _EmployeeList(
                    searchQuery: _searchQuery,
                    selectedDepartment: _selectedDepartment == 'Tümü'
                        ? null
                        : _selectedDepartment,
                    selectedCategory:
                        _selectedCategory == 'Tümü' ? null : _selectedCategory,
                    sortBy: _sortBy,
                    ascending: _sortAscending,
                    tenantId: _tenantId,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'fab_add_employee',
                  onPressed: _onAddEmployee,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Yeni Personel Ekle'),
                ),
              ],
            ),
          ),
        ],
      ),
      persistentOnLarge: false,
      sidePanelWidth: 280,
    );
  }
}

class _EmployeesHeader extends StatelessWidget {
  final String? tenantId;
  const _EmployeesHeader({required this.tenantId});

  // Personellerin bakiyelerini toplu olarak hesapla
  Future<Map<String, double>> _calculateTotalBalance(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> employees,
    String? tenantId,
  ) async {
    final Map<String, double> balances = {};

    final transactionsCol = (tenantId != null && tenantId.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('employee_transactions')
        : FirebaseFirestore.instance.collection('employee_transactions');

    // Tüm personel ID'lerini topla
    final employeeIds = employees.map((e) => e.id).toList();

    if (employeeIds.isEmpty) {
      return balances;
    }

    // Tüm transaction'ları tek seferde çek (whereIn kullanarak)
    // Not: Firestore whereIn limiti 10'dur, bu yüzden batch'ler halinde çekmeliyiz
    const batchSize = 10;
    for (int i = 0; i < employeeIds.length; i += batchSize) {
      final batch = employeeIds.skip(i).take(batchSize).toList();
      final snapshot =
          await transactionsCol.where('employeeId', whereIn: batch).get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final employeeId = data['employeeId'] as String?;
        if (employeeId == null) continue;

        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final dir = (data['direction'] as String?) ?? 'out';
        balances[employeeId] =
            (balances[employeeId] ?? 0.0) + (dir == 'in' ? amount : -amount);
      }
    }

    // Bakiyesi olmayan personeller için 0.0 ekle
    for (final emp in employees) {
      balances.putIfAbsent(emp.id, () => 0.0);
    }

    return balances;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final scaleFactor = constraints.maxWidth < 400 ? 0.85 : 1.0;

        final employeesQuery = (tenantId != null && tenantId!.isNotEmpty)
            ? FirebaseFirestore.instance
                .collection('tenants')
                .doc(tenantId)
                .collection('employees')
            : FirebaseFirestore.instance.collection('employees');

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: employeesQuery.snapshots(),
          builder: (context, employeesSnapshot) {
            // Aktif personel sayısını hesapla
            int activeCount = 0;
            if (employeesSnapshot.hasData) {
              activeCount = employeesSnapshot.data!.docs
                  .where((doc) => (doc.data()['isActive'] as bool? ?? true))
                  .length;
            }

            // Toplam bakiyeyi hesapla - Her personelin bakiyesini ayrı ayrı hesaplayıp topla
            final activeEmployees = employeesSnapshot.hasData
                ? employeesSnapshot.data!.docs
                    .where((doc) => (doc.data()['isActive'] as bool? ?? true))
                    .toList()
                : <QueryDocumentSnapshot<Map<String, dynamic>>>[];

            return FutureBuilder<Map<String, double>>(
              future: _calculateTotalBalance(activeEmployees, tenantId),
              builder: (context, balanceSnapshot) {
                double totalBalance = 0.0;
                String currency = 'TRY';

                if (balanceSnapshot.hasData) {
                  // Tüm aktif personellerin bakiyelerini topla
                  totalBalance = balanceSnapshot.data!.values
                      .fold(0.0, (sum, balance) => sum + balance);

                  // İlk aktif personelin para birimini al (varsayılan olarak)
                  if (activeEmployees.isNotEmpty) {
                    for (final empDoc in activeEmployees) {
                      final empData = empDoc.data();
                      final salary = (empData['salary'] as Map?) ?? {};
                      final empCurrency = salary['currency']?.toString();
                      if (empCurrency != null && empCurrency.isNotEmpty) {
                        currency = empCurrency;
                        break;
                      }
                    }
                  }
                }

                // Format balance in Turkish format
                String formatBalance(double amount) {
                  final parts = amount.abs().toStringAsFixed(2).split('.');
                  final intPart = parts[0];
                  final decPart = parts[1];
                  final formattedInt = intPart.replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.',
                  );
                  final formatted = '$formattedInt,$decPart';
                  return amount < 0 ? '-$formatted' : formatted;
                }

                final formattedBalance = formatBalance(totalBalance);

                return Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3897F0),
                        Color(0xFF4C6EF5),
                        Color(0xFF1A56D9)
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Personeller',
                              style: GoogleFonts.poppins(
                                fontSize: 24 * scaleFactor,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Şirket personellerinizi yönetin.',
                              style: GoogleFonts.poppins(
                                  fontSize: 14 * scaleFactor,
                                  color: Colors.white.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                      ),
                      if (!isSmallScreen)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: _HeaderStatCard(
                                activeCount.toString(),
                                'Aktif Personel',
                                centerText: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: _HeaderStatCard(
                                '$formattedBalance $currency',
                                'Toplam Bakiye',
                                centerText: false,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _HeaderStatCard extends StatelessWidget {
  final String value;
  final String title;
  final bool centerText;
  const _HeaderStatCard(this.value, this.title, {this.centerText = false});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleFactor = constraints.maxWidth < 400 ? 0.85 : 1.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scaleFactor,
            vertical: 8 * scaleFactor,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                centerText ? CrossAxisAlignment.center : CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 18 * scaleFactor,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: centerText ? TextAlign.center : TextAlign.right),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 10 * scaleFactor,
                      color: Colors.white.withValues(alpha: 0.8)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: centerText ? TextAlign.center : TextAlign.right),
            ],
          ),
        );
      },
    );
  }
}

// Eski basit filtre bileşeni kaldırıldı; Expenses modülüne uygun
// gelişmiş filtre yapısı _buildSearchAndFilters içerisinde uygulanıyor.

class _EmployeeList extends StatefulWidget {
  final String searchQuery;
  final String? selectedDepartment;
  final String? selectedCategory;
  final String sortBy;
  final bool ascending;
  final String? tenantId;
  const _EmployeeList({
    this.searchQuery = '',
    this.selectedDepartment,
    this.selectedCategory,
    this.sortBy = 'Ad Soyad',
    this.ascending = true,
    this.tenantId,
  });

  @override
  State<_EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<_EmployeeList> {
  bool _isArchiveExpanded = false;

  // Personellerin bakiyelerini toplu olarak hesapla
  Future<Map<String, double>> _calculateBalancesForEmployees(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> employees,
    String? tenantId,
  ) async {
    final Map<String, double> balances = {};

    final transactionsCol = (tenantId != null && tenantId.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('employee_transactions')
        : FirebaseFirestore.instance.collection('employee_transactions');

    // Tüm personel ID'lerini topla
    final employeeIds = employees.map((e) => e.id).toList();

    if (employeeIds.isEmpty) {
      return balances;
    }

    // Tüm transaction'ları tek seferde çek (whereIn kullanarak)
    // Not: Firestore whereIn limiti 10'dur, bu yüzden batch'ler halinde çekmeliyiz
    const batchSize = 10;
    for (int i = 0; i < employeeIds.length; i += batchSize) {
      final batch = employeeIds.skip(i).take(batchSize).toList();
      final snapshot =
          await transactionsCol.where('employeeId', whereIn: batch).get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final employeeId = data['employeeId'] as String?;
        if (employeeId == null) continue;

        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final dir = (data['direction'] as String?) ?? 'out';
        balances[employeeId] =
            (balances[employeeId] ?? 0.0) + (dir == 'in' ? amount : -amount);
      }
    }

    // Bakiyesi olmayan personeller için 0.0 ekle
    for (final emp in employees) {
      balances.putIfAbsent(emp.id, () => 0.0);
    }

    return balances;
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query =
        (widget.tenantId != null && widget.tenantId!.isNotEmpty)
            ? FirebaseFirestore.instance
                .collection('tenants')
                .doc(widget.tenantId)
                .collection('employees')
            : FirebaseFirestore.instance.collection('employees');

    if (widget.selectedDepartment != null &&
        widget.selectedDepartment!.isNotEmpty) {
      query = query.where('department', isEqualTo: widget.selectedDepartment);
    }
    if (widget.selectedCategory != null &&
        widget.selectedCategory!.isNotEmpty) {
      query = query.where('category', isEqualTo: widget.selectedCategory);
    }

    String orderField;
    switch (widget.sortBy) {
      case 'Ad Soyad':
        orderField = 'name';
        break;
      case 'Departman':
        orderField = 'department';
        break;
      case 'Kategori':
        orderField = 'category';
        break;
      case 'Bakiye':
        orderField = 'name'; // placeholder
        break;
      default:
        orderField = 'createdAt';
    }
    // Tek bir orderBy kullanarak kompozit index ihtiyacını azalt
    query = query.orderBy(orderField, descending: !widget.ascending);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (!context.mounted) {
          return const SizedBox.shrink();
        }
        if (snap.hasError) {
          return Center(child: Text('Hata: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snap.data!.docs;
        final q = widget.searchQuery.trim().toLowerCase();
        if (q.isNotEmpty) {
          docs = docs.where((d) {
            final data = d.data();
            final name = (data['name'] as String?)?.toLowerCase() ?? '';
            final department =
                (data['department'] as String?)?.toLowerCase() ?? '';
            final category = (data['category'] as String?)?.toLowerCase() ?? '';
            return name.contains(q) ||
                department.contains(q) ||
                category.contains(q);
          }).toList();
        }
        // Aktif ve arşiv personelleri ayır
        final List<QueryDocumentSnapshot<Map<String, dynamic>>>
            activeEmployees = [];
        final List<QueryDocumentSnapshot<Map<String, dynamic>>>
            archivedEmployees = [];

        for (final d in docs) {
          final data = d.data();
          final isActive = data['isActive'] as bool? ?? true;
          if (isActive) {
            activeEmployees.add(d);
          } else {
            archivedEmployees.add(d);
          }
        }

        if (activeEmployees.isEmpty && archivedEmployees.isEmpty) {
          return const Center(child: Text('Henüz personel bulunmuyor'));
        }

        final List<_SectionEntry> entries = [];

        // Arşiv bölümünü en üste ekle
        if (archivedEmployees.isNotEmpty) {
          archivedEmployees.sort((a, b) {
            final an = (a.data()['name'] as String? ?? '').toLowerCase();
            final bn = (b.data()['name'] as String? ?? '').toLowerCase();
            return an.compareTo(bn);
          });
          entries.add(_SectionEntry.archiveHeader());
          // Arşiv açıksa personelleri göster
          if (_isArchiveExpanded) {
            for (final doc in archivedEmployees) {
              entries.add(_SectionEntry.item(doc));
            }
          }
        }

        // Bakiye sıralaması için client-side sorting
        if (widget.sortBy == 'Bakiye') {
          // Tüm personelleri bakiye bilgisiyle birlikte sırala
          return FutureBuilder<Map<String, double>>(
            future: _calculateBalancesForEmployees(
              activeEmployees,
              widget.tenantId,
            ),
            builder: (context, balanceSnapshot) {
              if (!balanceSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final balances = balanceSnapshot.data!;

              // Personelleri bakiyelerine göre sırala
              final sortedEmployees =
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
                      activeEmployees);
              sortedEmployees.sort((a, b) {
                final balanceA = balances[a.id] ?? 0.0;
                final balanceB = balances[b.id] ?? 0.0;
                return widget.ascending
                    ? balanceA.compareTo(balanceB)
                    : balanceB.compareTo(balanceA);
              });

              // Departmanlara göre grupla
              final Map<String,
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>>
                  grouped = {};
              for (final d in sortedEmployees) {
                final dep = (d.data()['department'] as String?)?.trim();
                final key = (dep == null || dep.isEmpty) ? '-' : dep;
                (grouped[key] ??= []).add(d);
              }
              final departments = grouped.keys.toList()..sort();

              final List<_SectionEntry> balanceEntries = [];

              // Arşiv bölümünü en üste ekle
              if (archivedEmployees.isNotEmpty) {
                archivedEmployees.sort((a, b) {
                  final an = (a.data()['name'] as String? ?? '').toLowerCase();
                  final bn = (b.data()['name'] as String? ?? '').toLowerCase();
                  return an.compareTo(bn);
                });
                balanceEntries.add(_SectionEntry.archiveHeader());
                if (_isArchiveExpanded) {
                  for (final doc in archivedEmployees) {
                    balanceEntries.add(_SectionEntry.item(doc));
                  }
                }
              }

              for (final dep in departments) {
                final items = grouped[dep]!;
                balanceEntries.add(_SectionEntry.header(dep));
                for (final doc in items) {
                  balanceEntries.add(_SectionEntry.item(doc));
                }
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: balanceEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final e = balanceEntries[idx];
                  if (e.isHeader) {
                    if (e.isArchiveHeader) {
                      return _ArchiveHeader(
                        tenantId: widget.tenantId,
                        isExpanded: _isArchiveExpanded,
                        onToggle: () {
                          setState(() {
                            _isArchiveExpanded = !_isArchiveExpanded;
                          });
                        },
                      );
                    }
                    final departmentName = e.headerTitle ?? '-';
                    return _DepartmentHeader(
                      departmentName:
                          departmentName == '-' ? null : departmentName,
                      tenantId: widget.tenantId,
                      onDepartmentChanged: () {},
                    );
                  }
                  final snap = e.doc!;
                  final data = snap.data();
                  final name = data['name'] as String? ?? '-';
                  final department = data['department'] as String? ?? '-';
                  final category = data['category'] as String? ?? '-';
                  final photoUrl = data['photoUrl'] as String?;
                  final isActive = data['isActive'] as bool? ?? true;
                  final isArchived = !isActive;
                  final salary = (data['salary'] as Map?) ?? {};
                  final salaryCurrency =
                      salary['currency']?.toString() ?? 'TRY';
                  return Opacity(
                    opacity: isArchived ? 0.6 : 1.0,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            (photoUrl != null && photoUrl.isNotEmpty)
                                ? NetworkImage(photoUrl)
                                : null,
                        onBackgroundImageError:
                            (photoUrl != null && photoUrl.isNotEmpty)
                                ? (exception, stackTrace) {}
                                : null,
                        child: (photoUrl == null || photoUrl.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        name,
                        style: isArchived
                            ? TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$department • $category'),
                          const SizedBox(height: 4),
                          _EmployeeBalanceCompact(
                            tenantId: widget.tenantId,
                            docId: snap.id,
                            currency: salaryCurrency.isNotEmpty
                                ? salaryCurrency
                                : 'TRY',
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => _EmployeeDetailSheet(
                            tenantId: widget.tenantId,
                            docId: snap.id,
                            data: data),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        // Aktif personelleri departmanlara göre grupla
        final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
            grouped = {};
        for (final d in activeEmployees) {
          final dep = (d.data()['department'] as String?)?.trim();
          final key = (dep == null || dep.isEmpty) ? '-' : dep;
          (grouped[key] ??= []).add(d);
        }
        final departments = grouped.keys.toList()..sort();

        for (final dep in departments) {
          final items = grouped[dep]!;
          // İstikrarlı görünüm için departman içini ada göre sırala (yerel sıralama)
          items.sort((a, b) {
            final an = (a.data()['name'] as String? ?? '').toLowerCase();
            final bn = (b.data()['name'] as String? ?? '').toLowerCase();
            return an.compareTo(bn);
          });
          entries.add(_SectionEntry.header(dep));
          for (final doc in items) {
            entries.add(_SectionEntry.item(doc));
          }
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final e = entries[idx];
            if (e.isHeader) {
              if (e.isArchiveHeader) {
                return _ArchiveHeader(
                  tenantId: widget.tenantId,
                  isExpanded: _isArchiveExpanded,
                  onToggle: () {
                    setState(() {
                      _isArchiveExpanded = !_isArchiveExpanded;
                    });
                  },
                );
              }
              final departmentName = e.headerTitle ?? '-';
              return _DepartmentHeader(
                departmentName: departmentName == '-' ? null : departmentName,
                tenantId: widget.tenantId,
                onDepartmentChanged: () {
                  // Listeyi yenilemek için setState çağrılabilir
                },
              );
            }
            final snap = e.doc!;
            final data = snap.data();
            final name = data['name'] as String? ?? '-';
            final department = data['department'] as String? ?? '-';
            final category = data['category'] as String? ?? '-';
            final photoUrl = data['photoUrl'] as String?;
            final isActive = data['isActive'] as bool? ?? true;
            final isArchived = !isActive;
            final salary = (data['salary'] as Map?) ?? {};
            final salaryCurrency = salary['currency']?.toString() ?? 'TRY';
            return Opacity(
              opacity: isArchived ? 0.6 : 1.0,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  onBackgroundImageError:
                      (photoUrl != null && photoUrl.isNotEmpty)
                          ? (exception, stackTrace) {
                              // Hata durumunda icon gösterilecek
                            }
                          : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                  name,
                  style: isArchived
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        )
                      : null,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$department • $category'),
                    const SizedBox(height: 4),
                    _EmployeeBalanceCompact(
                      tenantId: widget.tenantId,
                      docId: snap.id,
                      currency:
                          salaryCurrency.isNotEmpty ? salaryCurrency : 'TRY',
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => _EmployeeDetailSheet(
                      tenantId: widget.tenantId, docId: snap.id, data: data),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionEntry {
  final bool isHeader;
  final bool isArchiveHeader;
  final String? headerTitle;
  final QueryDocumentSnapshot<Map<String, dynamic>>? doc;
  _SectionEntry.header(this.headerTitle)
      : isHeader = true,
        isArchiveHeader = false,
        doc = null;
  _SectionEntry.archiveHeader()
      : isHeader = true,
        isArchiveHeader = true,
        headerTitle = 'Arşiv',
        doc = null;
  _SectionEntry.item(this.doc)
      : isHeader = false,
        isArchiveHeader = false,
        headerTitle = null;
}

class _ArchiveHeader extends StatelessWidget {
  final String? tenantId;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ArchiveHeader({
    required this.tenantId,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.archive,
              color: Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Arşiv',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
            ),
            const Spacer(),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: (tenantId != null && tenantId!.isNotEmpty)
                  ? FirebaseFirestore.instance
                      .collection('tenants')
                      .doc(tenantId)
                      .collection('employees')
                      .where('isActive', isEqualTo: false)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('employees')
                      .where('isActive', isEqualTo: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!context.mounted) {
                  return const SizedBox.shrink();
                }
                final count = snapshot.data?.docs.length ?? 0;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentHeader extends StatefulWidget {
  final String? departmentName;
  final String? tenantId;
  final VoidCallback onDepartmentChanged;

  const _DepartmentHeader({
    required this.departmentName,
    required this.tenantId,
    required this.onDepartmentChanged,
  });

  @override
  State<_DepartmentHeader> createState() => _DepartmentHeaderState();
}

class _DepartmentHeaderState extends State<_DepartmentHeader> {
  bool _isHovered = false;

  void _openDepartmentDialog() {
    if (widget.departmentName == null) return;
    showDialog(
      context: context,
      builder: (context) => _DepartmentEditDialog(
        departmentName: widget.departmentName!,
        tenantId: widget.tenantId,
        onDepartmentChanged: widget.onDepartmentChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.departmentName != null ? _openDepartmentDialog : null,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.departmentName ?? '-',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (_isHovered && widget.departmentName != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartmentEditDialog extends StatefulWidget {
  final String departmentName;
  final String? tenantId;
  final VoidCallback onDepartmentChanged;

  const _DepartmentEditDialog({
    required this.departmentName,
    required this.tenantId,
    required this.onDepartmentChanged,
  });

  @override
  State<_DepartmentEditDialog> createState() => _DepartmentEditDialogState();
}

class _DepartmentEditDialogState extends State<_DepartmentEditDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedTransferDepartment;
  List<String> _availableDepartments = [];
  bool _isLoading = false;
  Set<String> _selectedEmployeeIds = {};

  CollectionReference<Map<String, dynamic>> _tenantCol(String name) {
    if (widget.tenantId != null && widget.tenantId!.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('tenants')
          .doc(widget.tenantId)
          .collection(name);
    }
    return FirebaseFirestore.instance.collection(name);
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.departmentName;
    _loadDepartments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final snapshot = await _tenantCol('departments').orderBy('name').get();
      setState(() {
        _availableDepartments = snapshot.docs
            .map((doc) => doc.data()['name'] as String? ?? '')
            .where((name) => name.isNotEmpty && name != widget.departmentName)
            .toList();
      });
    } catch (e) {
      // Hata durumunda boş liste
      setState(() {
        _availableDepartments = [];
      });
    }
  }

  Future<void> _updateDepartmentName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.departmentName) return;

    setState(() => _isLoading = true);
    try {
      // Departman adını güncelle
      final deptSnapshot = await _tenantCol('departments')
          .where('name', isEqualTo: widget.departmentName)
          .limit(1)
          .get();

      if (deptSnapshot.docs.isNotEmpty) {
        await deptSnapshot.docs.first.reference.update({'name': newName});
      }

      // Tüm personellerin departman bilgisini güncelle
      final employeesSnapshot = await _tenantCol('employees')
          .where('department', isEqualTo: widget.departmentName)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in employeesSnapshot.docs) {
        batch.update(doc.reference, {'department': newName});
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Departman adı güncellendi')),
        );
        widget.onDepartmentChanged();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteDepartment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Departmanı Sil'),
        content: Text(
          '"${widget.departmentName}" departmanını silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      // Departmanı sil
      final deptSnapshot = await _tenantCol('departments')
          .where('name', isEqualTo: widget.departmentName)
          .limit(1)
          .get();

      if (deptSnapshot.docs.isNotEmpty) {
        await deptSnapshot.docs.first.reference.delete();
      }

      // Bu departmandaki personellerin departman bilgisini temizle
      final employeesSnapshot = await _tenantCol('employees')
          .where('department', isEqualTo: widget.departmentName)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in employeesSnapshot.docs) {
        batch.update(doc.reference, {'department': ''});
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Departman silindi')),
        );
        widget.onDepartmentChanged();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _transferEmployees() async {
    if (_selectedTransferDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen hedef departman seçin')),
      );
      return;
    }

    if (_selectedEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen aktarılacak personel seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final empId in _selectedEmployeeIds) {
        final empRef = _tenantCol('employees').doc(empId);
        batch.update(empRef, {'department': _selectedTransferDepartment});
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedEmployeeIds.length} personel "$_selectedTransferDepartment" departmanına aktarıldı',
            ),
          ),
        );
        widget.onDepartmentChanged();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Departman: ${widget.departmentName}'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Departman adı düzenleme
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Departman Adı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _updateDepartmentName,
                      child: const Text('Adı Güncelle'),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Personel listesi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bu Departmandaki Personeller',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedEmployeeIds.clear();
                            });
                          },
                          child: const Text('Temizle'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _tenantCol('employees')
                          .where('department', isEqualTo: widget.departmentName)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!context.mounted) {
                          return const SizedBox.shrink();
                        }
                        if (snapshot.hasError) {
                          return Text('Hata: ${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final employees = snapshot.data!.docs;
                        if (employees.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Bu departmanda personel bulunmuyor'),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedEmployeeIds = employees
                                          .map((doc) => doc.id)
                                          .toSet();
                                    });
                                  },
                                  child: const Text('Tümünü Seç'),
                                ),
                              ],
                            ),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: employees.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final empDoc = employees[index];
                                  final emp = empDoc.data();
                                  final empId = empDoc.id;
                                  final name = emp['name'] as String? ?? '-';
                                  final isSelected =
                                      _selectedEmployeeIds.contains(empId);
                                  return CheckboxListTile(
                                    dense: true,
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedEmployeeIds.add(empId);
                                        } else {
                                          _selectedEmployeeIds.remove(empId);
                                        }
                                      });
                                    },
                                    title: Text(name),
                                    subtitle: Text(
                                      emp['category'] as String? ?? '',
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Personel aktarma
                    Text(
                      'Personelleri Başka Departmana Aktar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (_availableDepartments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Aktarılacak başka departman bulunmuyor',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTransferDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Hedef Departman',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableDepartments
                            .map((dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTransferDepartment = value;
                          });
                        },
                      ),
                    if (_availableDepartments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _transferEmployees,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Personelleri Aktar'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Silme butonu
                    FilledButton(
                      onPressed: _deleteDepartment,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Departmanı Sil'),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}

class _EmployeeDetailSheet extends StatelessWidget {
  final String? tenantId;
  final String docId;
  final Map<String, dynamic> data;
  const _EmployeeDetailSheet(
      {required this.tenantId, required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '-';
    final department = data['department'] as String? ?? '-';
    final category = data['category'] as String? ?? '-';
    final position = data['position'] as String? ?? '-';
    final tc = data['tc']?.toString() ?? '-';
    final email = data['email']?.toString() ?? '-';
    final salary = (data['salary'] as Map?) ?? {};
    final salaryAmount = salary['amount']?.toString() ?? '-';
    final salaryCurrency = salary['currency']?.toString() ?? '';
    final entitlement = (data['entitlement'] as Map?) ?? {};
    final entitlementType = entitlement['type']?.toString() ?? '-';
    final startTs = data['startDate'];
    final birthTs = data['birthDate'];
    String? fmtTs(dynamic ts) {
      try {
        if (ts is Timestamp) {
          final d = ts.toDate();
          return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
        }
      } catch (_) {}
      return null;
    }

    final startDate = fmtTs(startTs) ?? '-';
    final birthDate = fmtTs(birthTs) ?? '-';
    final photoUrl = data['photoUrl'] as String?;
    final docs = (data['documents'] as List?) ?? const [];
    final schedule = (data['schedule'] as Map?) ?? const {};
    final workHours = (schedule['workHours'] as Map?);
    final overtime = (schedule['overtime'] as Map?);

    // Format salary amount in Turkish format
    String formatSalary(String amountStr) {
      if (amountStr == '-') return '-';
      final amount = double.tryParse(amountStr);
      if (amount == null) return amountStr;
      final parts = amount.toStringAsFixed(2).split('.');
      final intPart = parts[0];
      final decPart = parts[1];
      final formattedInt = intPart.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      return '$formattedInt,$decPart';
    }

    final formattedSalaryAmount = formatSalary(salaryAmount);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage:
                            (photoUrl != null && photoUrl.isNotEmpty)
                                ? NetworkImage(photoUrl)
                                : null,
                        onBackgroundImageError:
                            (photoUrl != null && photoUrl.isNotEmpty)
                                ? (exception, stackTrace) {
                                    // Hata durumunda icon gösterilecek
                                  }
                                : null,
                        child: (photoUrl == null || photoUrl.isEmpty)
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(name,
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1),
                            const SizedBox(height: 4),
                            Text('$department • $category',
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _openEdit(context),
                              icon: const Icon(Icons.edit),
                              tooltip: 'Düzenle',
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            IconButton(
                              onPressed: () =>
                                  _showEmployeeActionDialog(context),
                              icon: const Icon(Icons.more_vert),
                              tooltip: 'İşlemler',
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              tooltip: 'Kapat',
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              padding: EdgeInsets.zero,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _handleOvertimeAction(context),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.green,
                          ),
                          icon: const Icon(Icons.access_time),
                          label: const Text('Mesai'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _handleAdvancePaymentAction(context),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text('Ödeme'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _handleEntitlementAction(context),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.purple,
                          ),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Hak Ediş'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Önümüzdeki hak ediş tarihi gösterimi
                  FutureBuilder<DateTime?>(
                    future: _calculateNextEntitlementDate(
                      tenantId: tenantId,
                      employeeId: docId,
                      entitlementType: entitlementType,
                      entitlement: Map<String, dynamic>.from(entitlement),
                      startDate: startTs,
                      createdAt: () {
                        final createdAtField = data['createdAt'];
                        if (createdAtField is Timestamp) {
                          return createdAtField.toDate();
                        } else if (createdAtField is DateTime) {
                          return createdAtField;
                        }
                        return null;
                      }(),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 12),
                                Text('Hak ediş tarihi hesaplanıyor...'),
                              ],
                            ),
                          ),
                        );
                      }

                      final nextDate = snapshot.data;
                      if (nextDate == null) {
                        return const SizedBox.shrink();
                      }

                      final now = DateTime.now();
                      final difference = nextDate.difference(now);
                      final days = difference.inDays;
                      final hours = difference.inHours % 24;
                      final minutes = difference.inMinutes % 60;

                      final isOverdue = difference.isNegative;
                      final overdueDays = isOverdue ? -days : 0;

                      String timeText;
                      String titleText;
                      if (isOverdue) {
                        titleText = 'ÖDEME GECİKTİ! ⚠️';
                        if (overdueDays > 0) {
                          timeText = '$overdueDays gün gecikti';
                        } else {
                          final overdueHours = -difference.inHours;
                          if (overdueHours > 0) {
                            timeText = '$overdueHours saat gecikti';
                          } else {
                            final overdueMinutes = -difference.inMinutes;
                            timeText = '$overdueMinutes dakika gecikti';
                          }
                        }
                      } else if (days > 0) {
                        titleText = 'Önümüzdeki Hak Ediş Tarihi';
                        timeText = '$days gün $hours saat sonra';
                      } else if (hours > 0) {
                        titleText = 'Önümüzdeki Hak Ediş Tarihi';
                        timeText = '$hours saat $minutes dakika sonra';
                      } else {
                        titleText = 'Önümüzdeki Hak Ediş Tarihi';
                        timeText = '$minutes dakika sonra';
                      }

                      final nextDateStr =
                          '${nextDate.day.toString().padLeft(2, '0')}.${nextDate.month.toString().padLeft(2, '0')}.${nextDate.year}';

                      return Card(
                        color: isOverdue
                            ? Colors.red.shade50
                            : Colors.blue.shade50,
                        elevation: isOverdue ? 4 : 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                isOverdue
                                    ? Icons.warning
                                    : Icons.calendar_today,
                                color: isOverdue
                                    ? Colors.red.shade700
                                    : Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titleText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isOverdue
                                                ? Colors.red.shade700
                                                : null,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isOverdue
                                          ? '$nextDateStr • $timeText'
                                          : '$nextDateStr • $timeText',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isOverdue
                                                ? Colors.red.shade700
                                                : Colors.blue.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isOverdue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'GEÇ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Personel Bilgileri',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _showEmployeeDetailsDialog(
                              context,
                              name: name,
                              position: position,
                              salary: '$formattedSalaryAmount $salaryCurrency',
                              entitlementType: entitlementType,
                              entitlement: entitlement,
                              startDate: startDate,
                              birthDate: birthDate,
                              tc: tc,
                              email: email,
                              workHours: workHours,
                              overtime: overtime,
                            ),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Bilgileri Görüntüle'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (docs.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Dökümanlar (${docs.length})',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () => _showDocumentsDialog(
                                context,
                                docs: docs,
                              ),
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Dökümanları Görüntüle'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text('Hareketler',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              IconButton(
                                icon: const Icon(Icons.file_download),
                                iconSize: 18,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                tooltip: 'Dışa Aktar',
                                onPressed: () {
                                  final sheet = _EmployeeDetailSheet(
                                    tenantId: tenantId,
                                    docId: docId,
                                    data: data,
                                  );
                                  sheet._showExportTransactionsOptions(context);
                                },
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: _EmployeeBalance(
                                    tenantId: tenantId,
                                    docId: docId,
                                    currency: salaryCurrency.isNotEmpty
                                        ? salaryCurrency
                                        : 'TRY'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _EmployeeTransactionsList(
                              tenantId: tenantId,
                              docId: docId,
                              currency: salaryCurrency.isNotEmpty
                                  ? salaryCurrency
                                  : 'TRY',
                              onEditOvertimeTransaction:
                                  (ctx, tId, empId, transId, transData, curr) {
                                final sheet = _EmployeeDetailSheet(
                                  tenantId: tId,
                                  docId: empId,
                                  data: data,
                                );
                                sheet._showEditOvertimeTransactionDialog(
                                  ctx,
                                  tId,
                                  empId,
                                  transId,
                                  transData,
                                  curr,
                                );
                              },
                              onEditPaymentTransaction:
                                  (ctx, tId, empId, transId, transData, curr) {
                                final sheet = _EmployeeDetailSheet(
                                  tenantId: tId,
                                  docId: empId,
                                  data: data,
                                );
                                sheet._showEditPaymentTransactionDialog(
                                  ctx,
                                  tId,
                                  empId,
                                  transId,
                                  transData,
                                  curr,
                                );
                              },
                              onDeletePaymentTransaction:
                                  (ctx, tId, transId, transData) {
                                final sheet = _EmployeeDetailSheet(
                                  tenantId: tId,
                                  docId: docId,
                                  data: data,
                                );
                                sheet._showDeletePaymentTransactionDialog(
                                  ctx,
                                  tId,
                                  transId,
                                  transData,
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Önümüzdeki hak ediş tarihini hesapla
  Future<DateTime?> _calculateNextEntitlementDate({
    required String? tenantId,
    required String employeeId,
    required String entitlementType,
    required Map<String, dynamic> entitlement,
    required dynamic startDate,
    DateTime? createdAt,
  }) async {
    try {
      // Start date'i DateTime'a çevir
      DateTime? startDateTime;
      if (startDate is Timestamp) {
        startDateTime = startDate.toDate();
      } else if (startDate is DateTime) {
        startDateTime = startDate;
      }
      if (startDateTime == null) return null;

      // Personelin kaydedildiği tarihi kullan (eğer verilmişse)
      // Eğer createdAt verilmemişse, şu anki zamanı kullan
      final effectiveCreatedAt = createdAt ?? DateTime.now();

      // Otomatik hak ediş başlangıç tarihi: personelin kaydedildiği tarih ile işe başlama tarihinden daha geç olan
      final effectiveStartDate = startDateTime.isAfter(effectiveCreatedAt)
          ? startDateTime
          : effectiveCreatedAt;

      // Son transaction tarihini bul
      final transactionsCol = (tenantId != null && tenantId.isNotEmpty)
          ? FirebaseFirestore.instance
              .collection('tenants')
              .doc(tenantId)
              .collection('employee_transactions')
          : FirebaseFirestore.instance.collection('employee_transactions');

      // Index gerektirmeyen sorgu - client-side sıralama yapacağız
      final lastTransactionQuery = await transactionsCol
          .where('employeeId', isEqualTo: employeeId)
          .where('direction', isEqualTo: 'in')
          .get();

      // Client-side sıralama
      QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;
      DateTime? lastDate;

      for (final doc in lastTransactionQuery.docs) {
        final data = doc.data();
        final date = data['date'];
        DateTime? docDate;

        if (date is Timestamp) {
          docDate = date.toDate();
        } else if (date is DateTime) {
          docDate = date;
        }

        if (docDate != null) {
          if (lastDate == null || docDate.isAfter(lastDate)) {
            lastDate = docDate;
            lastDoc = doc;
          }
        }
      }

      // Son ödeme tarihini belirle: effectiveStartDate'den önceki tarihleri dikkate alma
      DateTime lastPaymentDate = effectiveStartDate;
      if (lastDoc != null &&
          lastDate != null &&
          lastDate.isAfter(effectiveStartDate)) {
        lastPaymentDate = lastDate;
      }

      // Bir sonraki ödeme tarihini hesapla
      final now = DateTime.now();
      // fromDate olarak lastPaymentDate veya now'dan daha geç olanı kullan
      final fromDate = lastPaymentDate.isAfter(now) ? lastPaymentDate : now;

      DateTime? nextPayment = _getNextPaymentDateForDisplay(
        fromDate: fromDate,
        entitlementType: entitlementType,
        entitlement: entitlement,
      );

      return nextPayment;
    } catch (e) {
      debugPrint('Hak ediş tarihi hesaplama hatası: $e');
      return null;
    }
  }

  // Bir sonraki ödeme tarihini hesapla (gösterim için)
  DateTime? _getNextPaymentDateForDisplay({
    required DateTime fromDate,
    required String entitlementType,
    required Map<String, dynamic> entitlement,
  }) {
    int getWeekdayNumber(String weekday) {
      const weekdays = {
        'Pazartesi': 1,
        'Salı': 2,
        'Çarşamba': 3,
        'Perşembe': 4,
        'Cuma': 5,
        'Cumartesi': 6,
        'Pazar': 7,
      };
      return weekdays[weekday] ?? 1;
    }

    DateTime findNextWeekday(DateTime from, int targetWeekday) {
      DateTime current = from;
      // Eğer bugün hedef günse, bir sonraki haftaya geç
      if (current.weekday == targetWeekday) {
        current = current.add(const Duration(days: 7));
      } else {
        // Bir sonraki hedef günü bul
        current = current.add(const Duration(days: 1));
        while (current.weekday != targetWeekday) {
          current = current.add(const Duration(days: 1));
        }
      }
      return current;
    }

    switch (entitlementType) {
      case 'Aylık':
        final monthlyDay = entitlement['monthlyDayOfMonth'] as int?;
        if (monthlyDay == null) return null;

        // Geçersiz değerleri düzelt (1-31 arasında olmalı)
        final validDay = monthlyDay >= 1 && monthlyDay <= 31 ? monthlyDay : 31;

        // Önce aynı ayın ödeme gününü kontrol et
        try {
          final sameMonthPayment =
              DateTime(fromDate.year, fromDate.month, validDay);
          if (sameMonthPayment.isAfter(fromDate) ||
              sameMonthPayment.isAtSameMomentAs(fromDate)) {
            return sameMonthPayment;
          }
        } catch (_) {
          // Geçersiz tarih (örn: 31 Şubat), devam et
        }

        // Aynı ayın ödeme günü geçmişse, bir sonraki ayın ödeme gününe git
        DateTime next = DateTime(fromDate.year, fromDate.month + 1, validDay);
        // Eğer ayın günü ayın sonundan büyükse, ayın sonunu kullan
        try {
          return next;
        } catch (_) {
          // Geçersiz tarih (örn: 31 Şubat), ayın sonunu kullan
          next = DateTime(fromDate.year, fromDate.month + 2, 0);
          return next;
        }

      case 'Aylık (İki Kere)':
        final days = entitlement['semiMonthlyDays'] as List?;
        if (days == null || days.length < 2) return null;
        final day1 = (days[0] as num?)?.toInt();
        final day2 = (days[1] as num?)?.toInt();
        if (day1 == null || day2 == null) return null;

        // Önce aynı ayın ilk ödeme gününü kontrol et
        try {
          DateTime next = DateTime(fromDate.year, fromDate.month, day1);
          if (next.isAfter(fromDate)) {
            return next;
          }
        } catch (_) {
          // Geçersiz tarih, devam et
        }

        // Sonra aynı ayın ikinci ödeme gününü kontrol et
        try {
          DateTime next = DateTime(fromDate.year, fromDate.month, day2);
          if (next.isAfter(fromDate)) {
            return next;
          }
        } catch (_) {
          // Geçersiz tarih, devam et
        }

        // Eğer aynı ayın ödeme günleri geçmişse, bir sonraki ayın ilk ödeme gününe git
        try {
          DateTime next = DateTime(fromDate.year, fromDate.month + 1, day1);
          return next;
        } catch (_) {
          // Geçersiz tarih (örn: 31 Şubat), ayın sonunu kullan
          DateTime next = DateTime(fromDate.year, fromDate.month + 2, 0);
          return next;
        }

      case 'Haftalık':
        final weekday = entitlement['weeklyWeekday'] as String?;
        if (weekday == null) return null;
        final targetWeekday = getWeekdayNumber(weekday);
        return findNextWeekday(fromDate, targetWeekday);

      case 'Günlük':
        final weeklyDays = entitlement['weeklyDays'] as List?;
        if (weeklyDays == null || weeklyDays.isEmpty) return null;

        DateTime current = fromDate.add(const Duration(days: 1));
        int maxDays = 14; // 2 hafta içinde bul
        int checked = 0;
        while (checked < maxDays) {
          final weekdayName = [
            'Pazartesi',
            'Salı',
            'Çarşamba',
            'Perşembe',
            'Cuma',
            'Cumartesi',
            'Pazar'
          ][current.weekday - 1];
          if (weeklyDays.contains(weekdayName)) {
            return current;
          }
          current = current.add(const Duration(days: 1));
          checked++;
        }
        return null;

      case 'Saatlik':
        // Ay sonu
        DateTime monthEnd = DateTime(fromDate.year, fromDate.month + 1, 0);
        if (monthEnd.isBefore(fromDate)) {
          monthEnd = DateTime(fromDate.year, fromDate.month + 2, 0);
        }
        return monthEnd;

      default:
        return null;
    }
  }

  Future<void> _downloadDocument(
      BuildContext context, String url, String fileName) async {
    try {
      if (kIsWeb) {
        // Web için direkt indirme
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final uint8List = Uint8List.fromList(bytes);
          final blob = web.Blob([uint8List.buffer.toJS].toJS);
          final downloadUrl = web.URL.createObjectURL(blob);

          final anchor = web.HTMLAnchorElement()
            ..href = downloadUrl
            ..download = fileName
            ..style.display = 'none';

          web.document.body?.appendChild(anchor);
          anchor.click();
          anchor.remove();
          web.URL.revokeObjectURL(downloadUrl);
        }
      } else {
        // Mobil için Downloads klasörüne kaydet
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final directory = await getDownloadsDirectory();
          if (directory != null) {
            final filePath = path.join(directory.path, fileName);
            final file = File(filePath);
            await file.writeAsBytes(bytes);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Döküman indirildi: $fileName'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İndirme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleOvertimeAction(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$name - Mesai İşlemleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showAddOvertimeDialog(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Mesai Ekle'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showDeductOvertimeDialog(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.remove),
              label: const Text('Mesaiden Kes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  // Saatlik ücreti hesapla
  double _calculateHourlyRateForOvertime({
    required double salaryAmount,
    required String entitlementType,
    required Map<String, dynamic> entitlement,
  }) {
    double hourlyRate = 0;

    switch (entitlementType) {
      case 'Aylık':
      case 'Aylık (İki Kere)':
        // Aylık maaş: Haftada kaç gün ve günde kaç saat bilgilerini kullan
        final daysPerWeek = entitlement['daysPerWeek'] as int? ?? 5;
        final hoursPerDay = entitlement['hoursPerDay'] as int? ?? 8;
        // Ayda ortalama 4.33 hafta var (30 gün / 7 gün ≈ 4.33)
        // Ayda toplam çalışma saati = 4.33 * haftada gün sayısı * günde saat sayısı
        final weeklyHours = daysPerWeek * hoursPerDay;
        final monthlyHours = weeklyHours * 4.33; // Ortalama hafta sayısı
        hourlyRate = salaryAmount / monthlyHours;
        break;
      case 'Haftalık':
        // Haftalık maaş: Haftada 5 gün, günde 8 saat (varsayılan)
        // Eğer entitlement'da bilgi varsa kullan
        final daysPerWeek = entitlement['daysPerWeek'] as int? ?? 5;
        final hoursPerDay = entitlement['hoursPerDay'] as int? ?? 8;
        hourlyRate = salaryAmount / (daysPerWeek * hoursPerDay);
        break;
      case 'Günlük':
        // Günlük maaş: Günde kaç saat bilgisini kullan
        final hoursPerDay = entitlement['hoursPerDay'] as int? ?? 8;
        hourlyRate = salaryAmount / hoursPerDay;
        break;
      case 'Saatlik':
        // Saatlik maaş: Zaten saatlik ücret
        hourlyRate = salaryAmount;
        break;
      default:
        // Varsayılan: Aylık hesaplama (eski yöntem - geriye dönük uyumluluk)
        hourlyRate = salaryAmount / (30 * 8);
    }

    return hourlyRate;
  }

  void _showAddOvertimeDialog(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    final salary =
        (data['salary'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final salaryAmount = (salary['amount'] as num?)?.toDouble() ?? 0;
    final salaryCurrency = salary['currency']?.toString() ?? 'TRY';
    final entitlement =
        (data['entitlement'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final entitlementType = entitlement['type']?.toString() ?? 'Aylık';

    final hoursController = TextEditingController();
    final multiplierController = TextEditingController(text: '1');
    final hourlyOvertimeRateController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
    final noteController = TextEditingController();
    DateTime? selectedDate = DateTime.now();

    // Saatlik ücreti hesapla
    final baseHourlyRate = _calculateHourlyRateForOvertime(
      salaryAmount: salaryAmount,
      entitlementType: entitlementType,
      entitlement: entitlement,
    );

    // İlk hesaplama için listener ekle
    String? lastCalculatedHourlyRate;
    String? lastCalculatedMultiplier;
    bool userChangedHourlyRate = false;
    bool userChangedMultiplier = false;
    bool isDisposed = false;

    // İlk saatlik mesai ücretini hesapla ve doldur (çarpan = 1)
    if (baseHourlyRate > 0) {
      final initialHourlyOvertimeRate = baseHourlyRate * 1;
      hourlyOvertimeRateController.text =
          initialHourlyOvertimeRate.toStringAsFixed(2);
      lastCalculatedHourlyRate = initialHourlyOvertimeRate.toStringAsFixed(2);
    }

    void updateHourlyOvertimeRate() {
      if (isDisposed) return;
      final multiplier =
          double.tryParse(multiplierController.text.replaceAll(',', '.')) ?? 1;
      if (multiplier > 0 && baseHourlyRate > 0 && !userChangedHourlyRate) {
        final calculatedHourlyRate = baseHourlyRate * multiplier;
        final calculatedHourlyRateStr = calculatedHourlyRate.toStringAsFixed(2);
        if (lastCalculatedHourlyRate == null ||
            hourlyOvertimeRateController.text == lastCalculatedHourlyRate ||
            hourlyOvertimeRateController.text.isEmpty) {
          hourlyOvertimeRateController.text = calculatedHourlyRateStr;
          lastCalculatedHourlyRate = calculatedHourlyRateStr;
        }
      }
    }

    void updateMultiplier() {
      if (isDisposed) return;
      final hourlyOvertimeRate = double.tryParse(
              hourlyOvertimeRateController.text.replaceAll(',', '.')) ??
          0;
      if (hourlyOvertimeRate > 0 &&
          baseHourlyRate > 0 &&
          !userChangedMultiplier) {
        final calculatedMultiplier = hourlyOvertimeRate / baseHourlyRate;
        final calculatedMultiplierStr = calculatedMultiplier.toStringAsFixed(2);
        if (lastCalculatedMultiplier == null ||
            multiplierController.text == lastCalculatedMultiplier ||
            multiplierController.text.isEmpty) {
          multiplierController.text = calculatedMultiplierStr;
          lastCalculatedMultiplier = calculatedMultiplierStr;
        }
      }
    }

    void updateAmount({bool force = false}) {
      if (isDisposed) return;
      final hours =
          double.tryParse(hoursController.text.replaceAll(',', '.')) ?? 0;
      final hourlyOvertimeRate = double.tryParse(
              hourlyOvertimeRateController.text.replaceAll(',', '.')) ??
          0;

      if (hours > 0 && hourlyOvertimeRate > 0) {
        // Mesai tutarı her zaman otomatik hesaplanır (read-only alan)
        final calculatedAmount = hourlyOvertimeRate * hours;
        final calculatedAmountStr = calculatedAmount.toStringAsFixed(2);
        amountController.text = calculatedAmountStr;
      } else {
        amountController.text = '';
      }
    }

    // Listener fonksiyonlarını sakla (dispose için)
    void multiplierListener() {
      if (isDisposed) return;
      userChangedMultiplier = true;
      userChangedHourlyRate = false;
      updateHourlyOvertimeRate();
      updateAmount();
    }

    void hourlyOvertimeRateListener() {
      if (isDisposed) return;
      userChangedHourlyRate = true;
      userChangedMultiplier = false;
      updateMultiplier();
      updateAmount();
    }

    hoursController.addListener(updateAmount);
    multiplierController.addListener(multiplierListener);
    hourlyOvertimeRateController.addListener(hourlyOvertimeRateListener);
    // Mesai tutarı read-only olduğu için listener'a gerek yok

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Mesai Ekle'),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('$name için mesai ekle'),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text =
                                '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          dateController.text.isEmpty
                              ? 'Tarih seçin'
                              : dateController.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Mesai Saati',
                        border: OutlineInputBorder(),
                        hintText: 'Örn: 2.5',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        setState(() {
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: multiplierController,
                      decoration: const InputDecoration(
                        labelText: 'Mesai Çarpanı',
                        border: OutlineInputBorder(),
                        hintText: 'Örn: 1.5 (varsayılan: 1)',
                        helperText: 'Saatlik ücretin kaç katı olacak?',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hourlyOvertimeRateController,
                      decoration: InputDecoration(
                        labelText: 'Saatlik Mesai Ücreti ($salaryCurrency)',
                        border: const OutlineInputBorder(),
                        hintText: 'Otomatik hesaplanır',
                        helperText: 'Saatlik ücret × çarpan',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Mesai Tutarı ($salaryCurrency)',
                        border: const OutlineInputBorder(),
                        hintText: 'Otomatik hesaplanır',
                        helperText: 'Saatlik mesai ücreti × mesai saati',
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      readOnly: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (Opsiyonel)',
                        border: OutlineInputBorder(),
                        hintText: 'Mesai nedeni...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Önce isDisposed flag'ini set et
                  isDisposed = true;
                  // Listener'ları kaldır
                  hoursController.removeListener(updateAmount);
                  multiplierController.removeListener(multiplierListener);
                  hourlyOvertimeRateController
                      .removeListener(hourlyOvertimeRateListener);
                  // Dialog'u önce kapat (Flutter otomatik olarak focus'u temizler)
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  // Controller'ları dispose et (dialog kapandıktan sonra)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    hoursController.dispose();
                    multiplierController.dispose();
                    hourlyOvertimeRateController.dispose();
                    amountController.dispose();
                    dateController.dispose();
                    noteController.dispose();
                  });
                },
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  final hours = double.tryParse(
                    hoursController.text.replaceAll(',', '.'),
                  );
                  if (hours == null || hours <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir mesai saati girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final multiplier = double.tryParse(
                    multiplierController.text.replaceAll(',', '.'),
                  );
                  if (multiplier == null || multiplier <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir çarpan girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final hourlyOvertimeRate = double.tryParse(
                    hourlyOvertimeRateController.text.replaceAll(',', '.'),
                  );
                  if (hourlyOvertimeRate == null || hourlyOvertimeRate <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Lütfen geçerli bir saatlik mesai ücreti girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final overtimeAmount = double.tryParse(
                    amountController.text.replaceAll(',', '.'),
                  );
                  if (overtimeAmount == null || overtimeAmount <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir tutar girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final col = (tenantId != null && tenantId!.isNotEmpty)
                        ? FirebaseFirestore.instance
                            .collection('tenants')
                            .doc(tenantId)
                            .collection('employee_transactions')
                        : FirebaseFirestore.instance
                            .collection('employee_transactions');

                    await col.add({
                      'employeeId': docId,
                      'amount': overtimeAmount,
                      'direction': 'in',
                      'type': 'overtime',
                      'note': noteController.text.trim().isEmpty
                          ? 'Mesai: $hours saat (x$multiplier)'
                          : 'Mesai: $hours saat (x$multiplier) - ${noteController.text.trim()}',
                      'overtimeHours': hours,
                      'overtimeMultiplier': multiplier,
                      'hourlyOvertimeRate': hourlyOvertimeRate,
                      'date': Timestamp.fromDate(selectedDate!),
                      'currency': salaryCurrency,
                      'tenantId': tenantId,
                      'createdBy': FirebaseAuth.instance.currentUser?.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    // Önce isDisposed flag'ini set et
                    isDisposed = true;
                    // Listener'ları kaldır
                    hoursController.removeListener(updateAmount);
                    multiplierController.removeListener(multiplierListener);
                    hourlyOvertimeRateController
                        .removeListener(hourlyOvertimeRateListener);
                    // Dialog'u önce kapat (Flutter otomatik olarak focus'u temizler)
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                    // Controller'ları dispose et ve SnackBar'ı göster (dialog kapandıktan sonra)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      hoursController.dispose();
                      multiplierController.dispose();
                      hourlyOvertimeRateController.dispose();
                      amountController.dispose();
                      dateController.dispose();
                      noteController.dispose();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$hours saat mesai eklendi (${overtimeAmount.toStringAsFixed(2)} $salaryCurrency)',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                  } catch (e) {
                    if (!isDisposed && ctx.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Mesai Ekle'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeductOvertimeDialog(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    final salary =
        (data['salary'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final salaryAmount = (salary['amount'] as num?)?.toDouble() ?? 0;
    final salaryCurrency = salary['currency']?.toString() ?? 'TRY';
    final entitlement =
        (data['entitlement'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final entitlementType = entitlement['type']?.toString() ?? 'Aylık';

    final hoursController = TextEditingController();
    final multiplierController = TextEditingController(text: '1');
    final hourlyOvertimeRateController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
    final noteController = TextEditingController();
    DateTime? selectedDate = DateTime.now();

    // Saatlik ücreti hesapla
    final baseHourlyRate = _calculateHourlyRateForOvertime(
      salaryAmount: salaryAmount,
      entitlementType: entitlementType,
      entitlement: entitlement,
    );

    // İlk hesaplama için listener ekle
    String? lastCalculatedHourlyRate;
    String? lastCalculatedMultiplier;
    bool userChangedHourlyRate = false;
    bool userChangedMultiplier = false;
    bool isDisposed = false;

    // İlk saatlik mesai ücretini hesapla ve doldur (çarpan = 1)
    if (baseHourlyRate > 0) {
      final initialHourlyOvertimeRate = baseHourlyRate * 1;
      hourlyOvertimeRateController.text =
          initialHourlyOvertimeRate.toStringAsFixed(2);
      lastCalculatedHourlyRate = initialHourlyOvertimeRate.toStringAsFixed(2);
    }

    void updateHourlyOvertimeRate() {
      if (isDisposed) return;
      final multiplier =
          double.tryParse(multiplierController.text.replaceAll(',', '.')) ?? 1;
      if (multiplier > 0 && baseHourlyRate > 0 && !userChangedHourlyRate) {
        final calculatedHourlyRate = baseHourlyRate * multiplier;
        final calculatedHourlyRateStr = calculatedHourlyRate.toStringAsFixed(2);
        if (lastCalculatedHourlyRate == null ||
            hourlyOvertimeRateController.text == lastCalculatedHourlyRate ||
            hourlyOvertimeRateController.text.isEmpty) {
          hourlyOvertimeRateController.text = calculatedHourlyRateStr;
          lastCalculatedHourlyRate = calculatedHourlyRateStr;
        }
      }
    }

    void updateMultiplier() {
      if (isDisposed) return;
      final hourlyOvertimeRate = double.tryParse(
              hourlyOvertimeRateController.text.replaceAll(',', '.')) ??
          0;
      if (hourlyOvertimeRate > 0 &&
          baseHourlyRate > 0 &&
          !userChangedMultiplier) {
        final calculatedMultiplier = hourlyOvertimeRate / baseHourlyRate;
        final calculatedMultiplierStr = calculatedMultiplier.toStringAsFixed(2);
        if (lastCalculatedMultiplier == null ||
            multiplierController.text == lastCalculatedMultiplier ||
            multiplierController.text.isEmpty) {
          multiplierController.text = calculatedMultiplierStr;
          lastCalculatedMultiplier = calculatedMultiplierStr;
        }
      }
    }

    void updateAmount({bool force = false}) {
      if (isDisposed) return;
      final hours =
          double.tryParse(hoursController.text.replaceAll(',', '.')) ?? 0;
      final hourlyOvertimeRate = double.tryParse(
              hourlyOvertimeRateController.text.replaceAll(',', '.')) ??
          0;

      if (hours > 0 && hourlyOvertimeRate > 0) {
        // Mesai tutarı her zaman otomatik hesaplanır (read-only alan)
        final calculatedAmount = hourlyOvertimeRate * hours;
        final calculatedAmountStr = calculatedAmount.toStringAsFixed(2);
        amountController.text = calculatedAmountStr;
      } else {
        amountController.text = '';
      }
    }

    // Listener fonksiyonlarını sakla (dispose için)
    void multiplierListener() {
      if (isDisposed) return;
      userChangedMultiplier = true;
      userChangedHourlyRate = false;
      updateHourlyOvertimeRate();
      updateAmount();
    }

    void hourlyOvertimeRateListener() {
      if (isDisposed) return;
      userChangedHourlyRate = true;
      userChangedMultiplier = false;
      updateMultiplier();
      updateAmount();
    }

    hoursController.addListener(updateAmount);
    multiplierController.addListener(multiplierListener);
    hourlyOvertimeRateController.addListener(hourlyOvertimeRateListener);
    // Mesai tutarı read-only olduğu için listener'a gerek yok

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Mesaiden Kes'),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('$name için mesai kes'),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text =
                                '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          dateController.text.isEmpty
                              ? 'Tarih seçin'
                              : dateController.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Kesilecek Mesai Saati',
                        border: OutlineInputBorder(),
                        hintText: 'Örn: 2.5',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        setState(() {
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: multiplierController,
                      decoration: const InputDecoration(
                        labelText: 'Mesai Çarpanı',
                        border: OutlineInputBorder(),
                        hintText: 'Örn: 1.5 (varsayılan: 1)',
                        helperText: 'Saatlik ücretin kaç katı olacak?',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hourlyOvertimeRateController,
                      decoration: InputDecoration(
                        labelText: 'Saatlik Mesai Ücreti ($salaryCurrency)',
                        border: const OutlineInputBorder(),
                        hintText: 'Otomatik hesaplanır',
                        helperText: 'Saatlik ücret × çarpan',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Kesilecek Mesai Tutarı ($salaryCurrency)',
                        border: const OutlineInputBorder(),
                        hintText: 'Otomatik hesaplanır',
                        helperText: 'Saatlik mesai ücreti × mesai saati',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        setState(() {});
                      },
                      onEditingComplete: () {
                        setState(() {
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        setState(() {
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (Opsiyonel)',
                        border: OutlineInputBorder(),
                        hintText: 'Kesme nedeni...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Önce isDisposed flag'ini set et
                  isDisposed = true;
                  // Listener'ları kaldır
                  hoursController.removeListener(updateAmount);
                  multiplierController.removeListener(multiplierListener);
                  hourlyOvertimeRateController
                      .removeListener(hourlyOvertimeRateListener);
                  // Dialog'u önce kapat (Flutter otomatik olarak focus'u temizler)
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  // Controller'ları dispose et (dialog kapandıktan sonra)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    hoursController.dispose();
                    multiplierController.dispose();
                    hourlyOvertimeRateController.dispose();
                    amountController.dispose();
                    dateController.dispose();
                    noteController.dispose();
                  });
                },
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  final hours = double.tryParse(
                    hoursController.text.replaceAll(',', '.'),
                  );
                  if (hours == null || hours <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir mesai saati girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final multiplier = double.tryParse(
                    multiplierController.text.replaceAll(',', '.'),
                  );
                  if (multiplier == null || multiplier <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir çarpan girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final hourlyOvertimeRate = double.tryParse(
                    hourlyOvertimeRateController.text.replaceAll(',', '.'),
                  );
                  if (hourlyOvertimeRate == null || hourlyOvertimeRate <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Lütfen geçerli bir saatlik mesai ücreti girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final overtimeAmount = double.tryParse(
                    amountController.text.replaceAll(',', '.'),
                  );
                  if (overtimeAmount == null || overtimeAmount <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir tutar girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final col = (tenantId != null && tenantId!.isNotEmpty)
                        ? FirebaseFirestore.instance
                            .collection('tenants')
                            .doc(tenantId)
                            .collection('employee_transactions')
                        : FirebaseFirestore.instance
                            .collection('employee_transactions');

                    await col.add({
                      'employeeId': docId,
                      'amount': overtimeAmount,
                      'direction': 'out',
                      'type': 'overtime_deduction',
                      'note': noteController.text.trim().isEmpty
                          ? 'Mesaiden kesme: $hours saat (x$multiplier)'
                          : 'Mesaiden kesme: $hours saat (x$multiplier) - ${noteController.text.trim()}',
                      'overtimeHours': hours,
                      'overtimeMultiplier': multiplier,
                      'hourlyOvertimeRate': hourlyOvertimeRate,
                      'date': Timestamp.fromDate(selectedDate!),
                      'currency': salaryCurrency,
                      'tenantId': tenantId,
                      'createdBy': FirebaseAuth.instance.currentUser?.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    // Önce isDisposed flag'ini set et
                    isDisposed = true;
                    // Listener'ları kaldır
                    hoursController.removeListener(updateAmount);
                    multiplierController.removeListener(multiplierListener);
                    hourlyOvertimeRateController
                        .removeListener(hourlyOvertimeRateListener);
                    // Dialog'u önce kapat (Flutter otomatik olarak focus'u temizler)
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                    // Controller'ları dispose et ve SnackBar'ı göster (dialog kapandıktan sonra)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      hoursController.dispose();
                      multiplierController.dispose();
                      hourlyOvertimeRateController.dispose();
                      amountController.dispose();
                      dateController.dispose();
                      noteController.dispose();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$hours saat mesai kesildi (${overtimeAmount.toStringAsFixed(2)} $salaryCurrency)',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    });
                  } catch (e) {
                    if (!isDisposed && ctx.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Mesaiden Kes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleAdvancePaymentAction(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    final salary =
        (data['salary'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final salaryCurrency = salary['currency']?.toString() ?? 'TRY';

    _showAddPaymentDialog(context, name, salaryCurrency);
  }

  // Kur bilgisini otomatik getir
  Future<void> _fetchExchangeRate(
    String fromCurrency,
    String toCurrency,
    TextEditingController controller,
    StateSetter setState,
    Function(double?) onRateFetched,
  ) async {
    try {
      final exchangeRateService = ExchangeRateService();

      // Her iki para biriminin TRY karşılığını al
      final fromRate = await exchangeRateService.getExchangeRate(fromCurrency);
      final toRate = await exchangeRateService.getExchangeRate(toCurrency);

      if (fromRate != null && toRate != null && toRate.rate > 0) {
        // Kur hesaplama: 1 fromCurrency = ? toCurrency
        // Örnek: 1 GBP = ? USD
        // GBP/TRY = 45, USD/TRY = 34
        // Kur = 45 / 34 = 1.32 (1 GBP = 1.32 USD)
        final calculatedRate = fromRate.rate / toRate.rate;

        setState(() {
          onRateFetched(calculatedRate);
          // Türkçe formatla (virgül ile)
          final formattedRate =
              calculatedRate.toStringAsFixed(6).replaceAll('.', ',');
          controller.text = formattedRate;
        });
      } else {
        // Kur bulunamadıysa boş bırak
        setState(() {
          onRateFetched(null);
          controller.clear();
        });
      }
    } catch (e) {
      // Hata durumunda boş bırak, kullanıcı manuel girebilir
      setState(() {
        onRateFetched(null);
        controller.clear();
      });
    }
  }

  // Türkçe sayı formatı yardımcısı
  String _formatNumberTr(double value, {int decimalDigits = 2}) {
    final decimalPart =
        decimalDigits > 0 ? '.${List.filled(decimalDigits, '0').join()}' : '';
    final formatter = NumberFormat('#,##0$decimalPart', 'tr_TR');
    return formatter.format(value);
  }

  double? _parseAmountText(String text) {
    if (text.trim().isEmpty) return null;
    String sanitized = text.replaceAll(' ', '');
    sanitized = sanitized.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (sanitized.isEmpty) return null;

    final formatter = NumberFormat.decimalPattern('tr_TR');
    double? parsed;
    try {
      parsed = formatter.parse(sanitized).toDouble();
    } catch (_) {}

    if (parsed == null && sanitized.contains('.')) {
      try {
        parsed = formatter.parse(sanitized.replaceAll('.', ',')).toDouble();
      } catch (_) {}
    }

    if (parsed == null) {
      final fallback = sanitized.replaceAll('.', '').replaceAll(',', '.');
      parsed = double.tryParse(fallback);
    }

    return parsed;
  }

  // Tutar alanını Türkçe formata çevir
  void _formatAmountField(TextEditingController controller) {
    final value = _parseAmountText(controller.text);
    if (value == null) return;

    final formatted = _formatNumberTr(value);
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _showAddPaymentDialog(
    BuildContext context,
    String name,
    String currency,
  ) async {
    // Önce kasaları çek - accounts collection'ından
    final accountsCol = (tenantId != null && tenantId!.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('accounts')
        : FirebaseFirestore.instance.collection('accounts');

    try {
      final accountsSnapshot =
          await accountsCol.where('isActive', isEqualTo: true).get();

      // Sadece Nakit ve Banka (checking/savings) kasalarını filtrele
      final availableAccounts = accountsSnapshot.docs.where((doc) {
        final data = doc.data();
        final type = data['type'] as String?;
        // Nakit veya Banka (checking, savings) hesapları
        return type == 'cash' || type == 'checking' || type == 'savings';
      }).map((doc) {
        final data = doc.data();
        final type = data['type'] as String?;
        String typeLabel = 'Diğer';
        if (type == 'cash') {
          typeLabel = 'Nakit';
        } else if (type == 'checking' || type == 'savings') {
          typeLabel = 'Banka';
        }
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? '',
          'type': type ?? '',
          'typeLabel': typeLabel,
          'balance': (data['balance'] as num?)?.toDouble() ?? 0.0,
          'currency': data['currency'] as String? ?? 'TRY',
        };
      }).toList();

      if (availableAccounts.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Aktif Nakit veya Banka hesabı bulunamadı. Lütfen önce hesap ekleyin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (!context.mounted) return;

      final amountController = TextEditingController();
      final exchangeRateController = TextEditingController();
      final noteController = TextEditingController();
      final now = DateTime.now();
      final dateController = TextEditingController(
        text:
            '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}',
      );
      DateTime selectedDate = now;
      String? selectedAccountId = availableAccounts.first['id'] as String;
      String selectedAccountCurrency =
          availableAccounts.first['currency'] as String;
      bool needsExchangeRate = selectedAccountCurrency != currency;
      double? exchangeRate;
      bool isDialogDisposed = false;

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (dialogContext, setState) {
          // İlk yüklemede kur bilgisini otomatik getir
          if (needsExchangeRate && exchangeRate == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchExchangeRate(
                selectedAccountCurrency,
                currency,
                exchangeRateController,
                setState,
                (rate) {
                  exchangeRate = rate;
                },
              );
            });
          }
          return AlertDialog(
            title: const Text('Ödeme Ekle'),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('$name için ödeme ekle'),
                    const SizedBox(height: 16),
                    // Kasa seçimi - StreamBuilder ile güncel bakiye gösterimi
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: selectedAccountId != null
                          ? accountsCol.doc(selectedAccountId).snapshots()
                          : null,
                      builder: (context, snapshot) {
                        double currentBalance = 0.0;
                        String accountCurrency = 'TRY';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final accountData = snapshot.data!.data()!;
                          currentBalance =
                              (accountData['balance'] as num?)?.toDouble() ??
                                  0.0;
                          accountCurrency =
                              accountData['currency'] as String? ?? 'TRY';
                        } else {
                          // İlk yükleme için availableAccounts'tan al
                          final selectedAccount = availableAccounts.firstWhere(
                            (acc) => acc['id'] == selectedAccountId,
                            orElse: () => availableAccounts.first,
                          );
                          currentBalance = selectedAccount['balance'] as double;
                          accountCurrency =
                              selectedAccount['currency'] as String;
                        }

                        // Format balance in Turkish format
                        String formatBalance(double amount) {
                          final parts =
                              amount.abs().toStringAsFixed(2).split('.');
                          final intPart = parts[0];
                          final decPart = parts[1];
                          final formattedInt = intPart.replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]}.',
                          );
                          return '$formattedInt,$decPart';
                        }

                        final formattedBalance = formatBalance(currentBalance);

                        return DropdownButtonFormField<String>(
                          initialValue: selectedAccountId,
                          decoration: InputDecoration(
                            labelText: 'Kasa *',
                            border: const OutlineInputBorder(),
                            helperText: snapshot.hasData
                                ? 'Bakiye: $formattedBalance $accountCurrency'
                                : 'Nakit veya Banka hesabı seçin',
                            isDense: true,
                          ),
                          isExpanded: true,
                          items: availableAccounts.map((account) {
                            final accountName = account['name'] as String;
                            final typeLabel = account['typeLabel'] as String;
                            return DropdownMenuItem<String>(
                              value: account['id'] as String,
                              child: Text(
                                '$accountName ($typeLabel)',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return availableAccounts.map((account) {
                              final accountName = account['name'] as String;
                              final typeLabel = account['typeLabel'] as String;
                              return Text(
                                '$accountName ($typeLabel)',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            }).toList();
                          },
                          onChanged: (value) async {
                            setState(() {
                              selectedAccountId = value;
                              // Seçilen hesabın para birimini al
                              final selectedAccount =
                                  availableAccounts.firstWhere(
                                (acc) => acc['id'] == value,
                              );
                              selectedAccountCurrency =
                                  selectedAccount['currency'] as String;
                              needsExchangeRate =
                                  selectedAccountCurrency != currency;
                              if (!needsExchangeRate) {
                                exchangeRate = null;
                                exchangeRateController.clear();
                              } else {
                                // Kur bilgisini otomatik getir
                                _fetchExchangeRate(
                                  selectedAccountCurrency,
                                  currency,
                                  exchangeRateController,
                                  setState,
                                  (rate) {
                                    exchangeRate = rate;
                                  },
                                );
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kasa seçimi zorunludur';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Tarih seçici
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text =
                                '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          dateController.text.isEmpty
                              ? 'Tarih seçin'
                              : dateController.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Kur girişi (farklı para birimi varsa)
                    if (needsExchangeRate) ...[
                      TextFormField(
                        controller: exchangeRateController,
                        decoration: InputDecoration(
                          labelText:
                              'Kur (1 $selectedAccountCurrency = ? $currency) *',
                          border: const OutlineInputBorder(),
                          hintText: 'Örn: 34,50',
                          helperText:
                              'Kasa para birimi ($selectedAccountCurrency) ile personel para birimi ($currency) farklı',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+([,.]\d{0,6})?$')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            final rateText =
                                value.replaceAll('.', '').replaceAll(',', '.');
                            exchangeRate = double.tryParse(rateText);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Tutar
                    Builder(
                      builder: (context) {
                        // Hesap para birimi karşılığını hesapla
                        String? accountCurrencyEquivalent;
                        final parsedAmount =
                            _parseAmountText(amountController.text);
                        if (parsedAmount != null && parsedAmount > 0) {
                          if (needsExchangeRate &&
                              exchangeRate != null &&
                              exchangeRate! > 0) {
                            final accountAmount = parsedAmount / exchangeRate!;
                            accountCurrencyEquivalent =
                                '${_formatNumberTr(accountAmount)} $selectedAccountCurrency';
                          } else if (selectedAccountCurrency == currency) {
                            accountCurrencyEquivalent =
                                '${_formatNumberTr(parsedAmount)} $selectedAccountCurrency';
                          }
                        }

                        return Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus && !isDialogDisposed) {
                              // Focus kaybedildiğinde formatla
                              try {
                                setState(() {
                                  _formatAmountField(amountController);
                                });
                              } catch (e) {
                                // Dialog kapatıldıysa hata yok sayılır
                              }
                            }
                          },
                          child: TextFormField(
                            controller: amountController,
                            decoration: InputDecoration(
                              labelText: 'Tutar ($currency)',
                              border: const OutlineInputBorder(),
                              hintText: 'Örn: 10000,00',
                              helperText: accountCurrencyEquivalent,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]')),
                            ],
                            onChanged: (value) {
                              // Tutar değiştiğinde hesap para birimi karşılığını güncelle
                              if (!isDialogDisposed) {
                                try {
                                  setState(() {});
                                } catch (e) {
                                  // Dialog kapatıldıysa hata yok sayılır
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Not
                    TextFormField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Not (Opsiyonel)',
                        border: OutlineInputBorder(),
                        hintText: 'Ödeme açıklaması...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  isDialogDisposed = true;
                  amountController.dispose();
                  exchangeRateController.dispose();
                  noteController.dispose();
                  dateController.dispose();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  if (selectedAccountId == null || selectedAccountId!.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen bir kasa seçin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Kur kontrolü (farklı para birimi varsa)
                  if (needsExchangeRate &&
                      (exchangeRate == null || exchangeRate! <= 0)) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir kur girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final amountText = amountController.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.');
                  final amount = double.tryParse(amountText) ?? 0;
                  final note = noteController.text.trim();

                  if (amount <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Tutar 0\'dan büyük olmalıdır'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    // Önce account bilgisini al (balance güncellemesi için)
                    final accountDoc =
                        await accountsCol.doc(selectedAccountId).get();
                    if (!accountDoc.exists) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Seçilen hesap bulunamadı'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final accountData =
                        accountDoc.data() as Map<String, dynamic>;
                    final accountCurrency =
                        accountData['currency'] as String? ?? 'TRY';
                    final currentBalance =
                        (accountData['balance'] as num?)?.toDouble() ?? 0.0;
                    final blockedAmount =
                        (accountData['blockedAmount'] as num?)?.toDouble() ??
                            0.0;

                    // Tutarı kasa para birimine çevir (eğer farklıysa)
                    double amountInAccountCurrency = amount;
                    if (accountCurrency != currency &&
                        exchangeRate != null &&
                        exchangeRate! > 0) {
                      amountInAccountCurrency = amount / exchangeRate!;
                    }

                    final newBalance = currentBalance -
                        amountInAccountCurrency; // Ödeme çıkış olduğu için balance'dan düş
                    final newAvailableBalance = newBalance - blockedAmount;

                    // Batch işlem: hem employee_transaction hem account_transaction ekle, account balance güncelle
                    final batch = FirebaseFirestore.instance.batch();

                    // 1. Employee transaction ekle
                    final employeeTransactionsCol =
                        (tenantId != null && tenantId!.isNotEmpty)
                            ? FirebaseFirestore.instance
                                .collection('tenants')
                                .doc(tenantId)
                                .collection('employee_transactions')
                            : FirebaseFirestore.instance
                                .collection('employee_transactions');

                    final employeeTransactionRef =
                        employeeTransactionsCol.doc();
                    batch.set(employeeTransactionRef, {
                      'employeeId': docId,
                      'amount': amount,
                      'direction': 'out',
                      'type': 'payment',
                      'note': note.isEmpty ? 'Ödeme' : note,
                      'date': Timestamp.fromDate(selectedDate),
                      'currency': currency,
                      'accountId': selectedAccountId,
                      'tenantId': tenantId,
                      'createdBy': FirebaseAuth.instance.currentUser?.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    // 2. Account transaction ekle (kasa hareketi)
                    final accountTransactionsCol =
                        (tenantId != null && tenantId!.isNotEmpty)
                            ? FirebaseFirestore.instance
                                .collection('tenants')
                                .doc(tenantId)
                                .collection('accountTransactions')
                            : FirebaseFirestore.instance
                                .collection('accountTransactions');

                    final accountTransactionRef = accountTransactionsCol.doc();
                    final exchangeRateNote = needsExchangeRate &&
                            exchangeRate != null
                        ? ' (Kur: $exchangeRate, $amount $currency = ${amountInAccountCurrency.toStringAsFixed(2)} $accountCurrency)'
                        : '';
                    batch.set(accountTransactionRef, {
                      'accountId': selectedAccountId,
                      'type': 'withdrawal', // Para çıkışı
                      'category': 'expense', // Gider
                      'amount':
                          amountInAccountCurrency, // Kasa para biriminde tutar
                      'debitAmount': amountInAccountCurrency, // Borç (çıkış)
                      'creditAmount': null,
                      'balanceAfter': newBalance,
                      'description':
                          '$name - Personel Ödemesi$exchangeRateNote',
                      'notes': note.isEmpty ? null : note,
                      'transactionDate': Timestamp.fromDate(selectedDate),
                      'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
                      'isReconciled': false,
                      'tenantId': tenantId,
                      'createdBy': FirebaseAuth.instance.currentUser?.uid,
                      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    // 3. Account balance güncelle
                    final accountRef = accountsCol.doc(selectedAccountId);
                    batch.update(accountRef, {
                      'balance': newBalance,
                      'availableBalance': newAvailableBalance,
                      'updatedAt': FieldValue.serverTimestamp(),
                      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
                    });

                    // Batch'i commit et
                    await batch.commit();

                    if (ctx.mounted) {
                      isDialogDisposed = true;
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ödeme eklendi (${amount.toStringAsFixed(2)} $currency)',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }

                    amountController.dispose();
                    exchangeRateController.dispose();
                    noteController.dispose();
                    dateController.dispose();
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Ekle'),
              ),
            ],
          );
        }),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kasa bilgileri alınırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleEntitlementAction(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    final salary =
        (data['salary'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final salaryCurrency = salary['currency']?.toString() ?? 'TRY';
    final autoEntitlementEnabled =
        data['autoEntitlementEnabled'] as bool? ?? true;

    _showAddEntitlementDialog(
        context, name, salaryCurrency, autoEntitlementEnabled);
  }

  void _showAddEntitlementDialog(
    BuildContext context,
    String name,
    String currency,
    bool currentAutoEntitlementEnabled,
  ) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final now = DateTime.now();
    final dateController = TextEditingController(
      text:
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}',
    );
    DateTime selectedDate = now;
    bool autoEntitlementEnabled = currentAutoEntitlementEnabled;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Manuel Hak Ediş Ekle'),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('$name için manuel hak ediş ekle'),
                  const SizedBox(height: 16),
                  // Otomatik hak ediş açma/kapama
                  Card(
                    color: Colors.grey[50],
                    child: SwitchListTile(
                      title: const Text('Otomatik Hak Ediş'),
                      subtitle: const Text(
                        'Otomatik hak ediş oluşturmayı aç/kapat',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: autoEntitlementEnabled,
                      onChanged: (value) {
                        setState(() {
                          autoEntitlementEnabled = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tarih seçici
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        locale: const Locale('tr', 'TR'),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                          dateController.text =
                              '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tarih',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        dateController.text.isEmpty
                            ? 'Tarih seçin'
                            : dateController.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tutar
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Tutar ($currency)',
                      border: const OutlineInputBorder(),
                      hintText: 'Örn: 10000,00',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+([,.]\d{0,2})?$')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Not
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Not (Opsiyonel)',
                      border: OutlineInputBorder(),
                      hintText: 'Hak ediş açıklaması...',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                amountController.dispose();
                noteController.dispose();
                dateController.dispose();
                Navigator.of(ctx).pop();
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () async {
                final amountText = amountController.text
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                final amount = double.tryParse(amountText) ?? 0;
                final note = noteController.text.trim();

                if (amount <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Tutar 0\'dan büyük olmalıdır'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Önce employee document'ini güncelle (otomatik hak ediş ayarı)
                  final employeesCol =
                      (tenantId != null && tenantId!.isNotEmpty)
                          ? FirebaseFirestore.instance
                              .collection('tenants')
                              .doc(tenantId)
                              .collection('employees')
                          : FirebaseFirestore.instance.collection('employees');

                  await employeesCol.doc(docId).update({
                    'autoEntitlementEnabled': autoEntitlementEnabled,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  // Sonra transaction'ı ekle
                  final transactionsCol = (tenantId != null &&
                          tenantId!.isNotEmpty)
                      ? FirebaseFirestore.instance
                          .collection('tenants')
                          .doc(tenantId)
                          .collection('employee_transactions')
                      : FirebaseFirestore.instance
                          .collection('employee_transactions');

                  await transactionsCol.add({
                    'employeeId': docId,
                    'amount': amount,
                    'direction': 'in',
                    'type': 'entitlement',
                    'note': note.isEmpty ? 'Manuel hak ediş' : note,
                    'date': Timestamp.fromDate(selectedDate),
                    'currency': currency,
                    'tenantId': tenantId,
                    'createdBy': FirebaseAuth.instance.currentUser?.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Hak ediş eklendi (${amount.toStringAsFixed(2)} $currency)${autoEntitlementEnabled ? '' : '\nOtomatik hak ediş kapatıldı'}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }

                  amountController.dispose();
                  noteController.dispose();
                  dateController.dispose();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentsDialog(BuildContext context, {required List docs}) {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: (tenantId != null && tenantId!.isNotEmpty)
            ? FirebaseFirestore.instance
                .collection('tenants')
                .doc(tenantId)
                .collection('employees')
                .doc(docId)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('employees')
                .doc(docId)
                .snapshots(),
        builder: (streamContext, snapshot) {
          if (!streamContext.mounted) {
            return const SizedBox.shrink();
          }
          List<dynamic> currentDocs = docs;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            currentDocs = data['documents'] as List? ?? [];
          }

          return StatefulBuilder(
            builder: (stateContext, setState) => AlertDialog(
              title: Text('Dökümanlar (${currentDocs.length})'),
              content: SizedBox(
                width: 500,
                child: currentDocs.isEmpty
                    ? const Text('Döküman bulunmamaktadır.')
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: currentDocs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final raw = currentDocs[i];
                          final m = raw is Map ? raw : <String, dynamic>{};
                          final fileName = m['name']?.toString() ?? 'dosya';
                          final url = m['url']?.toString();
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.download),
                            title: Text(
                              fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () async {
                                    await _renameDocument(
                                      stateContext,
                                      i,
                                      fileName,
                                      setState,
                                    );
                                  },
                                  tooltip: 'Yeniden Adlandır',
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: url == null
                                ? null
                                : () => _downloadDocument(
                                    dialogContext, url, fileName),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _renameDocument(BuildContext context, int index,
      String currentName, StateSetter setState) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dökümanı Yeniden Adlandır'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Yeni Ad',
            hintText: 'Döküman adını girin',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      final newName = controller.text.trim();
      try {
        final employeesCol = (tenantId != null && tenantId!.isNotEmpty)
            ? FirebaseFirestore.instance
                .collection('tenants')
                .doc(tenantId)
                .collection('employees')
            : FirebaseFirestore.instance.collection('employees');

        final doc = await employeesCol.doc(docId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final documents =
              List<Map<String, dynamic>>.from(data['documents'] as List? ?? []);
          if (index < documents.length) {
            documents[index]['name'] = newName;
            await employeesCol.doc(docId).update({
              'documents': documents,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            // Trigger rebuild to show updated name
            setState(() {});

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Döküman adı güncellendi'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    controller.dispose();
  }

  void _showEmployeeDetailsDialog(
    BuildContext context, {
    required String name,
    required String position,
    required String salary,
    required String entitlementType,
    required Map entitlement,
    required String startDate,
    required String birthDate,
    required String tc,
    required String email,
    Map? workHours,
    Map? overtime,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$name - Detaylı Bilgiler'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoTile(label: 'Pozisyon', value: position),
                    _InfoTile(label: 'Maaş', value: salary),
                    _InfoTile(label: 'Hak Ediş', value: entitlementType),
                    _InfoTile(label: 'İşe Başlama', value: startDate),
                    _InfoTile(label: 'Doğum Tarihi', value: birthDate),
                    _InfoTile(label: 'TC', value: tc),
                    _InfoTile(label: 'E-posta', value: email),
                    // Entitlement details based on type
                    Builder(
                      builder: (context) {
                        if (entitlementType == 'Aylık' &&
                            entitlement['monthlyDayOfMonth'] != null) {
                          final monthlyDay =
                              entitlement['monthlyDayOfMonth'] as int?;
                          // Geçersiz değerleri düzelt (1-31 arasında olmalı)
                          if (monthlyDay != null &&
                              monthlyDay >= 1 &&
                              monthlyDay <= 31) {
                            return _InfoTile(
                              label: 'Ödeme Günü',
                              value: 'Ayın $monthlyDay. günü',
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    if (entitlementType == 'Aylık (İki Kere)' &&
                        entitlement['semiMonthlyDays'] != null)
                      Builder(builder: (context) {
                        final days = entitlement['semiMonthlyDays'] as List?;
                        if (days != null && days.length >= 2) {
                          return _InfoTile(
                            label: 'Ödeme Günleri',
                            value: 'Ayın ${days[0]}. ve ${days[1]}. günü',
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    if (entitlementType == 'Haftalık' &&
                        entitlement['weeklyWeekday'] != null)
                      _InfoTile(
                        label: 'Ödeme Günü',
                        value: entitlement['weeklyWeekday'].toString(),
                      ),
                    if (entitlementType == 'Günlük') ...[
                      if (entitlement['daysPerWeek'] != null)
                        _InfoTile(
                          label: 'Haftada Çalışma Günü',
                          value: '${entitlement['daysPerWeek']} gün',
                        ),
                      if (entitlement['weeklyDays'] != null)
                        Builder(builder: (context) {
                          final weeklyDays = entitlement['weeklyDays'] as List?;
                          if (weeklyDays != null && weeklyDays.isNotEmpty) {
                            return _InfoTile(
                              label: 'Çalışma Günleri',
                              value: weeklyDays.join(', '),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                    ],
                  ],
                ),
                if (workHours != null && workHours.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Çalışma Saatleri',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workHours.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final day = workHours.keys.elementAt(index);
                      final v = (workHours[day] as Map?) ?? const {};
                      final start = v['start']?.toString() ?? '';
                      final end = v['end']?.toString() ?? '';
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.schedule),
                        title: Text('$day: $start - $end'),
                      );
                    },
                  ),
                ],
                if (overtime != null && (overtime['enabled'] == true)) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Fazla Mesai',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _InfoTile(
                        label: 'Durum',
                        value:
                            (overtime['enabled'] == true) ? 'Açık' : 'Kapalı',
                      ),
                      if (overtime['thresholdHoursPerDay'] != null)
                        _InfoTile(
                          label: 'Günlük Eşik (saat)',
                          value: overtime['thresholdHoursPerDay'].toString(),
                        ),
                      if (overtime['multiplier'] != null)
                        _InfoTile(
                          label: 'Çarpan',
                          value: overtime['multiplier'].toString(),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showEmployeeActionDialog(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    final isActive = data['isActive'] as bool? ?? true;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$name - İşlemler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (isActive) {
                  _showTerminationDialog(context);
                } else {
                  _showTerminationCancelDialog(context);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: isActive ? Colors.orange : Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: Icon(isActive ? Icons.logout : Icons.undo),
              label: Text(isActive ? 'İş Çıkışı Ver' : 'İş Çıkışını İptal Et'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showDeleteConfirmationDialog(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Personeli Sil'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _showTerminationDialog(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    final selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());

    showDialog(
      context: context,
      builder: (ctx) => ValueListenableBuilder<DateTime>(
        valueListenable: selectedDateNotifier,
        builder: (dialogContext, selectedDate, _) {
          return AlertDialog(
            title: const Text('İş Çıkışı'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name için iş çıkışı vermek istediğinize emin misiniz?'),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('tr', 'TR'),
                    );
                    if (picked != null) {
                      selectedDateNotifier.value = picked;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'İş Çıkış Tarihi',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  selectedDateNotifier.dispose();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    final col = (tenantId != null && tenantId!.isNotEmpty)
                        ? FirebaseFirestore.instance
                            .collection('tenants')
                            .doc(tenantId)
                            .collection('employees')
                        : FirebaseFirestore.instance.collection('employees');

                    final terminationTimestamp =
                        Timestamp.fromDate(selectedDate);

                    await col.doc(docId).update({
                      'isActive': false,
                      'terminationDate': terminationTimestamp,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    selectedDateNotifier.dispose();
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(); // Ana dialog'u da kapat
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('İş çıkışı verildi'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    selectedDateNotifier.dispose();
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('İş Çıkışı Ver'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTerminationCancelDialog(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İş Çıkışını İptal Et'),
        content: Text(
          '$name için iş çıkışını iptal etmek istediğinize emin misiniz? Personel tekrar aktif hale gelecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final col = (tenantId != null && tenantId!.isNotEmpty)
                    ? FirebaseFirestore.instance
                        .collection('tenants')
                        .doc(tenantId)
                        .collection('employees')
                    : FirebaseFirestore.instance.collection('employees');

                await col.doc(docId).update({
                  'isActive': true,
                  'terminationDate': FieldValue.delete(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // Ana dialog'u da kapat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('İş çıkışı iptal edildi, personel tekrar aktif'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('İş Çıkışını İptal Et'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final name = data['name'] as String? ?? 'Personel';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Personeli Sil'),
        content: Text(
          '"$name" adlı personeli silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final col = (tenantId != null && tenantId!.isNotEmpty)
                    ? FirebaseFirestore.instance
                        .collection('tenants')
                        .doc(tenantId)
                        .collection('employees')
                    : FirebaseFirestore.instance.collection('employees');

                await col.doc(docId).delete();

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // Ana dialog'u da kapat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Personel silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context) {
    // Mevcut verileri al
    final nameCtrl = TextEditingController(text: data['name'] as String? ?? '');
    final tcCtrl = TextEditingController(text: data['tc']?.toString() ?? '');
    final emailCtrl =
        TextEditingController(text: data['email']?.toString() ?? '');
    final posCtrl =
        TextEditingController(text: data['position'] as String? ?? '');
    final deptCtrl =
        TextEditingController(text: data['department'] as String? ?? '');
    final catCtrl =
        TextEditingController(text: data['category'] as String? ?? '');
    final salary = (data['salary'] as Map?) ?? {};
    final salAmtCtrl =
        TextEditingController(text: (salary['amount']?.toString()) ?? '');
    final salCurCtrl =
        TextEditingController(text: (salary['currency']?.toString()) ?? 'TRY');

    // Tarihleri al
    final startTs = data['startDate'];
    final birthTs = data['birthDate'];
    DateTime? startDate;
    DateTime? birthDate;
    if (startTs is Timestamp) {
      startDate = startTs.toDate();
    } else if (startTs is DateTime) {
      startDate = startTs;
    }
    if (birthTs is Timestamp) {
      birthDate = birthTs.toDate();
    } else if (birthTs is DateTime) {
      birthDate = birthTs;
    }

    // Entitlement bilgilerini al
    final entitlement = (data['entitlement'] as Map?) ?? {};
    final entitlementType = entitlement['type']?.toString() ?? 'Aylık';
    final monthlyDayOfMonth = entitlement['monthlyDayOfMonth'] as int?;
    final semiMonthlyDay1 = entitlement['semiMonthlyDay1'] as int?;
    final semiMonthlyDay2 = entitlement['semiMonthlyDay2'] as int?;
    final weeklyWeekday = entitlement['weeklyWeekday'] as String?;
    final daysPerWeek = entitlement['daysPerWeek'] as int? ?? 5;
    final weeklySelectedDays = (entitlement['weeklyDays'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final monthlyDaysPerWeek = entitlement['monthlyDaysPerWeek'] as int? ?? 5;
    final monthlyHoursPerDay = entitlement['monthlyHoursPerDay'] as int? ?? 8;
    final semiMonthlyAmounts =
        entitlement['semiMonthlyAmounts'] as Map<String, dynamic>?;

    // Schedule bilgilerini al (şimdilik kullanılmıyor, gelecekte eklenebilir)
    // final schedule = (data['schedule'] as Map?) ?? {};
    // final workHours = (schedule['workHours'] as Map?) ?? {};
    // final overtime = (schedule['overtime'] as Map?) ?? {};
    final autoEntitlementEnabled =
        data['autoEntitlementEnabled'] as bool? ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          // Tarih controller'ları
          final startDateCtrl = TextEditingController(
            text: startDate != null
                ? '${startDate.day.toString().padLeft(2, '0')}.${startDate.month.toString().padLeft(2, '0')}.${startDate.year}'
                : '',
          );
          final birthDateCtrl = TextEditingController(
            text: birthDate != null
                ? '${birthDate.day.toString().padLeft(2, '0')}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}'
                : '',
          );

          DateTime? selectedStartDate = startDate;
          DateTime? selectedBirthDate = birthDate;
          String selectedEntitlementType = entitlementType;
          int? selectedMonthlyDayOfMonth = monthlyDayOfMonth;
          int? selectedSemiMonthlyDay1 = semiMonthlyDay1;
          int? selectedSemiMonthlyDay2 = semiMonthlyDay2;
          String? selectedWeeklyWeekday = weeklyWeekday;
          int selectedDaysPerWeek = daysPerWeek;
          List<String> selectedWeeklyDays = List.from(weeklySelectedDays);
          int selectedMonthlyDaysPerWeek = monthlyDaysPerWeek;
          int selectedMonthlyHoursPerDay = monthlyHoursPerDay;
          bool selectedAutoEntitlementEnabled = autoEntitlementEnabled;

          // Aylık (İki Kere) için tutar controller'ları
          final semiMonthlyAmount1Ctrl = TextEditingController(
            text: semiMonthlyAmounts != null &&
                    semiMonthlyAmounts[semiMonthlyDay1.toString()] != null
                ? (semiMonthlyAmounts[semiMonthlyDay1.toString()] as num)
                    .toString()
                : '',
          );
          final semiMonthlyAmount2Ctrl = TextEditingController(
            text: semiMonthlyAmounts != null &&
                    semiMonthlyAmounts[semiMonthlyDay2.toString()] != null
                ? (semiMonthlyAmounts[semiMonthlyDay2.toString()] as num)
                    .toString()
                : '',
          );

          return AlertDialog(
            title: const Text('Personel Düzenle'),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Temel Bilgiler
                    Text(
                      'Temel Bilgiler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tcCtrl,
                      decoration: const InputDecoration(
                        labelText: 'TC Kimlik No',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Tarihler
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate:
                                    selectedStartDate ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                                locale: const Locale('tr', 'TR'),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedStartDate = picked;
                                  startDateCtrl.text =
                                      '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'İşe Başlama Tarihi',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                startDateCtrl.text.isEmpty
                                    ? 'Tarih seçin'
                                    : startDateCtrl.text,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate:
                                    selectedBirthDate ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                locale: const Locale('tr', 'TR'),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedBirthDate = picked;
                                  birthDateCtrl.text =
                                      '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Doğum Tarihi',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                birthDateCtrl.text.isEmpty
                                    ? 'Tarih seçin'
                                    : birthDateCtrl.text,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // İş Bilgileri
                    Text(
                      'İş Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: posCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Pozisyon',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: deptCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Departman',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: catCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Maaş Bilgileri
                    Text(
                      'Maaş Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: salAmtCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Maaş Tutarı',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: salCurCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Para Birimi',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Hak Ediş Bilgileri
                    Text(
                      'Hak Ediş Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedEntitlementType,
                      decoration: const InputDecoration(
                        labelText: 'Hak Ediş Türü',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Aylık', child: Text('Aylık')),
                        DropdownMenuItem(
                            value: 'Aylık (İki Kere)',
                            child: Text('Aylık (İki Kere)')),
                        DropdownMenuItem(
                            value: 'Haftalık', child: Text('Haftalık')),
                        DropdownMenuItem(
                            value: 'Günlük', child: Text('Günlük')),
                        DropdownMenuItem(
                            value: 'Saatlik', child: Text('Saatlik')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedEntitlementType = value ?? 'Aylık';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Hak Ediş türüne göre ek alanlar
                    if (selectedEntitlementType == 'Aylık') ...[
                      DropdownButtonFormField<int>(
                        initialValue: selectedMonthlyDayOfMonth,
                        decoration: const InputDecoration(
                          labelText: 'Ödeme Günü',
                          border: OutlineInputBorder(),
                          helperText: 'Ayın kaçıncı günü ödeme yapılacak?',
                        ),
                        items: List.generate(31, (index) => index + 1)
                            .map((day) => DropdownMenuItem(
                                  value: day,
                                  child: Text('Ayın $day. günü'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMonthlyDayOfMonth = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedMonthlyDaysPerWeek,
                              decoration: const InputDecoration(
                                labelText: 'Haftada Kaç Gün',
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(7, (index) => index + 1)
                                  .map((days) => DropdownMenuItem(
                                        value: days,
                                        child: Text('$days gün'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedMonthlyDaysPerWeek = value ?? 5;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedMonthlyHoursPerDay,
                              decoration: const InputDecoration(
                                labelText: 'Günde Kaç Saat',
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(12, (index) => index + 1)
                                  .map((hours) => DropdownMenuItem(
                                        value: hours,
                                        child: Text('$hours saat'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedMonthlyHoursPerDay = value ?? 8;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else if (selectedEntitlementType ==
                        'Aylık (İki Kere)') ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedSemiMonthlyDay1,
                              decoration: const InputDecoration(
                                labelText: '1. Ödeme Günü',
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(31, (index) => index + 1)
                                  .map((day) => DropdownMenuItem(
                                        value: day,
                                        child: Text('$day'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSemiMonthlyDay1 = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: semiMonthlyAmount1Ctrl,
                              decoration: const InputDecoration(
                                labelText: '1. Ödeme Tutarı',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedSemiMonthlyDay2,
                              decoration: const InputDecoration(
                                labelText: '2. Ödeme Günü',
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(31, (index) => index + 1)
                                  .map((day) => DropdownMenuItem(
                                        value: day,
                                        child: Text('$day'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSemiMonthlyDay2 = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: semiMonthlyAmount2Ctrl,
                              decoration: const InputDecoration(
                                labelText: '2. Ödeme Tutarı',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        ],
                      ),
                    ] else if (selectedEntitlementType == 'Haftalık') ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedWeeklyWeekday,
                        decoration: const InputDecoration(
                          labelText: 'Ödeme Günü',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Pazartesi', child: Text('Pazartesi')),
                          DropdownMenuItem(value: 'Salı', child: Text('Salı')),
                          DropdownMenuItem(
                              value: 'Çarşamba', child: Text('Çarşamba')),
                          DropdownMenuItem(
                              value: 'Perşembe', child: Text('Perşembe')),
                          DropdownMenuItem(value: 'Cuma', child: Text('Cuma')),
                          DropdownMenuItem(
                              value: 'Cumartesi', child: Text('Cumartesi')),
                          DropdownMenuItem(
                              value: 'Pazar', child: Text('Pazar')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedWeeklyWeekday = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue: selectedDaysPerWeek,
                        decoration: const InputDecoration(
                          labelText: 'Haftada Kaç Gün',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(7, (index) => index + 1)
                            .map((days) => DropdownMenuItem(
                                  value: days,
                                  child: Text('$days gün'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDaysPerWeek = value ?? 5;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Otomatik Hak Ediş
                    SwitchListTile(
                      title: const Text('Otomatik Hak Ediş'),
                      subtitle: const Text(
                          'Otomatik olarak hak ediş oluşturulsun mu?'),
                      value: selectedAutoEntitlementEnabled,
                      onChanged: (value) {
                        setState(() {
                          selectedAutoEntitlementEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  nameCtrl.dispose();
                  tcCtrl.dispose();
                  emailCtrl.dispose();
                  posCtrl.dispose();
                  deptCtrl.dispose();
                  catCtrl.dispose();
                  salAmtCtrl.dispose();
                  salCurCtrl.dispose();
                  startDateCtrl.dispose();
                  birthDateCtrl.dispose();
                  semiMonthlyAmount1Ctrl.dispose();
                  semiMonthlyAmount2Ctrl.dispose();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    final col = (tenantId != null &&
                            (tenantId?.isNotEmpty ?? false))
                        ? FirebaseFirestore.instance
                            .collection('tenants')
                            .doc(tenantId)
                            .collection('employees')
                        : FirebaseFirestore.instance.collection('employees');

                    // Entitlement map'ini oluştur
                    final Map<String, dynamic> entitlementMap = {
                      'type': selectedEntitlementType,
                    };

                    if (selectedEntitlementType == 'Aylık') {
                      if (selectedMonthlyDayOfMonth != null) {
                        entitlementMap['monthlyDayOfMonth'] =
                            selectedMonthlyDayOfMonth;
                      }
                      entitlementMap['monthlyDaysPerWeek'] =
                          selectedMonthlyDaysPerWeek;
                      entitlementMap['monthlyHoursPerDay'] =
                          selectedMonthlyHoursPerDay;
                    } else if (selectedEntitlementType == 'Aylık (İki Kere)') {
                      if (selectedSemiMonthlyDay1 != null) {
                        entitlementMap['semiMonthlyDay1'] =
                            selectedSemiMonthlyDay1;
                      }
                      if (selectedSemiMonthlyDay2 != null) {
                        entitlementMap['semiMonthlyDay2'] =
                            selectedSemiMonthlyDay2;
                      }
                      final amount1 = double.tryParse(semiMonthlyAmount1Ctrl
                              .text
                              .replaceAll(',', '.')) ??
                          0;
                      final amount2 = double.tryParse(semiMonthlyAmount2Ctrl
                              .text
                              .replaceAll(',', '.')) ??
                          0;
                      if (amount1 > 0 || amount2 > 0) {
                        entitlementMap['semiMonthlyAmounts'] = {
                          if (selectedSemiMonthlyDay1 != null)
                            selectedSemiMonthlyDay1.toString(): amount1,
                          if (selectedSemiMonthlyDay2 != null)
                            selectedSemiMonthlyDay2.toString(): amount2,
                        };
                      }
                    } else if (selectedEntitlementType == 'Haftalık') {
                      if (selectedWeeklyWeekday != null) {
                        entitlementMap['weeklyWeekday'] = selectedWeeklyWeekday;
                      }
                      entitlementMap['daysPerWeek'] = selectedDaysPerWeek;
                    } else if (selectedEntitlementType == 'Günlük') {
                      if (selectedWeeklyDays.isNotEmpty) {
                        entitlementMap['weeklyDays'] = selectedWeeklyDays;
                      }
                    }

                    // Update map'ini oluştur
                    final updateMap = <String, dynamic>{
                      'name': nameCtrl.text.trim(),
                      'tc': tcCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                      'position': posCtrl.text.trim(),
                      'department': deptCtrl.text.trim(),
                      'category': catCtrl.text.trim(),
                      'salary': {
                        'amount': double.tryParse(salAmtCtrl.text
                                .replaceAll('.', '')
                                .replaceAll(',', '.')) ??
                            0,
                        'currency': salCurCtrl.text.trim(),
                      },
                      'entitlement': entitlementMap,
                      'autoEntitlementEnabled': selectedAutoEntitlementEnabled,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    // Tarihleri ekle
                    if (selectedStartDate != null) {
                      updateMap['startDate'] =
                          Timestamp.fromDate(selectedStartDate!);
                    }
                    if (selectedBirthDate != null) {
                      updateMap['birthDate'] =
                          Timestamp.fromDate(selectedBirthDate!);
                    }

                    await col.doc(docId).update(updateMap);

                    nameCtrl.dispose();
                    tcCtrl.dispose();
                    emailCtrl.dispose();
                    posCtrl.dispose();
                    deptCtrl.dispose();
                    catCtrl.dispose();
                    salAmtCtrl.dispose();
                    salCurCtrl.dispose();
                    startDateCtrl.dispose();
                    birthDateCtrl.dispose();
                    semiMonthlyAmount1Ctrl.dispose();
                    semiMonthlyAmount2Ctrl.dispose();

                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Personel bilgileri güncellendi'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Colors.grey[700]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(999),
        color: Colors.grey[50],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: labelStyle),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmployeeBalance extends StatelessWidget {
  final String? tenantId;
  final String docId;
  final String currency;
  const _EmployeeBalance({
    required this.tenantId,
    required this.docId,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final query = (tenantId != null && tenantId!.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('employee_transactions')
            .where('employeeId', isEqualTo: docId)
        : FirebaseFirestore.instance
            .collection('employee_transactions')
            .where('employeeId', isEqualTo: docId);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Hata: ${snapshot.error}',
              style: const TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData) {
          return const SizedBox(
              width: 100, child: LinearProgressIndicator(minHeight: 4));
        }
        double balance = 0;
        for (final doc in snapshot.data!.docs) {
          final m = doc.data();
          final amount = (m['amount'] as num?)?.toDouble() ?? 0;
          final dir = (m['direction'] as String?) ?? 'out';
          balance += dir == 'in' ? amount : -amount;
        }

        // Format balance in Turkish format
        String formatBalance(double amount) {
          final parts = amount.abs().toStringAsFixed(2).split('.');
          final intPart = parts[0];
          final decPart = parts[1];
          final formattedInt = intPart.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
          final formatted = '$formattedInt,$decPart';
          return balance < 0 ? '-$formatted' : formatted;
        }

        final text = formatBalance(balance);
        final color = balance >= 0 ? Colors.green : Colors.red;
        return Row(children: [
          Text('Bakiye: ', style: Theme.of(context).textTheme.bodyMedium),
          Text('$text $currency',
              style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        ]);
      },
    );
  }
}

class _EmployeeBalanceCompact extends StatelessWidget {
  final String? tenantId;
  final String docId;
  final String currency;
  const _EmployeeBalanceCompact({
    required this.tenantId,
    required this.docId,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final query = (tenantId != null && tenantId!.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('employee_transactions')
            .where('employeeId', isEqualTo: docId)
        : FirebaseFirestore.instance
            .collection('employee_transactions')
            .where('employeeId', isEqualTo: docId);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        if (!snapshot.hasData) {
          return const SizedBox(
              width: 60,
              height: 12,
              child: LinearProgressIndicator(minHeight: 2));
        }
        double balance = 0;
        for (final doc in snapshot.data!.docs) {
          final m = doc.data();
          final amount = (m['amount'] as num?)?.toDouble() ?? 0;
          final dir = (m['direction'] as String?) ?? 'out';
          balance += dir == 'in' ? amount : -amount;
        }

        // Format balance in Turkish format
        String formatBalance(double amount) {
          final parts = amount.abs().toStringAsFixed(2).split('.');
          final intPart = parts[0];
          final decPart = parts[1];
          final formattedInt = intPart.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
          final formatted = '$formattedInt,$decPart';
          return balance < 0 ? '-$formatted' : formatted;
        }

        final text = formatBalance(balance);
        final color =
            balance >= 0 ? Colors.green.shade700 : Colors.red.shade700;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              'Bakiye: $text $currency',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmployeeTransactionsList extends StatelessWidget {
  final String? tenantId;
  final String docId;
  final String currency;
  final Function(
          BuildContext, String?, String, String, Map<String, dynamic>, String)?
      onEditOvertimeTransaction;
  final Function(
          BuildContext, String?, String, String, Map<String, dynamic>, String)?
      onEditPaymentTransaction;
  final Function(BuildContext, String?, String, Map<String, dynamic>)?
      onDeletePaymentTransaction;
  const _EmployeeTransactionsList({
    required this.tenantId,
    required this.docId,
    required this.currency,
    this.onEditOvertimeTransaction,
    this.onEditPaymentTransaction,
    this.onDeletePaymentTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final q = (tenantId != null && tenantId!.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('employee_transactions')
            .where('employeeId', isEqualTo: docId)
            .limit(10)
        : FirebaseFirestore.instance
            .collection('employee_transactions')
            .where('employeeId', isEqualTo: docId)
            .limit(10);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Text('Hata: ${snap.error}',
              style: const TextStyle(color: Colors.red));
        }
        if (!snap.hasData) {
          return const LinearProgressIndicator(minHeight: 2);
        }
        final docs = [...snap.data!.docs];
        docs.sort((a, b) {
          final ad = a.data()['date'];
          final bd = b.data()['date'];
          DateTime adt;
          DateTime bdt;
          try {
            adt = ad is Timestamp
                ? ad.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
          } catch (_) {
            adt = DateTime.fromMillisecondsSinceEpoch(0);
          }
          try {
            bdt = bd is Timestamp
                ? bd.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
          } catch (_) {
            bdt = DateTime.fromMillisecondsSinceEpoch(0);
          }

          return bdt.compareTo(adt); // desc
        });
        if (docs.isEmpty) {
          return const Text('Henüz hareket yok');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final m = docs[i].data();
            final amount = (m['amount'] as num?)?.toDouble() ?? 0;
            final dir = (m['direction'] as String?) ?? 'out';
            final sign = dir == 'in' ? '+' : '-';
            final color = dir == 'in' ? Colors.green : Colors.red;
            final note = m['note']?.toString() ?? '';
            final ts = m['date'];
            String dt = '';
            try {
              if (ts is Timestamp) {
                final d = ts.toDate();
                dt =
                    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
              }
            } catch (_) {}

            // Format amount in Turkish format
            String formatAmount(double amount) {
              final parts = amount.abs().toStringAsFixed(2).split('.');
              final intPart = parts[0];
              final decPart = parts[1];
              final formattedInt = intPart.replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]}.',
              );
              return '$formattedInt,$decPart';
            }

            final formattedAmount = formatAmount(amount);
            final transactionId = docs[i].id;
            final transactionType = m['type'] as String?;
            // Hak ediş olarak kabul edilen transaction'lar: direction == 'in' ve type yok veya 'entitlement'
            final isEntitlement = dir == 'in' &&
                (transactionType == null ||
                    transactionType == 'entitlement' ||
                    transactionType.isEmpty);
            // Mesai işlemleri: type == 'overtime' veya 'overtime_deduction'
            final isOvertime = transactionType == 'overtime' ||
                transactionType == 'overtime_deduction';
            // Ödeme işlemleri: type == 'payment' ve direction == 'out'
            final isPayment = transactionType == 'payment' && dir == 'out';

            return ListTile(
              dense: true,
              leading: Icon(
                  isOvertime
                      ? Icons.access_time
                      : (dir == 'in' ? Icons.call_received : Icons.call_made),
                  color: color),
              title: Text(note.isEmpty
                  ? (isOvertime
                      ? (dir == 'in' ? 'Mesai Ekleme' : 'Mesai Kesme')
                      : (dir == 'in' ? 'Ödeme' : 'Avans/Çıkış'))
                  : note),
              subtitle: Text(dt),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$sign$formattedAmount $currency',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w600)),
                  if (isEntitlement || isOvertime || isPayment)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'edit') {
                          if (isOvertime) {
                            if (onEditOvertimeTransaction != null) {
                              onEditOvertimeTransaction!(
                                context,
                                tenantId,
                                docId,
                                transactionId,
                                m,
                                currency,
                              );
                            }
                          } else if (isPayment) {
                            if (onEditPaymentTransaction != null) {
                              onEditPaymentTransaction!(
                                context,
                                tenantId,
                                docId,
                                transactionId,
                                m,
                                currency,
                              );
                            }
                          } else {
                            _showEditTransactionDialog(
                              context,
                              tenantId,
                              docId,
                              transactionId,
                              m,
                              currency,
                            );
                          }
                        } else if (value == 'delete') {
                          if (isPayment) {
                            if (onDeletePaymentTransaction != null) {
                              onDeletePaymentTransaction!(
                                context,
                                tenantId,
                                transactionId,
                                m,
                              );
                            }
                          } else {
                            _showDeleteTransactionDialog(
                              context,
                              tenantId,
                              transactionId,
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Düzenle'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Sil', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Düzenleme dialogu
  void _showEditTransactionDialog(
    BuildContext context,
    String? tenantId,
    String employeeId,
    String transactionId,
    Map<String, dynamic> transactionData,
    String currency,
  ) {
    final amount = (transactionData['amount'] as num?)?.toDouble() ?? 0;
    final note = transactionData['note']?.toString() ?? '';
    final date = transactionData['date'];
    DateTime? transactionDate;
    if (date is Timestamp) {
      transactionDate = date.toDate();
    } else if (date is DateTime) {
      transactionDate = date;
    }
    transactionDate ??= DateTime.now();

    final amountController = TextEditingController(
        text: amount.toStringAsFixed(2).replaceAll('.', ','));
    final noteController = TextEditingController(text: note);
    DateTime selectedDate = transactionDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hak Ediş Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tarih seçici
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tarih',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tutar
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Tutar ($currency)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+([,.]\d{0,2})?$')),
                  ],
                ),
                const SizedBox(height: 16),
                // Not
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Not (Opsiyonel)',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () async {
                final amountText = amountController.text
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                final newAmount = double.tryParse(amountText) ?? 0;
                final newNote = noteController.text.trim();

                if (newAmount <= 0) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tutar 0\'dan büyük olmalıdır'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                try {
                  final transactionsCol =
                      (tenantId != null && tenantId.isNotEmpty)
                          ? FirebaseFirestore.instance
                              .collection('tenants')
                              .doc(tenantId)
                              .collection('employee_transactions')
                          : FirebaseFirestore.instance
                              .collection('employee_transactions');

                  await transactionsCol.doc(transactionId).update({
                    'amount': newAmount,
                    'note': newNote,
                    'date': Timestamp.fromDate(selectedDate),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hak ediş güncellendi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  // Silme dialogu
  void _showDeleteTransactionDialog(
    BuildContext context,
    String? tenantId,
    String transactionId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hak Edişi Sil'),
        content: const Text(
            'Bu hak edişi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final transactionsCol =
                    (tenantId != null && tenantId.isNotEmpty)
                        ? FirebaseFirestore.instance
                            .collection('tenants')
                            .doc(tenantId)
                            .collection('employee_transactions')
                        : FirebaseFirestore.instance
                            .collection('employee_transactions');

                await transactionsCol.doc(transactionId).delete();

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hak ediş silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

extension _EmployeeDetailSheetExtension on _EmployeeDetailSheet {
  // Mesai işlemi düzenleme dialogu
  void _showEditOvertimeTransactionDialog(
    BuildContext context,
    String? tenantId,
    String employeeId,
    String transactionId,
    Map<String, dynamic> transactionData,
    String currency,
  ) async {
    // Önce employee bilgilerini çek
    final employeesCol = (tenantId != null && tenantId.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('employees')
        : FirebaseFirestore.instance.collection('employees');

    final employeeDoc = await employeesCol.doc(employeeId).get();
    if (!employeeDoc.exists || !context.mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personel bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final employeeData = employeeDoc.data() as Map<String, dynamic>;
    final name = employeeData['name'] as String? ?? 'Personel';
    final salary = (employeeData['salary'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    final salaryAmount = (salary['amount'] as num?)?.toDouble() ?? 0;
    final salaryCurrency = salary['currency']?.toString() ?? 'TRY';
    final entitlement =
        (employeeData['entitlement'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
    final entitlementType = entitlement['type']?.toString() ?? 'Aylık';

    // Mevcut transaction verilerini al
    final amount = (transactionData['amount'] as num?)?.toDouble() ?? 0;
    final note = transactionData['note']?.toString() ?? '';
    final overtimeHours =
        (transactionData['overtimeHours'] as num?)?.toDouble() ?? 0;
    final overtimeMultiplier =
        (transactionData['overtimeMultiplier'] as num?)?.toDouble() ?? 1;
    final hourlyOvertimeRate =
        (transactionData['hourlyOvertimeRate'] as num?)?.toDouble() ?? 0;
    final date = transactionData['date'];
    DateTime? transactionDate;
    if (date is Timestamp) {
      transactionDate = date.toDate();
    } else if (date is DateTime) {
      transactionDate = date;
    }
    transactionDate ??= DateTime.now();

    // Note'dan açıklama kısmını çıkar (eğer varsa)
    String noteText = note;
    if (note.contains(' - ')) {
      noteText = note.split(' - ').skip(1).join(' - ');
    } else if (note.startsWith('Mesai:') ||
        note.startsWith('Mesaiden kesme:')) {
      noteText = '';
    }

    final hoursController =
        TextEditingController(text: overtimeHours.toStringAsFixed(2));
    final multiplierController =
        TextEditingController(text: overtimeMultiplier.toStringAsFixed(2));
    final hourlyOvertimeRateController =
        TextEditingController(text: hourlyOvertimeRate.toStringAsFixed(2));
    final amountController =
        TextEditingController(text: amount.toStringAsFixed(2));
    final dateController = TextEditingController(
      text:
          '${transactionDate.day.toString().padLeft(2, '0')}.${transactionDate.month.toString().padLeft(2, '0')}.${transactionDate.year}',
    );
    final noteController = TextEditingController(text: noteText);
    DateTime selectedDate = transactionDate;

    // Saatlik ücreti hesapla - extension içinde helper fonksiyon kullan
    double calculateHourlyRateForOvertime({
      required double salaryAmount,
      required String entitlementType,
      required Map<String, dynamic> entitlement,
    }) {
      double hourlyRate = 0;
      switch (entitlementType) {
        case 'Aylık':
        case 'Aylık (İki Kere)':
          final daysPerWeek = entitlement['daysPerWeek'] as int? ?? 5;
          final hoursPerDay = entitlement['hoursPerDay'] as int? ?? 8;
          final weeklyHours = daysPerWeek * hoursPerDay;
          final monthlyHours = weeklyHours * 4.33;
          hourlyRate = salaryAmount / monthlyHours;
          break;
        case 'Haftalık':
          final daysPerWeek = entitlement['daysPerWeek'] as int? ?? 5;
          final hoursPerDay = entitlement['hoursPerDay'] as int? ?? 8;
          hourlyRate = salaryAmount / (daysPerWeek * hoursPerDay);
          break;
        case 'Günlük':
          final hoursPerDay = entitlement['hoursPerDay'] as int? ?? 8;
          hourlyRate = salaryAmount / hoursPerDay;
          break;
        case 'Saatlik':
          hourlyRate = salaryAmount;
          break;
        default:
          hourlyRate = salaryAmount / (30 * 8);
      }
      return hourlyRate;
    }

    final baseHourlyRate = calculateHourlyRateForOvertime(
      salaryAmount: salaryAmount,
      entitlementType: entitlementType,
      entitlement: entitlement,
    );

    // İlk hesaplama için listener ekle
    String? lastCalculatedHourlyRate;
    String? lastCalculatedMultiplier;
    bool userChangedHourlyRate = false;
    bool userChangedMultiplier = false;
    bool isDisposed = false;

    void updateHourlyOvertimeRate() {
      if (isDisposed) return;
      final multiplier =
          double.tryParse(multiplierController.text.replaceAll(',', '.')) ?? 1;
      if (multiplier > 0 && baseHourlyRate > 0 && !userChangedHourlyRate) {
        final calculatedHourlyRate = baseHourlyRate * multiplier;
        final calculatedHourlyRateStr = calculatedHourlyRate.toStringAsFixed(2);
        if (lastCalculatedHourlyRate == null ||
            hourlyOvertimeRateController.text == lastCalculatedHourlyRate ||
            hourlyOvertimeRateController.text.isEmpty) {
          hourlyOvertimeRateController.text = calculatedHourlyRateStr;
          lastCalculatedHourlyRate = calculatedHourlyRateStr;
        }
      }
    }

    void updateMultiplier() {
      if (isDisposed) return;
      final hourlyOvertimeRate = double.tryParse(
              hourlyOvertimeRateController.text.replaceAll(',', '.')) ??
          0;
      if (hourlyOvertimeRate > 0 &&
          baseHourlyRate > 0 &&
          !userChangedMultiplier) {
        final calculatedMultiplier = hourlyOvertimeRate / baseHourlyRate;
        final calculatedMultiplierStr = calculatedMultiplier.toStringAsFixed(2);
        if (lastCalculatedMultiplier == null ||
            multiplierController.text == lastCalculatedMultiplier ||
            multiplierController.text.isEmpty) {
          multiplierController.text = calculatedMultiplierStr;
          lastCalculatedMultiplier = calculatedMultiplierStr;
        }
      }
    }

    void updateAmount({bool force = false}) {
      if (isDisposed) return;
      final hours =
          double.tryParse(hoursController.text.replaceAll(',', '.')) ?? 0;
      final hourlyOvertimeRate = double.tryParse(
              hourlyOvertimeRateController.text.replaceAll(',', '.')) ??
          0;

      if (hours > 0 && hourlyOvertimeRate > 0) {
        // Mesai tutarı her zaman otomatik hesaplanır (read-only alan)
        final calculatedAmount = hourlyOvertimeRate * hours;
        final calculatedAmountStr = calculatedAmount.toStringAsFixed(2);
        amountController.text = calculatedAmountStr;
      } else {
        if (force) {
          amountController.text = '0.00';
        }
      }
    }

    void multiplierListener() {
      if (isDisposed) return;
      userChangedMultiplier = true;
      userChangedHourlyRate = false;
      updateHourlyOvertimeRate();
      updateAmount();
    }

    void hourlyOvertimeRateListener() {
      if (isDisposed) return;
      userChangedHourlyRate = true;
      userChangedMultiplier = false;
      updateMultiplier();
      updateAmount();
    }

    hoursController.addListener(updateAmount);
    multiplierController.addListener(multiplierListener);
    hourlyOvertimeRateController.addListener(hourlyOvertimeRateListener);

    final transactionType = transactionData['type'] as String?;
    final isDeduction = transactionType == 'overtime_deduction';
    final dialogTitle =
        isDeduction ? 'Mesaiden Kesme Düzenle' : 'Mesai Ekleme Düzenle';

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text(dialogTitle),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        '$name için mesai ${isDeduction ? 'kesme' : 'ekleme'} düzenle'),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text =
                                '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(dateController.text),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Mesai Saati',
                        border: OutlineInputBorder(),
                        hintText: 'Örn: 2.5',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        setState(() {
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: multiplierController,
                      decoration: const InputDecoration(
                        labelText: 'Mesai Çarpanı',
                        border: OutlineInputBorder(),
                        hintText: 'Örn: 1.5 (varsayılan: 1)',
                        helperText: 'Saatlik ücretin kaç katı olacak?',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateHourlyOvertimeRate();
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hourlyOvertimeRateController,
                      decoration: InputDecoration(
                        labelText: 'Saatlik Mesai Ücreti ($salaryCurrency)',
                        border: const OutlineInputBorder(),
                        hintText: 'Otomatik hesaplanır',
                        helperText: 'Saatlik ücret × çarpan',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount();
                        });
                      },
                      onEditingComplete: () {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount(force: true);
                        });
                      },
                      onTapOutside: (_) {
                        if (isDisposed || !ctx.mounted) return;
                        setState(() {
                          updateMultiplier();
                          updateAmount(force: true);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Mesai Tutarı ($salaryCurrency)',
                        border: const OutlineInputBorder(),
                        hintText: 'Otomatik hesaplanır',
                        helperText: 'Saatlik mesai ücreti × mesai saati',
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      readOnly: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (Opsiyonel)',
                        border: OutlineInputBorder(),
                        hintText: 'Mesai nedeni...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Önce isDisposed flag'ini set et
                  isDisposed = true;
                  // Listener'ları kaldır
                  hoursController.removeListener(updateAmount);
                  multiplierController.removeListener(multiplierListener);
                  hourlyOvertimeRateController
                      .removeListener(hourlyOvertimeRateListener);
                  // Dialog'u önce kapat (Flutter otomatik olarak focus'u temizler)
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  // Controller'ları dispose et (dialog kapandıktan sonra)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    hoursController.dispose();
                    multiplierController.dispose();
                    hourlyOvertimeRateController.dispose();
                    amountController.dispose();
                    dateController.dispose();
                    noteController.dispose();
                  });
                },
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  final hours = double.tryParse(
                    hoursController.text.replaceAll(',', '.'),
                  );
                  if (hours == null || hours <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir mesai saati girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final multiplier = double.tryParse(
                    multiplierController.text.replaceAll(',', '.'),
                  );
                  if (multiplier == null || multiplier <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir çarpan girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final hourlyOvertimeRate = double.tryParse(
                    hourlyOvertimeRateController.text.replaceAll(',', '.'),
                  );
                  if (hourlyOvertimeRate == null || hourlyOvertimeRate <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Lütfen geçerli bir saatlik mesai ücreti girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final overtimeAmount = double.tryParse(
                    amountController.text.replaceAll(',', '.'),
                  );
                  if (overtimeAmount == null || overtimeAmount <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir tutar girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final col = (tenantId != null && tenantId.isNotEmpty)
                        ? FirebaseFirestore.instance
                            .collection('tenants')
                            .doc(tenantId)
                            .collection('employee_transactions')
                        : FirebaseFirestore.instance
                            .collection('employee_transactions');

                    final noteText = noteController.text.trim();
                    final finalNote = noteText.isEmpty
                        ? (isDeduction
                            ? 'Mesaiden kesme: $hours saat (x$multiplier)'
                            : 'Mesai: $hours saat (x$multiplier)')
                        : (isDeduction
                            ? 'Mesaiden kesme: $hours saat (x$multiplier) - $noteText'
                            : 'Mesai: $hours saat (x$multiplier) - $noteText');

                    await col.doc(transactionId).update({
                      'amount': overtimeAmount,
                      'note': finalNote,
                      'overtimeHours': hours,
                      'overtimeMultiplier': multiplier,
                      'hourlyOvertimeRate': hourlyOvertimeRate,
                      'date': Timestamp.fromDate(selectedDate),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    // Önce isDisposed flag'ini set et
                    isDisposed = true;
                    // Listener'ları kaldır
                    hoursController.removeListener(updateAmount);
                    multiplierController.removeListener(multiplierListener);
                    hourlyOvertimeRateController
                        .removeListener(hourlyOvertimeRateListener);
                    // Dialog'u önce kapat (Flutter otomatik olarak focus'u temizler)
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                    // Controller'ları dispose et ve SnackBar'ı göster (dialog kapandıktan sonra)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      hoursController.dispose();
                      multiplierController.dispose();
                      hourlyOvertimeRateController.dispose();
                      amountController.dispose();
                      dateController.dispose();
                      noteController.dispose();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mesai ${isDeduction ? 'kesme' : 'ekleme'} güncellendi',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                  } catch (e) {
                    if (!isDisposed && ctx.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(isDeduction ? 'Mesaiden Kes' : 'Mesai Ekle'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Ödeme işlemi düzenleme dialogu
  void _showEditPaymentTransactionDialog(
    BuildContext context,
    String? tenantId,
    String employeeId,
    String transactionId,
    Map<String, dynamic> transactionData,
    String currency,
  ) async {
    // Önce employee bilgilerini çek
    final employeesCol = (tenantId != null && (tenantId.isNotEmpty))
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('employees')
        : FirebaseFirestore.instance.collection('employees');

    final employeeDoc = await employeesCol.doc(employeeId).get();
    if (!employeeDoc.exists || !context.mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personel bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final employeeData = employeeDoc.data() as Map<String, dynamic>;
    final name = employeeData['name'] as String? ?? 'Personel';

    // Mevcut transaction bilgilerini al
    final amount = (transactionData['amount'] as num?)?.toDouble() ?? 0;
    final note = transactionData['note']?.toString() ?? '';
    final date = transactionData['date'];
    DateTime? transactionDate;
    if (date is Timestamp) {
      transactionDate = date.toDate();
    } else if (date is DateTime) {
      transactionDate = date;
    }
    transactionDate ??= DateTime.now();
    final accountId = transactionData['accountId'] as String?;

    // Önce kasaları çek - accounts collection'ından
    final accountsCol = (tenantId != null && (tenantId.isNotEmpty))
        ? FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('accounts')
        : FirebaseFirestore.instance.collection('accounts');

    try {
      final accountsSnapshot =
          await accountsCol.where('isActive', isEqualTo: true).get();

      // Sadece Nakit ve Banka (checking/savings) kasalarını filtrele
      final availableAccounts = accountsSnapshot.docs.where((doc) {
        final data = doc.data();
        final type = data['type'] as String?;
        return type == 'cash' || type == 'checking' || type == 'savings';
      }).map((doc) {
        final data = doc.data();
        final type = data['type'] as String?;
        String typeLabel = 'Diğer';
        if (type == 'cash') {
          typeLabel = 'Nakit';
        } else if (type == 'checking' || type == 'savings') {
          typeLabel = 'Banka';
        }
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? '',
          'type': type ?? '',
          'typeLabel': typeLabel,
          'balance': (data['balance'] as num?)?.toDouble() ?? 0.0,
          'currency': data['currency'] as String? ?? 'TRY',
        };
      }).toList();

      if (availableAccounts.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Aktif Nakit veya Banka hesabı bulunamadı. Lütfen önce hesap ekleyin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (!context.mounted) return;

      // Seçili hesabı bul veya ilk hesabı kullan
      String? selectedAccountId = accountId;
      if (selectedAccountId == null ||
          !availableAccounts.any((acc) => acc['id'] == selectedAccountId)) {
        selectedAccountId = availableAccounts.first['id'] as String;
      }

      final selectedAccount = availableAccounts.firstWhere(
        (acc) => acc['id'] == selectedAccountId,
        orElse: () => availableAccounts.first,
      );
      String selectedAccountCurrency = selectedAccount['currency'] as String;
      bool needsExchangeRate = selectedAccountCurrency != currency;
      double? exchangeRate;

      // Eski account transaction'ı bul (kur bilgisi için)
      String? oldAccountTransactionId;
      double? oldAmountInAccountCurrency;
      if (accountId != null) {
        final accountTransactionsCol =
            (tenantId != null && (tenantId.isNotEmpty))
                ? FirebaseFirestore.instance
                    .collection('tenants')
                    .doc(tenantId)
                    .collection('accountTransactions')
                : FirebaseFirestore.instance.collection('accountTransactions');

        final accountTransactionsSnapshot = await accountTransactionsCol
            .where('accountId', isEqualTo: accountId)
            .where('transactionDate',
                isEqualTo: Timestamp.fromDate(transactionDate))
            .where('type', isEqualTo: 'withdrawal')
            .where('category', isEqualTo: 'expense')
            .get();

        if (accountTransactionsSnapshot.docs.isNotEmpty) {
          // İlk eşleşeni al (genellikle tek olmalı)
          final accountTransactionDoc = accountTransactionsSnapshot.docs.first;
          oldAccountTransactionId = accountTransactionDoc.id;
          final accountTransactionData = accountTransactionDoc.data();
          oldAmountInAccountCurrency =
              (accountTransactionData['amount'] as num?)?.toDouble();
        }
      }

      // Kur bilgisini hesapla (eğer farklı para birimi varsa)
      if (needsExchangeRate &&
          oldAmountInAccountCurrency != null &&
          amount > 0) {
        exchangeRate = amount / oldAmountInAccountCurrency;
      }

      final amountController = TextEditingController(
        text: _formatNumberTr(amount),
      );
      final exchangeRateController = TextEditingController(
        text: exchangeRate != null
            ? exchangeRate.toStringAsFixed(6).replaceAll('.', ',')
            : '',
      );
      final noteController = TextEditingController(text: note);
      final dateController = TextEditingController(
        text:
            '${transactionDate.day.toString().padLeft(2, '0')}.${transactionDate.month.toString().padLeft(2, '0')}.${transactionDate.year}',
      );
      DateTime selectedDate = transactionDate;
      bool isDialogDisposed = false;

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (dialogContext, setState) {
          // İlk yüklemede kur bilgisini otomatik getir (eğer yoksa)
          if (needsExchangeRate && exchangeRate == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchExchangeRate(
                selectedAccountCurrency,
                currency,
                exchangeRateController,
                setState,
                (rate) {
                  exchangeRate = rate;
                },
              );
            });
          }
          return AlertDialog(
            title: const Text('Ödeme Düzenle'),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('$name için ödeme düzenle'),
                    const SizedBox(height: 16),
                    // Kasa seçimi - StreamBuilder ile güncel bakiye gösterimi
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: selectedAccountId != null
                          ? accountsCol.doc(selectedAccountId).snapshots()
                          : null,
                      builder: (context, snapshot) {
                        double currentBalance = 0.0;
                        String accountCurrency = 'TRY';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final accountData = snapshot.data!.data()!;
                          currentBalance =
                              (accountData['balance'] as num?)?.toDouble() ??
                                  0.0;
                          accountCurrency =
                              accountData['currency'] as String? ?? 'TRY';
                        } else {
                          final selectedAccount = availableAccounts.firstWhere(
                            (acc) => acc['id'] == selectedAccountId,
                            orElse: () => availableAccounts.first,
                          );
                          currentBalance = selectedAccount['balance'] as double;
                          accountCurrency =
                              selectedAccount['currency'] as String;
                        }

                        String formatBalance(double amount) {
                          final parts =
                              amount.abs().toStringAsFixed(2).split('.');
                          final intPart = parts[0];
                          final decPart = parts[1];
                          final formattedInt = intPart.replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]}.',
                          );
                          return '$formattedInt,$decPart';
                        }

                        final formattedBalance = formatBalance(currentBalance);

                        return DropdownButtonFormField<String>(
                          initialValue: selectedAccountId,
                          decoration: InputDecoration(
                            labelText: 'Kasa *',
                            border: const OutlineInputBorder(),
                            helperText: snapshot.hasData
                                ? 'Bakiye: $formattedBalance $accountCurrency'
                                : 'Nakit veya Banka hesabı seçin',
                            isDense: true,
                          ),
                          isExpanded: true,
                          items: availableAccounts.map((account) {
                            final accountName = account['name'] as String;
                            final typeLabel = account['typeLabel'] as String;
                            return DropdownMenuItem<String>(
                              value: account['id'] as String,
                              child: Text(
                                '$accountName ($typeLabel)',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return availableAccounts.map((account) {
                              final accountName = account['name'] as String;
                              final typeLabel = account['typeLabel'] as String;
                              return Text(
                                '$accountName ($typeLabel)',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            }).toList();
                          },
                          onChanged: (value) async {
                            setState(() {
                              selectedAccountId = value;
                              final selectedAccount =
                                  availableAccounts.firstWhere(
                                (acc) => acc['id'] == value,
                              );
                              selectedAccountCurrency =
                                  selectedAccount['currency'] as String;
                              needsExchangeRate =
                                  selectedAccountCurrency != currency;
                              if (!needsExchangeRate) {
                                exchangeRate = null;
                                exchangeRateController.clear();
                              } else {
                                _fetchExchangeRate(
                                  selectedAccountCurrency,
                                  currency,
                                  exchangeRateController,
                                  setState,
                                  (rate) {
                                    exchangeRate = rate;
                                  },
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Tarih seçici
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text =
                                '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          dateController.text.isEmpty
                              ? 'Tarih seçin'
                              : dateController.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Kur girişi (farklı para birimi varsa)
                    if (needsExchangeRate) ...[
                      TextFormField(
                        controller: exchangeRateController,
                        decoration: InputDecoration(
                          labelText:
                              'Kur (1 $selectedAccountCurrency = ? $currency) *',
                          border: const OutlineInputBorder(),
                          hintText: 'Örn: 34,50',
                          helperText:
                              'Kasa para birimi ($selectedAccountCurrency) ile personel para birimi ($currency) farklı',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+([,.]\d{0,6})?$')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            final rateText =
                                value.replaceAll('.', '').replaceAll(',', '.');
                            exchangeRate = double.tryParse(rateText);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Tutar
                    Builder(
                      builder: (context) {
                        String? accountCurrencyEquivalent;
                        final parsedAmount =
                            _parseAmountText(amountController.text);
                        if (parsedAmount != null && parsedAmount > 0) {
                          if (needsExchangeRate &&
                              exchangeRate != null &&
                              exchangeRate! > 0) {
                            final accountAmount = parsedAmount / exchangeRate!;
                            accountCurrencyEquivalent =
                                '${_formatNumberTr(accountAmount)} $selectedAccountCurrency';
                          } else if (selectedAccountCurrency == currency) {
                            accountCurrencyEquivalent =
                                '${_formatNumberTr(parsedAmount)} $selectedAccountCurrency';
                          }
                        }

                        return Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus && !isDialogDisposed) {
                              try {
                                setState(() {
                                  _formatAmountField(amountController);
                                });
                              } catch (e) {
                                // Dialog kapatıldıysa hata yok sayılır
                              }
                            }
                          },
                          child: TextFormField(
                            controller: amountController,
                            decoration: InputDecoration(
                              labelText: 'Tutar ($currency)',
                              border: const OutlineInputBorder(),
                              hintText: 'Örn: 10000,00',
                              helperText: accountCurrencyEquivalent,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]')),
                            ],
                            onChanged: (value) {
                              if (!isDialogDisposed) {
                                try {
                                  setState(() {});
                                } catch (e) {
                                  // Dialog kapatıldıysa hata yok sayılır
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Not
                    TextFormField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Not (Opsiyonel)',
                        border: OutlineInputBorder(),
                        hintText: 'Ödeme açıklaması...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  isDialogDisposed = true;
                  amountController.dispose();
                  exchangeRateController.dispose();
                  noteController.dispose();
                  dateController.dispose();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  if (selectedAccountId == null || selectedAccountId!.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen bir kasa seçin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (needsExchangeRate &&
                      (exchangeRate == null || exchangeRate! <= 0)) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen geçerli bir kur girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final amountText = amountController.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.');
                  final newAmount = double.tryParse(amountText) ?? 0;
                  final newNote = noteController.text.trim();

                  if (newAmount <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Tutar 0\'dan büyük olmalıdır'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    // Eski account bilgisini al (yukarıda hesaplanan oldAmountInAccountCurrency kullanılacak)
                    final oldAccountDoc = accountId != null
                        ? await accountsCol.doc(accountId).get()
                        : null;

                    // Yeni account bilgisini al
                    final newAccountDoc =
                        await accountsCol.doc(selectedAccountId).get();
                    if (!newAccountDoc.exists) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Seçilen hesap bulunamadı'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newAccountData =
                        newAccountDoc.data() as Map<String, dynamic>;
                    final newAccountCurrency =
                        newAccountData['currency'] as String? ?? 'TRY';
                    double currentBalance =
                        (newAccountData['balance'] as num?)?.toDouble() ?? 0.0;
                    final blockedAmount =
                        (newAccountData['blockedAmount'] as num?)?.toDouble() ??
                            0.0;

                    // Eski ödeme tutarını geri ekle (eğer aynı hesapsa)
                    if (accountId == selectedAccountId &&
                        oldAccountDoc != null &&
                        oldAmountInAccountCurrency != null) {
                      currentBalance += oldAmountInAccountCurrency;
                    }

                    // Yeni tutarı kasa para birimine çevir
                    double newAmountInAccountCurrency = newAmount;
                    if (newAccountCurrency != currency &&
                        exchangeRate != null &&
                        exchangeRate! > 0) {
                      newAmountInAccountCurrency = newAmount / exchangeRate!;
                    }

                    // Yeni balance hesapla
                    final newBalance =
                        currentBalance - newAmountInAccountCurrency;
                    final newAvailableBalance = newBalance - blockedAmount;

                    // Batch işlem
                    final batch = FirebaseFirestore.instance.batch();

                    // 1. Employee transaction güncelle
                    final employeeTransactionsCol =
                        (tenantId != null && (tenantId.isNotEmpty))
                            ? FirebaseFirestore.instance
                                .collection('tenants')
                                .doc(tenantId)
                                .collection('employee_transactions')
                            : FirebaseFirestore.instance
                                .collection('employee_transactions');

                    final employeeTransactionRef =
                        employeeTransactionsCol.doc(transactionId);
                    batch.update(employeeTransactionRef, {
                      'amount': newAmount,
                      'note': newNote.isEmpty ? 'Ödeme' : newNote,
                      'date': Timestamp.fromDate(selectedDate),
                      'accountId': selectedAccountId,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    // 2. Eski account transaction'ı sil veya güncelle
                    if (oldAccountTransactionId != null && accountId != null) {
                      final accountTransactionsCol =
                          (tenantId != null && (tenantId.isNotEmpty))
                              ? FirebaseFirestore.instance
                                  .collection('tenants')
                                  .doc(tenantId)
                                  .collection('accountTransactions')
                              : FirebaseFirestore.instance
                                  .collection('accountTransactions');

                      final oldAccountTransactionRef =
                          accountTransactionsCol.doc(oldAccountTransactionId);
                      batch.delete(oldAccountTransactionRef);

                      // Eski account balance'ı geri yükle
                      if (accountId != selectedAccountId &&
                          oldAccountDoc != null &&
                          oldAmountInAccountCurrency != null) {
                        final oldAccountRef = accountsCol.doc(accountId);
                        final oldAccountDocData = oldAccountDoc.data()!;
                        final oldAccountBalance =
                            (oldAccountDocData['balance'] as num?)
                                    ?.toDouble() ??
                                0.0;
                        final oldAccountBlockedAmount =
                            (oldAccountDocData['blockedAmount'] as num?)
                                    ?.toDouble() ??
                                0.0;
                        batch.update(oldAccountRef, {
                          'balance':
                              oldAccountBalance + oldAmountInAccountCurrency,
                          'availableBalance':
                              (oldAccountBalance + oldAmountInAccountCurrency) -
                                  oldAccountBlockedAmount,
                          'updatedAt': FieldValue.serverTimestamp(),
                          'updatedBy': FirebaseAuth.instance.currentUser?.uid,
                        });
                      }
                    }

                    // 3. Yeni account transaction ekle
                    final accountTransactionsCol =
                        (tenantId != null && (tenantId.isNotEmpty))
                            ? FirebaseFirestore.instance
                                .collection('tenants')
                                .doc(tenantId)
                                .collection('accountTransactions')
                            : FirebaseFirestore.instance
                                .collection('accountTransactions');

                    final accountTransactionRef = accountTransactionsCol.doc();
                    final exchangeRateNote = needsExchangeRate &&
                            exchangeRate != null
                        ? ' (Kur: $exchangeRate, $newAmount $currency = ${newAmountInAccountCurrency.toStringAsFixed(2)} $newAccountCurrency)'
                        : '';
                    batch.set(accountTransactionRef, {
                      'accountId': selectedAccountId,
                      'type': 'withdrawal',
                      'category': 'expense',
                      'amount': newAmountInAccountCurrency,
                      'debitAmount': newAmountInAccountCurrency,
                      'creditAmount': null,
                      'balanceAfter': newBalance,
                      'description':
                          '$name - Personel Ödemesi$exchangeRateNote',
                      'notes': newNote.isEmpty ? null : newNote,
                      'transactionDate': Timestamp.fromDate(selectedDate),
                      'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
                      'isReconciled': false,
                      'tenantId': tenantId,
                      'createdBy': FirebaseAuth.instance.currentUser?.uid,
                      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    // 4. Yeni account balance güncelle
                    final newAccountRef = accountsCol.doc(selectedAccountId);
                    batch.update(newAccountRef, {
                      'balance': newBalance,
                      'availableBalance': newAvailableBalance,
                      'updatedAt': FieldValue.serverTimestamp(),
                      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
                    });

                    await batch.commit();

                    if (ctx.mounted) {
                      isDialogDisposed = true;
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ödeme güncellendi (${newAmount.toStringAsFixed(2)} $currency)',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }

                    amountController.dispose();
                    exchangeRateController.dispose();
                    noteController.dispose();
                    dateController.dispose();
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        }),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kasa bilgileri alınırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Ödeme işlemi silme dialogu
  void _showDeletePaymentTransactionDialog(
    BuildContext context,
    String? tenantId,
    String transactionId,
    Map<String, dynamic> transactionData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödemeyi Sil'),
        content: const Text(
            'Bu ödemeyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve ilgili kasa bakiyesi güncellenecektir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final accountId = transactionData['accountId'] as String?;
                final amount =
                    (transactionData['amount'] as num?)?.toDouble() ?? 0;
                final date = transactionData['date'];
                DateTime? transactionDate;
                if (date is Timestamp) {
                  transactionDate = date.toDate();
                } else if (date is DateTime) {
                  transactionDate = date;
                }

                // Account transaction'ı bul
                String? accountTransactionId;
                double? amountInAccountCurrency;
                if (accountId != null && transactionDate != null) {
                  final accountTransactionsCol =
                      (tenantId != null && (tenantId.isNotEmpty))
                          ? FirebaseFirestore.instance
                              .collection('tenants')
                              .doc(tenantId)
                              .collection('accountTransactions')
                          : FirebaseFirestore.instance
                              .collection('accountTransactions');

                  final accountTransactionsSnapshot =
                      await accountTransactionsCol
                          .where('accountId', isEqualTo: accountId)
                          .where('transactionDate',
                              isEqualTo: Timestamp.fromDate(transactionDate))
                          .where('type', isEqualTo: 'withdrawal')
                          .where('category', isEqualTo: 'expense')
                          .get();

                  if (accountTransactionsSnapshot.docs.isNotEmpty) {
                    final accountTransactionDoc =
                        accountTransactionsSnapshot.docs.first;
                    accountTransactionId = accountTransactionDoc.id;
                    final accountTransactionData = accountTransactionDoc.data();
                    amountInAccountCurrency =
                        (accountTransactionData['amount'] as num?)?.toDouble();
                  }
                }

                // Batch işlem
                final batch = FirebaseFirestore.instance.batch();

                // 1. Employee transaction sil
                final employeeTransactionsCol =
                    (tenantId != null && (tenantId.isNotEmpty))
                        ? FirebaseFirestore.instance
                            .collection('tenants')
                            .doc(tenantId)
                            .collection('employee_transactions')
                        : FirebaseFirestore.instance
                            .collection('employee_transactions');

                batch.delete(employeeTransactionsCol.doc(transactionId));

                // 2. Account transaction sil ve balance geri yükle
                if (accountId != null && accountTransactionId != null) {
                  final accountTransactionsCol =
                      (tenantId != null && (tenantId.isNotEmpty))
                          ? FirebaseFirestore.instance
                              .collection('tenants')
                              .doc(tenantId)
                              .collection('accountTransactions')
                          : FirebaseFirestore.instance
                              .collection('accountTransactions');

                  batch
                      .delete(accountTransactionsCol.doc(accountTransactionId));

                  // Account balance'ı geri yükle
                  final accountsCol =
                      (tenantId != null && (tenantId.isNotEmpty))
                          ? FirebaseFirestore.instance
                              .collection('tenants')
                              .doc(tenantId)
                              .collection('accounts')
                          : FirebaseFirestore.instance.collection('accounts');

                  final accountDoc = await accountsCol.doc(accountId).get();
                  if (accountDoc.exists) {
                    final accountData = accountDoc.data()!;
                    final currentBalance =
                        (accountData['balance'] as num?)?.toDouble() ?? 0.0;
                    final blockedAmount =
                        (accountData['blockedAmount'] as num?)?.toDouble() ??
                            0.0;
                    final newBalance =
                        currentBalance + (amountInAccountCurrency ?? amount);
                    final newAvailableBalance = newBalance - blockedAmount;

                    batch.update(accountsCol.doc(accountId), {
                      'balance': newBalance,
                      'availableBalance': newAvailableBalance,
                      'updatedAt': FieldValue.serverTimestamp(),
                      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
                    });
                  }
                }

                await batch.commit();

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ödeme silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Personel hareketlerini export et
  void _showExportTransactionsOptions(BuildContext context) {
    final parentContext = context;
    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel Olarak İndir'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportTransactionsToExcel(parentContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Olarak İndir'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportTransactionsToPDF(parentContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransactionsToExcel(BuildContext context) async {
    bool dialogShown = false;
    Object? error;
    String? fileName;
    try {
      // Loading göster
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      dialogShown = true;

      // Currency bilgisini al
      final salary = (data['salary'] as Map?) ?? {};
      final currency = salary['currency']?.toString() ?? 'TRY';

      // Tüm hareketleri çek (limit yok)
      final transactionsCol =
          (tenantId != null && (tenantId?.isNotEmpty ?? false))
              ? FirebaseFirestore.instance
                  .collection('tenants')
                  .doc(tenantId)
                  .collection('employee_transactions')
              : FirebaseFirestore.instance.collection('employee_transactions');

      final snapshot =
          await transactionsCol.where('employeeId', isEqualTo: docId).get();

      final employeeName = data['name'] as String? ?? 'Personel';
      final transactions = [...snapshot.docs];

      // Client-side sıralama (index gerektirmez)
      transactions.sort((a, b) {
        final ad = a.data()['date'];
        final bd = b.data()['date'];
        DateTime adt;
        DateTime bdt;
        try {
          adt = ad is Timestamp
              ? ad.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);
        } catch (_) {
          adt = DateTime.fromMillisecondsSinceEpoch(0);
        }
        try {
          bdt = bd is Timestamp
              ? bd.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);
        } catch (_) {
          bdt = DateTime.fromMillisecondsSinceEpoch(0);
        }
        return bdt.compareTo(adt); // desc
      });

      if (transactions.isEmpty) {
        if (dialogShown && context.mounted) {
          try {
            Navigator.of(context, rootNavigator: true).pop();
            dialogShown = false;
          } catch (_) {}
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Export edilecek hareket bulunamadı'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        return;
      }

      // Headers
      final headers = [
        'Tarih',
        'İşlem Türü',
        'Açıklama',
        'Tutar',
        'Yön',
      ];

      // Data
      final exportData = <List<dynamic>>[];

      for (final doc in transactions) {
        final m = doc.data();
        final amount = (m['amount'] as num?)?.toDouble() ?? 0;
        final dir = (m['direction'] as String?) ?? 'out';
        final note = m['note']?.toString() ?? '';
        final transactionType = m['type'] as String?;
        final ts = m['date'];

        String dateStr = '';
        if (ts is Timestamp) {
          final d = ts.toDate();
          dateStr =
              '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
        }

        String transactionTypeStr = '';
        if (transactionType == 'overtime') {
          transactionTypeStr = 'Mesai Ekleme';
        } else if (transactionType == 'overtime_deduction') {
          transactionTypeStr = 'Mesai Kesme';
        } else if (transactionType == 'payment') {
          transactionTypeStr = 'Ödeme';
        } else if (dir == 'in') {
          transactionTypeStr = 'Hak Ediş';
        } else {
          transactionTypeStr = 'Avans/Çıkış';
        }

        String description = note.isEmpty
            ? (transactionTypeStr == 'Mesai Ekleme' ||
                    transactionTypeStr == 'Mesai Kesme'
                ? transactionTypeStr
                : (dir == 'in' ? 'Ödeme' : 'Avans/Çıkış'))
            : note;

        // Format amount in Turkish format
        String formatAmount(double amount) {
          final parts = amount.abs().toStringAsFixed(2).split('.');
          final intPart = parts[0];
          final decPart = parts[1];
          final formattedInt = intPart.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
          return '$formattedInt,$decPart';
        }

        final formattedAmount = formatAmount(amount);
        final direction = dir == 'in' ? 'Giriş' : 'Çıkış';

        exportData.add([
          dateStr,
          transactionTypeStr,
          description,
          '$formattedAmount $currency',
          direction,
        ]);
      }

      // Export service kullan
      final exportService = ExportService();
      final fileBytes = await exportService.exportToExcel(
        title: '$employeeName - Hareketler',
        headers: headers,
        data: exportData,
        sheetName: 'Hareketler',
      );

      // Dosyayı kaydet
      fileName =
          '${employeeName.replaceAll(' ', '_')}_Hareketler_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

      if (kIsWeb) {
        final blob = web.Blob([fileBytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.HTMLAnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';
        web.document.body?.appendChild(anchor);
        anchor.click();
        anchor.remove();
        web.URL.revokeObjectURL(url);
      } else {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final filePath = path.join(directory.path, fileName);
          final file = File(filePath);
          await file.writeAsBytes(fileBytes);
        }
      }
    } catch (e) {
      error = e;
    } finally {
      // Dialog'u mutlaka kapat ve SnackBar göster
      if (dialogShown) {
        final finalError = error;
        final finalFileName = fileName;

        // Dialog'u kapat
        Future.microtask(() {
          try {
            if (context.mounted) {
              final navigator = Navigator.of(context, rootNavigator: true);
              if (navigator.canPop()) {
                navigator.pop();
              }
            }
          } catch (_) {
            // Context dispose edilmiş olabilir
          }
        });

        // SnackBar'ı göster (dialog kapandıktan sonra)
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            if (context.mounted) {
              if (finalError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Export hatası: $finalError'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (finalFileName != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Excel dosyası indirildi: $finalFileName'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (_) {
            // Context dispose edilmiş olabilir
          }
        });
      }
    }
  }

  Future<void> _exportTransactionsToPDF(BuildContext context) async {
    bool dialogShown = false;
    Object? error;
    String? fileName;
    try {
      // Loading göster
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      dialogShown = true;

      // Currency bilgisini al
      final salary = (data['salary'] as Map?) ?? {};
      final currency = salary['currency']?.toString() ?? 'TRY';

      // Tüm hareketleri çek (limit yok)
      final transactionsCol =
          (tenantId != null && (tenantId?.isNotEmpty ?? false))
              ? FirebaseFirestore.instance
                  .collection('tenants')
                  .doc(tenantId)
                  .collection('employee_transactions')
              : FirebaseFirestore.instance.collection('employee_transactions');

      final snapshot =
          await transactionsCol.where('employeeId', isEqualTo: docId).get();

      final employeeName = data['name'] as String? ?? 'Personel';
      final transactions = [...snapshot.docs];

      // Client-side sıralama (index gerektirmez)
      transactions.sort((a, b) {
        final ad = a.data()['date'];
        final bd = b.data()['date'];
        DateTime adt;
        DateTime bdt;
        try {
          adt = ad is Timestamp
              ? ad.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);
        } catch (_) {
          adt = DateTime.fromMillisecondsSinceEpoch(0);
        }
        try {
          bdt = bd is Timestamp
              ? bd.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);
        } catch (_) {
          bdt = DateTime.fromMillisecondsSinceEpoch(0);
        }
        return bdt.compareTo(adt); // desc
      });

      if (transactions.isEmpty) {
        if (dialogShown && context.mounted) {
          try {
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            dialogShown = false;
          } catch (_) {}
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export edilecek hareket bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Headers
      final headers = [
        'Tarih',
        'İşlem Türü',
        'Açıklama',
        'Tutar',
        'Yön',
      ];

      // Data
      final exportData = <List<dynamic>>[];
      double totalIn = 0;
      double totalOut = 0;

      for (final doc in transactions) {
        final m = doc.data();
        final amount = (m['amount'] as num?)?.toDouble() ?? 0;
        final dir = (m['direction'] as String?) ?? 'out';
        final note = m['note']?.toString() ?? '';
        final transactionType = m['type'] as String?;
        final ts = m['date'];

        String dateStr = '';
        if (ts is Timestamp) {
          final d = ts.toDate();
          dateStr =
              '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
        }

        String transactionTypeStr = '';
        if (transactionType == 'overtime') {
          transactionTypeStr = 'Mesai Ekleme';
        } else if (transactionType == 'overtime_deduction') {
          transactionTypeStr = 'Mesai Kesme';
        } else if (transactionType == 'payment') {
          transactionTypeStr = 'Ödeme';
        } else if (dir == 'in') {
          transactionTypeStr = 'Hak Ediş';
        } else {
          transactionTypeStr = 'Avans/Çıkış';
        }

        String description = note.isEmpty
            ? (transactionTypeStr == 'Mesai Ekleme' ||
                    transactionTypeStr == 'Mesai Kesme'
                ? transactionTypeStr
                : (dir == 'in' ? 'Ödeme' : 'Avans/Çıkış'))
            : note;

        // Format amount in Turkish format
        String formatAmount(double amount) {
          final parts = amount.abs().toStringAsFixed(2).split('.');
          final intPart = parts[0];
          final decPart = parts[1];
          final formattedInt = intPart.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
          return '$formattedInt,$decPart';
        }

        final formattedAmount = formatAmount(amount);
        final direction = dir == 'in' ? 'Giriş' : 'Çıkış';

        exportData.add([
          dateStr,
          transactionTypeStr,
          description,
          '$formattedAmount $currency',
          direction,
        ]);

        if (dir == 'in') {
          totalIn += amount;
        } else {
          totalOut += amount;
        }
      }

      // Özet bilgileri
      final summary = <String, dynamic>{
        'Toplam Giriş': '${formatAmount(totalIn)} $currency',
        'Toplam Çıkış': '${formatAmount(totalOut)} $currency',
        'Bakiye': '${formatAmount(totalIn - totalOut)} $currency',
        'Toplam İşlem': transactions.length,
      };

      // Export service kullan
      final exportService = ExportService();
      final fileBytes = await exportService.exportToPDF(
        title: '$employeeName - Hareketler',
        subtitle: 'Personel hareket raporu',
        headers: headers,
        data: exportData,
        summary: summary,
        tenantId: tenantId,
      );

      // Dosyayı kaydet
      fileName =
          '${employeeName.replaceAll(' ', '_')}_Hareketler_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final blob = web.Blob([fileBytes.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.HTMLAnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';
        web.document.body?.appendChild(anchor);
        anchor.click();
        anchor.remove();
        web.URL.revokeObjectURL(url);
      } else {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final filePath = path.join(directory.path, fileName);
          final file = File(filePath);
          await file.writeAsBytes(fileBytes);
        }
      }
    } catch (e) {
      error = e;
    } finally {
      // Dialog'u mutlaka kapat ve SnackBar göster
      if (dialogShown) {
        final finalError = error;
        final finalFileName = fileName;

        // Dialog'u kapat
        Future.microtask(() {
          try {
            if (context.mounted) {
              final navigator = Navigator.of(context, rootNavigator: true);
              if (navigator.canPop()) {
                navigator.pop();
              }
            }
          } catch (_) {
            // Context dispose edilmiş olabilir
          }
        });

        // SnackBar'ı göster (dialog kapandıktan sonra)
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            if (context.mounted) {
              if (finalError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Export hatası: $finalError'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (finalFileName != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PDF dosyası indirildi: $finalFileName'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (_) {
            // Context dispose edilmiş olabilir
          }
        });
      }
    }
  }

  // Format amount helper
  String formatAmount(double amount) {
    final parts = amount.abs().toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final formattedInt = intPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formattedInt,$decPart';
  }
}

class _AddEmployeeForm extends StatefulWidget {
  final List<String> departments;
  final List<String> categories;
  final List<String> positions;
  final VoidCallback onManagePositions;
  final ScrollController scrollController;
  final String? tenantId;
  const _AddEmployeeForm({
    required this.departments,
    required this.categories,
    required this.positions,
    required this.onManagePositions,
    required this.scrollController,
    this.tenantId,
  });

  @override
  State<_AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<_AddEmployeeForm> {
  CollectionReference<Map<String, dynamic>> _col(String name) {
    if (widget.tenantId != null && widget.tenantId!.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('tenants')
          .doc(widget.tenantId)
          .collection(name);
    }
    return FirebaseFirestore.instance.collection(name);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _salaryAmountController = TextEditingController();
  final TextEditingController _customPeriodNoteController =
      TextEditingController();
  // Aylık (İki Kere) için özel tutar alanları
  final TextEditingController _semiMonthlyAmount1Controller =
      TextEditingController();
  final TextEditingController _semiMonthlyAmount2Controller =
      TextEditingController();
  // Focus node'ları (Tab tuşu için)
  final FocusNode _salaryAmountFocusNode = FocusNode();
  final FocusNode _semiMonthlyAmount1FocusNode = FocusNode();
  final FocusNode _semiMonthlyAmount2FocusNode = FocusNode();

  // Selections
  DateTime? _birthDate;
  DateTime? _startDate;
  String? _selectedDepartment;
  String? _selectedCategory;
  String? _selectedPosition;
  String _salaryCurrency = 'TRY';
  String _entitlementType = 'Aylık';
  int? _monthlyDayOfMonth; // 1-31
  int? _semiMonthlyDay1;
  int? _semiMonthlyDay2;
  double? _semiMonthlyAmount1; // 1. ödeme günü tutarı
  double? _semiMonthlyAmount2; // 2. ödeme günü tutarı
  String? _weeklyWeekday; // Pazartesi, ...
  int _daysPerWeek = 5;
  final List<String> _weeklySelectedDays = [];
  // Aylık ve Aylık (İki Kere) için çalışma bilgileri
  int _monthlyDaysPerWeek = 5; // Haftada kaç gün
  int _monthlyHoursPerDay = 8; // Günde kaç saat

  // Uploads
  Uint8List? _photoBytes;
  String? _photoName;
  final List<_PickedDoc> _pickedDocs = [];

  bool _isSaving = false;

  // Live option lists
  List<String> _positionsLive = [];
  List<String> _categoriesLive = [];
  List<String> _departmentsLive = [];
  StreamSubscription? _posSub;
  StreamSubscription? _catSub;
  StreamSubscription? _deptSub;

  @override
  void initState() {
    super.initState();
    // Seed from parent (filter out "Tümü" for form dropdowns)
    _positionsLive = List<String>.from(widget.positions);
    _categoriesLive =
        List<String>.from(widget.categories).where((c) => c != 'Tümü').toList();
    _departmentsLive = List<String>.from(widget.departments)
        .where((d) => d != 'Tümü')
        .toList();
    // Başlangıçta _dayEnabled'e göre _weeklySelectedDays'i doldur
    for (final day in _weekdays) {
      if (_dayEnabled[day] == true) {
        _weeklySelectedDays.add(day);
      }
    }
    _daysPerWeek = _weeklySelectedDays.length;

    // Focus node'larına key event listener ekle
    _salaryAmountFocusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
        _handleSalaryAmountFormat();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    _semiMonthlyAmount1FocusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
        _handleSemiMonthlyAmount1Format();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    _semiMonthlyAmount2FocusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
        _handleSemiMonthlyAmount2Format();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    // Listen to Firestore for runtime updates
    _posSub = _col('positions').orderBy('name').snapshots().listen((s) {
      if (!mounted) return;
      final names = s.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _positionsLive = names;
        if (_selectedPosition != null &&
            !_positionsLive.contains(_selectedPosition)) {
          _selectedPosition = null;
        }
      });
    });
    _catSub =
        _col('employee_categories').orderBy('name').snapshots().listen((s) {
      if (!mounted) return;
      final names = s.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _categoriesLive = names;
        if (_selectedCategory != null &&
            !_categoriesLive.contains(_selectedCategory)) {
          _selectedCategory = null;
        }
      });
    });

    _deptSub = _col('departments').orderBy('name').snapshots().listen((s) {
      if (!mounted) return;
      final names = s.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _departmentsLive = names;
        if (_selectedDepartment != null &&
            !_departmentsLive.contains(_selectedDepartment)) {
          _selectedDepartment = null;
        }
      });
    });
  }

  void _updateTotalSalary() {
    if (_entitlementType == 'Aylık (İki Kere)') {
      final amount1Text = _semiMonthlyAmount1Controller.text.trim();
      final amount2Text = _semiMonthlyAmount2Controller.text.trim();

      if (amount1Text.isEmpty && amount2Text.isEmpty) {
        _salaryAmountController.clear();
        return;
      }

      final amount1 = double.tryParse(
              amount1Text.replaceAll('.', '').replaceAll(',', '.')) ??
          0;
      final amount2 = double.tryParse(
              amount2Text.replaceAll('.', '').replaceAll(',', '.')) ??
          0;
      final total = amount1 + amount2;

      if (total == 0) {
        _salaryAmountController.clear();
        return;
      }

      // Format: 1000.00 -> "1000,00" -> format edilmiş hali
      final totalStr = total.toStringAsFixed(2).replaceAll('.', ',');
      final formatted = _formatSalaryAmount(totalStr);
      _salaryAmountController.text = formatted;
    }
  }

  // Orantılı (pro-rata) maaş hesaplama fonksiyonu
  double _calculateProRataAmount({
    required String entitlementType,
    required Map<String, dynamic> entitlement,
    required double salaryAmount,
    required DateTime startDate,
    required DateTime paymentDate,
    required bool isFirstPayment,
  }) {
    // İlk ödeme değilse tam maaş
    if (!isFirstPayment) {
      if (entitlementType == 'Aylık (İki Kere)') {
        final amounts =
            entitlement['semiMonthlyAmounts'] as Map<String, dynamic>?;
        if (amounts != null) {
          final paymentDay = paymentDate.day.toString();
          final dayAmount = amounts[paymentDay];
          if (dayAmount != null) {
            return (dayAmount as num).toDouble();
          }
        }
        // Geriye dönük uyumluluk: yarıya böl
        return salaryAmount / 2;
      }
      return salaryAmount;
    }

    // İlk ödeme için orantılı hesaplama
    switch (entitlementType) {
      case 'Aylık':
        // Çalışılan gün sayısını hesapla
        final daysWorked = paymentDate.difference(startDate).inDays;
        if (daysWorked <= 0) return 0;

        // Eğer başlangıç ve ödeme aynı aydaysa, o ayın gün sayısını kullan
        // Eğer farklı aylardaysa, ödeme ayının gün sayısını kullan
        final daysInMonth = (startDate.year == paymentDate.year &&
                startDate.month == paymentDate.month)
            ? DateTime(startDate.year, startDate.month + 1, 0).day
            : DateTime(paymentDate.year, paymentDate.month + 1, 0).day;

        // Orantılı maaş: (Çalışılan gün / Ayın toplam günü) * Aylık Maaş
        return (daysWorked / daysInMonth) * salaryAmount;

      case 'Aylık (İki Kere)':
        // İlk ödeme gününe kadar çalışılan gün sayısı
        final daysWorked = paymentDate.difference(startDate).inDays;
        if (daysWorked <= 0) return 0;

        // Ödeme gününe kadar olan gün sayısı (ayın başından itibaren)
        final daysUntilPayment = paymentDate.day;

        // İlgili ödeme gününün tutarını al
        final amounts =
            entitlement['semiMonthlyAmounts'] as Map<String, dynamic>?;
        double baseAmount = salaryAmount / 2; // Varsayılan
        if (amounts != null) {
          final paymentDay = paymentDate.day.toString();
          final dayAmount = amounts[paymentDay];
          if (dayAmount != null) {
            baseAmount = (dayAmount as num).toDouble();
          }
        }

        // Orantılı maaş: (Çalışılan gün / Ödeme gününe kadar olan gün) * Ödeme günü tutarı
        return (daysWorked / daysUntilPayment) * baseAmount;

      case 'Haftalık':
        // Çalışılan gün sayısını hesapla
        final daysWorked = paymentDate.difference(startDate).inDays;
        if (daysWorked <= 0) return 0;

        // Haftada çalışılan gün sayısını al
        final daysPerWeek = entitlement['daysPerWeek'] as int? ?? 5;

        // Eğer çalışılan gün sayısı haftada çalışılan gün sayısına eşitse tam maaş
        if (daysWorked == daysPerWeek) {
          return salaryAmount;
        }

        // Değilse orantılı maaş: (Çalışılan gün / Haftada çalışılan gün) * Haftalık Maaş
        return (daysWorked / daysPerWeek) * salaryAmount;

      case 'Günlük':
        // Günlük maaş için çalışılan gün sayısı
        // paymentDate dahil değil, sadece startDate'den paymentDate'e kadar (paymentDate hariç)
        final daysWorked = paymentDate.difference(startDate).inDays;
        if (daysWorked <= 0) return 0;

        // Günlük maaş * çalışılan gün sayısı
        // Ancak sadece çalışma günlerini saymalıyız
        final weeklyDays = entitlement['weeklyDays'] as List?;
        if (weeklyDays != null && weeklyDays.isNotEmpty) {
          int workingDaysCount = 0;
          DateTime current = startDate;
          // paymentDate hariç, sadece startDate'den paymentDate'e kadar olan günleri say
          while (current.isBefore(paymentDate)) {
            final weekdayName = [
              'Pazartesi',
              'Salı',
              'Çarşamba',
              'Perşembe',
              'Cuma',
              'Cumartesi',
              'Pazar'
            ][current.weekday - 1];
            if (weeklyDays.contains(weekdayName)) {
              workingDaysCount++;
            }
            current = current.add(const Duration(days: 1));
          }
          return workingDaysCount * salaryAmount;
        }
        // Çalışma günleri bilgisi yoksa, tüm günleri say (paymentDate hariç)
        return daysWorked * salaryAmount;

      case 'Saatlik':
        // Saatlik maaş için orantılı hesaplama yapılmaz (çalışılan saat bilinmiyor)
        return salaryAmount;

      default:
        return salaryAmount;
    }
  }

  // Saatlik maaş hesaplama fonksiyonu
  double? _calculateHourlyRate() {
    double? salaryAmount;

    if (_entitlementType == 'Aylık (İki Kere)') {
      final amount1 = double.tryParse(_semiMonthlyAmount1Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0;
      final amount2 = double.tryParse(_semiMonthlyAmount2Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0;
      salaryAmount = amount1 + amount2;
    } else {
      salaryAmount = double.tryParse(_salaryAmountController.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0;
    }

    if (salaryAmount <= 0) return null;

    double hourlyRate = 0;

    switch (_entitlementType) {
      case 'Aylık':
      case 'Aylık (İki Kere)':
        final daysPerWeek = _monthlyDaysPerWeek;
        final hoursPerDay = _monthlyHoursPerDay;
        final weeklyHours = daysPerWeek * hoursPerDay;
        final monthlyHours = weeklyHours * 4.33; // Ortalama hafta sayısı
        hourlyRate = salaryAmount / monthlyHours;
        break;
      case 'Haftalık':
        final daysPerWeek = _daysPerWeek;
        const hoursPerDay = 8; // Varsayılan, günlük saat bilgisi yok
        hourlyRate = salaryAmount / (daysPerWeek * hoursPerDay);
        break;
      case 'Günlük':
        // Günlük maaş için ortalama saat hesapla
        if (_weeklySelectedDays.isEmpty) return null;
        double totalHours = 0;
        int workingDays = 0;
        for (final day in _weeklySelectedDays) {
          if (_dayEnabled[day] == true) {
            final start = _startTimes[day];
            final end = _endTimes[day];
            if (start != null && end != null) {
              final startMin = start.hour * 60 + start.minute;
              final endMin = end.hour * 60 + end.minute;
              if (endMin > startMin) {
                totalHours += (endMin - startMin) / 60.0;
                workingDays++;
              }
            }
          }
        }
        if (totalHours == 0 || workingDays == 0) return null;
        final avgHoursPerDay = totalHours / workingDays;
        hourlyRate = salaryAmount / avgHoursPerDay;
        break;
      case 'Saatlik':
        hourlyRate = salaryAmount;
        break;
      default:
        return null;
    }

    return hourlyRate;
  }

  // Formatlama fonksiyonları (Enter ve Tab için)
  void _handleSalaryAmountFormat() {
    if (_entitlementType != 'Aylık (İki Kere)') {
      final formatted = _formatSalaryAmount(_salaryAmountController.text);
      if (formatted != _salaryAmountController.text) {
        _salaryAmountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
    setState(() {}); // Saatlik maaş bilgisini güncelle
  }

  void _handleSemiMonthlyAmount1Format() {
    final value = _semiMonthlyAmount1Controller.text;
    if (value.isNotEmpty) {
      final formatted = _formatSalaryAmount(value);
      if (formatted != value) {
        _semiMonthlyAmount1Controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
    setState(() {
      _updateTotalSalary();
    });
  }

  void _handleSemiMonthlyAmount2Format() {
    final value = _semiMonthlyAmount2Controller.text;
    if (value.isNotEmpty) {
      final formatted = _formatSalaryAmount(value);
      if (formatted != value) {
        _semiMonthlyAmount2Controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
    setState(() {
      _updateTotalSalary();
    });
  }

  // Saatlik maaş hesaplama bilgisi dialog'u
  void _showHourlyRateCalculationInfo(BuildContext context) {
    final hourlyRate = _calculateHourlyRate();
    if (hourlyRate == null || hourlyRate <= 0) return;

    String calculationInfo = '';
    String formula = '';
    double? salaryAmount;

    if (_entitlementType == 'Aylık (İki Kere)') {
      final amount1 = double.tryParse(_semiMonthlyAmount1Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0;
      final amount2 = double.tryParse(_semiMonthlyAmount2Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0;
      salaryAmount = amount1 + amount2;
    } else {
      salaryAmount = double.tryParse(_salaryAmountController.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0;
    }

    final formattedSalary = _formatSalaryAmount(
        salaryAmount.toStringAsFixed(2).replaceAll('.', ','));

    switch (_entitlementType) {
      case 'Aylık':
      case 'Aylık (İki Kere)':
        final daysPerWeek = _monthlyDaysPerWeek;
        final hoursPerDay = _monthlyHoursPerDay;
        final weeklyHours = daysPerWeek * hoursPerDay;
        final monthlyHours = weeklyHours * 4.33;
        formula =
            '$formattedSalary $_salaryCurrency ÷ ($daysPerWeek gün/hafta × $hoursPerDay saat/gün × 4.33 hafta/ay)';
        calculationInfo = '''
Aylık Maaş: $formattedSalary $_salaryCurrency
Haftada Çalışılan Gün: $daysPerWeek gün
Günde Çalışılan Saat: $hoursPerDay saat
Haftalık Çalışma Saati: $daysPerWeek × $hoursPerDay = ${weeklyHours.toStringAsFixed(0)} saat
Aylık Çalışma Saati: ${weeklyHours.toStringAsFixed(0)} × 4.33 = ${monthlyHours.toStringAsFixed(2)} saat
Saatlik Maaş: $formattedSalary ÷ ${monthlyHours.toStringAsFixed(2)} = ${_formatSalaryAmount(hourlyRate.toStringAsFixed(2).replaceAll('.', ','))} $_salaryCurrency/saat
''';
        break;
      case 'Haftalık':
        final daysPerWeek = _daysPerWeek;
        const hoursPerDay = 8; // Varsayılan
        final weeklyHours = daysPerWeek * hoursPerDay;
        formula =
            '$formattedSalary $_salaryCurrency ÷ ($daysPerWeek gün/hafta × $hoursPerDay saat/gün)';
        calculationInfo = '''
Haftalık Maaş: $formattedSalary $_salaryCurrency
Haftada Çalışılan Gün: $daysPerWeek gün
Günde Çalışılan Saat: $hoursPerDay saat (varsayılan)
Haftalık Çalışma Saati: $daysPerWeek × $hoursPerDay = $weeklyHours saat
Saatlik Maaş: $formattedSalary ÷ $weeklyHours = ${_formatSalaryAmount(hourlyRate.toStringAsFixed(2).replaceAll('.', ','))} $_salaryCurrency/saat

Not: İlk ödeme için, çalışılan gün sayısı haftada çalışılan gün sayısına ($daysPerWeek) eşitse tam maaş, değilse orantılı hesaplama yapılır.
''';
        break;
      case 'Günlük':
        if (_weeklySelectedDays.isEmpty) return;
        double totalHours = 0;
        int workingDays = 0;
        for (final day in _weeklySelectedDays) {
          if (_dayEnabled[day] == true) {
            final start = _startTimes[day];
            final end = _endTimes[day];
            if (start != null && end != null) {
              final startMin = start.hour * 60 + start.minute;
              final endMin = end.hour * 60 + end.minute;
              if (endMin > startMin) {
                totalHours += (endMin - startMin) / 60.0;
                workingDays++;
              }
            }
          }
        }
        if (totalHours == 0 || workingDays == 0) return;
        final avgHoursPerDay = totalHours / workingDays;
        formula =
            '$formattedSalary $_salaryCurrency ÷ ${avgHoursPerDay.toStringAsFixed(2)} saat/gün';
        calculationInfo = '''
Günlük Maaş: $formattedSalary $_salaryCurrency
Çalışılan Günler: ${_weeklySelectedDays.join(', ')}
Toplam Çalışma Saati: ${totalHours.toStringAsFixed(2)} saat
Çalışılan Gün Sayısı: $workingDays gün
Ortalama Günlük Çalışma Saati: ${totalHours.toStringAsFixed(2)} ÷ $workingDays = ${avgHoursPerDay.toStringAsFixed(2)} saat
Saatlik Maaş: $formattedSalary ÷ ${avgHoursPerDay.toStringAsFixed(2)} = ${_formatSalaryAmount(hourlyRate.toStringAsFixed(2).replaceAll('.', ','))} $_salaryCurrency/saat
''';
        break;
      case 'Saatlik':
        formula = '$formattedSalary $_salaryCurrency (direkt saatlik ücret)';
        calculationInfo = '''
Saatlik Maaş: $formattedSalary $_salaryCurrency/saat
Bu maaş türü zaten saatlik ücret olduğu için hesaplama yapılmamıştır.
''';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.calculate, size: 24),
            SizedBox(width: 8),
            Text('Saatlik Maaş Hesaplaması'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Formül:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                formula,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hesaplama Detayları:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                calculationInfo.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Format salary amount in Turkish format (1.000,00)
  String _formatSalaryAmount(String value) {
    if (value.trim().isEmpty) return '';

    // Remove all formatting characters
    String cleaned = value.replaceAll(RegExp(r'[^\d,]'), '');

    // Split integer and decimal parts
    String integerPart = cleaned;
    String? decimalPart;

    if (cleaned.contains(',')) {
      final parts = cleaned.split(',');
      integerPart = parts[0];
      if (parts.length > 1) {
        decimalPart = parts[1];
      }
    }

    // Remove all non-digits from integer part
    integerPart = integerPart.replaceAll(RegExp(r'[^\d]'), '');

    if (integerPart.isEmpty) return '';

    // Format integer part with thousand separators
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    String result = buffer.toString();

    // Always add decimal part (2 digits)
    if (decimalPart != null && decimalPart.isNotEmpty) {
      // Pad or truncate to 2 digits
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      } else {
        decimalPart = decimalPart.padRight(2, '0');
      }
      result += ',$decimalPart';
    } else {
      result += ',00';
    }

    return result;
  }

  // Çalışma takvimi (saatlik/günlük)
  final List<String> _weekdays = const [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];
  late final Map<String, bool> _dayEnabled = {
    'Pazartesi': true,
    'Salı': true,
    'Çarşamba': true,
    'Perşembe': true,
    'Cuma': true,
    'Cumartesi': false,
    'Pazar': false,
  };
  late final Map<String, TimeOfDay> _startTimes = {
    for (final d in _weekdays) d: const TimeOfDay(hour: 9, minute: 0)
  };
  late final Map<String, TimeOfDay> _endTimes = {
    for (final d in _weekdays) d: const TimeOfDay(hour: 18, minute: 0)
  };

  // Fazla mesai
  bool _overtimeEnabled = false;
  // Saatlik için takvim opsiyonel
  bool _hourlyScheduleEnabled = false;
  final TextEditingController _overtimeThresholdHoursController =
      TextEditingController(text: '8');
  final TextEditingController _overtimeMultiplierController =
      TextEditingController(text: '1.5');

  // Calculate payment dates based on entitlement type
  List<DateTime> _calculatePaymentDates({
    required DateTime startDate,
    required String entitlementType,
    int? monthlyDayOfMonth,
    int? semiMonthlyDay1,
    int? semiMonthlyDay2,
    String? weeklyWeekday,
    int? daysPerWeek,
    List<String>? weeklySelectedDays,
  }) {
    final List<DateTime> paymentDates = [];

    // Haftanın günlerini sayıya çevirme
    int getWeekdayNumber(String weekday) {
      const weekdays = {
        'Pazartesi': 1,
        'Salı': 2,
        'Çarşamba': 3,
        'Perşembe': 4,
        'Cuma': 5,
        'Cumartesi': 6,
        'Pazar': 7,
      };
      return weekdays[weekday] ?? 1;
    }

    // Belirli bir tarihten sonraki ilk belirli günü bul
    DateTime findNextWeekday(DateTime from, int targetWeekday) {
      DateTime current = from;
      // Eğer bugün hedef günse, bir sonraki haftaya geç
      if (current.weekday == targetWeekday) {
        current = current.add(const Duration(days: 7));
      } else {
        // Bir sonraki hedef günü bul
        current = current.add(const Duration(days: 1));
        while (current.weekday != targetWeekday) {
          current = current.add(const Duration(days: 1));
        }
      }
      return current;
    }

    switch (entitlementType) {
      case 'Aylık':
        if (monthlyDayOfMonth != null) {
          // Geçersiz değerleri düzelt (1-31 arasında olmalı)
          final validDay = monthlyDayOfMonth >= 1 && monthlyDayOfMonth <= 31
              ? monthlyDayOfMonth
              : 31;

          // İşe başlama tarihinden itibaren ilk ödeme gününü hesapla
          DateTime firstPayment = DateTime(
            startDate.year,
            startDate.month,
            validDay,
          );

          // Eğer işe başlama tarihinden önceyse veya aynı günse, bir sonraki aya al
          if (firstPayment.isBefore(startDate) ||
              firstPayment.isAtSameMomentAs(startDate)) {
            firstPayment = DateTime(
              startDate.year,
              startDate.month + 1,
              validDay,
            );
          }

          paymentDates.add(firstPayment);
        }
        break;

      case 'Aylık (İki Kere)':
        if (semiMonthlyDay1 != null && semiMonthlyDay2 != null) {
          final day1 = semiMonthlyDay1 < semiMonthlyDay2
              ? semiMonthlyDay1
              : semiMonthlyDay2;
          final day2 = semiMonthlyDay1 < semiMonthlyDay2
              ? semiMonthlyDay2
              : semiMonthlyDay1;

          // İlk ödeme: Ayın ilk günü
          DateTime firstPayment = DateTime(
            startDate.year,
            startDate.month,
            day1,
          );
          if (firstPayment.isBefore(startDate) ||
              firstPayment.isAtSameMomentAs(startDate)) {
            firstPayment = DateTime(
              startDate.year,
              startDate.month + 1,
              day1,
            );
          }
          paymentDates.add(firstPayment);

          // İkinci ödeme: Ayın ikinci günü (aynı ay veya bir sonraki ay)
          DateTime secondPayment = DateTime(
            firstPayment.year,
            firstPayment.month,
            day2,
          );
          if (secondPayment.isBefore(startDate) ||
              secondPayment.isBefore(firstPayment)) {
            secondPayment = DateTime(
              firstPayment.year,
              firstPayment.month + 1,
              day2,
            );
          }
          paymentDates.add(secondPayment);
        }
        break;

      case 'Haftalık':
        if (weeklyWeekday != null) {
          final targetWeekday = getWeekdayNumber(weeklyWeekday);
          final firstPayment = findNextWeekday(startDate, targetWeekday);
          paymentDates.add(firstPayment);
        }
        break;

      case 'Günlük':
        if (weeklySelectedDays != null && weeklySelectedDays.isNotEmpty) {
          // İlk çalışma gününü bul (başlangıç tarihinden sonraki)
          DateTime current = startDate.add(const Duration(days: 1));
          int maxDays = 14; // 2 hafta içinde bul
          int checked = 0;
          while (checked < maxDays) {
            final weekdayName = [
              'Pazartesi',
              'Salı',
              'Çarşamba',
              'Perşembe',
              'Cuma',
              'Cumartesi',
              'Pazar'
            ][current.weekday - 1];
            if (weeklySelectedDays.contains(weekdayName)) {
              paymentDates.add(current);
              break;
            }
            current = current.add(const Duration(days: 1));
            checked++;
          }
        }
        break;

      case 'Saatlik':
        // Saatlik için ay sonunu kullan
        DateTime monthEnd = DateTime(
          startDate.year,
          startDate.month + 1,
          0, // Ayın son günü
        );
        if (monthEnd.isBefore(startDate) ||
            monthEnd.isAtSameMomentAs(startDate)) {
          monthEnd = DateTime(
            startDate.year,
            startDate.month + 2,
            0,
          );
        }
        paymentDates.add(monthEnd);
        break;

      default:
        // Varsayılan olarak işe başlama tarihini kullan
        paymentDates.add(startDate);
    }

    return paymentDates;
  }

  // Get transaction note based on entitlement type
  String _getTransactionNote({
    required String entitlementType,
    required DateTime paymentDate,
  }) {
    final dateStr =
        '${paymentDate.day.toString().padLeft(2, '0')}.${paymentDate.month.toString().padLeft(2, '0')}.${paymentDate.year}';

    switch (entitlementType) {
      case 'Aylık':
        return 'Aylık Maaş - $dateStr';
      case 'Aylık (İki Kere)':
        return 'Aylık Maaş (Yarı Dönem) - $dateStr';
      case 'Haftalık':
        return 'Haftalık Maaş - $dateStr';
      case 'Günlük':
        return 'Günlük Maaş - $dateStr';
      case 'Saatlik':
        return 'Saatlik Maaş - $dateStr';
      default:
        return 'Maaş Ödemesi - $dateStr';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tcController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _salaryAmountController.dispose();
    _customPeriodNoteController.dispose();
    _semiMonthlyAmount1Controller.dispose();
    _semiMonthlyAmount2Controller.dispose();
    _salaryAmountFocusNode.dispose();
    _semiMonthlyAmount1FocusNode.dispose();
    _semiMonthlyAmount2FocusNode.dispose();
    _overtimeThresholdHoursController.dispose();
    _overtimeMultiplierController.dispose();
    _posSub?.cancel();
    _catSub?.cancel();
    _deptSub?.cancel();
    super.dispose();
  }

  // Eski birleşik diyalog kaldırıldı (departman+kategori). Ayrı diyaloglar kullanılıyor.

  void _openManageDepartments() {
    final deptCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Departmanlar'),
          content: SizedBox(
            width: 520,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: deptCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Yeni departman adı'))),
                    const SizedBox(width: 8),
                    FilledButton(
                        onPressed: () async {
                          final name = deptCtrl.text.trim();
                          if (name.isEmpty) return;
                          if (widget.tenantId == null ||
                              widget.tenantId!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Tenant bilgisi yüklenmedi. Lütfen tekrar deneyin.')));
                            return;
                          }
                          final exists = await _col('departments')
                              .where('name', isEqualTo: name)
                              .limit(1)
                              .get();
                          if (exists.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Bu departman zaten var')));
                            return;
                          }
                          await _col('departments').add({
                            'name': name,
                            'tenantId': widget.tenantId,
                            'createdBy': FirebaseAuth.instance.currentUser?.uid,
                            'createdAt': FieldValue.serverTimestamp()
                          });
                          deptCtrl.clear();
                        },
                        child: const Text('Ekle')),
                  ]),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _col('departments').orderBy('name').snapshots(),
                    builder: (context, snap) {
                      if (!context.mounted) {
                        return const SizedBox.shrink();
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                    'Departman Düzenle'),
                                                content: TextField(
                                                    controller: editCtrl,
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText: 'Ad')),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(false),
                                                      child:
                                                          const Text('İptal')),
                                                  FilledButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(true),
                                                      child:
                                                          const Text('Kaydet'))
                                                ]));
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  }),
                              IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    // Bu departmana ait personel var mı kontrol et
                                    final employeesWithDept =
                                        await _col('employees')
                                            .where('department',
                                                isEqualTo: name)
                                            .limit(1)
                                            .get();

                                    if (employeesWithDept.docs.isNotEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '"$name" departmanına ait personel bulunduğu için silinemez. Önce personelleri başka bir departmana aktarın.',
                                            ),
                                            backgroundColor: Colors.orange,
                                            duration:
                                                const Duration(seconds: 4),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                                title:
                                                    const Text('Departman Sil'),
                                                content: Text(
                                                    '"$name" silinsin mi?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(false),
                                                      child:
                                                          const Text('Vazgeç')),
                                                  FilledButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(true),
                                                      child: const Text('Sil'))
                                                ]));
                                    if (ok == true) {
                                      // Tekrar kontrol et (güvenlik için)
                                      final recheck = await _col('employees')
                                          .where('department', isEqualTo: name)
                                          .limit(1)
                                          .get();

                                      if (recheck.docs.isNotEmpty) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '"$name" departmanına ait personel bulunduğu için silinemez.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      await d.reference.delete();
                                      if (mounted &&
                                          _selectedDepartment == name) {
                                        setState(
                                            () => _selectedDepartment = null);
                                      }
                                    }
                                  }),
                            ]),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'))
          ],
        );
      },
    );
  }

  void _openManageCategories() {
    final catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kategoriler'),
          content: SizedBox(
            width: 520,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: catCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Yeni kategori adı'))),
                    const SizedBox(width: 8),
                    FilledButton(
                        onPressed: () async {
                          final name = catCtrl.text.trim();
                          if (name.isEmpty) return;
                          if (widget.tenantId == null ||
                              widget.tenantId!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Tenant bilgisi yüklenmedi. Lütfen tekrar deneyin.')));
                            return;
                          }
                          final exists = await _col('employee_categories')
                              .where('name', isEqualTo: name)
                              .limit(1)
                              .get();
                          if (exists.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Bu kategori zaten var')));
                            return;
                          }
                          await _col('employee_categories').add({
                            'name': name,
                            'tenantId': widget.tenantId,
                            'createdBy': FirebaseAuth.instance.currentUser?.uid,
                            'createdAt': FieldValue.serverTimestamp()
                          });
                          catCtrl.clear();
                        },
                        child: const Text('Ekle')),
                  ]),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream:
                        _col('employee_categories').orderBy('name').snapshots(),
                    builder: (context, snap) {
                      if (!context.mounted) {
                        return const SizedBox.shrink();
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                    'Kategori Düzenle'),
                                                content: TextField(
                                                    controller: editCtrl,
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText: 'Ad')),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(false),
                                                      child:
                                                          const Text('İptal')),
                                                  FilledButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(true),
                                                      child:
                                                          const Text('Kaydet'))
                                                ]));
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  }),
                              IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    // Bu kategoriye ait personel var mı kontrol et
                                    final employeesWithCat =
                                        await _col('employees')
                                            .where('category', isEqualTo: name)
                                            .limit(1)
                                            .get();

                                    if (employeesWithCat.docs.isNotEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '"$name" kategorisine ait personel bulunduğu için silinemez. Önce personelleri başka bir kategoriye aktarın.',
                                            ),
                                            backgroundColor: Colors.orange,
                                            duration:
                                                const Duration(seconds: 4),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                                title:
                                                    const Text('Kategori Sil'),
                                                content: Text(
                                                    '"$name" silinsin mi?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(false),
                                                      child:
                                                          const Text('Vazgeç')),
                                                  FilledButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(true),
                                                      child: const Text('Sil'))
                                                ]));
                                    if (ok == true) {
                                      // Tekrar kontrol et (güvenlik için)
                                      final recheck = await _col('employees')
                                          .where('category', isEqualTo: name)
                                          .limit(1)
                                          .get();

                                      if (recheck.docs.isNotEmpty) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '"$name" kategorisine ait personel bulunduğu için silinemez.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      await d.reference.delete();
                                    }
                                  }),
                            ]),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'))
          ],
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickPhoto() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fotoğraf Seç'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera ile Çek'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final XFile? file =
          await picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();

      // Check file size limit (4MB)
      const maxPhotoSize = 4 * 1024 * 1024; // 4MB in bytes
      if (bytes.length > maxPhotoSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fotoğraf boyutu 4MB\'dan büyük olamaz'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _photoBytes = bytes;
        _photoName = file.name;
      });
    } catch (_) {}
  }

  Future<void> _pickDocuments() async {
    try {
      // Check document count limit (max 10)
      if (_pickedDocs.length >= 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimum 10 döküman ekleyebilirsiniz'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Calculate current total size
      int currentTotalSize = 0;
      for (final doc in _pickedDocs) {
        currentTotalSize += doc.bytes.length;
      }

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );
      if (result == null) return;

      const maxTotalSize = 20 * 1024 * 1024; // 20MB in bytes

      int newFilesCount = 0;
      int newFilesSize = 0;

      for (final f in result.files) {
        if (f.bytes == null) continue;

        // Check remaining slots
        if (_pickedDocs.length + newFilesCount >= 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Maksimum 10 döküman limitine ulaşıldı. Sadece $newFilesCount dosya eklendi.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          break;
        }

        // Check total size limit
        if (currentTotalSize + newFilesSize + f.bytes!.length > maxTotalSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Toplam boyut 20MB limitini aşıyor. Sadece $newFilesCount dosya eklendi.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          break;
        }

        _pickedDocs.add(_PickedDoc(name: f.name, bytes: f.bytes!));
        newFilesCount++;
        newFilesSize += f.bytes!.length;
      }

      if (newFilesCount > 0) {
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doğru şekilde doldurun'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Doğum tarihi seçin')));
      return;
    }
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Departman seçin')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kategori seçin')));
      return;
    }
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşe başlama tarihi seçin')));
      return;
    }

    // Entitlement validations
    if (_entitlementType == 'Aylık') {
      if (_monthlyDayOfMonth == null ||
          _monthlyDayOfMonth! < 1 ||
          _monthlyDayOfMonth! > 31) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ayın gününü 1-31 arasında seçin')));
        return;
      }
    } else if (_entitlementType == 'Aylık (İki Kere)') {
      if (_semiMonthlyDay1 == null || _semiMonthlyDay2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Her iki ödeme gününü de seçin')));
        return;
      }
      if (_semiMonthlyDay1 == _semiMonthlyDay2) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Günler farklı olmalı')));
        return;
      }
      // Tutar kontrolü
      final amount1 = double.tryParse(_semiMonthlyAmount1Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0;
      final amount2 = double.tryParse(_semiMonthlyAmount2Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0;
      if (amount1 <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_semiMonthlyDay1. gün için tutar girin')));
        return;
      }
      if (amount2 <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_semiMonthlyDay2. gün için tutar girin')));
        return;
      }
    } else if (_entitlementType == 'Haftalık') {
      if (_weeklyWeekday == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Haftanın gününü seçin')));
        return;
      }
    } else if (_entitlementType == 'Günlük') {
      // Günler saat seçimi ile otomatik seçildiği için sadece kontrol et
      if (_weeklySelectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('En az bir gün için çalışma saatleri seçin')));
        return;
      }
      // Seçili günler için saat kontrolü yap
      for (final d in _weeklySelectedDays) {
        if (_dayEnabled[d] == true) {
          final s = _startTimes[d]!;
          final e = _endTimes[d]!;
          final sMin = s.hour * 60 + s.minute;
          final eMin = e.hour * 60 + e.minute;
          if (eMin <= sMin) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Çalışma saatleri geçersiz: $d')),
            );
            return;
          }
        }
      }
    } else if (_entitlementType == 'Saatlik' && _hourlyScheduleEnabled) {
      // Saatlik + takvim aktif ise saat kontrolleri
      for (final d in _weekdays) {
        if (_dayEnabled[d] == true) {
          final s = _startTimes[d]!;
          final e = _endTimes[d]!;
          final sMin = s.hour * 60 + s.minute;
          final eMin = e.hour * 60 + e.minute;
          if (eMin <= sMin) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Çalışma saatleri geçersiz: $d')),
            );
            return;
          }
        }
      }
    }

    if (!mounted) return;

    setState(() => _isSaving = true);

    // Show loading dialog
    BuildContext? dialogContext;
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) {
          dialogContext = dialogCtx;
          return const PopScope(
            canPop: false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                      'Personel ekleniyor...\nFotoğraf ve dökümanlar yükleniyor...'),
                ],
              ),
            ),
          );
        },
      );
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;

      // Helper to add timeouts to awaits to prevent indefinite hangs
      Future<T> withTimeout<T>(Future<T> future, String operation,
          {Duration timeout = const Duration(seconds: 30)}) async {
        try {
          return await future.timeout(timeout);
        } on TimeoutException {
          throw Exception('$operation zaman aşımına uğradı');
        }
      }

      // Create doc first to get ID
      final entitlement = <String, dynamic>{
        'type': _entitlementType,
      };
      if (_entitlementType == 'Aylık') {
        entitlement['monthlyDayOfMonth'] = _monthlyDayOfMonth;
        entitlement['daysPerWeek'] = _monthlyDaysPerWeek;
        entitlement['hoursPerDay'] = _monthlyHoursPerDay;
      } else if (_entitlementType == 'Aylık (İki Kere)') {
        final days = [_semiMonthlyDay1, _semiMonthlyDay2]..sort();
        entitlement['semiMonthlyDays'] = days;
        entitlement['daysPerWeek'] = _monthlyDaysPerWeek;
        entitlement['hoursPerDay'] = _monthlyHoursPerDay;
        // Her ödeme günü için tutarları kaydet
        final amount1 = double.tryParse(_semiMonthlyAmount1Controller.text
                .replaceAll('.', '')
                .replaceAll(',', '.')) ??
            0;
        final amount2 = double.tryParse(_semiMonthlyAmount2Controller.text
                .replaceAll('.', '')
                .replaceAll(',', '.')) ??
            0;
        // Gün numaralarına göre tutarları eşleştir
        entitlement['semiMonthlyAmounts'] = {
          _semiMonthlyDay1.toString(): amount1,
          _semiMonthlyDay2.toString(): amount2,
        };
      } else if (_entitlementType == 'Haftalık') {
        entitlement['weeklyWeekday'] = _weeklyWeekday;
        entitlement['daysPerWeek'] = _daysPerWeek;
      } else if (_entitlementType == 'Günlük') {
        entitlement['daysPerWeek'] = _daysPerWeek;
        entitlement['weeklyDays'] = List<String>.from(_weeklySelectedDays);
        // Günlük maaş için ortalama günlük çalışma saatini hesapla
        // Eğer çalışma saatleri belirlenmişse, ortalama saat hesapla
        int totalHours = 0;
        int enabledDays = 0;
        for (final d in _weekdays) {
          if (_dayEnabled[d] == true) {
            final start = _startTimes[d]!;
            final end = _endTimes[d]!;
            final startMinutes = start.hour * 60 + start.minute;
            final endMinutes = end.hour * 60 + end.minute;
            final dayHours = (endMinutes - startMinutes) / 60;
            if (dayHours > 0) {
              totalHours += dayHours.round();
              enabledDays++;
            }
          }
        }
        // Ortalama günlük saat hesapla, yoksa varsayılan 8 saat
        final avgHoursPerDay =
            enabledDays > 0 ? (totalHours / enabledDays).round() : 8;
        entitlement['hoursPerDay'] = avgHoursPerDay;
      }

      // Çalışma takvimi ve fazla mesai
      final Map<String, dynamic> schedule = {};
      // Work hours (only if daily or hourly with schedule enabled)
      if (_entitlementType == 'Günlük' ||
          (_entitlementType == 'Saatlik' && _hourlyScheduleEnabled)) {
        final workHours = <String, Map<String, String>>{};
        for (final d in _weekdays) {
          if (_dayEnabled[d] == true) {
            workHours[d] = {
              'start': _formatTimeOfDay(_startTimes[d]!),
              'end': _formatTimeOfDay(_endTimes[d]!),
            };
          }
        }
        schedule['workHours'] = workHours;

        if (_overtimeEnabled) {
          final threshold = double.tryParse(_overtimeThresholdHoursController
                  .text
                  .replaceAll(',', '.')) ??
              0;
          final multiplier = double.tryParse(
                  _overtimeMultiplierController.text.replaceAll(',', '.')) ??
              1.0;
          schedule['overtime'] = {
            'enabled': true,
            'thresholdHoursPerDay': threshold,
            'multiplier': multiplier,
          };
        } else {
          schedule['overtime'] = {'enabled': false};
        }
      }

      final employeesCol =
          (widget.tenantId != null && widget.tenantId!.isNotEmpty)
              ? FirebaseFirestore.instance
                  .collection('tenants')
                  .doc(widget.tenantId)
                  .collection('employees')
              : firestore.collection('employees');
      final docRef = await withTimeout(
        employeesCol.add({
          'name': _nameController.text.trim(),
          'tc': _tcController.text.trim(),
          'email': _emailController.text.trim(),
          'birthDate': Timestamp.fromDate(_birthDate!),
          'startDate': Timestamp.fromDate(_startDate!),
          'department': _selectedDepartment,
          'position': (_selectedPosition ?? _positionController.text.trim()),
          'category': _selectedCategory,
          'salary': {
            'amount': _entitlementType == 'Aylık (İki Kere)'
                ? (double.tryParse(_semiMonthlyAmount1Controller.text
                            .replaceAll('.', '')
                            .replaceAll(',', '.')) ??
                        0) +
                    (double.tryParse(_semiMonthlyAmount2Controller.text
                            .replaceAll('.', '')
                            .replaceAll(',', '.')) ??
                        0)
                : (double.tryParse(_salaryAmountController.text
                        .replaceAll('.', '') // Remove thousand separators
                        .replaceAll(',', '.')) ??
                    0),
            'currency': _salaryCurrency,
          },
          'entitlement': entitlement,
          if (schedule.isNotEmpty) 'schedule': schedule,
          'photoUrl': null,
          'documents': [],
          'autoEntitlementEnabled': true, // Varsayılan olarak açık
          'tenantId': widget.tenantId,
          'createdBy': FirebaseAuth.instance.currentUser?.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        'Personel kaydı oluşturma',
      );

      final String employeeId = docRef.id;
      String? photoUrl;
      final List<Map<String, dynamic>> docUrls = [];

      // Build storage path with tenantId if available
      final String storagePrefix =
          (widget.tenantId != null && widget.tenantId!.isNotEmpty)
              ? 'tenants/${widget.tenantId}/employees/$employeeId'
              : 'employees/$employeeId';

      // Upload photo
      if (_photoBytes != null && _photoName != null) {
        final ref = storage.ref().child('$storagePrefix/photo/$_photoName');
        final snap = await withTimeout(
          ref.putData(
            _photoBytes!,
            SettableMetadata(contentType: 'image/jpeg'),
          ),
          'Fotoğraf yükleme',
        );
        photoUrl = await withTimeout(
          snap.ref.getDownloadURL(),
          'Fotoğraf linki alma',
        );
      }

      // Upload documents
      for (final d in _pickedDocs) {
        final ref = storage.ref().child('$storagePrefix/docs/${d.name}');
        final contentType = d.name.toLowerCase().endsWith('.pdf')
            ? 'application/pdf'
            : 'image/jpeg';
        final snap = await withTimeout(
          ref.putData(
            d.bytes,
            SettableMetadata(contentType: contentType),
          ),
          'Döküman yükleme (${d.name})',
        );
        final url = await withTimeout(
          snap.ref.getDownloadURL(),
          'Döküman linki alma (${d.name})',
        );
        docUrls.add({'name': d.name, 'url': url});
      }

      // Update document with URLs
      await withTimeout(
          docRef.update({
            'photoUrl': photoUrl,
            'documents': docUrls,
            'updatedAt': FieldValue.serverTimestamp(),
          }),
          'Kayıt güncelleme');

      // Calculate salary amount
      final salaryAmount = _entitlementType == 'Aylık (İki Kere)'
          ? (double.tryParse(_semiMonthlyAmount1Controller.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.')) ??
                  0) +
              (double.tryParse(_semiMonthlyAmount2Controller.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.')) ??
                  0)
          : (double.tryParse(_salaryAmountController.text
                  .replaceAll('.', '') // Remove thousand separators
                  .replaceAll(',', '.')) ??
              0);

      // Auto-create entitlement transaction(s) based on payment period
      // Saatlik maaş için otomatik hak ediş oluşturma (çalışılan saat bilinmediği için)
      if (salaryAmount > 0 && _entitlementType != 'Saatlik') {
        try {
          final transactionsCol = (widget.tenantId != null &&
                  widget.tenantId!.isNotEmpty)
              ? FirebaseFirestore.instance
                  .collection('tenants')
                  .doc(widget.tenantId)
                  .collection('employee_transactions')
              : FirebaseFirestore.instance.collection('employee_transactions');

          final List<DateTime> paymentDates = _calculatePaymentDates(
            startDate: _startDate!,
            entitlementType: _entitlementType,
            monthlyDayOfMonth: _monthlyDayOfMonth,
            semiMonthlyDay1: _semiMonthlyDay1,
            semiMonthlyDay2: _semiMonthlyDay2,
            weeklyWeekday: _weeklyWeekday,
            daysPerWeek: _daysPerWeek,
            weeklySelectedDays: _weeklySelectedDays,
          );

          // Personelin kaydedildiği tarih (şu anki zaman)
          final now = DateTime.now();

          // Otomatik hak ediş başlangıç tarihi: personelin kaydedildiği tarih ile işe başlama tarihinden daha geç olan
          // Eğer personel gelecekte başlayacaksa (startDate > now), startDate kullan
          // Eğer geriye dönük kayıt yapılıyorsa (startDate < now), now kullan
          final effectiveStartDate =
              _startDate!.isAfter(now) ? _startDate! : now;

          // Sadece bugüne kadar olan ödeme tarihleri için transaction oluştur
          // Gelecekteki tarihler için transaction oluşturulmamalı (tarihi gelmeden eklenmesin)
          final effectivePaymentDates = paymentDates
              .where((date) => date.isBefore(now) || date.isAtSameMomentAs(now))
              .toList();

          // Create transaction(s) for each payment date
          for (int i = 0; i < effectivePaymentDates.length; i++) {
            final paymentDate = effectivePaymentDates[i];
            final isFirstPayment = i == 0;

            final transactionNote = _getTransactionNote(
              entitlementType: _entitlementType,
              paymentDate: paymentDate,
            );

            // Entitlement map'ini oluştur
            final Map<String, dynamic> entitlementMap = {
              'type': _entitlementType,
            };
            if (_entitlementType == 'Aylık (İki Kere)') {
              final amount1 = double.tryParse(_semiMonthlyAmount1Controller.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.')) ??
                  0;
              final amount2 = double.tryParse(_semiMonthlyAmount2Controller.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.')) ??
                  0;
              entitlementMap['semiMonthlyAmounts'] = {
                _semiMonthlyDay1.toString(): amount1,
                _semiMonthlyDay2.toString(): amount2,
              };
            } else if (_entitlementType == 'Haftalık') {
              entitlementMap['weeklyWeekday'] = _weeklyWeekday;
              entitlementMap['daysPerWeek'] = _daysPerWeek;
            } else if (_entitlementType == 'Günlük') {
              entitlementMap['weeklyDays'] =
                  List<String>.from(_weeklySelectedDays);
            }

            // İlk ödeme için orantılı maaş hesapla (effectiveStartDate kullan)
            double transactionAmount = _calculateProRataAmount(
              entitlementType: _entitlementType,
              entitlement: entitlementMap,
              salaryAmount: salaryAmount,
              startDate: effectiveStartDate,
              paymentDate: paymentDate,
              isFirstPayment: isFirstPayment,
            );

            await withTimeout(
              transactionsCol.add({
                'employeeId': employeeId,
                'amount': transactionAmount,
                'direction': 'in', // Alacak (personel için ödenecek)
                'note': transactionNote,
                'date': Timestamp.fromDate(paymentDate),
                'tenantId': widget.tenantId,
                'createdBy': FirebaseAuth.instance.currentUser?.uid,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              }),
              'Otomatik alacak kaydı oluşturma',
            );
          }
        } catch (e) {
          // Log error but don't fail the employee creation
          debugPrint('Otomatik alacak kaydı oluşturulurken hata: $e');
        }
      }

      if (mounted) {
        // Close loading dialog if it's still open
        if (dialogContext != null) {
          try {
            Navigator.of(dialogContext!).pop();
          } catch (_) {
            // Dialog might already be closed
          }
        }
        // Close form dialog
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Personel başarıyla eklendi'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if it's still open
        if (dialogContext != null) {
          try {
            Navigator.of(dialogContext!).pop();
          } catch (_) {
            // Dialog might already be closed
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt sırasında hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Yeni Personel Ekle',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Kapat',
                    )
                  ],
                ),
                const SizedBox(height: 8),

                // Photo picker and Name
                Row(
                  children: [
                    GestureDetector(
                      onTap: _isSaving ? null : _pickPhoto,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: _photoBytes != null
                            ? MemoryImage(_photoBytes!)
                            : null,
                        child: _photoBytes == null
                            ? const Icon(Icons.person, size: 32)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'İsim Soyisim'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-ZçğıöşüÇĞIİÖŞÜ\s]'),
                          ),
                        ],
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Zorunlu alan'
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Saatlik: takvim bölümünü opsiyonel yap
                if (_entitlementType == 'Saatlik') ...[
                  SwitchListTile(
                    title: const Text('Çalışma Takvimi (opsiyonel)'),
                    value: _hourlyScheduleEnabled,
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _hourlyScheduleEnabled = v),
                  ),
                  if (_hourlyScheduleEnabled) ...[
                    const SizedBox(height: 6),
                    Text('Çalışma Saatleri',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Column(
                      children: _weekdays.map((d) {
                        final enabled = _dayEnabled[d] ?? false;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 140,
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: Text(d),
                                  value: enabled,
                                  onChanged: _isSaving
                                      ? null
                                      : (v) => setState(
                                          () => _dayEnabled[d] = v ?? false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _isSaving || !enabled
                                          ? null
                                          : () async {
                                              final picked =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: _startTimes[d]!,
                                              );
                                              if (picked != null) {
                                                setState(() =>
                                                    _startTimes[d] = picked);
                                              }
                                            },
                                      icon: const Icon(Icons.access_time),
                                      label: Text(
                                          _formatTimeOfDay(_startTimes[d]!)),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('—'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _isSaving || !enabled
                                          ? null
                                          : () async {
                                              final picked =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: _endTimes[d]!,
                                              );
                                              if (picked != null) {
                                                setState(() =>
                                                    _endTimes[d] = picked);
                                              }
                                            },
                                      icon:
                                          const Icon(Icons.access_time_filled),
                                      label:
                                          Text(_formatTimeOfDay(_endTimes[d]!)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Fazla Mesai Kuralları'),
                      value: _overtimeEnabled,
                      onChanged: _isSaving
                          ? null
                          : (v) => setState(() => _overtimeEnabled = v),
                    ),
                    if (_overtimeEnabled)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _overtimeThresholdHoursController,
                              decoration: const InputDecoration(
                                  labelText: 'Günlük Eşik (saat)'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _overtimeMultiplierController,
                              decoration: const InputDecoration(
                                  labelText: 'Çarpan (örn. 1.5)'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        ],
                      ),
                  ],
                ],

                // TC, Email
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _tcController,
                        decoration: const InputDecoration(
                          labelText: 'TC',
                          counterText: '',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Zorunlu alan';
                          if (t.length != 11) return '11 haneli olmalı';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'E-posta'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final email = v?.trim() ?? '';
                          if (email.isEmpty) return 'Zorunlu alan';
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(email)) {
                            return 'Geçerli bir e-posta adresi giriniz';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Birth date, Start date
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _isSaving
                            ? null
                            : () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(
                                      now.year - 25, now.month, now.day),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime(now.year - 10),
                                );
                                if (picked != null) {
                                  setState(() => _birthDate = picked);
                                }
                              },
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'Doğum Tarihi'),
                          child: Text(
                            _birthDate == null
                                ? 'Seçiniz'
                                : '${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _isSaving
                            ? null
                            : () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(now.year + 1),
                                );
                                if (picked != null) {
                                  setState(() => _startDate = picked);
                                }
                              },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                              labelText: 'İşe Başlama Tarihi'),
                          child: Text(
                            _startDate == null
                                ? 'Seçiniz'
                                : '${_startDate!.day.toString().padLeft(2, '0')}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.year}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Department, Category
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDepartment,
                        decoration:
                            const InputDecoration(labelText: 'Departman'),
                        isExpanded: true,
                        items: _departmentsLive
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ))
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (v) => setState(() => _selectedDepartment = v),
                        validator: (v) => v == null ? 'Zorunlu alan' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Departman Ekle',
                      onPressed: _isSaving ? null : _openManageDepartments,
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration:
                            const InputDecoration(labelText: 'Kategori'),
                        isExpanded: true,
                        items: _categoriesLive
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ))
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (v) => setState(() => _selectedCategory = v),
                        validator: (v) => v == null ? 'Zorunlu alan' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Kategori Ekle',
                      onPressed: _isSaving ? null : _openManageCategories,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Position
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPosition,
                        decoration:
                            const InputDecoration(labelText: 'Pozisyon'),
                        items: _positionsLive
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (v) => setState(() => _selectedPosition = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Pozisyon Ekle',
                      onPressed: _isSaving ? null : widget.onManagePositions,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Salary
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _salaryAmountController,
                        focusNode: _salaryAmountFocusNode,
                        decoration: InputDecoration(
                          labelText: _entitlementType == 'Aylık (İki Kere)'
                              ? 'Toplam Maaş (Otomatik)'
                              : 'Maaş Miktarı',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.next,
                        enabled: _entitlementType != 'Aylık (İki Kere)',
                        readOnly: _entitlementType == 'Aylık (İki Kere)',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d,.]'),
                          ),
                        ],
                        onEditingComplete: _handleSalaryAmountFormat,
                        onFieldSubmitted: (_) => _handleSalaryAmountFormat(),
                        onTapOutside: (_) => _handleSalaryAmountFormat(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _salaryCurrency,
                        decoration:
                            const InputDecoration(labelText: 'Para Birimi'),
                        items: const ['TRY', 'USD', 'EUR']
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (v) =>
                                setState(() => _salaryCurrency = v ?? 'TRY'),
                      ),
                    ),
                  ],
                ),

                // Saatlik maaş bilgisi
                Builder(
                  builder: (context) {
                    final hourlyRate = _calculateHourlyRate();
                    if (hourlyRate == null || hourlyRate <= 0) {
                      return const SizedBox.shrink();
                    }
                    final formattedHourlyRate = _formatSalaryAmount(
                        hourlyRate.toStringAsFixed(2).replaceAll('.', ','));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () =>
                                _showHourlyRateCalculationInfo(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.info_outline,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Saatlik Maaş: $formattedHourlyRate $_salaryCurrency/saat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Entitlement
                DropdownButtonFormField<String>(
                  initialValue: _entitlementType,
                  decoration: const InputDecoration(labelText: 'Hak Ediş'),
                  items: const [
                    'Saatlik',
                    'Günlük',
                    'Haftalık',
                    'Aylık',
                    'Aylık (İki Kere)'
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (v) {
                          setState(() {
                            _entitlementType = v ?? 'Aylık';
                            // Maaş türü değiştiğinde toplam maaşı güncelle
                            if (_entitlementType == 'Aylık (İki Kere)') {
                              _updateTotalSalary();
                            }
                          });
                        },
                ),

                const SizedBox(height: 8),

                if (_entitlementType == 'Aylık') ...[
                  DropdownButtonFormField<int>(
                    initialValue: _monthlyDayOfMonth,
                    decoration:
                        const InputDecoration(labelText: 'Ayın Günü (1-31)'),
                    items: List.generate(31, (i) => i + 1)
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text('$d')))
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _monthlyDayOfMonth = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _monthlyDaysPerWeek,
                          decoration: const InputDecoration(
                              labelText: 'Haftada Kaç Gün Çalışır?'),
                          items: List.generate(7, (i) => i + 1)
                              .map((d) => DropdownMenuItem(
                                  value: d, child: Text('$d gün')))
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) =>
                                  setState(() => _monthlyDaysPerWeek = v ?? 5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _monthlyHoursPerDay,
                          decoration: const InputDecoration(
                              labelText: 'Günde Kaç Saat Çalışır?'),
                          items: List.generate(12, (i) => i + 1)
                              .map((h) => DropdownMenuItem(
                                  value: h, child: Text('$h saat')))
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) =>
                                  setState(() => _monthlyHoursPerDay = v ?? 8),
                        ),
                      ),
                    ],
                  ),
                ],

                if (_entitlementType == 'Aylık (İki Kere)') ...[
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _semiMonthlyDay1,
                          decoration:
                              const InputDecoration(labelText: '1. Gün (1-31)'),
                          items: List.generate(31, (i) => i + 1)
                              .map((d) =>
                                  DropdownMenuItem(value: d, child: Text('$d')))
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) {
                                  setState(() {
                                    _semiMonthlyDay1 = v;
                                    // Gün değiştiğinde label'ı güncellemek için
                                  });
                                },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _semiMonthlyDay2,
                          decoration:
                              const InputDecoration(labelText: '2. Gün (1-31)'),
                          items: List.generate(31, (i) => i + 1)
                              .map((d) =>
                                  DropdownMenuItem(value: d, child: Text('$d')))
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) {
                                  setState(() {
                                    _semiMonthlyDay2 = v;
                                    // Gün değiştiğinde label'ı güncellemek için
                                  });
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Her ödeme günü için tutar alanları
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _semiMonthlyAmount1Controller,
                          focusNode: _semiMonthlyAmount1FocusNode,
                          decoration: InputDecoration(
                            labelText:
                                '${_semiMonthlyDay1 ?? 1}. Gün Tutarı ($_salaryCurrency)',
                            border: const OutlineInputBorder(),
                            hintText: 'Örn: 5000',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.next,
                          enabled: !_isSaving && _semiMonthlyDay1 != null,
                          onChanged: (value) {
                            // Sadece toplam maaşı güncelle, formatlama yapma
                            setState(() {
                              _updateTotalSalary();
                            });
                          },
                          onEditingComplete: _handleSemiMonthlyAmount1Format,
                          onFieldSubmitted: (_) =>
                              _handleSemiMonthlyAmount1Format(),
                          onTapOutside: (_) =>
                              _handleSemiMonthlyAmount1Format(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _semiMonthlyAmount2Controller,
                          focusNode: _semiMonthlyAmount2FocusNode,
                          decoration: InputDecoration(
                            labelText:
                                '${_semiMonthlyDay2 ?? 2}. Gün Tutarı ($_salaryCurrency)',
                            border: const OutlineInputBorder(),
                            hintText: 'Örn: 5000',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.next,
                          enabled: !_isSaving && _semiMonthlyDay2 != null,
                          onChanged: (value) {
                            // Sadece toplam maaşı güncelle, formatlama yapma
                            setState(() {
                              _updateTotalSalary();
                            });
                          },
                          onEditingComplete: _handleSemiMonthlyAmount2Format,
                          onFieldSubmitted: (_) =>
                              _handleSemiMonthlyAmount2Format(),
                          onTapOutside: (_) =>
                              _handleSemiMonthlyAmount2Format(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _monthlyDaysPerWeek,
                          decoration: const InputDecoration(
                              labelText: 'Haftada Kaç Gün Çalışır?'),
                          items: List.generate(7, (i) => i + 1)
                              .map((d) => DropdownMenuItem(
                                  value: d, child: Text('$d gün')))
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) =>
                                  setState(() => _monthlyDaysPerWeek = v ?? 5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _monthlyHoursPerDay,
                          decoration: const InputDecoration(
                              labelText: 'Günde Kaç Saat Çalışır?'),
                          items: List.generate(12, (i) => i + 1)
                              .map((h) => DropdownMenuItem(
                                  value: h, child: Text('$h saat')))
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) =>
                                  setState(() => _monthlyHoursPerDay = v ?? 8),
                        ),
                      ),
                    ],
                  ),
                ],

                if (_entitlementType == 'Haftalık')
                  DropdownButtonFormField<String>(
                    initialValue: _weeklyWeekday,
                    decoration:
                        const InputDecoration(labelText: 'Haftanın Günü'),
                    items: const [
                      'Pazartesi',
                      'Salı',
                      'Çarşamba',
                      'Perşembe',
                      'Cuma',
                      'Cumartesi',
                      'Pazar'
                    ]
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _weeklyWeekday = v),
                  ),

                if (_entitlementType == 'Günlük') ...[
                  // Haftalık çalışma saatleri - Günler saat seçimi ile otomatik seçilir
                  Text('Çalışma Saatleri',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Column(
                    children: _weekdays.map((d) {
                      final enabled = _dayEnabled[d] ?? false;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(d),
                                value: enabled,
                                onChanged: _isSaving
                                    ? null
                                    : (v) {
                                        setState(() {
                                          _dayEnabled[d] = v ?? false;
                                          // Gün seçildiğinde veya kaldırıldığında _weeklySelectedDays'i güncelle
                                          if (v == true) {
                                            if (!_weeklySelectedDays
                                                .contains(d)) {
                                              _weeklySelectedDays.add(d);
                                            }
                                          } else {
                                            _weeklySelectedDays.remove(d);
                                          }
                                          // _daysPerWeek'i güncelle
                                          _daysPerWeek =
                                              _weeklySelectedDays.length;
                                        });
                                      },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _isSaving || !enabled
                                        ? null
                                        : () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _startTimes[d]!,
                                            );
                                            if (picked != null) {
                                              setState(() =>
                                                  _startTimes[d] = picked);
                                            }
                                          },
                                    icon: const Icon(Icons.access_time),
                                    label:
                                        Text(_formatTimeOfDay(_startTimes[d]!)),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('—'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _isSaving || !enabled
                                        ? null
                                        : () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _endTimes[d]!,
                                            );
                                            if (picked != null) {
                                              setState(
                                                  () => _endTimes[d] = picked);
                                            }
                                          },
                                    icon: const Icon(Icons.access_time_filled),
                                    label:
                                        Text(_formatTimeOfDay(_endTimes[d]!)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Fazla mesai ayarları
                  SwitchListTile(
                    title: const Text('Fazla Mesai Kuralları'),
                    value: _overtimeEnabled,
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _overtimeEnabled = v),
                  ),
                  if (_overtimeEnabled)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeThresholdHoursController,
                            decoration: const InputDecoration(
                                labelText: 'Günlük Eşik (saat)'),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeMultiplierController,
                            decoration: const InputDecoration(
                                labelText: 'Çarpan (örn. 1.5)'),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                ],

                const SizedBox(height: 16),

                // Documents
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _pickDocuments,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Döküman Ekle (PDF/PNG/JPG)'),
                    ),
                    const SizedBox(width: 12),
                    Text('${_pickedDocs.length}/10 dosya seçildi'),
                  ],
                ),

                const SizedBox(height: 8),
                if (_pickedDocs.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _pickedDocs
                        .map((d) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  d.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: _isSaving
                                      ? null
                                      : () {
                                          setState(() => _pickedDocs.remove(d));
                                        },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Kaldır',
                                ),
                              ],
                            ))
                        .toList(),
                  ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    FilledButton.icon(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Vazgeç'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: const Text('Kaydet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedDoc {
  final String name;
  final Uint8List bytes;
  _PickedDoc({required this.name, required this.bytes});
}

// Removed helper chip; using inline FilterChip with parent setState
