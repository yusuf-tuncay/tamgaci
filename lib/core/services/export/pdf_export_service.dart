import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

class PdfExportService {
  static Future<String?> exportTransactionsToPdf({
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
    debugPrint('=== PDF EXPORT SERVİSİ BAŞLADI ===');
    debugPrint('Servis çağrı zamanı: ${DateTime.now()}');
    debugPrint('Account: ${account.name}');
    debugPrint('Transactions count: ${transactions.length}');

    try {
      // PDF dosyası oluştur (varsayılan font kullan)
      final pdf = pw.Document();

      // İşlemleri en yeni olan en alta gelecek şekilde sırala
      final sortedTransactions = List<AccountTransaction>.from(transactions)
        ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

      // PDF içeriği oluştur
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // Kurumsal başlık
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'TAMGACI',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Muhasebe ve Finans Yönetim Sistemi',
                      style: const pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),

              // Şirket bilgileri
              if (company != null) ...[
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    'Şirket Bilgileri',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Şirket Adı:', company.name),
                      _buildInfoRow(
                          'Vergi No:', user?.taxId ?? 'Belirtilmemiş'),
                      _buildInfoRow('Adres:',
                          company.address ?? user?.address ?? 'Belirtilmemiş'),
                      _buildInfoRow('Telefon:',
                          company.phone ?? user?.phone ?? 'Belirtilmemiş'),
                      _buildInfoRow('E-posta:',
                          company.email ?? user?.email ?? 'Belirtilmemiş'),
                      _buildInfoRow(
                          'Web Sitesi:', company.website ?? 'Belirtilmemiş'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),
              ],

              // Kullanıcı bilgileri
              if (user != null) ...[
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    'Kullanıcı Bilgileri',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                          'Kullanıcı Adı:', '${user.name} ${user.surname}'),
                      _buildInfoRow('E-posta:', user.email),
                      _buildInfoRow('Telefon:', user.phone ?? 'Belirtilmemiş'),
                      _buildInfoRow('Adres:', user.address ?? 'Belirtilmemiş'),
                      _buildInfoRow('Vergi No:', user.taxId ?? 'Belirtilmemiş'),
                      _buildInfoRow(
                          'Vergi Dairesi:', user.taxOffice ?? 'Belirtilmemiş'),
                      _buildInfoRow('Fatura Adresi:',
                          user.billingAddress ?? 'Belirtilmemiş'),
                      _buildInfoRow('Kayıt Tarihi:',
                          DateFormat('dd.MM.yyyy').format(user.createdAt)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),
              ],

              // Rapor bilgileri
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Rapor Bilgileri',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Rapor Tarihi:',
                        DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())),
                    _buildInfoRow('Rapor Türü:', 'Hesap Hareketleri Raporu'),
                    _buildInfoRow(
                        'Toplam İşlem:', '${transactions.length} adet'),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Filtreleme bilgileri
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Filtreleme Bilgileri',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (startDate != null && endDate != null)
                      _buildInfoRow('Tarih Aralığı:',
                          '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}')
                    else
                      _buildInfoRow('Tarih Aralığı:', 'Tüm tarihler'),
                    if (transactionType != null)
                      _buildInfoRow('İşlem Türü:',
                          _getTransactionTypeText(transactionType))
                    else
                      _buildInfoRow('İşlem Türü:', 'Tüm işlem türleri'),
                    if (transactionCategory != null)
                      _buildInfoRow('Kategori:',
                          _getTransactionCategoryText(transactionCategory))
                    else
                      _buildInfoRow('Kategori:', 'Tüm kategoriler'),
                    if (searchQuery != null && searchQuery.isNotEmpty)
                      _buildInfoRow('Arama:', searchQuery)
                    else
                      _buildInfoRow('Arama:', 'Arama yapılmadı'),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Hesap bilgileri
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Hesap Bilgileri',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Hesap Adı:', account.name),
                    _buildInfoRow(
                        'Hesap Türü:', _getAccountTypeText(account.type)),
                    _buildInfoRow('Para Birimi:', account.currency),
                    _buildInfoRow('Mevcut Bakiye:',
                        '${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}'),
                    _buildInfoRow(
                        'Oluşturulma Tarihi:',
                        DateFormat('dd.MM.yyyy HH:mm')
                            .format(account.createdAt)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // İşlemler başlığı
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Hesap Hareketleri',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              // İşlemler tablosu
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80), // Tarih
                  1: const pw.FixedColumnWidth(60), // Saat
                  2: const pw.FixedColumnWidth(100), // İşlem Türü
                  3: const pw.FixedColumnWidth(80), // Kategori
                  4: const pw.FlexColumnWidth(2), // Açıklama
                  5: const pw.FixedColumnWidth(80), // Miktar
                  6: const pw.FixedColumnWidth(60), // Para Birimi
                  7: const pw.FixedColumnWidth(100), // Bakiye Sonrası
                },
                children: [
                  // Başlık satırı
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Tarih', isHeader: true),
                      _buildTableCell('Saat', isHeader: true),
                      _buildTableCell('İşlem Türü', isHeader: true),
                      _buildTableCell('Kategori', isHeader: true),
                      _buildTableCell('Açıklama', isHeader: true),
                      _buildTableCell('Miktar', isHeader: true),
                      _buildTableCell('Para Birimi', isHeader: true),
                      _buildTableCell('Bakiye Sonrası', isHeader: true),
                    ],
                  ),
                  // İşlemler
                  ...sortedTransactions.map((transaction) => pw.TableRow(
                        children: [
                          _buildTableCell(DateFormat('dd.MM.yyyy')
                              .format(transaction.transactionDate)),
                          _buildTableCell(DateFormat('HH:mm')
                              .format(transaction.transactionDate)),
                          _buildTableCell(
                              _getTransactionTypeText(transaction.type)),
                          _buildTableCell(_getTransactionCategoryText(
                              transaction.category)),
                          _buildTableCell(transaction.description),
                          _buildTableCell(transaction.amount.toString()),
                          _buildTableCell(account.currency),
                          _buildTableCell(transaction.balanceAfter.toString()),
                        ],
                      )),
                ],
              ),
            ];
          },
        ),
      );

      // Dosya adı oluştur
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = '${account.name}_HesapHareketleri_$timestamp.pdf';
      final finalFileName = fileName ?? defaultFileName;

      // PDF'i byte array'e çevir
      final bytes = await pdf.save();
      debugPrint('PDF export: ${bytes.length} byte veri oluşturuldu');

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

        debugPrint('PDF export: Web indirme başlatıldı - $finalFileName');
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

        debugPrint('PDF export: Dosya kaydedildi - $filePath');
        debugPrint('PDF export: Dosya boyutu - ${file.lengthSync()} byte');

        return filePath;
      }
    } catch (e) {
      throw Exception('PDF export hatası: $e');
    }
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 10 : 9,
        ),
      ),
    );
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