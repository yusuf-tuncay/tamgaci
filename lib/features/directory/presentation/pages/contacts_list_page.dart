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
    final searchQuery = ref.watch(contactSearchQueryProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Fihrist',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: _buildContactsList(contactState),
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

  Widget _buildSearchAndFilterSection() {
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
              fillColor: Colors.white,
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
          // Tip filtreleri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Tümü'),
                const SizedBox(width: 8),
                _buildFilterChip(ContactType.customer, 'Müşteriler'),
                const SizedBox(width: 8),
                _buildFilterChip(ContactType.supplier, 'Tedarikçiler'),
                const SizedBox(width: 8),
                _buildFilterChip(ContactType.both, 'Her İkisi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ContactType? type, String label) {
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
      backgroundColor: Colors.white,
      selectedColor: TamgaciConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: TamgaciConstants.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? TamgaciConstants.primaryColor : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildContactsList(ContactOperationsState state) {
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
                color: Colors.grey[600],
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
        return _buildContactCard(contact);
      },
    );
  }

  Widget _buildContactCard(Contact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                              color: Colors.grey[800],
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
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contact.phone!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contact.email!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
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
                  color:
                      contact.isFavorite ? Colors.red[400] : Colors.grey[400],
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
}
