// ========== TRANSACTION DETAIL CARD ==========
// lib/features/payment_collection/presentation/widgets/transaction_detail_card.dart

import 'package:flutter/material.dart';

/// İşlem detay kartı widget'ı
class TransactionDetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  const TransactionDetailCard({
    super.key,
    required this.title,
    required this.children,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: backgroundColor ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 12),

            // İçerik
            ...children,
          ],
        ),
      ),
    );
  }
}
