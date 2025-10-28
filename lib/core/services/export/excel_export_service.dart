import 'dart:io';
import 'dart:math' as math;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../../../features/accounts/domain/entities/account.dart';
import '../../../features/accounts/domain/entities/account_transaction.dart';
import 'package:flutter/foundation.dart';
import '../../../features/auth/domain/entities/user.dart';
import '../../entities/company.dart';
import '../../../features/company/domain/entities/company_info.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class ExcelExportService {
  static Future<String?> exportTransactionsToExcel({
    required Account account,
    required List<AccountTransaction> transactions,
    User? user,
    Company? company,
    CompanyInfo? companyInfo,
    String? fileName,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? transactionType,
    TransactionCategory? transactionCategory,
    String? searchQuery,
  }) async {
    debugPrint('=== EXCEL EXPORT SERVİSİ BAŞLADI ===');
    debugPrint('Servis çağrı zamanı: ${DateTime.now()}');
    debugPrint('Account: ${account.name}');
    debugPrint('Transactions count: ${transactions.length}');

    try {
      // Excel dosyası oluştur
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Sayfa düzenini ayarla
      _setupPageLayout(sheet);

      // Başlık bölümü
      _buildHeader(sheet, company, user);

      // Bilgiler bölümü (PDF'deki gibi iki sütunlu)
      _buildInfoSection(
          sheet,
          account,
          company,
          companyInfo,
          user,
          transactions,
          startDate,
          endDate,
          transactionType,
          transactionCategory,
          searchQuery);

      // Ekstre tablosu
      _buildStatementTable(sheet, account, transactions);

      // Footer
      _buildFooter(sheet);

      // Dosya adı oluştur
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = '${account.name}_Ekstre_$timestamp.xlsx';
      final finalFileName = fileName ?? defaultFileName;

      // Dosyayı kaydet
      final bytes = excel.save();
      if (bytes == null) {
        throw Exception('Excel dosyası oluşturulamadı');
      }

      debugPrint('Excel export: ${bytes.length} byte veri oluşturuldu');

      // Platform kontrolü - Web ve Mobil için farklı yaklaşım
      if (kIsWeb) {
        return _saveForWeb(Uint8List.fromList(bytes), finalFileName);
      } else {
        return await _saveForMobile(Uint8List.fromList(bytes), finalFileName);
      }
    } catch (e) {
      throw Exception('Excel export hatası: $e');
    }
  }

  static void _setupPageLayout(Sheet sheet) {
    // Excel kütüphanesi sütun genişliği ayarlamayı desteklemiyor
    // Bu nedenle sadece boş satırlar ekleyerek düzeni oluşturuyoruz
  }

  static void _buildHeader(Sheet sheet, Company? company, User? user) {
    // TAMGACI başlığı (küçük ve üstte)
    sheet.appendRow(['TAMGACI', 'Muhasebe ve İş Yönetim Sistemi']);

    // Boş satır
    sheet.appendRow(['']);
  }

  static void _buildInfoSection(
      Sheet sheet,
      Account account,
      Company? company,
      CompanyInfo? companyInfo,
      User? user,
      List<AccountTransaction> transactions,
      DateTime? startDate,
      DateTime? endDate,
      TransactionType? transactionType,
      TransactionCategory? transactionCategory,
      String? searchQuery) {
    // Sol sütun - Şirket bilgileri + Rapor bilgileri + Kullanıcı adı
    final leftColumn = <String>[];

    // Şirket bilgileri
    if (companyInfo != null || company != null) {
      leftColumn.addAll([
        'Şirket Adı: ${companyInfo?.name ?? company?.name ?? ''}',
        'Vergi No: ${companyInfo?.taxNumber ?? user?.taxId ?? 'Belirtilmemis'}${(companyInfo?.taxOffice ?? user?.taxOffice) != null && (companyInfo?.taxOffice ?? user?.taxOffice)!.isNotEmpty ? ' (${companyInfo?.taxOffice ?? user?.taxOffice})' : ''}',
        'Adres: ${(companyInfo != null && companyInfo.fullAddress.isNotEmpty) ? companyInfo.fullAddress : (company?.address ?? 'Belirtilmemis')}',
        'Telefon: ${companyInfo?.phone ?? company?.phone ?? 'Belirtilmemis'}',
        'E-posta: ${companyInfo?.email ?? company?.email ?? 'Belirtilmemis'}',
        'Web Sitesi: ${companyInfo?.website ?? company?.website ?? 'Belirtilmemis'}',
        '', // Boş satır
      ]);
    }

    // Kullanıcı adı (Web Sitesi altına)
    if (user != null) {
      leftColumn.add('Kullanıcı: ${user.name} ${user.surname}');
      leftColumn.add(''); // Boş satır
    }

    // Rapor bilgileri
    leftColumn.addAll([
      'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
      'Rapor Türü: Hesap Ekstresi',
      'Toplam İşlem: ${transactions.length} adet',
    ]);

    // Sağ sütun - Filtreleme bilgileri + Hesap bilgileri
    final rightColumn = <String>[];

    // Filtreleme bilgileri
    rightColumn.addAll([
      'Tarih Aralığı: ${startDate != null && endDate != null ? '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}' : 'Tüm tarihler'}',
      'İşlem Türü: ${transactionType != null ? _getTransactionTypeText(transactionType) : 'Tüm işlem türleri'}',
      'Kategori: ${transactionCategory != null ? _getTransactionCategoryText(transactionCategory) : 'Tüm kategoriler'}',
      'Arama: ${searchQuery != null && searchQuery.isNotEmpty ? searchQuery : 'Arama yapılmadı'}',
      '', // Boş satır
    ]);

    // Hesap bilgileri
    rightColumn.addAll([
      'Hesap Adı: ${account.name}',
      'Hesap Türü: ${_getAccountTypeText(account.type)}',
      'Para Birimi: ${account.currency}',
      'Mevcut Bakiye: ${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}',
    ]);

    // İki sütunlu düzenleme
    final maxRows = math.max(leftColumn.length, rightColumn.length);
    for (int i = 0; i < maxRows; i++) {
      final leftValue = i < leftColumn.length ? leftColumn[i] : '';
      final rightValue = i < rightColumn.length ? rightColumn[i] : '';
      sheet.appendRow([leftValue, '', '', rightValue]);
    }

    // Boş satır
    sheet.appendRow(['']);
  }

  static void _buildStatementTable(
      Sheet sheet, Account account, List<AccountTransaction> transactions) {
    // Başlık satırı
    final headerRow = [
      '📅 Tarih',
      '🕐 Saat',
      '📂 Kategori',
      '📝 Açıklama',
      '🔴 Borç',
      '🟢 Alacak',
      '⚫ Bakiye'
    ];
    sheet.appendRow(headerRow);

    // İşlemleri en yeni olan en alta gelecek şekilde sırala
    final sortedTransactions = List<AccountTransaction>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    // İşlemleri ekle
    for (final transaction in sortedTransactions) {
      // Borç/Alacak hesaplama
      double debitAmount = 0.0;
      double creditAmount = 0.0;

      switch (transaction.type) {
        case TransactionType.income:
          creditAmount = transaction.amount;
          break;
        case TransactionType.expense:
          debitAmount = transaction.amount;
          break;
        case TransactionType.withdrawal:
          debitAmount = transaction.amount;
          break;
        case TransactionType.deposit:
          creditAmount = transaction.amount;
          break;
        case TransactionType.transfer:
        case TransactionType.adjustment:
        case TransactionType.opening:
          if (transaction.amount > 0) {
            creditAmount = transaction.amount;
          } else if (transaction.amount < 0) {
            debitAmount = transaction.amount;
          }
          break;
      }

      final row = [
        DateFormat('dd.MM.yyyy').format(transaction.transactionDate),
        DateFormat('HH:mm').format(transaction.transactionDate),
        _getTransactionCategoryText(transaction.category),
        transaction.description,
        debitAmount != 0
            ? NumberFormat('#,##0.00', 'tr_TR').format(debitAmount)
            : '',
        creditAmount != 0
            ? NumberFormat('#,##0.00', 'tr_TR').format(creditAmount)
            : '',
        NumberFormat('#,##0.00', 'tr_TR').format(transaction.balanceAfter),
      ];

      sheet.appendRow(row);
    }
  }

  static void _buildFooter(Sheet sheet) {
    // Boş satırlar
    sheet.appendRow(['']);
    sheet.appendRow(['']);

    // Footer - TAMGACI branding
    sheet.appendRow(
        ['TAMGACI', 'Muhasebe ve İş Yönetim Sistemi', '', '', '', '', '1/1']);
  }

  static String _saveForWeb(Uint8List bytes, String fileName) {
    final uint8List = Uint8List.fromList(bytes);
    final blob = web.Blob([uint8List.buffer.toJS].toJS);
    final url = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();

    web.URL.revokeObjectURL(url);

    debugPrint('Excel export: Web indirme başlatıldı - $fileName');
    return 'Web indirme başlatıldı: $fileName';
  }

  static Future<String> _saveForMobile(Uint8List bytes, String fileName) async {
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      throw Exception('Downloads klasörü bulunamadı');
    }

    final filePath = path.join(directory.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    debugPrint('Excel export: Dosya kaydedildi - $filePath');
    debugPrint('Excel export: Dosya boyutu - ${file.lengthSync()} byte');

    return filePath;
  }

  static String _getAccountTypeText(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'Nakit Kasa';
      case AccountType.checking:
        return 'Vadesiz Hesap';
      case AccountType.savings:
        return 'Vadeli Hesap';
      case AccountType.creditCard:
        return 'Kredi Kartı';
      case AccountType.credit:
        return 'Kredi Hesabı';
      case AccountType.investment:
        return 'Yatırım Hesabı';
      case AccountType.foreign:
        return 'Döviz Hesabı';
      case AccountType.other:
        return 'Diğer';
    }
  }

  static String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Gelir';
      case TransactionType.expense:
        return 'Gider';
      case TransactionType.deposit:
        return 'Para Girişi';
      case TransactionType.withdrawal:
        return 'Para Çıkışı';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.adjustment:
        return 'Düzeltme';
      case TransactionType.opening:
        return 'Açılış Bakiyesi';
    }
  }

  static String _getTransactionCategoryText(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.cash:
        return 'Nakit';
      case TransactionCategory.bank:
        return 'Banka';
      case TransactionCategory.credit:
        return 'Kredi';
      case TransactionCategory.investment:
        return 'Yatırım';
      case TransactionCategory.expense:
        return 'Masraf';
      case TransactionCategory.other:
        return 'Diğer';
    }
  }
}
