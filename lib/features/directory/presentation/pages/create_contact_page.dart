// ========== CREATE CONTACT PAGE ==========
// lib/features/directory/presentation/pages/create_contact_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/widgets/formatted_text_field.dart';
import '../../../../core/validation/input_validator.dart';
import '../../../../core/validation/data_sanitizer.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/contact_providers.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_type.dart';

class CreateContactPage extends ConsumerStatefulWidget {
  const CreateContactPage({super.key});

  @override
  ConsumerState<CreateContactPage> createState() => _CreateContactPageState();
}

class _CreateContactPageState extends ConsumerState<CreateContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();

  ContactType _selectedType = ContactType.customer;
  bool _isFavorite = false;
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactState = ref.watch(contactOperationsProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Yeni Kişi/Kurum',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildContactInfoSection(),
            const SizedBox(height: 24),
            _buildAddressSection(),
            const SizedBox(height: 24),
            _buildTaxInfoSection(),
            const SizedBox(height: 24),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(contactState),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temel Bilgiler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            FormattedNameField(
              label: 'Ad/Şirket Adı',
              controller: _nameController,
              hint: 'Kişi veya şirket adını girin',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ContactType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tip *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: ContactType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İletişim Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            FormattedEmailField(
              label: 'E-posta',
              controller: _emailController,
              hint: 'ornek@email.com',
              required: false,
            ),
            const SizedBox(height: 16),
            FormattedPhoneField(
              label: 'Telefon',
              controller: _phoneController,
              hint: '+90 543 288 1296',
              required: false,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Web Sitesi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adres Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adres',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Şehir',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Ülke',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.public),
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

  Widget _buildTaxInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vergi Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxNumberController,
              decoration: const InputDecoration(
                labelText: 'Vergi Numarası',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxOfficeController,
              decoration: const InputDecoration(
                labelText: 'Vergi Dairesi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ek Bilgiler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ayarlar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Favori'),
              subtitle: const Text('Favori kişi/kurum olarak işaretle'),
              value: _isFavorite,
              onChanged: (value) {
                setState(() {
                  _isFavorite = value;
                });
              },
              secondary: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red[400] : Colors.grey[400],
              ),
            ),
            SwitchListTile(
              title: const Text('Aktif'),
              subtitle: const Text('Kişi/kurumu aktif olarak işaretle'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: Icon(
                _isActive ? Icons.check_circle : Icons.cancel,
                color: _isActive ? Colors.green[400] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ContactOperationsState state) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: state.isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: TamgaciConstants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Kişi/Kurum Ekle',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form validasyonu başarılı, verileri sanitize et
      final sanitizedName = DataSanitizer.sanitizeText(_nameController.text);
      final sanitizedEmail = _emailController.text.trim().isEmpty
          ? null
          : DataSanitizer.sanitizeEmail(_emailController.text);
      final sanitizedPhone = _phoneController.text.trim().isEmpty
          ? null
          : DataSanitizer.sanitizePhone(_phoneController.text);
      final sanitizedWebsite = _websiteController.text.trim().isEmpty
          ? null
          : DataSanitizer.sanitizeUrl(_websiteController.text);

      // Ek validasyonlar
      if (sanitizedEmail != null &&
          !InputValidator.isValidEmail(sanitizedEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçerli bir e-posta adresi girin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (sanitizedPhone != null &&
          !InputValidator.isValidPhone(sanitizedPhone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçerli bir telefon numarası girin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (sanitizedWebsite != null &&
          !InputValidator.isValidUrl(sanitizedWebsite)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçerli bir web sitesi adresi girin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final contact = Contact(
        id: '', // Will be set by repository
        name: sanitizedName,
        type: _selectedType,
        email: sanitizedEmail,
        phone: sanitizedPhone,
        address: DataSanitizer.sanitizeText(_addressController.text),
        city: DataSanitizer.sanitizeText(_cityController.text),
        country: DataSanitizer.sanitizeText(_countryController.text),
        taxNumber: DataSanitizer.sanitizeText(_taxNumberController.text),
        taxOffice: DataSanitizer.sanitizeText(_taxOfficeController.text),
        website: sanitizedWebsite,
        notes: DataSanitizer.sanitizeText(_notesController.text),
        isFavorite: _isFavorite,
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      ref
          .read(contactOperationsProvider.notifier)
          .addContact(contact)
          .then((_) {
        if (mounted) {
          Navigator.pop(context); // Loading dialog'u kapat
          final state = ref.read(contactOperationsProvider);
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Tamam',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
            Navigator.pop(context); // Sayfayı kapat
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Tamam',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        }
      }).catchError((error) {
        if (mounted) {
          Navigator.pop(context); // Loading dialog'u kapat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
}
