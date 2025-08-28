// ========== TAX SETTINGS PAGE ==========
// lib/features/settings/presentation/pages/tax_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Vergi ayarları sayfası
class TaxSettingsPage extends ConsumerStatefulWidget {
  const TaxSettingsPage({super.key});

  @override
  ConsumerState<TaxSettingsPage> createState() => _TaxSettingsPageState();
}

class _TaxSettingsPageState extends ConsumerState<TaxSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _defaultTaxRateController = TextEditingController(text: '18');
  final _taxNumberController = TextEditingController(text: '1234567890');
  final _taxOfficeController = TextEditingController(
    text: 'Kadıköy Vergi Dairesi',
  );
  final _taxExemptionController = TextEditingController(text: '0');

  bool _isLoading = false;
  bool _autoCalculateTax = true;
  bool _includeTaxInPrices = false;
  bool _showTaxSeparately = true;
  String _taxCalculationMethod = 'Percentage';

  final List<String> _taxCalculationMethods = ['Percentage', 'Fixed Amount'];

  @override
  void dispose() {
    _defaultTaxRateController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _taxExemptionController.dispose();
    super.dispose();
  }

  /// Ayarları kaydet
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Gerçek kaydetme işlemi
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş işlem

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vergi ayarları başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(title: 'Vergi Ayarları', showDrawer: false),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Form alanları
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Genel vergi ayarları
                    _buildSectionTitle('Genel Vergi Ayarları'),
                    _buildGeneralTaxSettings(),

                    const SizedBox(height: 24),

                    // Vergi hesaplama ayarları
                    _buildSectionTitle('Vergi Hesaplama'),
                    _buildTaxCalculationSettings(),

                    const SizedBox(height: 24),

                    // Vergi bilgileri
                    _buildSectionTitle('Vergi Bilgileri'),
                    _buildTaxInfoSettings(),

                    const SizedBox(height: 24),

                    // Vergi muafiyeti
                    _buildSectionTitle('Vergi Muafiyeti'),
                    _buildTaxExemptionSettings(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Kaydet butonu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TamgaciConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Ayarları Kaydet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TamgaciConstants.textPrimary,
        ),
      ),
    );
  }

  /// Genel vergi ayarları bölümü
  Widget _buildGeneralTaxSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _defaultTaxRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Varsayılan Vergi Oranı (%) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent),
                suffixText: '%',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vergi oranı gereklidir';
                }
                final rate = double.tryParse(value);
                if (rate == null || rate < 0 || rate > 100) {
                  return 'Geçerli bir vergi oranı girin (0-100)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _taxCalculationMethod,
              decoration: const InputDecoration(
                labelText: 'Vergi Hesaplama Yöntemi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calculate),
              ),
              items: _taxCalculationMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(
                    method == 'Percentage' ? 'Yüzde (%)' : 'Sabit Tutar',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _taxCalculationMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Vergi hesaplama ayarları bölümü
  Widget _buildTaxCalculationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Otomatik Vergi Hesaplama'),
              subtitle: const Text('Fiyatlara otomatik olarak vergi ekle'),
              value: _autoCalculateTax,
              onChanged: (value) {
                setState(() {
                  _autoCalculateTax = value;
                });
              },
              secondary: const Icon(Icons.auto_fix_high),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Fiyatlara Vergi Dahil'),
              subtitle: const Text('Girilen fiyatlar vergi dahil olsun'),
              value: _includeTaxInPrices,
              onChanged: (value) {
                setState(() {
                  _includeTaxInPrices = value;
                });
              },
              secondary: const Icon(Icons.attach_money),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Vergiyi Ayrı Göster'),
              subtitle: const Text(
                'Fatura ve raporlarda vergiyi ayrı satırda göster',
              ),
              value: _showTaxSeparately,
              onChanged: (value) {
                setState(() {
                  _showTaxSeparately = value;
                });
              },
              secondary: const Icon(Icons.receipt_long),
            ),
          ],
        ),
      ),
    );
  }

  /// Vergi bilgileri bölümü
  Widget _buildTaxInfoSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _taxNumberController,
              decoration: const InputDecoration(
                labelText: 'Vergi Numarası *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vergi numarası gereklidir';
                }
                if (value.length != 10) {
                  return 'Vergi numarası 10 haneli olmalıdır';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxOfficeController,
              decoration: const InputDecoration(
                labelText: 'Vergi Dairesi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vergi dairesi gereklidir';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Vergi muafiyeti bölümü
  Widget _buildTaxExemptionSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _taxExemptionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Vergi Muafiyet Limiti (₺)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
                suffixText: '₺',
                helperText:
                    'Bu tutarın altındaki işlemler vergi muafiyetinden yararlanır',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Geçerli bir tutar girin';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vergi muafiyeti, belirtilen tutarın altındaki işlemler için geçerlidir. Bu özellik KDV muafiyeti olan işletmeler için kullanılır.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
