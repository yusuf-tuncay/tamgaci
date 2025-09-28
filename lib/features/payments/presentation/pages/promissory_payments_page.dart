// ========== PROMISSORY PAYMENTS PAGE ==========
// lib/features/payments/presentation/pages/promissory_payments_page.dart

import 'package:flutter/material.dart';

class PromissoryPaymentsPage extends StatelessWidget {
  const PromissoryPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Senet Al/Ver'),
        backgroundColor: Colors.purple[50],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple[50]!,
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description,
                size: 64,
                color: Colors.purple,
              ),
              SizedBox(height: 16),
              Text(
                'Senet Al/Ver İşlemleri',
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
