// ========== EXCEL SERVICE ==========
// lib/core/services/excel_service.dart

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/logger.dart';
import '../../features/customers/domain/entities/customer.dart';
import '../../features/customers/domain/entities/customer_enums.dart';

/// Excel/CSV import/export servisi
class ExcelService {
  static const _uuid = Uuid();

  /// Müşterileri Excel dosyasına export et
  static Future<String?> exportCustomersToExcel(
    List<Customer> customers, {
    String? fileName,
  }) async {
    try {
      AppLogger.info('Exporting ${customers.length} customers to Excel');

      // Excel dosyası oluştur
      final excel = Excel.createExcel();
      final sheet = excel['Müşteriler'];

      // Başlık satırı
      final headers = [
        'Müşteri Adı',
        'Müşteri Kodu',
        'Telefon',
        'E-posta',
        'Adres',
        'Vergi Numarası',
        'Vergi Dairesi',
        'Şehir',
        'Ülke',
        'Posta Kodu',
        'Kategori 1',
        'Kategori 2',
        'Müşteri Tipi',
        'Durum',
        'Kredi Limiti',
        'Mevcut Bakiye',
        'Açılış Bakiyesi',
        'Para Birimi',
        'Vade (Gün)',
        'Sabit İskonto (%)',
        'Vergiden Muaf',
        'Banka Bilgileri',
        'Yetkili Kişi',
        'Yetkili Telefon',
        'Açıklama',
        'Kayıt Tarihi',
        'Güncelleme Tarihi',
      ];

      // Başlıkları ekle
      for (int i = 0; i < headers.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = headers[i];
      }

      // Müşteri verilerini ekle
      for (int i = 0; i < customers.length; i++) {
        final customer = customers[i];
        final rowIndex = i + 1;

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = customer.name;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = customer.customerCode ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = customer.phone ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = customer.email ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = customer.address ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = customer.taxNumber ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = customer.taxOffice ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = customer.city ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = customer.country ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = customer.postalCode ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = customer.category1 ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
            .value = customer.category2 ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex))
            .value = customer.customerType.name;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex))
            .value = customer.status.name;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: rowIndex))
            .value = customer.creditLimit;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: rowIndex))
            .value = customer.currentBalance;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: rowIndex))
            .value = customer.openingBalance ?? 0.0;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: rowIndex))
            .value = customer.customerCurrency ?? 'TRY';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: rowIndex))
            .value = customer.maturityDays ?? 0;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 19, rowIndex: rowIndex))
            .value = customer.fixedDiscountRate ?? 0.0;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 20, rowIndex: rowIndex))
            .value = customer.isTaxExempt;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 21, rowIndex: rowIndex))
            .value = customer.bankDetails ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 22, rowIndex: rowIndex))
            .value = customer.authorizedPersonName ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 23, rowIndex: rowIndex))
            .value = customer.authorizedPersonPhone ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 24, rowIndex: rowIndex))
            .value = customer.notes ?? '';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 25, rowIndex: rowIndex))
            .value = customer.createdAt.toIso8601String();
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 26, rowIndex: rowIndex))
            .value = customer.updatedAt.toIso8601String();
      }

      // Dosyayı kaydet
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Excel dosyası oluşturulamadı');
      }

      // Dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? 'musteriler_$timestamp.xlsx';

      if (kIsWeb) {
        // Web için dosyayı indir
        AppLogger.info('Excel file ready for download: $finalFileName');
        return finalFileName;
      } else {
        // Mobil/Desktop için dosyayı kaydet
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$finalFileName');
        await file.writeAsBytes(fileBytes);

        AppLogger.info('Excel file saved: ${file.path}');
        return file.path;
      }
    } catch (e) {
      AppLogger.error('Error exporting customers to Excel', e);
      rethrow;
    }
  }

  /// Excel dosyasından müşterileri import et
  static Future<List<Customer>> importCustomersFromExcel() async {
    try {
      AppLogger.info('Starting Excel import process');

      // Dosya seç
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('Dosya seçilmedi');
      }

      final file = result.files.first;
      if (file.bytes == null) {
        throw Exception('Dosya okunamadı');
      }

      // Excel dosyasını aç
      final excel = Excel.decodeBytes(file.bytes!);
      // ignore: dead_null_aware_expression
      final sheet = excel['Müşteriler'] ?? excel[excel.tables.keys.first];

      // ignore: unnecessary_null_comparison
      if (sheet == null) {
        throw Exception('Excel dosyasında "Müşteriler" sayfası bulunamadı');
      }

      final customers = <Customer>[];
      final now = DateTime.now();

      // Başlık satırını atla (0. satır)
      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        try {
          final row = sheet.rows[rowIndex];
          if (row.isEmpty) continue;

          // Gerekli alanları oku
          final name = _getCellValue(row, 0)?.toString().trim();
          if (name == null || name.isEmpty) continue;

          final customer = Customer(
            id: _uuid.v4(),
            name: name,
            customerCode: _getCellValue(row, 1)?.toString().trim(),
            phone: _getCellValue(row, 2)?.toString().trim(),
            email: _getCellValue(row, 3)?.toString().trim(),
            address: _getCellValue(row, 4)?.toString().trim(),
            taxNumber: _getCellValue(row, 5)?.toString().trim(),
            taxOffice: _getCellValue(row, 6)?.toString().trim(),
            city: _getCellValue(row, 7)?.toString().trim(),
            country: _getCellValue(row, 8)?.toString().trim(),
            postalCode: _getCellValue(row, 9)?.toString().trim(),
            category1: _getCellValue(row, 10)?.toString().trim(),
            category2: _getCellValue(row, 11)?.toString().trim(),
            customerType:
                _parseCustomerType(_getCellValue(row, 12)?.toString()),
            status: _parseCustomerStatus(_getCellValue(row, 13)?.toString()),
            creditLimit: _parseDouble(_getCellValue(row, 14)) ?? 0.0,
            currentBalance: _parseDouble(_getCellValue(row, 15)) ?? 0.0,
            openingBalance: _parseDouble(_getCellValue(row, 16)),
            customerCurrency:
                _getCellValue(row, 17)?.toString().trim() ?? 'TRY',
            maturityDays: _parseInt(_getCellValue(row, 18)),
            fixedDiscountRate: _parseDouble(_getCellValue(row, 19)),
            isTaxExempt: _parseBool(_getCellValue(row, 20)) ?? false,
            bankDetails: _getCellValue(row, 21)?.toString().trim(),
            authorizedPersonName: _getCellValue(row, 22)?.toString().trim(),
            authorizedPersonPhone: _getCellValue(row, 23)?.toString().trim(),
            notes: _getCellValue(row, 24)?.toString().trim(),
            companyId: 'default', // Gerçek company ID'yi al
            createdAt: now,
            updatedAt: now,
            createdBy: 'system', // Gerçek user ID'yi al
          );

          customers.add(customer);
        } catch (e) {
          AppLogger.warning('Error parsing row $rowIndex: $e');
          continue;
        }
      }

      AppLogger.info(
          'Successfully imported ${customers.length} customers from Excel');
      return customers;
    } catch (e) {
      AppLogger.error('Error importing customers from Excel', e);
      rethrow;
    }
  }

  /// CSV dosyasından müşterileri import et
  static Future<List<Customer>> importCustomersFromCSV() async {
    try {
      AppLogger.info('Starting CSV import process');

      // Dosya seç
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('Dosya seçilmedi');
      }

      final file = result.files.first;
      if (file.bytes == null) {
        throw Exception('Dosya okunamadı');
      }

      // CSV içeriğini oku
      final content = String.fromCharCodes(file.bytes!);
      final lines = content.split('\n');

      if (lines.isEmpty) {
        throw Exception('CSV dosyası boş');
      }

      final customers = <Customer>[];
      final now = DateTime.now();

      // Başlık satırını atla (0. satır)
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          final fields = _parseCSVLine(line);
          if (fields.isEmpty) continue;

          final name = fields[0].trim();
          if (name.isEmpty) continue;

          final customer = Customer(
            id: _uuid.v4(),
            name: name,
            customerCode: fields.length > 1 ? fields[1].trim() : null,
            phone: fields.length > 2 ? fields[2].trim() : null,
            email: fields.length > 3 ? fields[3].trim() : null,
            address: fields.length > 4 ? fields[4].trim() : null,
            taxNumber: fields.length > 5 ? fields[5].trim() : null,
            taxOffice: fields.length > 6 ? fields[6].trim() : null,
            city: fields.length > 7 ? fields[7].trim() : null,
            country: fields.length > 8 ? fields[8].trim() : null,
            postalCode: fields.length > 9 ? fields[9].trim() : null,
            category1: fields.length > 10 ? fields[10].trim() : null,
            category2: fields.length > 11 ? fields[11].trim() : null,
            customerType: _parseCustomerType(
                fields.length > 12 ? fields[12].trim() : null),
            status: _parseCustomerStatus(
                fields.length > 13 ? fields[13].trim() : null),
            creditLimit:
                _parseDouble(fields.length > 14 ? fields[14].trim() : null) ??
                    0.0,
            currentBalance:
                _parseDouble(fields.length > 15 ? fields[15].trim() : null) ??
                    0.0,
            openingBalance:
                _parseDouble(fields.length > 16 ? fields[16].trim() : null),
            customerCurrency: fields.length > 17 ? fields[17].trim() : 'TRY',
            maturityDays:
                _parseInt(fields.length > 18 ? fields[18].trim() : null),
            fixedDiscountRate:
                _parseDouble(fields.length > 19 ? fields[19].trim() : null),
            isTaxExempt:
                _parseBool(fields.length > 20 ? fields[20].trim() : null) ??
                    false,
            bankDetails: fields.length > 21 ? fields[21].trim() : null,
            authorizedPersonName: fields.length > 22 ? fields[22].trim() : null,
            authorizedPersonPhone:
                fields.length > 23 ? fields[23].trim() : null,
            notes: fields.length > 24 ? fields[24].trim() : null,
            companyId: 'default', // Gerçek company ID'yi al
            createdAt: now,
            updatedAt: now,
            createdBy: 'system', // Gerçek user ID'yi al
          );

          customers.add(customer);
        } catch (e) {
          AppLogger.warning('Error parsing CSV line $i: $e');
          continue;
        }
      }

      AppLogger.info(
          'Successfully imported ${customers.length} customers from CSV');
      return customers;
    } catch (e) {
      AppLogger.error('Error importing customers from CSV', e);
      rethrow;
    }
  }

  /// Müşterileri PDF dosyasına export et
  static Future<String?> exportCustomersToPDF(
    List<Customer> customers, {
    String? fileName,
  }) async {
    try {
      AppLogger.info('Exporting ${customers.length} customers to PDF');

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // Başlık
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Müşteri Listesi',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Tarih ve toplam sayı
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Tarih: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Toplam: ${customers.length} müşteri',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Müşteri tablosu
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Başlık satırı
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Müşteri Adı',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Kod',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Telefon',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Bakiye',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Durum',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Müşteri verileri
                  ...customers
                      .map((customer) => pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  customer.name,
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  customer.customerCode ?? '-',
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  customer.phone ?? '-',
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '${customer.currentBalance.toStringAsFixed(2)} ${customer.customerCurrency ?? 'TRY'}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: customer.currentBalance >= 0
                                        ? PdfColors.green
                                        : PdfColors.red,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  customer.status.name,
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ))
                      // ignore: unnecessary_to_list_in_spreads
                      .toList(),
                ],
              ),
            ];
          },
        ),
      );

      // Dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? 'musteriler_$timestamp.pdf';

      if (kIsWeb) {
        // Web için dosyayı indir
        AppLogger.info('PDF file ready for download: $finalFileName');
        return finalFileName;
      } else {
        // Mobil/Desktop için dosyayı kaydet
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$finalFileName');
        await file.writeAsBytes(await pdf.save());

        AppLogger.info('PDF file saved: ${file.path}');
        return file.path;
      }
    } catch (e) {
      AppLogger.error('Error exporting customers to PDF', e);
      rethrow;
    }
  }

  /// Müşterileri CSV dosyasına export et
  static Future<String?> exportCustomersToCSV(
    List<Customer> customers, {
    String? fileName,
  }) async {
    try {
      AppLogger.info('Exporting ${customers.length} customers to CSV');

      final csvContent = StringBuffer();

      // Başlık satırı
      csvContent.writeln(
          'Müşteri Adı,Müşteri Kodu,Telefon,E-posta,Adres,Vergi Numarası,'
          'Vergi Dairesi,Şehir,Ülke,Posta Kodu,Kategori 1,Kategori 2,'
          'Müşteri Tipi,Durum,Kredi Limiti,Mevcut Bakiye,Açılış Bakiyesi,'
          'Para Birimi,Vade (Gün),Sabit İskonto (%),Vergiden Muaf,'
          'Banka Bilgileri,Yetkili Kişi,Yetkili Telefon,Açıklama,'
          'Kayıt Tarihi,Güncelleme Tarihi');

      // Müşteri verilerini ekle
      for (final customer in customers) {
        csvContent.writeln('${_escapeCSV(customer.name)},'
            '${_escapeCSV(customer.customerCode ?? '')},'
            '${_escapeCSV(customer.phone ?? '')},'
            '${_escapeCSV(customer.email ?? '')},'
            '${_escapeCSV(customer.address ?? '')},'
            '${_escapeCSV(customer.taxNumber ?? '')},'
            '${_escapeCSV(customer.taxOffice ?? '')},'
            '${_escapeCSV(customer.city ?? '')},'
            '${_escapeCSV(customer.country ?? '')},'
            '${_escapeCSV(customer.postalCode ?? '')},'
            '${_escapeCSV(customer.category1 ?? '')},'
            '${_escapeCSV(customer.category2 ?? '')},'
            '${_escapeCSV(customer.customerType.name)},'
            '${_escapeCSV(customer.status.name)},'
            '${customer.creditLimit},'
            '${customer.currentBalance},'
            '${customer.openingBalance ?? 0.0},'
            '${_escapeCSV(customer.customerCurrency ?? 'TRY')},'
            '${customer.maturityDays ?? 0},'
            '${customer.fixedDiscountRate ?? 0.0},'
            '${customer.isTaxExempt},'
            '${_escapeCSV(customer.bankDetails ?? '')},'
            '${_escapeCSV(customer.authorizedPersonName ?? '')},'
            '${_escapeCSV(customer.authorizedPersonPhone ?? '')},'
            '${_escapeCSV(customer.notes ?? '')},'
            '${customer.createdAt.toIso8601String()},'
            '${customer.updatedAt.toIso8601String()}');
      }

      // Dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? 'musteriler_$timestamp.csv';

      if (kIsWeb) {
        // Web için dosyayı indir
        AppLogger.info('CSV file ready for download: $finalFileName');
        return finalFileName;
      } else {
        // Mobil/Desktop için dosyayı kaydet
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$finalFileName');
        await file.writeAsString(csvContent.toString());

        AppLogger.info('CSV file saved: ${file.path}');
        return file.path;
      }
    } catch (e) {
      AppLogger.error('Error exporting customers to CSV', e);
      rethrow;
    }
  }

  // Helper methods
  static dynamic _getCellValue(List<dynamic> row, int columnIndex) {
    if (columnIndex >= row.length) return null;
    final cell = row[columnIndex];
    return cell?.value;
  }

  static CustomerType _parseCustomerType(String? value) {
    if (value == null) return CustomerType.individual;
    switch (value.toLowerCase()) {
      case 'corporate':
      case 'company':
      case 'kurumsal':
        return CustomerType.company;
      case 'individual':
      case 'bireysel':
      default:
        return CustomerType.individual;
    }
  }

  static CustomerStatus _parseCustomerStatus(String? value) {
    if (value == null) return CustomerStatus.active;
    switch (value.toLowerCase()) {
      case 'inactive':
      case 'pasif':
        return CustomerStatus.inactive;
      case 'suspended':
      case 'askıda':
        return CustomerStatus.suspended;
      case 'active':
      case 'aktif':
      default:
        return CustomerStatus.active;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.trim().replaceAll(',', '.');
      return double.tryParse(cleaned);
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final cleaned = value.trim();
      return int.tryParse(cleaned);
    }
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final cleaned = value.trim().toLowerCase();
      return cleaned == 'true' || cleaned == '1' || cleaned == 'evet';
    }
    return null;
  }

  static List<String> _parseCSVLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    fields.add(buffer.toString());
    return fields;
  }

  static String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
