// ========== lib/features/invoices/presentation/pages/invoices_list_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../domain/entities/invoice.dart';
import '../../data/models/invoice_status.dart';
import '../providers/invoice_providers.dart';

/// Faturalar listesi sayfası - Tam fonksiyonel
class InvoicesListPage extends ConsumerStatefulWidget {
  const InvoicesListPage({super.key});

  @override
  ConsumerState<InvoicesListPage> createState() => _InvoicesListPageState();
}

class _InvoicesListPageState extends ConsumerState<InvoicesListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Invoice verilerini dinle
    final invoicesAsync = ref.watch(invoicesProvider);
    // ignore: unused_local_variable
    final searchQuery = ref.watch(invoiceSearchQueryProvider);
    final selectedStatus = ref.watch(selectedInvoiceStatusProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Faturalar'),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: isDark
            ? TamgaciConstants.textPrimaryDark
            : TamgaciConstants.textPrimary,
        actions: [
          // Filtreleme butonu
          PopupMenuButton<InvoiceStatus?>(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_outlined),
                if (selectedStatus != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: TamgaciConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onSelected: (status) {
              ref.read(selectedInvoiceStatusProvider.notifier).state = status;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text(
                  'Tüm Faturalar',
                  style: TextStyle(
                    fontWeight: selectedStatus == null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              ...InvoiceStatus.values.map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.displayName,
                        style: TextStyle(
                          fontWeight: selectedStatus == status
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fatura sayısı
          Consumer(
            builder: (context, ref, child) {
              final countAsync = ref.watch(invoiceCountProvider);
              return countAsync.when(
                data: (count) => Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TamgaciConstants.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TamgaciConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Arama çubuğu
          _buildSearchBar(),

          // İstatistik kartları
          _buildStatsCards(),

          // Fatura listesi
          Expanded(
            child: invoicesAsync.when(
              data: (invoices) => _buildInvoiceList(invoices),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TamgaciRoutes.pushNamed(context, TamgaciRoutes.createInvoice);
        },
        child: const Icon(Icons.receipt_long),
      ),
    );
  }

  /// Arama çubuğu widget'ı
  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: TamgaciConstants.paddingMedium(context),
      decoration: BoxDecoration(
        color: isDark
            ? TamgaciConstants.surfaceColorDark
            : TamgaciConstants.surfaceColor,
        border: const Border(
          bottom: BorderSide(
            color: TamgaciConstants.borderColor,
            width: 1,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDark
              ? TamgaciConstants.textPrimaryDark
              : TamgaciConstants.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Fatura ara (numara, açıklama)...',
          prefixIcon: const Icon(Icons.search_outlined),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(invoiceSearchQueryProvider.notifier).state = '';
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark
              ? TamgaciConstants.backgroundColorDark
              : TamgaciConstants.backgroundColor,
          hintStyle: TextStyle(
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
        ),
        onChanged: (value) {
          ref.read(invoiceSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  /// İstatistik kartları
  Widget _buildStatsCards() {
    return Container(
      padding: TamgaciConstants.paddingMedium(context),
      child: Row(
        children: [
          // Bu ay gelir
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final revenueAsync = ref.watch(currentMonthRevenueProvider);
                return revenueAsync.when(
                  data: (revenue) => _buildStatCard(
                    'Bu Ay Gelir',
                    '₺${revenue.toStringAsFixed(2)}',
                    Icons.trending_up,
                    TamgaciConstants.successColor,
                  ),
                  loading: () => _buildStatCardLoading(),
                  error: (error, stack) => _buildStatCard(
                    'Bu Ay Gelir',
                    '₺0,00',
                    Icons.trending_up,
                    TamgaciConstants.successColor,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: TamgaciConstants.spaceMD),

          // Bekleyen ödeme
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final pendingAsync = ref.watch(pendingPaymentAmountProvider);
                return pendingAsync.when(
                  data: (pending) => _buildStatCard(
                    'Bekleyen Ödeme',
                    '₺${pending.toStringAsFixed(2)}',
                    Icons.schedule,
                    TamgaciConstants.warningColor,
                  ),
                  loading: () => _buildStatCardLoading(),
                  error: (error, stack) => _buildStatCard(
                    'Bekleyen Ödeme',
                    '₺0,00',
                    Icons.schedule,
                    TamgaciConstants.warningColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// İstatistik kartı
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: isDark
            ? TamgaciConstants.cardColorDark
            : TamgaciConstants.cardColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        boxShadow: TamgaciConstants.shadowLight,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? TamgaciConstants.textPrimaryDark
                      : TamgaciConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Yükleme durumunda stat kartı
  Widget _buildStatCardLoading() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: isDark
            ? TamgaciConstants.cardColorDark
            : TamgaciConstants.cardColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        boxShadow: TamgaciConstants.shadowLight,
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  /// Fatura listesi widget'ı
  Widget _buildInvoiceList(List<Invoice> invoices) {
    // Filtreleme uygula
    final selectedStatus = ref.watch(selectedInvoiceStatusProvider);
    final searchQuery = ref.watch(invoiceSearchQueryProvider);

    List<Invoice> filteredInvoices = invoices;

    // Durum filtresi
    if (selectedStatus != null) {
      filteredInvoices = filteredInvoices
          .where((invoice) => invoice.status == selectedStatus)
          .toList();
    }

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredInvoices = filteredInvoices.where((invoice) {
        return invoice.invoiceNumber.toLowerCase().contains(query) ||
            (invoice.description?.toLowerCase().contains(query) ?? false) ||
            (invoice.customer?.name.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (filteredInvoices.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(invoicesStreamProvider);
      },
      child: ListView.separated(
        padding: TamgaciConstants.pagePadding(context),
        itemCount: filteredInvoices.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: TamgaciConstants.spaceXS),
        itemBuilder: (context, index) {
          final invoice = filteredInvoices[index];
          return _buildInvoiceCard(invoice);
        },
      ),
    );
  }

  /// Fatura kartı widget'ı
  Widget _buildInvoiceCard(Invoice invoice) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(invoice.status);
    final isOverdue = invoice.isOverdue;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: isDark ? TamgaciConstants.cardColorDark : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        side: isOverdue
            ? BorderSide(
                color: TamgaciConstants.errorColor.withValues(alpha: 0.3),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          TamgaciRoutes.pushNamed(
            context,
            TamgaciRoutes.invoiceDetail,
            arguments: invoice.id,
          );
        },
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: Fatura numarası, durum, tutar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? TamgaciConstants.textPrimaryDark
                                : TamgaciConstants.textPrimary,
                          ),
                        ),
                        if (invoice.customer != null)
                          Text(
                            invoice.customer!.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? TamgaciConstants.textSecondaryDark
                                  : TamgaciConstants.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Durum badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.statusDisplayName,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceSM),

              // Alt satır: Tarih, tutar, işlemler
              Row(
                children: [
                  // Tarih bilgisi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: isDark
                                  ? TamgaciConstants.textSecondaryDark
                                  : TamgaciConstants.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(invoice.invoiceDate),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? TamgaciConstants.textSecondaryDark
                                    : TamgaciConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (invoice.dueDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: isOverdue
                                    ? TamgaciConstants.errorColor
                                    : (isDark
                                        ? TamgaciConstants.textSecondaryDark
                                        : TamgaciConstants.textSecondary),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Vade: ${DateFormat('dd/MM/yyyy').format(invoice.dueDate!)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: isOverdue
                                      ? TamgaciConstants.errorColor
                                      : (isDark
                                          ? TamgaciConstants.textSecondaryDark
                                          : TamgaciConstants.textSecondary),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Tutar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        invoice.formattedTotalAmount,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? TamgaciConstants.textPrimaryDark : TamgaciConstants.textPrimary,
                        ),
                      ),
                      Text(
                        '${invoice.items.length} kalem',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isDark ? TamgaciConstants.textSecondaryDark : TamgaciConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // İşlemler menüsü
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? TamgaciConstants.textSecondaryDark : TamgaciConstants.textSecondary,
                    ),
                    onSelected: (action) =>
                        _handleInvoiceAction(action, invoice),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility_outlined),
                          title: Text('Görüntüle'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (invoice.canEdit)
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Düzenle'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      if (invoice.canSend)
                        const PopupMenuItem(
                          value: 'send',
                          child: ListTile(
                            leading: Icon(Icons.send_outlined),
                            title: Text('Gönder'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      if (invoice.canMarkAsPaid)
                        const PopupMenuItem(
                          value: 'mark_paid',
                          child: ListTile(
                            leading: Icon(
                              Icons.payment_outlined,
                              color: Colors.green,
                            ),
                            title: Text(
                              'Ödendi İşaretle',
                              style: TextStyle(color: Colors.green),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Sil',
                            style: TextStyle(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
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

  /// Boş durum widget'ı
  Widget _buildEmptyState() {
    final selectedStatus = ref.watch(selectedInvoiceStatusProvider);
    final searchQuery = ref.watch(invoiceSearchQueryProvider);

    String message;
    if (searchQuery.isNotEmpty) {
      message = 'Arama sonucu bulunamadı';
    } else if (selectedStatus != null) {
      message = '${selectedStatus.displayName} durumunda fatura bulunamadı';
    } else {
      message = 'Henüz fatura oluşturulmamış';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: TamgaciConstants.textDisabled,
          ),
          const SizedBox(height: TamgaciConstants.spaceLG),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: TamgaciConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          if (searchQuery.isEmpty && selectedStatus == null)
            ElevatedButton.icon(
              onPressed: () {
                TamgaciRoutes.pushNamed(context, TamgaciRoutes.createInvoice);
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('İlk Faturayı Oluştur'),
            ),
        ],
      ),
    );
  }

  /// Hata durumu widget'ı
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: TamgaciConstants.errorColor,
          ),
          const SizedBox(height: TamgaciConstants.spaceLG),
          Text(
            'Faturalar yüklenirken hata oluştu',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: TamgaciConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TamgaciConstants.spaceSM),
          Text(
            error.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: TamgaciConstants.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TamgaciConstants.spaceLG),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(invoicesStreamProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// Durum rengini getir
  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return TamgaciConstants.primaryColor;
      case InvoiceStatus.paid:
        return TamgaciConstants.successColor;
      case InvoiceStatus.overdue:
        return TamgaciConstants.errorColor;
      case InvoiceStatus.cancelled:
        return Colors.blueGrey;
      case InvoiceStatus.partiallyPaid:
        return TamgaciConstants.warningColor;
      case InvoiceStatus.unpaid:
        return Colors.deepOrange;
    }
  }

  /// Fatura aksiyon işleyici
  void _handleInvoiceAction(String action, Invoice invoice) {
    switch (action) {
      case 'view':
        TamgaciRoutes.pushNamed(
          context,
          TamgaciRoutes.invoiceDetail,
          arguments: invoice.id,
        );
        break;
      case 'edit':
        Navigator.of(context).pushNamed('/invoice/edit', arguments: invoice.id);
        break;
      case 'send':
        _showSendConfirmation(invoice);
        break;
      case 'mark_paid':
        _showMarkAsPaidConfirmation(invoice);
        break;
      case 'delete':
        _showDeleteConfirmation(invoice);
        break;
    }
  }

  /// Gönderme onayı
  void _showSendConfirmation(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faturayı Gönder'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı ${invoice.customer?.name ?? 'müşteriye'} göndermek istediğinizden emin misiniz?',
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
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.updateInvoiceStatus(
                  invoice.id,
                  InvoiceStatus.sent,
                );

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${invoice.invoiceNumber} gönderildi'),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gönderme işlemi başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  /// Ödendi işaretleme onayı
  void _showMarkAsPaidConfirmation(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödendi İşaretle'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı ödendi olarak işaretlemek istediğinizden emin misiniz?',
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
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.markInvoiceAsPaid(invoice.id);

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${invoice.invoiceNumber} ödendi olarak işaretlendi',
                      ),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İşlem başarısız: $e'),
                      backgroundColor: TamgaciConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TamgaciConstants.successColor,
            ),
            child: const Text('Ödendi İşaretle'),
          ),
        ],
      ),
    );
  }

  /// Silme onayı
  void _showDeleteConfirmation(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faturayı Sil'),
        content: Text(
          '${invoice.invoiceNumber} numaralı faturayı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
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
                final repository = ref.read(invoiceRepositoryProvider);
                await repository.deleteInvoice(invoice.id);

                // Provider'ı yenile
                ref.invalidate(invoicesProvider);

                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${invoice.invoiceNumber} başarıyla silindi',
                      ),
                      backgroundColor: TamgaciConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
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

// ========== DOSYA YERLEŞTİRME TALİMATLARI ==========

/*
📁 Bu dosyaların yerleştirilmesi gereken konumlar:

1. 📄 invoices_list_page.dart
   → lib/features/invoices/presentation/pages/invoices_list_page.dart
   (Mevcut placeholder'ı değiştir)

========== ÖNEMLİ NOTLAR ==========

✅ Tam fonksiyonel invoice list
✅ Status filtering ve search
✅ Real-time data streaming
✅ Status management (send, mark paid, delete)
✅ Complex business logic handling
✅ Overdue invoice highlighting
✅ Revenue statistics
✅ Responsive design
✅ Error handling
✅ Loading states

Artık tam çalışan bir invoice list sayfanız var! 

Sonraki adım: Create Invoice Page (daha karmaşık - items management)
*/
