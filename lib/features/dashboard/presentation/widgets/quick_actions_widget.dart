// ========== QUICK ACTIONS WIDGET ==========
// lib/features/dashboard/presentation/widgets/quick_actions_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';

/// Hızlı işlemler widget'ı
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _buildQuickAction(
                context,
                'Yeni Satış',
                Icons.sell_outlined,
                AppColors.primary,
                () => Navigator.pushNamed(context, TamgaciRoutes.createInvoice),
              ),
              _buildQuickAction(
                context,
                'Yeni Alış',
                Icons.shopping_cart_outlined,
                Colors.orange,
                () => Navigator.pushNamed(context, TamgaciRoutes.suppliersList),
              ),
              _buildQuickAction(
                context,
                'Müşteri Ekle',
                Icons.person_add_outlined,
                Colors.green,
                () =>
                    Navigator.pushNamed(context, TamgaciRoutes.createCustomer),
              ),
              _buildQuickAction(
                context,
                'Ürün Ekle',
                Icons.add_box_outlined,
                Colors.blue,
                () => Navigator.pushNamed(context, TamgaciRoutes.createProduct),
              ),
              _buildQuickAction(
                context,
                'Kasa İşlemi',
                Icons.account_balance_wallet_outlined,
                Colors.purple,
                () => Navigator.pushNamed(context, TamgaciRoutes.accountsList),
              ),
              _buildQuickAction(
                context,
                'Gider Ekle',
                Icons.money_off_outlined,
                Colors.red,
                () => Navigator.pushNamed(context, TamgaciRoutes.createExpense),
              ),
              _buildQuickAction(
                context,
                'Gelir Ekle',
                Icons.attach_money_outlined,
                Colors.teal,
                () => Navigator.pushNamed(context, TamgaciRoutes.createIncome),
              ),
              _buildQuickAction(
                context,
                'Tahsilat',
                Icons.payments_outlined,
                Colors.green,
                () => Navigator.pushNamed(context, TamgaciRoutes.paymentsHome),
              ),
              _buildQuickAction(
                context,
                'Raporlar',
                Icons.assessment_outlined,
                Colors.indigo,
                () =>
                    Navigator.pushNamed(context, TamgaciRoutes.reportsOverview),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
