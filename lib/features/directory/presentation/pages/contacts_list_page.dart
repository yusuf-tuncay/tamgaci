// ========== CONTACTS LIST PAGE ==========
// lib/features/directory/presentation/pages/contacts_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/contact_providers.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_type.dart';
import 'contact_detail_page.dart';
import 'create_contact_page.dart';

class ContactsListPage extends ConsumerStatefulWidget {
  const ContactsListPage({super.key});

  @override
  ConsumerState<ContactsListPage> createState() => _ContactsListPageState();
}

class _ContactsListPageState extends ConsumerState<ContactsListPage> {
  final TextEditingController _searchController = TextEditingController();
  ContactType? _selectedType;
  String _sortBy = 'name'; // name, createdAt, updatedAt
  final bool _sortAscending = true;
  bool _showAdvancedFilters = false;
  String? _selectedCity;
  String? _selectedCountry;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactOperationsProvider.notifier).loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactState = ref.watch(contactOperationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Fihrist',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(isDark),
          Expanded(
            child: _buildContactsList(contactState, isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateContact(),
        backgroundColor: TamgaciConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilterSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Arama kutusu
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Kişi/kurum ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(contactSearchQueryProvider.notifier).state =
                            '';
                        ref
                            .read(contactOperationsProvider.notifier)
                            .loadContacts();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? TamgaciConstants.cardColorDark : Colors.white,
              hintStyle: TextStyle(
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
            ),
            style: TextStyle(
              color: isDark
                  ? TamgaciConstants.textPrimaryDark
                  : TamgaciConstants.textPrimary,
            ),
            onChanged: (value) {
              ref.read(contactSearchQueryProvider.notifier).state = value;
              if (value.isNotEmpty) {
                ref
                    .read(contactOperationsProvider.notifier)
                    .searchContacts(value);
              } else {
                ref.read(contactOperationsProvider.notifier).loadContacts();
              }
            },
          ),
          const SizedBox(height: 12),
          // Sıralama ve filtre butonları
          Row(
            children: [
              Expanded(
                child: _buildSortDropdown(isDark),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = !_showAdvancedFilters;
                  });
                },
                icon: Icon(
                  _showAdvancedFilters
                      ? Icons.filter_list_off
                      : Icons.filter_list,
                  color: _showAdvancedFilters
                      ? TamgaciConstants.primaryColor
                      : (isDark
                          ? TamgaciConstants.textSecondaryDark
                          : Colors.grey[600]),
                ),
              ),
              IconButton(
                onPressed: _showExportOptions,
                icon: Icon(
                  Icons.download,
                  color: isDark
                      ? TamgaciConstants.textSecondaryDark
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tip filtreleri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Tümü', isDark),
                const SizedBox(width: 8),
                _buildFilterChip(ContactType.customer, 'Müşteriler', isDark),
                const SizedBox(width: 8),
                _buildFilterChip(ContactType.supplier, 'Tedarikçiler', isDark),
                const SizedBox(width: 8),
                _buildFilterChip(ContactType.both, 'Her İkisi', isDark),
              ],
            ),
          ),
          // Gelişmiş filtreler
          if (_showAdvancedFilters) ...[
            const SizedBox(height: 12),
            _buildAdvancedFilters(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(ContactType? type, String label, bool isDark) {
    final isSelected = _selectedType == type;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
        ref.read(selectedContactTypeProvider.notifier).state = type;

        if (type != null) {
          ref.read(contactOperationsProvider.notifier).getContactsByType(type);
        } else {
          ref.read(contactOperationsProvider.notifier).loadContacts();
        }
      },
      backgroundColor: isDark ? TamgaciConstants.cardColorDark : Colors.white,
      selectedColor: TamgaciConstants.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: TamgaciConstants.primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? TamgaciConstants.primaryColor
            : (isDark ? TamgaciConstants.textSecondaryDark : Colors.grey[600]),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildContactsList(ContactOperationsState state, bool isDark) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Hata',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(contactOperationsProvider.notifier).clearError();
                ref.read(contactOperationsProvider.notifier).loadContacts();
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (state.contacts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'Henüz kişi/kurum yok',
        message: 'Yeni kişi veya kurum eklemek için + butonuna tıklayın',
        actionButton: ElevatedButton(
          onPressed: () => _navigateToCreateContact(),
          child: const Text('Kişi/Kurum Ekle'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.contacts.length,
      itemBuilder: (context, index) {
        final contact = state.contacts[index];
        return _buildContactCard(contact, isDark);
      },
    );
  }

  Widget _buildContactCard(Contact contact, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isDark ? TamgaciConstants.cardColorDark : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToContactDetail(contact),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: _getContactTypeColor(contact.type),
                child: Icon(
                  _getContactTypeIcon(contact.type),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? TamgaciConstants.textPrimaryDark
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                        if (contact.isFavorite)
                          Icon(
                            Icons.favorite,
                            color: Colors.red[400],
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.type.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _getContactTypeColor(contact.type),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (contact.phone != null && contact.phone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: isDark
                                ? TamgaciConstants.textSecondaryDark
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contact.phone!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark
                                  ? TamgaciConstants.textSecondaryDark
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (contact.email != null && contact.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 14,
                            color: isDark
                                ? TamgaciConstants.textSecondaryDark
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contact.email!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark
                                    ? TamgaciConstants.textSecondaryDark
                                    : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Favori toggle butonu
              IconButton(
                onPressed: () {
                  ref
                      .read(contactOperationsProvider.notifier)
                      .toggleFavorite(contact);
                },
                icon: Icon(
                  contact.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: contact.isFavorite
                      ? Colors.red[400]
                      : (isDark
                          ? TamgaciConstants.textSecondaryDark
                          : Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
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

  void _navigateToContactDetail(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailPage(contact: contact),
      ),
    );
  }

  void _navigateToCreateContact() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateContactPage(),
      ),
    );
  }

  Widget _buildSortDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isExpanded: true,
          icon: Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            color:
                isDark ? TamgaciConstants.textSecondaryDark : Colors.grey[600],
          ),
          style: TextStyle(
            color: isDark ? TamgaciConstants.textPrimaryDark : Colors.grey[800],
            fontSize: 14,
          ),
          items: const [
            DropdownMenuItem(value: 'name', child: Text('İsme Göre')),
            DropdownMenuItem(
                value: 'createdAt', child: Text('Oluşturma Tarihi')),
            DropdownMenuItem(
                value: 'updatedAt', child: Text('Güncelleme Tarihi')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _sortBy = value;
              });
              _applySorting();
            }
          },
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gelişmiş Filtreler',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? TamgaciConstants.textPrimaryDark : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Şehir',
                    hintText: 'Şehir ara...',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? TamgaciConstants.backgroundColorDark
                        : Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value.isEmpty ? null : value;
                    });
                    _applyAdvancedFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Ülke',
                    hintText: 'Ülke ara...',
                    prefixIcon: const Icon(Icons.public),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? TamgaciConstants.backgroundColorDark
                        : Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value.isEmpty ? null : value;
                    });
                    _applyAdvancedFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateRange(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isDark
                          ? TamgaciConstants.backgroundColorDark
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          color: isDark
                              ? TamgaciConstants.textSecondaryDark
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _startDate != null && _endDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Tarih Aralığı Seç',
                          style: TextStyle(
                            color: isDark
                                ? TamgaciConstants.textPrimaryDark
                                : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _clearAdvancedFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey[700],
                ),
                child: const Text('Temizle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applySorting() {
    ref
        .read(contactOperationsProvider.notifier)
        .sortContacts(_sortBy, _sortAscending);
  }

  void _applyAdvancedFilters() {
    ref.read(contactOperationsProvider.notifier).applyAdvancedFilters(
          city: _selectedCity,
          country: _selectedCountry,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  void _clearAdvancedFilters() {
    setState(() {
      _selectedCity = null;
      _selectedCountry = null;
      _startDate = null;
      _endDate = null;
    });
    ref.read(contactOperationsProvider.notifier).clearAdvancedFilters();
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyAdvancedFilters();
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Excel Olarak Export'),
              onTap: () {
                Navigator.pop(context);
                _exportContacts('excel');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Olarak Export'),
              onTap: () {
                Navigator.pop(context);
                _exportContacts('pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('CSV Olarak Export'),
              onTap: () {
                Navigator.pop(context);
                _exportContacts('csv');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportContacts(String format) {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format formatında export işlemi başlatıldı'),
        backgroundColor: TamgaciConstants.primaryColor,
      ),
    );
  }
}
