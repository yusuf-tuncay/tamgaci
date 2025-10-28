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
import '../../../features/company/domain/entities/company_info.dart';
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
      'assets/images/logos/256x256logorenkli.png', // Ana logo - renkli
      'assets/images/logos/512x512logo.png', // Alternatif 1
      'assets/images/logos/192x192logo.png', // Alternatif 2
      'assets/images/logos/180x180logo.png', // Alternatif 3
      'assets/images/logos/160x160logo.png', // Alternatif 4
      'assets/images/logos/140x140logo.png', // Alternatif 5
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
    debugPrint('=== FİRMA LOGOSU YÜKLEME BAŞLADI ===');
    debugPrint('Logo URL: $logoUrl');

    if (logoUrl == null || logoUrl.isEmpty) {
      debugPrint('Firma logosu URL\'si boş - logo yüklenmeyecek');
      _cachedCompanyLogo = null;
      return;
    }

    try {
      debugPrint('Firma logosu yükleniyor: $logoUrl');
      // HTTP ile şirket logosunu yükle
      final response = await http.get(Uri.parse(logoUrl));
      debugPrint('Firma logosu HTTP yanıtı: ${response.statusCode}');

      if (response.statusCode == 200) {
        final logoBytes = response.bodyBytes;
        debugPrint('Firma logosu yüklendi, boyut: ${logoBytes.length} byte');
        _cachedCompanyLogo = pw.MemoryImage(logoBytes);
        debugPrint('Firma logosu başarıyla MemoryImage\'a dönüştürüldü');
      } else {
        debugPrint('Firma logosu yüklenemedi: HTTP ${response.statusCode}');
        _cachedCompanyLogo = null;
      }
    } catch (e) {
      debugPrint('Firma logosu yükleme hatası: $e');
      _cachedCompanyLogo = null;
    }
    debugPrint('=== FİRMA LOGOSU YÜKLEME BİTTİ ===');
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
    CompanyInfo? companyInfo,
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

    // Company ve User verilerini debug et
    debugPrint('=== VERİ KONTROLÜ ===');
    debugPrint('Company: ${company?.name ?? 'NULL'}');
    debugPrint('Company logoUrl: ${company?.logoUrl ?? 'NULL'}');
    debugPrint('Company address: ${company?.address ?? 'NULL'}');
    debugPrint('Company phone: ${company?.phone ?? 'NULL'}');
    debugPrint('Company email: ${company?.email ?? 'NULL'}');
    debugPrint('Company website: ${company?.website ?? 'NULL'}');
    debugPrint('CompanyInfo: ${companyInfo?.name ?? 'NULL'}');
    debugPrint('CompanyInfo logoUrl: ${companyInfo?.logoUrl ?? 'NULL'}');
    debugPrint('CompanyInfo address: ${companyInfo?.address ?? 'NULL'}');
    debugPrint('CompanyInfo phone: ${companyInfo?.phone ?? 'NULL'}');
    debugPrint('CompanyInfo email: ${companyInfo?.email ?? 'NULL'}');
    debugPrint('CompanyInfo website: ${companyInfo?.website ?? 'NULL'}');
    debugPrint('User: ${user?.name ?? 'NULL'} ${user?.surname ?? ''}');
    debugPrint('User phone: ${user?.phone ?? 'NULL'}');
    debugPrint('User address: ${user?.address ?? 'NULL'}');
    debugPrint('User taxId: ${user?.taxId ?? 'NULL'}');
    debugPrint('User taxOffice: ${user?.taxOffice ?? 'NULL'}');
    debugPrint('User billingAddress: ${user?.billingAddress ?? 'NULL'}');
    debugPrint('=== VERİ KONTROLÜ BİTTİ ===');

    try {
      // Cache'i temizle ve logoları yeniden yükle
      clearCache();
      await _ensureLogoLoaded();
      await _ensureCompanyLogoLoaded(companyInfo?.logoUrl ?? company?.logoUrl);

      // PDF dosyası oluştur (varsayılan font kullan)
      final pdf = pw.Document();
      final sortedTransactions = List<AccountTransaction>.from(transactions)
        ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

      // PDF içeriği oluştur
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          footer: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Sol taraf: TAMGACI branding
                  pw.Row(
                    children: [
                      if (_cachedLogo != null) ...[
                        pw.Container(
                          width: 20,
                          height: 20,
                          child: pw.Image(_cachedLogo!),
                        ),
                        pw.SizedBox(width: 8),
                      ] else ...[
                        pw.Container(
                          width: 20,
                          height: 20,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.red100,
                            border: pw.Border.all(color: PdfColors.red),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              'LOGO YOK',
                              style: const pw.TextStyle(
                                  fontSize: 5, color: PdfColors.red),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                      ],
                      pw.Text(
                        _convertTurkishChars('TAMGACI'),
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        _convertTurkishChars('Muhasebe ve İş Yönetim Sistemi'),
                        style: const pw.TextStyle(
                          fontSize: 6,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  // Sağ taraf: Sayfa numarası
                  pw.Text(
                    '${context.pageNumber}/${context.pagesCount}',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context context) {
            return [
              // Birleştirilmiş Şirket ve Kullanıcı bilgileri
              if (companyInfo != null || company != null || user != null) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColors.grey50,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Üst kısım: Firma logosu ve adı
                      if (companyInfo != null || company != null) ...[
                        pw.Row(
                          children: [
                            // Firma logosu (küçük)
                            if (_cachedCompanyLogo != null)
                              pw.Container(
                                width: 40,
                                height: 40,
                                decoration: pw.BoxDecoration(
                                  border:
                                      pw.Border.all(color: PdfColors.grey300),
                                  borderRadius: pw.BorderRadius.circular(6),
                                  color: PdfColors.white,
                                ),
                                child: pw.Image(
                                  _cachedCompanyLogo!,
                                  fit: pw.BoxFit.contain,
                                ),
                              )
                            else
                              pw.Container(
                                width: 40,
                                height: 40,
                                decoration: pw.BoxDecoration(
                                  border:
                                      pw.Border.all(color: PdfColors.grey300),
                                  borderRadius: pw.BorderRadius.circular(6),
                                  color: PdfColors.grey100,
                                ),
                                child: pw.Center(
                                  child: pw.Text(
                                    _convertTurkishChars('LOGO'),
                                    style: const pw.TextStyle(
                                      fontSize: 8,
                                      color: PdfColors.grey500,
                                    ),
                                  ),
                                ),
                              ),
                            pw.SizedBox(width: 10),
                            // Firma adı
                            pw.Text(
                              _convertTurkishChars(
                                  companyInfo?.name ?? company?.name ?? ''),
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 15),
                      ],
                      // Alt kısım: İki sütunlu bilgiler
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Sol sütun: Şirket bilgileri + Rapor bilgileri + Kullanıcı adı
                          pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Şirket bilgileri
                                if (companyInfo != null || company != null) ...[
                                  _buildInfoRow(
                                      _convertTurkishChars('Vergi No:'),
                                      _convertTurkishChars([
                                        (companyInfo?.taxNumber ??
                                            user?.taxId ??
                                            'Belirtilmemis'),
                                        if ((companyInfo?.taxOffice ??
                                                    user?.taxOffice) !=
                                                null &&
                                            (companyInfo?.taxOffice ??
                                                    user?.taxOffice)!
                                                .isNotEmpty)
                                          '(${(companyInfo?.taxOffice ?? user?.taxOffice)})',
                                      ].join(' '))),
                                  _buildInfoRow(
                                      _convertTurkishChars('Adres:'),
                                      _convertTurkishChars(
                                          (companyInfo != null &&
                                                  companyInfo
                                                      .fullAddress.isNotEmpty)
                                              ? companyInfo.fullAddress
                                              : (company?.address ??
                                                  'Belirtilmemis'))),
                                  _buildInfoRow(
                                      _convertTurkishChars('Telefon:'),
                                      _convertTurkishChars(companyInfo?.phone ??
                                          company?.phone ??
                                          'Belirtilmemis')),
                                  _buildInfoRow(
                                      _convertTurkishChars('E-posta:'),
                                      _convertTurkishChars(companyInfo?.email ??
                                          company?.email ??
                                          'Belirtilmemis')),
                                  _buildInfoRow(
                                      _convertTurkishChars('Web Sitesi:'),
                                      _convertTurkishChars(
                                          companyInfo?.website ??
                                              company?.website ??
                                              'Belirtilmemis')),
                                ],
                                // Rapor bilgileri
                                pw.SizedBox(height: 10),
                                pw.Text(
                                  _convertTurkishChars('Rapor Bilgileri'),
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue700,
                                  ),
                                ),
                                pw.SizedBox(height: 5),
                                _buildInfoRow(
                                    _convertTurkishChars('Rapor Tarihi:'),
                                    DateFormat('dd.MM.yyyy HH:mm')
                                        .format(DateTime.now())),
                                _buildInfoRow(
                                    _convertTurkishChars('Rapor Turu:'),
                                    _convertTurkishChars(
                                        'Hesap Hareketleri Raporu')),
                                _buildInfoRow(
                                    _convertTurkishChars('Toplam Islem:'),
                                    '${transactions.length} adet'),
                                // Kullanıcı adı
                                if (user != null) ...[
                                  pw.SizedBox(height: 10),
                                  pw.Text(
                                    _convertTurkishChars('Kullanici Bilgileri'),
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.blue700,
                                    ),
                                  ),
                                  pw.SizedBox(height: 5),
                                  _buildInfoRow(
                                      _convertTurkishChars('Kullanici Adi:'),
                                      _convertTurkishChars(
                                          '${user.name} ${user.surname}')),
                                ],
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          // Sağ sütun: Filtreleme + Hesap bilgileri
                          pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Filtreleme bilgileri
                                pw.Text(
                                  _convertTurkishChars('Filtreleme Bilgileri'),
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue700,
                                  ),
                                ),
                                pw.SizedBox(height: 5),
                                if (startDate != null && endDate != null)
                                  _buildInfoRow(
                                      _convertTurkishChars('Tarih Araligi:'),
                                      '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}')
                                else
                                  _buildInfoRow(
                                      _convertTurkishChars('Tarih Araligi:'),
                                      _convertTurkishChars('Tum tarihler')),
                                if (transactionType != null)
                                  _buildInfoRow(
                                      _convertTurkishChars('Islem Turu:'),
                                      _convertTurkishChars(
                                          _getTransactionTypeText(
                                              transactionType)))
                                else
                                  _buildInfoRow(
                                      _convertTurkishChars('Islem Turu:'),
                                      _convertTurkishChars(
                                          'Tum islem turleri')),
                                if (transactionCategory != null)
                                  _buildInfoRow(
                                      _convertTurkishChars('Kategori:'),
                                      _convertTurkishChars(
                                          _getTransactionCategoryText(
                                              transactionCategory)))
                                else
                                  _buildInfoRow(
                                      _convertTurkishChars('Kategori:'),
                                      _convertTurkishChars('Tum kategoriler')),
                                if (searchQuery != null &&
                                    searchQuery.isNotEmpty)
                                  _buildInfoRow(_convertTurkishChars('Arama:'),
                                      _convertTurkishChars(searchQuery))
                                else
                                  _buildInfoRow(_convertTurkishChars('Arama:'),
                                      _convertTurkishChars('Arama yapilmadi')),
                                // Hesap bilgileri
                                pw.SizedBox(height: 10),
                                pw.Text(
                                  _convertTurkishChars('Hesap Bilgileri'),
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue700,
                                  ),
                                ),
                                pw.SizedBox(height: 5),
                                _buildInfoRow(
                                    _convertTurkishChars('Hesap Adi:'),
                                    _convertTurkishChars(account.name)),
                                _buildInfoRow(
                                    _convertTurkishChars('Hesap Turu:'),
                                    _convertTurkishChars(
                                        _getAccountTypeText(account.type))),
                                _buildInfoRow(
                                    _convertTurkishChars('Para Birimi:'),
                                    account.currency),
                                _buildInfoRow(
                                    _convertTurkishChars('Mevcut Bakiye:'),
                                    '${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}'),
                                _buildInfoRow(
                                    _convertTurkishChars('Olusturulma Tarihi:'),
                                    DateFormat('dd.MM.yyyy HH:mm')
                                        .format(account.createdAt)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),
              ],

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
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9),
            ),
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
