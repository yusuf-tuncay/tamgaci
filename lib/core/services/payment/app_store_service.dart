// ========== APP STORE SERVICE ==========
// lib/core/services/payment/app_store_service.dart

import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../features/subscription/domain/entities/subscription_plan.dart';
import '../../../features/auth/domain/entities/user.dart';

/// iOS App Store abonelik servisi
class AppStoreService {
  static final AppStoreService _instance = AppStoreService._internal();
  factory AppStoreService() => _instance;
  AppStoreService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  /// App Store ürün ID'leri
  static const Map<SubscriptionPlanType, String> _productIds = {
    SubscriptionPlanType.monthly: 'com.tamgaci.monthly',
    SubscriptionPlanType.semiAnnual: 'com.tamgaci.semi_annual',
    SubscriptionPlanType.annual: 'com.tamgaci.annual',
  };

  /// App Store abonelik başlat
  Future<AppStorePurchaseResult> startSubscription({
    required User user,
    required SubscriptionPlanType planType,
  }) async {
    try {
      // iOS kontrolü
      if (!Platform.isIOS) {
        return const AppStorePurchaseResult(
          success: false,
          error: 'App Store sadece iOS\'ta kullanılabilir',
        );
      }

      // Ürün ID'sini al
      final productId = _productIds[planType];
      if (productId == null) {
        return const AppStorePurchaseResult(
          success: false,
          error: 'Geçersiz plan tipi',
        );
      }

      // Mevcut ürünleri al
      final productDetailsResponse = await _inAppPurchase.queryProductDetails(
        {productId},
      );

      if (productDetailsResponse.error != null) {
        return AppStorePurchaseResult(
          success: false,
          error: 'Ürün bilgileri alınamadı: ${productDetailsResponse.error}',
        );
      }

      final products = productDetailsResponse.productDetails;
      if (products.isEmpty) {
        return const AppStorePurchaseResult(
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
        return AppStorePurchaseResult(
          success: true,
          productId: productId,
          message: 'Satın alma işlemi başlatıldı',
        );
      } else {
        return const AppStorePurchaseResult(
          success: false,
          error: 'Satın alma işlemi başlatılamadı',
        );
      }
    } catch (e) {
      debugPrint('App Store Purchase Error: $e');
      return AppStorePurchaseResult(
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
  Future<AppStorePurchaseResult> checkPurchaseStatus(String productId) async {
    try {
      // restorePurchases() void döndürüyor, bu yüzden farklı yaklaşım kullanıyoruz
      await _inAppPurchase.restorePurchases();

      // Şimdilik basit bir kontrol - gerçek implementasyonda App Store API'si kullanılacak
      // Bu placeholder implementation - production'da App Store receipt validation yapılacak

      return const AppStorePurchaseResult(
        success: false,
        error:
            'Abonelik durumu kontrol edilemedi - App Store API entegrasyonu gerekli',
      );
    } catch (e) {
      debugPrint('App Store Status Check Error: $e');
      return AppStorePurchaseResult(
        success: false,
        error: 'Durum kontrolü hatası: $e',
      );
    }
  }

  /// Aboneliği iptal et
  Future<AppStorePurchaseResult> cancelSubscription(String productId) async {
    try {
      // App Store'da abonelik iptali kullanıcı tarafından yapılır
      // Bu sadece bilgilendirme amaçlı
      return const AppStorePurchaseResult(
        success: true,
        message: 'Abonelik iptali için App Store ayarlarına gidin',
      );
    } catch (e) {
      debugPrint('App Store Cancel Error: $e');
      return AppStorePurchaseResult(
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

/// App Store satın alma sonucu
class AppStorePurchaseResult {
  final bool success;
  final String? productId;
  final String? message;
  final String? error;

  const AppStorePurchaseResult({
    required this.success,
    this.productId,
    this.message,
    this.error,
  });
}
