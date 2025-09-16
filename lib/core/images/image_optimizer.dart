import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Image optimizer for handling image compression and optimization
class ImageOptimizer {
  static final ImageOptimizer _instance = ImageOptimizer._internal();
  factory ImageOptimizer() => _instance;
  ImageOptimizer._internal();

  /// Default optimization settings
  static const ImageOptimizationConfig _defaultConfig = ImageOptimizationConfig(
    maxWidth: 1920,
    maxHeight: 1080,
    quality: 85,
    format: ImageFormat.jpeg,
    enableCompression: true,
    enableResizing: true,
  );

  ImageOptimizationConfig _config = _defaultConfig;

  /// Get current configuration
  ImageOptimizationConfig get config => _config;

  /// Get image format from data
  ImageFormat getImageFormat(Uint8List data) {
    if (data.length < 4) return ImageFormat.unknown;

    // Check magic bytes
    if (data[0] == 0xFF && data[1] == 0xD8) return ImageFormat.jpeg;
    if (data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      return ImageFormat.png;
    }
    if (data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46) {
      return ImageFormat.gif;
    }
    if (data[0] == 0x42 && data[1] == 0x4D) return ImageFormat.bmp;
    if (data[0] == 0x52 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x46) {
      return ImageFormat.webp;
    }

    return ImageFormat.unknown;
  }

  /// Set configuration
  void configure(ImageOptimizationConfig config) {
    _config = config;
    ErrorLogger.logInfo(
      'Image optimization configuration updated',
      context: 'ImageOptimizer',
      additionalData: {
        'maxWidth': config.maxWidth,
        'maxHeight': config.maxHeight,
        'quality': config.quality,
        'format': config.format.name,
        'enableCompression': config.enableCompression,
        'enableResizing': config.enableResizing,
      },
    );
  }

  /// Optimize image
  Future<OptimizedImage> optimizeImage(
    Uint8List imageData, {
    ImageOptimizationConfig? config,
  }) async {
    try {
      final optimizationConfig = config ?? _config;

      ErrorLogger.logInfo(
        'Optimizing image',
        context: 'ImageOptimizer',
        additionalData: {
          'originalSize': imageData.length,
          'config': optimizationConfig.toString(),
        },
      );

      Uint8List optimizedData = imageData;
      ImageInfo imageInfo = _getImageInfo(imageData);

      // Resize image if needed
      if (optimizationConfig.enableResizing) {
        optimizedData = await _resizeImage(
          optimizedData,
          optimizationConfig.maxWidth,
          optimizationConfig.maxHeight,
        );
        imageInfo = _getImageInfo(optimizedData);
      }

      // Compress image if needed
      if (optimizationConfig.enableCompression) {
        optimizedData = await _compressImage(
          optimizedData,
          optimizationConfig.quality,
          optimizationConfig.format,
        );
      }

      final optimizedImage = OptimizedImage(
        data: optimizedData,
        originalSize: imageData.length,
        optimizedSize: optimizedData.length,
        compressionRatio: imageData.length / optimizedData.length,
        format: optimizationConfig.format,
        width: imageInfo.width,
        height: imageInfo.height,
      );

      ErrorLogger.logInfo(
        'Image optimization completed',
        context: 'ImageOptimizer',
        additionalData: {
          'originalSize': imageData.length,
          'optimizedSize': optimizedData.length,
          'compressionRatio': optimizedImage.compressionRatio,
          'savings':
              '${((1 - optimizedData.length / imageData.length) * 100).toStringAsFixed(1)}%',
        },
      );

      return optimizedImage;
    } catch (e) {
      ErrorLogger.logError(
        'Error optimizing image',
        error: e,
        context: 'ImageOptimizer',
      );

      // Return original image if optimization fails
      return OptimizedImage(
        data: imageData,
        originalSize: imageData.length,
        optimizedSize: imageData.length,
        compressionRatio: 1.0,
        format: ImageFormat.unknown,
        width: 0,
        height: 0,
      );
    }
  }

  /// Resize image
  Future<Uint8List> _resizeImage(
    Uint8List imageData,
    int maxWidth,
    int maxHeight,
  ) async {
    try {
      // This would typically use image processing library
      // For now, we'll return the original data
      ErrorLogger.logDebug(
        'Image resize requested',
        context: 'ImageOptimizer',
        additionalData: {
          'maxWidth': maxWidth,
          'maxHeight': maxHeight,
        },
      );

      return imageData;
    } catch (e) {
      ErrorLogger.logError(
        'Error resizing image',
        error: e,
        context: 'ImageOptimizer',
      );
      return imageData;
    }
  }

  /// Compress image
  Future<Uint8List> _compressImage(
    Uint8List imageData,
    int quality,
    ImageFormat format,
  ) async {
    try {
      // This would typically use image compression library
      // For now, we'll return the original data
      ErrorLogger.logDebug(
        'Image compression requested',
        context: 'ImageOptimizer',
        additionalData: {
          'quality': quality,
          'format': format.name,
        },
      );

      return imageData;
    } catch (e) {
      ErrorLogger.logError(
        'Error compressing image',
        error: e,
        context: 'ImageOptimizer',
      );
      return imageData;
    }
  }

  /// Get image information
  ImageInfo _getImageInfo(Uint8List imageData) {
    try {
      // This would typically parse image metadata
      // For now, we'll return default values
      return ImageInfo(
        width: 0,
        height: 0,
        format: _detectImageFormat(imageData),
        size: imageData.length,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error getting image info',
        error: e,
        context: 'ImageOptimizer',
      );
      return ImageInfo(
        width: 0,
        height: 0,
        format: ImageFormat.unknown,
        size: imageData.length,
      );
    }
  }

  /// Detect image format
  ImageFormat _detectImageFormat(Uint8List imageData) {
    try {
      if (imageData.length < 4) return ImageFormat.unknown;

      // Check for common image formats
      if (imageData[0] == 0xFF && imageData[1] == 0xD8) return ImageFormat.jpeg;
      if (imageData[0] == 0x89 &&
          imageData[1] == 0x50 &&
          imageData[2] == 0x4E &&
          imageData[3] == 0x47) {
        return ImageFormat.png;
      }
      if (imageData[0] == 0x47 &&
          imageData[1] == 0x49 &&
          imageData[2] == 0x46) {
        return ImageFormat.gif;
      }
      if (imageData[0] == 0x42 && imageData[1] == 0x4D) return ImageFormat.bmp;
      if (imageData[0] == 0x52 &&
          imageData[1] == 0x49 &&
          imageData[2] == 0x46 &&
          imageData[3] == 0x46) {
        return ImageFormat.webp;
      }

      return ImageFormat.unknown;
    } catch (e) {
      ErrorLogger.logError(
        'Error detecting image format',
        error: e,
        context: 'ImageOptimizer',
      );
      return ImageFormat.unknown;
    }
  }

  /// Batch optimize images
  Future<List<OptimizedImage>> batchOptimizeImages(
    List<Uint8List> imageDataList, {
    ImageOptimizationConfig? config,
  }) async {
    try {
      ErrorLogger.logInfo(
        'Batch optimizing ${imageDataList.length} images',
        context: 'ImageOptimizer',
      );

      final optimizedImages = <OptimizedImage>[];

      for (int i = 0; i < imageDataList.length; i++) {
        try {
          final optimizedImage =
              await optimizeImage(imageDataList[i], config: config);
          optimizedImages.add(optimizedImage);
        } catch (e) {
          ErrorLogger.logError(
            'Error optimizing image $i',
            error: e,
            context: 'ImageOptimizer',
          );

          // Add original image if optimization fails
          optimizedImages.add(OptimizedImage(
            data: imageDataList[i],
            originalSize: imageDataList[i].length,
            optimizedSize: imageDataList[i].length,
            compressionRatio: 1.0,
            format: ImageFormat.unknown,
            width: 0,
            height: 0,
          ));
        }
      }

      ErrorLogger.logInfo(
        'Batch image optimization completed',
        context: 'ImageOptimizer',
        additionalData: {
          'totalImages': imageDataList.length,
          'successfulOptimizations': optimizedImages.length,
        },
      );

      return optimizedImages;
    } catch (e) {
      ErrorLogger.logError(
        'Error batch optimizing images',
        error: e,
        context: 'ImageOptimizer',
      );
      return [];
    }
  }

  /// Get optimization statistics
  OptimizationStats getOptimizationStats(List<OptimizedImage> optimizedImages) {
    try {
      int totalOriginalSize = 0;
      int totalOptimizedSize = 0;
      int successfulOptimizations = 0;

      for (final image in optimizedImages) {
        totalOriginalSize += image.originalSize;
        totalOptimizedSize += image.optimizedSize;
        if (image.compressionRatio > 1.0) {
          successfulOptimizations++;
        }
      }

      final totalSavings = totalOriginalSize - totalOptimizedSize;
      final savingsPercentage = totalOriginalSize > 0
          ? (totalSavings / totalOriginalSize) * 100
          : 0.0;

      return OptimizationStats(
        totalImages: optimizedImages.length,
        successfulOptimizations: successfulOptimizations,
        totalOriginalSize: totalOriginalSize,
        totalOptimizedSize: totalOptimizedSize,
        totalSavings: totalSavings,
        savingsPercentage: savingsPercentage,
        averageCompressionRatio: optimizedImages.isNotEmpty
            ? optimizedImages
                    .map((img) => img.compressionRatio)
                    .reduce((a, b) => a + b) /
                optimizedImages.length
            : 1.0,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error calculating optimization statistics',
        error: e,
        context: 'ImageOptimizer',
      );
      return OptimizationStats.empty();
    }
  }

  /// Validate image
  bool validateImage(Uint8List imageData) {
    try {
      if (imageData.isEmpty) return false;

      final format = _detectImageFormat(imageData);
      return format != ImageFormat.unknown;
    } catch (e) {
      ErrorLogger.logError(
        'Error validating image',
        error: e,
        context: 'ImageOptimizer',
      );
      return false;
    }
  }

  /// Get recommended settings for different use cases
  ImageOptimizationConfig getRecommendedSettings(ImageUseCase useCase) {
    switch (useCase) {
      case ImageUseCase.thumbnail:
        return const ImageOptimizationConfig(
          maxWidth: 300,
          maxHeight: 300,
          quality: 70,
          format: ImageFormat.jpeg,
          enableCompression: true,
          enableResizing: true,
        );
      case ImageUseCase.profile:
        return const ImageOptimizationConfig(
          maxWidth: 500,
          maxHeight: 500,
          quality: 80,
          format: ImageFormat.jpeg,
          enableCompression: true,
          enableResizing: true,
        );
      case ImageUseCase.gallery:
        return const ImageOptimizationConfig(
          maxWidth: 1920,
          maxHeight: 1080,
          quality: 85,
          format: ImageFormat.jpeg,
          enableCompression: true,
          enableResizing: true,
        );
      case ImageUseCase.document:
        return const ImageOptimizationConfig(
          maxWidth: 2048,
          maxHeight: 2048,
          quality: 90,
          format: ImageFormat.jpeg,
          enableCompression: true,
          enableResizing: true,
        );
      case ImageUseCase.fullSize:
        return const ImageOptimizationConfig(
          maxWidth: 4096,
          maxHeight: 4096,
          quality: 95,
          format: ImageFormat.jpeg,
          enableCompression: false,
          enableResizing: false,
        );
    }
  }
}

/// Image optimization configuration
class ImageOptimizationConfig {
  final int maxWidth;
  final int maxHeight;
  final int quality;
  final ImageFormat format;
  final bool enableCompression;
  final bool enableResizing;

  const ImageOptimizationConfig({
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
    required this.format,
    required this.enableCompression,
    required this.enableResizing,
  });

  @override
  String toString() {
    return 'ImageOptimizationConfig(maxWidth: $maxWidth, maxHeight: $maxHeight, quality: $quality, format: ${format.name})';
  }
}

/// Image format enum
enum ImageFormat {
  jpeg,
  png,
  gif,
  bmp,
  webp,
  unknown,
}

/// Image use case enum
enum ImageUseCase {
  thumbnail,
  profile,
  gallery,
  document,
  fullSize,
}

/// Optimized image result
class OptimizedImage {
  final Uint8List data;
  final int originalSize;
  final int optimizedSize;
  final double compressionRatio;
  final ImageFormat format;
  final int width;
  final int height;

  const OptimizedImage({
    required this.data,
    required this.originalSize,
    required this.optimizedSize,
    required this.compressionRatio,
    required this.format,
    required this.width,
    required this.height,
  });

  /// Get size savings in bytes
  int get sizeSavings => originalSize - optimizedSize;

  /// Get size savings percentage
  double get sizeSavingsPercentage =>
      originalSize > 0 ? (sizeSavings / originalSize) * 100 : 0.0;

  @override
  String toString() {
    return 'OptimizedImage(original: $originalSize, optimized: $optimizedSize, ratio: ${compressionRatio.toStringAsFixed(2)}, format: ${format.name})';
  }
}

/// Image information
class ImageInfo {
  final int width;
  final int height;
  final ImageFormat format;
  final int size;

  const ImageInfo({
    required this.width,
    required this.height,
    required this.format,
    required this.size,
  });

  @override
  String toString() {
    return 'ImageInfo(${width}x$height, ${format.name}, ${size}bytes)';
  }
}

/// Optimization statistics
class OptimizationStats {
  final int totalImages;
  final int successfulOptimizations;
  final int totalOriginalSize;
  final int totalOptimizedSize;
  final int totalSavings;
  final double savingsPercentage;
  final double averageCompressionRatio;

  const OptimizationStats({
    required this.totalImages,
    required this.successfulOptimizations,
    required this.totalOriginalSize,
    required this.totalOptimizedSize,
    required this.totalSavings,
    required this.savingsPercentage,
    required this.averageCompressionRatio,
  });

  factory OptimizationStats.empty() => const OptimizationStats(
        totalImages: 0,
        successfulOptimizations: 0,
        totalOriginalSize: 0,
        totalOptimizedSize: 0,
        totalSavings: 0,
        savingsPercentage: 0.0,
        averageCompressionRatio: 1.0,
      );

  @override
  String toString() {
    return 'OptimizationStats(images: $totalImages, savings: ${savingsPercentage.toStringAsFixed(1)}%, ratio: ${averageCompressionRatio.toStringAsFixed(2)})';
  }
}
