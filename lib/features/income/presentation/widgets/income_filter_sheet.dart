// ========== INCOME FILTER SHEET ==========
// lib/features/income/presentation/widgets/income_filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../providers/income_providers.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/income_category.dart';

/// Gelir filtre sayfası
class IncomeFilterSheet extends ConsumerStatefulWidget {
  const IncomeFilterSheet({super.key});

  @override
  ConsumerState<IncomeFilterSheet> createState() => _IncomeFilterSheetState();
}

class _IncomeFilterSheetState extends ConsumerState<IncomeFilterSheet> {
  IncomeCategory? _selectedCategory;
  IncomeStatus? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedCategory = ref.read(selectedIncomeCategoryProvider);
    _selectedStatus = ref.read(selectedIncomeStatusProvider);
    _selectedDateRange = ref.read(incomeDateRangeProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık çubuğu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TamgaciConstants.borderColor),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: TamgaciConstants.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Gelir Filtreleri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TamgaciConstants.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Temizle',
                    style: GoogleFonts.poppins(
                      color: TamgaciConstants.errorColor,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori filtresi
                  _buildSectionTitle('Kategori'),
                  _buildCategoryFilter(),

                  const SizedBox(height: 24),

                  // Durum filtresi
                  _buildSectionTitle('Durum'),
                  _buildStatusFilter(),

                  const SizedBox(height: 24),

                  // Tarih aralığı filtresi
                  _buildSectionTitle('Tarih Aralığı'),
                  _buildDateRangeFilter(),

                  const SizedBox(height: 32),

                  // Uygula butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TamgaciConstants.primaryColor,
                        foregroundColor: Colors.white,
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

  /// Bölüm başlığı oluşturur
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

  /// Kategori filtresi oluşturur
  Widget _buildCategoryFilter() {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(incomeCategoriesProvider);

        return categoriesAsync.when(
          data: (categories) {
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
                // Kategori seçenekleri
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
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Kategoriler yüklenemedi: $error'),
        );
      },
    );
  }

  /// Durum filtresi oluşturur
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
        // Durum seçenekleri
        ...IncomeStatus.values.map(
          (status) => FilterChip(
            label: Text(status.displayName),
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

  /// Tarih aralığı filtresi oluşturur
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
              label: const Text('Bugün'),
              selected: _isTodaySelected(),
              onSelected: (selected) {
                setState(() {
                  _selectedDateRange = selected ? _getTodayRange() : null;
                });
              },
            ),
            FilterChip(
              label: const Text('Bu Hafta'),
              selected: _isThisWeekSelected(),
              onSelected: (selected) {
                setState(() {
                  _selectedDateRange = selected ? _getThisWeekRange() : null;
                });
              },
            ),
            FilterChip(
              label: const Text('Bu Ay'),
              selected: _isThisMonthSelected(),
              onSelected: (selected) {
                setState(() {
                  _selectedDateRange = selected ? _getThisMonthRange() : null;
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

  /// Bugün aralığını alır
  DateTimeRange _getTodayRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  /// Bu hafta aralığını alır
  DateTimeRange _getThisWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return DateTimeRange(
      start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }

  /// Bu ay aralığını alır
  DateTimeRange _getThisMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return DateTimeRange(
      start: startOfMonth,
      end: DateTime(
        endOfMonth.year,
        endOfMonth.month,
        endOfMonth.day,
        23,
        59,
        59,
      ),
    );
  }

  /// Bugün seçili mi kontrol eder
  bool _isTodaySelected() {
    if (_selectedDateRange == null) return false;
    final today = _getTodayRange();
    return _selectedDateRange!.start == today.start &&
        _selectedDateRange!.end == today.end;
  }

  /// Bu hafta seçili mi kontrol eder
  bool _isThisWeekSelected() {
    if (_selectedDateRange == null) return false;
    final thisWeek = _getThisWeekRange();
    return _selectedDateRange!.start == thisWeek.start &&
        _selectedDateRange!.end == thisWeek.end;
  }

  /// Bu ay seçili mi kontrol eder
  bool _isThisMonthSelected() {
    if (_selectedDateRange == null) return false;
    final thisMonth = _getThisMonthRange();
    return _selectedDateRange!.start == thisMonth.start &&
        _selectedDateRange!.end == thisMonth.end;
  }

  /// Özel tarih aralığı seçer
  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  /// Tarihi formatlar
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Tüm filtreleri temizler
  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedStatus = null;
      _selectedDateRange = null;
    });
  }

  /// Filtreleri uygular
  void _applyFilters() {
    ref.read(selectedIncomeCategoryProvider.notifier).state = _selectedCategory;
    ref.read(selectedIncomeStatusProvider.notifier).state = _selectedStatus;
    ref.read(incomeDateRangeProvider.notifier).state = _selectedDateRange;

    Navigator.of(context).pop();
  }
}
