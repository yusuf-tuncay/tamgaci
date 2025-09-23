// ========== SUBSCRIPTION PAGE ==========
// lib/features/settings/presentation/pages/subscription_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart' as auth_domain;
import '../../../../core/services/payment/payment_service.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(
          title: 'Abonelik', showBackButton: true, showDrawer: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(user, isDark),
            const SizedBox(height: 20),
            _buildPricingGrid(context, ref, user),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(auth_domain.User? user, bool isDark) {
    final now = DateTime.now();
    String statusText = 'Abonelik bulunmuyor';
    Color statusColor = Colors.grey;
    int? remaining;

    if (user != null) {
      if (user.subscriptionStatus == auth_domain.SubscriptionStatus.trial &&
          user.trialEndAt != null) {
        remaining = user.trialEndAt!.difference(now).inDays;
        statusText = remaining >= 0
            ? 'Deneme sürümü: $remaining gün kaldı'
            : 'Deneme süresi doldu';
        statusColor = remaining > 0 ? Colors.orange : Colors.red;
      } else if (user.subscriptionStatus ==
              auth_domain.SubscriptionStatus.active &&
          user.subscriptionEndAt != null) {
        remaining = user.subscriptionEndAt!.difference(now).inDays;
        statusText = remaining >= 0
            ? 'Abonelik aktif: $remaining gün kaldı'
            : 'Abonelik süresi doldu';
        statusColor = remaining > 0 ? Colors.green : Colors.red;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingGrid(
      BuildContext context, WidgetRef ref, auth_domain.User? user) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;
      final children = [
        Expanded(
          child: _buildPlanCard(
            context: context,
            ref: ref,
            user: user,
            title: 'Aylık Plan',
            priceText: '119 TRY',
            monthlyText: '≈ 119 TRY/ay',
            subtitle: 'Denemek için ideal',
            highlight: false,
            plan: auth_domain.SubscriptionPlan.monthly,
            duration: const Duration(days: 30),
          ),
        ),
        const SizedBox(width: 16, height: 16),
        Expanded(
          child: _buildPlanCard(
            context: context,
            ref: ref,
            user: user,
            title: 'Yıllık Plan',
            priceText: '999 TRY',
            monthlyText: '≈ 83 TRY/ay',
            subtitle: '%30 daha kârlı',
            highlight: true,
            plan: auth_domain.SubscriptionPlan.annual,
            duration: const Duration(days: 365),
          ),
        ),
        const SizedBox(width: 16, height: 16),
        Expanded(
          child: _buildPlanCard(
            context: context,
            ref: ref,
            user: user,
            title: '6 Aylık Plan',
            priceText: '649 TRY',
            monthlyText: '≈ 108 TRY/ay',
            subtitle: 'Küçük indirim',
            highlight: false,
            plan: auth_domain.SubscriptionPlan.semiAnnual,
            duration: const Duration(days: 182),
          ),
        ),
      ];

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          children[1 - 1], // Aylık
          const SizedBox(height: 16),
          children[1 + 1], // 6 Aylık
          const SizedBox(height: 16),
          children[1], // Yıllık (ortada & vurgulu)
        ],
      );
    });
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required WidgetRef ref,
    required auth_domain.User? user,
    required String title,
    required String priceText,
    required String monthlyText,
    required String subtitle,
    required bool highlight,
    required auth_domain.SubscriptionPlan plan,
    required Duration duration,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg =
        highlight ? Colors.white : (isDark ? Colors.white : Colors.black);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: highlight
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
              )
            : null,
        color: highlight
            ? null
            : (isDark ? TamgaciConstants.cardColorDark : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? Colors.transparent
              : Colors.grey.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: (highlight ? const Color(0xFF2563EB) : Colors.black)
                .withValues(alpha: highlight ? 0.25 : 0.06),
            blurRadius: highlight ? 24 : 12,
            spreadRadius: highlight ? 2 : 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'En Popüler',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          if (highlight) const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: highlight ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            priceText,
            style: TextStyle(
              fontSize: highlight ? 28 : 24,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            monthlyText,
            style: TextStyle(
              fontSize: 12,
              color: fg.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: fg.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: user == null
                  ? null
                  : () async {
                      final ok =
                          await const PaymentService().startCheckout(plan);
                      if (!ok) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ödeme sayfası açılamadı')),
                          );
                        }
                        return;
                      }
                      final start = DateTime.now();
                      final end = start.add(duration);
                      final updated = user.copyWith(
                        subscriptionStatus:
                            auth_domain.SubscriptionStatus.active,
                        subscriptionPlan: plan,
                        subscriptionStartAt: start,
                        subscriptionEndAt: end,
                      );
                      await ref
                          .read(authProvider.notifier)
                          .updateUserProfile(updated);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Abonelik etkinleştirildi')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    highlight ? Colors.white : const Color(0xFF2563EB),
                foregroundColor:
                    highlight ? const Color(0xFF2563EB) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Satın Al',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
