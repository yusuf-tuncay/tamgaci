import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../providers/inventory_providers.dart';
import '../../domain/entities/stock_movement.dart';
import '../widgets/stock_movement_tile.dart';

class StockMovementsListPage extends ConsumerStatefulWidget {
  const StockMovementsListPage({super.key});

  @override
  ConsumerState<StockMovementsListPage> createState() =>
      _StockMovementsListPageState();
}

class _StockMovementsListPageState
    extends ConsumerState<StockMovementsListPage> {
  @override
  Widget build(BuildContext context) {
    final stockMovementsAsync = ref.watch(stockMovementsProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Stok Hareketleri',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: TamgaciConstants.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterModal();
            },
          ),
        ],
      ),
      body: stockMovementsAsync.when(
        data: (stockMovements) {
          if (stockMovements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz stok hareketi yok',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk stok hareketini oluşturmak için + butonuna tıklayın',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(stockMovementsProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stockMovements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movement = stockMovements[index];
                return StockMovementTile(
                  movement: movement,
                  onTap: () {
                    TamgaciRoutes.pushNamed(
                      context,
                      TamgaciRoutes.stockMovementDetail,
                      arguments: movement,
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Hata oluştu',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(stockMovementsProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TamgaciConstants.primaryColor,
                ),
                child: Text(
                  'Tekrar Dene',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          TamgaciRoutes.pushNamed(context, TamgaciRoutes.createStockMovement);
        },
        backgroundColor: TamgaciConstants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Stok Hareketi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) => _buildFilterSheet(modalContext),
    );
  }

  Widget _buildFilterSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtreleme',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hareket türü filtresi
          Text(
            'Hareket Türü',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: StockMovementType.values.map((type) {
              return FilterChip(
                label: Text(type.displayName),
                selected: false, // TODO: Implement filter state
                onSelected: (selected) {
                  // TODO: Implement filter logic
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Tarih aralığı filtresi
          Text(
            'Tarih Aralığı',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: 'Başlangıç tarihi'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    // TODO: Implement date filter logic
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: 'Bitiş tarihi'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    // TODO: Implement date filter logic
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Filtreleme butonları
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Clear filters
                    Navigator.pop(context);
                  },
                  child: const Text('Temizle'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Apply filters
                    Navigator.pop(context);
                  },
                  child: const Text('Uygula'),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
