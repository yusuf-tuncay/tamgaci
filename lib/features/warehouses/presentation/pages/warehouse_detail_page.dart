import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/warehouse.dart';
import '../providers/warehouse_providers.dart';
import 'create_warehouse_page.dart';

/// Depo Detay Sayfası
class WarehouseDetailPage extends ConsumerStatefulWidget {
  final Warehouse warehouse;

  const WarehouseDetailPage({
    super.key,
    required this.warehouse,
  });

  @override
  ConsumerState<WarehouseDetailPage> createState() =>
      _WarehouseDetailPageState();
}

class _WarehouseDetailPageState extends ConsumerState<WarehouseDetailPage>
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
          _buildWarehouseCard(),
          _buildDetailsSection(),
          _buildLocationSection(),
          _buildContactSection(),
          _buildCapacitySection(),
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
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.black87, size: 24),
          onPressed: _editWarehouse,
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

  Widget _buildWarehouseCard() {
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
                  gradient: _getWarehouseGradient(),
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
                      child: Center(
                        child: Text(
                          widget.warehouse.type.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.warehouse.name,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.warehouse.type.displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor().withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.warehouse.status.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(),
                              ),
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
                    Text(
                      'Depo Bilgileri',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Depo Adı', widget.warehouse.name),
                    if (widget.warehouse.description != null)
                      _buildInfoRow('Açıklama', widget.warehouse.description!),
                    _buildInfoRow(
                        'Depo Türü', widget.warehouse.type.displayName),
                    _buildInfoRow('Durum', widget.warehouse.status.displayName),
                    _buildInfoRow(
                        'Aktif', widget.warehouse.isActive ? 'Evet' : 'Hayır'),
                    if (widget.warehouse.notes != null)
                      _buildInfoRow('Notlar', widget.warehouse.notes!),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationSection() {
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
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Konum Bilgileri',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Adres', widget.warehouse.address),
                    if (widget.warehouse.city != null)
                      _buildInfoRow('Şehir', widget.warehouse.city!),
                    if (widget.warehouse.state != null)
                      _buildInfoRow('İl', widget.warehouse.state!),
                    if (widget.warehouse.country != null)
                      _buildInfoRow('Ülke', widget.warehouse.country!),
                    if (widget.warehouse.postalCode != null)
                      _buildInfoRow('Posta Kodu', widget.warehouse.postalCode!),
                    if (widget.warehouse.latitude != null &&
                        widget.warehouse.longitude != null)
                      _buildInfoRow('Koordinatlar',
                          '${widget.warehouse.latitude}, ${widget.warehouse.longitude}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactSection() {
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
                      children: [
                        Icon(Icons.contact_phone,
                            color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'İletişim Bilgileri',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.warehouse.phone != null)
                      _buildInfoRow('Telefon', widget.warehouse.phone!),
                    if (widget.warehouse.email != null)
                      _buildInfoRow('E-posta', widget.warehouse.email!),
                    if (widget.warehouse.managerName != null)
                      _buildInfoRow('Sorumlu', widget.warehouse.managerName!),
                    if (widget.warehouse.managerPhone != null)
                      _buildInfoRow(
                          'Sorumlu Telefon', widget.warehouse.managerPhone!),
                    if (widget.warehouse.managerEmail != null)
                      _buildInfoRow(
                          'Sorumlu E-posta', widget.warehouse.managerEmail!),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCapacitySection() {
    if (widget.warehouse.capacity == null)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

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
                      children: [
                        Icon(Icons.storage,
                            color: Colors.orange[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Kapasite Bilgileri',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Kapasite',
                        '${widget.warehouse.capacity} ${widget.warehouse.capacityUnit ?? 'm²'}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editWarehouse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateWarehousePage(existingWarehouse: widget.warehouse),
      ),
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
              leading: const Icon(Icons.edit),
              title: Text(
                'Düzenle',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                _editWarehouse();
              },
            ),
            if (!widget.warehouse.isDefault)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Depoyu Sil',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(
                'Paylaş',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                // Paylaşma işlemi
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
          'Depoyu Sil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${widget.warehouse.name} deposunu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteWarehouse();
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

  Future<void> _deleteWarehouse() async {
    try {
      await ref
          .read(warehouseNotifierProvider.notifier)
          .deleteWarehouse(widget.warehouse.id);

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.warehouse.name} deposu başarıyla silindi',
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
              'Depo silinemedi: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  LinearGradient _getWarehouseGradient() {
    switch (widget.warehouse.type) {
      case WarehouseType.main:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[600]!, Colors.blue[800]!],
        );
      case WarehouseType.branch:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[600]!, Colors.green[800]!],
        );
      case WarehouseType.retail:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[600]!, Colors.orange[800]!],
        );
      case WarehouseType.wholesale:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[600]!, Colors.purple[800]!],
        );
      case WarehouseType.cold:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.cyan[600]!, Colors.cyan[800]!],
        );
      case WarehouseType.bonded:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo[600]!, Colors.indigo[800]!],
        );
      case WarehouseType.virtual:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal[600]!, Colors.teal[800]!],
        );
      case WarehouseType.other:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[600]!, Colors.grey[800]!],
        );
    }
  }

  Color _getStatusColor() {
    switch (widget.warehouse.status) {
      case WarehouseStatus.active:
        return Colors.green;
      case WarehouseStatus.inactive:
        return Colors.orange;
      case WarehouseStatus.maintenance:
        return Colors.yellow;
      case WarehouseStatus.closed:
        return Colors.red;
      case WarehouseStatus.suspended:
        return Colors.purple;
    }
  }
}
