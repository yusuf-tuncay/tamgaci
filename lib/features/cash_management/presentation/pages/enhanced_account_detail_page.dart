// ========== ENHANCED ACCOUNT DETAIL PAGE ==========
// lib/features/cash_management/presentation/pages/enhanced_account_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../domain/entities/account.dart';

/// Gelişmiş hesap detay sayfası
class EnhancedAccountDetailPage extends ConsumerStatefulWidget {
  final String accountId;

  const EnhancedAccountDetailPage({super.key, required this.accountId});

  @override
  ConsumerState<EnhancedAccountDetailPage> createState() =>
      _EnhancedAccountDetailPageState();
}

class _EnhancedAccountDetailPageState
    extends ConsumerState<EnhancedAccountDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = _getMockAccount();

    return ResponsiveScaffold(
      appBar: AppBar(
        title: Text(account.name),
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
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Dışa Aktar'),
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
            Tab(text: 'İşlemler', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Grafikler', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(account),
          _buildTransactionsTab(account),
          _buildChartsTab(account),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Account account) {
    return SingleChildScrollView(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hesap Özet Kartı
          _buildAccountSummaryCard(account),

          const SizedBox(height: 24),

          // Temel Bilgiler
          _buildInfoSection('Temel Bilgiler', [
            _buildInfoRow('Hesap Adı', account.name),
            _buildInfoRow('Açıklama', account.description ?? 'Açıklama yok'),
            _buildInfoRow('Hesap Türü', account.type.displayName),
            _buildInfoRow('Durum', account.status.displayName),
            _buildInfoRow('Para Birimi', account.currency),
          ]),

          const SizedBox(height: 24),

          // Banka Bilgileri
          if (account.bankName != null ||
              account.accountNumber != null ||
              account.iban != null)
            _buildInfoSection('Banka Bilgileri', [
              if (account.bankName != null)
                _buildInfoRow('Banka Adı', account.bankName!),
              if (account.accountNumber != null)
                _buildInfoRow('Hesap Numarası', account.accountNumber!),
              if (account.iban != null) _buildInfoRow('IBAN', account.iban!),
              if (account.swiftCode != null)
                _buildInfoRow('SWIFT Kodu', account.swiftCode!),
            ]),

          const SizedBox(height: 24),

          // Kredi Bilgileri
          if (account.hasCreditLimit)
            _buildInfoSection('Kredi Bilgileri', [
              _buildInfoRow(
                  'Kredi Limiti',
                  CurrencyHelper.formatCurrency(
                      account.creditLimit!, account.currency)),
              if (account.interestRate != null)
                _buildInfoRow('Faiz Oranı', '${account.interestRate}%'),
              _buildInfoRow('Kullanım Oranı',
                  '${(account.creditUtilization * 100).toStringAsFixed(1)}%'),
              _buildInfoRow(
                  'Limit Aşımı', account.isOverCreditLimit ? 'Evet' : 'Hayır'),
            ]),

          const SizedBox(height: 24),

          // İletişim Bilgileri
          if (account.contactPerson != null ||
              account.contactPhone != null ||
              account.contactEmail != null)
            _buildInfoSection('İletişim Bilgileri', [
              if (account.contactPerson != null)
                _buildInfoRow('İletişim Kişisi', account.contactPerson!),
              if (account.contactPhone != null)
                _buildInfoRow('Telefon', account.contactPhone!),
              if (account.contactEmail != null)
                _buildInfoRow('E-posta', account.contactEmail!),
              if (account.address != null)
                _buildInfoRow('Adres', account.address!),
            ]),

          const SizedBox(height: 24),

          // Sistem Bilgileri
          _buildInfoSection('Sistem Bilgileri', [
            _buildInfoRow('Oluşturulma Tarihi', _formatDate(account.createdAt)),
            _buildInfoRow('Son Güncelleme', _formatDate(account.updatedAt)),
            if (account.createdBy != null)
              _buildInfoRow('Oluşturan', account.createdBy!),
            if (account.updatedBy != null)
              _buildInfoRow('Güncelleyen', account.updatedBy!),
          ]),
        ],
      ),
    );
  }

  Widget _buildAccountSummaryCard(Account account) {
    final statusColor = _getStatusColor(account.status);
    final balanceColor = _getBalanceColor(account.currentBalance);

    return Card(
      elevation: 4,
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          children: [
            // Üst kısım - Hesap adı ve durum
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(TamgaciConstants.radiusMD),
                  ),
                  child: Icon(
                    _getAccountTypeIcon(account.type),
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (account.bankName != null)
                        Text(
                          account.bankName!,
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
                          account.status.displayName,
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

            // Alt kısım - Bakiye ve kredi bilgileri
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Mevcut Bakiye',
                    CurrencyHelper.formatCurrency(
                        account.currentBalance, account.currency),
                    balanceColor,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 16),
                if (account.hasCreditLimit)
                  Expanded(
                    child: _buildSummaryCard(
                      'Kredi Limiti',
                      CurrencyHelper.formatCurrency(
                          account.creditLimit!, account.currency),
                      AppColors.info,
                      Icons.credit_card,
                    ),
                  ),
                if (account.hasCreditLimit) const SizedBox(width: 16),
                if (account.hasCreditLimit)
                  Expanded(
                    child: _buildSummaryCard(
                      'Kullanım Oranı',
                      '${(account.creditUtilization * 100).toStringAsFixed(1)}%',
                      account.isOverCreditLimit
                          ? AppColors.error
                          : AppColors.warning,
                      Icons.pie_chart,
                    ),
                  ),
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

  Widget _buildTransactionsTab(Account account) {
    return const Center(
      child: Text('İşlemler sekmesi yakında eklenecek'),
    );
  }

  Widget _buildChartsTab(Account account) {
    return const Center(
      child: Text('Grafikler sekmesi yakında eklenecek'),
    );
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.account_balance_wallet;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.other:
        return Icons.category;
    }
  }

  Color _getStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return AppColors.success;
      case AccountStatus.inactive:
        return AppColors.warning;
      case AccountStatus.closed:
        return AppColors.error;
      case AccountStatus.suspended:
        return AppColors.textSecondary;
    }
  }

  Color _getBalanceColor(double balance) {
    if (balance > 0) return AppColors.success;
    if (balance < 0) return AppColors.error;
    return AppColors.textSecondary;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Account _getMockAccount() {
    return Account(
      id: widget.accountId,
      name: 'Ana Nakit Kasa',
      description: 'Günlük nakit işlemler için ana kasa',
      type: AccountType.cash,
      status: AccountStatus.active,
      currentBalance: 15000.0,
      currency: 'TRY',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      createdBy: 'Admin',
      updatedBy: 'Admin',
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesap Düzenle'),
        content: const Text('Hesap düzenleme formu yakında eklenecek.'),
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
      case 'export':
        _showExportDialog();
        break;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Bu hesabı silmek istediğinizden emin misiniz?'),
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

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dışa Aktar'),
        content:
            const Text('Excel/PDF dışa aktarım özellikleri yakında eklenecek.'),
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
