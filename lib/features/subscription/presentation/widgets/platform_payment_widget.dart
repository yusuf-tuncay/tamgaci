// ========== PLATFORM PAYMENT WIDGET ==========
// lib/features/subscription/presentation/widgets/platform_payment_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/services/payment/app_store_service.dart';
import '../../../../core/services/payment/play_store_service.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../../auth/domain/entities/user.dart';
import 'paytr_iframe_widget.dart';

/// Platform-specific ödeme widget'ı
class PlatformPaymentWidget extends StatefulWidget {
  /// Kullanıcı bilgileri
  final User user;

  /// Seçilen plan
  final SubscriptionPlanType planType;

  /// Plan fiyatı
  final double amount;

  /// Başarılı ödeme callback'i
  final VoidCallback? onPaymentSuccess;

  /// Başarısız ödeme callback'i
  final VoidCallback? onPaymentFailed;

  /// İptal callback'i
  final VoidCallback? onPaymentCancelled;

  const PlatformPaymentWidget({
    super.key,
    required this.user,
    required this.planType,
    required this.amount,
    this.onPaymentSuccess,
    this.onPaymentFailed,
    this.onPaymentCancelled,
  });

  @override
  State<PlatformPaymentWidget> createState() => _PlatformPaymentWidgetState();
}

class _PlatformPaymentWidgetState extends State<PlatformPaymentWidget> {
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ödeme',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  /// Ana body widget'ı
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return _buildPaymentOptions();
  }

  /// Ödeme seçenekleri
  Widget _buildPaymentOptions() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık
          Text(
            'Ödeme Yöntemi Seçin',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hangi yöntemle ödeme yapmak istiyorsunuz?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Platform-specific ödeme seçenekleri
          if (Platform.isIOS) ...[
            _buildAppStoreOption(),
            const SizedBox(height: 16),
            _buildPaytrOption(),
          ] else if (Platform.isAndroid) ...[
            _buildPlayStoreOption(),
            const SizedBox(height: 16),
            _buildPaytrOption(),
          ] else ...[
            // Web/Windows - sadece PayTR
            _buildPaytrOption(),
          ],

          const SizedBox(height: 24),

          // Bilgi kartı
          _buildInfoCard(),
        ],
      ),
    );
  }

  /// App Store seçeneği
  Widget _buildAppStoreOption() {
    return _buildPaymentCard(
      title: 'App Store',
      subtitle: 'iOS cihazınızda güvenli ödeme',
      icon: Icons.apple,
      color: Colors.black,
      onTap: _handleAppStorePayment,
    );
  }

  /// Play Store seçeneği
  Widget _buildPlayStoreOption() {
    return _buildPaymentCard(
      title: 'Google Play',
      subtitle: 'Android cihazınızda güvenli ödeme',
      icon: Icons.android,
      color: Colors.green[600]!,
      onTap: _handlePlayStorePayment,
    );
  }

  /// PayTR seçeneği
  Widget _buildPaytrOption() {
    return _buildPaymentCard(
      title: 'PayTR',
      subtitle: 'Kredi kartı ile güvenli ödeme',
      icon: Icons.credit_card,
      color: AppColors.primary,
      onTap: _handlePaytrPayment,
    );
  }

  /// Ödeme kartı
  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bilgi kartı
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tüm ödeme yöntemleri güvenlidir ve 256-bit SSL şifreleme kullanır.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Yükleniyor widget'ı
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Ödeme işlemi başlatılıyor...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Ödeme Hatası',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Tekrar Dene',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// App Store ödeme işlemi
  void _handleAppStorePayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appStoreService = AppStoreService();
      final result = await appStoreService.startSubscription(
        user: widget.user,
        planType: widget.planType,
      );

      if (result.success) {
        widget.onPaymentSuccess?.call();
      } else {
        setState(() {
          _error = result.error ?? 'App Store ödeme hatası';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'App Store ödeme hatası: $e';
        _isLoading = false;
      });
    }
  }

  /// Play Store ödeme işlemi
  void _handlePlayStorePayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final playStoreService = PlayStoreService();
      final result = await playStoreService.startSubscription(
        user: widget.user,
        planType: widget.planType,
      );

      if (result.success) {
        widget.onPaymentSuccess?.call();
      } else {
        setState(() {
          _error = result.error ?? 'Play Store ödeme hatası';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Play Store ödeme hatası: $e';
        _isLoading = false;
      });
    }
  }

  /// PayTR ödeme işlemi
  void _handlePaytrPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaytrIframeWidget(
          user: widget.user,
          planType: widget.planType,
          amount: widget.amount,
          onPaymentSuccess: widget.onPaymentSuccess,
          onPaymentFailed: widget.onPaymentFailed,
          onPaymentCancelled: widget.onPaymentCancelled,
        ),
      ),
    );
  }
}
