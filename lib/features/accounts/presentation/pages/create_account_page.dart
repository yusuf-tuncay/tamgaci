import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';

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

    debugPrint('CreateAccountPage - existingAccount: ${widget.existingAccount?.name}');
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
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
        onPressed: () => context.pop(),
      ),
      title: Text(
        widget.existingAccount != null ? 'Hesap Düzenle' : 'Yeni Hesap',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87, size: 24),
          onPressed: _showMoreOptions,
          tooltip: 'Daha fazla seçenek',
        ),
      ],
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
    return Container(
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
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  widget.existingAccount != null
                      ? 'Mevcut hesap bilgilerini güncelleyin'
                      : 'Banka hesabı bilgilerini girin',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
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
          subtitle: Text(
            'Hesap aktif olarak kullanılabilir',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
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
    return Container(
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
            children: [
              Icon(icon, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[400]!),
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
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[400]!),
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
      } else {
        await ref.read(accountNotifierProvider.notifier).createAccount(account);
      }

      if (mounted) {
        context.pop();
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
                !widget.existingAccount!.isDefault)
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
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
