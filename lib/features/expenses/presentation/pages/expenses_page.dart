import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tamgaci/features/accounts/domain/entities/account.dart';
import 'package:tamgaci/features/accounts/domain/entities/account_transaction.dart';
import 'package:tamgaci/features/accounts/presentation/providers/account_providers.dart';
import 'package:tamgaci/features/accounts/presentation/providers/account_transaction_providers.dart';
import 'package:tamgaci/shared/widgets/loading_widget.dart';
import 'package:tamgaci/shared/widgets/error_widget.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  String _selectedAccountId = 'all';
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final allTransactionsAsync = ref.watch(allAccountTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masraflar'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(accountsProvider);
              ref.invalidate(allAccountTransactionsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtreler
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                // Hesap filtresi
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 20),
                    const SizedBox(width: 8),
                    const Text('Hesap:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedAccountId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('Tüm Hesaplar'),
                          ),
                          ...accountsAsync.when(
                            data: (accounts) => accounts.map((account) => DropdownMenuItem(
                              value: account.id,
                              child: Text(account.name),
                            )).toList(),
                            loading: () => [],
                            error: (_, __) => [],
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountId = value ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Kategori filtresi
                Row(
                  children: [
                    const Icon(Icons.category, size: 20),
                    const SizedBox(width: 8),
                    const Text('Kategori:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tüm Kategoriler')),
                          DropdownMenuItem(value: 'expense', child: Text('Masraf')),
                          DropdownMenuItem(value: 'other', child: Text('Diğer')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Arama
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Masraf açıklamasında ara...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),
          // Masraflar listesi
          Expanded(
            child: allTransactionsAsync.when(
              data: (allTransactions) {
                // Sadece masraf kategorisindeki işlemleri filtrele
                final expenseTransactions = allTransactions
                    .where((transaction) => transaction.category == TransactionCategory.expense)
                    .toList();

                // Hesap filtresi uygula
                final filteredByAccount = _selectedAccountId == 'all'
                    ? expenseTransactions
                    : expenseTransactions.where((transaction) => transaction.accountId == _selectedAccountId).toList();

                // Kategori filtresi uygula
                final filteredByCategory = _selectedCategory == 'all'
                    ? filteredByAccount
                    : filteredByAccount.where((transaction) => transaction.category.toString().split('.').last == _selectedCategory).toList();

                // Arama filtresi uygula
                final filteredTransactions = _searchQuery.isEmpty
                    ? filteredByCategory
                    : filteredByCategory.where((transaction) => 
                        transaction.description.toLowerCase().contains(_searchQuery)).toList();

                // Tarihe göre sırala (en yeni üstte)
                filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (filteredTransactions.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Masraf bulunamadı',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Henüz hiç masraf kaydı yok',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    final account = accountsAsync.when(
                      data: (accounts) => accounts.firstWhere(
                        (acc) => acc.id == transaction.accountId,
                        orElse: () => Account(
                          id: transaction.accountId,
                          tenantId: 'unknown',
                          name: 'Bilinmeyen Hesap',
                          accountNumber: '',
                          bankName: '',
                          branchName: '',
                          iban: '',
                          swiftCode: '',
                          type: AccountType.cash,
                          balance: 0,
                          currency: 'TRY',
                          availableBalance: 0,
                          blockedAmount: 0,
                          status: AccountStatus.active,
                          isActive: true,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          createdBy: 'system',
                          updatedBy: 'system',
                        ),
                      ),
                      loading: () => Account(
                        id: transaction.accountId,
                        tenantId: 'unknown',
                        name: 'Yükleniyor...',
                        accountNumber: '',
                        bankName: '',
                        branchName: '',
                        iban: '',
                        swiftCode: '',
                        type: AccountType.cash,
                        balance: 0,
                        currency: 'TRY',
                        availableBalance: 0,
                        blockedAmount: 0,
                        status: AccountStatus.active,
                        isActive: true,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        createdBy: 'system',
                        updatedBy: 'system',
                      ),
                      error: (_, __) => Account(
                        id: transaction.accountId,
                        tenantId: 'unknown',
                        name: 'Hata',
                        accountNumber: '',
                        bankName: '',
                        branchName: '',
                        iban: '',
                        swiftCode: '',
                        type: AccountType.cash,
                        balance: 0,
                        currency: 'TRY',
                        availableBalance: 0,
                        blockedAmount: 0,
                        status: AccountStatus.active,
                        isActive: true,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        createdBy: 'system',
                        updatedBy: 'system',
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: Icon(
                            Icons.money_off,
                            color: Colors.red[700],
                          ),
                        ),
                        title: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hesap: ${account.name}'),
                            Text(
                              DateFormat('dd.MM.yyyy HH:mm').format(transaction.createdAt),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₺${NumberFormat('#,##0.00', 'tr_TR').format(transaction.amount.abs())}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            Text(
                              'Masraf',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Masraf detayına git
                          _showExpenseDetail(transaction, account);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stackTrace) => CustomErrorWidget(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(allAccountTransactionsProvider);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetail(AccountTransaction transaction, Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Masraf Detayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Açıklama', transaction.description),
            _buildDetailRow('Hesap', account.name),
            _buildDetailRow('Tutar', '₺${NumberFormat('#,##0.00', 'tr_TR').format(transaction.amount.abs())}'),
            _buildDetailRow('Tarih', DateFormat('dd.MM.yyyy').format(transaction.createdAt)),
            _buildDetailRow('Saat', DateFormat('HH:mm').format(transaction.createdAt)),
            _buildDetailRow('Kategori', 'Masraf'),
            _buildDetailRow('Bakiye', '₺${NumberFormat('#,##0.00', 'tr_TR').format(transaction.balanceAfter)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
