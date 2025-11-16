import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../payment_collection/domain/entities/payment_enums.dart';
import '../../../payment_collection/domain/entities/payment_transaction.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_transaction.dart';
import '../providers/account_transaction_providers.dart';
import '../providers/account_providers.dart';
import 'package:tamgaci/core/services/utils/exchange_rate_service.dart';
import 'package:tamgaci/core/theme/constants.dart';
import 'create_account_page.dart';
import 'account_transactions_page.dart';

/// Hesap Detay Sayfası
class AccountDetailPage extends ConsumerStatefulWidget {
  final Account account;

  const AccountDetailPage({
    super.key,
    required this.account,
  });

  @override
  ConsumerState<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends ConsumerState<AccountDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hesaplar listesi ile aynı mantık - accountNotifierProvider kullan
    final accountsAsync = ref.watch(accountNotifierProvider);
    final transactionsAsync =
        ref.watch(transactionsByAccountIdProvider(widget.account.id));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: accountsAsync.when(
        data: (accounts) {
          // Güncel hesap verisini bul
          final updatedAccount = accounts.firstWhere(
            (acc) => acc.id == widget.account.id,
            orElse: () => widget.account,
          );

          debugPrint(
              'AccountDetailPage - accountNotifier account: ${updatedAccount.name}');
          debugPrint(
              'AccountDetailPage - accountNotifier balance: ${updatedAccount.balance}');
          debugPrint(
              'AccountDetailPage - updatedAccount.isDefault: ${updatedAccount.isDefault}');

          return transactionsAsync.when(
            data: (transactions) {
              // Hesap hareketlerinden bakiye hesapla
              final calculatedBalance =
                  _calculateBalanceFromTransactions(transactions);
              final accountWithCalculatedBalance =
                  updatedAccount.copyWith(balance: calculatedBalance);
              final account = accountWithCalculatedBalance;

              debugPrint(
                  'AccountDetailPage - account.isDefault: ${account.isDefault}');

              debugPrint(
                  'AccountDetailPage - calculated balance: $calculatedBalance');
              debugPrint(
                  'AccountDetailPage - original balance: ${updatedAccount.balance}');

              return CustomScrollView(
                slivers: [
                  _buildAppBar(account),
                  _buildAccountCard(account),
                  _buildDetailsSection(account),
                  if (account.isCheckAccount)
                    _buildCheckPortfolioSection(account)
                  else if (account.isPromissoryAccount)
                    _buildPromissoryPortfolioSection(account)
                  else
                    _buildTransactionsSection(account),
                  _buildActionsSection(account),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Transaction hatası: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  /// Hesap hareketlerinden bakiye hesapla
  double _calculateBalanceFromTransactions(
      List<AccountTransaction> transactions) {
    double balance = 0.0;

    // İşlemleri tarih sırasına göre sırala (en eski önce)
    final sortedTransactions = List<AccountTransaction>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    for (final transaction in sortedTransactions) {
      balance += transaction.amount;
    }

    return balance;
  }

  Widget _buildAppBar(Account account) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      title: Text(
        'TAMGACI',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: TamgaciConstants.primaryColor,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 24),
        onPressed: () => context.goNamed('accounts-home'),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface, size: 24),
          onPressed: _showMoreOptions,
          tooltip: 'Daha fazla seçenek',
        ),
      ],
    );
  }

  Widget _buildAccountCard(Account account) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TamgaciConstants.primaryColor,
                      Color(0xFF4C6EF5),
                      TamgaciConstants.primaryColorDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          TamgaciConstants.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            account.bankName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsSection(Account account) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDetailsExpanded = !_isDetailsExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hesap Detayları',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            Icon(
                              _isDetailsExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _isDetailsExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                                'Hesap Numarası', account.accountNumber),
                            _buildDetailRow('IBAN', account.iban),
                            _buildDetailRow('SWIFT Kodu', account.swiftCode),
                            _buildDetailRow('Şube', account.branchName),
                            _buildDetailRow('Para Birimi', account.currency),
                            _buildDetailRow(
                                'Hesap Türü', account.type.displayName),
                            _buildDetailRow(
                                'Durum', account.status.displayName),
                            if (account.description != null)
                              _buildDetailRow('Açıklama', account.description!),
                            if (account.notes != null)
                              _buildDetailRow('Notlar', account.notes!),
                            _buildDetailRow(
                                'Oluşturulma', _formatDate(account.createdAt)),
                            _buildDetailRow('Son Güncelleme',
                                _formatDate(account.updatedAt)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckPortfolioSection(Account account) {
    final accentColor = Colors.orange[600] ?? Colors.orange;
    final portfolioAsync = ref.watch(
      checkPortfolioProvider(
        buildAccountPortfolioKey(
          accountId: account.id,
          tenantId: account.tenantId,
        ),
      ),
    );
    return _buildPortfolioSection(
      title: 'Çek Portföyü',
      asyncValue: portfolioAsync,
      accentColor: accentColor,
      icon: Icons.receipt_long_outlined,
      emptyMessage: 'Bu hesapta kayıtlı çek bulunmuyor.',
      infoText: 'Çek ekleme ve yönetimi Tahsilat modülünden yapılır.',
    );
  }

  Widget _buildPromissoryPortfolioSection(Account account) {
    final accentColor = Colors.blueGrey[600] ?? Colors.blueGrey;
    final portfolioAsync = ref.watch(
      promissoryPortfolioProvider(
        buildAccountPortfolioKey(
          accountId: account.id,
          tenantId: account.tenantId,
        ),
      ),
    );
    return _buildPortfolioSection(
      title: 'Senet Portföyü',
      asyncValue: portfolioAsync,
      accentColor: accentColor,
      icon: Icons.description_outlined,
      emptyMessage: 'Bu hesapta kayıtlı senet bulunmuyor.',
      infoText: 'Senet ekleme ve yönetimi Tahsilat modülünden yapılır.',
    );
  }

  Widget _buildPortfolioSection({
    required String title,
    required AsyncValue<List<PaymentTransaction>> asyncValue,
    required Color accentColor,
    required IconData icon,
    required String emptyMessage,
    String? infoText,
  }) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: asyncValue.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return _buildPortfolioEmptyState(
                        icon: icon,
                        message: emptyMessage,
                        accentColor: accentColor,
                      );
                    }
                    return _buildPortfolioContent(
                      title: title,
                      transactions: transactions,
                      accentColor: accentColor,
                      icon: icon,
                      infoText: infoText,
                    );
                  },
                  loading: () => _buildPortfolioLoading(),
                  error: (error, stack) =>
                      _buildPortfolioError(title, error.toString()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortfolioContent({
    required String title,
    required List<PaymentTransaction> transactions,
    required Color accentColor,
    required IconData icon,
    String? infoText,
  }) {
    final currency = transactions.first.currency;
    final totalAmount = transactions.fold<double>(
        0, (runningTotal, transaction) => runningTotal + transaction.amount);
    final pendingCount = transactions
        .where((transaction) =>
            transaction.status == PaymentTransactionStatus.pending ||
            transaction.status == PaymentTransactionStatus.processing ||
            transaction.status == PaymentTransactionStatus.onHold)
        .length;
    final completedCount = transactions
        .where((transaction) =>
            transaction.status == PaymentTransactionStatus.completed ||
            transaction.status == PaymentTransactionStatus.approved)
        .length;
    final sortedTransactions = transactions.toList()
      ..sort((a, b) {
        final aDate = a.dueDate ?? a.transactionDate;
        final bDate = b.dueDate ?? b.transactionDate;
        return aDate.compareTo(bDate);
      });

    final pendingColor = Colors.orange[600] ?? Colors.orange;
    final completedColor = Colors.green[600] ?? Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        if (infoText != null) ...[
          const SizedBox(height: 12),
          Text(
            infoText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildPortfolioSummaryChip(
              label: 'Toplam Tutar',
              value:
                  '${NumberFormat('#,##0.00', 'tr_TR').format(totalAmount)} $currency',
              accentColor: accentColor,
            ),
            _buildPortfolioSummaryChip(
              label: 'Bekleyen',
              value: pendingCount.toString(),
              accentColor: pendingColor,
            ),
            _buildPortfolioSummaryChip(
              label: 'Tamamlanan',
              value: completedCount.toString(),
              accentColor: completedColor,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          children: sortedTransactions
              .map((transaction) =>
                  _buildPortfolioItem(transaction, accentColor))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPortfolioSummaryChip({
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: accentColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(
      PaymentTransaction transaction, Color accentColor) {
    final amountText =
        '${NumberFormat('#,##0.00', 'tr_TR').format(transaction.amount)} ${transaction.currency}';
    final transactionDate = _formatDate(transaction.transactionDate);
    final dueDateText = transaction.dueDate != null
        ? _formatDate(transaction.dueDate!)
        : 'Belirtilmemiş';
    final statusColor = _mapStatusColor(transaction.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.transactionNumber,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  transaction.statusDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payments_outlined, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                amountText,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildPortfolioMetaChip(
                icon: Icons.today_outlined,
                label: 'İşlem',
                value: transactionDate,
              ),
              _buildPortfolioMetaChip(
                icon: Icons.event_outlined,
                label: 'Vade',
                value: dueDateText,
              ),
              _buildPortfolioMetaChip(
                icon: Icons.sync_alt,
                label: 'Yön',
                value: transaction.directionDisplayName,
              ),
            ],
          ),
          // Çek bilgileri
          if (transaction.type == PaymentTransactionType.check &&
              transaction.metadata.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance, 
                          color: Colors.blue[700], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Çek Bilgileri',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (transaction.metadata['checkNumber'] != null)
                    _buildMetadataRow('Çek No', 
                        transaction.metadata['checkNumber'].toString()),
                  if (transaction.metadata['bankName'] != null)
                    _buildMetadataRow('Banka', 
                        transaction.metadata['bankName'].toString()),
                  if (transaction.metadata['branchName'] != null)
                    _buildMetadataRow('Şube', 
                        transaction.metadata['branchName'].toString()),
                  if (transaction.metadata['accountNumber'] != null)
                    _buildMetadataRow('Hesap No', 
                        transaction.metadata['accountNumber'].toString()),
                  if (transaction.metadata['iban'] != null)
                    _buildMetadataRow('IBAN', 
                        transaction.metadata['iban'].toString()),
                ],
              ),
            ),
          ],
          // Senet bilgileri
          if (transaction.type == PaymentTransactionType.promissoryNote &&
              transaction.metadata.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, 
                          color: Colors.orange[700], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Senet Bilgileri',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (transaction.metadata['noteNumber'] != null)
                    _buildMetadataRow('Senet No', 
                        transaction.metadata['noteNumber'].toString()),
                  if (transaction.metadata['interestRate'] != null)
                    _buildMetadataRow('Faiz Oranı', 
                        '${transaction.metadata['interestRate']}%'),
                ],
              ),
            ),
          ],
          if (transaction.description != null &&
              transaction.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                transaction.description!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioMetaChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioEmptyState({
    required IconData icon,
    required String message,
    required Color accentColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: accentColor.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        3,
        (index) => Container(
          margin: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
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

  Widget _buildPortfolioError(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title yüklenirken bir hata oluştu',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _mapStatusColor(PaymentTransactionStatus status) {
    switch (status) {
      case PaymentTransactionStatus.completed:
      case PaymentTransactionStatus.approved:
        return Colors.green[600] ?? Colors.green;
      case PaymentTransactionStatus.pending:
      case PaymentTransactionStatus.processing:
      case PaymentTransactionStatus.onHold:
        return Colors.orange[600] ?? Colors.orange;
      case PaymentTransactionStatus.cancelled:
      case PaymentTransactionStatus.rejected:
      case PaymentTransactionStatus.failed:
        return Colors.red[600] ?? Colors.red;
      default:
        return Colors.blueGrey[600] ?? Colors.blueGrey;
    }
  }

  Widget _buildTransactionsSection(Account account) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hesap Hareketleri',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        TextButton(
                          onPressed: _viewAllTransactions,
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
                    ),
                    const SizedBox(height: 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final transactionsAsync = ref.watch(
                          transactionsByAccountIdProvider(account.id),
                        );
                        final paymentTransactionsAsync = ref.watch(
                          paymentTransactionsByAccountProvider(account.id),
                        );

                        return transactionsAsync.when(
                          data: (transactions) {
                            final paymentTransactions = paymentTransactionsAsync.maybeWhen(
                              data: (value) => value,
                              orElse: () => <PaymentTransaction>[],
                            );
                            
                            // Tüm işlemleri birleştir
                            final allItems = <Map<String, dynamic>>[
                              ...transactions.map((t) => {
                                    'type': 'account_transaction',
                                    'date': t.createdAt,
                                    'data': t,
                                  }),
                              ...paymentTransactions.map((pt) => {
                                    'type': 'payment_transaction',
                                    'date': pt.transactionDate,
                                    'data': pt,
                                  }),
                            ]..sort((a, b) => (b['date'] as DateTime)
                                .compareTo(a['date'] as DateTime));
                            
                            if (allItems.isEmpty) {
                              return Center(child: _buildEmptyTransactions());
                            }

                            return Column(
                              children: allItems.take(5).map((item) {
                                if (item['type'] == 'account_transaction') {
                                  return _buildTransactionItem(
                                      item['data'] as AccountTransaction);
                                } else {
                                  return _buildPaymentTransactionItem(
                                      item['data'] as PaymentTransaction);
                                }
                              }).toList(),
                            );
                          },
                          loading: () => _buildLoadingTransactions(),
                          error: (error, stack) =>
                              _buildErrorTransactions(error),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz işlem yok',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu hesapta henüz işlem bulunmuyor',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(Account account) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildActionButton(
                      'Hesap Düzenle',
                      Icons.edit,
                      Colors.blue[600]!,
                      () => _editAccount(account),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Bakiye Güncelle',
                      Icons.update,
                      Colors.green[600]!,
                      () => _updateBalance(account),
                    ),
                    if (!account.isPortfolioAccount) ...[
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Para Transferi',
                        Icons.swap_horiz,
                        Colors.orange[600]!,
                        _transferMoney,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Masraf Ekle',
                        Icons.add_circle_outline,
                        Colors.purple[600]!,
                        () => _addExpense(account),
                      ),
                    ],
                    if (!account.isSystemDefaultAccount) ...[
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Hesap Sil',
                        Icons.delete,
                        account.canBeDeleted
                            ? Colors.red[600]!
                            : Colors.grey[400]!,
                        account.canBeDeleted
                            ? () => _deleteAccount(account)
                            : null,
                        enabled: account.canBeDeleted,
                      ),
                      if (!account.canBeDeleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.red[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bu hesapta bakiye veya bloke tutarı bulunduğu için silinemez.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    bool enabled = true,
  }) {
    final accentColor = enabled ? color : Colors.grey[400]!;
    final textColor = enabled ? Colors.grey[800] : Colors.grey[500];
    final arrowColor = enabled ? Colors.grey[400] : Colors.grey[300];
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: arrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editAccount(Account account) async {
    debugPrint('_editAccount - account: ${account.name}');
    debugPrint('_editAccount - account.id: ${account.id}');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAccountPage(existingAccount: account),
      ),
    );

    debugPrint('_editAccount - result: $result');

    // Riverpod provider otomatik olarak güncelleyecek
    if (result == true) {
      debugPrint(
          '_editAccount - Account updated successfully, Riverpod will refresh automatically');
    } else {
      debugPrint('_editAccount - result is not true: $result');
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Paylaş'),
              onTap: () {
                context.pop();
                // Paylaşma işlemi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Paylaşma özelliği yakında eklenecek')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('IBAN Kopyala'),
              onTap: () {
                context.pop();
                // IBAN kopyalama işlemi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('IBAN kopyalandı')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Yazdır'),
              onTap: () {
                context.pop();
                // Yazdırma işlemi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Yazdırma özelliği yakında eklenecek')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewAllTransactions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountTransactionsPage(account: widget.account),
      ),
    );
  }

  void _updateBalance(Account account) {
    showDialog(
      context: context,
      builder: (context) => _BalanceUpdateDialog(
        account: account,
        onBalanceUpdated: () {
          // Bakiye güncellendikten sonra sayfayı yenile
          setState(() {});
        },
      ),
    );
  }

  void _transferMoney() {
    showDialog(
      context: context,
      builder: (context) => _TransferDialog(
        currentAccount: widget.account,
        onTransferCompleted: () {
          // Transfer tamamlandıktan sonra sayfayı yenile
          setState(() {});
        },
      ),
    );
  }

  void _addExpense(Account account) {
    showDialog(
      context: context,
      builder: (context) => _ExpenseDialog(
        account: account,
        onExpenseAdded: () {
          // Masraf eklendikten sonra sayfayı yenile
          setState(() {});
        },
      ),
    );
  }

  void _deleteAccount(Account account) {
    if (!account.canBeDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Bu hesabı silmeden önce bakiyesini sıfırlamanız gerekir.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesap Sil'),
        content: const Text(
            'Bu hesabı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              context.pop(); // Dialog'u kapat
              await _performDeleteAccount(account);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount(Account account) async {
    if (!account.canBeDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Bu hesabı silmeden önce bakiyesini sıfırlamanız gerekir.'),
        ),
      );
      return;
    }

    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await ref
          .read(accountNotifierProvider.notifier)
          .deleteAccount(account.id);

      // Loading'i kapat
      if (mounted) context.pop();

      // Başarı mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesap başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );

        // Ana sayfaya dön
        context.goNamed('accounts-home');
      }
    } catch (e) {
      // Loading'i kapat
      if (mounted) context.pop();

      // Hata mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hesap silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPaymentTransactionItem(PaymentTransaction pt) {
    // Payment transaction için detaylı tile
    final isNegative = pt.direction == PaymentDirection.outgoing;
    
    String typeText = '';
    IconData icon = Icons.payment;
    
    switch (pt.type) {
      case PaymentTransactionType.cash:
        typeText = 'Nakit';
        icon = Icons.money;
        break;
      case PaymentTransactionType.check:
        typeText = 'Çek';
        icon = Icons.check_circle_outline;
        break;
      case PaymentTransactionType.promissoryNote:
        typeText = 'Senet';
        icon = Icons.description;
        break;
      case PaymentTransactionType.eftTransfer:
        typeText = 'Havale/EFT';
        icon = Icons.account_balance;
        break;
      case PaymentTransactionType.creditCard:
        typeText = 'Kredi Kartı';
        icon = Icons.credit_card;
        break;
      case PaymentTransactionType.debtReceipt:
        typeText = 'Borç Fişi';
        icon = Icons.receipt;
        break;
      case PaymentTransactionType.creditReceipt:
        typeText = 'Alacak Fişi';
        icon = Icons.receipt_long;
        break;
      case PaymentTransactionType.accountTransfer:
        typeText = 'Cari Virman';
        icon = Icons.swap_horiz;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isNegative ? Colors.red[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isNegative ? Colors.red[600] : Colors.green[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$typeText - ${pt.direction == PaymentDirection.incoming ? "Tahsilat" : "Ödeme"}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pt.transactionDate.day}/${pt.transactionDate.month}/${pt.transactionDate.year} ${pt.transactionDate.hour}:${pt.transactionDate.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (pt.description != null && pt.description!.isNotEmpty)
                  Text(
                    pt.description!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isNegative ? "-" : "+"}${NumberFormat.currency(
                  locale: 'tr_TR',
                  symbol: pt.currency,
                  decimalDigits: 2,
                ).format(pt.amount.abs())}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? Colors.red[600] : Colors.green[600],
                ),
              ),
              Text(
                pt.status.name.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(AccountTransaction transaction) {
    // Transaction amount'unu doğru şekilde al
    final amount = transaction.amount;
    final isNegative = amount < 0;

    return GestureDetector(
        onTap: () => _showTransactionEditDialog(transaction),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isNegative ? Colors.red[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isNegative ? Colors.red[600] : Colors.green[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year} ${transaction.transactionDate.hour}:${transaction.transactionDate.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isNegative ? '' : '+'}${NumberFormat('#,##0.00', 'tr_TR').format(amount.abs())} ${widget.account.currency}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isNegative ? Colors.red[600] : Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bakiye: ${NumberFormat('#,##0.00', 'tr_TR').format(transaction.balanceAfter)} ${widget.account.currency}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildLoadingTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorTransactions(Object error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'İşlemler yüklenemedi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Transaction Düzenleme Dialog'u
  void _showTransactionEditDialog(AccountTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => _TransactionEditDialog(
        transaction: transaction,
        account: widget.account,
        onTransactionUpdated: () {
          ref.invalidate(transactionsByAccountIdProvider(widget.account.id));
          ref.invalidate(accountsProvider);
        },
      ),
    );
  }
}

/// Masraf Ekleme Dialog'u
class _ExpenseDialog extends ConsumerStatefulWidget {
  final Account account;
  final VoidCallback onExpenseAdded;

  const _ExpenseDialog({
    required this.account,
    required this.onExpenseAdded,
  });

  @override
  ConsumerState<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends ConsumerState<_ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  final _amountFocusNode = FocusNode();

  String _selectedCategory = 'Genel';
  String _selectedCurrency = 'TRY';
  bool _isLoading = false;
  double _convertedAmount = 0.0;

  final List<String> _categories = [
    'Genel',
    'Ofis Malzemeleri',
    'Ulaşım',
    'Yemek',
    'İletişim',
    'Eğitim',
    'Sağlık',
    'Diğer',
  ];

  final List<String> _currencies = ['TRY', 'USD', 'EUR', 'GBP'];

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.account.currency;
    _updateExchangeRate(widget.account);

    // Miktar alanı focus değişikliklerini dinle
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus) {
        // Focus kaybedildiğinde formatla
        _formatAmount(_amountController.text);
        _calculateConvertedAmount();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _exchangeRateController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_circle_outline, color: Colors.purple[600]),
          const SizedBox(width: 8),
          const Text('Masraf Ekle'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Masraf Adı
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Masraf Adı *',
                    hintText: 'Örn: Ofis malzemeleri',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Masraf adı gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategori
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Para Birimi ve Kur
                Row(
                  children: [
                    // Para Birimi
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Para Birimi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        items: _currencies.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                          _updateExchangeRate(widget.account);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Kur Bilgisi (sadece farklı para birimi seçildiğinde)
                    if (_selectedCurrency != widget.account.currency)
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _exchangeRateController,
                          decoration: InputDecoration(
                            labelText: 'Kur',
                            hintText: '29.50',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.swap_horiz),
                            suffixText: widget.account.currency,
                            suffixStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Kur gerekli';
                            }
                            final rate = double.tryParse(value);
                            if (rate == null || rate <= 0) {
                              return 'Geçerli kur girin';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Miktar
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Miktar *',
                          hintText: '1.000,00',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.money_outlined),
                          suffixText: _getCurrencySymbol(_selectedCurrency),
                          suffixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Miktar gerekli';
                          }
                          final cleanValue =
                              value.replaceAll('.', '').replaceAll(',', '.');
                          final amount = double.tryParse(cleanValue);
                          if (amount == null || amount <= 0) {
                            return 'Geçerli bir miktar girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Dönüştürülmüş miktar
                    if (_selectedCurrency != widget.account.currency)
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue[500]!, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.blue[50],
                            prefixIcon: Icon(Icons.swap_horiz,
                                size: 20, color: Colors.blue[600]),
                            suffixText:
                                _getCurrencySymbol(widget.account.currency),
                            suffixStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                          controller: TextEditingController(
                            text: _convertedAmount > 0
                                ? NumberFormat('#,##0.00', 'tr_TR')
                                    .format(_convertedAmount)
                                : '',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Açıklama
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    hintText: 'Masraf hakkında detaylar...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                // Hesap Bilgisi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet,
                              color: Colors.blue[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Masraf Eklenecek Hesap',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildAccountInfoTable(widget.account),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveExpense,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Masraf Ekle'),
        ),
      ],
    );
  }

  Widget _buildAccountInfoTable(Account account) {
    return Column(
      children: [
        _buildInfoRow('Hesap Adı', account.name),
        _buildInfoRow('Banka', account.bankName),
        _buildInfoRow('Hesap No', account.accountNumber),
        _buildInfoRow('Para Birimi', account.currency),
        _buildInfoRow('Hesap Türü', account.type.displayName),
        _buildInfoRow('Mevcut Bakiye',
            '${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateExchangeRate(Account account) async {
    final fromCurrency = account.currency; // Hesap para birimi
    final toCurrency = _selectedCurrency; // Seçilen para birimi

    if (mounted) {
      setState(() {
        if (fromCurrency == toCurrency) {
          _exchangeRateController.clear();
        } else {
          // Loading state
          _exchangeRateController.text = 'Yükleniyor...';
        }
      });
    }

    if (fromCurrency != toCurrency) {
      try {
        final exchangeService = ExchangeRateService();
        final fromRate = await exchangeService.getExchangeRate(fromCurrency);
        final toRate = await exchangeService.getExchangeRate(toCurrency);

        if (fromRate != null && toRate != null && mounted) {
          // TRY'den diğer para birimlerine kur hesaplama
          double rate;
          if (fromCurrency == 'TRY') {
            rate = toRate.rate; // TRY'den diğer para birimlerine
          } else if (toCurrency == 'TRY') {
            rate = 1.0 / fromRate.rate; // Diğer para birimlerinden TRY'ye
          } else {
            // İki yabancı para birimi arasında (TRY üzerinden)
            rate = toRate.rate / fromRate.rate;
          }

          setState(() {
            _exchangeRateController.text = rate.toStringAsFixed(4);
          });
          // Kur güncellendiğinde dönüştürülmüş miktarı yeniden hesapla
          _calculateConvertedAmount();
        } else if (mounted) {
          setState(() {
            _exchangeRateController.text = 'Kur alınamadı';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _exchangeRateController.text = 'Hata: ${e.toString()}';
          });
        }
      }
    }
  }

  // Para birimi sembolü al
  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'TRY':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  // Miktarı Türkçe formatla
  void _formatAmount(String value) {
    if (value.isEmpty) return;

    // Sadece rakam ve virgül içeren değerleri işle
    final cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');
    if (cleanValue.isEmpty) return;

    // Virgülü nokta ile değiştir
    final doubleValue = cleanValue.replaceAll(',', '.');
    final amount = double.tryParse(doubleValue);

    if (amount != null && amount > 0) {
      // Türkçe formatla (1.000,00)
      final formatter = NumberFormat('#,##0.00', 'tr_TR');
      final formatted = formatter.format(amount);

      // Sadece formatlama yap, cursor pozisyonu korunmaz
      _amountController.text = formatted;
    }
  }

  // Dönüştürülmüş miktarı hesapla
  void _calculateConvertedAmount() {
    if (_amountController.text.isEmpty) {
      if (mounted) {
        setState(() {
          _convertedAmount = 0.0;
        });
      }
      return;
    }

    try {
      // Miktarı temizle ve parse et
      final cleanValue =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.tryParse(cleanValue);

      if (amount == null || amount <= 0) {
        if (mounted) {
          setState(() {
            _convertedAmount = 0.0;
          });
        }
        return;
      }

      // Kur bilgisini al
      final exchangeRateText = _exchangeRateController.text;
      if (exchangeRateText.isEmpty ||
          exchangeRateText == 'Yükleniyor...' ||
          exchangeRateText.contains('Hata')) {
        if (mounted) {
          setState(() {
            _convertedAmount = 0.0;
          });
        }
        return;
      }

      final exchangeRate = double.tryParse(exchangeRateText);
      if (exchangeRate == null || exchangeRate <= 0) {
        if (mounted) {
          setState(() {
            _convertedAmount = 0.0;
          });
        }
        return;
      }

      // Dönüştürülmüş miktarı hesapla
      final converted = amount * exchangeRate;

      if (mounted) {
        setState(() {
          _convertedAmount = converted;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _convertedAmount = 0.0;
        });
      }
    }
  }

  /// Hesap hareketlerinden bakiye hesapla
  double _calculateBalanceFromTransactions(
      List<AccountTransaction> transactions) {
    double balance = 0.0;

    // İşlemleri tarih sırasına göre sırala (en eski önce)
    final sortedTransactions = List<AccountTransaction>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    for (final transaction in sortedTransactions) {
      balance += transaction.amount;
    }

    return balance;
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Miktarı parse et
      final cleanValue =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.tryParse(cleanValue);
      if (amount == null) {
        throw Exception('Geçersiz miktar');
      }

      // Firebase'den tenantId ve userId'yi al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Kullanıcı bilgileri bulunamadı');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String? ?? '';

      // Hesap hareketlerinden güncel bakiyeyi hesapla
      final transactionsAsync =
          ref.read(transactionsByAccountIdProvider(widget.account.id));
      double currentBalance = widget.account.balance;

      transactionsAsync.whenData((transactions) {
        currentBalance = _calculateBalanceFromTransactions(transactions);
      });

      // Masraf transaction'ı oluştur (negatif miktar)
      final expenseAmount = -amount; // Masraf negatif olarak kaydedilir
      final newBalance = currentBalance + expenseAmount;

      final transaction = AccountTransaction(
        id: '',
        accountId: widget.account.id,
        tenantId: tenantId,
        type: TransactionType.withdrawal,
        amount: expenseAmount,
        balanceAfter: newBalance,
        description: '${_nameController.text} - ${_descriptionController.text}',
        category: TransactionCategory.expense,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: user.uid,
        updatedBy: user.uid,
        userId: user.uid,
      );

      // Transaction'ı kaydet
      await ref
          .read(accountTransactionNotifierProvider.notifier)
          .createTransaction(transaction);

      // Hesap bakiyesini güncelle
      await ref
          .read(accountNotifierProvider.notifier)
          .updateAccountBalance(widget.account.id, newBalance);

      // Provider'ları refresh et
      ref.invalidate(accountsProvider);
      ref.invalidate(transactionsByAccountIdProvider(widget.account.id));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Masraf başarıyla eklendi: ${_nameController.text}'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onExpenseAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Masraf eklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Bakiye Güncelleme Dialog'u
class _BalanceUpdateDialog extends ConsumerStatefulWidget {
  final Account account;
  final VoidCallback onBalanceUpdated;

  const _BalanceUpdateDialog({
    required this.account,
    required this.onBalanceUpdated,
  });

  @override
  ConsumerState<_BalanceUpdateDialog> createState() =>
      _BalanceUpdateDialogState();
}

class _BalanceUpdateDialogState extends ConsumerState<_BalanceUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();

  BalanceUpdateType _updateType = BalanceUpdateType.setDirect;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.account.balance.toString();
    _descriptionController.text = 'Bakiye düzeltme'; // Başlangıç açıklaması

    // Miktar alanı focus değişikliklerini dinle
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus) {
        _formatAmount();
      }
    });

    // Miktar değişikliklerini dinle - Sonuç Önizleme için
    _amountController.addListener(() {
      setState(() {
        // Sonuç önizleme güncellensin
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.update, color: Colors.green[600]),
          const SizedBox(width: 8),
          Text(
            'Bakiye Güncelle',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hesap Bilgileri
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hesap: ${widget.account.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mevcut Bakiye: ${NumberFormat('#,##0.00', 'tr_TR').format(widget.account.balance)} ${widget.account.currency}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Güncelleme Türü
              Text(
                'Güncelleme Türü',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<BalanceUpdateType>(
                segments: [
                  ButtonSegment<BalanceUpdateType>(
                    value: BalanceUpdateType.setDirect,
                    label: SizedBox(
                      width: 90,
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Doğrudan',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Gir',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    tooltip: 'Yeni bakiye',
                  ),
                  ButtonSegment<BalanceUpdateType>(
                    value: BalanceUpdateType.add,
                    label: SizedBox(
                      width: 90,
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Para',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Ekle',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    tooltip: 'Mevcut + ekle',
                  ),
                  ButtonSegment<BalanceUpdateType>(
                    value: BalanceUpdateType.subtract,
                    label: SizedBox(
                      width: 90,
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Para',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Çıkar',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    tooltip: 'Mevcut - çıkar',
                  ),
                ],
                selected: {_updateType},
                onSelectionChanged: (Set<BalanceUpdateType> newSelection) {
                  setState(() {
                    _updateType = newSelection.first;
                    _updateAmountController();
                  });
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  ),
                  textStyle: WidgetStateProperty.all(
                    GoogleFonts.poppins(fontSize: 10),
                  ),
                  minimumSize: WidgetStateProperty.all(const Size(90, 50)),
                  maximumSize: WidgetStateProperty.all(const Size(90, 50)),
                ),
              ),
              const SizedBox(height: 20),

              // Miktar Girişi
              Text(
                _getAmountLabel(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: widget.account.currency,
                  suffixStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Miktar giriniz';
                  }
                  // Formatlanmış değeri parse etmek için virgülü noktaya çevir
                  final cleanValue =
                      value.replaceAll('.', '').replaceAll(',', '.');
                  final amount = double.tryParse(cleanValue);
                  if (amount == null) {
                    return 'Geçerli bir miktar giriniz';
                  }
                  if (amount < 0) {
                    return 'Miktar negatif olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Açıklama Alanı
              Text(
                'Açıklama (Opsiyonel)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: _getDescriptionHint(),
                  prefixIcon: const Icon(Icons.description),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Sonuç Önizleme
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sonuç Önizleme',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPreviewText(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'İptal',
            style: GoogleFonts.poppins(),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateBalance,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Güncelle',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  String _getAmountLabel() {
    switch (_updateType) {
      case BalanceUpdateType.setDirect:
        return 'Yeni Bakiye';
      case BalanceUpdateType.add:
        return 'Eklenecek Miktar';
      case BalanceUpdateType.subtract:
        return 'Çıkarılacak Miktar';
    }
  }

  String _getDescriptionHint() {
    switch (_updateType) {
      case BalanceUpdateType.setDirect:
        return 'Bakiye düzeltme açıklaması...';
      case BalanceUpdateType.add:
        return 'Para girişi açıklaması...';
      case BalanceUpdateType.subtract:
        return 'Para çıkışı açıklaması...';
    }
  }

  /// Hesap hareketlerinden bakiye hesapla
  double _calculateBalanceFromTransactions(
      List<AccountTransaction> transactions) {
    double balance = 0.0;

    // İşlemleri tarih sırasına göre sırala (en eski önce)
    final sortedTransactions = List<AccountTransaction>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    for (final transaction in sortedTransactions) {
      balance += transaction.amount;
    }

    return balance;
  }

  String _getPreviewText() {
    // Formatlanmış değeri parse etmek için virgülü noktaya çevir
    final cleanValue =
        _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(cleanValue);

    // Hesap hareketlerinden güncel bakiyeyi al
    final transactionsAsync =
        ref.read(transactionsByAccountIdProvider(widget.account.id));
    double currentBalance = widget.account.balance;

    transactionsAsync.whenData((transactions) {
      currentBalance = _calculateBalanceFromTransactions(transactions);
    });

    if (amount == null) {
      // Miktar girilmemişse sadece mevcut bakiyeyi göster
      return 'Mevcut bakiye: ${NumberFormat('#,##0.00', 'tr_TR').format(currentBalance)} ${widget.account.currency}';
    }

    switch (_updateType) {
      case BalanceUpdateType.setDirect:
        return 'Yeni bakiye: ${NumberFormat('#,##0.00', 'tr_TR').format(amount)} ${widget.account.currency}';
      case BalanceUpdateType.add:
        final newBalance = currentBalance + amount;
        return 'Mevcut: ${NumberFormat('#,##0.00', 'tr_TR').format(currentBalance)} + ${NumberFormat('#,##0.00', 'tr_TR').format(amount)} = ${NumberFormat('#,##0.00', 'tr_TR').format(newBalance)} ${widget.account.currency}';
      case BalanceUpdateType.subtract:
        final newBalance = currentBalance - amount;
        return 'Mevcut: ${NumberFormat('#,##0.00', 'tr_TR').format(currentBalance)} - ${NumberFormat('#,##0.00', 'tr_TR').format(amount)} = ${NumberFormat('#,##0.00', 'tr_TR').format(newBalance)} ${widget.account.currency}';
    }
  }

  void _updateAmountController() {
    // Hesap hareketlerinden güncel bakiyeyi al
    final transactionsAsync =
        ref.read(transactionsByAccountIdProvider(widget.account.id));
    double currentBalance = widget.account.balance;

    transactionsAsync.whenData((transactions) {
      currentBalance = _calculateBalanceFromTransactions(transactions);
    });

    switch (_updateType) {
      case BalanceUpdateType.setDirect:
        _amountController.text = currentBalance.toString();
        _descriptionController.text = 'Bakiye düzeltme';
        break;
      case BalanceUpdateType.add:
        _amountController.clear();
        _descriptionController.text = 'Para girişi';
        break;
      case BalanceUpdateType.subtract:
        _amountController.clear();
        _descriptionController.text = 'Para çıkışı';
        break;
    }
  }

  void _formatAmount() {
    final text = _amountController.text;
    if (text.isNotEmpty) {
      // Formatlanmış değeri parse etmek için virgülü noktaya çevir
      final cleanValue = text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.tryParse(cleanValue);
      if (amount != null) {
        _amountController.text =
            NumberFormat('#,##0.00', 'tr_TR').format(amount);
      }
    }
  }

  Future<void> _updateBalance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Formatlanmış değeri parse etmek için virgülü noktaya çevir
      final cleanValue =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.parse(cleanValue);
      double newBalance;

      switch (_updateType) {
        case BalanceUpdateType.setDirect:
          newBalance = amount;
          break;
        case BalanceUpdateType.add:
          newBalance = widget.account.balance + amount;
          break;
        case BalanceUpdateType.subtract:
          newBalance = widget.account.balance - amount;
          break;
      }

      // Firebase'e güncelle
      await ref.read(accountNotifierProvider.notifier).updateAccountBalance(
            widget.account.id,
            newBalance,
          );

      // Transaction oluştur
      try {
        final description = _descriptionController.text.trim();

        // Transaction'da gösterilecek miktar: bakiye değişikliği
        double transactionAmount;
        switch (_updateType) {
          case BalanceUpdateType.setDirect:
            transactionAmount =
                newBalance - widget.account.balance; // Bakiye farkı
            break;
          case BalanceUpdateType.add:
            transactionAmount = amount; // Eklenen miktar
            break;
          case BalanceUpdateType.subtract:
            transactionAmount = -amount; // Çıkarılan miktar (negatif)
            break;
        }

        debugPrint('=== TRANSACTION DEBUG ===');
        debugPrint('Update Type: $_updateType');
        debugPrint('Old Balance: ${widget.account.balance}');
        debugPrint('New Balance: $newBalance');
        debugPrint('Amount: $amount');
        debugPrint('Transaction Amount: $transactionAmount');
        debugPrint('Description: $description');

        // Firebase'den tenantId ve userId'yi al
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            final tenantId = userData['tenantId'] as String? ?? '';

            // Transaction type'ını güncelleme türüne göre belirle
            TransactionType transactionType;
            switch (_updateType) {
              case BalanceUpdateType.setDirect:
                transactionType = TransactionType.adjustment; // Düzeltme
                break;
              case BalanceUpdateType.add:
                transactionType = TransactionType.deposit; // Giriş
                break;
              case BalanceUpdateType.subtract:
                transactionType = TransactionType.withdrawal; // Çıkış
                break;
            }

            final transaction = AccountTransaction(
              id: '',
              accountId: widget.account.id,
              tenantId: tenantId,
              type: transactionType,
              amount: transactionAmount,
              balanceAfter: newBalance,
              description: description,
              category: TransactionCategory.other,
              transactionDate: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              createdBy: user.uid,
              updatedBy: user.uid,
              userId: user.uid,
            );

            debugPrint(
                'Transaction created with amount: ${transaction.amount}');

            await ref
                .read(accountTransactionNotifierProvider.notifier)
                .createTransaction(transaction);
            debugPrint(
                'Balance transaction created: $description - Amount: $transactionAmount');
          }
        }
      } catch (e) {
        debugPrint('Error creating transaction: $e');
      }

      // Provider'ı refresh et
      ref.invalidate(accountsProvider);
      ref.invalidate(transactionsByAccountIdProvider(widget.account.id));

      if (mounted) {
        Navigator.pop(context);
        widget.onBalanceUpdated();

        // Açıklama varsa göster
        final description = _descriptionController.text.trim();
        final message = description.isNotEmpty
            ? 'Bakiye güncellendi: ${NumberFormat('#,##0.00', 'tr_TR').format(newBalance)} ${widget.account.currency}\nAçıklama: $description'
            : 'Bakiye başarıyla güncellendi: ${NumberFormat('#,##0.00', 'tr_TR').format(newBalance)} ${widget.account.currency}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bakiye güncellenemedi: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Transaction Düzenleme Dialog'u
class _TransactionEditDialog extends ConsumerStatefulWidget {
  final AccountTransaction transaction;
  final Account account;
  final VoidCallback onTransactionUpdated;

  const _TransactionEditDialog({
    required this.transaction,
    required this.account,
    required this.onTransactionUpdated,
  });

  @override
  ConsumerState<_TransactionEditDialog> createState() =>
      _TransactionEditDialogState();
}

class _TransactionEditDialogState
    extends ConsumerState<_TransactionEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _descriptionController.text = widget.transaction.description;
    _amountController.text = NumberFormat('#,##0.00', 'tr_TR')
        .format(widget.transaction.amount.abs());
    _selectedDate = widget.transaction.transactionDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.transaction.transactionDate);
    _updateDateTimeControllers();
  }

  void _updateDateTimeControllers() {
    _dateController.text =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    _timeController.text =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            'İşlem Düzenle',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Açıklama
              Text(
                'Açıklama',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'İşlem açıklaması...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Miktar
              Text(
                'Miktar',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: widget.account.currency,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Miktar gerekli';
                  }
                  final cleanValue =
                      value.replaceAll('.', '').replaceAll(',', '.');
                  final amount = double.tryParse(cleanValue);
                  if (amount == null) {
                    return 'Geçerli bir miktar girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tarih ve Saat
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tarih',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText: 'GG/AA/YYYY',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: _selectDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saat',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _timeController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText: 'SS:DD',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          onTap: _selectTime,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bakiye Bilgisi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mevcut Bakiye',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,##0.00', 'tr_TR').format(widget.transaction.balanceAfter)} ${widget.account.currency}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Silme Butonu
        TextButton.icon(
          onPressed: _isLoading ? null : _deleteTransaction,
          icon: Icon(Icons.delete, color: Colors.red[600]),
          label: Text(
            'Sil',
            style: GoogleFonts.poppins(color: Colors.red[600]),
          ),
        ),
        const SizedBox(width: 16),
        // İptal Butonu
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'İptal',
            style: GoogleFonts.poppins(),
          ),
        ),
        // Kaydet Butonu
        ElevatedButton(
          onPressed: _isLoading ? null : _updateTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Kaydet',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDateTimeControllers();
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _updateDateTimeControllers();
      });
    }
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cleanValue =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.parse(cleanValue);

      // Orijinal amount'un işaretini koru
      final finalAmount = widget.transaction.amount < 0 ? -amount : amount;

      final transactionDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final updatedTransaction = widget.transaction.copyWith(
        description: _descriptionController.text.trim(),
        amount: finalAmount,
        transactionDate: transactionDate,
        updatedAt: DateTime.now(),
        updatedBy: FirebaseAuth.instance.currentUser?.uid ?? 'system',
      );

      await ref
          .read(accountTransactionNotifierProvider.notifier)
          .updateTransaction(updatedTransaction);

      if (mounted) {
        Navigator.pop(context);
        widget.onTransactionUpdated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'İşlem başarıyla güncellendi',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green[600],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'İşlem güncellenemedi: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'İşlemi Sil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bu işlemi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(accountTransactionNotifierProvider.notifier)
            .deleteTransaction(widget.transaction.id);

        if (mounted) {
          Navigator.pop(context);
          widget.onTransactionUpdated();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'İşlem başarıyla silindi',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green[600],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'İşlem silinemedi: $e',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}

/// Bakiye Güncelleme Türleri
enum BalanceUpdateType {
  setDirect, // Doğrudan gir
  add, // Para ekle
  subtract, // Para çıkar
}

/// Para Transferi Dialog'u
class _TransferDialog extends ConsumerStatefulWidget {
  final Account currentAccount;
  final VoidCallback onTransferCompleted;

  const _TransferDialog({
    required this.currentAccount,
    required this.onTransferCompleted,
  });

  @override
  ConsumerState<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<_TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();

  TransferType _transferType = TransferType.send;
  Account? _selectedAccount;
  bool _isLoading = false;

  // Kur bilgileri
  final _exchangeRateController = TextEditingController();
  double _convertedAmount = 0.0;
  bool _isLoadingExchangeRate = false;
  bool _isAutoExchangeRate = true; // Otomatik kur çekildi mi?

  @override
  void initState() {
    super.initState();
    _descriptionController.text = 'Para transferi';

    // Miktar alanı focus değişikliklerini dinle
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus) {
        _formatAmount();
      }
    });

    // Miktar değişikliklerini dinle (kur hesaplama için)
    _amountController.addListener(() {
      debugPrint('Amount changed: ${_amountController.text}');
      _calculateConvertedAmount();
    });

    // Kur değişikliklerini dinle (dönüştürme için)
    _exchangeRateController.addListener(() {
      debugPrint('Exchange rate changed: ${_exchangeRateController.text}');
      _calculateConvertedAmount();
      // Kullanıcı manuel kur girerse TCMB etiketini gizle
      if (_exchangeRateController.text.isNotEmpty &&
          !_exchangeRateController.text.contains('TCMB') &&
          !_exchangeRateController.text.contains('Yükleniyor') &&
          !_exchangeRateController.text.contains('Hata')) {
        setState(() {
          _isAutoExchangeRate = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.swap_horiz, color: Colors.orange[600]),
          const SizedBox(width: 8),
          const Text('Para Transferi'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Transfer Türü Seçimi
                Text(
                  'Transfer Türü',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<TransferType>(
                      segments: [
                        ButtonSegment<TransferType>(
                          value: TransferType.send,
                          label: Text(
                            'Gönder',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          tooltip: 'Bu hesaptan başka hesaba para gönder',
                        ),
                        ButtonSegment<TransferType>(
                          value: TransferType.receive,
                          label: Text(
                            'Al',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          tooltip: 'Başka hesaptan bu hesaba para al',
                        ),
                      ],
                      selected: {_transferType},
                      onSelectionChanged: (Set<TransferType> newSelection) {
                        setState(() {
                          _transferType = newSelection.first;
                          _selectedAccount = null; // Hesap seçimini sıfırla
                        });
                        // Kur bilgisini güncelle
                        _updateExchangeRate();
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                        ),
                        textStyle: WidgetStateProperty.all(
                          GoogleFonts.poppins(fontSize: 12),
                        ),
                        minimumSize: WidgetStateProperty.all(const Size(0, 40)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Hesap Seçimi
                Text(
                  _transferType == TransferType.send
                      ? 'Hedef Hesap'
                      : 'Kaynak Hesap',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                accountsAsync.when(
                  data: (accounts) {
                    // Mevcut hesabı listeden çıkar ve transfer edilemeyen hesapları filtrele
                    final otherAccounts = accounts
                        .where((account) =>
                            account.id != widget.currentAccount.id &&
                            _isTransferableAccount(account))
                        .toList();

                    if (otherAccounts.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Transfer edilebilecek başka hesap bulunmuyor\n(Senet/Çek/Pos hesapları transfer edilemez)',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Account>(
                          value: _selectedAccount,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Icon(Icons.account_balance,
                                    color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  _transferType == TransferType.send
                                      ? 'Hedef hesabı seçin'
                                      : 'Kaynak hesabı seçin',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          items: otherAccounts.map((account) {
                            return DropdownMenuItem<Account>(
                              value: account,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getAccountIcon(account.type),
                                      size: 20,
                                      color: Colors.blue[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            account.name,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)} ${account.currency}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Account? account) {
                            setState(() {
                              _selectedAccount = account;
                            });
                            // Kur bilgisini güncelle
                            _updateExchangeRate();
                          },
                          isExpanded: true,
                        ),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Text('Hesap listesi yüklenemedi: $error'),
                ),
                const SizedBox(height: 16),

                // Miktar Girişi
                Text(
                  'Transfer Miktarı',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0,00',
                    prefixIcon: Icon(_transferType == TransferType.send
                        ? Icons.arrow_upward
                        : Icons.arrow_downward),
                    suffixText: _transferType == TransferType.send
                        ? widget.currentAccount.currency
                        : (_selectedAccount?.currency ?? ''),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Miktar gerekli';
                    }
                    final cleanValue =
                        value.replaceAll('.', '').replaceAll(',', '.');
                    final amount = double.tryParse(cleanValue);
                    if (amount == null || amount <= 0) {
                      return 'Geçerli bir miktar girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kur Bilgisi (farklı para birimlerinde)
                if (_selectedAccount != null &&
                    _selectedAccount!.currency !=
                        widget.currentAccount.currency)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Kur Bilgisi',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // TCMB Kur etiketi sadece otomatik kur çekildiğinde göster
                            if (_isAutoExchangeRate)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green[300]!),
                                ),
                                child: Text(
                                  'TCMB Kur',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (_isLoadingExchangeRate) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue[600]!),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Kur alanı
                        TextFormField(
                          controller: _exchangeRateController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Kuru Gerekli',
                            labelText: 'Döviz Kuru',
                            helperText: _convertedAmount > 0
                                ? '${NumberFormat('#,##0.00', 'tr_TR').format(_convertedAmount)} ${_transferType == TransferType.send ? _selectedAccount?.currency : widget.currentAccount.currency}'
                                : 'TCMB\'den otomatik çekilir',
                            helperStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _convertedAmount > 0
                                  ? Colors.blue[700]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(Icons.swap_horiz),
                            suffixText: widget.currentAccount.currency,
                            border: const OutlineInputBorder(),
                            suffixStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Kur gerekli';
                            }
                            final rate = double.tryParse(value);
                            if (rate == null || rate <= 0) {
                              return 'Geçerli kur girin';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Açıklama
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Açıklama',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama',
                          hintText: 'Transfer açıklaması...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Transfer Önizleme
                if (_selectedAccount != null &&
                    _amountController.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Önizleme',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTransferPreview(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.orange[700],
                          ),
                        ),
                        // Para birimi uyarısı
                        if (_selectedAccount != null)
                          Builder(
                            builder: (context) {
                              final currencyWarning =
                                  _getCurrencyConversionWarning(
                                _transferType == TransferType.send
                                    ? widget.currentAccount
                                    : _selectedAccount!,
                                _transferType == TransferType.send
                                    ? _selectedAccount!
                                    : widget.currentAccount,
                              );
                              if (currencyWarning != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(4),
                                      border:
                                          Border.all(color: Colors.red[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning,
                                            color: Colors.red[600], size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            currencyWarning,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _executeTransfer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Transfer Et'),
        ),
      ],
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Icons.account_balance;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.credit:
        return Icons.account_balance_wallet;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.cash:
        return Icons.payments;
      case AccountType.foreign:
        return Icons.public;
      case AccountType.other:
        return Icons.category;
    }
  }

  String _getTransferPreview() {
    final cleanValue =
        _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(cleanValue);
    if (amount == null) return '';

    if (_transferType == TransferType.send) {
      // Gönder: Bu hesaptan başka hesaba
      // Miktar bu hesabın para biriminde giriliyor
      if (_convertedAmount > 0) {
        // Dönüştürülen miktar varsa onu göster
        return '${widget.currentAccount.name} → ${_selectedAccount?.name}\n'
            '${NumberFormat('#,##0.00', 'tr_TR').format(amount)} ${widget.currentAccount.currency} = '
            '${NumberFormat('#,##0.00', 'tr_TR').format(_convertedAmount)} ${_selectedAccount?.currency}';
      } else {
        return '${widget.currentAccount.name} → ${_selectedAccount?.name}\n'
            '${NumberFormat('#,##0.00', 'tr_TR').format(amount)} ${widget.currentAccount.currency}';
      }
    } else {
      // Al: Başka hesaptan bu hesaba
      // Miktar kaynak hesabın para biriminde giriliyor
      if (_convertedAmount > 0) {
        // Dönüştürülen miktar varsa onu göster
        return '${_selectedAccount?.name} → ${widget.currentAccount.name}\n'
            '${NumberFormat('#,##0.00', 'tr_TR').format(amount)} ${_selectedAccount?.currency ?? ''} = '
            '${NumberFormat('#,##0.00', 'tr_TR').format(_convertedAmount)} ${widget.currentAccount.currency}';
      } else {
        return '${_selectedAccount?.name} → ${widget.currentAccount.name}\n'
            '${NumberFormat('#,##0.00', 'tr_TR').format(amount)} ${_selectedAccount?.currency ?? ''}';
      }
    }
  }

  void _formatAmount() {
    final text = _amountController.text;
    if (text.isNotEmpty) {
      final cleanValue = text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.tryParse(cleanValue);
      if (amount != null) {
        _amountController.text =
            NumberFormat('#,##0.00', 'tr_TR').format(amount);
      }
    }
  }

  Future<void> _executeTransfer() async {
    debugPrint('Transfer başlatılıyor...');

    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validasyonu başarısız');
      return;
    }

    if (_selectedAccount == null) {
      debugPrint('Hesap seçilmedi');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir hesap seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('Seçilen hesap: ${_selectedAccount!.name}');
    debugPrint('Transfer türü: $_transferType');

    // Transfer validasyonları
    if (!_isTransferableAccount(widget.currentAccount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${widget.currentAccount.name} hesabına transfer yapılamaz (Senet/Çek/Pos hesabı)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isTransferableAccount(_selectedAccount!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_selectedAccount!.name} hesabına transfer yapılamaz (Senet/Çek/Pos hesabı)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Para birimi uyarısı
    final currencyWarning = _getCurrencyConversionWarning(
      _transferType == TransferType.send
          ? widget.currentAccount
          : _selectedAccount!,
      _transferType == TransferType.send
          ? _selectedAccount!
          : widget.currentAccount,
    );

    if (currencyWarning != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currencyWarning),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Miktarı parse et
      final cleanValue =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.tryParse(cleanValue);
      if (amount == null) {
        throw Exception('Geçersiz miktar');
      }

      // Firebase'den tenantId ve userId'yi al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Kullanıcı bilgileri bulunamadı');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final tenantId = userData['tenantId'] as String? ?? '';

      // Hesap hareketlerinden güncel bakiyeleri hesapla
      final currentAccountTransactionsAsync =
          ref.read(transactionsByAccountIdProvider(widget.currentAccount.id));
      final selectedAccountTransactionsAsync =
          ref.read(transactionsByAccountIdProvider(_selectedAccount!.id));

      double currentAccountBalance = widget.currentAccount.balance;
      double selectedAccountBalance = _selectedAccount!.balance;

      // AsyncValue'dan veriyi al
      if (currentAccountTransactionsAsync.hasValue) {
        currentAccountBalance = _calculateBalanceFromTransactions(
            currentAccountTransactionsAsync.value!);
      }

      if (selectedAccountTransactionsAsync.hasValue) {
        selectedAccountBalance = _calculateBalanceFromTransactions(
            selectedAccountTransactionsAsync.value!);
      }

      if (_transferType == TransferType.send) {
        // Bu hesaptan başka hesaba gönder
        // Girilen miktar bu hesabın para biriminde
        // Hedef hesaba dönüştürülen miktar eklenmeli

        double amountToDeduct = amount; // Bu hesaptan çıkarılacak miktar
        double amountToAdd = _convertedAmount > 0
            ? _convertedAmount
            : amount; // Hedef hesaba eklenecek miktar

        final currentAccountNewBalance = currentAccountBalance - amountToDeduct;
        final selectedAccountNewBalance = selectedAccountBalance + amountToAdd;

        // Bu hesap için transaction (çıkış)
        final currentAccountTransaction = AccountTransaction(
          id: '',
          accountId: widget.currentAccount.id,
          tenantId: tenantId,
          type: TransactionType.transfer,
          amount: -amountToDeduct,
          balanceAfter: currentAccountNewBalance,
          description:
              '${_descriptionController.text} → ${_selectedAccount!.name}',
          category: TransactionCategory.bank,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: user.uid,
          updatedBy: user.uid,
          userId: user.uid,
        );

        // Hedef hesap için transaction (giriş)
        final selectedAccountTransaction = AccountTransaction(
          id: '',
          accountId: _selectedAccount!.id,
          tenantId: tenantId,
          type: TransactionType.transfer,
          amount: amountToAdd,
          balanceAfter: selectedAccountNewBalance,
          description:
              '${_descriptionController.text} ← ${widget.currentAccount.name}',
          category: TransactionCategory.bank,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: user.uid,
          updatedBy: user.uid,
          userId: user.uid,
        );

        // Transaction'ları kaydet
        debugPrint(
            'Transaction oluşturuluyor - Mevcut hesap: -$amountToDeduct ${widget.currentAccount.currency}');
        await ref
            .read(accountTransactionNotifierProvider.notifier)
            .createTransaction(currentAccountTransaction);

        debugPrint(
            'Transaction oluşturuluyor - Hedef hesap: +$amountToAdd ${_selectedAccount!.currency}');
        await ref
            .read(accountTransactionNotifierProvider.notifier)
            .createTransaction(selectedAccountTransaction);

        // Hesap bakiyelerini güncelle
        await ref.read(accountNotifierProvider.notifier).updateAccountBalance(
            widget.currentAccount.id, currentAccountNewBalance);

        await ref.read(accountNotifierProvider.notifier).updateAccountBalance(
            _selectedAccount!.id, selectedAccountNewBalance);
      } else {
        // Başka hesaptan bu hesaba al
        // Girilen miktar kaynak hesabın para biriminde
        // Bu hesaba dönüştürülen miktar eklenmeli

        double amountToDeduct = amount; // Kaynak hesaptan çıkarılacak miktar
        double amountToAdd = _convertedAmount > 0
            ? _convertedAmount
            : amount; // Bu hesaba eklenecek miktar

        final currentAccountNewBalance = currentAccountBalance + amountToAdd;
        final selectedAccountNewBalance =
            selectedAccountBalance - amountToDeduct;

        // Kaynak hesap için transaction (çıkış)
        final selectedAccountTransaction = AccountTransaction(
          id: '',
          accountId: _selectedAccount!.id,
          tenantId: tenantId,
          type: TransactionType.transfer,
          amount: -amountToDeduct,
          balanceAfter: selectedAccountNewBalance,
          description:
              '${_descriptionController.text} → ${widget.currentAccount.name}',
          category: TransactionCategory.bank,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: user.uid,
          updatedBy: user.uid,
          userId: user.uid,
        );

        // Bu hesap için transaction (giriş)
        final currentAccountTransaction = AccountTransaction(
          id: '',
          accountId: widget.currentAccount.id,
          tenantId: tenantId,
          type: TransactionType.transfer,
          amount: amountToAdd,
          balanceAfter: currentAccountNewBalance,
          description:
              '${_descriptionController.text} ← ${_selectedAccount!.name}',
          category: TransactionCategory.bank,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: user.uid,
          updatedBy: user.uid,
          userId: user.uid,
        );

        // Transaction'ları kaydet
        debugPrint(
            'Transaction oluşturuluyor - Kaynak hesap: -$amountToDeduct ${_selectedAccount!.currency}');
        await ref
            .read(accountTransactionNotifierProvider.notifier)
            .createTransaction(selectedAccountTransaction);

        debugPrint(
            'Transaction oluşturuluyor - Mevcut hesap: +$amountToAdd ${widget.currentAccount.currency}');
        await ref
            .read(accountTransactionNotifierProvider.notifier)
            .createTransaction(currentAccountTransaction);

        // Hesap bakiyelerini güncelle
        await ref.read(accountNotifierProvider.notifier).updateAccountBalance(
            _selectedAccount!.id, selectedAccountNewBalance);

        await ref.read(accountNotifierProvider.notifier).updateAccountBalance(
            widget.currentAccount.id, currentAccountNewBalance);
      }

      // Provider'ları refresh et
      ref.invalidate(accountsProvider);
      ref.invalidate(transactionsByAccountIdProvider(widget.currentAccount.id));
      ref.invalidate(transactionsByAccountIdProvider(_selectedAccount!.id));

      debugPrint('Transfer başarıyla tamamlandı');
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Transfer başarıyla tamamlandı: ${NumberFormat('#,##0.00', 'tr_TR').format(amount)} ${widget.currentAccount.currency}'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onTransferCompleted();
      }
    } catch (e) {
      debugPrint('Transfer hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer sırasında hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Hesap hareketlerinden bakiye hesapla
  double _calculateBalanceFromTransactions(
      List<AccountTransaction> transactions) {
    double balance = 0.0;

    // İşlemleri tarih sırasına göre sırala (en eski önce)
    final sortedTransactions = List<AccountTransaction>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    for (final transaction in sortedTransactions) {
      balance += transaction.amount;
    }

    return balance;
  }

  /// Transfer edilemeyen hesap türlerini kontrol et
  bool _isTransferableAccount(Account account) {
    // Senet, Çek ve Pos hesaplarına transfer yapılamaz
    // Bu hesaplar muhtemelen "other" türünde veya özel isimlerle tanımlanmış
    final nonTransferableTypes = [
      'senet',
      'çek',
      'pos',
      'promissory',
      'check',
      'pos'
    ];
    final accountNameLower = account.name.toLowerCase();
    final accountTypeLower = account.type.name.toLowerCase();

    // Hesap türü kontrolü
    if (nonTransferableTypes.contains(accountTypeLower)) {
      return false;
    }

    // Hesap adı kontrolü (senet, çek, pos içeren hesaplar)
    for (final type in nonTransferableTypes) {
      if (accountNameLower.contains(type)) {
        return false;
      }
    }

    return true;
  }

  /// Para birimi farklılığında döviz dönüşümü uyarısı
  String? _getCurrencyConversionWarning(
      Account fromAccount, Account toAccount) {
    if (fromAccount.currency != toAccount.currency) {
      return 'Dikkat: ${fromAccount.currency} → ${toAccount.currency} transferi yapıyorsunuz. '
          'Döviz dönüşümü gerekebilir. Güncel kur oranlarını kontrol edin.';
    }
    return null;
  }

  /// Kur bilgisini güncelle
  void _updateExchangeRate() async {
    if (_selectedAccount == null) return;

    final fromAccount = _transferType == TransferType.send
        ? widget.currentAccount
        : _selectedAccount!;
    final toAccount = _transferType == TransferType.send
        ? _selectedAccount!
        : widget.currentAccount;

    final fromCurrency = fromAccount.currency;
    final toCurrency = toAccount.currency;

    if (fromCurrency == toCurrency) {
      setState(() {
        _exchangeRateController.clear();
        _convertedAmount = 0.0;
        _isLoadingExchangeRate = false;
      });
      return;
    }

    setState(() {
      _isLoadingExchangeRate = true;
      _exchangeRateController.text = 'TCMB\'den kur çekiliyor...';
    });

    try {
      final exchangeService = ExchangeRateService();
      final fromRate = await exchangeService.getExchangeRate(fromCurrency);
      final toRate = await exchangeService.getExchangeRate(toCurrency);

      if (fromRate != null && toRate != null && mounted) {
        // Transfer türüne göre kur yönü hesapla
        double rate;
        debugPrint('Transfer type: $_transferType');
        debugPrint('From currency: $fromCurrency, To currency: $toCurrency');
        debugPrint('From rate: ${fromRate.rate}, To rate: ${toRate.rate}');

        // Doğru kur hesaplama mantığı
        if (fromCurrency == 'TRY') {
          // TRY'den diğer para birimlerine: 1 TRY = 1/kur EUR
          // Örnek: 1 EUR = 33.20 TRY ise, 1 TRY = 1/33.20 EUR
          rate = 1.0 / toRate.rate;
          debugPrint(
              'TRY to $toCurrency: 1 TRY = ${1.0 / toRate.rate} $toCurrency');
        } else if (toCurrency == 'TRY') {
          // Diğer para birimlerinden TRY'ye: 1 EUR = kur TRY
          // Örnek: 1 EUR = 33.20 TRY
          rate = fromRate.rate;
          debugPrint(
              '$fromCurrency to TRY: 1 $fromCurrency = ${fromRate.rate} TRY');
        } else {
          // İki yabancı para birimi arasında (TRY üzerinden)
          // Örnek: EUR → USD: (1 EUR = 33.20 TRY) / (1 USD = 30.50 TRY) = 1.088 EUR/USD
          rate = fromRate.rate / toRate.rate;
          debugPrint(
              '$fromCurrency to $toCurrency: ${fromRate.rate} / ${toRate.rate} = ${fromRate.rate / toRate.rate}');
        }

        debugPrint('Final calculated rate: $rate');

        setState(() {
          _exchangeRateController.text = rate.toStringAsFixed(4);
          _isLoadingExchangeRate = false;
          _isAutoExchangeRate = true; // Otomatik kur çekildi
        });
        _calculateConvertedAmount();
      } else if (mounted) {
        setState(() {
          _exchangeRateController.text = 'TCMB\'den kur alınamadı';
          _isLoadingExchangeRate = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _exchangeRateController.text = 'Hata: ${e.toString()}';
          _isLoadingExchangeRate = false;
        });
      }
    }
  }

  /// Dönüştürülmüş miktarı hesapla
  void _calculateConvertedAmount() {
    debugPrint('_calculateConvertedAmount called');
    debugPrint('Amount: ${_amountController.text}');
    debugPrint('Exchange rate: ${_exchangeRateController.text}');

    if (_amountController.text.isEmpty ||
        _exchangeRateController.text.isEmpty) {
      debugPrint('Empty amount or exchange rate, setting converted to 0');
      setState(() {
        _convertedAmount = 0.0;
      });
      return;
    }

    try {
      final cleanValue =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.tryParse(cleanValue);

      // Kur metninden sadece sayısal kısmı çıkar (TCMB) etiketini kaldır
      final rateText = _exchangeRateController.text
          .replaceAll(' (TCMB)', '')
          .replaceAll('TCMB\'den kur çekiliyor...', '')
          .replaceAll('TCMB\'den kur alınamadı', '')
          .replaceAll('Hata:', '');
      final exchangeRate = double.tryParse(rateText);

      debugPrint('Clean amount: $amount');
      debugPrint('Clean exchange rate: $exchangeRate');

      if (amount != null &&
          exchangeRate != null &&
          amount > 0 &&
          exchangeRate > 0) {
        final converted = amount * exchangeRate;
        debugPrint('Converted amount: $converted');
        setState(() {
          _convertedAmount = converted;
        });
      } else {
        debugPrint('Invalid amount or exchange rate');
        setState(() {
          _convertedAmount = 0.0;
        });
      }
    } catch (e) {
      debugPrint('Error in _calculateConvertedAmount: $e');
      setState(() {
        _convertedAmount = 0.0;
      });
    }
  }
}

/// Transfer türleri
enum TransferType {
  send, // Bu hesaptan başka hesaba gönder
  receive, // Başka hesaptan bu hesaba al
}
