import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web platformu için asset yükleme yardımcı sınıfı
class WebAssetLoader {
  /// Web'de asset yollarını düzeltir
  static String getAssetPath(String assetPath) {
    if (kIsWeb) {
      // Web'de asset yolları / ile başlamalı
      if (!assetPath.startsWith('/')) {
        return '/$assetPath';
      }
      return assetPath;
    }
    return assetPath;
  }

  /// Web'de güvenilir asset widget'ı oluşturur
  static Widget buildAssetImage({
    required String assetPath,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    BlendMode? colorBlendMode,
    Widget? fallback,
  }) {
    if (kIsWeb) {
      return Image.network(
        getAssetPath(assetPath),
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (context, error, stackTrace) {
          // Network yüklenemezse asset'i dene
          return Image.asset(
            assetPath,
            width: width,
            height: height,
            fit: fit,
            color: color,
            colorBlendMode: colorBlendMode,
            errorBuilder: (context, error, stackTrace) {
              // Son fallback
              return fallback ?? const Icon(Icons.error);
            },
          );
        },
      );
    } else {
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (context, error, stackTrace) {
          return fallback ?? const Icon(Icons.error);
        },
      );
    }
  }
}
