import 'package:tamgaci/features/reports/domain/entities/report.dart';
import 'package:tamgaci/features/reports/domain/repositories/report_repository.dart';

/// Raporları getirme use case'i
class GetReportsUseCase {
  final ReportRepository _repository;

  GetReportsUseCase(this._repository);

  /// Tüm raporları getirir
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> call({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getAllReports(
      limit: limit,
      offset: offset,
    );
  }

  /// Türüne göre raporları getirir
  /// [type]: Rapor türü
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getByType(
    ReportType type, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getReportsByType(
      type,
      limit: limit,
      offset: offset,
    );
  }

  /// Duruma göre raporları getirir
  /// [status]: Rapor durumu
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getByStatus(
    ReportStatus status, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getReportsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
  }

  /// Formatına göre raporları getirir
  /// [format]: Rapor formatı
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getByFormat(
    ReportFormat format, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getReportsByFormat(
      format,
      limit: limit,
      offset: offset,
    );
  }

  /// Kullanıcıya göre raporları getirir
  /// [userId]: Kullanıcı ID'si
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getReportsByUser(
      userId,
      limit: limit,
      offset: offset,
    );
  }

  /// Tarih aralığına göre raporları getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> getByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getReportsByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Rapor arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum rapor sayısı
  /// [offset]: Atlanacak rapor sayısı
  /// Returns: Rapor listesi
  Future<List<Report>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.searchReports(
      query,
      limit: limit,
      offset: offset,
    );
  }
}
