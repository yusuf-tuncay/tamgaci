import 'package:flutter/material.dart';
import 'package:tamgaci/features/cash_management/domain/entities/cash_account.dart';

/// Nakit hesap kartı widget'ı
class CashAccountCard extends StatelessWidget {
  final CashAccount cashAccount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const CashAccountCard({
    super.key,
    required this.cashAccount,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cashAccount.name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          cashAccount.description ?? '',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${cashAccount.balance.toStringAsFixed(2)} ${cashAccount.currency}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: cashAccount.balance >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _formatDate(cashAccount.createdAt),
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  _buildTypeChip(cashAccount.type),
                  const SizedBox(width: 8.0),
                  _buildStatusChip(cashAccount.status),
                  if (cashAccount.isDefault) ...[
                    const SizedBox(width: 8.0),
                    _buildDefaultChip(),
                  ],
                ],
              ),
              if (cashAccount.bankName != null ||
                  cashAccount.accountNumber != null) ...[
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    if (cashAccount.bankName != null) ...[
                      Icon(Icons.account_balance,
                          size: 16.0, color: Colors.grey.shade600),
                      const SizedBox(width: 4.0),
                      Text(
                        cashAccount.bankName!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (cashAccount.accountNumber != null) ...[
                      const SizedBox(width: 16.0),
                      Icon(Icons.credit_card,
                          size: 16.0, color: Colors.grey.shade600),
                      const SizedBox(width: 4.0),
                      Text(
                        cashAccount.accountNumber!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (cashAccount.creditLimit != null)
                    Text(
                      'Limit: ${cashAccount.creditLimit!.toStringAsFixed(2)} ${cashAccount.currency}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade600,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20.0),
                          onPressed: onEdit,
                          tooltip: 'Düzenle',
                        ),
                      if (onDuplicate != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20.0),
                          onPressed: onDuplicate,
                          tooltip: 'Kopyala',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete,
                              size: 20.0, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Sil',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(CashAccountType type) {
    return Chip(
      label: Text(
        type.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getTypeColor(type),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(CashAccountStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12.0),
      ),
      backgroundColor: _getStatusColor(status),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDefaultChip() {
    return Chip(
      label: const Text(
        'Varsayılan',
        style: TextStyle(fontSize: 12.0),
      ),
      backgroundColor: Colors.blue.shade300,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getTypeColor(CashAccountType type) {
    switch (type) {
      case CashAccountType.cash:
        return Colors.green.shade300;
      case CashAccountType.bank:
        return Colors.blue.shade300;
      case CashAccountType.creditCard:
        return Colors.orange.shade300;
      case CashAccountType.check:
        return Colors.purple.shade300;
      case CashAccountType.other:
        return Colors.grey.shade300;
    }
  }

  Color _getStatusColor(CashAccountStatus status) {
    switch (status) {
      case CashAccountStatus.active:
        return Colors.green.shade300;
      case CashAccountStatus.inactive:
        return Colors.orange.shade300;
      case CashAccountStatus.closed:
        return Colors.red.shade300;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
