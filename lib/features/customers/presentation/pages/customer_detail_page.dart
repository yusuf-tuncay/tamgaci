// ========== lib/features/customers/presentation/pages/customer_detail_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/features/customers/data/models/customer_entity.dart';
import 'package:tamgaci/features/customers/presentation/pages/edit_customer_page.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_providers.dart';

/// Müşteri detay sayfası - Tam fonksiyonel
class CustomerDetailPage extends ConsumerWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerStreamProvider(customerId));

    return customerAsync.when(
      data: (customer) => customer != null
          ? _CustomerDetailView(customer: customer)
          : _CustomerNotFound(),
      loading: () => _CustomerDetailLoading(),
      error: (error, stack) => _CustomerDetailError(error: error),
    );
  }
}

/// Müşteri detay görünümü
class _CustomerDetailView extends ConsumerWidget {
  final Customer customer;

  const _CustomerDetailView({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: Text(customer.name),
        elevation: 0,
        backgroundColor: TamgaciConstants.appBarColor,
        foregroundColor: TamgaciConstants.textPrimary,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          // Düzenle butonu
          IconButton(
            onPressed: () {
              // TODO: Edit sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditCustomerPage(customerId: customer.id),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),

          // Daha fazla seçenek
          PopupMenuButton<String>(
            onSelected: (action) => _handleAction(context, ref, action),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Düzenle'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'deactivate',
                child: ListTile(
                  leading: Icon(Icons.visibility_off_outlined),
                  title: Text('Pasif Yap'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Sil', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: TamgaciConstants.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Müşteri başlık kartı
            _buildHeaderCard(),

            const SizedBox(height: TamgaciConstants.spaceLG),

            // İletişim bilgileri
            _buildContactInfoCard(),

            const SizedBox(height: TamgaciConstants.spaceLG),

            // Vergi bilgileri (kurumsal için)
            if (customer.customerType == CustomerType.company)
              _buildTaxInfoCard(),

            if (customer.customerType == CustomerType.company)
              const SizedBox(height: TamgaciConstants.spaceLG),

            // Adres bilgileri
            if (customer.fullAddress.isNotEmpty) _buildAddressInfoCard(),

            if (customer.fullAddress.isNotEmpty)
              const SizedBox(height: TamgaciConstants.spaceLG),

            // Notlar
            if (customer.notes != null && customer.notes!.isNotEmpty)
              _buildNotesCard(),

            if (customer.notes != null && customer.notes!.isNotEmpty)
              const SizedBox(height: TamgaciConstants.spaceLG),

            // İstatistikler (gelecek için placeholder)
            _buildStatsCard(),

            const SizedBox(height: TamgaciConstants.spaceXXL),
          ],
        ),
      ),
    );
  }

  /// Başlık kartı
  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: customer.customerType == CustomerType.company
                    ? TamgaciConstants.primaryLight
                    : TamgaciConstants.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: customer.initials.isEmpty
                    ? Icon(
                        customer.customerType == CustomerType.company
                            ? Icons.business
                            : Icons.person,
                        size: 40,
                        color: customer.customerType == CustomerType.company
                            ? TamgaciConstants.primaryColor
                            : TamgaciConstants.secondaryColor,
                      )
                    : Text(
                        customer.initials,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: customer.customerType == CustomerType.company
                              ? TamgaciConstants.primaryColor
                              : TamgaciConstants.secondaryColor,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: TamgaciConstants.spaceMD),

            // İsim
            Text(
              customer.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: TamgaciConstants.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: TamgaciConstants.spaceXS),

            // Müşteri tipi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: customer.customerType == CustomerType.company
                    ? TamgaciConstants.primaryLight.withValues(alpha: 0.2)
                    : TamgaciConstants.secondaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                customer.customerType.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: customer.customerType == CustomerType.company
                      ? TamgaciConstants.primaryColor
                      : TamgaciConstants.secondaryColor,
                ),
              ),
            ),

            const SizedBox(height: TamgaciConstants.spaceMD),

            // Durum
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: customer.isActive
                        ? TamgaciConstants.successColor
                        : TamgaciConstants.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: TamgaciConstants.spaceXS),
                Text(
                  customer.isActive ? 'Aktif' : 'Pasif',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: customer.isActive
                        ? TamgaciConstants.successColor
                        : TamgaciConstants.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// İletişim bilgileri kartı
  Widget _buildContactInfoCard() {
    final contactItems = <Map<String, dynamic>>[];

    if (customer.email != null && customer.email!.isNotEmpty) {
      contactItems.add({
        'icon': Icons.email_outlined,
        'title': 'E-posta',
        'value': customer.email!,
        'action': () {
          /* TODO: E-posta gönder */
        },
      });
    }

    if (customer.phone != null && customer.phone!.isNotEmpty) {
      contactItems.add({
        'icon': Icons.phone_outlined,
        'title': 'Telefon',
        'value': customer.phone!,
        'action': () {
          /* TODO: Ara */
        },
      });
    }

    if (contactItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İletişim Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            ...contactItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(
                  bottom: TamgaciConstants.spaceSM,
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: TamgaciConstants.textSecondary,
                    ),
                    const SizedBox(width: TamgaciConstants.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: TamgaciConstants.textSecondary,
                            ),
                          ),
                          Text(
                            item['value'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: TamgaciConstants.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: item['action'] as VoidCallback,
                      icon: const Icon(Icons.launch),
                      iconSize: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vergi bilgileri kartı
  Widget _buildTaxInfoCard() {
    if (customer.taxNumber == null && customer.taxOffice == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vergi Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            if (customer.taxNumber != null) ...[
              _buildInfoRow('Vergi Numarası', customer.taxNumber!),
              const SizedBox(height: TamgaciConstants.spaceSM),
            ],
            if (customer.taxOffice != null)
              _buildInfoRow('Vergi Dairesi', customer.taxOffice!),
          ],
        ),
      ),
    );
  }

  /// Adres bilgileri kartı
  Widget _buildAddressInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adres Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: TamgaciConstants.textSecondary,
                ),
                const SizedBox(width: TamgaciConstants.spaceMD),
                Expanded(
                  child: Text(
                    customer.fullAddress,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: TamgaciConstants.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Notlar kartı
  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notlar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            Text(
              customer.notes!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: TamgaciConstants.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// İstatistikler kartı (gelecek için placeholder)
  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Müşteri İstatistikleri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Toplam Fatura',
                    '0',
                    Icons.receipt_long,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Toplam Tutar',
                    '₺0',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Son İşlem', 'Yok', Icons.schedule),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Kayıt Tarihi',
                    '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// İstatistik öğesi
  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: TamgaciConstants.surfaceColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: TamgaciConstants.primaryColor),
          const SizedBox(height: TamgaciConstants.spaceXS),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TamgaciConstants.textPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: TamgaciConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Bilgi satırı
  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: TamgaciConstants.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TamgaciConstants.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Aksiyon işleyici
  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCustomerPage(customerId: customer.id),
          ),
        );
        break;
      case 'deactivate':
        _showDeactivateConfirmation(context, ref);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
    }
  }

  /// Pasif yapma onayı
  void _showDeactivateConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.isActive ? 'Pasif Yap' : 'Aktif Yap'),
        content: Text(
          '${customer.name} müşterisini ${customer.isActive ? 'pasif' : 'aktif'} yapmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(customerRepositoryProvider);
                await repository.updateCustomerStatus(
                  customer.id,
                  !customer.isActive,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${customer.name} ${customer.isActive ? 'pasif' : 'aktif'} yapıldı',
                      ),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İşlem başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(customer.isActive ? 'Pasif Yap' : 'Aktif Yap'),
          ),
        ],
      ),
    );
  }

  /// Silme onayı
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: Text(
          '${customer.name} müşterisini kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(customerRepositoryProvider);
                await repository.deleteCustomer(customer.id);

                if (context.mounted) {
                  Navigator.of(context).pop(); // Detail sayfasından çık
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${customer.name} başarıyla silindi'),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Silme işlemi başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

/// Müşteri bulunamadı durumu
class _CustomerNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Müşteri Bulunamadı')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 80,
              color: TamgaciConstants.textDisabled,
            ),
            SizedBox(height: TamgaciConstants.spaceLG),
            Text(
              'Müşteri bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: TamgaciConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yükleme durumu
class _CustomerDetailLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Müşteri Detayı')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// Hata durumu
class _CustomerDetailError extends StatelessWidget {
  final Object error;

  const _CustomerDetailError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hata')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: TamgaciConstants.errorColor,
            ),
            const SizedBox(height: TamgaciConstants.spaceLG),
            const Text(
              'Müşteri yüklenirken hata oluştu',
              style: TextStyle(
                fontSize: 18,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: TamgaciConstants.spaceMD),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: TamgaciConstants.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
