import 'dart:io';
import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../../../features/accounts/domain/entities/account.dart';
import '../../../features/accounts/domain/entities/account_transaction.dart';
import 'package:flutter/foundation.dart';

class ExcelExportService {
  static Future<String?> exportTransactionsToExcel({
    required Account account,
    required List<AccountTransaction> transactions,
    String? fileName,
  }) async {
    try {
      // Excel dosyası oluştur
      final excel = Excel.createExcel();

      // Varsayılan sheet'i kullan
      final sheet = excel['Sheet1'];

      // Kurumsal başlık
      sheet.appendRow(['TAMGACI']);
      sheet.appendRow(['Muhasebe ve Finans Yönetim Sistemi']);
      sheet.appendRow(['']);
      sheet.appendRow(['Şirket:', 'TAMGACI Yazılım']);
      sheet.appendRow(['Web:', 'www.tamgaci.com']);
      sheet.appendRow(['E-posta:', 'info@tamgaci.com']);
      sheet.appendRow(['']);
      sheet.appendRow(['Rapor Tarihi:', DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())]);
      sheet.appendRow(['Rapor Türü:', 'Hesap Hareketleri Raporu']);
      sheet.appendRow(['']);

      // Kasa bilgileri başlığı
      sheet.appendRow(['HESAP BİLGİLERİ']);
      sheet.appendRow(['Hesap Adı', account.name]);
      sheet.appendRow(['Hesap Türü', _getAccountTypeText(account.type)]);
      sheet.appendRow(['Para Birimi', account.currency]);
      sheet.appendRow([
        'Mevcut Bakiye',
        '${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}'
      ]);
      sheet.appendRow([
        'Oluşturulma Tarihi',
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

      // İşlemleri ekle
      debugPrint('Excel export: ${transactions.length} işlem ekleniyor');
      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];

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
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', finalFileName)
          ..click();
        html.Url.revokeObjectUrl(url);

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
