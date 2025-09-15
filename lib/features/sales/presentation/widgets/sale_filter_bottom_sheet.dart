import 'package:flutter/material.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';

/// Satış filtreleme bottom sheet widget'ı
class SaleFilterBottomSheet extends StatefulWidget {
  final SaleStatus? selectedStatus;
  final PaymentStatus? selectedPaymentStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(SaleStatus?, PaymentStatus?, DateTime?, DateTime?)
      onFilterChanged;
  final VoidCallback onClearFilters;

  const SaleFilterBottomSheet({
    super.key,
    this.selectedStatus,
    this.selectedPaymentStatus,
    this.startDate,
    this.endDate,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  State<SaleFilterBottomSheet> createState() => _SaleFilterBottomSheetState();
}

class _SaleFilterBottomSheetState extends State<SaleFilterBottomSheet> {
  SaleStatus? _selectedStatus;
  PaymentStatus? _selectedPaymentStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
    _selectedPaymentStatus = widget.selectedPaymentStatus;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
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
                          _selectedStatus = null;
                          _selectedPaymentStatus = null;
                          _startDate = null;
                          _endDate = null;
                        });
                        widget.onClearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Temizle'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildStatusFilter(),
                const SizedBox(height: 16.0),
                _buildPaymentStatusFilter(),
                const SizedBox(height: 16.0),
                _buildDateRangeFilter(),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFilterChanged(
                        _selectedStatus,
                        _selectedPaymentStatus,
                        _startDate,
                        _endDate,
                      );
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

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Satış Durumu',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: SaleStatus.values.map((status) {
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

  Widget _buildPaymentStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ödeme Durumu',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: PaymentStatus.values.map((status) {
            final isSelected = _selectedPaymentStatus == status;
            return FilterChip(
              label: Text(status.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPaymentStatus = selected ? status : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tarih Aralığı',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectStartDate(),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Başlangıç',
                        style: TextStyle(
                          color: _startDate != null
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20.0),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            const Text(' - '),
            const SizedBox(width: 8.0),
            Expanded(
              child: InkWell(
                onTap: () => _selectEndDate(),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Bitiş',
                        style: TextStyle(
                          color: _endDate != null
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }
}
