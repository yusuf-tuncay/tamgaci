// ========== CONTACT DETAIL PAGE ==========
// lib/features/directory/presentation/pages/contact_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/contact_providers.dart';
import '../../domain/entities/contact.dart';
import 'edit_contact_page.dart';

class ContactDetailPage extends ConsumerStatefulWidget {
  final Contact contact;

  const ContactDetailPage({
    super.key,
    required this.contact,
  });

  @override
  ConsumerState<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends ConsumerState<ContactDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: widget.contact.name,
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => _showOptionsModal(),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildContactInfoSection(),
            const SizedBox(height: 24),
            _buildAddressSection(),
            const SizedBox(height: 24),
            _buildTaxInfoSection(),
            const SizedBox(height: 24),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 24),
            _buildTimestampsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar ve tip
            CircleAvatar(
              radius: 40,
              backgroundColor: _getContactTypeColor(widget.contact.type),
              child: Icon(
                _getContactTypeIcon(widget.contact.type),
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            // İsim
            Text(
              widget.contact.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Tip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    _getContactTypeColor(widget.contact.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getContactTypeColor(widget.contact.type),
                  width: 1,
                ),
              ),
              child: Text(
                widget.contact.type.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getContactTypeColor(widget.contact.type),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Durum göstergeleri
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.contact.isFavorite) ...[
                  _buildStatusChip(
                    Icons.favorite,
                    'Favori',
                    Colors.red[400]!,
                  ),
                  const SizedBox(width: 12),
                ],
                if (widget.contact.isActive) ...[
                  _buildStatusChip(
                    Icons.check_circle,
                    'Aktif',
                    Colors.green[400]!,
                  ),
                ] else ...[
                  _buildStatusChip(
                    Icons.cancel,
                    'Pasif',
                    Colors.grey[400]!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return _buildInfoCard(
      'İletişim Bilgileri',
      Icons.contact_phone,
      [
        if (widget.contact.phone != null && widget.contact.phone!.isNotEmpty)
          _buildInfoRow(Icons.phone, 'Telefon', widget.contact.phone!),
        if (widget.contact.email != null && widget.contact.email!.isNotEmpty)
          _buildInfoRow(Icons.email, 'E-posta', widget.contact.email!),
        if (widget.contact.website != null &&
            widget.contact.website!.isNotEmpty)
          _buildInfoRow(Icons.language, 'Web Sitesi', widget.contact.website!),
      ],
    );
  }

  Widget _buildAddressSection() {
    final hasAddress =
        widget.contact.address != null && widget.contact.address!.isNotEmpty;
    final hasCity =
        widget.contact.city != null && widget.contact.city!.isNotEmpty;
    final hasCountry =
        widget.contact.country != null && widget.contact.country!.isNotEmpty;

    if (!hasAddress && !hasCity && !hasCountry) {
      return const SizedBox.shrink();
    }

    return _buildInfoCard(
      'Adres Bilgileri',
      Icons.location_on,
      [
        if (hasAddress)
          _buildInfoRow(Icons.location_on, 'Adres', widget.contact.address!),
        if (hasCity)
          _buildInfoRow(Icons.location_city, 'Şehir', widget.contact.city!),
        if (hasCountry)
          _buildInfoRow(Icons.public, 'Ülke', widget.contact.country!),
      ],
    );
  }

  Widget _buildTaxInfoSection() {
    final hasTaxNumber = widget.contact.taxNumber != null &&
        widget.contact.taxNumber!.isNotEmpty;
    final hasTaxOffice = widget.contact.taxOffice != null &&
        widget.contact.taxOffice!.isNotEmpty;

    if (!hasTaxNumber && !hasTaxOffice) {
      return const SizedBox.shrink();
    }

    return _buildInfoCard(
      'Vergi Bilgileri',
      Icons.receipt,
      [
        if (hasTaxNumber)
          _buildInfoRow(
              Icons.receipt, 'Vergi Numarası', widget.contact.taxNumber!),
        if (hasTaxOffice)
          _buildInfoRow(Icons.account_balance, 'Vergi Dairesi',
              widget.contact.taxOffice!),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    if (widget.contact.notes == null || widget.contact.notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildInfoCard(
      'Ek Bilgiler',
      Icons.note,
      [
        _buildInfoRow(Icons.note, 'Notlar', widget.contact.notes!),
      ],
    );
  }

  Widget _buildTimestampsSection() {
    return _buildInfoCard(
      'Sistem Bilgileri',
      Icons.info,
      [
        _buildInfoRow(
          Icons.add_circle,
          'Oluşturulma',
          _formatDateTime(widget.contact.createdAt),
        ),
        _buildInfoRow(
          Icons.update,
          'Güncellenme',
          _formatDateTime(widget.contact.updatedAt),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: TamgaciConstants.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getContactTypeColor(ContactType type) {
    switch (type) {
      case ContactType.customer:
        return Colors.blue;
      case ContactType.supplier:
        return Colors.orange;
      case ContactType.both:
        return Colors.purple;
    }
  }

  IconData _getContactTypeIcon(ContactType type) {
    switch (type) {
      case ContactType.customer:
        return Icons.person;
      case ContactType.supplier:
        return Icons.business;
      case ContactType.both:
        return Icons.people;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showOptionsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildOptionsSheet(),
    );
  }

  Widget _buildOptionsSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Düzenle'),
            onTap: () {
              Navigator.pop(context);
              _navigateToEdit();
            },
          ),
          ListTile(
            leading: Icon(
              widget.contact.isFavorite
                  ? Icons.favorite_border
                  : Icons.favorite,
              color: Colors.red[400],
            ),
            title: Text(widget.contact.isFavorite
                ? 'Favorilerden Çıkar'
                : 'Favorilere Ekle'),
            onTap: () {
              Navigator.pop(context);
              _toggleFavorite();
            },
          ),
          ListTile(
            leading: Icon(
              widget.contact.isActive ? Icons.block : Icons.check_circle,
              color: widget.contact.isActive ? Colors.orange : Colors.green,
            ),
            title: Text(widget.contact.isActive ? 'Pasif Yap' : 'Aktif Yap'),
            onTap: () {
              Navigator.pop(context);
              _toggleActive();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Sil'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation();
            },
          ),
        ],
      ),
    );
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactPage(contact: widget.contact),
      ),
    );
  }

  void _toggleFavorite() {
    ref.read(contactOperationsProvider.notifier).toggleFavorite(widget.contact);
  }

  void _toggleActive() {
    final updatedContact = widget.contact.copyWith(
      isActive: !widget.contact.isActive,
      updatedAt: DateTime.now(),
    );
    ref.read(contactOperationsProvider.notifier).updateContact(updatedContact);
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kişi/Kurum Sil'),
        content: Text(
            '${widget.contact.name} kişi/kurumunu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteContact();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _deleteContact() {
    ref
        .read(contactOperationsProvider.notifier)
        .deleteContact(widget.contact.id!);
    Navigator.pop(context);
  }
}
