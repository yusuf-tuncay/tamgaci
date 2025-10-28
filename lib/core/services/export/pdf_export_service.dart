import 'dart:io';
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

  // Cache temizleme fonksiyonu
  static void clearCache() {
    _cachedLogo = null;
    _cachedCompanyLogo = null;
    debugPrint('PDF logo cache temizlendi');
  }

  // TAMGACI logosu yükleme fonksiyonu - fallback mekanizması ile
  static Future<void> _ensureLogoLoaded() async {
    if (_cachedLogo != null) {
      debugPrint(
          'TAMGACI logosu zaten yüklü - tip: ${_cachedLogo!.runtimeType}');
      return;
    }

    // Logo dosya yolları - öncelik sırasına göre
    final List<String> logoPaths = [
      'assets/images/logos/180x180logo.png', // Ana logo - 180x180 (hesap makinesi logosu)
      'assets/images/logos/192x192logo.png', // Alternatif 1
      'assets/images/logos/160x160logo.png', // Alternatif 2
      'assets/images/logos/140x140logo.png', // Alternatif 3
      'assets/images/logos/512x512logo.png', // Alternatif 4
    ];

    for (String logoPath in logoPaths) {
      try {
        debugPrint('TAMGACI logosu yükleniyor: $logoPath');

        // Logo dosyasını asset'ten yükle
        final logoData = await rootBundle.load(logoPath);
        final logoBytes = logoData.buffer.asUint8List();

        debugPrint(
            'TAMGACI logo dosyası yüklendi: $logoPath, boyut: ${logoBytes.length} byte');

        _cachedLogo = pw.MemoryImage(logoBytes);
        debugPrint(
            'TAMGACI logosu başarıyla MemoryImage\'a dönüştürüldü: $logoPath');
        return; // Başarılı yükleme, döngüden çık
      } catch (e) {
        debugPrint('TAMGACI logo yükleme hatası ($logoPath): $e');
        continue; // Sonraki dosyayı dene
      }
    }

    // Tüm dosyalar başarısız oldu
    debugPrint('TAMGACI logosu hiçbir dosyadan yüklenemedi');
    _cachedLogo = null;
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
      // Cache'i temizle ve logoları yeniden yükle
      clearCache();
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
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // TAMGACI logosu sol üst köşede
                    pw.Row(
                      children: [
                        if (_cachedLogo != null) ...[
                          pw.Container(
                            width: 80,
                            height: 80,
                            child: pw.Image(_cachedLogo!),
                          ),
                          pw.SizedBox(width: 20),
                        ] else ...[
                          pw.Container(
                            width: 80,
                            height: 80,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.red100,
                              border: pw.Border.all(color: PdfColors.red),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'LOGO YOK',
                                style: pw.TextStyle(
                                    fontSize: 8, color: PdfColors.red),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 20),
                        ],
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                _convertTurkishChars('TAMGACI'),
                                style: pw.TextStyle(
                                  fontSize: 28,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue800,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                _convertTurkishChars(
                                    'Muhasebe ve Finans Yonetim Sistemi'),
                                style: const pw.TextStyle(
                                  fontSize: 16,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 25),
                  ],
                ),
              ),

              // Şirket bilgileri
              if (company != null) ...[
                pw.Header(
                  level: 1,
                  child: pw.Row(
                    children: [
                      pw.Text(
                        _convertTurkishChars('Sirket Bilgileri'),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Spacer(),
                      if (_cachedCompanyLogo != null) ...[
                        pw.Container(
                          width: 50,
                          height: 50,
                          child: pw.Image(_cachedCompanyLogo!),
                        ),
                      ],
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
