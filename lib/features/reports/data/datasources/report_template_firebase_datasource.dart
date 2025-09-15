import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/reports/data/models/report_template_model.dart';
import 'package:tamgaci/features/reports/domain/entities/report_template.dart';

/// ReportTemplate Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class ReportTemplateFirebaseDataSource {
  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth;

  ReportTemplateFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm rapor şablonlarını getirir
  Future<List<ReportTemplateModel>> getAllReportTemplates({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('report_templates')
          .orderBy('sortOrder', descending: false)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('report_templates')
            .orderBy('sortOrder', descending: false)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReportTemplateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all report templates', e);
      rethrow;
    }
  }

  /// ID'ye göre rapor şablonu getirir
  Future<ReportTemplateModel?> getReportTemplateById(String id) async {
    try {
      final doc = await _firestore.collection('report_templates').doc(id).get();
      if (doc.exists) {
        return ReportTemplateModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting report template by id: $id', e);
      rethrow;
    }
  }

  /// Türüne göre rapor şablonlarını getirir
  Future<List<ReportTemplateModel>> getReportTemplatesByType(
    ReportTemplateType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('report_templates')
          .where('type', isEqualTo: type.name)
          .orderBy('sortOrder', descending: false)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('report_templates')
            .where('type', isEqualTo: type.name)
            .orderBy('sortOrder', descending: false)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReportTemplateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting report templates by type: ${type.name}', e);
      rethrow;
    }
  }

  /// Rapor türüne göre şablonları getirir
  Future<List<ReportTemplateModel>> getReportTemplatesByReportType(
    String reportType, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('report_templates')
          .where('reportType', isEqualTo: reportType)
          .orderBy('sortOrder', descending: false)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('report_templates')
            .where('reportType', isEqualTo: reportType)
            .orderBy('sortOrder', descending: false)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReportTemplateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting report templates by report type: $reportType', e);
      rethrow;
    }
  }

  /// Aktif rapor şablonlarını getirir
  Future<List<ReportTemplateModel>> getActiveReportTemplates({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('report_templates')
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder', descending: false)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('report_templates')
            .where('isActive', isEqualTo: true)
            .orderBy('sortOrder', descending: false)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReportTemplateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting active report templates', e);
      rethrow;
    }
  }

  /// Varsayılan rapor şablonlarını getirir
  Future<List<ReportTemplateModel>> getDefaultReportTemplates({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('report_templates')
          .where('isDefault', isEqualTo: true)
          .orderBy('sortOrder', descending: false)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('report_templates')
            .where('isDefault', isEqualTo: true)
            .orderBy('sortOrder', descending: false)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReportTemplateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting default report templates', e);
      rethrow;
    }
  }

  /// Kullanıcıya göre rapor şablonlarını getirir
  Future<List<ReportTemplateModel>> getReportTemplatesByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('report_templates')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('report_templates')
            .where('createdBy', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(offset)
            .get();
        if (offsetDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetDoc.docs.last);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReportTemplateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting report templates by user: $userId', e);
      rethrow;
    }
  }

  /// Yeni rapor şablonu oluşturur
  Future<ReportTemplateModel> createReportTemplate(
      ReportTemplateModel reportTemplate) async {
    try {
      final docRef = _firestore.collection('report_templates').doc();
      final newReportTemplate = reportTemplate.copyWith(id: docRef.id);

      await docRef.set(newReportTemplate.toFirestore());
      AppLogger.info('Report template created: ${newReportTemplate.name}');
      return newReportTemplate;
    } catch (e) {
      AppLogger.error('Error creating report template', e);
      rethrow;
    }
  }

  /// Rapor şablonu günceller
  Future<ReportTemplateModel> updateReportTemplate(
      ReportTemplateModel reportTemplate) async {
    try {
      await _firestore
          .collection('report_templates')
          .doc(reportTemplate.id)
          .update(reportTemplate.toFirestore());

      AppLogger.info('Report template updated: ${reportTemplate.name}');
      return reportTemplate;
    } catch (e) {
      AppLogger.error(
          'Error updating report template: ${reportTemplate.id}', e);
      rethrow;
    }
  }

  /// Rapor şablonu siler
  Future<void> deleteReportTemplate(String id) async {
    try {
      await _firestore.collection('report_templates').doc(id).delete();
      AppLogger.info('Report template deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting report template: $id', e);
      rethrow;
    }
  }

  /// Rapor şablonu arama
  Future<List<ReportTemplateModel>> searchReportTemplates(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - name ve description'da arama
      final snapshot = await _firestore
          .collection('report_templates')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results = snapshot.docs
          .map((doc) => ReportTemplateModel.fromFirestore(doc))
          .toList();

      // Eğer yeterli sonuç yoksa, description'da da ara
      if (results.length < (limit ?? 50)) {
        final descSnapshot = await _firestore
            .collection('report_templates')
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThanOrEqualTo: '$query\uf8ff')
            .limit((limit ?? 50) - results.length)
            .get();

        final descResults = descSnapshot.docs
            .map((doc) => ReportTemplateModel.fromFirestore(doc))
            .where((template) => !results.any((r) => r.id == template.id))
            .toList();

        results.addAll(descResults);
      }

      return results;
    } catch (e) {
      AppLogger.error('Error searching report templates: $query', e);
      rethrow;
    }
  }

  /// Rapor şablonu sayısını getirir
  Future<int> getReportTemplatesCount() async {
    try {
      final snapshot =
          await _firestore.collection('report_templates').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting report templates count', e);
      rethrow;
    }
  }

  /// Rapor şablonu istatistiklerini getirir
  Future<Map<String, dynamic>> getReportTemplateStatistics() async {
    try {
      final snapshot = await _firestore.collection('report_templates').get();
      final int totalCount = snapshot.docs.length;
      final Map<String, int> typeCounts = {};
      final Map<String, int> reportTypeCounts = {};
      int activeCount = 0;
      int defaultCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String? ?? 'unknown';
        final reportType = data['reportType'] as String? ?? 'unknown';
        final isActive = data['isActive'] as bool? ?? false;
        final isDefault = data['isDefault'] as bool? ?? false;

        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
        reportTypeCounts[reportType] = (reportTypeCounts[reportType] ?? 0) + 1;

        if (isActive) activeCount += 1;
        if (isDefault) defaultCount += 1;
      }

      return {
        'totalCount': totalCount,
        'typeCounts': typeCounts,
        'reportTypeCounts': reportTypeCounts,
        'activeCount': activeCount,
        'defaultCount': defaultCount,
      };
    } catch (e) {
      AppLogger.error('Error getting report template statistics', e);
      rethrow;
    }
  }

  /// Rapor şablonu numarası oluşturur
  Future<String> generateReportTemplateNumber(ReportTemplateType type) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final prefix = type.name.toUpperCase();
      final datePrefix = '$year$month$day';

      // Bugünkü aynı tipte kaç tane şablon var?
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('report_templates')
          .where('type', isEqualTo: type.name)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();

      final count = snapshot.docs.length + 1;
      final number = count.toString().padLeft(4, '0');

      return '$prefix-$datePrefix-$number';
    } catch (e) {
      AppLogger.error('Error generating report template number', e);
      rethrow;
    }
  }

  /// Rapor şablonu kategorilerini getirir
  Future<List<String>> getReportTemplateCategories() async {
    try {
      final snapshot = await _firestore.collection('report_templates').get();
      final categories = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      AppLogger.error('Error getting report template categories', e);
      rethrow;
    }
  }

  /// Rapor şablonu etiketlerini getirir
  Future<List<String>> getReportTemplateTags() async {
    try {
      final snapshot = await _firestore.collection('report_templates').get();
      final tags = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final templateTags = data['tags'] as List<dynamic>?;
        if (templateTags != null) {
          for (final tag in templateTags) {
            if (tag is String && tag.isNotEmpty) {
              tags.add(tag);
            }
          }
        }
      }

      return tags.toList()..sort();
    } catch (e) {
      AppLogger.error('Error getting report template tags', e);
      rethrow;
    }
  }

  /// Rapor şablonu önerilerini getirir
  Future<List<ReportTemplateModel>> getReportTemplateSuggestions(
    String reportType, {
    int limit = 5,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('report_templates')
          .where('reportType', isEqualTo: reportType)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ReportTemplateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting report template suggestions', e);
      rethrow;
    }
  }
}
