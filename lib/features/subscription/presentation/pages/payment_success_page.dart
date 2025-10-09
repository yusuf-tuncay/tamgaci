// ========== PAYMENT SUCCESS PAGE ==========
// lib/features/subscription/presentation/pages/payment_success_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

/// PayTR ödeme başarılı sayfası
class PaymentSuccessPage extends ConsumerStatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  ConsumerState<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends ConsumerState<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();
    // Sayfa yüklendiğinde kullanıcıyı dashboard'a yönlendir
    _redirectToDashboard();
  }

  void _redirectToDashboard() {
    // 3 saniye sonra dashboard'a yönlendir
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Ödeme Başarılı',
        showBackButton: false,
      ),
      drawerContent: const SizedBox.shrink(), // Boş drawer
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Başarı ikonu
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 32),

              // Başarı mesajı
              Text(
                'Ödeme Başarıyla Tamamlandı!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Aboneliğiniz aktif edildi. Dashboard\'a yönlendiriliyorsunuz...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Yönlendirme butonu
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                },
                icon: const Icon(Icons.dashboard),
                label: const Text('Dashboard\'a Git'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Yönlendirme sayacı
              Consumer(
                builder: (context, ref, child) {
                  return StreamBuilder<int>(
                    stream: Stream.periodic(
                      const Duration(seconds: 1),
                      (i) => 3 - i,
                    ).take(4),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 3;
                      return Text(
                        '$count saniye sonra yönlendirileceksiniz...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
