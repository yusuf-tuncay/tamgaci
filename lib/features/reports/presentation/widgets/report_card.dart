import 'package:flutter/material.dart';
import 'package:tamgaci/features/reports/domain/entities/report.dart';

/// Rapor kartı widget'ı
class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        if (report.description != null)
                          Text(
                            report.description!,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        report.type.displayName,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        report.format.displayName,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  _buildTypeChip(report.type),
                  const SizedBox(width: 8.0),
                  _buildStatusChip(report.status),
                  const SizedBox(width: 8.0),
                  _buildFormatChip(report.format),
                ],
              ),
              if (report.generatedAt != null) ...[
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16.0, color: Colors.grey.shade600),
                    const SizedBox(width: 4.0),
                    Text(
                      'Oluşturulma: ${_formatDate(report.generatedAt!)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              if (report.fileSize != null) ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.file_download,
                        size: 16.0, color: Colors.grey.shade600),
                    const SizedBox(width: 4.0),
                    Text(
                      'Dosya Boyutu: ${_formatFileSize(report.fileSize!)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Oluşturulma: ${_formatDate(report.createdAt)}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20.0),
                          onPressed: onEdit,
                          tooltip: 'Düzenle',
                        ),
                      if (onDuplicate != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20.0),
                          onPressed: onDuplicate,
                          tooltip: 'Kopyala',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete,
                              size: 20.0, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Sil',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(ReportType type) {
    return Chip(
      label: Text(
        type.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getTypeColor(type),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getStatusColor(status),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildFormatChip(ReportFormat format) {
    return Chip(
      label: Text(
        format.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getFormatColor(format),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getTypeColor(ReportType type) {
    switch (type) {
      case ReportType.sales:
        return Colors.green.shade300;
      case ReportType.purchases:
        return Colors.blue.shade300;
      case ReportType.cashFlow:
        return Colors.orange.shade300;
      case ReportType.inventory:
        return Colors.purple.shade300;
      case ReportType.profitLoss:
        return Colors.red.shade300;
      case ReportType.balanceSheet:
        return Colors.teal.shade300;
      case ReportType.customer:
        return Colors.indigo.shade300;
      case ReportType.supplier:
        return Colors.brown.shade300;
      case ReportType.product:
        return Colors.pink.shade300;
      case ReportType.custom:
        return Colors.grey.shade300;
      case ReportType.payments:
        return Colors.cyan.shade300;
      case ReportType.paymentSummary:
        return Colors.deepPurple.shade300;
      case ReportType.paymentByType:
        return Colors.amber.shade300;
      case ReportType.paymentByCustomer:
        return Colors.lightBlue.shade300;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange.shade300;
      case ReportStatus.generating:
        return Colors.blue.shade300;
      case ReportStatus.completed:
        return Colors.green.shade300;
      case ReportStatus.failed:
        return Colors.red.shade300;
      case ReportStatus.expired:
        return Colors.grey.shade300;
    }
  }

  Color _getFormatColor(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return Colors.red.shade300;
      case ReportFormat.excel:
        return Colors.green.shade300;
      case ReportFormat.csv:
        return Colors.blue.shade300;
      case ReportFormat.json:
        return Colors.orange.shade300;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
