import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tamgaci/core/services/utils/export_import_service.dart';

class ExportImportWidget extends ConsumerStatefulWidget {
  final Map<String, List<Map<String, dynamic>>> data;
  final String title;
  final Function(Map<String, dynamic>)? onImportSuccess;

  const ExportImportWidget({
    super.key,
    required this.data,
    required this.title,
    this.onImportSuccess,
  });

  @override
  ConsumerState<ExportImportWidget> createState() => _ExportImportWidgetState();
}

class _ExportImportWidgetState extends ConsumerState<ExportImportWidget> {
  final ExportImportService _exportImportService = ExportImportService();
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veri Dışa/İçe Aktarma',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildExportSection(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImportSection(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dışa Aktar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildExportButton(
          'JSON',
          Icons.code,
          Colors.orange,
          () => _exportData('json'),
        ),
        const SizedBox(height: 8),
        _buildExportButton(
          'Excel',
          Icons.table_chart,
          Colors.green,
          () => _exportData('excel'),
        ),
        const SizedBox(height: 8),
        _buildExportButton(
          'PDF',
          Icons.picture_as_pdf,
          Colors.red,
          () => _exportData('pdf'),
        ),
      ],
    );
  }

  Widget _buildImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İçe Aktar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildImportButton(
          'JSON',
          Icons.code,
          Colors.orange,
          () => _importData('json'),
        ),
        const SizedBox(height: 8),
        _buildImportButton(
          'Excel',
          Icons.table_chart,
          Colors.green,
          () => _importData('excel'),
        ),
      ],
    );
  }

  Widget _buildExportButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : onPressed,
        icon: _isExporting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildImportButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isImporting ? null : onPressed,
        icon: _isImporting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: color),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _exportData(String format) async {
    setState(() {
      _isExporting = true;
    });

    try {
      String? filePath;
      final fileName =
          '${widget.title}_${DateTime.now().millisecondsSinceEpoch}';

      switch (format) {
        case 'json':
          final jsonData = _convertToJsonFormat();
          final fileBytes = await _exportImportService.exportToJson(jsonData);
          filePath = await _saveFile(fileBytes, fileName);
          break;
        case 'excel':
          final fileBytes = await _exportImportService.exportToExcel(
            title: widget.title,
            headers: _getHeaders(),
            data: _getData(),
          );
          filePath = await _saveFile(fileBytes, fileName);
          break;
        case 'pdf':
          final fileBytes = await _exportImportService.exportToPdf(
            title: widget.title,
            subtitle: 'Export Report',
            headers: _getHeaders(),
            data: _getData(),
            summary: _getSummary(),
          );
          filePath = await _saveFile(fileBytes, fileName);
          break;
      }

      if (filePath != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$format formatında dışa aktarıldı: $fileName'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Dosyayı Aç',
                textColor: Colors.white,
                onPressed: () => _openFile(filePath!),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$format dışa aktarma başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importData(String format) async {
    setState(() {
      _isImporting = true;
    });

    try {
      dynamic importedData;

      switch (format) {
        case 'json':
          final fileData = await _pickFile();
          if (fileData != null) {
            importedData = await _exportImportService.importFromJson(fileData);
          }
          break;
        case 'excel':
          final fileData = await _pickFile();
          if (fileData != null) {
            importedData = await _exportImportService.importFromExcel(fileData);
          }
          break;
      }

      if (importedData != null) {
        if (widget.onImportSuccess != null) {
          widget.onImportSuccess!(importedData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$format formatından başarıyla içe aktarıldı'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$format içe aktarma başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Map<String, dynamic> _convertToJsonFormat() {
    final Map<String, dynamic> jsonData = {};

    widget.data.forEach((key, value) {
      jsonData[key] = value;
    });

    return jsonData;
  }

  List<String> _getHeaders() {
    if (widget.data.isEmpty) return [];
    return widget.data.values.first
        .map<String>((item) => item.keys.first)
        .toList();
  }

  List<List<dynamic>> _getData() {
    if (widget.data.isEmpty) return [];
    final headers = _getHeaders();
    final allData = <List<dynamic>>[];

    for (final dataList in widget.data.values) {
      for (final item in dataList) {
        allData.add(headers.map((header) => item[header]).toList());
      }
    }

    return allData;
  }

  Map<String, dynamic> _getSummary() {
    return {
      'totalRecords': _getData().length,
      'exportedAt': DateTime.now().toIso8601String(),
      'format': 'Export Report',
    };
  }

  Future<Uint8List?> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'xlsx', 'xls'],
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.bytes;
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
    return null;
  }

  Future<String?> _saveFile(Uint8List bytes, String fileName) async {
    try {
      final result = await FilePicker.platform.saveFile(
        fileName: fileName,
        bytes: bytes,
      );
      return result;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  void _openFile(String filePath) {
    // TODO: Implement file opening functionality
    debugPrint('Opening file: $filePath');
  }
}

class ExportImportDialog extends ConsumerWidget {
  final Map<String, List<Map<String, dynamic>>> data;
  final String title;
  final Function(Map<String, dynamic>)? onImportSuccess;

  const ExportImportDialog({
    super.key,
    required this.data,
    required this.title,
    this.onImportSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('$title - Veri Dışa/İçe Aktarma'),
      content: SizedBox(
        width: double.maxFinite,
        child: ExportImportWidget(
          data: data,
          title: title,
          onImportSuccess: onImportSuccess,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
