import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../../../features/accounts/domain/entities/account.dart';
import '../../../features/accounts/domain/entities/account_transaction.dart';
import 'package:flutter/foundation.dart';
import '../../../features/auth/domain/entities/user.dart';
import '../../entities/company.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class ExcelExportService {
  static Future<String?> exportTransactionsToExcel({
    required Account account,
    required List<AccountTransaction> transactions,
    User? user,
    Company? company,
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

      // Varsayılan sheet'i kullan
      final sheet = excel['Sheet1'];

      // Excel dosyası hazırlanıyor...

      // Kurumsal başlık - TAMGACI logosu
      sheet.appendRow(['TAMGACI']);
      sheet.appendRow(['Muhasebe ve Finans Yönetim Sistemi']);
      sheet.appendRow(['']);

      // Şirket bilgileri
      if (company != null) {
        sheet.appendRow(['Şirket Bilgileri']);
        sheet.appendRow(['Şirket Adı:', company.name]);
        sheet.appendRow(['Vergi No:', user?.taxId ?? 'Belirtilmemiş']);
        sheet.appendRow(
            ['Adres:', company.address ?? user?.address ?? 'Belirtilmemiş']);
        sheet.appendRow(
            ['Telefon:', company.phone ?? user?.phone ?? 'Belirtilmemiş']);
        sheet.appendRow(
            ['E-posta:', company.email ?? user?.email ?? 'Belirtilmemiş']);
        sheet.appendRow(['Web Sitesi:', company.website ?? 'Belirtilmemiş']);
        sheet.appendRow(['']);
      }

      // Kullanıcı bilgileri
      if (user != null) {
        sheet.appendRow(['Kullanıcı Bilgileri']);
        sheet.appendRow(['Kullanıcı Adı:', '${user.name} ${user.surname}']);
        sheet.appendRow(['E-posta:', user.email]);
        sheet.appendRow(['Telefon:', user.phone ?? 'Belirtilmemiş']);
        sheet.appendRow(['Adres:', user.address ?? 'Belirtilmemiş']);
        sheet.appendRow(['Vergi No:', user.taxId ?? 'Belirtilmemiş']);
        sheet.appendRow(['Vergi Dairesi:', user.taxOffice ?? 'Belirtilmemiş']);
        sheet.appendRow(
            ['Fatura Adresi:', user.billingAddress ?? 'Belirtilmemiş']);
        sheet.appendRow(
            ['Kayıt Tarihi:', DateFormat('dd.MM.yyyy').format(user.createdAt)]);
        sheet.appendRow(['']);
      }

      // Rapor bilgileri
      sheet.appendRow(['Rapor Bilgileri']);
      sheet.appendRow([
        'Rapor Tarihi:',
        DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())
      ]);
      sheet.appendRow(['Rapor Türü:', 'Hesap Hareketleri Raporu']);
      sheet.appendRow(['Toplam İşlem:', '${transactions.length} adet']);

      // Filtreleme bilgileri
      sheet.appendRow(['Filtreleme Bilgileri']);
      if (startDate != null && endDate != null) {
        sheet.appendRow([
          'Tarih Aralığı:',
          '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}'
        ]);
      } else {
        sheet.appendRow(['Tarih Aralığı:', 'Tüm tarihler']);
      }

      if (transactionType != null) {
        sheet.appendRow(
            ['İşlem Türü:', _getTransactionTypeText(transactionType)]);
      } else {
        sheet.appendRow(['İşlem Türü:', 'Tüm işlem türleri']);
      }

      if (transactionCategory != null) {
        sheet.appendRow(
            ['Kategori:', _getTransactionCategoryText(transactionCategory)]);
      } else {
        sheet.appendRow(['Kategori:', 'Tüm kategoriler']);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        sheet.appendRow(['Arama:', searchQuery]);
      } else {
        sheet.appendRow(['Arama:', 'Arama yapılmadı']);
      }

      sheet.appendRow(['']);

      // Hesap bilgileri başlığı
      sheet.appendRow(['HESAP BİLGİLERİ']);
      sheet.appendRow(['Hesap Adı:', account.name]);
      sheet.appendRow(['Hesap Türü:', _getAccountTypeText(account.type)]);
      sheet.appendRow(['Para Birimi:', account.currency]);
      sheet.appendRow([
        'Mevcut Bakiye:',
        '${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}'
      ]);
      sheet.appendRow([
        'Oluşturulma Tarihi:',
        DateFormat('dd.MM.yyyy HH:mm').format(account.createdAt)
      ]);
      sheet.appendRow(['']); // Boş satır

      // İşlemler başlığı
      sheet.appendRow(['HESAP HAREKETLERİ']);
      sheet.appendRow(['']); // Boş satır

      // İşlemler başlık satırı
      final headerRow = [
        'Tarih',
        'Saat',
        'İşlem Türü',
        'Kategori',
        'Açıklama',
        'Miktar',
        'Para Birimi',
        'Bakiye Sonrası',
      ];

      sheet.appendRow(headerRow);

      // İşlemleri en yeni olan en alta gelecek şekilde sırala
      final sortedTransactions = List<AccountTransaction>.from(transactions)
        ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

      // İşlemleri ekle
      debugPrint('Excel export: ${sortedTransactions.length} işlem ekleniyor');
      for (int i = 0; i < sortedTransactions.length; i++) {
        final transaction = sortedTransactions[i];

        final row = [
          DateFormat('dd.MM.yyyy').format(transaction.transactionDate),
          DateFormat('HH:mm').format(transaction.transactionDate),
          _getTransactionTypeText(transaction.type),
          _getTransactionCategoryText(transaction.category),
          transaction.description,
          transaction.amount,
          account.currency,
          transaction.balanceAfter,
        ];

        debugPrint('Excel export: Satır ${i + 1} - ${row.join(', ')}');
        sheet.appendRow(row);
      }

      debugPrint('Excel export: Toplam ${sheet.maxRows} satır eklendi');

      // Dosya adı oluştur
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName =
          '${account.name}_HesapHareketleri_$timestamp.xlsx';
      final finalFileName = fileName ?? defaultFileName;

      // Dosyayı kaydet
      final bytes = excel.save();
      if (bytes == null) {
        throw Exception('Excel dosyası oluşturulamadı');
      }

      debugPrint('Excel export: ${bytes.length} byte veri oluşturuldu');

      // Platform kontrolü - Web ve Mobil için farklı yaklaşım
      if (kIsWeb) {
        // Web'de dosyayı direkt indirme olarak ayarla
        final uint8List = Uint8List.fromList(bytes);
        final blob = web.Blob([uint8List.buffer.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        
        // Direkt indirme için anchor element kullan
        final anchor = web.HTMLAnchorElement()
          ..href = url
          ..download = finalFileName
          ..style.display = 'none';
        
        // DOM'a ekle, tıkla ve kaldır
        web.document.body?.appendChild(anchor);
        anchor.click();
        anchor.remove();
        
        // URL'yi temizle
        web.URL.revokeObjectURL(url);
        
        debugPrint('Excel export: Web indirme başlatıldı - $finalFileName');
        return 'Web indirme başlatıldı: $finalFileName';
      } else {
        // Mobil'de Downloads klasörüne kaydet
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('Downloads klasörü bulunamadı');
        }

        final filePath = path.join(directory.path, finalFileName);
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        debugPrint('Excel export: Dosya kaydedildi - $filePath');
        debugPrint('Excel export: Dosya boyutu - ${file.lengthSync()} byte');

        return filePath;
      }
    } catch (e) {
      throw Exception('Excel export hatası: $e');
    }
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
