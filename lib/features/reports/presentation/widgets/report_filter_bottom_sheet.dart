import 'package:flutter/material.dart';
import 'package:tamgaci/features/reports/domain/entities/report.dart';

/// Rapor filtreleme bottom sheet widget'ı
class ReportFilterBottomSheet extends StatefulWidget {
  final ReportType? selectedType;
  final ReportStatus? selectedStatus;
  final ReportFormat? selectedFormat;
  final Function(ReportType?, ReportStatus?, ReportFormat?) onFilterChanged;
  final VoidCallback onClearFilters;

  const ReportFilterBottomSheet({
    super.key,
    this.selectedType,
    this.selectedStatus,
    this.selectedFormat,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  State<ReportFilterBottomSheet> createState() =>
      _ReportFilterBottomSheetState();
}

class _ReportFilterBottomSheetState extends State<ReportFilterBottomSheet> {
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;
  ReportFormat? _selectedFormat;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedStatus = widget.selectedStatus;
    _selectedFormat = widget.selectedFormat;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.0,
            height: 4.0,
            margin: const EdgeInsets.only(top: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrele',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedType = null;
                          _selectedStatus = null;
                          _selectedFormat = null;
                        });
                        widget.onClearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Temizle'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildTypeFilter(),
                const SizedBox(height: 16.0),
                _buildStatusFilter(),
                const SizedBox(height: 16.0),
                _buildFormatFilter(),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFilterChanged(
                          _selectedType, _selectedStatus, _selectedFormat);
                      Navigator.pop(context);
                    },
                    child: const Text('Filtrele'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rapor Türü',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: ReportType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? type : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rapor Durumu',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: ReportStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return FilterChip(
              label: Text(status.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? status : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFormatFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rapor Formatı',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: ReportFormat.values.map((format) {
            final isSelected = _selectedFormat == format;
            return FilterChip(
              label: Text(format.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFormat = selected ? format : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
