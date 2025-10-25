// ========== TRANSACTION FORM SCREEN ==========
// lib/features/payment_collection/presentation/pages/transaction_form_screen.dart

import 'package:flutter/material.dart';
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
              // İşlem türü - Hesap transferi için özel widget
              if (formState.type == PaymentTransactionType.accountTransfer)
                _buildTransactionTypeFieldForTransfer(formState)
              else
                TransactionFormFields.buildTransactionTypeField(
                  formState: formState,
                  onChanged: (value) {
                    _updateField('type', value);
                    // İşlem türü değiştiğinde hesap seçimini yeniden hesapla
                    _updateAccountSelection();
                  },
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

              // Hesap seçimi - Borç/Alacak fişleri için gizle
              if (formState.type != PaymentTransactionType.debtReceipt &&
                  formState.type != PaymentTransactionType.creditReceipt)
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

              // Hesap transferi için müşteri+tedarikçi karışık seçim
              if (formState.type == PaymentTransactionType.accountTransfer)
                _buildSimpleAccountTransferField(formState)
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
  }

  /// İşlem türü değiştiğinde hesap seçimini güncelle
  void _updateAccountSelection() {
    // Hesap seçimini yeniden hesaplamak için state'i güncelle
    setState(() {
      // Bu, hesap seçimi widget'ının yeniden render edilmesini sağlar
    });
  }

  /// Hesap türüne göre ikon döndür
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

  /// Hesap türüne göre renk döndür
  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Colors.green;
      case AccountType.checking:
        return Colors.blue;
      case AccountType.savings:
        return Colors.teal;
      case AccountType.credit:
        return Colors.orange;
      case AccountType.creditCard:
        return Colors.red;
      case AccountType.investment:
        return Colors.purple;
      case AccountType.foreign:
        return Colors.indigo;
      case AccountType.other:
        return Colors.grey;
    }
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
      // EFT/Havale için: Banka hesabı + aynı para birimi
      final bankAccounts = accounts
          .where((account) =>
              account.type == AccountType.checking &&
              account.currency == currency)
          .toList();

      if (bankAccounts.isNotEmpty) {
        debugPrint('DEBUG: Banka hesabı bulundu: ${bankAccounts.first.name}');
        return bankAccounts.first.id;
      }

      // Eğer AccountType.checking bulunamazsa, isim kontrolü yap
      final bankByName = accounts
          .where((account) =>
              account.currency == currency &&
              (account.name.toLowerCase().contains('banka') ||
                  account.name.toLowerCase().contains('bank') ||
                  account.name.toLowerCase().contains('çek') ||
                  account.name.toLowerCase().contains('checking')))
          .toList();

      if (bankByName.isNotEmpty) {
        debugPrint(
            'DEBUG: Banka hesabı (isim kontrolü) bulundu: ${bankByName.first.name}');
        return bankByName.first.id;
      }

      // Eğer banka hesabı hiç bulunamazsa, null döndür (hesap yok göster)
      debugPrint(
          'DEBUG: EFT için banka hesabı bulunamadı - hesap yok gösterilecek');
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

    // 2. İkinci öncelik: Aynı para birimindeki hesaplar
    final sameCurrencyAccounts =
        accounts.where((account) => account.currency == currency).toList();

    if (sameCurrencyAccounts.isNotEmpty) {
      debugPrint(
          'DEBUG: Aynı para birimindeki hesap bulundu: ${sameCurrencyAccounts.first.name}');
      return sameCurrencyAccounts.first.id;
    }

    // 3. Son seçenek: İlk hesap
    if (accounts.isNotEmpty) {
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
        List<Account> filteredAccounts = accounts;
        if (formState.type == PaymentTransactionType.accountTransfer) {
          // Seçili müşteri/tedarikçi ile aynı hesap filtrelenmeli
          final selectedCustomerId = formState.customerId;
          final selectedSupplierId = formState.supplierId;

          if (selectedCustomerId != null || selectedSupplierId != null) {
            // Müşteri/tedarikçi hesaplarını filtrele
            filteredAccounts = accounts.where((account) {
              // Müşteri seçildiyse, o müşteri ile ilgili hesapları filtrele
              if (selectedCustomerId != null) {
                // Hesap adında müşteri ID'si veya 'müşteri' kelimesi varsa filtrele
                if (account.name
                        .toLowerCase()
                        .contains(selectedCustomerId.toLowerCase()) ||
                    account.name.toLowerCase().contains('müşteri') ||
                    account.name.toLowerCase().contains('customer')) {
                  return false; // Bu müşteri hesaplarını filtrele
                }
              }

              // Tedarikçi seçildiyse, o tedarikçi ile ilgili hesapları filtrele
              if (selectedSupplierId != null) {
                // Hesap adında tedarikçi ID'si veya 'tedarikçi' kelimesi varsa filtrele
                if (account.name
                        .toLowerCase()
                        .contains(selectedSupplierId.toLowerCase()) ||
                    account.name.toLowerCase().contains('tedarikçi') ||
                    account.name.toLowerCase().contains('supplier')) {
                  return false; // Bu tedarikçi hesaplarını filtrele
                }
              }

              return true;
            }).toList();
          }
        }

        return AlertDialog(
          title: const Text('Hesap Seçin'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.6, // Ekranın %60'ı
              maxWidth:
                  MediaQuery.of(context).size.width * 0.9, // Ekranın %90'ı
            ),
            child: filteredAccounts.isEmpty
                ? const Center(
                    child: Text(
                      'Hesap bulunamadı',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredAccounts.length,
                    itemBuilder: (context, index) {
                      final account = filteredAccounts[index];
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
                          _updateField('accountId', account.id);
                          Navigator.of(context).pop();
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
        );
      },
    );
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

  /// Basit hesap transferi widget'ı - sadece dialog
  Widget _buildSimpleAccountTransferField(dynamic formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Müşteri/Tedarikçi Seçimi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showSimpleAccountTransferDialog(formState),
            icon: const Icon(Icons.people),
            label: Consumer(
              builder: (context, ref, child) {
                final selectedId = formState.customerId ?? formState.supplierId;
                if (selectedId == null) {
                  return const Text('Müşteri/Tedarikçi Seçin');
                }

                // Müşteri ID'si varsa müşteri adını bul
                if (formState.customerId != null) {
                  final customersAsync = ref.watch(customersProvider);
                  return customersAsync.when(
                    data: (customers) {
                      try {
                        final customer =
                            customers.firstWhere((c) => c.id == selectedId);
                        return Text('Seçili: ${customer.name} (Müşteri)');
                      } catch (e) {
                        return Text('Seçili: $selectedId');
                      }
                    },
                    loading: () => Text('Seçili: $selectedId'),
                    error: (error, stack) => Text('Seçili: $selectedId'),
                  );
                }

                // Tedarikçi ID'si varsa tedarikçi adını bul
                if (formState.supplierId != null) {
                  final suppliersAsync = ref.watch(suppliersProvider);
                  return suppliersAsync.when(
                    data: (suppliers) {
                      try {
                        final supplier =
                            suppliers.firstWhere((s) => s.id == selectedId);
                        return Text('Seçili: ${supplier.name} (Tedarikçi)');
                      } catch (e) {
                        return Text('Seçili: $selectedId');
                      }
                    },
                    loading: () => Text('Seçili: $selectedId'),
                    error: (error, stack) => Text('Seçili: $selectedId'),
                  );
                }

                return const Text('Müşteri/Tedarikçi Seçin');
              },
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
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
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: PaymentTransactionType.values.length,
            itemBuilder: (context, index) {
              final type = PaymentTransactionType.values[index];
              return ListTile(
                leading: Icon(
                  Icons.payment,
                  color: Colors.blue,
                ),
                title: Text(
                  type.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  _updateField('type', type);
                  _updateAccountSelection();
                  Navigator.pop(context);
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

  /// Basit hesap transferi dialog'u
  void _showSimpleAccountTransferDialog(dynamic formState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteri/Tedarikçi Seçin'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Consumer(
            builder: (context, ref, child) {
              final customersAsync = ref.watch(customersProvider);
              final suppliersAsync = ref.watch(suppliersProvider);

              return customersAsync.when(
                data: (customers) => suppliersAsync.when(
                  data: (suppliers) {
                    final allEntities = <Map<String, dynamic>>[];

                    // Müşterileri ekle
                    for (final customer in customers) {
                      allEntities.add({
                        'id': customer.id,
                        'name': customer.name,
                        'type': 'Müşteri',
                      });
                    }

                    // Tedarikçileri ekle
                    for (final supplier in suppliers) {
                      allEntities.add({
                        'id': supplier.id,
                        'name': supplier.name,
                        'type': 'Tedarikçi',
                      });
                    }

                    // İsme göre sırala
                    allEntities.sort((a, b) => a['name'].compareTo(b['name']));

                    return ListView.builder(
                      itemCount: allEntities.length,
                      itemBuilder: (context, index) {
                        final entity = allEntities[index];
                        return ListTile(
                          leading: Icon(
                            entity['type'] == 'Müşteri'
                                ? Icons.person
                                : Icons.business,
                            color: entity['type'] == 'Müşteri'
                                ? Colors.blue
                                : Colors.green,
                          ),
                          title: Text(entity['name']),
                          subtitle: Text(entity['type']),
                          onTap: () {
                            if (entity['type'] == 'Müşteri') {
                              _updateField('customerId', entity['id']);
                              _updateField('supplierId', null);
                            } else {
                              _updateField('supplierId', entity['id']);
                              _updateField('customerId', null);
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Text('Tedarikçiler yüklenemedi: $error'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Müşteriler yüklenemedi: $error'),
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

  /// Hesap adından ID'leri temizle
  String _cleanAccountName(String accountName) {
    // ID'leri temizle (genellikle _ ile başlayan veya uzun string'ler)
    String cleaned = accountName;
    
    // Müşteri/tedarikçi ID'lerini temizle
    // Örnek: "Ahmet Yılmaz_customer_123" -> "Ahmet Yılmaz"
    cleaned = cleaned.replaceAll(RegExp(r'_[a-zA-Z0-9_]+$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[a-zA-Z0-9_]{20,}'), '');
    
    // Fazla boşlukları temizle
    cleaned = cleaned.trim();
    
    return cleaned.isEmpty ? accountName : cleaned;
  }
}
