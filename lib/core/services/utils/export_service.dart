// ========== EXPORT SERVICE ==========
// lib/core/services/export_service.dart

import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/currency_helper.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/core/services/tenant_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

/// Dışa aktarım formatları
enum ExportFormat {
  excel('Excel'),
  pdf('PDF'),
  csv('CSV');

  const ExportFormat(this.displayName);
  final String displayName;
}

/// Dışa aktarım servisi
class ExportService {
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TenantService _tenantService = TenantService();
  static pw.MemoryImage? _cachedCompanyLogo;
  static pw.Font? _cachedRobotoFont;
  static pw.Font? _cachedRobotoBoldFont;

  /// Excel dosyası oluştur
  Future<Uint8List> exportToExcel({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
    String? sheetName,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel[sheetName ?? 'Sheet1'];

      // Başlık ekle
      sheet.cell(CellIndex.indexByString('A1')).value = title;
      sheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );

      // Başlıkları birleştir (A1'den son sütuna kadar)
      final lastColumn = String.fromCharCode(65 + headers.length - 1);
      sheet.merge(CellIndex.indexByString('A1'),
          CellIndex.indexByString('${lastColumn}1'));

      // Header'ları ekle
      for (int i = 0; i < headers.length; i++) {
        final cellIndex =
            CellIndex.indexByString('${String.fromCharCode(65 + i)}2');
        sheet.cell(cellIndex).value = headers[i];
        sheet.cell(cellIndex).cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: 'FF2196F3', // Blue color
          fontColorHex: 'FFFFFFFF', // White color
        );
      }

      // Verileri ekle
      for (int row = 0; row < data.length; row++) {
        for (int col = 0; col < data[row].length; col++) {
          final cellIndex = CellIndex.indexByString(
              '${String.fromCharCode(65 + col)}${row + 3}');
          final value = data[row][col];

          if (value is num) {
            sheet.cell(cellIndex).value = value.toDouble();
          } else if (value is DateTime) {
            sheet.cell(cellIndex).value = value;
          } else {
            sheet.cell(cellIndex).value = value.toString();
          }
        }
      }

      // Sütun genişliklerini ayarla (Excel package'da setColumnWidth mevcut değil)
      // for (int i = 0; i < headers.length; i++) {
      //   sheet.setColumnWidth(i, 15);
      // }

      final bytes = excel.encode();
      _logger.i(
          'Excel dosyası oluşturuldu: ${headers.length} sütun, ${data.length} satır');
      return Uint8List.fromList(bytes!);
    } catch (e) {
      _logger.e('Excel dosyası oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Türkçe karakterleri İngilizce karakterlerle değiştir
  String _convertTurkishChars(String text) {
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

  /// Firma logosu yükleme fonksiyonu
  Future<void> _ensureCompanyLogoLoaded(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) {
      _cachedCompanyLogo = null;
      return;
    }

    try {
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode == 200) {
        final logoBytes = response.bodyBytes;
        _cachedCompanyLogo = pw.MemoryImage(logoBytes);
      } else {
        _cachedCompanyLogo = null;
      }
    } catch (e) {
      _cachedCompanyLogo = null;
    }
  }

  /// Roboto fontunu yükle (Unicode desteği için)
  Future<void> _ensureRobotoFontLoaded() async {
    if (_cachedRobotoFont != null && _cachedRobotoBoldFont != null) {
      return;
    }

    // Web platformunda font yükleme desteklenmiyor, varsayılan font kullanılacak
    if (kIsWeb) {
      return;
    }

    try {
      // Roboto Regular fontunu yükle
      final regularFontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      _cachedRobotoFont = pw.Font.ttf(regularFontData);

      // Roboto Bold fontunu yükle
      final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      _cachedRobotoBoldFont = pw.Font.ttf(boldFontData);
    } catch (e) {
      // Font yükleme başarısız, varsayılan font kullanılacak
      _logger.w('Roboto font yüklenemedi, varsayılan font kullanılacak: $e');
    }
  }

  /// Firma bilgilerini getir
  Future<Map<String, dynamic>?> _getCompanyInfo(String? tenantId) async {
    try {
      if (tenantId == null || tenantId.isEmpty) {
        final currentTenantId = await _tenantService.getUserTenantId();
        if (currentTenantId == null) return null;
        tenantId = currentTenantId;
      }

      // Önce tenants/{tenantId}/companies/{tenantId} koleksiyonundan dene
      final companyDoc = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('companies')
          .doc(tenantId)
          .get();

      if (companyDoc.exists) {
        final data = companyDoc.data()!;
        return {
          'name': data['name'] ?? '',
          'logoUrl': data['logoUrl'],
        };
      }

      // Fallback: company_info koleksiyonundan dene
      final companyInfoDoc = await _firestore
          .collection('company_info')
          .doc(tenantId)
          .get();

      if (companyInfoDoc.exists) {
        final data = companyInfoDoc.data()!;
        return {
          'name': data['name'] ?? '',
          'logoUrl': data['logoUrl'],
        };
      }

      return null;
    } catch (e) {
      _logger.w('Firma bilgileri alınamadı: $e');
      return null;
    }
  }

  /// PDF dosyası oluştur
  Future<Uint8List> exportToPDF({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
    String? subtitle,
    Map<String, dynamic>? summary,
    String? tenantId,
  }) async {
    try {
      // Firma bilgilerini al
      final companyInfo = await _getCompanyInfo(tenantId);
      if (companyInfo != null && companyInfo['logoUrl'] != null) {
        await _ensureCompanyLogoLoaded(companyInfo['logoUrl'] as String?);
      }

      // Roboto fontunu yükle (Unicode desteği için)
      await _ensureRobotoFontLoaded();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Firma logosu ve adı
              if (companyInfo != null) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 20),
                  child: pw.Row(
                    children: [
                      // Firma logosu
                      if (_cachedCompanyLogo != null)
                        pw.Container(
                          width: 50,
                          height: 50,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
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
                          width: 50,
                          height: 50,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
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
                      pw.SizedBox(width: 12),
                      // Firma adı
                      pw.Expanded(
                        child: pw.Text(
                          _convertTurkishChars(companyInfo['name'] ?? ''),
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 20),
              ],

              // Başlık
              pw.Header(
                level: 0,
                child: pw.Text(
                  _convertTurkishChars(title),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              if (subtitle != null) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  _convertTurkishChars(subtitle),
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],

              pw.SizedBox(height: 20),

              // Özet bilgileri
              if (summary != null) ...[
                _buildSummarySection(summary),
                pw.SizedBox(height: 20),
              ],

              // Tablo
              _buildTable(headers, data),
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      _logger.i(
          'PDF dosyası oluşturuldu: ${headers.length} sütun, ${data.length} satır');
      return bytes;
    } catch (e) {
      _logger.e('PDF dosyası oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// CSV dosyası oluştur
  Future<String> exportToCSV({
    required List<String> headers,
    required List<List<dynamic>> data,
  }) async {
    try {
      final buffer = StringBuffer();

      // Header'ları ekle
      buffer.writeln(headers.map((h) => '"$h"').join(','));

      // Verileri ekle
      for (final row in data) {
        final csvRow = row.map((cell) {
          final value = cell.toString();
          // CSV'de özel karakterleri escape et
          if (value.contains(',') ||
              value.contains('"') ||
              value.contains('\n')) {
            return '"${value.replaceAll('"', '""')}"';
          }
          return '"$value"';
        }).join(',');
        buffer.writeln(csvRow);
      }

      _logger.i(
          'CSV dosyası oluşturuldu: ${headers.length} sütun, ${data.length} satır');
      return buffer.toString();
    } catch (e) {
      _logger.e('CSV dosyası oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Firebase'den müşteri listesi çekme - Multi-tenant
  Future<List<Map<String, dynamic>>> getCustomersFromFirebase() async {
    try {
      // Kullanıcının tenant ID'sini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppLogger.warning('No authenticated user found');
        return [];
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        AppLogger.warning('User document not found');
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String?;

      if (tenantId == null || tenantId.isEmpty) {
        AppLogger.warning('No tenant ID found for user');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tenants')
          .doc(tenantId)
          .collection('customers')
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'phone': data['phone'] ?? '',
          'address': data['address'] ?? '',
          'taxNumber': data['taxNumber'] ?? '',
          'type': data['customerType'] ?? 'individual',
          'status': data['status'] ?? 'active',
          'creditLimit': (data['creditLimit'] ?? 0.0).toDouble(),
          'currentBalance': (data['currentBalance'] ?? 0.0).toDouble(),
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      _logger.e('Error getting customers from Firebase: $e');
      rethrow;
    }
  }

  /// Firebase'den ürün listesi çekme
  Future<List<Map<String, dynamic>>> getProductsFromFirebase() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'code': data['sku'] ?? '',
          'barcode': data['barcode'] ?? '',
          'category': data['category'] ?? '',
          'type': data['type'] ?? 'product',
          'unit': data['unit'] ?? 'Adet',
          'price': (data['unitPrice'] ?? 0.0).toDouble(),
          'cost': (data['cost'] ?? 0.0).toDouble(),
          'stock': (data['stockQuantity'] ?? 0).toInt(),
          'minStock': (data['minStockLevel'] ?? 0).toInt(),
          'maxStock': (data['maxStockLevel'] ?? 0).toInt(),
          'warehouseName': data['warehouseName'] ?? '',
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      _logger.e('Error getting products from Firebase: $e');
      rethrow;
    }
  }

  /// Firebase'den satış listesi çekme
  Future<List<Map<String, dynamic>>> getSalesFromFirebase() async {
    try {
      final querySnapshot = await _firestore.collection('invoices').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'saleNumber': data['invoiceNumber'] ?? '',
          'customerName': data['customerName'] ?? '',
          'saleDate': (data['invoiceDate'] as Timestamp).toDate(),
          'dueDate': data['dueDate'] != null
              ? (data['dueDate'] as Timestamp).toDate()
              : null,
          'type': data['type'] ?? 'sale',
          'status': data['status'] ?? 'draft',
          'paymentStatus': data['isPaid'] == true ? 'Ödendi' : 'Ödenmedi',
          'subtotal': (data['subtotal'] ?? 0.0).toDouble(),
          'taxAmount': (data['taxAmount'] ?? 0.0).toDouble(),
          'discountAmount': (data['discountAmount'] ?? 0.0).toDouble(),
          'totalAmount': (data['totalAmount'] ?? 0.0).toDouble(),
          'currency': data['currencyCode'] ?? 'TRY',
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      _logger.e('Error getting sales from Firebase: $e');
      rethrow;
    }
  }

  /// Müşteri listesi için Excel oluştur (Firebase'den)
  Future<Uint8List> exportCustomersToExcelFromFirebase() async {
    final customers = await getCustomersFromFirebase();
    return exportCustomersToExcel(customers);
  }

  /// Müşteri listesi için Excel oluştur
  Future<Uint8List> exportCustomersToExcel(
      List<Map<String, dynamic>> customers) async {
    final headers = [
      'Müşteri Adı',
      'E-posta',
      'Telefon',
      'Adres',
      'Vergi No',
      'Tip',
      'Durum',
      'Kredi Limiti',
      'Mevcut Bakiye',
      'Oluşturulma Tarihi',
    ];

    final data = customers
        .map((customer) => [
              customer['name'] ?? '',
              customer['email'] ?? '',
              customer['phone'] ?? '',
              customer['address'] ?? '',
              customer['taxNumber'] ?? '',
              customer['type'] ?? '',
              customer['status'] ?? '',
              CurrencyHelper.formatCurrency(
                  customer['creditLimit'] ?? 0, 'TRY'),
              CurrencyHelper.formatCurrency(
                  customer['currentBalance'] ?? 0, 'TRY'),
              _formatDate(customer['createdAt']),
            ])
        .toList();

    return exportToExcel(
      title: 'Müşteri Listesi',
      headers: headers,
      data: data,
      sheetName: 'Müşteriler',
    );
  }

  /// Ürün listesi için Excel oluştur (Firebase'den)
  Future<Uint8List> exportProductsToExcelFromFirebase() async {
    final products = await getProductsFromFirebase();
    return exportProductsToExcel(products);
  }

  /// Ürün listesi için Excel oluştur
  Future<Uint8List> exportProductsToExcel(
      List<Map<String, dynamic>> products) async {
    final headers = [
      'Ürün Adı',
      'Kod',
      'Barkod',
      'Kategori',
      'Tip',
      'Birim',
      'Fiyat',
      'Maliyet',
      'Stok',
      'Min. Stok',
      'Max. Stok',
      'Depo',
      'Oluşturulma Tarihi',
    ];

    final data = products
        .map((product) => [
              product['name'] ?? '',
              product['code'] ?? '',
              product['barcode'] ?? '',
              product['category'] ?? '',
              product['type'] ?? '',
              product['unit'] ?? '',
              CurrencyHelper.formatCurrency(product['price'] ?? 0, 'TRY'),
              CurrencyHelper.formatCurrency(product['cost'] ?? 0, 'TRY'),
              product['stock'] ?? 0,
              product['minStock'] ?? 0,
              product['maxStock'] ?? 0,
              product['warehouseName'] ?? '',
              _formatDate(product['createdAt']),
            ])
        .toList();

    return exportToExcel(
      title: 'Ürün Listesi',
      headers: headers,
      data: data,
      sheetName: 'Ürünler',
    );
  }

  /// Satış listesi için Excel oluştur (Firebase'den)
  Future<Uint8List> exportSalesToExcelFromFirebase() async {
    final sales = await getSalesFromFirebase();
    return exportSalesToExcel(sales);
  }

  /// Satış listesi için Excel oluştur
  Future<Uint8List> exportSalesToExcel(List<Map<String, dynamic>> sales) async {
    final headers = [
      'Satış No',
      'Müşteri',
      'Tarih',
      'Vade Tarihi',
      'Tip',
      'Durum',
      'Ödeme Durumu',
      'Ara Toplam',
      'KDV',
      'İndirim',
      'Toplam',
      'Para Birimi',
      'Oluşturulma Tarihi',
    ];

    final data = sales
        .map((sale) => [
              sale['saleNumber'] ?? '',
              sale['customerName'] ?? '',
              _formatDate(sale['saleDate']),
              _formatDate(sale['dueDate']),
              sale['type'] ?? '',
              sale['status'] ?? '',
              sale['paymentStatus'] ?? '',
              CurrencyHelper.formatCurrency(
                  sale['subtotal'] ?? 0, sale['currency'] ?? 'TRY'),
              CurrencyHelper.formatCurrency(
                  sale['taxAmount'] ?? 0, sale['currency'] ?? 'TRY'),
              CurrencyHelper.formatCurrency(
                  sale['discountAmount'] ?? 0, sale['currency'] ?? 'TRY'),
              CurrencyHelper.formatCurrency(
                  sale['totalAmount'] ?? 0, sale['currency'] ?? 'TRY'),
              sale['currency'] ?? 'TRY',
              _formatDate(sale['createdAt']),
            ])
        .toList();

    return exportToExcel(
      title: 'Satış Listesi',
      headers: headers,
      data: data,
      sheetName: 'Satışlar',
    );
  }

  /// Stok raporu için PDF oluştur (Firebase'den)
  Future<Uint8List> exportStockReportToPDFFromFirebase() async {
    final products = await getProductsFromFirebase();

    // Stok özeti hesapla
    final summary = <String, dynamic>{
      'Toplam Ürün': products.length,
      'Toplam Stok':
          products.fold<int>(0, (acc, p) => acc + (p['stock'] as int)),
      'Düşük Stok': products
          .where((p) => (p['stock'] as int) <= (p['minStock'] as int))
          .length,
      'Stokta Olmayan': products.where((p) => (p['stock'] as int) == 0).length,
      'Toplam Değer': products.fold<double>(
          0, (acc, p) => acc + ((p['stock'] as int) * (p['price'] as double))),
    };

    return exportStockReportToPDF(products: products, summary: summary);
  }

  /// Stok raporu için PDF oluştur
  Future<Uint8List> exportStockReportToPDF({
    required List<Map<String, dynamic>> products,
    required Map<String, dynamic> summary,
  }) async {
    final headers = [
      'Ürün Adı',
      'Kod',
      'Kategori',
      'Stok',
      'Min. Stok',
      'Durum',
      'Fiyat',
      'Toplam Değer',
    ];

    final data = products
        .map((product) => [
              product['name'] ?? '',
              product['code'] ?? '',
              product['category'] ?? '',
              product['stock'] ?? 0,
              product['minStock'] ?? 0,
              _getStockStatus(product['stock'], product['minStock']),
              CurrencyHelper.formatCurrency(product['price'] ?? 0, 'TRY'),
              CurrencyHelper.formatCurrency(
                  (product['stock'] ?? 0) * (product['price'] ?? 0), 'TRY'),
            ])
        .toList();

    return exportToPDF(
      title: 'Stok Durumu Raporu',
      subtitle: 'Güncel stok seviyeleri ve uyarılar',
      headers: headers,
      data: data,
      summary: summary,
    );
  }

  /// PDF'de özet bölümü oluştur
  pw.Widget _buildSummarySection(Map<String, dynamic> summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _convertTurkishChars('Özet'),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...summary.entries.map((entry) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(_convertTurkishChars(entry.key)),
                    pw.Text(
                      _convertTurkishChars(entry.value.toString()),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// PDF'de tablo oluştur
  pw.Widget _buildTable(List<String> headers, List<List<dynamic>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        for (int i = 0; i < headers.length; i++) i: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers
              .map((header) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      _convertTurkishChars(header),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ))
              .toList(),
        ),
        // Data rows
        ...data.map((row) => pw.TableRow(
              children: row
                  .map((cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(_convertTurkishChars(cell.toString())),
                      ))
                  .toList(),
            )),
      ],
    );
  }

  /// Tarih formatla
  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return date.toString();
  }

  /// Stok durumu belirle
  String _getStockStatus(dynamic stock, dynamic minStock) {
    final stockValue = (stock ?? 0).toDouble();
    final minStockValue = (minStock ?? 0).toDouble();

    if (stockValue <= 0) return 'Stok Yok';
    if (stockValue <= minStockValue) return 'Düşük Stok';
    return 'Normal';
  }

  /// JSON formatında export et
  Future<Uint8List> exportToJson(Map<String, dynamic> data) async {
    try {
      final jsonString = data.toString();
      return Uint8List.fromList(jsonString.codeUnits);
    } catch (e) {
      _logger.e('Error exporting to JSON: $e');
      rethrow;
    }
  }

  /// JSON formatında import et
  Future<Map<String, dynamic>> importFromJson(Uint8List data) async {
    try {
      final jsonString = String.fromCharCodes(data);
      return jsonString as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error importing from JSON: $e');
      rethrow;
    }
  }

  /// Excel formatında import et
  Future<List<Map<String, dynamic>>> importFromExcel(Uint8List data) async {
    try {
      final excel = Excel.decodeBytes(data);
      final List<Map<String, dynamic>> result = [];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet != null) {
          final headers = sheet.rows[0]
              .map((cell) => cell?.value?.toString() ?? '')
              .toList();

          for (int i = 1; i < sheet.rows.length; i++) {
            final row = sheet.rows[i];
            final Map<String, dynamic> rowData = {};

            for (int j = 0; j < headers.length; j++) {
              rowData[headers[j]] = row[j]?.value?.toString() ?? '';
            }

            result.add(rowData);
          }
        }
      }

      return result;
    } catch (e) {
      _logger.e('Error importing from Excel: $e');
      rethrow;
    }
  }

  /// CSV formatında export et (binary)
  Future<Uint8List> exportToCSVBinary({
    required List<Map<String, dynamic>> data,
    required List<String> headers,
  }) async {
    try {
      final csvContent = StringBuffer();

      // Headers
      csvContent.writeln(headers.join(','));

      // Data rows
      for (final row in data) {
        final values =
            headers.map((header) => row[header]?.toString() ?? '').toList();
        csvContent.writeln(values.join(','));
      }

      return Uint8List.fromList(csvContent.toString().codeUnits);
    } catch (e) {
      _logger.e('Error exporting to CSV: $e');
      rethrow;
    }
  }
}
