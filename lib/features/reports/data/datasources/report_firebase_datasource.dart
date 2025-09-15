import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamgaci/core/utils/logger.dart';
import 'package:tamgaci/features/reports/data/models/report_model.dart';
import 'package:tamgaci/features/reports/domain/entities/report.dart';

/// Report Firebase DataSource
/// Firebase Firestore ile doğrudan etkileşimi yönetir.
class ReportFirebaseDataSource {
  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final FirebaseAuth _firebaseAuth;

  ReportFirebaseDataSource(this._firestore, this._firebaseAuth);

  /// Tüm raporları getirir
  Future<List<ReportModel>> getAllReports({
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('reports')
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
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all reports', e);
      rethrow;
    }
  }

  /// ID'ye göre rapor getirir
  Future<ReportModel?> getReportById(String id) async {
    try {
      final doc = await _firestore.collection('reports').doc(id).get();
      if (doc.exists) {
        return ReportModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting report by id: $id', e);
      rethrow;
    }
  }

  /// Türüne göre raporları getirir
  Future<List<ReportModel>> getReportsByType(
    ReportType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('reports')
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('reports')
            .where('type', isEqualTo: type.name)
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
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting reports by type: ${type.name}', e);
      rethrow;
    }
  }

  /// Duruma göre raporları getirir
  Future<List<ReportModel>> getReportsByStatus(
    ReportStatus status, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('reports')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('reports')
            .where('status', isEqualTo: status.name)
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
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting reports by status: ${status.name}', e);
      rethrow;
    }
  }

  /// Formatına göre raporları getirir
  Future<List<ReportModel>> getReportsByFormat(
    ReportFormat format, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('reports')
          .where('format', isEqualTo: format.name)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('reports')
            .where('format', isEqualTo: format.name)
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
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting reports by format: ${format.name}', e);
      rethrow;
    }
  }

  /// Kullanıcıya göre raporları getirir
  Future<List<ReportModel>> getReportsByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('reports')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('reports')
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
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting reports by user: $userId', e);
      rethrow;
    }
  }

  /// Tarih aralığına göre raporları getirir
  Future<List<ReportModel>> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection('reports')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true);

      if (offset != null && offset > 0) {
        final offsetDoc = await _firestore
            .collection('reports')
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate))
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
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting reports by date range', e);
      rethrow;
    }
  }

  /// Yeni rapor oluşturur
  Future<ReportModel> createReport(ReportModel report) async {
    try {
      final docRef = _firestore.collection('reports').doc();
      final newReport = report.copyWith(id: docRef.id);

      await docRef.set(newReport.toFirestore());
      AppLogger.info('Report created: ${newReport.name}');
      return newReport;
    } catch (e) {
      AppLogger.error('Error creating report', e);
      rethrow;
    }
  }

  /// Rapor günceller
  Future<ReportModel> updateReport(ReportModel report) async {
    try {
      await _firestore
          .collection('reports')
          .doc(report.id)
          .update(report.toFirestore());

      AppLogger.info('Report updated: ${report.name}');
      return report;
    } catch (e) {
      AppLogger.error('Error updating report: ${report.id}', e);
      rethrow;
    }
  }

  /// Rapor siler
  Future<void> deleteReport(String id) async {
    try {
      await _firestore.collection('reports').doc(id).delete();
      AppLogger.info('Report deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting report: $id', e);
      rethrow;
    }
  }

  /// Rapor arama
  Future<List<ReportModel>> searchReports(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Basit arama - name ve description'da arama
      final snapshot = await _firestore
          .collection('reports')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit ?? 50)
          .get();

      final results =
          snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();

      // Eğer yeterli sonuç yoksa, description'da da ara
      if (results.length < (limit ?? 50)) {
        final descSnapshot = await _firestore
            .collection('reports')
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThanOrEqualTo: '$query\uf8ff')
            .limit((limit ?? 50) - results.length)
            .get();

        final descResults = descSnapshot.docs
            .map((doc) => ReportModel.fromFirestore(doc))
            .where((report) => !results.any((r) => r.id == report.id))
            .toList();

        results.addAll(descResults);
      }

      return results;
    } catch (e) {
      AppLogger.error('Error searching reports: $query', e);
      rethrow;
    }
  }

  /// Rapor sayısını getirir
  Future<int> getReportsCount() async {
    try {
      final snapshot = await _firestore.collection('reports').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting reports count', e);
      rethrow;
    }
  }

  /// Rapor oluşturur
  Future<ReportModel> generateReport(
    ReportType type,
    ReportFormat format, {
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final reportNumber = await generateReportNumber(type);
      final now = DateTime.now();

      final report = ReportModel(
        id: '',
        name: reportNumber,
        type: type,
        format: format,
        status: ReportStatus.pending,
        parameters: parameters ?? {},
        filters: filters ?? {},
        data: const {},
        createdAt: now,
        updatedAt: now,
      );

      return await createReport(report);
    } catch (e) {
      AppLogger.error('Error generating report', e);
      rethrow;
    }
  }

  /// Rapor verilerini getirir
  Future<Map<String, dynamic>> getReportData(String id) async {
    try {
      final doc = await _firestore.collection('reports').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      return {};
    } catch (e) {
      AppLogger.error('Error getting report data: $id', e);
      rethrow;
    }
  }

  /// Rapor dosyasını indirir
  Future<String> downloadReport(String id) async {
    try {
      final doc = await _firestore.collection('reports').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final fileUrl = data['fileUrl'] as String?;
        if (fileUrl != null) {
          return fileUrl;
        }
      }
      throw Exception('Report file not found');
    } catch (e) {
      AppLogger.error('Error downloading report: $id', e);
      rethrow;
    }
  }

  /// Rapor şablonlarını getirir
  Future<List<Map<String, dynamic>>> getReportTemplates({String? type}) async {
    try {
      Query query = _firestore.collection('report_templates');

      if (type != null) {
        query = query.where('reportType', isEqualTo: type);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      AppLogger.error('Error getting report templates', e);
      rethrow;
    }
  }

  /// Rapor istatistiklerini getirir
  Future<Map<String, dynamic>> getReportStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('reports');

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final stats = <String, dynamic>{
        'totalCount': snapshot.docs.length,
        'typeCounts': <String, int>{},
        'statusCounts': <String, int>{},
        'formatCounts': <String, int>{},
      };

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final type = data['type'] as String;
        final status = data['status'] as String;
        final format = data['format'] as String;

        stats['typeCounts'][type] =
            (stats['typeCounts'][type] as int? ?? 0) + 1;
        stats['statusCounts'][status] =
            (stats['statusCounts'][status] as int? ?? 0) + 1;
        stats['formatCounts'][format] =
            (stats['formatCounts'][format] as int? ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      AppLogger.error('Error getting report statistics', e);
      rethrow;
    }
  }

  /// Rapor numarası oluşturur
  Future<String> generateReportNumber(ReportType type) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final prefix = type.name.toUpperCase();
      final datePrefix = '$year$month$day';

      // Bugünkü aynı tipte kaç tane rapor var?
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('reports')
          .where('type', isEqualTo: type.name)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();

      final count = snapshot.docs.length + 1;
      final number = count.toString().padLeft(4, '0');

      return '$prefix-$datePrefix-$number';
    } catch (e) {
      AppLogger.error('Error generating report number', e);
      rethrow;
    }
  }
}
