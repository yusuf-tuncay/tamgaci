// ========== EXPORT IMPORT SERVICE ==========
// lib/core/services/utils/export_import_service.dart

import 'dart:typed_data';
import 'package:tamgaci/core/services/utils/export_service.dart';

/// Export ve Import işlemlerini yöneten servis
class ExportImportService {
  final ExportService _exportService;

  ExportImportService({ExportService? exportService})
      : _exportService = exportService ?? ExportService();

  /// Müşterileri Excel'e export et
  Future<Uint8List> exportCustomersToExcel(
      List<Map<String, dynamic>> customers) async {
    return await _exportService.exportCustomersToExcel(customers);
  }

  /// Ürünleri Excel'e export et
  Future<Uint8List> exportProductsToExcel(
      List<Map<String, dynamic>> products) async {
    return await _exportService.exportProductsToExcel(products);
  }

  /// Satışları Excel'e export et
  Future<Uint8List> exportSalesToExcel(List<Map<String, dynamic>> sales) async {
    return await _exportService.exportSalesToExcel(sales);
  }

  /// Stok raporunu PDF'e export et
  Future<Uint8List> exportStockReportToPDF({
    required List<Map<String, dynamic>> products,
    required Map<String, dynamic> summary,
  }) async {
    return await _exportService.exportStockReportToPDF(
      products: products,
      summary: summary,
    );
  }

  /// CSV formatında export et
  Future<Uint8List> exportToCSV({
    required List<Map<String, dynamic>> data,
    required List<String> headers,
  }) async {
    return await _exportService.exportToCSVBinary(
      data: data,
      headers: headers,
    );
  }

  /// JSON formatında export et
  Future<Uint8List> exportToJson(Map<String, dynamic> data) async {
    return await _exportService.exportToJson(data);
  }

  /// Excel formatında export et
  Future<Uint8List> exportToExcel({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
  }) async {
    return await _exportService.exportToExcel(
      title: title,
      headers: headers,
      data: data,
    );
  }

  /// PDF formatında export et
  Future<Uint8List> exportToPdf({
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<List<dynamic>> data,
    required Map<String, dynamic> summary,
  }) async {
    return await _exportService.exportToPDF(
      title: title,
      subtitle: subtitle,
      headers: headers,
      data: data,
      summary: summary,
    );
  }

  /// JSON formatından import et
  Future<Map<String, dynamic>> importFromJson(Uint8List data) async {
    return await _exportService.importFromJson(data);
  }

  /// Excel formatından import et
  Future<List<Map<String, dynamic>>> importFromExcel(Uint8List data) async {
    return await _exportService.importFromExcel(data);
  }

  /// Import işlemi (gelecekte implement edilecek)
  Future<List<Map<String, dynamic>>> importFromCSV(Uint8List fileData) async {
    // CSV import implementasyonu
    throw UnimplementedError('CSV import not implemented yet');
  }
}
