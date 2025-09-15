import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamgaci/core/images/image_optimizer.dart';

void main() {
  group('ImageOptimizer Tests', () {
    late ImageOptimizer imageOptimizer;

    setUp(() {
      imageOptimizer = ImageOptimizer();
    });

    group('Configuration', () {
      test('should have default configuration', () {
        // Arrange & Act
        final config = imageOptimizer.config;

        // Assert
        expect(config.maxWidth, equals(1920));
        expect(config.maxHeight, equals(1080));
        expect(config.quality, equals(85));
        expect(config.format, equals(ImageFormat.jpeg));
        expect(config.enableCompression, isTrue);
        expect(config.enableResizing, isTrue);
      });

      test('should update configuration', () {
        // Arrange
        const newConfig = ImageOptimizationConfig(
          maxWidth: 1024,
          maxHeight: 768,
          quality: 90,
          format: ImageFormat.png,
          enableCompression: false,
          enableResizing: true,
        );

        // Act
        imageOptimizer.configure(newConfig);

        // Assert
        expect(imageOptimizer.config.maxWidth, equals(1024));
        expect(imageOptimizer.config.maxHeight, equals(768));
        expect(imageOptimizer.config.quality, equals(90));
        expect(imageOptimizer.config.format, equals(ImageFormat.png));
        expect(imageOptimizer.config.enableCompression, isFalse);
        expect(imageOptimizer.config.enableResizing, isTrue);
      });
    });

    group('Image Optimization', () {
      test('should optimize image successfully', () async {
        // Arrange
        final imageData =
            Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]); // Mock JPEG header
        const config = ImageOptimizationConfig(
          maxWidth: 800,
          maxHeight: 600,
          quality: 80,
          format: ImageFormat.jpeg,
          enableCompression: true,
          enableResizing: true,
        );

        // Act
        final result =
            await imageOptimizer.optimizeImage(imageData, config: config);

        // Assert
        expect(result, isNotNull);
        expect(result.data, isNotNull);
        expect(result.originalSize, equals(imageData.length));
        expect(result.optimizedSize, greaterThan(0));
        expect(result.compressionRatio, greaterThanOrEqualTo(1.0));
        expect(result.format, equals(ImageFormat.jpeg));
      });

      test('should handle optimization errors gracefully', () async {
        // Arrange
        final invalidImageData = Uint8List.fromList([]); // Empty data

        // Act
        final result = await imageOptimizer.optimizeImage(invalidImageData);

        // Assert
        expect(result, isNotNull);
        expect(result.data, equals(invalidImageData));
        expect(result.originalSize, equals(0));
        expect(result.optimizedSize, equals(0));
        expect(result.compressionRatio, closeTo(1.0, 0.01));
        expect(result.format, equals(ImageFormat.unknown));
      });

      test('should optimize image with default config', () async {
        // Arrange
        final imageData =
            Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]); // Mock JPEG header

        // Act
        final result = await imageOptimizer.optimizeImage(imageData);

        // Assert
        expect(result, isNotNull);
        expect(result.data, isNotNull);
        expect(result.originalSize, equals(imageData.length));
        expect(result.optimizedSize, greaterThan(0));
        expect(result.compressionRatio, greaterThanOrEqualTo(1.0));
      });
    });

    group('Batch Optimization', () {
      test('should batch optimize images successfully', () async {
        // Arrange
        final imageDataList = [
          Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]), // Mock JPEG
          Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]), // Mock PNG
          Uint8List.fromList([0x47, 0x49, 0x46, 0x38]), // Mock GIF
        ];

        // Act
        final results = await imageOptimizer.batchOptimizeImages(imageDataList);

        // Assert
        expect(results, hasLength(3));
        for (final result in results) {
          expect(result, isNotNull);
          expect(result.data, isNotNull);
          expect(result.originalSize, greaterThan(0));
          expect(result.optimizedSize, greaterThan(0));
          expect(result.compressionRatio, greaterThanOrEqualTo(1.0));
        }
      });

      test('should handle batch optimization errors gracefully', () async {
        // Arrange
        final imageDataList = [
          Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]), // Valid JPEG
          Uint8List.fromList([]), // Invalid empty data
          Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]), // Valid PNG
        ];

        // Act
        final results = await imageOptimizer.batchOptimizeImages(imageDataList);

        // Assert
        expect(results, hasLength(3));
        // All results should be returned, even if some failed
        for (final result in results) {
          expect(result, isNotNull);
          expect(result.data, isNotNull);
        }
      });
    });

    group('Image Validation', () {
      test('should validate valid image data', () {
        // Arrange
        final validJpegData = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
        final validPngData = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
        final validGifData = Uint8List.fromList([0x47, 0x49, 0x46, 0x38]);

        // Act & Assert
        expect(imageOptimizer.validateImage(validJpegData), isTrue);
        expect(imageOptimizer.validateImage(validPngData), isTrue);
        expect(imageOptimizer.validateImage(validGifData), isTrue);
      });

      test('should reject invalid image data', () {
        // Arrange
        final invalidData = Uint8List.fromList([]);
        final unknownData = Uint8List.fromList([0x00, 0x01, 0x02, 0x03]);

        // Act & Assert
        expect(imageOptimizer.validateImage(invalidData), isFalse);
        expect(imageOptimizer.validateImage(unknownData), isFalse);
      });
    });

    group('Optimization Statistics', () {
      test('should calculate optimization statistics', () {
        // Arrange
        final optimizedImages = [
          OptimizedImage(
            data: Uint8List.fromList([1, 2, 3, 4]),
            originalSize: 1000,
            optimizedSize: 500,
            compressionRatio: 2.0,
            format: ImageFormat.jpeg,
            width: 100,
            height: 100,
          ),
          OptimizedImage(
            data: Uint8List.fromList([5, 6, 7, 8]),
            originalSize: 2000,
            optimizedSize: 1000,
            compressionRatio: 2.0,
            format: ImageFormat.png,
            width: 200,
            height: 200,
          ),
          OptimizedImage(
            data: Uint8List.fromList([9, 10, 11, 12]),
            originalSize: 1500,
            optimizedSize: 1500,
            compressionRatio: 1.0,
            format: ImageFormat.gif,
            width: 150,
            height: 150,
          ),
        ];

        // Act
        final stats = imageOptimizer.getOptimizationStats(optimizedImages);

        // Assert
        expect(stats.totalImages, equals(3));
        expect(stats.successfulOptimizations, equals(2));
        expect(stats.totalOriginalSize, equals(4500));
        expect(stats.totalOptimizedSize, equals(3000));
        expect(stats.totalSavings, equals(1500));
        expect(stats.savingsPercentage, closeTo(33.33, 0.01));
        expect(stats.averageCompressionRatio, closeTo(1.67, 0.01));
      });

      test('should handle empty optimization statistics', () {
        // Arrange
        final optimizedImages = <OptimizedImage>[];

        // Act
        final stats = imageOptimizer.getOptimizationStats(optimizedImages);

        // Assert
        expect(stats.totalImages, equals(0));
        expect(stats.successfulOptimizations, equals(0));
        expect(stats.totalOriginalSize, equals(0));
        expect(stats.totalOptimizedSize, equals(0));
        expect(stats.totalSavings, equals(0));
        expect(stats.savingsPercentage, equals(0.0));
        expect(stats.averageCompressionRatio, equals(1.0));
      });
    });

    group('Recommended Settings', () {
      test('should return recommended settings for thumbnail', () {
        // Act
        final settings =
            imageOptimizer.getRecommendedSettings(ImageUseCase.thumbnail);

        // Assert
        expect(settings.maxWidth, equals(300));
        expect(settings.maxHeight, equals(300));
        expect(settings.quality, equals(70));
        expect(settings.format, equals(ImageFormat.jpeg));
        expect(settings.enableCompression, isTrue);
        expect(settings.enableResizing, isTrue);
      });

      test('should return recommended settings for profile', () {
        // Act
        final settings =
            imageOptimizer.getRecommendedSettings(ImageUseCase.profile);

        // Assert
        expect(settings.maxWidth, equals(500));
        expect(settings.maxHeight, equals(500));
        expect(settings.quality, equals(80));
        expect(settings.format, equals(ImageFormat.jpeg));
        expect(settings.enableCompression, isTrue);
        expect(settings.enableResizing, isTrue);
      });

      test('should return recommended settings for gallery', () {
        // Act
        final settings =
            imageOptimizer.getRecommendedSettings(ImageUseCase.gallery);

        // Assert
        expect(settings.maxWidth, equals(1920));
        expect(settings.maxHeight, equals(1080));
        expect(settings.quality, equals(85));
        expect(settings.format, equals(ImageFormat.jpeg));
        expect(settings.enableCompression, isTrue);
        expect(settings.enableResizing, isTrue);
      });

      test('should return recommended settings for document', () {
        // Act
        final settings =
            imageOptimizer.getRecommendedSettings(ImageUseCase.document);

        // Assert
        expect(settings.maxWidth, equals(2048));
        expect(settings.maxHeight, equals(2048));
        expect(settings.quality, equals(90));
        expect(settings.format, equals(ImageFormat.jpeg));
        expect(settings.enableCompression, isTrue);
        expect(settings.enableResizing, isTrue);
      });

      test('should return recommended settings for full size', () {
        // Act
        final settings =
            imageOptimizer.getRecommendedSettings(ImageUseCase.fullSize);

        // Assert
        expect(settings.maxWidth, equals(4096));
        expect(settings.maxHeight, equals(4096));
        expect(settings.quality, equals(95));
        expect(settings.format, equals(ImageFormat.jpeg));
        expect(settings.enableCompression, isFalse);
        expect(settings.enableResizing, isFalse);
      });
    });

    group('Image Format Detection', () {
      test('should detect JPEG format', () {
        // Arrange
        final jpegData = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

        // Act
        final format = imageOptimizer.getImageFormat(jpegData);

        // Assert
        expect(format, equals(ImageFormat.jpeg));
      });

      test('should detect PNG format', () {
        // Arrange
        final pngData = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);

        // Act
        final format = imageOptimizer.getImageFormat(pngData);

        // Assert
        expect(format, equals(ImageFormat.png));
      });

      test('should detect GIF format', () {
        // Arrange
        final gifData = Uint8List.fromList([0x47, 0x49, 0x46, 0x38]);

        // Act
        final format = imageOptimizer.getImageFormat(gifData);

        // Assert
        expect(format, equals(ImageFormat.gif));
      });

      test('should detect BMP format', () {
        // Arrange
        final bmpData = Uint8List.fromList([0x42, 0x4D, 0x00, 0x00]);

        // Act
        final format = imageOptimizer.getImageFormat(bmpData);

        // Assert
        expect(format, equals(ImageFormat.bmp));
      });

      test('should detect WebP format', () {
        // Arrange
        final webpData = Uint8List.fromList([0x52, 0x49, 0x46, 0x46]);

        // Act
        final format = imageOptimizer.getImageFormat(webpData);

        // Assert
        expect(format, equals(ImageFormat.webp));
      });

      test('should return unknown for invalid format', () {
        // Arrange
        final unknownData = Uint8List.fromList([0x00, 0x01, 0x02, 0x03]);

        // Act
        final format = imageOptimizer.getImageFormat(unknownData);

        // Assert
        expect(format, equals(ImageFormat.unknown));
      });

      test('should return unknown for empty data', () {
        // Arrange
        final emptyData = Uint8List.fromList([]);

        // Act
        final format = imageOptimizer.getImageFormat(emptyData);

        // Assert
        expect(format, equals(ImageFormat.unknown));
      });
    });
  });
}
