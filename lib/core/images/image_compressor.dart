import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tamgaci/core/errors/error_logger.dart';

/// Image compressor for handling image compression operations
class ImageCompressor {
  static final ImageCompressor _instance = ImageCompressor._internal();
  factory ImageCompressor() => _instance;
  ImageCompressor._internal();

  /// Default compression settings
  static const CompressionConfig _defaultConfig = CompressionConfig(
    quality: 85,
    maxWidth: 1920,
    maxHeight: 1080,
    format: CompressionFormat.jpeg,
    enableProgressive: true,
    enableOptimization: true,
  );

  CompressionConfig _config = _defaultConfig;

  /// Get current configuration
  CompressionConfig get config => _config;

  /// Set configuration
  void configure(CompressionConfig config) {
    _config = config;
    ErrorLogger.logInfo(
      'Image compression configuration updated',
      context: 'ImageCompressor',
      additionalData: {
        'quality': config.quality,
        'maxWidth': config.maxWidth,
        'maxHeight': config.maxHeight,
        'format': config.format.name,
        'enableProgressive': config.enableProgressive,
        'enableOptimization': config.enableOptimization,
      },
    );
  }

  /// Compress image
  Future<CompressedImage> compressImage(
    Uint8List imageData, {
    CompressionConfig? config,
  }) async {
    try {
      final compressionConfig = config ?? _config;

      ErrorLogger.logInfo(
        'Compressing image',
        context: 'ImageCompressor',
        additionalData: {
          'originalSize': imageData.length,
          'config': compressionConfig.toString(),
        },
      );

      Uint8List compressedData = imageData;
      CompressionInfo compressionInfo = _getCompressionInfo(imageData);

      // Apply compression based on format
      switch (compressionConfig.format) {
        case CompressionFormat.jpeg:
          compressedData = await _compressJpeg(imageData, compressionConfig);
          break;
        case CompressionFormat.png:
          compressedData = await _compressPng(imageData, compressionConfig);
          break;
        case CompressionFormat.webp:
          compressedData = await _compressWebp(imageData, compressionConfig);
          break;
        case CompressionFormat.auto:
          compressedData = await _compressAuto(imageData, compressionConfig);
          break;
      }

      final compressedImage = CompressedImage(
        data: compressedData,
        originalSize: imageData.length,
        compressedSize: compressedData.length,
        compressionRatio: imageData.length / compressedData.length,
        format: compressionConfig.format,
        quality: compressionConfig.quality,
        width: compressionInfo.width,
        height: compressionInfo.height,
      );

      ErrorLogger.logInfo(
        'Image compression completed',
        context: 'ImageCompressor',
        additionalData: {
          'originalSize': imageData.length,
          'compressedSize': compressedData.length,
          'compressionRatio': compressedImage.compressionRatio,
          'savings':
              '${((1 - compressedData.length / imageData.length) * 100).toStringAsFixed(1)}%',
        },
      );

      return compressedImage;
    } catch (e) {
      ErrorLogger.logError(
        'Error compressing image',
        error: e,
        context: 'ImageCompressor',
      );

      // Return original image if compression fails
      return CompressedImage(
        data: imageData,
        originalSize: imageData.length,
        compressedSize: imageData.length,
        compressionRatio: 1.0,
        format: CompressionFormat.auto,
        quality: 100,
        width: 0,
        height: 0,
      );
    }
  }

  /// Compress JPEG image
  Future<Uint8List> _compressJpeg(
    Uint8List imageData,
    CompressionConfig config,
  ) async {
    try {
      // This would typically use JPEG compression library
      // For now, we'll return the original data
      ErrorLogger.logDebug(
        'JPEG compression requested',
        context: 'ImageCompressor',
        additionalData: {
          'quality': config.quality,
          'progressive': config.enableProgressive,
        },
      );

      return imageData;
    } catch (e) {
      ErrorLogger.logError(
        'Error compressing JPEG',
        error: e,
        context: 'ImageCompressor',
      );
      return imageData;
    }
  }

  /// Compress PNG image
  Future<Uint8List> _compressPng(
    Uint8List imageData,
    CompressionConfig config,
  ) async {
    try {
      // This would typically use PNG compression library
      // For now, we'll return the original data
      ErrorLogger.logDebug(
        'PNG compression requested',
        context: 'ImageCompressor',
        additionalData: {
          'optimization': config.enableOptimization,
        },
      );

      return imageData;
    } catch (e) {
      ErrorLogger.logError(
        'Error compressing PNG',
        error: e,
        context: 'ImageCompressor',
      );
      return imageData;
    }
  }

  /// Compress WebP image
  Future<Uint8List> _compressWebp(
    Uint8List imageData,
    CompressionConfig config,
  ) async {
    try {
      // This would typically use WebP compression library
      // For now, we'll return the original data
      ErrorLogger.logDebug(
        'WebP compression requested',
        context: 'ImageCompressor',
        additionalData: {
          'quality': config.quality,
        },
      );

      return imageData;
    } catch (e) {
      ErrorLogger.logError(
        'Error compressing WebP',
        error: e,
        context: 'ImageCompressor',
      );
      return imageData;
    }
  }

  /// Auto compress based on image format
  Future<Uint8List> _compressAuto(
    Uint8List imageData,
    CompressionConfig config,
  ) async {
    try {
      final format = _detectImageFormat(imageData);

      switch (format) {
        case CompressionFormat.jpeg:
          return await _compressJpeg(imageData, config);
        case CompressionFormat.png:
          return await _compressPng(imageData, config);
        case CompressionFormat.webp:
          return await _compressWebp(imageData, config);
        default:
          return imageData;
      }
    } catch (e) {
      ErrorLogger.logError(
        'Error auto compressing image',
        error: e,
        context: 'ImageCompressor',
      );
      return imageData;
    }
  }

  /// Detect image format
  CompressionFormat _detectImageFormat(Uint8List imageData) {
    try {
      if (imageData.length < 4) {
        return CompressionFormat.auto;
      }

      // Check for common image formats
      if (imageData[0] == 0xFF && imageData[1] == 0xD8) {
        return CompressionFormat.jpeg;
      }
      if (imageData[0] == 0x89 &&
          imageData[1] == 0x50 &&
          imageData[2] == 0x4E &&
          imageData[3] == 0x47) {
        return CompressionFormat.png;
      }
      if (imageData[0] == 0x52 &&
          imageData[1] == 0x49 &&
          imageData[2] == 0x46 &&
          imageData[3] == 0x46) {
        return CompressionFormat.webp;
      }

      return CompressionFormat.auto;
    } catch (e) {
      ErrorLogger.logError(
        'Error detecting image format',
        error: e,
        context: 'ImageCompressor',
      );
      return CompressionFormat.auto;
    }
  }

  /// Get compression information
  CompressionInfo _getCompressionInfo(Uint8List imageData) {
    try {
      // This would typically parse image metadata
      // For now, we'll return default values
      return CompressionInfo(
        width: 0,
        height: 0,
        format: _detectImageFormat(imageData),
        size: imageData.length,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error getting compression info',
        error: e,
        context: 'ImageCompressor',
      );
      return CompressionInfo(
        width: 0,
        height: 0,
        format: CompressionFormat.auto,
        size: imageData.length,
      );
    }
  }

  /// Batch compress images
  Future<List<CompressedImage>> batchCompressImages(
    List<Uint8List> imageDataList, {
    CompressionConfig? config,
  }) async {
    try {
      ErrorLogger.logInfo(
        'Batch compressing ${imageDataList.length} images',
        context: 'ImageCompressor',
      );

      final compressedImages = <CompressedImage>[];

      for (int i = 0; i < imageDataList.length; i++) {
        try {
          final compressedImage =
              await compressImage(imageDataList[i], config: config);
          compressedImages.add(compressedImage);
        } catch (e) {
          ErrorLogger.logError(
            'Error compressing image $i',
            error: e,
            context: 'ImageCompressor',
          );

          // Add original image if compression fails
          compressedImages.add(CompressedImage(
            data: imageDataList[i],
            originalSize: imageDataList[i].length,
            compressedSize: imageDataList[i].length,
            compressionRatio: 1.0,
            format: CompressionFormat.auto,
            quality: 100,
            width: 0,
            height: 0,
          ));
        }
      }

      ErrorLogger.logInfo(
        'Batch image compression completed',
        context: 'ImageCompressor',
        additionalData: {
          'totalImages': imageDataList.length,
          'successfulCompressions': compressedImages.length,
        },
      );

      return compressedImages;
    } catch (e) {
      ErrorLogger.logError(
        'Error batch compressing images',
        error: e,
        context: 'ImageCompressor',
      );
      return [];
    }
  }

  /// Get compression statistics
  CompressionStats getCompressionStats(List<CompressedImage> compressedImages) {
    try {
      int totalOriginalSize = 0;
      int totalCompressedSize = 0;
      int successfulCompressions = 0;

      for (final image in compressedImages) {
        totalOriginalSize += image.originalSize;
        totalCompressedSize += image.compressedSize;
        if (image.compressionRatio > 1.0) {
          successfulCompressions++;
        }
      }

      final totalSavings = totalOriginalSize - totalCompressedSize;
      final savingsPercentage = totalOriginalSize > 0
          ? (totalSavings / totalOriginalSize) * 100
          : 0.0;

      return CompressionStats(
        totalImages: compressedImages.length,
        successfulCompressions: successfulCompressions,
        totalOriginalSize: totalOriginalSize,
        totalCompressedSize: totalCompressedSize,
        totalSavings: totalSavings,
        savingsPercentage: savingsPercentage,
        averageCompressionRatio: compressedImages.isNotEmpty
            ? compressedImages
                    .map((img) => img.compressionRatio)
                    .reduce((a, b) => a + b) /
                compressedImages.length
            : 1.0,
      );
    } catch (e) {
      ErrorLogger.logError(
        'Error calculating compression statistics',
        error: e,
        context: 'ImageCompressor',
      );
      return CompressionStats.empty();
    }
  }

  /// Get recommended compression settings
  CompressionConfig getRecommendedSettings(CompressionUseCase useCase) {
    switch (useCase) {
      case CompressionUseCase.thumbnail:
        return const CompressionConfig(
          quality: 70,
          maxWidth: 300,
          maxHeight: 300,
          format: CompressionFormat.jpeg,
          enableProgressive: false,
          enableOptimization: true,
        );
      case CompressionUseCase.profile:
        return const CompressionConfig(
          quality: 80,
          maxWidth: 500,
          maxHeight: 500,
          format: CompressionFormat.jpeg,
          enableProgressive: true,
          enableOptimization: true,
        );
      case CompressionUseCase.gallery:
        return const CompressionConfig(
          quality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
          format: CompressionFormat.jpeg,
          enableProgressive: true,
          enableOptimization: true,
        );
      case CompressionUseCase.document:
        return const CompressionConfig(
          quality: 90,
          maxWidth: 2048,
          maxHeight: 2048,
          format: CompressionFormat.jpeg,
          enableProgressive: true,
          enableOptimization: true,
        );
      case CompressionUseCase.web:
        return const CompressionConfig(
          quality: 75,
          maxWidth: 1200,
          maxHeight: 800,
          format: CompressionFormat.webp,
          enableProgressive: true,
          enableOptimization: true,
        );
    }
  }
}

/// Compression configuration
class CompressionConfig {
  final int quality;
  final int maxWidth;
  final int maxHeight;
  final CompressionFormat format;
  final bool enableProgressive;
  final bool enableOptimization;

  const CompressionConfig({
    required this.quality,
    required this.maxWidth,
    required this.maxHeight,
    required this.format,
    required this.enableProgressive,
    required this.enableOptimization,
  });

  @override
  String toString() {
    return 'CompressionConfig(quality: $quality, maxSize: ${maxWidth}x$maxHeight, format: ${format.name})';
  }
}

/// Compression format enum
enum CompressionFormat {
  jpeg,
  png,
  webp,
  auto,
}

/// Compression use case enum
enum CompressionUseCase {
  thumbnail,
  profile,
  gallery,
  document,
  web,
}

/// Compressed image result
class CompressedImage {
  final Uint8List data;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final CompressionFormat format;
  final int quality;
  final int width;
  final int height;

  const CompressedImage({
    required this.data,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.format,
    required this.quality,
    required this.width,
    required this.height,
  });

  /// Get size savings in bytes
  int get sizeSavings => originalSize - compressedSize;

  /// Get size savings percentage
  double get sizeSavingsPercentage =>
      originalSize > 0 ? (sizeSavings / originalSize) * 100 : 0.0;

  @override
  String toString() {
    return 'CompressedImage(original: $originalSize, compressed: $compressedSize, ratio: ${compressionRatio.toStringAsFixed(2)}, format: ${format.name})';
  }
}

/// Compression information
class CompressionInfo {
  final int width;
  final int height;
  final CompressionFormat format;
  final int size;

  const CompressionInfo({
    required this.width,
    required this.height,
    required this.format,
    required this.size,
  });

  @override
  String toString() {
    return 'CompressionInfo(${width}x$height, ${format.name}, ${size}bytes)';
  }
}

/// Compression statistics
class CompressionStats {
  final int totalImages;
  final int successfulCompressions;
  final int totalOriginalSize;
  final int totalCompressedSize;
  final int totalSavings;
  final double savingsPercentage;
  final double averageCompressionRatio;

  const CompressionStats({
    required this.totalImages,
    required this.successfulCompressions,
    required this.totalOriginalSize,
    required this.totalCompressedSize,
    required this.totalSavings,
    required this.savingsPercentage,
    required this.averageCompressionRatio,
  });

  factory CompressionStats.empty() => const CompressionStats(
        totalImages: 0,
        successfulCompressions: 0,
        totalOriginalSize: 0,
        totalCompressedSize: 0,
        totalSavings: 0,
        savingsPercentage: 0.0,
        averageCompressionRatio: 1.0,
      );

  @override
  String toString() {
    return 'CompressionStats(images: $totalImages, savings: ${savingsPercentage.toStringAsFixed(1)}%, ratio: ${averageCompressionRatio.toStringAsFixed(2)})';
  }
}
