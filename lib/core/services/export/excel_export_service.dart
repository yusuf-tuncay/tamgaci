import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../../../features/accounts/domain/entities/account.dart';
import '../../../features/accounts/domain/entities/account_transaction.dart';

class ExcelExportService {
  static Future<String?> exportTransactionsToExcel({
    required Account account,
    required List<AccountTransaction> transactions,
    String? fileName,
  }) async {
    try {
      // Excel dosyası oluştur
      final excel = Excel.createExcel();

      // Varsayılan sheet'i sil ve yeni sheet oluştur
      excel.delete('Sheet1');
      final sheet = excel['Hesap Hareketleri'];

      // Başlık satırı
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
      print('Excel export: ${transactions.length} işlem ekleniyor');
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
        
        print('Excel export: Satır ${i + 1} - ${row.join(', ')}');
        sheet.appendRow(row);
      }
      
      print('Excel export: Toplam ${sheet.maxRows} satır eklendi');

      // Dosya adı oluştur
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName =
          '${account.name}_HesapHareketleri_$timestamp.xlsx';
      final finalFileName = fileName ?? defaultFileName;

      // Dosyayı kaydet
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Excel dosyası oluşturulamadı');
      }
      
      print('Excel export: ${bytes.length} byte veri oluşturuldu');
      
      // Downloads klasörüne kaydet
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Downloads klasörü bulunamadı');
      }
      
      final filePath = path.join(directory.path, finalFileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      print('Excel export: Dosya kaydedildi - $filePath');
      print('Excel export: Dosya boyutu - ${file.lengthSync()} byte');
      
      return filePath;
    } catch (e) {
      throw Exception('Excel export hatası: $e');
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
