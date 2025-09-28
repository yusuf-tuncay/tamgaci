// ========== PAYMENTS HOME PAGE ==========
// lib/features/payments/presentation/pages/payments_home_page.dart

import 'package:flutter/material.dart';

class PaymentsHomePage extends StatelessWidget {
  const PaymentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahsilat Modülü'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blue[700],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tahsilat Modülü',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Muhasebe işlemlerinizi kolayca yönetin',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Categories Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildPaymentCategoryCard(
                      context: context,
                      title: 'Nakit, Kredi Kartı, Banka',
                      subtitle: 'Nakit ve banka işlemleri',
                      icon: Icons.monetization_on,
                      color: Colors.green,
                      onTap: () => Navigator.pushNamed(context, '/payments/cash'),
                    ),
                    _buildPaymentCategoryCard(
                      context: context,
                      title: 'Çek',
                      subtitle: 'Çek işlemleri',
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(context, '/payments/check'),
                    ),
                    _buildPaymentCategoryCard(
                      context: context,
                      title: 'Senet Al/Ver',
                      subtitle: 'Senet işlemleri',
                      icon: Icons.description,
                      color: Colors.purple,
                      onTap: () => Navigator.pushNamed(context, '/payments/promissory'),
                    ),
                    _buildPaymentCategoryCard(
                      context: context,
                      title: 'Cari Virman',
                      subtitle: 'Hesap transferleri',
                      icon: Icons.swap_horiz,
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(context, '/payments/transfer'),
                    ),
                    _buildPaymentCategoryCard(
                      context: context,
                      title: 'Borç-Alacak Fişleri',
                      subtitle: 'Fiş işlemleri',
                      icon: Icons.receipt,
                      color: Colors.red,
                      onTap: () => Navigator.pushNamed(context, '/payments/voucher'),
                    ),
                    _buildPaymentCategoryCard(
                      context: context,
                      title: 'Bakiye Düzelt',
                      subtitle: 'Bakiye düzeltme işlemleri',
                      icon: Icons.balance,
                      color: Colors.teal,
                      onTap: () => Navigator.pushNamed(context, '/payments/balance'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
