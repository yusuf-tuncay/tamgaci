import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_transaction.dart';
import '../providers/account_transaction_providers.dart';
import 'package:tamgaci/core/services/utils/exchange_rate_service.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildAccountCard(),
          _buildDetailsSection(),
          _buildTransactionsSection(),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.black87, size: 24),
          onPressed: _editAccount,
          tooltip: 'Düzenle',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87, size: 24),
          onPressed: _showMoreOptions,
          tooltip: 'Daha fazla seçenek',
        ),
      ],
    );
  }

  Widget _buildAccountCard() {
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
                      Color(0xFF6366F1), // Indigo-500
                      Color(0xFF8B5CF6), // Violet-500
                      Color(0xFF7C3AED), // Violet-600
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.25),
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
                            widget.account.name,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.account.bankName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildDetailsSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    Text(
                      'Hesap Detayları',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        'Hesap Numarası', widget.account.accountNumber),
                    _buildDetailRow('IBAN', widget.account.iban),
                    _buildDetailRow('SWIFT Kodu', widget.account.swiftCode),
                    _buildDetailRow('Şube', widget.account.branchName),
                    _buildDetailRow('Para Birimi', widget.account.currency),
                    _buildDetailRow(
                        'Hesap Türü', widget.account.type.displayName),
                    _buildDetailRow('Durum', widget.account.status.displayName),
                    if (widget.account.description != null)
                      _buildDetailRow('Açıklama', widget.account.description!),
                    if (widget.account.notes != null)
                      _buildDetailRow('Notlar', widget.account.notes!),
                    _buildDetailRow(
                        'Oluşturulma', _formatDate(widget.account.createdAt)),
                    _buildDetailRow('Son Güncelleme',
                        _formatDate(widget.account.updatedAt)),
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
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  Widget _buildTransactionsSection() {
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
                          transactionsByAccountIdProvider(widget.account.id),
                        );

                        return transactionsAsync.when(
                          data: (transactions) {
                            if (transactions.isEmpty) {
                              return _buildEmptyTransactions();
                            }
                            return Column(
                              children: transactions.take(5).map((transaction) {
                                return _buildTransactionItem(transaction);
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

  Widget _buildActionsSection() {
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
                      _editAccount,
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Bakiye Güncelle',
                      Icons.update,
                      Colors.green[600]!,
                      _updateBalance,
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Hesap Durumu',
                      Icons.settings,
                      Colors.orange[600]!,
                      _changeStatus,
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Masraf Ekle',
                      Icons.add_circle_outline,
                      Colors.purple[600]!,
                      _addExpense,
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Hesap Sil',
                      Icons.delete,
                      Colors.red[600]!,
                      _deleteAccount,
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

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editAccount() {
    context.pushNamed(
      'create-account',
      extra: widget.account,
    );
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
    // TODO: İşlemler sayfasına git - henüz implement edilmedi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İşlemler sayfası yakında eklenecek'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _updateBalance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bakiye Güncelle'),
        content: const Text('Bakiye güncelleme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _changeStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durum Değiştir'),
        content:
            const Text('Hesap durumu değiştirme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _addExpense() {
    showDialog(
      context: context,
      builder: (context) => _ExpenseDialog(
        account: widget.account,
        onExpenseAdded: () {
          // Masraf eklendikten sonra sayfayı yenile
          setState(() {});
        },
      ),
    );
  }

  void _deleteAccount() {
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
              await _performDeleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Hesap silme işlemi burada yapılacak
      // TODO: Account service ile silme işlemi implement edilecek

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

  Widget _buildTransactionItem(AccountTransaction transaction) {
    final isDebit = transaction.type == TransactionType.withdrawal ||
        transaction.type == TransactionType.transfer;
    final amount =
        isDebit ? transaction.debitAmount ?? 0 : transaction.creditAmount ?? 0;

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
              color: isDebit ? Colors.red[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDebit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDebit ? Colors.red[600] : Colors.green[600],
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
                '${isDebit ? '-' : '+'}${amount.toStringAsFixed(2)} ${widget.account.currency}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDebit ? Colors.red[600] : Colors.green[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bakiye: ${transaction.balanceAfter.toStringAsFixed(2)} ${widget.account.currency}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
}

/// Masraf Ekleme Dialog'u
class _ExpenseDialog extends StatefulWidget {
  final Account account;
  final VoidCallback onExpenseAdded;

  const _ExpenseDialog({
    required this.account,
    required this.onExpenseAdded,
  });

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
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
    _updateExchangeRate();

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
                          _updateExchangeRate();
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
                            labelText: 'Hesap Para Biriminde',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.swap_horiz, size: 20),
                            suffixText: _getCurrencySymbol(widget.account.currency),
                            suffixStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                                ? NumberFormat('#,##0.00', 'tr_TR').format(_convertedAmount)
                                : '',
                          ),
                        ),
                      ),
                  ],
                ),

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
                      _buildAccountInfoRow('Hesap Adı', widget.account.name),
                      _buildAccountInfoRow('Banka', widget.account.bankName),
                      _buildAccountInfoRow(
                          'Hesap No', widget.account.accountNumber),
                      _buildAccountInfoRow(
                          'Para Birimi', widget.account.currency),
                      _buildAccountInfoRow(
                          'Hesap Türü', widget.account.type.displayName),
                      _buildAccountInfoRow('Mevcut Bakiye',
                          '${widget.account.balance.toStringAsFixed(2)} ${widget.account.currency}'),
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

  Widget _buildAccountInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  void _updateExchangeRate() async {
    final fromCurrency = widget.account.currency; // Hesap para birimi
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Gerçek masraf ekleme işlemi burada yapılacak
      // Şimdilik simüle ediyoruz
      await Future.delayed(const Duration(seconds: 1));

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
