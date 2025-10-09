// ========== PAYMENT FAIL PAGE ==========
// lib/features/subscription/presentation/pages/payment_fail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

/// PayTR ödeme başarısız sayfası
class PaymentFailPage extends ConsumerStatefulWidget {
  const PaymentFailPage({super.key});

  @override
  ConsumerState<PaymentFailPage> createState() => _PaymentFailPageState();
}

class _PaymentFailPageState extends ConsumerState<PaymentFailPage> {
  @override
  void initState() {
    super.initState();
    // Sayfa yüklendiğinde kullanıcıyı abonelik sayfasına yönlendir
    _redirectToSubscription();
  }

  void _redirectToSubscription() {
    // 5 saniye sonra abonelik sayfasına yönlendir
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/subscription',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Ödeme Başarısız',
        showBackButton: false,
      ),
      drawerContent: const SizedBox.shrink(), // Boş drawer
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hata ikonu
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error,
                  size: 80,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 32),

              // Hata mesajı
              Text(
                'Ödeme İşlemi Başarısız',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Ödeme işleminiz tamamlanamadı. Lütfen tekrar deneyin.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Tekrar dene butonu
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/subscription',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
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

              const SizedBox(height: 16),

              // Ana sayfa butonu
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/dashboard',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Ana Sayfa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
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
                      (i) => 5 - i,
                    ).take(6),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 5;
                      return Text(
                        '$count saniye sonra abonelik sayfasına yönlendirileceksiniz...',
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
