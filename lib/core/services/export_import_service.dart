import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class ExportImportService {
  static final ExportImportService _instance = ExportImportService._internal();
  factory ExportImportService() => _instance;
  ExportImportService._internal();

  /// Veriyi JSON formatında export eder
  Future<String?> exportToJson(Map<String, dynamic> data, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, '$fileName.json');
      
      final jsonString = jsonEncode(data);
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      return filePath;
    } catch (e) {
      debugPrint('JSON export failed: $e');
      return null;
    }
  }

  /// Veriyi Excel formatında export eder
  Future<String?> exportToExcel(Map<String, List<Map<String, dynamic>>> data, String fileName) async {
    try {
      final excel = Excel.createExcel();
      
      data.forEach((sheetName, rows) {
        final sheet = excel[sheetName];
        
        if (rows.isNotEmpty) {
          // Header'ları ekle
          final headers = rows.first.keys.toList();
          for (int i = 0; i < headers.length; i++) {
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
              ..value = headers[i]
              ..cellStyle = CellStyle(
                bold: true,
                horizontalAlign: HorizontalAlign.Center,
                backgroundColorHex: '#E0E0E0',
              );
          }
          
          // Verileri ekle
          for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
            final row = rows[rowIndex];
            for (int colIndex = 0; colIndex < headers.length; colIndex++) {
              final value = row[headers[colIndex]];
              sheet.cell(CellIndex.indexByColumnRow(
                columnIndex: colIndex, 
                rowIndex: rowIndex + 1
              )).value = value?.toString() ?? '';
            }
          }
        }
      });
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, '$fileName.xlsx');
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      
      return filePath;
    } catch (e) {
      debugPrint('Excel export failed: $e');
      return null;
    }
  }

  /// Veriyi PDF formatında export eder
  Future<String?> exportToPdf(Map<String, List<Map<String, dynamic>>> data, String fileName) async {
    try {
      final pdf = pw.Document();
      
      data.forEach((sectionName, items) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  sectionName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              if (items.isNotEmpty) ...[
                pw.Table.fromTextArray(
                  headers: items.first.keys.map((key) => pw.Text(key)).toList(),
                  data: items.map((item) => 
                    item.values.map((value) => pw.Text(value?.toString() ?? '')).toList()
                  ).toList(),
                ),
              ] else ...[
                pw.Text('Bu bölümde veri bulunmamaktadır.'),
              ],
            ],
          ),
        );
      });
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, '$fileName.pdf');
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      return filePath;
    } catch (e) {
      debugPrint('PDF export failed: $e');
      return null;
    }
  }

  /// JSON dosyasından veri import eder
  Future<Map<String, dynamic>?> importFromJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      debugPrint('JSON import failed: $e');
      return null;
    }
  }

  /// Excel dosyasından veri import eder
  Future<Map<String, List<Map<String, dynamic>>>?> importFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        
        final Map<String, List<Map<String, dynamic>>> data = {};
        
        for (final sheetName in excel.tables.keys) {
          final sheet = excel.tables[sheetName]!;
          final List<Map<String, dynamic>> rows = [];
          
          if (sheet.maxRows > 0) {
            final headers = <String>[];
            
            // Header'ları al
            for (int col = 0; col < sheet.maxCols; col++) {
              final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
              if (cell.value != null) {
                headers.add(cell.value.toString());
              }
            }
            
            // Verileri al
            for (int row = 1; row < sheet.maxRows; row++) {
              final Map<String, dynamic> rowData = {};
              bool hasData = false;
              
              for (int col = 0; col < headers.length; col++) {
                final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
                final value = cell.value;
                if (value != null) {
                  rowData[headers[col]] = value;
                  hasData = true;
                }
              }
              
              if (hasData) {
                rows.add(rowData);
              }
            }
          }
          
          data[sheetName] = rows;
        }
        
        return data;
      }
      
      return null;
    } catch (e) {
      debugPrint('Excel import failed: $e');
      return null;
    }
  }

  /// Dosya paylaşımı için dosya yolunu döndürür
  Future<String?> getShareableFilePath(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('File path error: $e');
      return null;
    }
  }

  /// Dosya boyutunu formatlar
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Dosya türüne göre icon döndürür
  IconData getFileIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.json':
        return Icons.code;
      case '.xlsx':
      case '.xls':
        return Icons.table_chart;
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.csv':
        return Icons.table_view;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Dosya türüne göre renk döndürür
  Color getFileColor(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.json':
        return Colors.orange;
      case '.xlsx':
      case '.xls':
        return Colors.green;
      case '.pdf':
        return Colors.red;
      case '.csv':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Tarih formatını döndürür
  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  /// Dosya bilgilerini döndürür
  Future<Map<String, dynamic>?> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return {
          'name': path.basename(filePath),
          'size': formatFileSize(stat.size),
          'modified': formatDate(stat.modified),
          'path': filePath,
        };
      }
      return null;
    } catch (e) {
      debugPrint('File info error: $e');
      return null;
    }
  }
}
