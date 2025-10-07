// ========== SUBSCRIPTION TEST PAGE ==========
// lib/features/subscription/presentation/pages/subscription_test_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/services/subscription/pricing_config.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/subscription_plan.dart' as sub;
import '../../domain/entities/subscription_entity.dart' as sub_entity;
import '../providers/subscription_providers.dart';
import '../widgets/platform_payment_widget.dart';

/// Abonelik test sayfası - tüm akışları test etmek için
class SubscriptionTestPage extends ConsumerStatefulWidget {
  const SubscriptionTestPage({super.key});

  @override
  ConsumerState<SubscriptionTestPage> createState() => _SubscriptionTestPageState();
}

class _SubscriptionTestPageState extends ConsumerState<SubscriptionTestPage> {
  sub.SubscriptionPlanType? _selectedPlan;
  sub_entity.PaymentProvider _selectedProvider = sub_entity.PaymentProvider.paytr;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final plans = PricingConfig.getAllPlans();
    final syncStatus = ref.watch(subscriptionSyncStatusProvider);

    return ResponsiveScaffold(
      drawerContent: const SizedBox.shrink(),
      appBar: const CustomAppBar(
        title: 'Abonelik Test',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test durumu
            _buildTestStatusCard(syncStatus),
            const SizedBox(height: 16),
            
            // Kullanıcı bilgileri
            if (user != null) _buildUserInfoCard(user),
            const SizedBox(height: 16),
            
            // Abonelik planları
            _buildPlansSection(plans),
            const SizedBox(height: 16),
            
            // Ödeme provider seçimi
            _buildProviderSelection(),
            const SizedBox(height: 16),
            
            // Test butonları
            _buildTestButtons(),
            const SizedBox(height: 16),
            
            // Test sonuçları
            _buildTestResults(),
          ],
        ),
      ),
    );
  }

  /// Test durumu kartı
  Widget _buildTestStatusCard(SubscriptionSyncState syncStatus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Durumu',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  syncStatus.isLoading ? Icons.sync : Icons.check_circle,
                  color: syncStatus.isLoading ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  syncStatus.isLoading 
                    ? 'Senkronizasyon yapılıyor...' 
                    : 'Test hazır',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
            if (syncStatus.error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hata: ${syncStatus.error}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
            if (syncStatus.message != null) ...[
              const SizedBox(height: 8),
              Text(
                'Mesaj: ${syncStatus.message}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Kullanıcı bilgileri kartı
  Widget _buildUserInfoCard(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kullanıcı Bilgileri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('ID', user.id),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Abonelik Durumu', user.subscriptionStatus.name),
            _buildInfoRow('Abonelik Planı', user.subscriptionPlan.name),
            if (user.trialStartAt != null)
              _buildInfoRow('Deneme Başlangıcı', user.trialStartAt!.toIso8601String()),
            if (user.trialEndAt != null)
              _buildInfoRow('Deneme Bitişi', user.trialEndAt!.toIso8601String()),
            if (user.subscriptionEndAt != null)
              _buildInfoRow('Abonelik Bitişi', user.subscriptionEndAt!.toIso8601String()),
          ],
        ),
      ),
    );
  }

  /// Bilgi satırı
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Abonelik planları bölümü
  Widget _buildPlansSection(List<sub.SubscriptionPlan> plans) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Abonelik Planları',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...plans.map((plan) => _buildPlanCard(plan)),
          ],
        ),
      ),
    );
  }

  /// Plan kartı
  Widget _buildPlanCard(sub.SubscriptionPlan plan) {
    final isSelected = _selectedPlan == plan.type;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioGroup<sub.SubscriptionPlanType>(
        onChanged: (value) {
          setState(() {
            _selectedPlan = value;
          });
        },
        child: RadioListTile<sub.SubscriptionPlanType>(
          title: Text(
            plan.name,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.description,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '₺${plan.price.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (plan.isLaunchPrice) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Lansman Fiyatı',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          value: plan.type,
        ),
      ),
    );
  }

  /// Ödeme provider seçimi
  Widget _buildProviderSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ödeme Provider Seçimi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...sub_entity.PaymentProvider.values.map((provider) => _buildProviderCard(provider)),
          ],
        ),
      ),
    );
  }

  /// Provider kartı
  Widget _buildProviderCard(sub_entity.PaymentProvider provider) {
    final isSelected = _selectedProvider == provider;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioGroup<sub_entity.PaymentProvider>(
        onChanged: (value) {
          setState(() {
            _selectedProvider = value!;
          });
        },
        child: RadioListTile<sub_entity.PaymentProvider>(
          title: Text(
            provider.name,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          value: provider,
        ),
      ),
    );
  }

  /// Test butonları
  Widget _buildTestButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Butonları',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _testSync,
                  child: const Text('Senkronizasyon Test'),
                ),
                ElevatedButton(
                  onPressed: _testTrial,
                  child: const Text('Deneme Test'),
                ),
                ElevatedButton(
                  onPressed: _testPayment,
                  child: const Text('Ödeme Test'),
                ),
                ElevatedButton(
                  onPressed: _testGuard,
                  child: const Text('Guard Test'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Test sonuçları
  Widget _buildTestResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Sonuçları',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test sonuçları burada görünecek...',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Senkronizasyon testi
  void _testSync() {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return;

    ref.read(subscriptionSyncStatusProvider.notifier).syncUserSubscriptions(user.id);
  }

  /// Deneme testi
  void _testTrial() {
    // Deneme süresi testi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deneme süresi testi başlatıldı')),
    );
  }

  /// Ödeme testi
  void _testPayment() {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir plan seçin')),
      );
      return;
    }

    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return;

    final plan = PricingConfig.getAllPlans()
        .firstWhere((p) => p.type == _selectedPlan);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlatformPaymentWidget(
          user: user,
          planType: _selectedPlan!,
          amount: plan.price,
          onPaymentSuccess: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ödeme başarılı!')),
            );
          },
          onPaymentFailed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ödeme başarısız!')),
            );
          },
          onPaymentCancelled: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ödeme iptal edildi!')),
            );
          },
        ),
      ),
    );
  }

  /// Guard testi
  void _testGuard() {
    // Guard testi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guard testi başlatıldı')),
    );
  }
}
