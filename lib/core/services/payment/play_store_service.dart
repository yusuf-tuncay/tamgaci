// ========== PLAY STORE SERVICE ==========
// lib/core/services/payment/play_store_service.dart

import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../features/subscription/domain/entities/subscription_plan.dart';
import '../../../features/auth/domain/entities/user.dart';

/// Android Play Store abonelik servisi
class PlayStoreService {
  static final PlayStoreService _instance = PlayStoreService._internal();
  factory PlayStoreService() => _instance;
  PlayStoreService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  /// Play Store ürün ID'leri
  static const Map<SubscriptionPlanType, String> _productIds = {
    SubscriptionPlanType.monthly: 'com.tamgaci.monthly',
    SubscriptionPlanType.semiAnnual: 'com.tamgaci.semi_annual',
    SubscriptionPlanType.annual: 'com.tamgaci.annual',
  };

  /// Play Store abonelik başlat
  Future<PlayStorePurchaseResult> startSubscription({
    required User user,
    required SubscriptionPlanType planType,
  }) async {
    try {
      // Android kontrolü
      if (!Platform.isAndroid) {
        return const PlayStorePurchaseResult(
          success: false,
          error: 'Play Store sadece Android\'de kullanılabilir',
        );
      }

      // Ürün ID'sini al
      final productId = _productIds[planType];
      if (productId == null) {
        return const PlayStorePurchaseResult(
          success: false,
          error: 'Geçersiz plan tipi',
        );
      }

      // Mevcut ürünleri al
      final productDetailsResponse = await _inAppPurchase.queryProductDetails(
        {productId},
      );

      if (productDetailsResponse.error != null) {
        return PlayStorePurchaseResult(
          success: false,
          error: 'Ürün bilgileri alınamadı: ${productDetailsResponse.error}',
        );
      }

      final products = productDetailsResponse.productDetails;
      if (products.isEmpty) {
        return const PlayStorePurchaseResult(
          success: false,
          error: 'Ürün bulunamadı',
        );
      }

      // Satın alma işlemini başlat
      final productDetails = products.first;
      final purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: user.id,
      );

      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (success) {
        return PlayStorePurchaseResult(
          success: true,
          productId: productId,
          message: 'Satın alma işlemi başlatıldı',
        );
      } else {
        return const PlayStorePurchaseResult(
          success: false,
          error: 'Satın alma işlemi başlatılamadı',
        );
      }
    } catch (e) {
      debugPrint('Play Store Purchase Error: $e');
      return PlayStorePurchaseResult(
        success: false,
        error: 'Satın alma hatası: $e',
      );
    }
  }

  /// Satın alma durumunu dinle
  void listenToPurchases(Function(PurchaseDetails) onPurchaseUpdate) {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        for (final purchaseDetails in purchaseDetailsList) {
          onPurchaseUpdate(purchaseDetails);
        }
      },
    );
  }

  /// Satın alma durumunu kontrol et
  Future<PlayStorePurchaseResult> checkPurchaseStatus(String productId) async {
    try {
      // restorePurchases() void döndürüyor, bu yüzden farklı yaklaşım kullanıyoruz
      await _inAppPurchase.restorePurchases();
      
      // Şimdilik basit bir kontrol - gerçek implementasyonda Play Store API'si kullanılacak
      // Bu placeholder implementation - production'da Play Store receipt validation yapılacak
      
      return const PlayStorePurchaseResult(
        success: false,
        error: 'Abonelik durumu kontrol edilemedi - Play Store API entegrasyonu gerekli',
      );
    } catch (e) {
      debugPrint('Play Store Status Check Error: $e');
      return PlayStorePurchaseResult(
        success: false,
        error: 'Durum kontrolü hatası: $e',
      );
    }
  }

  /// Aboneliği iptal et
  Future<PlayStorePurchaseResult> cancelSubscription(String productId) async {
    try {
      // Play Store'da abonelik iptali kullanıcı tarafından yapılır
      // Bu sadece bilgilendirme amaçlı
      return PlayStorePurchaseResult(
        success: true,
        message: 'Abonelik iptali için Play Store ayarlarına gidin',
      );
    } catch (e) {
      debugPrint('Play Store Cancel Error: $e');
      return PlayStorePurchaseResult(
        success: false,
        error: 'İptal hatası: $e',
      );
    }
  }

  /// Satın alma dinleyicisini temizle
  void dispose() {
    _subscription.cancel();
  }
}

/// Play Store satın alma sonucu
class PlayStorePurchaseResult {
  final bool success;
  final String? productId;
  final String? message;
  final String? error;

  const PlayStorePurchaseResult({
    required this.success,
    this.productId,
    this.message,
    this.error,
  });
}
