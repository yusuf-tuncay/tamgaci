// ========== EXPENSE FILTER SHEET WIDGET ==========
// lib/features/expenses/presentation/widgets/expense_filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../providers/expense_providers.dart';

/// Gider filtre sayfası widget'ı
class ExpenseFilterSheet extends ConsumerStatefulWidget {
  const ExpenseFilterSheet({super.key});

  @override
  ConsumerState<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends ConsumerState<ExpenseFilterSheet> {
  ExpenseCategory? _selectedCategory;
  ExpenseStatus? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Mevcut filtreleri yükle
    _selectedCategory = ref.read(selectedExpenseCategoryProvider);
    _selectedStatus = ref.read(selectedExpenseStatusProvider);
    _selectedDateRange = ref.read(expenseDateRangeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: TamgaciConstants.primaryColor,
                  size: 24,
                ),

                const SizedBox(width: 12),

                Text(
                  'Filtreler',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TamgaciConstants.textPrimary,
                  ),
                ),

                const Spacer(),

                // Temizle butonu
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Temizle',
                    style: GoogleFonts.poppins(
                      color: TamgaciConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filtre içeriği
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori filtresi
                  _buildSectionTitle('Kategori'),

                  const SizedBox(height: 12),

                  categoriesAsync.when(
                    data: (categories) => _buildCategoryFilter(categories),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Text('Kategoriler yüklenemedi: $error'),
                  ),

                  const SizedBox(height: 24),

                  // Durum filtresi
                  _buildSectionTitle('Durum'),

                  const SizedBox(height: 12),

                  _buildStatusFilter(),

                  const SizedBox(height: 24),

                  // Tarih aralığı filtresi
                  _buildSectionTitle('Tarih Aralığı'),

                  const SizedBox(height: 12),

                  _buildDateRangeFilter(),

                  const SizedBox(height: 32),

                  // Uygula butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TamgaciConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TamgaciConstants.radiusMD,
                          ),
                        ),
                      ),
                      child: Text(
                        'Filtreleri Uygula',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bölüm başlığı widget'ı
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimary,
      ),
    );
  }

  /// Kategori filtresi widget'ı
  Widget _buildCategoryFilter(List<ExpenseCategory> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Tümü seçeneği
        FilterChip(
          label: const Text('Tümü'),
          selected: _selectedCategory == null,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = null;
            });
          },
        ),

        // Kategoriler
        ...categories.map(
          (category) => FilterChip(
            label: Text(category.name),
            selected: _selectedCategory?.id == category.id,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? category : null;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Durum filtresi widget'ı
  Widget _buildStatusFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Tümü seçeneği
        FilterChip(
          label: const Text('Tümü'),
          selected: _selectedStatus == null,
          onSelected: (selected) {
            setState(() {
              _selectedStatus = null;
            });
          },
        ),

        // Durumlar
        ...ExpenseStatus.values.map(
          (status) => FilterChip(
            label: Text(status.name),
            selected: _selectedStatus == status,
            onSelected: (selected) {
              setState(() {
                _selectedStatus = selected ? status : null;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Tarih aralığı filtresi widget'ı
  Widget _buildDateRangeFilter() {
    return Column(
      children: [
        // Hızlı seçenekler
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Tümü'),
              selected: _selectedDateRange == null,
              onSelected: (selected) {
                setState(() {
                  _selectedDateRange = null;
                });
              },
            ),
            FilterChip(
              label: const Text('Bu Ay'),
              selected: _isCurrentMonthSelected(),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    final now = DateTime.now();
                    _selectedDateRange = DateTimeRange(
                      start: DateTime(now.year, now.month, 1),
                      end: DateTime(now.year, now.month + 1, 0),
                    );
                  } else {
                    _selectedDateRange = null;
                  }
                });
              },
            ),
            FilterChip(
              label: const Text('Geçen Ay'),
              selected: _isLastMonthSelected(),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    final now = DateTime.now();
                    _selectedDateRange = DateTimeRange(
                      start: DateTime(now.year, now.month - 1, 1),
                      end: DateTime(now.year, now.month, 0),
                    );
                  } else {
                    _selectedDateRange = null;
                  }
                });
              },
            ),
            FilterChip(
              label: const Text('Bu Yıl'),
              selected: _isCurrentYearSelected(),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    final now = DateTime.now();
                    _selectedDateRange = DateTimeRange(
                      start: DateTime(now.year, 1, 1),
                      end: DateTime(now.year, 12, 31),
                    );
                  } else {
                    _selectedDateRange = null;
                  }
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Özel tarih seçici
        OutlinedButton.icon(
          onPressed: _selectCustomDateRange,
          icon: const Icon(Icons.calendar_today),
          label: Text(
            _selectedDateRange == null
                ? 'Özel Tarih Aralığı Seç'
                : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  /// Özel tarih aralığı seç
  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  /// Filtreleri uygula
  void _applyFilters() {
    ref.read(selectedExpenseCategoryProvider.notifier).state =
        _selectedCategory;
    ref.read(selectedExpenseStatusProvider.notifier).state = _selectedStatus;
    ref.read(expenseDateRangeProvider.notifier).state = _selectedDateRange;

    Navigator.of(context).pop();
  }

  /// Tüm filtreleri temizle
  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedStatus = null;
      _selectedDateRange = null;
    });
  }

  /// Bu ay seçili mi kontrol et
  bool _isCurrentMonthSelected() {
    if (_selectedDateRange == null) return false;
    final now = DateTime.now();
    return _selectedDateRange!.start.year == now.year &&
        _selectedDateRange!.start.month == now.month &&
        _selectedDateRange!.start.day == 1 &&
        _selectedDateRange!.end.day == DateTime(now.year, now.month + 1, 0).day;
  }

  /// Geçen ay seçili mi kontrol et
  bool _isLastMonthSelected() {
    if (_selectedDateRange == null) return false;
    final now = DateTime.now();
    return _selectedDateRange!.start.year == now.year &&
        _selectedDateRange!.start.month == now.month - 1 &&
        _selectedDateRange!.start.day == 1 &&
        _selectedDateRange!.end.day == DateTime(now.year, now.month, 0).day;
  }

  /// Bu yıl seçili mi kontrol et
  bool _isCurrentYearSelected() {
    if (_selectedDateRange == null) return false;
    final now = DateTime.now();
    return _selectedDateRange!.start.year == now.year &&
        _selectedDateRange!.start.month == 1 &&
        _selectedDateRange!.start.day == 1 &&
        _selectedDateRange!.end.year == now.year &&
        _selectedDateRange!.end.month == 12 &&
        _selectedDateRange!.end.day == 31;
  }

  /// Tarihi formatla
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
