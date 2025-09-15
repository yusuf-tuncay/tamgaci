// ========== ENHANCED PRODUCT DETAIL PAGE ==========
// lib/features/products/presentation/pages/enhanced_product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_transaction.dart';
import '../../data/services/product_firebase_service.dart';

/// Gelişmiş ürün detay sayfası - Satış/alış geçmişi ile
class EnhancedProductDetailPage extends ConsumerStatefulWidget {
  final String productId;

  const EnhancedProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<EnhancedProductDetailPage> createState() =>
      _EnhancedProductDetailPageState();
}

class _EnhancedProductDetailPageState
    extends ConsumerState<EnhancedProductDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Tümü';
  ProductTransactionType? _selectedTransactionType;
  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final productService = ProductFirebaseService();
      final product = await productService.getProduct(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Ürün Detayı'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Ürün Detayı'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProduct,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Ürün Detayı'),
        body: Center(
          child: Text('Ürün bulunamadı'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: _product!.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Ürün düzenleme sayfasına git
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProductInfoCard(),
          _buildStatsCards(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesTab(),
                _buildPurchasesTab(),
                _buildStockMovementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ürün resmi
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _product!.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _product!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image,
                                color: Colors.grey, size: 40);
                          },
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey, size: 40),
              ),
              const SizedBox(width: 16),
              // Ürün bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product!.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _product!.category ?? 'Kategori Yok',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyHelper.formatCurrency(
                          _product!.unitPrice, _product!.currency),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Stok durumu
              _buildStockStatus(),
            ],
          ),
          if (_product!.description?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Açıklama',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _product!.description!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockStatus() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (_product!.stockQuantity <= 0) {
      statusColor = Colors.red;
      statusText = 'Stok Yok';
      statusIcon = Icons.error;
    } else if (_product!.stockQuantity <= _product!.minStockLevel) {
      statusColor = Colors.orange;
      statusText = 'Düşük Stok';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.green;
      statusText = 'Stokta';
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          Text(
            '${_product!.stockQuantity} adet',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    // Mock data - gerçek veriler provider'dan gelecek
    const totalSales = 45;
    const totalSalesAmount = 67500.0;
    const totalPurchases = 12;
    const profitMargin = 33.3; // %

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Toplam Satış',
              totalSales.toString(),
              Icons.trending_up,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Satış Tutarı',
              CurrencyHelper.formatCurrency(totalSalesAmount, 'TRY'),
              Icons.attach_money,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Toplam Alış',
              totalPurchases.toString(),
              Icons.shopping_cart,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kar Marjı',
              '%$profitMargin',
              Icons.percent,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Satışlar'),
          Tab(text: 'Alışlar'),
          Tab(text: 'Stok Hareketleri'),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return _buildTransactionList(ProductTransactionType.sale);
  }

  Widget _buildPurchasesTab() {
    return _buildTransactionList(ProductTransactionType.purchase);
  }

  Widget _buildStockMovementsTab() {
    return _buildStockMovementsList();
  }

  Widget _buildTransactionList(ProductTransactionType type) {
    // Mock data - gerçek veriler provider'dan gelecek
    final transactions = _getMockTransactions(type);

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: transactions.isEmpty
              ? _buildEmptyState(type)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStockMovementsList() {
    // Mock data - gerçek stok hareketleri
    final stockMovements = _getMockStockMovements();

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: stockMovements.isEmpty
              ? _buildEmptyStockMovements()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stockMovements.length,
                  itemBuilder: (context, index) {
                    final movement = stockMovements[index];
                    return _buildStockMovementCard(movement);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 'Tümü', child: Text('Tüm Zamanlar')),
                    DropdownMenuItem(value: 'Bu Ay', child: Text('Bu Ay')),
                    DropdownMenuItem(
                        value: 'Son 3 Ay', child: Text('Son 3 Ay')),
                    DropdownMenuItem(value: 'Bu Yıl', child: Text('Bu Yıl')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(ProductTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // İşlem detay sayfasına git
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // İşlem türü ikonu
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTransactionColor(transaction.type)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        transaction.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // İşlem bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${transaction.type.displayName} - ${transaction.documentNumber}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tarih: ${_formatDate(transaction.transactionDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (transaction.customer != null)
                          Text(
                            'Müşteri: ${transaction.customer!.name}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (transaction.supplier != null)
                          Text(
                            'Tedarikçi: ${transaction.supplier!.name}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Tutar ve miktar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyHelper.formatCurrency(
                            transaction.totalAmount, transaction.currency),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.quantity.toInt()} adet',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        CurrencyHelper.formatCurrency(
                            transaction.unitPrice, transaction.currency),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (transaction.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  transaction.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockMovementCard(Map<String, dynamic> movement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Hareket türü ikonu
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: movement['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  movement['icon'],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Hareket bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movement['type'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tarih: ${_formatDate(movement['date'])}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (movement['reference'] != null)
                    Text(
                      'Referans: ${movement['reference']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            // Miktar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${movement['quantity']} adet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: movement['color'],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${movement['remainingStock']} adet',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ProductTransactionType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyStateIcon(type),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '${type.displayName} bulunamadı',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu ürün için henüz ${type.displayName.toLowerCase()} kaydı bulunmuyor',
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

  Widget _buildEmptyStockMovements() {
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
            'Stok hareketi bulunamadı',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu ürün için henüz stok hareketi kaydı bulunmuyor',
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

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                // Ürün düzenleme sayfasına git
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Stok Girişi'),
              onTap: () {
                Navigator.pop(context);
                // Stok girişi sayfasına git
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_shopping_cart),
              title: const Text('Stok Çıkışı'),
              onTap: () {
                Navigator.pop(context);
                // Stok çıkışı sayfasına git
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Depo Transferi'),
              onTap: () {
                Navigator.pop(context);
                // Depo transferi sayfasına git
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ProductTransactionType?>(
              initialValue: _selectedTransactionType,
              decoration: const InputDecoration(labelText: 'İşlem Türü'),
              items: [
                const DropdownMenuItem<ProductTransactionType?>(
                  value: null,
                  child: Text('Tümü'),
                ),
                ...ProductTransactionType.values.map(
                  (type) => DropdownMenuItem<ProductTransactionType?>(
                    value: type,
                    child: Text(type.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTransactionType = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  List<ProductTransaction> _getMockTransactions(ProductTransactionType type) {
    // Mock data - gerçek veriler provider'dan gelecek
    return [
      ProductTransaction(
        id: 1,
        productId: int.tryParse(widget.productId) ?? 0,
        type: type,
        documentNumber: '${type.shortName}-2024-001',
        quantity: 5.0,
        unitPrice: _product!.unitPrice,
        totalAmount: _product!.unitPrice * 5,
        currency: _product!.currency,
        transactionDate: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Test ${type.displayName.toLowerCase()} açıklaması',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        customerId: type == ProductTransactionType.sale ? 1 : null,
        supplierId: type == ProductTransactionType.purchase ? 1 : null,
      ),
      ProductTransaction(
        id: 2,
        productId: int.tryParse(widget.productId) ?? 0,
        type: type,
        documentNumber: '${type.shortName}-2024-002',
        quantity: 3.0,
        unitPrice: _product!.unitPrice,
        totalAmount: 100.0 * 3, // Mock data
        currency: _product!.currency,
        transactionDate: DateTime.now().subtract(const Duration(days: 10)),
        description: 'Test ${type.displayName.toLowerCase()} açıklaması',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        customerId: type == ProductTransactionType.sale ? 2 : null,
        supplierId: type == ProductTransactionType.purchase ? 2 : null,
      ),
    ];
  }

  List<Map<String, dynamic>> _getMockStockMovements() {
    // Mock data - gerçek stok hareketleri
    return [
      {
        'type': 'Stok Girişi',
        'icon': '📥',
        'color': Colors.green,
        'quantity': 10,
        'remainingStock': 15,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'reference': 'SATIN-2024-001',
      },
      {
        'type': 'Satış',
        'icon': '📤',
        'color': Colors.blue,
        'quantity': -2,
        'remainingStock': 13,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'reference': 'SAT-2024-001',
      },
      {
        'type': 'Stok Düzeltmesi',
        'icon': '⚖️',
        'color': Colors.orange,
        'quantity': -1,
        'remainingStock': 12,
        'date': DateTime.now().subtract(const Duration(hours: 5)),
        'reference': 'DÜZELT-2024-001',
      },
    ];
  }

  Color _getTransactionColor(ProductTransactionType type) {
    switch (type) {
      case ProductTransactionType.purchase:
        return Colors.green;
      case ProductTransactionType.sale:
        return Colors.blue;
      case ProductTransactionType.return_:
        return Colors.orange;
      case ProductTransactionType.adjustment:
        return Colors.purple;
      case ProductTransactionType.transfer:
        return Colors.teal;
      case ProductTransactionType.loss:
        return Colors.red;
    }
  }

  IconData _getEmptyStateIcon(ProductTransactionType type) {
    switch (type) {
      case ProductTransactionType.purchase:
        return Icons.shopping_cart;
      case ProductTransactionType.sale:
        return Icons.trending_up;
      case ProductTransactionType.return_:
        return Icons.undo;
      case ProductTransactionType.adjustment:
        return Icons.tune;
      case ProductTransactionType.transfer:
        return Icons.swap_horiz;
      case ProductTransactionType.loss:
        return Icons.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
