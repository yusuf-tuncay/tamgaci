// ========== VOUCHER PAYMENTS PAGE ==========
// lib/features/payments/presentation/pages/voucher_payments_page.dart

import 'package:flutter/material.dart';

class VoucherPaymentsPage extends StatelessWidget {
  const VoucherPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borç-Alacak Fişleri'),
        backgroundColor: Colors.red[50],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red[50]!,
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Borç-Alacak Fişleri',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bu modül yakında eklenecek',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
