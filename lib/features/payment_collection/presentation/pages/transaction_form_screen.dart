// ========== TRANSACTION FORM SCREEN ==========
// lib/features/payment_collection/presentation/pages/transaction_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_enums.dart';
import '../../domain/entities/payment_transaction.dart';
import '../providers/payment_collection_providers.dart';
import '../widgets/transaction_form_fields.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../suppliers/presentation/providers/supplier_providers.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../accounts/domain/entities/account.dart';

/// Tahsilat ve ödeme işlemi form ekranı
class TransactionFormScreen extends ConsumerStatefulWidget {
  final PaymentDirection direction;
  final String? transactionId;
  final String? customerId;
  final String? supplierId;
  final String? revenueId;
  final String? expenseId;

  const TransactionFormScreen({
    super.key,
    required this.direction,
    this.transactionId,
    this.customerId,
    this.supplierId,
    this.revenueId,
    this.expenseId,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    // Ödeme yöntemlerini ve kaynaklarını yükle
    await ref
        .read(paymentCollectionStateProvider.notifier)
        .loadPaymentMethods();
    await ref
        .read(paymentCollectionStateProvider.notifier)
        .loadPaymentSources();

    // Eğer düzenleme modundaysa, işlem detayını yükle
    if (widget.transactionId != null) {
      await ref
          .read(paymentCollectionStateProvider.notifier)
          .loadTransactionDetail(widget.transactionId!);
      final state = ref.read(paymentCollectionStateProvider);
      if (state.selectedTransaction != null) {
        _populateForm(state.selectedTransaction!);
      }
    } else {
      // Yeni işlem için form alanlarını ayarla
      _setupNewTransaction();
    }
  }

  void _populateForm(dynamic transaction) {
    final formNotifier = ref.read(paymentTransactionFormProvider.notifier);
    formNotifier.updateField('type', transaction.type);
    formNotifier.updateField('category', transaction.category);
    formNotifier.updateField('direction', transaction.direction);
    formNotifier.updateField('amount', transaction.amount);
    formNotifier.updateField('currency', transaction.currency);
    formNotifier.updateField('transactionDate', transaction.transactionDate);
    formNotifier.updateField('dueDate', transaction.dueDate);
    formNotifier.updateField('description', transaction.description);
    formNotifier.updateField('referenceNumber', transaction.referenceNumber);
    formNotifier.updateField('notes', transaction.notes);
    formNotifier.updateField('customerId', transaction.customerId);
    formNotifier.updateField('supplierId', transaction.supplierId);
    formNotifier.updateField('revenueId', transaction.revenueId);
    formNotifier.updateField('expenseId', transaction.expenseId);
    formNotifier.updateField('accountId', transaction.accountId);
    formNotifier.updateField('targetAccountId', transaction.targetAccountId);
    formNotifier.updateField('paymentMethodId', transaction.paymentMethodId);
    formNotifier.updateField('paymentSourceId', transaction.paymentSourceId);
    formNotifier.updateField(
        'relatedDocumentId', transaction.relatedDocumentId);
    formNotifier.updateField(
        'relatedDocumentType', transaction.relatedDocumentType);
  }

  void _setupNewTransaction() {
    final formNotifier = ref.read(paymentTransactionFormProvider.notifier);

    // İşlem yönü ve kategorisini ayarla
    formNotifier.updateField('direction', widget.direction);

    if (widget.direction == PaymentDirection.incoming) {
      formNotifier.updateField(
          'category', PaymentTransactionCategory.customerPayment);
    } else {
      formNotifier.updateField(
          'category', PaymentTransactionCategory.supplierPayment);
    }

    // Parametrelerden gelen ID'leri ayarla
    if (widget.customerId != null) {
      formNotifier.updateField('customerId', widget.customerId);
    }
    if (widget.supplierId != null) {
      formNotifier.updateField('supplierId', widget.supplierId);
    }
    if (widget.revenueId != null) {
      formNotifier.updateField('revenueId', widget.revenueId);
    }
    if (widget.expenseId != null) {
      formNotifier.updateField('expenseId', widget.expenseId);
    }

    // İşlem türünü otomatik seç
    _setDefaultTransactionType();

    // Temel alanları ayarla
    formNotifier.updateField('transactionDate', DateTime.now());

    // Para birimini otomatik seç
    _setDefaultCurrency();

    // Açıklama alanını otomatik doldur
    _setDefaultDescription();

    // Varsayılan hesap ayarla
    _setDefaultAccount();
  }

  void _setDefaultTransactionType() {
    final formNotifier = ref.read(paymentTransactionFormProvider.notifier);

    // Müşteri işlemi ise tahsilat türü seç
    if (widget.customerId != null) {
      formNotifier.updateField('type', PaymentTransactionType.cash);
    }
    // Tedarikçi işlemi ise ödeme türü seç
    else if (widget.supplierId != null) {
      formNotifier.updateField('type', PaymentTransactionType.cash);
    }
    // Varsayılan olarak nakit
    else {
      formNotifier.updateField('type', PaymentTransactionType.cash);
    }
  }

  /// Para birimini otomatik seç
  void _setDefaultCurrency() {
    final formNotifier = ref.read(paymentTransactionFormProvider.notifier);

    // Varsayılan olarak TRY kullan
    String defaultCurrency = 'TRY';

    // Müşteri/tedarikçi bilgilerine göre para birimi belirle
    if (widget.customerId != null) {
      // Müşteri bilgilerini al ve para birimini belirle
      // Şimdilik varsayılan TRY kullan, ileride müşteri tercihine göre ayarlanabilir
      defaultCurrency = 'TRY';
    } else if (widget.supplierId != null) {
      // Tedarikçi bilgilerini al ve para birimini belirle
      // Şimdilik varsayılan TRY kullan, ileride tedarikçi tercihine göre ayarlanabilir
      defaultCurrency = 'TRY';
    }

    formNotifier.updateField('currency', defaultCurrency);
  }

  /// Varsayılan hesap ayarla
  void _setDefaultAccount() {
    // Hesap seçimini async olarak yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectDefaultAccount();
    });
  }

  /// Para birimine göre varsayılan hesap seç
  void _selectDefaultAccount() async {
    try {
      final accountsAsync = ref.read(activeAccountsProvider);

      accountsAsync.when(
        data: (accounts) {
          if (accounts.isNotEmpty) {
            // Para birimine göre hesap filtrele
            String currency = ref.read(paymentTransactionFormProvider).currency;
            List<Account> currencyAccounts = accounts
                .where((account) => account.currency == currency)
                .toList();

            Account? selectedAccount;

            if (currencyAccounts.isNotEmpty) {
              // Önce varsayılan hesabı ara
              selectedAccount = currencyAccounts.firstWhere(
                (account) => account.isDefault,
                orElse: () => currencyAccounts.first,
              );
            } else {
              // Para birimi uygun hesap yoksa, varsayılan hesabı ara
              selectedAccount = accounts.firstWhere(
                (account) => account.isDefault,
                orElse: () => accounts.first,
              );
            }

            final formNotifier =
                ref.read(paymentTransactionFormProvider.notifier);
            formNotifier.updateField('accountId', selectedAccount.id);
          }
        },
        loading: () {
          // Yükleme durumunda varsayılan hesap ID'si kullan
          final formNotifier =
              ref.read(paymentTransactionFormProvider.notifier);
          formNotifier.updateField('accountId', 'default_account_1');
        },
        error: (error, stack) {
          // Hata durumunda varsayılan hesap ID'si kullan
          final formNotifier =
              ref.read(paymentTransactionFormProvider.notifier);
          formNotifier.updateField('accountId', 'default_account_1');
        },
      );
    } catch (e) {
      // Hata durumunda varsayılan hesap ID'si kullan
      final formNotifier = ref.read(paymentTransactionFormProvider.notifier);
      formNotifier.updateField('accountId', 'default_account_1');
    }
  }

  void _setDefaultDescription() {
    final formNotifier = ref.read(paymentTransactionFormProvider.notifier);

    String description = '';

    if (widget.customerId != null) {
      description = 'Müşteri tahsilatı';
    } else if (widget.supplierId != null) {
      description = 'Tedarikçi ödemesi';
    } else if (widget.revenueId != null) {
      description = 'Gelir fişi tahsilatı';
    } else if (widget.expenseId != null) {
      description = 'Gider fişi ödemesi';
    } else {
      description = widget.direction == PaymentDirection.incoming
          ? 'Tahsilat işlemi'
          : 'Ödeme işlemi';
    }

    formNotifier.updateField('description', description);
  }

  /// Seçili müşteri bilgisi widget'ı
  Widget _buildSelectedCustomerInfo() {
    return Consumer(
      builder: (context, ref, child) {
        final customerAsync = ref.watch(customerProvider(widget.customerId!));

        return customerAsync.when(
          data: (customer) {
            if (customer == null) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Müşteri bulunamadı',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seçili Müşteri',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (customer.email != null)
                          Text(
                            customer.email!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        if (customer.phone != null)
                          Text(
                            customer.phone!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Müşteri bilgileri yükleniyor...'),
              ],
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Müşteri bilgileri yüklenemedi: $error',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Seçili tedarikçi bilgisi widget'ı
  Widget _buildSelectedSupplierInfo() {
    return Consumer(
      builder: (context, ref, child) {
        final supplierAsync = ref.watch(supplierProvider(widget.supplierId!));

        return supplierAsync.when(
          data: (supplier) {
            if (supplier == null) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Tedarikçi bulunamadı',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.business, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seçili Tedarikçi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          supplier.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (supplier.email != null)
                          Text(
                            supplier.email!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        if (supplier.phone != null)
                          Text(
                            supplier.phone!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Tedarikçi bilgileri yükleniyor...'),
              ],
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tedarikçi bilgileri yüklenemedi: $error',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// App bar başlığını belirle
  String _getAppBarTitle() {
    if (widget.transactionId != null) {
      return 'İşlem Düzenle';
    }

    if (widget.customerId != null) {
      return 'Müşteri Tahsilatı';
    } else if (widget.supplierId != null) {
      return 'Tedarikçi Ödemesi';
    } else if (widget.revenueId != null) {
      return 'Gelir Fişi Tahsilatı';
    } else if (widget.expenseId != null) {
      return 'Gider Fişi Ödemesi';
    } else {
      return widget.direction == PaymentDirection.incoming
          ? 'Yeni Tahsilat'
          : 'Yeni Ödeme';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(paymentTransactionFormProvider);
    final collectionState = ref.watch(paymentCollectionStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          if (widget.transactionId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seçili müşteri/tedarikçi bilgisi göster - EN ÜSTTE
              if (widget.customerId != null) _buildSelectedCustomerInfo(),

              if (widget.supplierId != null) _buildSelectedSupplierInfo(),

              // Müşteri/tedarikçi bilgisi ile form alanları arasında boşluk
              if (widget.customerId != null || widget.supplierId != null)
                const SizedBox(height: 16),

              // İşlem türü ve yönü
              TransactionFormFields.buildTransactionTypeField(
                formState: formState,
                onChanged: (value) => _updateField('type', value),
                enabled: widget.transactionId == null,
              ),

              const SizedBox(height: 16),

              TransactionFormFields.buildDirectionField(
                formState: formState,
                onChanged: (value) => _updateField('direction', value),
                enabled: widget.transactionId == null,
              ),

              const SizedBox(height: 16),

              // Tutar ve para birimi
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TransactionFormFields.buildAmountField(
                      formState: formState,
                      onChanged: (value) => _updateField('amount', value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TransactionFormFields.buildCurrencyField(
                      formState: formState,
                      onChanged: (value) => _updateField('currency', value),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tarih alanları
              Row(
                children: [
                  Expanded(
                    child: TransactionFormFields.buildTransactionDateField(
                      formState: formState,
                      onChanged: (value) =>
                          _updateField('transactionDate', value),
                      context: context,
                    ),
                  ),
                  if (formState.isDueDateRequired) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TransactionFormFields.buildDueDateField(
                        formState: formState,
                        onChanged: (value) => _updateField('dueDate', value),
                        context: context,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Müşteri/Tedarikçi seçimi - sadece ID yoksa göster
              if (formState.isCustomerSelectionRequired &&
                  widget.customerId == null)
                TransactionFormFields.buildCustomerField(
                  formState: formState,
                  onChanged: (value) => _updateField('customerId', value),
                ),

              if (formState.isSupplierSelectionRequired &&
                  widget.supplierId == null)
                TransactionFormFields.buildSupplierField(
                  formState: formState,
                  onChanged: (value) => _updateField('supplierId', value),
                ),

              const SizedBox(height: 16),

              // Hesap seçimi
              Consumer(
                builder: (context, ref, child) {
                  final accountsAsync = ref.watch(activeAccountsProvider);
                  return accountsAsync.when(
                    data: (accounts) {
                      return TransactionFormFields.buildAccountField(
                        formState: formState,
                        onChanged: (value) => _updateField('accountId', value),
                        accounts: accounts,
                        selectedCurrency: formState.currency,
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Hesap yüklenemedi: $error'),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Ödeme yöntemi
              TransactionFormFields.buildPaymentMethodField(
                formState: formState,
                paymentMethods: collectionState.paymentMethods,
                onChanged: (value) => _updateField('paymentMethodId', value),
              ),

              const SizedBox(height: 16),

              // Ödeme kaynağı
              if (formState.isPaymentSourceRequired)
                TransactionFormFields.buildPaymentSourceField(
                  formState: formState,
                  paymentSources: collectionState.paymentSources,
                  onChanged: (value) => _updateField('paymentSourceId', value),
                ),

              const SizedBox(height: 16),

              // Açıklama
              TransactionFormFields.buildDescriptionField(
                formState: formState,
                onChanged: (value) => _updateField('description', value),
              ),

              const SizedBox(height: 16),

              // Referans numarası
              TransactionFormFields.buildReferenceNumberField(
                formState: formState,
                onChanged: (value) => _updateField('referenceNumber', value),
              ),

              const SizedBox(height: 16),

              // Notlar
              TransactionFormFields.buildNotesField(
                formState: formState,
                onChanged: (value) => _updateField('notes', value),
              ),

              const SizedBox(height: 32),

              // Hata mesajları
              if (formState.errors.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: formState.errors.entries.map((entry) {
                      return Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                            color: theme.colorScheme.onErrorContainer),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 16),

              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.transactionId != null ? 'Güncelle' : 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateField(String field, dynamic value) {
    ref.read(paymentTransactionFormProvider.notifier).updateField(field, value);
  }

  Future<void> _saveTransaction() async {
    final formState = ref.read(paymentTransactionFormProvider);
    final formNotifier = ref.read(paymentTransactionFormProvider.notifier);

    // Form doğrulama
    formNotifier.validateForm();

    if (!formState.isValid) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.transactionId != null) {
        // Güncelleme
        await _updateTransaction(formState);
      } else {
        // Yeni oluşturma
        await _createTransaction(formState);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
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

  Future<void> _createTransaction(dynamic formState) async {
    try {
      // PaymentTransaction oluştur
      final transaction = PaymentTransaction(
        id: '', // Service tarafından oluşturulacak
        transactionNumber: '', // Service tarafından oluşturulacak
        type: formState.type!,
        category: formState.category!,
        direction: formState.direction!,
        status: PaymentTransactionStatus.pending,
        amount: formState.amount!,
        currency: formState.currency,
        transactionDate: formState.transactionDate!,
        dueDate: formState.dueDate,
        description: formState.description,
        referenceNumber: formState.referenceNumber,
        notes: formState.notes,
        customerId: formState.customerId,
        supplierId: formState.supplierId,
        revenueId: formState.revenueId,
        expenseId: formState.expenseId,
        accountId: formState.accountId!,
        targetAccountId: formState.targetAccountId,
        paymentMethodId: formState.paymentMethodId!,
        paymentSourceId: formState.paymentSourceId,
        relatedDocumentId: formState.relatedDocumentId,
        relatedDocumentType: formState.relatedDocumentType,
        attachments: formState.attachments,
        metadata: formState.metadata,
        companyId: '', // Service tarafından ayarlanacak
        tenantId: '', // Service tarafından ayarlanacak
        createdBy: '', // Service tarafından ayarlanacak
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        updatedBy: null,
      );

      await ref
          .read(paymentCollectionStateProvider.notifier)
          .createTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İşlem başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem kaydedilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateTransaction(dynamic formState) async {
    try {
      // Mevcut transaction'ı güncelle
      final state = ref.read(paymentCollectionStateProvider);
      if (state.selectedTransaction != null) {
        final updatedTransaction = state.selectedTransaction!.copyWith(
          type: formState.type,
          category: formState.category,
          direction: formState.direction,
          amount: formState.amount,
          currency: formState.currency,
          transactionDate: formState.transactionDate,
          dueDate: formState.dueDate,
          description: formState.description,
          referenceNumber: formState.referenceNumber,
          notes: formState.notes,
          customerId: formState.customerId,
          supplierId: formState.supplierId,
          revenueId: formState.revenueId,
          expenseId: formState.expenseId,
          accountId: formState.accountId,
          targetAccountId: formState.targetAccountId,
          paymentMethodId: formState.paymentMethodId,
          paymentSourceId: formState.paymentSourceId,
          relatedDocumentId: formState.relatedDocumentId,
          relatedDocumentType: formState.relatedDocumentType,
          attachments: formState.attachments,
          metadata: formState.metadata,
          updatedAt: DateTime.now(),
        );

        await ref
            .read(paymentCollectionStateProvider.notifier)
            .updateTransaction(updatedTransaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İşlem başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu işlemi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.transactionId != null) {
      await ref
          .read(paymentCollectionStateProvider.notifier)
          .deleteTransaction(widget.transactionId!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
