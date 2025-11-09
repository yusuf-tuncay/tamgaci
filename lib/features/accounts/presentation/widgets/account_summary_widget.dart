import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/account.dart';

/// Hesap Özet Widget'ı
class AccountSummaryWidget extends StatelessWidget {
  final List<Account> accounts;
  final VoidCallback? onViewAll;

  const AccountSummaryWidget({
    super.key,
    required this.accounts,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalBalance = accounts.fold<double>(
      0.0,
      (sum, account) => sum + account.balance,
    );

    final activeAccounts = accounts.where((a) => a.isActive).length;
    final totalAccounts = accounts.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSummaryCards(totalBalance, activeAccounts, totalAccounts),
          const SizedBox(height: 12),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap Özeti',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Tüm hesaplarınızın genel durumu',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'Tümünü Gör',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCards(
      double totalBalance, int activeAccounts, int totalAccounts) {
    final summaryItems = [
      (
        title: 'Toplam Bakiye',
        value: _formatCurrency(totalBalance),
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.blue[600] ?? Colors.blue
      ),
      (
        title: 'Aktif Hesap',
        value: activeAccounts.toString(),
        icon: Icons.check_circle_outline,
        color: Colors.green[600] ?? Colors.green
      ),
      (
        title: 'Toplam Hesap',
        value: totalAccounts.toString(),
        icon: Icons.account_balance_outlined,
        color: Colors.grey[700] ?? Colors.grey
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: summaryItems
          .map(
            (item) => _buildSummaryChip(
              item.title,
              item.value,
              item.icon,
              item.color,
            ),
          )
          .toList(),
    );
  }

  Widget _buildSummaryChip(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
        label: 'Hesap Ekle',
        icon: Icons.add,
        color: Colors.blue[600] ?? Colors.blue,
        onTap: () {}
      ),
      (
        label: 'Transfer',
        icon: Icons.swap_horiz,
        color: Colors.green[600] ?? Colors.green,
        onTap: () {}
      ),
      (
        label: 'Raporlar',
        icon: Icons.analytics_outlined,
        color: Colors.purple[600] ?? Colors.purple,
        onTap: () {}
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions
          .map(
            (action) => _buildActionChip(
              action.label,
              action.icon,
              action.color,
              action.onTap,
            ),
          )
          .toList(),
    );
  }

  Widget _buildActionChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 18,
        color: color,
      ),
      backgroundColor: color.withValues(alpha: 0.08),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ₺';
  }
}
