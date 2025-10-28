import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../features/accounts/domain/entities/account.dart';
import '../../../features/accounts/domain/entities/account_transaction.dart';
import 'package:flutter/foundation.dart';
import '../../../features/auth/domain/entities/user.dart';
import '../../entities/company.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:flutter/services.dart';

class PdfExportService {
  static pw.MemoryImage? _cachedLogo;
  static pw.MemoryImage? _cachedCompanyLogo;

  // TAMGACI logosu yükleme fonksiyonu
  static Future<void> _ensureLogoLoaded() async {
    if (_cachedLogo != null) {
      debugPrint('TAMGACI logosu zaten yüklü');
      return;
    }

    try {
      debugPrint('TAMGACI logosu yükleniyor...');
      
      // Base64 logo string'i
      const String logoBase64 = 'iVBORw0KGgoAAAANSUhEUgAAALQAAAC0CAYAAAA9zQYyAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAEs2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLyc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpBdHRyaWI9J2h0dHA6Ly9ucy5hdHRyaWJ1dGlvbi5jb20vYWRzLzEuMC8nPgogIDxBdHRyaWI6QWRzPgogICA8cmRmOlNlcT4KICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0nUmVzb3VyY2UnPgogICAgIDxBdHRyaWI6Q3JlYXRlZD4yMDI1LTA5LTIxPC9BdHRyaWI6Q3JlYXRlZD4KICAgICA8QXR0cmliOkV4dElkPjNhNDJiNjMwLTNjY2EtNDEzOS04N2Q5LWEzYjlhN2I1ZDE2NjwvQXR0cmliOkV4dElkPgogICAgIDxBdHRyaWI6RmJJZD41MjUyNjU5MTQxNzk1ODA8L0F0dHJpYjpGYklkPgogICAgIDxBdHRyaWI6VG91Y2hUeXBlPjI8L0F0dHJpYjpUb3VjaFR5cGU+CiAgICA8L3JkZjpsaT4KICAgPC9yZGY6U2VxPgogIDwvQXR0cmliOkFkcz4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6ZGM9J2h0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvJz4KICA8ZGM6dGl0bGU+CiAgIDxyZGY6QWx0PgogICAgPHJkZjpsaSB4bWw6bGFuZz0neC1kZWZhdWx0Jz4xODB4MTgwbG9nbyAtIDE8L3JkZjpsaT4KICAgPC9yZGY6QWx0PgogIDwvZGM6dGl0bGU+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJk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';
      
      // Base64 string'i Uint8List'e çevir
      final logoBytes = Uint8List.fromList(base64Decode(logoBase64));
      
      debugPrint('TAMGACI logo base64\'den yüklendi, boyut: ${logoBytes.length} byte');
      
      _cachedLogo = pw.MemoryImage(logoBytes);
      debugPrint('TAMGACI logosu başarıyla MemoryImage\'a dönüştürüldü');
    } catch (e) {
      debugPrint('TAMGACI logo yükleme hatası: $e');
      _cachedLogo = null;
    }
  }

  // Şirket logosu yükleme fonksiyonu
  static Future<void> _ensureCompanyLogoLoaded(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) {
      _cachedCompanyLogo = null;
      return;
    }

    try {
      // HTTP ile şirket logosunu yükle
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode == 200) {
        _cachedCompanyLogo = pw.MemoryImage(response.bodyBytes);
        debugPrint('Şirket logosu başarıyla yüklendi: $logoUrl');
      } else {
        debugPrint('Şirket logosu yüklenemedi: ${response.statusCode}');
        _cachedCompanyLogo = null;
      }
    } catch (e) {
      debugPrint('Şirket logosu yükleme hatası: $e');
      _cachedCompanyLogo = null;
    }
  }

  // Türkçe karakterleri ASCII karakterlerle değiştir
  static String _convertTurkishChars(String text) {
    return text
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U');
  }

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
      // Logoları yükle
      await _ensureLogoLoaded();
      await _ensureCompanyLogoLoaded(company?.logoUrl);

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
                    // Logo ve başlık
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (_cachedLogo != null) ...[
                          pw.Container(
                            width: 60,
                            height: 60,
                            child: pw.Image(_cachedLogo!),
                          ),
                          pw.SizedBox(width: 15),
                        ],
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              _convertTurkishChars('TAMGACI'),
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              _convertTurkishChars(
                                  'Muhasebe ve Finans Yonetim Sistemi'),
                              style: const pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),

              // Şirket bilgileri
              if (company != null) ...[
                pw.Header(
                  level: 1,
                  child: pw.Row(
                    children: [
                      if (_cachedCompanyLogo != null) ...[
                        pw.Container(
                          width: 30,
                          height: 30,
                          child: pw.Image(_cachedCompanyLogo!),
                        ),
                        pw.SizedBox(width: 10),
                      ],
                      pw.Text(
                        _convertTurkishChars('Sirket Bilgileri'),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
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
                      _buildInfoRow(_convertTurkishChars('Sirket Adi:'),
                          _convertTurkishChars(company.name)),
                      _buildInfoRow(_convertTurkishChars('Vergi No:'),
                          _convertTurkishChars(user?.taxId ?? 'Belirtilmemis')),
                      _buildInfoRow(
                          _convertTurkishChars('Adres:'),
                          _convertTurkishChars(company.address ??
                              user?.address ??
                              'Belirtilmemis')),
                      _buildInfoRow(
                          _convertTurkishChars('Telefon:'),
                          _convertTurkishChars(
                              company.phone ?? user?.phone ?? 'Belirtilmemis')),
                      _buildInfoRow(
                          _convertTurkishChars('E-posta:'),
                          _convertTurkishChars(
                              company.email ?? user?.email ?? 'Belirtilmemis')),
                      _buildInfoRow(
                          _convertTurkishChars('Web Sitesi:'),
                          _convertTurkishChars(
                              company.website ?? 'Belirtilmemis')),
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
                    _convertTurkishChars('Kullanici Bilgileri'),
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
                      _buildInfoRow(_convertTurkishChars('Kullanici Adi:'),
                          _convertTurkishChars('${user.name} ${user.surname}')),
                      _buildInfoRow(_convertTurkishChars('E-posta:'),
                          _convertTurkishChars(user.email)),
                      _buildInfoRow(_convertTurkishChars('Telefon:'),
                          _convertTurkishChars(user.phone ?? 'Belirtilmemis')),
                      _buildInfoRow(
                          _convertTurkishChars('Adres:'),
                          _convertTurkishChars(
                              user.address ?? 'Belirtilmemis')),
                      _buildInfoRow(_convertTurkishChars('Vergi No:'),
                          _convertTurkishChars(user.taxId ?? 'Belirtilmemis')),
                      _buildInfoRow(
                          _convertTurkishChars('Vergi Dairesi:'),
                          _convertTurkishChars(
                              user.taxOffice ?? 'Belirtilmemis')),
                      _buildInfoRow(
                          _convertTurkishChars('Fatura Adresi:'),
                          _convertTurkishChars(
                              user.billingAddress ?? 'Belirtilmemis')),
                      _buildInfoRow(_convertTurkishChars('Kayit Tarihi:'),
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
                  _convertTurkishChars('Rapor Bilgileri'),
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
                    _buildInfoRow(_convertTurkishChars('Rapor Tarihi:'),
                        DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())),
                    _buildInfoRow(_convertTurkishChars('Rapor Turu:'),
                        _convertTurkishChars('Hesap Hareketleri Raporu')),
                    _buildInfoRow(_convertTurkishChars('Toplam Islem:'),
                        '${transactions.length} adet'),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Filtreleme bilgileri
              pw.Header(
                level: 1,
                child: pw.Text(
                  _convertTurkishChars('Filtreleme Bilgileri'),
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
                      _buildInfoRow(_convertTurkishChars('Tarih Araligi:'),
                          '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}')
                    else
                      _buildInfoRow(_convertTurkishChars('Tarih Araligi:'),
                          _convertTurkishChars('Tum tarihler')),
                    if (transactionType != null)
                      _buildInfoRow(
                          _convertTurkishChars('Islem Turu:'),
                          _convertTurkishChars(
                              _getTransactionTypeText(transactionType)))
                    else
                      _buildInfoRow(_convertTurkishChars('Islem Turu:'),
                          _convertTurkishChars('Tum islem turleri')),
                    if (transactionCategory != null)
                      _buildInfoRow(
                          _convertTurkishChars('Kategori:'),
                          _convertTurkishChars(
                              _getTransactionCategoryText(transactionCategory)))
                    else
                      _buildInfoRow(_convertTurkishChars('Kategori:'),
                          _convertTurkishChars('Tum kategoriler')),
                    if (searchQuery != null && searchQuery.isNotEmpty)
                      _buildInfoRow(_convertTurkishChars('Arama:'),
                          _convertTurkishChars(searchQuery))
                    else
                      _buildInfoRow(_convertTurkishChars('Arama:'),
                          _convertTurkishChars('Arama yapilmadi')),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Hesap bilgileri
              pw.Header(
                level: 1,
                child: pw.Text(
                  _convertTurkishChars('Hesap Bilgileri'),
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
                    _buildInfoRow(_convertTurkishChars('Hesap Adi:'),
                        _convertTurkishChars(account.name)),
                    _buildInfoRow(
                        _convertTurkishChars('Hesap Turu:'),
                        _convertTurkishChars(
                            _getAccountTypeText(account.type))),
                    _buildInfoRow(
                        _convertTurkishChars('Para Birimi:'), account.currency),
                    _buildInfoRow(_convertTurkishChars('Mevcut Bakiye:'),
                        '${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}'),
                    _buildInfoRow(
                        _convertTurkishChars('Olusturulma Tarihi:'),
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
                  _convertTurkishChars('Hesap Hareketleri'),
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
                      _buildTableCell(_convertTurkishChars('Tarih'),
                          isHeader: true),
                      _buildTableCell(_convertTurkishChars('Saat'),
                          isHeader: true),
                      _buildTableCell(_convertTurkishChars('Islem Turu'),
                          isHeader: true),
                      _buildTableCell(_convertTurkishChars('Kategori'),
                          isHeader: true),
                      _buildTableCell(_convertTurkishChars('Aciklama'),
                          isHeader: true),
                      _buildTableCell(_convertTurkishChars('Miktar'),
                          isHeader: true),
                      _buildTableCell(_convertTurkishChars('Para Birimi'),
                          isHeader: true),
                      _buildTableCell(_convertTurkishChars('Bakiye Sonrasi'),
                          isHeader: true),
                    ],
                  ),
                  // İşlemler
                  ...sortedTransactions.map((transaction) => pw.TableRow(
                        children: [
                          _buildTableCell(DateFormat('dd.MM.yyyy')
                              .format(transaction.transactionDate)),
                          _buildTableCell(DateFormat('HH:mm')
                              .format(transaction.transactionDate)),
                          _buildTableCell(_convertTurkishChars(
                              _getTransactionTypeText(transaction.type))),
                          _buildTableCell(_convertTurkishChars(
                              _getTransactionCategoryText(
                                  transaction.category))),
                          _buildTableCell(
                              _convertTurkishChars(transaction.description)),
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
