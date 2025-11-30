// ========== TRANSACTION FORM SCREEN ==========
// lib/features/payment_collection/presentation/pages/transaction_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_enums.dart';
import '../../domain/entities/payment_transaction.dart';
import '../providers/payment_collection_providers.dart';
import '../widgets/transaction_form_fields.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../suppliers/presentation/providers/supplier_providers.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../../core/services/business/transaction_service.dart';
import '../models/payment_transaction_form_model.dart';

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

  // Controller'lar fokus kaybını önlemek için
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();

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

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
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

    // Amount controller'ını başlangıç değeriyle doldur
    if (transaction.amount != null) {
      _amountController.text = transaction.amount.toString();
    }
    formNotifier.updateField('targetAccountId', transaction.targetAccountId);
    formNotifier.updateField('paymentMethodId', transaction.paymentMethodId);
    formNotifier.updateField('paymentSourceId', transaction.paymentSourceId);
    formNotifier.updateField(
        'relatedDocumentId', transaction.relatedDocumentId);
    formNotifier.updateField(
        'relatedDocumentType', transaction.relatedDocumentType);

    // Metadata'yı da yükle (çek/senet bilgileri için)
    if (transaction.metadata != null && transaction.metadata.isNotEmpty) {
      formNotifier.updateField('metadata', transaction.metadata);
    }
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

    // Müşteri bilgilerine göre para birimi belirle
    if (widget.customerId != null) {
      try {
        final customerAsync = ref.read(customerProvider(widget.customerId!));
        customerAsync.whenData((customer) {
          if (customer != null && customer.customerCurrency != null) {
            defaultCurrency = customer.customerCurrency!;
            formNotifier.updateField('currency', defaultCurrency);
            debugPrint('DEBUG: Müşteri para birimi seçildi: $defaultCurrency');
          } else {
            formNotifier.updateField('currency', defaultCurrency);
          }
        });
      } catch (e) {
        debugPrint('DEBUG: Müşteri para birimi alınamadı: $e');
        formNotifier.updateField('currency', defaultCurrency);
      }
    } else if (widget.supplierId != null) {
      // Tedarikçi bilgilerini al ve para birimini belirle
      try {
        final supplierAsync = ref.read(supplierProvider(widget.supplierId!));
        supplierAsync.whenData((supplier) {
          if (supplier != null) {
            defaultCurrency = supplier.currency;
            formNotifier.updateField('currency', defaultCurrency);
            debugPrint(
                'DEBUG: Tedarikçi para birimi seçildi: $defaultCurrency');
          } else {
            formNotifier.updateField('currency', defaultCurrency);
          }
        });
      } catch (e) {
        debugPrint('DEBUG: Tedarikçi para birimi alınamadı: $e');
        formNotifier.updateField('currency', defaultCurrency);
      }
    } else {
      formNotifier.updateField('currency', defaultCurrency);
    }
  }

  /// Varsayılan hesap ayarla
  void _setDefaultAccount() {
    // Bu metod artık gerekli değil çünkü dropdown otomatik olarak ilk hesabı seçiyor
    // Consumer widget'ı içinde otomatik seçim yapılıyor
    // İşlem türü ve para birimine göre uygun kasa seçimi yapılacak
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Seçili Müşteri',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (customer.email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.email!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (customer.phone != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.phone!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: customer.balance >= 0
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: customer.balance >= 0
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                customer.balance >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 14,
                                color: customer.balance >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Bakiye: ${_formatCurrency(customer.balance)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: customer.balance >= 0
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ],
                          ),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
              // İşlem türü - Tüm durumlar için özel widget
              _buildTransactionTypeFieldForTransfer(formState),

              const SizedBox(height: 16),

              // Çek/Senet bilgileri göster
              if (formState.type == PaymentTransactionType.check ||
                  formState.type == PaymentTransactionType.promissoryNote) ...[
                _buildCheckPromissoryInfoCard(formState),
                const SizedBox(height: 16),
              ],

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
                      controller: _amountController,
                      focusNode: _amountFocusNode,
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

              // Tarih ve saat alanları
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TransactionFormFields.buildTransactionDateField(
                      formState: formState,
                      onChanged: (value) =>
                          _updateField('transactionDate', value),
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(DateTime.now()),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Hesap seçimi - Borç/Alacak fişleri ve Cari Virman için gizle
              if (formState.type != PaymentTransactionType.debtReceipt &&
                  formState.type != PaymentTransactionType.creditReceipt &&
                  formState.type != PaymentTransactionType.accountTransfer)
                Consumer(
                  builder: (context, ref, child) {
                    // Önce activeAccountsProvider'ı dene, başarısız olursa accountsProvider'ı kullan
                    final activeAccountsAsync =
                        ref.watch(activeAccountsProvider);
                    final allAccountsAsync = ref.watch(accountsProvider);

                    // activeAccountsProvider başarısız olursa accountsProvider'ı kullan
                    final accountsAsync = activeAccountsAsync.when(
                      data: (accounts) => AsyncValue.data(accounts),
                      loading: () => allAccountsAsync,
                      error: (error, stack) => allAccountsAsync,
                    );

                    return accountsAsync.when(
                      data: (accounts) {
                        // Debug: Hesap sayısını logla
                        debugPrint('DEBUG: Loaded ${accounts.length} accounts');
                        for (final account in accounts) {
                          debugPrint(
                              'DEBUG: Account - ${account.name}, Type: ${account.type}, Active: ${account.isActive}, Status: ${account.status}');
                        }

                        // Aktif hesapları filtrele (eğer activeAccountsProvider çalışmıyorsa)
                        final activeAccounts = accounts
                            .where((account) =>
                                account.isActive &&
                                account.status == AccountStatus.active)
                            .toList();

                        debugPrint(
                            'DEBUG: Filtered to ${activeAccounts.length} active accounts');

                        // Tüm aktif hesapları göster
                        if (activeAccounts.isEmpty) {
                          return Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Hesap bulunamadı - Lütfen hesap oluşturun',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Hesaplar sayfasına yönlendir
                                    Navigator.pushNamed(
                                        context, '/accounts/create');
                                  },
                                  child: const Text(
                                    'Hesap Oluştur',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Seçili hesap ID'sinin listede olup olmadığını kontrol et
                        String? selectedValue = formState.accountId;
                        if (selectedValue != null &&
                            !activeAccounts.any(
                                (account) => account.id == selectedValue)) {
                          selectedValue = null;
                        }

                        // İşlem türü değiştiğinde hesap seçimini yeniden hesapla
                        final newSelectedValue =
                            _selectBestAccount(activeAccounts, formState);
                        if (newSelectedValue != null &&
                            newSelectedValue != selectedValue) {
                          selectedValue = newSelectedValue;
                          // Seçilen hesabı form'a kaydet
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _updateField('accountId', selectedValue);
                          });
                        } else if (selectedValue == null &&
                            activeAccounts.isNotEmpty) {
                          // Eğer hiç seçili değilse, ilk hesabı seç
                          selectedValue = activeAccounts.first.id;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _updateField('accountId', selectedValue);
                          });
                        }

                        // Basit buton ile hesap seçimi (dropdown sorunları için alternatif)
                        return GestureDetector(
                          onTap: () => _showAccountSelectionDialog(
                              context, activeAccounts, formState),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 56),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance,
                                    color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        selectedValue != null
                                            ? activeAccounts
                                                .firstWhere((a) =>
                                                    a.id == selectedValue)
                                                .name
                                            : 'Hesap seçin',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: selectedValue != null
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (selectedValue != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${activeAccounts.firstWhere((a) => a.id == selectedValue).type.displayName} - ${activeAccounts.firstWhere((a) => a.id == selectedValue).currency}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Hesaplar yükleniyor...'),
                          ],
                        ),
                      ),
                      error: (error, stack) {
                        // Debug: Hata detaylarını logla
                        debugPrint('DEBUG: Error loading accounts: $error');
                        debugPrint('DEBUG: Stack trace: $stack');

                        return Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Hesaplar yüklenemedi: ${error.toString()}',
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 16),

              // Hesap transferi için hesap seçimi
              if (formState.type == PaymentTransactionType.accountTransfer)
                _buildAccountTransferFields(formState)
              else ...[
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
              ],

              const SizedBox(height: 16),

              // Açıklama
              TransactionFormFields.buildDescriptionField(
                formState: formState,
                onChanged: (value) => _updateField('description', value),
              ),

              const SizedBox(height: 8),

              // Hata mesajları
              if (formState.errors.isNotEmpty) ...[
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
                const SizedBox(height: 8),
              ],

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

    // Amount controller'ını güncelle (sadece amount field'ı için)
    if (field == 'amount' && value != null) {
      // Eğer controller'ın değeri farklıysa güncelle
      final currentText = _amountController.text;
      final newText = value.toString();
      if (currentText != newText) {
        _amountController.text = newText;
      }
    }
  }

  /// İşlem türü değiştiğinde hesap seçimini güncelle
  void _updateAccountSelection() {
    // Hesap seçimini yeniden hesaplamak için state'i güncelle
    setState(() {
      // Bu, hesap seçimi widget'ının yeniden render edilmesini sağlar
    });
  }

  /// Doğrulamadan önce zorunlu alanlar için varsayılan değerleri uygular
  void _ensureRequiredDefaults() {
    final formNotifier = ref.read(paymentTransactionFormProvider.notifier);
    var formState = ref.read(paymentTransactionFormProvider);

    // Çek/Senet işlemleri için vade tarihini metadata'dan al
    if ((formState.type == PaymentTransactionType.check ||
            formState.type == PaymentTransactionType.promissoryNote) &&
        formState.dueDate == null) {
      final metadataDueDate = formState.metadata['dueDate'];
      DateTime? parsed;
      if (metadataDueDate is String) {
        parsed = DateTime.tryParse(metadataDueDate);
      } else if (metadataDueDate is DateTime) {
        parsed = metadataDueDate;
      }
      if (parsed != null) {
        formNotifier.updateField('dueDate', parsed);
      }
      formState = ref.read(paymentTransactionFormProvider);
    }

    // Ödeme yöntemi seçili değilse işleme göre otomatik seç
    if (formState.paymentMethodId == null ||
        (formState.paymentMethodId?.isEmpty ?? true)) {
      final defaultMethod = _getDefaultPaymentMethodId(formState.type);
      formNotifier.updateField('paymentMethodId', defaultMethod);
      formState = ref.read(paymentTransactionFormProvider);
    }

    // Ödeme kaynağı gerekli ise otomatik seç
    if (formState.isPaymentSourceRequired &&
        (formState.paymentSourceId == null ||
            (formState.paymentSourceId?.isEmpty ?? true))) {
      final defaultSource =
          _getDefaultPaymentSourceId(formState.type, formState.direction);
      formNotifier.updateField('paymentSourceId', defaultSource);
      formState = ref.read(paymentTransactionFormProvider);
    }

    // Hedef hesap gerekli ise otomatik bir hedef belirle
    if (formState.isTargetAccountRequired &&
        (formState.targetAccountId == null ||
            (formState.targetAccountId?.isEmpty ?? true))) {
      final defaultTarget = _getDefaultTargetAccountId(formState);
      formNotifier.updateField('targetAccountId', defaultTarget);
    }
  }

  String _getDefaultPaymentMethodId(PaymentTransactionType? type) {
    if (type == null) {
      return 'payment_method_auto_cash';
    }
    switch (type) {
      case PaymentTransactionType.cash:
        return 'payment_method_auto_cash';
      case PaymentTransactionType.creditCard:
        return 'payment_method_auto_credit_card';
      case PaymentTransactionType.eftTransfer:
        return 'payment_method_auto_bank_transfer';
      case PaymentTransactionType.check:
        return 'payment_method_auto_check';
      case PaymentTransactionType.promissoryNote:
        return 'payment_method_auto_promissory';
      case PaymentTransactionType.debtReceipt:
        return 'payment_method_auto_adjustment';
      case PaymentTransactionType.creditReceipt:
        return 'payment_method_auto_credit_receipt';
      case PaymentTransactionType.accountTransfer:
        return 'payment_method_auto_account_transfer';
    }
  }

  String _getDefaultPaymentSourceId(
      PaymentTransactionType? type, PaymentDirection? direction) {
    final prefix = direction == PaymentDirection.outgoing ? 'out' : 'in';
    if (type == PaymentTransactionType.creditCard) {
      return 'payment_source_${prefix}_pos';
    }
    if (type == PaymentTransactionType.eftTransfer) {
      return 'payment_source_${prefix}_bank';
    }
    if (type == PaymentTransactionType.check ||
        type == PaymentTransactionType.promissoryNote) {
      return 'payment_source_${prefix}_portfolio';
    }
    return 'payment_source_${prefix}_cash';
  }

  String _getDefaultTargetAccountId(PaymentTransactionFormModel formState) {
    if (formState.direction == PaymentDirection.incoming) {
      return formState.customerId ?? 'target_account_auto_customer';
    }
    if (formState.direction == PaymentDirection.outgoing) {
      return formState.supplierId ?? 'target_account_auto_supplier';
    }
    if (formState.category == PaymentTransactionCategory.internalTransfer) {
      return 'target_account_auto_internal';
    }
    return 'target_account_auto_default';
  }

  /// İşlem türü ve para birimine göre en uygun hesabı seç
  String? _selectBestAccount(List<Account> accounts, dynamic formState) {
    final transactionType = formState.type;
    final currency = formState.currency ?? 'TRY';
    final direction = formState.direction;

    debugPrint(
        'DEBUG: Hesap seçimi - İşlem türü: $transactionType, Para birimi: $currency, Yön: $direction');

    // 1. Öncelik: İşlem türü ve para birimine uygun hesap
    if (transactionType == PaymentTransactionType.cash) {
      // Nakit işlem için: Nakit hesabı + aynı para birimi
      final cashAccounts = accounts
          .where((account) =>
              account.type == AccountType.cash && account.currency == currency)
          .toList();

      if (cashAccounts.isNotEmpty) {
        debugPrint('DEBUG: Nakit hesabı bulundu: ${cashAccounts.first.name}');
        return cashAccounts.first.id;
      }
    } else if (transactionType == PaymentTransactionType.creditCard) {
      // Kredi kartı işlemi için yön kontrolü
      if (direction == PaymentDirection.incoming) {
        // Gelen kredi kartı ödemesi: POS hesabı
        final posAccounts = accounts
            .where((account) =>
                account.type ==
                    AccountType.other && // POS hesabı için other türü
                account.currency == currency &&
                account.name.toLowerCase().contains('pos'))
            .toList();

        if (posAccounts.isNotEmpty) {
          debugPrint('DEBUG: POS hesabı bulundu: ${posAccounts.first.name}');
          return posAccounts.first.id;
        }
      } else if (direction == PaymentDirection.outgoing) {
        // Giden kredi kartı ödemesi: Kredi kartı hesabı
        // Önce AccountType.creditCard türündeki hesapları ara
        final creditCardAccounts = accounts
            .where((account) =>
                account.type == AccountType.creditCard &&
                account.currency == currency)
            .toList();

        if (creditCardAccounts.isNotEmpty) {
          debugPrint(
              'DEBUG: Kredi kartı hesabı bulundu: ${creditCardAccounts.first.name}');
          return creditCardAccounts.first.id;
        }

        // Eğer AccountType.creditCard bulunamazsa, isim kontrolü yap
        final creditCardByName = accounts
            .where((account) =>
                account.currency == currency &&
                (account.name.toLowerCase().contains('kredi kartı') ||
                    account.name.toLowerCase().contains('credit card') ||
                    account.name.toLowerCase().contains('kart')))
            .toList();

        if (creditCardByName.isNotEmpty) {
          debugPrint(
              'DEBUG: Kredi kartı hesabı (isim kontrolü) bulundu: ${creditCardByName.first.name}');
          return creditCardByName.first.id;
        }
      }
    } else if (transactionType == PaymentTransactionType.eftTransfer) {
      // EFT/Havale için: Sadece banka hesabı + aynı para birimi
      // Önce AccountType.checking türündeki hesapları ara
      final bankAccounts = accounts
          .where((account) =>
              account.type == AccountType.checking &&
              account.currency == currency)
          .toList();

      if (bankAccounts.isNotEmpty) {
        debugPrint(
            'DEBUG: Banka hesabı (checking) bulundu: ${bankAccounts.first.name}');
        return bankAccounts.first.id;
      }

      // Eğer AccountType.checking bulunamazsa, isim kontrolü yap
      final bankByName = accounts
          .where((account) =>
              account.currency == currency &&
              (account.name.toLowerCase().contains('banka') ||
                  account.name.toLowerCase().contains('bank') ||
                  account.name.toLowerCase().contains('checking')))
          .toList();

      if (bankByName.isNotEmpty) {
        debugPrint(
            'DEBUG: Banka hesabı (isim kontrolü) bulundu: ${bankByName.first.name}');
        return bankByName.first.id;
      }

      // EFT/Havale için sadece banka hesabı kabul edilir, başka hesap türleri seçilmez
      debugPrint(
          'DEBUG: EFT/Havale için uygun banka hesabı bulunamadı - banka entegrasyonu gerekli');
      return null;
    } else if (transactionType == PaymentTransactionType.promissoryNote) {
      // Senet işlemi için: Senet hesabı + aynı para birimi
      final promissoryAccounts = accounts
          .where((account) =>
              account.currency == currency &&
              (account.name.toLowerCase().contains('senet') ||
                  account.name.toLowerCase().contains('promissory')))
          .toList();

      if (promissoryAccounts.isNotEmpty) {
        debugPrint(
            'DEBUG: Senet hesabı bulundu: ${promissoryAccounts.first.name}');
        return promissoryAccounts.first.id;
      }
    }

    // 2. İkinci öncelik: Aynı para birimindeki hesaplar (EFT/Havale hariç)
    if (transactionType != PaymentTransactionType.eftTransfer) {
      final sameCurrencyAccounts =
          accounts.where((account) => account.currency == currency).toList();

      if (sameCurrencyAccounts.isNotEmpty) {
        debugPrint(
            'DEBUG: Aynı para birimindeki hesap bulundu: ${sameCurrencyAccounts.first.name}');
        return sameCurrencyAccounts.first.id;
      }
    }

    // 3. Son seçenek: İlk hesap (EFT/Havale hariç)
    if (transactionType != PaymentTransactionType.eftTransfer &&
        accounts.isNotEmpty) {
      debugPrint('DEBUG: Varsayılan hesap seçildi: ${accounts.first.name}');
      return accounts.first.id;
    }

    return null;
  }

  /// Hesap seçim dialog'unu göster
  void _showAccountSelectionDialog(
      BuildContext context, List<Account> accounts, dynamic formState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Hesap transferi için filtreleme
        List<Account> baseFilteredAccounts = accounts;
        if (formState.type == PaymentTransactionType.accountTransfer) {
          // Seçili müşteri/tedarikçi ile aynı hesap filtrelenmeli
          final selectedCustomerId = formState.customerId;
          final selectedSupplierId = formState.supplierId;

          if (selectedCustomerId != null || selectedSupplierId != null) {
            // Seçili müşteri/tedarikçi ile aynı hesap filtrelenmeli
            baseFilteredAccounts = accounts.where((account) {
              // Seçili müşteri ile aynı hesap filtrelenmeli
              if (selectedCustomerId != null &&
                  account.name
                      .toLowerCase()
                      .contains(selectedCustomerId.toLowerCase())) {
                return false; // Aynı müşteri hesabı filtrelenir
              }

              // Seçili tedarikçi ile aynı hesap filtrelenmeli
              if (selectedSupplierId != null &&
                  account.name
                      .toLowerCase()
                      .contains(selectedSupplierId.toLowerCase())) {
                return false; // Aynı tedarikçi hesabı filtrelenir
              }

              return true; // Diğer hesaplar gösterilir
            }).toList();
          }
        }

        return _AccountSelectionDialog(
          accounts: baseFilteredAccounts,
          onAccountSelected: (accountId) {
            _updateField('accountId', accountId);
          },
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    _ensureRequiredDefaults();

    final formNotifier = ref.read(paymentTransactionFormProvider.notifier);
    formNotifier.validateForm();

    var formState = ref.read(paymentTransactionFormProvider);
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

      final createdTransaction = await ref
          .read(paymentCollectionStateProvider.notifier)
          .createTransaction(transaction);

      if (createdTransaction != null) {
        await _recordCustomerTransaction(createdTransaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İşlem başarıyla kaydedildi'),
              backgroundColor: Colors.green,
            ),
          );
        }
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

  Future<void> _recordCustomerTransaction(
      PaymentTransaction paymentTransaction) async {
    final customerId = paymentTransaction.customerId;
    if (customerId == null || customerId.isEmpty) {
      return;
    }

    try {
      final transactionService = TransactionService();
      final now = DateTime.now();

      final transactionType =
          paymentTransaction.direction == PaymentDirection.outgoing
              ? TransactionType.refund
              : TransactionType.payment;

      final description = paymentTransaction.description ??
          (paymentTransaction.type == PaymentTransactionType.check
              ? 'Çek Tahsilatı'
              : paymentTransaction.type == PaymentTransactionType.promissoryNote
                  ? 'Senet Tahsilatı'
                  : 'Ödeme');

      final customerTransaction = Transaction(
        id: '',
        customerId: customerId,
        supplierId: paymentTransaction.supplierId,
        type: transactionType,
        amount: paymentTransaction.amount,
        currency: paymentTransaction.currency,
        description: description,
        reference: paymentTransaction.referenceNumber,
        transactionDate: paymentTransaction.transactionDate,
        dueDate: paymentTransaction.dueDate,
        invoiceId: paymentTransaction.relatedDocumentId,
        paymentMethod: paymentTransaction.paymentMethodId,
        documentNumber: paymentTransaction.transactionNumber,
        status: TransactionStatus.completed,
        companyId: paymentTransaction.companyId,
        createdAt: now,
        updatedAt: now,
        createdBy: paymentTransaction.createdBy,
        updatedBy: paymentTransaction.updatedBy,
        metadata: {
          'paymentTransactionId': paymentTransaction.id,
          'paymentTransactionType': paymentTransaction.type.name,
          'accountId': paymentTransaction.accountId,
          'targetAccountId': paymentTransaction.targetAccountId,
          'paymentSourceId': paymentTransaction.paymentSourceId,
        },
      );

      await transactionService.createTransaction(customerTransaction);
    } catch (e) {
      debugPrint('Error recording customer transaction: $e');
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

  /// Hesap transferi için özel işlem türü widget'ı
  Widget _buildTransactionTypeFieldForTransfer(dynamic formState) {
    return GestureDetector(
      onTap: () => _showTransactionTypeDialog(formState),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.payment, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formState.type?.displayName ?? 'İşlem Türü Seçin',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// İşlem türü dialog'unu göster
  void _showTransactionTypeDialog(dynamic formState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlem Türü Seçin'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: PaymentTransactionType.values.length,
            itemBuilder: (context, index) {
              final type = PaymentTransactionType.values[index];
              return ListTile(
                leading: const Icon(
                  Icons.payment,
                  color: Colors.blue,
                ),
                title: Text(
                  type.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  _updateField('type', type);
                  _updateAccountSelection();

                  // Çek veya senet seçildiyse bilgileri dialog ile al
                  if (type == PaymentTransactionType.check) {
                    final saved = await _showCheckInfoDialog(formState);
                    // Eğer dialog iptal edildiyse veya kaydedilmediyse işlem türünü geri al
                    if (!saved) {
                      _updateField('type', PaymentTransactionType.cash);
                    }
                  } else if (type == PaymentTransactionType.promissoryNote) {
                    final saved =
                        await _showPromissoryNoteInfoDialog(formState);
                    // Eğer dialog iptal edildiyse veya kaydedilmediyse işlem türünü geri al
                    if (!saved) {
                      _updateField('type', PaymentTransactionType.cash);
                    }
                  }

                  // State'i yeniden tetiklemek için setState çağır
                  if (mounted) {
                    setState(() {});
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  /// Çek/Senet bilgileri kartı
  Widget _buildCheckPromissoryInfoCard(dynamic formState) {
    final metadata = formState.metadata ?? {};
    final isCheck = formState.type == PaymentTransactionType.check;
    final cardColor = isCheck ? Colors.blue[50] : Colors.orange[50];
    final borderColor = isCheck ? Colors.blue[200] : Colors.orange[200];
    final iconColor = isCheck ? Colors.blue[700] : Colors.orange[700];
    final icon = isCheck ? Icons.account_balance : Icons.description;

    // Bilgilerin var olup olmadığını kontrol et
    final hasInfo = isCheck
        ? (metadata['checkNumber'] != null || metadata['bankName'] != null)
        : (metadata['noteNumber'] != null);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    isCheck ? 'Çek Bilgileri' : 'Senet Bilgileri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(hasInfo ? Icons.edit : Icons.add, size: 20),
                color: iconColor,
                onPressed: () async {
                  if (isCheck) {
                    await _showCheckInfoDialog(formState, isEdit: hasInfo);
                  } else {
                    await _showPromissoryNoteInfoDialog(formState,
                        isEdit: hasInfo);
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                tooltip: hasInfo ? 'Düzenle' : 'Ekle',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasInfo)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${isCheck ? 'Çek' : 'Senet'} bilgileri henüz eklenmemiş. Bilgileri eklemek için yukarıdaki butona tıklayın.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else if (isCheck) ...[
            if (metadata['checkNumber'] != null)
              _buildInfoRow('Çek Numarası', metadata['checkNumber'].toString()),
            if (metadata['bankName'] != null)
              _buildInfoRow('Banka', metadata['bankName'].toString()),
            if (metadata['branchName'] != null)
              _buildInfoRow('Şube', metadata['branchName'].toString()),
            if (metadata['accountNumber'] != null)
              _buildInfoRow('Hesap No', metadata['accountNumber'].toString()),
            if (metadata['iban'] != null)
              _buildInfoRow('IBAN', metadata['iban'].toString()),
            if (metadata['checkDate'] != null)
              _buildInfoRow(
                  'Çek Tarihi',
                  DateFormat('dd.MM.yyyy')
                      .format(DateTime.parse(metadata['checkDate']))),
            if (metadata['dueDate'] != null)
              _buildInfoRow(
                  'Vade Tarihi',
                  DateFormat('dd.MM.yyyy')
                      .format(DateTime.parse(metadata['dueDate']))),
          ] else ...[
            if (metadata['noteNumber'] != null)
              _buildInfoRow(
                  'Senet Numarası', metadata['noteNumber'].toString()),
            if (metadata['noteDate'] != null)
              _buildInfoRow(
                  'Senet Tarihi',
                  DateFormat('dd.MM.yyyy')
                      .format(DateTime.parse(metadata['noteDate']))),
            if (metadata['dueDate'] != null)
              _buildInfoRow(
                  'Vade Tarihi',
                  DateFormat('dd.MM.yyyy')
                      .format(DateTime.parse(metadata['dueDate']))),
            if (metadata['interestRate'] != null)
              _buildInfoRow('Faiz Oranı', '${metadata['interestRate']}%'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cari virman için hesap seçimi alanları
  Widget _buildAccountTransferFields(dynamic formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Virman hesabı seçimi (gerçek müşteri/tedarikçi verilerinden)
        const Text(
          'Virman Hesabı',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final customersAsync = ref.watch(customersProvider);
            final suppliersAsync = ref.watch(suppliersProvider);

            return customersAsync.when(
              data: (customers) {
                return suppliersAsync.when(
                  data: (suppliers) {
                    debugPrint('DEBUG: Müşteri sayısı: ${customers.length}');
                    debugPrint('DEBUG: Tedarikçi sayısı: ${suppliers.length}');
                    // Gerçek verilerden seçim
                    final allEntities = [
                      ...customers.map((c) =>
                          {'id': c.id, 'name': c.name, 'type': 'Müşteri'}),
                      ...suppliers.map((s) =>
                          {'id': s.id, 'name': s.name, 'type': 'Tedarikçi'}),
                    ];
                    debugPrint(
                        'DEBUG: Toplam entity sayısı: ${allEntities.length}');

                    // Seçili müşteri filtrelenir
                    final filteredEntities = allEntities.where((entity) {
                      if (entity['id'] == formState.customerId) {
                        return false; // Aynı müşteri filtrelenir
                      }
                      return true; // Diğer hesaplar gösterilir
                    }).toList();

                    return _buildVirmanAccountSelection(
                        filteredEntities, formState);
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Hata: $error'),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Hata: $error'),
            );
          },
        ),
      ],
    );
  }

  /// Virman Hesabı Seçim Widget'ı
  Widget _buildVirmanAccountSelection(
      List<Map<String, dynamic>> entities, dynamic formState) {
    return ElevatedButton.icon(
      onPressed: () {
        debugPrint('DEBUG: Virman hesabı seçimi tıklandı');
        _showVirmanAccountDialog(entities, formState);
      },
      icon: const Icon(Icons.account_balance, size: 20),
      label: Consumer(
        builder: (context, ref, child) {
          final targetAccountId = formState.targetAccountId;
          if (targetAccountId == null) {
            return const Text(
              'Virman hesabı seçin',
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            );
          }

          final customersAsync = ref.watch(customersProvider);
          final suppliersAsync = ref.watch(suppliersProvider);

          return customersAsync.when(
            data: (customers) {
              return suppliersAsync.when(
                data: (suppliers) {
                  // Seçili hesabın adını bul
                  final allEntities = [
                    ...customers.map(
                        (c) => {'id': c.id, 'name': c.name, 'type': 'Müşteri'}),
                    ...suppliers.map((s) =>
                        {'id': s.id, 'name': s.name, 'type': 'Tedarikçi'}),
                  ];

                  final selectedEntity = allEntities.firstWhere(
                    (e) => e['id'] == targetAccountId,
                    orElse: () => {'name': 'Bilinmeyen', 'type': ''},
                  );

                  return Text(
                    '${selectedEntity['name']} (${selectedEntity['type']})',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  );
                },
                loading: () => const Text('Yükleniyor...'),
                error: (error, stack) => const Text('Hata'),
              );
            },
            loading: () => const Text('Yükleniyor...'),
            error: (error, stack) => const Text('Hata'),
          );
        },
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(double.infinity, 56),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  /// Virman Hesabı Dialog
  void _showVirmanAccountDialog(
      List<Map<String, dynamic>> entities, dynamic formState) {
    debugPrint(
        'DEBUG: Virman hesabı dialog açılıyor, entity sayısı: ${entities.length}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Virman Hesabı Seçin'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) {
              final entity = entities[index];
              return ListTile(
                leading: Icon(
                  entity['type'] == 'Müşteri' ? Icons.person : Icons.business,
                  color:
                      entity['type'] == 'Müşteri' ? Colors.blue : Colors.green,
                ),
                title: Text(
                  entity['name'],
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  entity['type'],
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  final notifier =
                      ref.read(paymentTransactionFormProvider.notifier);
                  notifier.updateField('targetAccountId', entity['id']);
                  debugPrint(
                      'DEBUG: Seçilen hesap: ${entity['name']} (${entity['type']})');
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {});
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  /// Çek bilgileri dialog'unu göster
  /// Returns true if saved successfully, false if cancelled
  Future<bool> _showCheckInfoDialog(dynamic formState,
      {bool isEdit = false}) async {
    final metadata = formState.metadata ?? {};
    final checkNumberController = TextEditingController(
        text: isEdit ? (metadata['checkNumber']?.toString() ?? '') : '');
    final bankNameController = TextEditingController(
        text: isEdit ? (metadata['bankName']?.toString() ?? '') : '');
    final branchNameController = TextEditingController(
        text: isEdit ? (metadata['branchName']?.toString() ?? '') : '');
    final accountNumberController = TextEditingController(
        text: isEdit ? (metadata['accountNumber']?.toString() ?? '') : '');
    final ibanController = TextEditingController(
        text: isEdit ? (metadata['iban']?.toString() ?? '') : '');
    DateTime? checkDate = isEdit && metadata['checkDate'] != null
        ? DateTime.parse(metadata['checkDate'])
        : DateTime.now();
    DateTime? dueDate = isEdit && metadata['dueDate'] != null
        ? DateTime.parse(metadata['dueDate'])
        : DateTime.now().add(const Duration(days: 30));

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Çek Bilgilerini Düzenle' : 'Çek Bilgileri'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: checkNumberController,
                    decoration: InputDecoration(
                      labelText: 'Çek Numarası *',
                      border: const OutlineInputBorder(),
                      hintText: 'Sadece rakam (min 6, max 20 karakter)',
                      errorText: checkNumberController.text.isNotEmpty &&
                              !RegExp(r'^[0-9]+$')
                                  .hasMatch(checkNumberController.text)
                          ? 'Sadece rakam girebilirsiniz'
                          : checkNumberController.text.isNotEmpty &&
                                  (checkNumberController.text.length < 6 ||
                                      checkNumberController.text.length > 20)
                              ? '6-20 karakter arası olmalıdır'
                              : null,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(20),
                    ],
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bankNameController,
                    decoration: InputDecoration(
                      labelText: 'Banka Adı *',
                      border: const OutlineInputBorder(),
                      errorText: bankNameController.text.isEmpty &&
                              bankNameController.text.isNotEmpty
                          ? 'Banka adı zorunludur'
                          : null,
                    ),
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: branchNameController,
                    decoration: InputDecoration(
                      labelText: 'Şube Adı *',
                      border: const OutlineInputBorder(),
                      errorText: branchNameController.text.isEmpty &&
                              branchNameController.text.isNotEmpty
                          ? 'Şube adı zorunludur'
                          : null,
                    ),
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: accountNumberController,
                    decoration: InputDecoration(
                      labelText: 'Hesap Numarası *',
                      border: const OutlineInputBorder(),
                      hintText: 'Sadece rakam (min 6, max 20 karakter)',
                      errorText: accountNumberController.text.isNotEmpty &&
                              !RegExp(r'^[0-9]+$')
                                  .hasMatch(accountNumberController.text)
                          ? 'Sadece rakam girebilirsiniz'
                          : accountNumberController.text.isNotEmpty &&
                                  (accountNumberController.text.length < 6 ||
                                      accountNumberController.text.length > 20)
                              ? '6-20 karakter arası olmalıdır'
                              : null,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(20),
                    ],
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ibanController,
                    decoration: InputDecoration(
                      labelText: 'IBAN',
                      border: const OutlineInputBorder(),
                      hintText: 'TR... (15-34 karakter)',
                      errorText: ibanController.text.isNotEmpty &&
                              (ibanController.text.length < 15 ||
                                  ibanController.text.length > 34)
                          ? '15-34 karakter arası olmalıdır'
                          : ibanController.text.isNotEmpty &&
                                  !RegExp(r'^[A-Z0-9]+$').hasMatch(
                                      ibanController.text.toUpperCase())
                              ? 'Sadece harf ve rakam girebilirsiniz'
                              : null,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(34),
                    ],
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Çek Tarihi: ${checkDate != null ? DateFormat('dd.MM.yyyy').format(checkDate!) : 'Seçin'}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: checkDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          checkDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Vade Tarihi: ${dueDate != null ? DateFormat('dd.MM.yyyy').format(dueDate!) : 'Seçin'}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          dueDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // İptal
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validasyon kontrolü
                bool isValid = true;
                String errorMessage = '';
                final checkNumber = checkNumberController.text.trim();
                final accountNumber = accountNumberController.text.trim();

                if (checkNumber.isEmpty) {
                  isValid = false;
                  errorMessage = 'Çek numarası zorunludur';
                } else if (!RegExp(r'^[0-9]+$').hasMatch(checkNumber)) {
                  isValid = false;
                  errorMessage = 'Çek numarası sadece rakam içermelidir';
                } else if (checkNumber.length < 6 || checkNumber.length > 20) {
                  isValid = false;
                  errorMessage = 'Çek numarası 6-20 karakter arası olmalıdır';
                } else if (bankNameController.text.trim().isEmpty) {
                  isValid = false;
                  errorMessage = 'Banka adı zorunludur';
                } else if (branchNameController.text.trim().isEmpty) {
                  isValid = false;
                  errorMessage = 'Şube adı zorunludur';
                } else if (accountNumber.isEmpty) {
                  isValid = false;
                  errorMessage = 'Hesap numarası zorunludur';
                } else if (!RegExp(r'^[0-9]+$').hasMatch(accountNumber)) {
                  isValid = false;
                  errorMessage = 'Hesap numarası sadece rakam içermelidir';
                } else if (accountNumber.length < 6 ||
                    accountNumber.length > 20) {
                  isValid = false;
                  errorMessage = 'Hesap numarası 6-20 karakter arası olmalıdır';
                } else if (checkDate == null) {
                  isValid = false;
                  errorMessage = 'Çek tarihi seçilmelidir';
                } else if (dueDate == null) {
                  isValid = false;
                  errorMessage = 'Vade tarihi seçilmelidir';
                } else if (checkDate != null &&
                    dueDate != null &&
                    dueDate!.isBefore(checkDate!)) {
                  isValid = false;
                  errorMessage = 'Vade tarihi çek tarihinden önce olamaz';
                }

                // IBAN validasyonu (opsiyonel ama doluysa kontrol et)
                final iban = ibanController.text.trim();
                if (iban.isNotEmpty) {
                  if (iban.length < 15 || iban.length > 34) {
                    isValid = false;
                    errorMessage = 'IBAN 15-34 karakter arası olmalıdır';
                  } else if (!RegExp(r'^[A-Z0-9]+$')
                      .hasMatch(iban.toUpperCase())) {
                    isValid = false;
                    errorMessage = 'IBAN sadece harf ve rakam içermelidir';
                  }
                }

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setDialogState(() {});
                  return;
                }

                // Çek bilgilerini metadata'ya ekle
                final formNotifier =
                    ref.read(paymentTransactionFormProvider.notifier);
                // Güncel form state'i oku
                final currentFormState =
                    ref.read(paymentTransactionFormProvider);
                final currentMetadata =
                    Map<String, dynamic>.from(currentFormState.metadata);
                currentMetadata['checkNumber'] =
                    checkNumberController.text.trim();
                currentMetadata['bankName'] = bankNameController.text.trim();
                currentMetadata['branchName'] =
                    branchNameController.text.trim();
                currentMetadata['accountNumber'] =
                    accountNumberController.text.trim();
                if (ibanController.text.trim().isNotEmpty) {
                  currentMetadata['iban'] =
                      ibanController.text.trim().toUpperCase();
                } else {
                  currentMetadata.remove('iban');
                }
                currentMetadata['checkDate'] = checkDate?.toIso8601String();
                currentMetadata['dueDate'] = dueDate?.toIso8601String();
                formNotifier.updateField('metadata', currentMetadata);

                // State'i güncelle
                if (mounted) {
                  setState(() {});
                }

                Navigator.pop(context, true); // Başarılı kayıt
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  /// Senet bilgileri dialog'unu göster
  /// Returns true if saved successfully, false if cancelled
  Future<bool> _showPromissoryNoteInfoDialog(dynamic formState,
      {bool isEdit = false}) async {
    final metadata = formState.metadata ?? {};
    final noteNumberController = TextEditingController(
        text: isEdit ? (metadata['noteNumber']?.toString() ?? '') : '');
    DateTime? noteDate = isEdit && metadata['noteDate'] != null
        ? DateTime.parse(metadata['noteDate'])
        : DateTime.now();
    DateTime? dueDate = isEdit && metadata['dueDate'] != null
        ? DateTime.parse(metadata['dueDate'])
        : DateTime.now().add(const Duration(days: 30));
    final interestRateController = TextEditingController(
        text: isEdit ? (metadata['interestRate']?.toString() ?? '') : '');
    final descriptionController = TextEditingController(
        text: isEdit ? (metadata['description']?.toString() ?? '') : '');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Senet Bilgilerini Düzenle' : 'Senet Bilgileri'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noteNumberController,
                    decoration: InputDecoration(
                      labelText: 'Senet Numarası *',
                      border: const OutlineInputBorder(),
                      hintText: 'Min 3, max 50 karakter',
                      errorText: noteNumberController.text.isNotEmpty &&
                              (noteNumberController.text.length < 3 ||
                                  noteNumberController.text.length > 50)
                          ? '3-50 karakter arası olmalıdır'
                          : null,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Senet Tarihi: ${noteDate != null ? DateFormat('dd.MM.yyyy').format(noteDate!) : 'Seçin'}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: noteDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          noteDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Vade Tarihi: ${dueDate != null ? DateFormat('dd.MM.yyyy').format(dueDate!) : 'Seçin'}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          dueDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: interestRateController,
                    decoration: const InputDecoration(
                      labelText: 'Faiz Oranı (%)',
                      border: OutlineInputBorder(),
                      hintText: 'Örn: 15.5',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // İptal
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validasyon kontrolü
                bool isValid = true;
                String errorMessage = '';
                final noteNumber = noteNumberController.text.trim();

                if (noteNumber.isEmpty) {
                  isValid = false;
                  errorMessage = 'Senet numarası zorunludur';
                } else if (noteNumber.length < 3 || noteNumber.length > 50) {
                  isValid = false;
                  errorMessage = 'Senet numarası 3-50 karakter arası olmalıdır';
                } else if (noteDate == null) {
                  isValid = false;
                  errorMessage = 'Senet tarihi seçilmelidir';
                } else if (dueDate == null) {
                  isValid = false;
                  errorMessage = 'Vade tarihi seçilmelidir';
                } else if (noteDate != null &&
                    dueDate != null &&
                    dueDate!.isBefore(noteDate!)) {
                  isValid = false;
                  errorMessage = 'Vade tarihi senet tarihinden önce olamaz';
                }

                if (interestRateController.text.isNotEmpty) {
                  final interestRate =
                      double.tryParse(interestRateController.text.trim());
                  if (interestRate == null ||
                      interestRate < 0 ||
                      interestRate > 100) {
                    isValid = false;
                    errorMessage =
                        'Faiz oranı 0-100 arası geçerli bir sayı olmalıdır';
                  }
                }

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setDialogState(() {});
                  return;
                }

                final interestRateText = interestRateController.text.trim();
                final descriptionText = descriptionController.text.trim();

                // Senet bilgilerini metadata'ya ekle
                final formNotifier =
                    ref.read(paymentTransactionFormProvider.notifier);
                // Güncel form state'i oku
                final currentFormState =
                    ref.read(paymentTransactionFormProvider);
                final currentMetadata =
                    Map<String, dynamic>.from(currentFormState.metadata);
                currentMetadata['noteNumber'] =
                    noteNumberController.text.trim();
                currentMetadata['noteDate'] = noteDate?.toIso8601String();
                currentMetadata['dueDate'] = dueDate?.toIso8601String();
                if (interestRateText.isNotEmpty) {
                  final interestRate = double.tryParse(interestRateText);
                  if (interestRate != null) {
                    currentMetadata['interestRate'] = interestRate;
                  }
                } else {
                  currentMetadata.remove('interestRate');
                }
                if (descriptionText.isNotEmpty) {
                  currentMetadata['description'] = descriptionText;
                } else {
                  currentMetadata.remove('description');
                }
                formNotifier.updateField('metadata', currentMetadata);

                // State'i güncelle
                if (mounted) {
                  setState(() {});
                }

                Navigator.pop(context, true); // Başarılı kayıt
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  /// Para birimi formatla
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}

/// Hesap seçim dialog widget'ı
class _AccountSelectionDialog extends StatefulWidget {
  final List<Account> accounts;
  final Function(String) onAccountSelected;

  const _AccountSelectionDialog({
    required this.accounts,
    required this.onAccountSelected,
  });

  @override
  State<_AccountSelectionDialog> createState() =>
      _AccountSelectionDialogState();
}

class _AccountSelectionDialogState extends State<_AccountSelectionDialog> {
  late TextEditingController _searchController;
  List<Account> _filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredAccounts = widget.accounts;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final searchText = _searchController.text.toLowerCase();
      if (searchText.isEmpty) {
        _filteredAccounts = widget.accounts;
      } else {
        _filteredAccounts = widget.accounts.where((account) {
          final name = _cleanAccountName(account.name).toLowerCase();
          final type = account.type.displayName.toLowerCase();
          final currency = account.currency.toLowerCase();
          return name.contains(searchText) ||
              type.contains(searchText) ||
              currency.contains(searchText);
        }).toList();
      }
    });
  }

  String _cleanAccountName(String accountName) {
    // Hesap adından gereksiz bilgileri temizle
    String cleaned = accountName;

    // UUID'leri temizle (20+ karakterlik alfanumerik diziler)
    cleaned = cleaned.replaceAll(RegExp(r'[a-zA-Z0-9_]{20,}'), '');

    // Fazla boşlukları temizle
    cleaned = cleaned.trim();

    return cleaned.isEmpty ? accountName : cleaned;
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.account_balance_wallet;
      case AccountType.checking:
        return Icons.account_balance;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.foreign:
        return Icons.currency_exchange;
      case AccountType.other:
        return Icons.account_balance;
    }
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Colors.green;
      case AccountType.checking:
        return Colors.blue;
      case AccountType.savings:
        return Colors.blue.shade300;
      case AccountType.credit:
        return Colors.orange;
      case AccountType.creditCard:
        return Colors.orange;
      case AccountType.investment:
        return Colors.purple;
      case AccountType.foreign:
        return Colors.teal;
      case AccountType.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hesap Seçin'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arama kutusu
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Hesap ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Hesap listesi
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                  minHeight: 100.0,
                ),
                child: _filteredAccounts.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Hesap bulunamadı',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredAccounts.length,
                        itemBuilder: (context, index) {
                          final account = _filteredAccounts[index];
                          return ListTile(
                            leading: Icon(
                              _getAccountTypeIcon(account.type),
                              color: _getAccountTypeColor(account.type),
                            ),
                            title: Text(
                              _cleanAccountName(account.name),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${account.type.displayName} - ${account.currency} - ${account.balance.toStringAsFixed(2)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              widget.onAccountSelected(account.id);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
      ],
    );
  }
}
