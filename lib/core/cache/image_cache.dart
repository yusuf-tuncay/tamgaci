import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tamgaci/core/errors/error_logger.dart';
import 'package:tamgaci/core/cache/cache_manager.dart';

/// Image cache manager for handling image caching
class ImageCache {
  static final ImageCache _instance = ImageCache._internal();
  factory ImageCache() => _instance;
  ImageCache._internal();

  final CacheManager _cacheManager = CacheManager();
  static const String _imageCachePrefix = 'image_cache_';
  static const Duration _defaultImageExpiry = Duration(days: 7);
  static const int _maxImageSize = 10 * 1024 * 1024; // 10MB per image

  /// Get cached image
  Future<Uint8List?> getCachedImage(String imageUrl) async {
    try {
      final cacheKey = '$_imageCachePrefix${_getImageKey(imageUrl)}';

      final cachedData = await _cacheManager.get<Map<String, dynamic>>(
        cacheKey,
        fromJson: (data) => data,
      );

      if (cachedData != null) {
        final imageData = cachedData['data'] as String;
        final bytes = Uint8List.fromList(imageData.codeUnits);

        ErrorLogger.logDebug(
          'Image cache hit: $imageUrl',
          context: 'ImageCache',
          additionalData: {'size': bytes.length},
        );

        return bytes;
      }

      ErrorLogger.logDebug(
        'Image cache miss: $imageUrl',
        context: 'ImageCache',
      );

      return null;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting cached image: $imageUrl',
        error: e,
        context: 'ImageCache',
      );
      return null;
    }
  }

  /// Cache image
  Future<void> cacheImage(String imageUrl, Uint8List imageData) async {
    try {
      // Check image size
      if (imageData.length > _maxImageSize) {
        ErrorLogger.logWarning(
          'Image too large to cache: $imageUrl',
          context: 'ImageCache',
          additionalData: {'size': imageData.length, 'maxSize': _maxImageSize},
        );
        return;
      }

      final cacheKey = '$_imageCachePrefix${_getImageKey(imageUrl)}';
      final cacheData = {
        'url': imageUrl,
        'data': String.fromCharCodes(imageData),
        'size': imageData.length,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _cacheManager.set(
        cacheKey,
        cacheData,
        expiry: _defaultImageExpiry,
      );

      ErrorLogger.logDebug(
        'Image cached: $imageUrl',
        context: 'ImageCache',
        additionalData: {'size': imageData.length},
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error caching image: $imageUrl',
        error: e,
        context: 'ImageCache',
      );
    }
  }

  /// Remove cached image
  Future<void> removeCachedImage(String imageUrl) async {
    try {
      final cacheKey = '$_imageCachePrefix${_getImageKey(imageUrl)}';
      await _cacheManager.remove(cacheKey);

      ErrorLogger.logDebug(
        'Cached image removed: $imageUrl',
        context: 'ImageCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error removing cached image: $imageUrl',
        error: e,
        context: 'ImageCache',
      );
    }
  }

  /// Clear all cached images
  Future<void> clearAllImages() async {
    try {
      // This would require more complex logic to remove only image cache items
      // For now, we'll clear all cache
      await _cacheManager.clear();

      ErrorLogger.logInfo(
        'All cached images cleared',
        context: 'ImageCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error clearing all cached images',
        error: e,
        context: 'ImageCache',
      );
    }
  }

  /// Check if image is cached
  Future<bool> isImageCached(String imageUrl) async {
    try {
      final cacheKey = '$_imageCachePrefix${_getImageKey(imageUrl)}';
      return await _cacheManager.exists(cacheKey);
    } catch (e) {
      ErrorLogger.logError(
        'Error checking if image is cached: $imageUrl',
        error: e,
        context: 'ImageCache',
      );
      return false;
    }
  }

  /// Get cached image info
  Future<ImageCacheInfo?> getImageCacheInfo(String imageUrl) async {
    try {
      final cacheKey = '$_imageCachePrefix${_getImageKey(imageUrl)}';

      final cachedData = await _cacheManager.get<Map<String, dynamic>>(
        cacheKey,
        fromJson: (data) => data,
      );

      if (cachedData != null) {
        return ImageCacheInfo(
          url: cachedData['url'] as String,
          size: cachedData['size'] as int,
          cachedAt: DateTime.parse(cachedData['cachedAt'] as String),
        );
      }

      return null;
    } catch (e) {
      ErrorLogger.logError(
        'Error getting image cache info: $imageUrl',
        error: e,
        context: 'ImageCache',
      );
      return null;
    }
  }

  /// Get all cached images info
  Future<List<ImageCacheInfo>> getAllCachedImagesInfo() async {
    try {
      // This would require more complex logic to get all image cache items
      // For now, we'll return empty list
      return [];
    } catch (e) {
      ErrorLogger.logError(
        'Error getting all cached images info',
        error: e,
        context: 'ImageCache',
      );
      return [];
    }
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      return await _cacheManager.getCacheSize();
    } catch (e) {
      ErrorLogger.logError(
        'Error getting image cache size',
        error: e,
        context: 'ImageCache',
      );
      return 0;
    }
  }

  /// Cleanup expired images
  Future<void> cleanupExpiredImages() async {
    try {
      await _cacheManager.cleanup();

      ErrorLogger.logInfo(
        'Expired images cleanup completed',
        context: 'ImageCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error cleaning up expired images',
        error: e,
        context: 'ImageCache',
      );
    }
  }

  /// Preload images
  Future<void> preloadImages(List<String> imageUrls) async {
    try {
      ErrorLogger.logInfo(
        'Preloading ${imageUrls.length} images',
        context: 'ImageCache',
      );

      for (final url in imageUrls) {
        try {
          // Check if already cached
          if (await isImageCached(url)) {
            continue;
          }

          // Download and cache image
          await _downloadAndCacheImage(url);
        } catch (e) {
          ErrorLogger.logError(
            'Error preloading image: $url',
            error: e,
            context: 'ImageCache',
          );
        }
      }

      ErrorLogger.logInfo(
        'Image preloading completed',
        context: 'ImageCache',
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error preloading images',
        error: e,
        context: 'ImageCache',
      );
    }
  }

  /// Download and cache image
  Future<void> _downloadAndCacheImage(String imageUrl) async {
    try {
      // This would typically use http package to download image
      // For now, we'll just log the action
      ErrorLogger.logDebug(
        'Downloading image: $imageUrl',
        context: 'ImageCache',
      );

      // Simulate download
      await Future.delayed(const Duration(milliseconds: 100));

      // In real implementation, you would:
      // 1. Download image using http.get()
      // 2. Convert response body to Uint8List
      // 3. Cache the image data
    } catch (e) {
      ErrorLogger.logError(
        'Error downloading image: $imageUrl',
        error: e,
        context: 'ImageCache',
      );
    }
  }

  /// Get image key from URL
  String _getImageKey(String imageUrl) {
    // Create a hash of the URL for use as cache key
    return imageUrl.hashCode.toString();
  }

  /// Compress image
  Future<Uint8List> compressImage(Uint8List imageData,
      {int quality = 80}) async {
    try {
      // This would typically use image compression library
      // For now, we'll return the original data
      ErrorLogger.logDebug(
        'Image compression requested',
        context: 'ImageCache',
        additionalData: {
          'originalSize': imageData.length,
          'quality': quality,
        },
      );

      return imageData;
    } catch (e) {
      ErrorLogger.logError(
        'Error compressing image',
        error: e,
        context: 'ImageCache',
      );
      return imageData;
    }
  }

  /// Resize image
  Future<Uint8List> resizeImage(
    Uint8List imageData, {
    int? width,
    int? height,
  }) async {
    try {
      // This would typically use image resizing library
      // For now, we'll return the original data
      ErrorLogger.logDebug(
        'Image resize requested',
        context: 'ImageCache',
        additionalData: {
          'originalSize': imageData.length,
          'targetWidth': width,
          'targetHeight': height,
        },
      );

      return imageData;
    } catch (e) {
      ErrorLogger.logError(
        'Error resizing image',
        error: e,
        context: 'ImageCache',
      );
      return imageData;
    }
  }

  /// Get image format
  String getImageFormat(Uint8List imageData) {
    try {
      if (imageData.length < 4) return 'unknown';

      // Check for common image formats
      if (imageData[0] == 0xFF && imageData[1] == 0xD8) return 'jpeg';
      if (imageData[0] == 0x89 &&
          imageData[1] == 0x50 &&
          imageData[2] == 0x4E &&
          imageData[3] == 0x47) {
        return 'png';
      }
      if (imageData[0] == 0x47 &&
          imageData[1] == 0x49 &&
          imageData[2] == 0x46) {
        return 'gif';
      }
      if (imageData[0] == 0x42 && imageData[1] == 0x4D) return 'bmp';
      if (imageData[0] == 0x52 &&
          imageData[1] == 0x49 &&
          imageData[2] == 0x46 &&
          imageData[3] == 0x46) {
        return 'webp';
      }

      return 'unknown';
    } catch (e) {
      ErrorLogger.logError(
        'Error detecting image format',
        error: e,
        context: 'ImageCache',
      );
      return 'unknown';
    }
  }

  /// Validate image
  bool validateImage(Uint8List imageData) {
    try {
      if (imageData.isEmpty) return false;

      final format = getImageFormat(imageData);
      return format != 'unknown';
    } catch (e) {
      ErrorLogger.logError(
        'Error validating image',
        error: e,
        context: 'ImageCache',
      );
      return false;
    }
  }
}

/// Image cache info
class ImageCacheInfo {
  final String url;
  final int size;
  final DateTime cachedAt;

  const ImageCacheInfo({
    required this.url,
    required this.size,
    required this.cachedAt,
  });

  @override
  String toString() {
    return 'ImageCacheInfo(url: $url, size: $size, cachedAt: $cachedAt)';
  }
}

/// Image cache configuration
class ImageCacheConfig {
  final Duration expiry;
  final int maxSize;
  final int maxCount;
  final bool enableCompression;
  final int compressionQuality;
  final bool enableResizing;
  final int? maxWidth;
  final int? maxHeight;

  const ImageCacheConfig({
    this.expiry = const Duration(days: 7),
    this.maxSize = 10 * 1024 * 1024, // 10MB
    this.maxCount = 500,
    this.enableCompression = true,
    this.compressionQuality = 80,
    this.enableResizing = false,
    this.maxWidth,
    this.maxHeight,
  });
}
