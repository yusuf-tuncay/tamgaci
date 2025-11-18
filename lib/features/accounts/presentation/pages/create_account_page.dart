import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_transaction.dart';
import '../providers/account_providers.dart';
import '../providers/account_transaction_providers.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Hesap Oluşturma Sayfası
class CreateAccountPage extends ConsumerStatefulWidget {
  final Account? existingAccount;

  const CreateAccountPage({
    super.key,
    this.existingAccount,
  });

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _ibanController = TextEditingController();
  final _swiftCodeController = TextEditingController();
  final _balanceController = TextEditingController();
  final _availableBalanceController = TextEditingController();
  final _blockedAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  AccountType _selectedType = AccountType.checking;
  AccountStatus _selectedStatus = AccountStatus.active;
  String _selectedCurrency = 'TRY';
  bool _isActive = true;
  bool _isLoading = false;

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

    debugPrint(
        'CreateAccountPage - existingAccount: ${widget.existingAccount?.name}');
    if (widget.existingAccount != null) {
      _populateFields(widget.existingAccount!);
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _ibanController.dispose();
    _swiftCodeController.dispose();
    _balanceController.dispose();
    _availableBalanceController.dispose();
    _blockedAmountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateFields(Account account) {
    _nameController.text = account.name;
    _accountNumberController.text = account.accountNumber;
    _bankNameController.text = account.bankName;
    _branchNameController.text = account.branchName;
    _ibanController.text = account.iban;
    _swiftCodeController.text = account.swiftCode;
    _balanceController.text = account.balance.toString();
    _availableBalanceController.text = account.availableBalance.toString();
    _blockedAmountController.text = account.blockedAmount.toString();
    _descriptionController.text = account.description ?? '';
    _notesController.text = account.notes ?? '';
    _selectedType = account.type;
    _selectedStatus = account.status;
    _selectedCurrency = account.currency;
    _isActive = account.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        showBackButton: true,
        showDrawer: false,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/accounts');
          }
        },
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _showMoreOptions,
            tooltip: 'Daha fazla seçenek',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }


  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildBankInfoCard(),
            const SizedBox(height: 16),
            _buildBalanceInfoCard(),
            const SizedBox(height: 16),
            _buildAdditionalInfoCard(),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance,
              color: Colors.blue[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingAccount != null
                      ? 'Hesap Düzenle'
                      : 'Yeni Hesap Oluştur',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                Text(
                  widget.existingAccount != null
                      ? 'Mevcut hesap bilgilerini güncelleyin'
                      : 'Banka hesabı bilgilerini girin',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      'Temel Bilgiler',
      Icons.info_outline,
      [
        _buildTextField(
          controller: _nameController,
          label: 'Hesap Adı',
          hint: 'Örn: Ana Hesap',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Hesap adı gerekli';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _accountNumberController,
          label: 'Hesap Numarası',
          hint: 'Örn: 1234567890',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Hesap numarası gerekli';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdown<AccountType>(
                label: 'Hesap Türü',
                value: _selectedType,
                items: AccountType.values,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                itemBuilder: (type) => '${type.icon} ${type.displayName}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown<AccountStatus>(
                label: 'Durum',
                value: _selectedStatus,
                items: AccountStatus.values,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                itemBuilder: (status) => status.displayName,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankInfoCard() {
    return _buildCard(
      'Banka Bilgileri',
      Icons.business,
      [
        _buildTextField(
          controller: _bankNameController,
          label: 'Banka Adı',
          hint: 'Örn: Türkiye İş Bankası',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Banka adı gerekli';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _branchNameController,
          label: 'Şube Adı',
          hint: 'Örn: Merkez Şube',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _ibanController,
          label: 'IBAN',
          hint: 'TR00 0000 0000 0000 0000 0000 00',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'IBAN gerekli';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _swiftCodeController,
                label: 'SWIFT Kodu',
                hint: 'Örn: ISBKTRIS',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown<String>(
                label: 'Para Birimi',
                value: _selectedCurrency,
                items: ['TRY', 'USD', 'EUR', 'GBP'],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
                itemBuilder: (currency) => currency,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceInfoCard() {
    return _buildCard(
      'Bakiye Bilgileri',
      Icons.account_balance_wallet,
      [
        _buildTextField(
          controller: _balanceController,
          label: 'Toplam Bakiye',
          hint: '0.00',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Toplam bakiye gerekli';
            }
            if (double.tryParse(value) == null) {
              return 'Geçerli bir sayı girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _availableBalanceController,
                label: 'Kullanılabilir Bakiye',
                hint: '0.00',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _blockedAmountController,
                label: 'Bloke Tutar',
                hint: '0.00',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoCard() {
    return _buildCard(
      'Ek Bilgiler',
      Icons.note,
      [
        _buildTextField(
          controller: _descriptionController,
          label: 'Açıklama',
          hint: 'Hesap hakkında kısa açıklama',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _notesController,
          label: 'Notlar',
          hint: 'Ek notlar',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            'Aktif Hesap',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                'Hesap aktif olarak kullanılabilir',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              );
            },
          ),
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeThumbColor: Colors.blue[600],
        ),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.blue[400]!,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) itemBuilder,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<T>(
      initialValue: value,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.blue[400]!,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemBuilder(item)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final account = Account(
        id: widget.existingAccount?.id ?? '',
        tenantId: '', // Repository'de set edilecek
        name: _nameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        bankName: _bankNameController.text.trim(),
        branchName: _branchNameController.text.trim(),
        iban: _ibanController.text.trim(),
        swiftCode: _swiftCodeController.text.trim(),
        currency: _selectedCurrency,
        balance: double.parse(_balanceController.text),
        availableBalance:
            double.tryParse(_availableBalanceController.text) ?? 0.0,
        blockedAmount: double.tryParse(_blockedAmountController.text) ?? 0.0,
        type: _selectedType,
        status: _selectedStatus,
        isActive: _isActive,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.existingAccount?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.existingAccount?.createdBy ?? 'current_user',
        updatedBy: 'current_user',
      );

      if (widget.existingAccount != null) {
        await ref.read(accountNotifierProvider.notifier).updateAccount(account);
        // Provider'ı refresh et
        ref.invalidate(accountsProvider);
        debugPrint(
            'CreateAccountPage - accountsProvider invalidated after update');
      } else {
        // Yeni hesap oluştur
        await ref.read(accountNotifierProvider.notifier).createAccount(account);
        
        // Açılış bakiyesi için transaction oluştur (sadece yeni hesap için)
        final openingBalance = double.parse(_balanceController.text);
        if (openingBalance > 0) {
          await _createOpeningBalanceTransaction(account.id, openingBalance, account.currency);
        }
        
        // Provider'ları refresh et
        ref.invalidate(accountsProvider);
        ref.invalidate(transactionsByAccountIdProvider(account.id));
        debugPrint(
            'CreateAccountPage - accountsProvider invalidated after create');
      }

      if (mounted) {
        debugPrint('CreateAccountPage - Navigator.pop(context, true) called');
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingAccount != null
                  ? 'Hesap başarıyla güncellendi'
                  : 'Hesap başarıyla oluşturuldu',
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
              'Hesap kaydedilemedi: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(
                'Taslak Olarak Kaydet',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                context.pop();
                // Taslak kaydetme işlemi
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: Text(
                'Formu Temizle',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                context.pop();
                _clearForm();
              },
            ),
            // Sadece düzenleme modunda ve varsayılan olmayan hesaplar için silme butonu
            if (widget.existingAccount != null &&
                widget.existingAccount!.canBeDeleted)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Hesabı Sil',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
                onTap: () {
                  context.pop();
                  _showDeleteConfirmation();
                },
              ),
            if (widget.existingAccount != null &&
                !widget.existingAccount!.isSystemDefaultAccount &&
                !widget.existingAccount!.canBeDeleted)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.grey),
                title: Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Text(
                      'Bakiyesi olan hesaplar silinemez',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    );
                  },
                ),
                subtitle: Text(
                  'Silmeden önce bakiye, kullanılabilir ve bloke tutarlarını sıfırlayın.',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onTap: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Bu hesabı silmek için önce tüm bakiyeleri sıfırlayın.'),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(
                'Yardım',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                context.pop();
                // Yardım sayfasına git
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hesabı Sil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${widget.existingAccount!.name} hesabını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await _deleteAccount();
            },
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (widget.existingAccount == null) return;

    try {
      setState(() => _isLoading = true);

      await ref
          .read(accountNotifierProvider.notifier)
          .deleteAccount(widget.existingAccount!.id);

      if (mounted) {
        // Ana liste sayfasına dön (hesaplar ana sayfası)
        context.goNamed('accounts-home');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.existingAccount!.name} hesabı başarıyla silindi',
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
              'Hesap silinemedi: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 4,
          shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.existingAccount != null ? 'Güncelle' : 'Kaydet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _createOpeningBalanceTransaction(String accountId, double openingBalance, String currency) async {
    try {
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

          final transaction = AccountTransaction(
            id: '',
            accountId: accountId,
            tenantId: tenantId,
            type: TransactionType.opening,
            amount: openingBalance,
            balanceAfter: openingBalance,
            description: 'Hesap açılış bakiyesi',
            category: TransactionCategory.bank,
            transactionDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            createdBy: user.uid,
            updatedBy: user.uid,
            userId: user.uid,
          );

          await ref
              .read(accountTransactionNotifierProvider.notifier)
              .createTransaction(transaction);
          
          debugPrint('Opening balance transaction created: $openingBalance $currency');
        }
      }
    } catch (e) {
      debugPrint('Error creating opening balance transaction: $e');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _accountNumberController.clear();
    _bankNameController.clear();
    _branchNameController.clear();
    _ibanController.clear();
    _swiftCodeController.clear();
    _balanceController.clear();
    _availableBalanceController.clear();
    _blockedAmountController.clear();
    _descriptionController.clear();
    _notesController.clear();
    setState(() {
      _selectedType = AccountType.checking;
      _selectedStatus = AccountStatus.active;
      _selectedCurrency = 'TRY';
      _isActive = true;
    });
  }
}
