// ========== CONTACT DETAIL PAGE ==========
// lib/features/directory/presentation/pages/contact_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/contact_providers.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_type.dart';
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
            _buildQuickActionsSection(),
            const SizedBox(height: 24),
            _buildContactInfoSection(),
            const SizedBox(height: 24),
            _buildAddressSection(),
            const SizedBox(height: 24),
            _buildTaxInfoSection(),
            const SizedBox(height: 24),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 24),
            _buildStatisticsSection(),
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
                color: _getContactTypeColor(widget.contact.type)
                    .withValues(alpha: 0.1),
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
        color: color.withValues(alpha: 0.1),
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
        .deleteContact(widget.contact.id);
    Navigator.pop(context);
  }

  Widget _buildQuickActionsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hızlı İşlemler',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone,
                    label: 'Ara',
                    onTap: () => _makePhoneCall(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.email,
                    label: 'E-posta',
                    onTap: () => _sendEmail(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.share,
                    label: 'Paylaş',
                    onTap: () => _shareContact(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.qr_code,
                    label: 'QR Kod',
                    onTap: () => _showQRCode(),
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İstatistikler',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.receipt,
                    label: 'Toplam Fatura',
                    value: '0',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    label: 'Toplam Tutar',
                    value: '₺0',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shopping_cart,
                    label: 'Son Alışveriş',
                    value: 'Yok',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    label: 'Müşteri Puanı',
                    value: '5.0',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _makePhoneCall() {
    if (widget.contact.phone != null && widget.contact.phone!.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: widget.contact.phone!);
      launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefon numarası bulunamadı')),
      );
    }
  }

  void _sendEmail() {
    if (widget.contact.email != null && widget.contact.email!.isNotEmpty) {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: widget.contact.email!,
        query: 'subject=Merhaba ${widget.contact.name}',
      );
      launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta adresi bulunamadı')),
      );
    }
  }

  void _shareContact() {
    final contactInfo = '''
${widget.contact.name}
${widget.contact.phone != null ? 'Tel: ${widget.contact.phone}' : ''}
${widget.contact.email != null ? 'E-posta: ${widget.contact.email}' : ''}
${widget.contact.address != null ? 'Adres: ${widget.contact.address}' : ''}
''';

    Share.share(contactInfo,
        subject: '${widget.contact.name} - İletişim Bilgileri');
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.contact.name} - QR Kod'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: _generateContactVCard(),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'QR kodu tarayarak kişi bilgilerini kaydedebilirsiniz',
              style: GoogleFonts.poppins(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  String _generateContactVCard() {
    final vcard = StringBuffer();
    vcard.writeln('BEGIN:VCARD');
    vcard.writeln('VERSION:3.0');
    vcard.writeln('FN:${widget.contact.name}');
    if (widget.contact.phone != null) {
      vcard.writeln('TEL:${widget.contact.phone}');
    }
    if (widget.contact.email != null) {
      vcard.writeln('EMAIL:${widget.contact.email}');
    }
    if (widget.contact.address != null) {
      vcard.writeln('ADR:;;${widget.contact.address}');
    }
    if (widget.contact.website != null) {
      vcard.writeln('URL:${widget.contact.website}');
    }
    vcard.writeln('END:VCARD');
    return vcard.toString();
  }
}
