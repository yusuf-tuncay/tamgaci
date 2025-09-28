// ========== CASH PAYMENTS PAGE ==========
// lib/features/payments/presentation/pages/cash_payments_page.dart

import 'package:flutter/material.dart';

class CashPaymentsPage extends StatelessWidget {
  const CashPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nakit, Kredi Kartı, Banka'),
        backgroundColor: Colors.green[50],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on,
                size: 64,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'Nakit, Kredi Kartı, Banka İşlemleri',
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
