// ========== EXPORT DIALOG WIDGET ==========
// lib/shared/widgets/export_dialog.dart

// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';
import 'package:tamgaci/core/services/utils/export_service.dart';

/// Dışa aktarım dialog widget'ı
class ExportDialog extends StatefulWidget {
  final String title;
  final List<String> headers;
  final List<List<dynamic>> data;
  final Map<String, dynamic>? summary;
  final String? subtitle;

  const ExportDialog({
    super.key,
    required this.title,
    required this.headers,
    required this.data,
    this.summary,
    this.subtitle,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final ExportService _exportService = ExportService();
  String _selectedFormat = 'excel';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? Colors.grey[850] : null,
      title: Text(
        'Dışa Aktar',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verilerinizi hangi formatta dışa aktarmak istiyorsunuz?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Format seçimi
          ...['excel', 'pdf', 'csv'].map((format) => RadioListTile<String>(
                title: Text(
                  format.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  _getFormatDescription(format),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                value: format,
                groupValue: _selectedFormat,
                onChanged: (String? value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
                activeColor: AppColors.primary,
              )),

          const SizedBox(height: 16),

          // Özet bilgileri
          if (widget.summary != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Özet Bilgiler',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Theme.of(context).colorScheme.primary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.summary!.entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Veri bilgileri
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? TamgaciConstants.cardColorDark : Colors.grey[50],
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dışa Aktarılacak Veriler',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sütun Sayısı:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${widget.headers.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Satır Sayısı:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${widget.data.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text(
            'İptal',
            style: GoogleFonts.poppins(),
          ),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _exportData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Dışa Aktar',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  String _getFormatDescription(String format) {
    switch (format) {
      case 'excel':
        return 'Excel dosyası (.xlsx) - Düzenlenebilir tablo formatı';
      case 'pdf':
        return 'PDF dosyası (.pdf) - Yazdırılabilir rapor formatı';
      case 'csv':
        return 'CSV dosyası (.csv) - Virgülle ayrılmış değerler';
      default:
        return 'Format açıklaması';
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      Uint8List? fileBytes;
      String? fileName;

      switch (_selectedFormat) {
        case 'excel':
          fileBytes = await _exportService.exportToExcel(
            title: widget.title,
            headers: widget.headers,
            data: widget.data,
          );
          fileName = '${_sanitizeFileName(widget.title)}.xlsx';
          break;

        case 'pdf':
          fileBytes = await _exportService.exportToPDF(
            title: widget.title,
            subtitle: widget.subtitle,
            headers: widget.headers,
            data: widget.data,
            summary: widget.summary,
          );
          fileName = '${_sanitizeFileName(widget.title)}.pdf';
          break;

        case 'csv':
          final csvContent = await _exportService.exportToCSV(
            headers: widget.headers,
            data: widget.data,
          );
          fileBytes = Uint8List.fromList(csvContent.codeUnits);
          fileName = '${_sanitizeFileName(widget.title)}.csv';
          break;
      }

      // Dosyayı kaydet
      if (fileBytes != null && fileName != null) {
        await _saveFile(fileBytes, fileName);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName başarıyla kaydedildi'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dışa aktarım sırasında hata: $e'),
            backgroundColor: AppColors.error,
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

  Future<void> _saveFile(Uint8List bytes, String fileName) async {
    try {
      // Mobil platformlarda dosya kaydetme
      final result = await FilePicker.platform.saveFile(
        fileName: fileName,
        bytes: bytes,
      );

      if (result == null) {
        throw Exception('Dosya kaydedilemedi');
      }
    } catch (e) {
      throw Exception('Dosya kaydetme hatası: $e');
    }
  }

  String _sanitizeFileName(String fileName) {
    // Dosya adındaki geçersiz karakterleri temizle
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }
}

/// Dışa aktarım dialog'unu göster
Future<void> showExportDialog({
  required BuildContext context,
  required String title,
  required List<String> headers,
  required List<List<dynamic>> data,
  Map<String, dynamic>? summary,
  String? subtitle,
}) {
  return showDialog(
    context: context,
    builder: (context) => ExportDialog(
      title: title,
      headers: headers,
      data: data,
      summary: summary,
      subtitle: subtitle,
    ),
  );
}
