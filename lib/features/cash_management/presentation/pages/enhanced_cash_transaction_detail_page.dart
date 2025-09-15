// ========== ENHANCED CASH TRANSACTION DETAIL PAGE ==========
// lib/features/cash_management/presentation/pages/enhanced_cash_transaction_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../domain/entities/account.dart';

/// Gelişmiş nakit işlemi detay sayfası
class EnhancedCashTransactionDetailPage extends ConsumerStatefulWidget {
  final String transactionId;

  const EnhancedCashTransactionDetailPage(
      {super.key, required this.transactionId});

  @override
  ConsumerState<EnhancedCashTransactionDetailPage> createState() =>
      _EnhancedCashTransactionDetailPageState();
}

class _EnhancedCashTransactionDetailPageState
    extends ConsumerState<EnhancedCashTransactionDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final transaction = _getMockTransaction();

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('İşlem Detayı'),
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.edit),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 8),
                    Text('Kopyala'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Detaylar', icon: Icon(Icons.info_outline)),
            Tab(text: 'Geçmiş', icon: Icon(Icons.history)),
          ],
        ),
      ),
      drawer: const TamgaciDrawerMenu(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(transaction),
          _buildHistoryTab(transaction),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(CashTransaction transaction) {
    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İşlem Özet Kartı
          _buildTransactionSummaryCard(transaction),

          const SizedBox(height: 24),

          // Temel Bilgiler
          _buildInfoSection('Temel Bilgiler', [
            _buildInfoRow('İşlem Türü', transaction.type.displayName),
            _buildInfoRow('Durum', transaction.status.displayName),
            _buildInfoRow(
                'Tutar',
                CurrencyHelper.formatCurrency(
                    transaction.amount, transaction.currency)),
            _buildInfoRow('Para Birimi', transaction.currency),
            _buildInfoRow(
                'İşlem Tarihi', _formatDate(transaction.transactionDate)),
            if (transaction.dueDate != null)
              _buildInfoRow('Vade Tarihi', _formatDate(transaction.dueDate!)),
          ]),

          const SizedBox(height: 24),

          // Hesap Bilgileri
          _buildInfoSection('Hesap Bilgileri', [
            _buildInfoRow(
                'Kaynak Hesap', _getAccountName(transaction.accountId)),
            if (transaction.toAccountId != null)
              _buildInfoRow(
                  'Hedef Hesap', _getAccountName(transaction.toAccountId!)),
          ]),

          const SizedBox(height: 24),

          // Açıklama ve Notlar
          if (transaction.description != null || transaction.notes != null)
            _buildInfoSection('Açıklama ve Notlar', [
              if (transaction.description != null)
                _buildInfoRow('Açıklama', transaction.description!),
              if (transaction.notes != null)
                _buildInfoRow('Notlar', transaction.notes!),
            ]),

          const SizedBox(height: 24),

          // Kategori ve Referans
          if (transaction.category != null || transaction.reference != null)
            _buildInfoSection('Kategori ve Referans', [
              if (transaction.category != null)
                _buildInfoRow('Kategori', transaction.category!),
              if (transaction.subCategory != null)
                _buildInfoRow('Alt Kategori', transaction.subCategory!),
              if (transaction.reference != null)
                _buildInfoRow('Referans', transaction.reference!),
            ]),

          const SizedBox(height: 24),

          // Sistem Bilgileri
          _buildInfoSection('Sistem Bilgileri', [
            _buildInfoRow(
                'Oluşturulma Tarihi', _formatDate(transaction.createdAt)),
            _buildInfoRow('Son Güncelleme', _formatDate(transaction.updatedAt)),
            if (transaction.createdBy != null)
              _buildInfoRow('Oluşturan', transaction.createdBy!),
            if (transaction.updatedBy != null)
              _buildInfoRow('Güncelleyen', transaction.updatedBy!),
          ]),
        ],
      ),
    );
  }

  Widget _buildTransactionSummaryCard(CashTransaction transaction) {
    final typeColor = _getTypeColor(transaction.type);
    final statusColor = _getStatusColor(transaction.status);

    return Card(
      elevation: 4,
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          children: [
            // Üst kısım - İşlem türü ve durum
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(TamgaciConstants.radiusMD),
                  ),
                  child: Icon(
                    _getTransactionTypeIcon(transaction.type),
                    color: typeColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'İşlem Açıklaması Yok',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _getAccountName(transaction.accountId),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transaction.status.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Alt kısım - Tutar ve tarih bilgileri
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Tutar',
                    CurrencyHelper.formatCurrency(
                        transaction.amount, transaction.currency),
                    transaction.isIncome ? AppColors.success : AppColors.error,
                    transaction.isIncome
                        ? Icons.add_circle
                        : Icons.remove_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'İşlem Tarihi',
                    _formatDate(transaction.transactionDate),
                    AppColors.info,
                    Icons.calendar_today,
                  ),
                ),
                if (transaction.dueDate != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Vade Tarihi',
                      _formatDate(transaction.dueDate!),
                      transaction.isOverdue
                          ? AppColors.error
                          : AppColors.warning,
                      Icons.schedule,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(CashTransaction transaction) {
    return const Center(
      child: Text('İşlem geçmişi yakında eklenecek'),
    );
  }

  IconData _getTransactionTypeIcon(CashTransactionType type) {
    switch (type) {
      case CashTransactionType.income:
        return Icons.trending_up;
      case CashTransactionType.expense:
        return Icons.trending_down;
      case CashTransactionType.transfer:
        return Icons.swap_horiz;
      case CashTransactionType.adjustment:
        return Icons.edit;
      case CashTransactionType.loan:
        return Icons.credit_card;
      case CashTransactionType.investment:
        return Icons.trending_up;
    }
  }

  Color _getTypeColor(CashTransactionType type) {
    switch (type) {
      case CashTransactionType.income:
        return AppColors.success;
      case CashTransactionType.expense:
        return AppColors.error;
      case CashTransactionType.transfer:
        return AppColors.info;
      case CashTransactionType.adjustment:
        return AppColors.warning;
      case CashTransactionType.loan:
        return AppColors.primary;
      case CashTransactionType.investment:
        return AppColors.success;
    }
  }

  Color _getStatusColor(CashTransactionStatus status) {
    switch (status) {
      case CashTransactionStatus.pending:
        return AppColors.warning;
      case CashTransactionStatus.completed:
        return AppColors.success;
      case CashTransactionStatus.cancelled:
        return AppColors.error;
      case CashTransactionStatus.failed:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getAccountName(String accountId) {
    switch (accountId) {
      case '1':
        return 'Ana Nakit Kasa';
      case '2':
        return 'İş Bankası TL Hesabı';
      case '3':
        return 'Kredi Kartı';
      case '4':
        return 'USD Döviz Hesabı';
      default:
        return 'Bilinmeyen Hesap';
    }
  }

  CashTransaction _getMockTransaction() {
    return CashTransaction(
      id: widget.transactionId,
      accountId: '1',
      type: CashTransactionType.income,
      status: CashTransactionStatus.completed,
      amount: 5000.0,
      currency: 'TRY',
      description: 'Satış geliri',
      category: 'Satış',
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdBy: 'Admin',
      updatedBy: 'Admin',
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlem Düzenle'),
        content: const Text('İşlem düzenleme formu yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _showEditDialog();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
      case 'duplicate':
        _showDuplicateDialog();
        break;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu işlemi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete logic here
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDuplicateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlemi Kopyala'),
        content: const Text('İşlem kopyalama özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
