import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamgaci/features/reports/domain/entities/report.dart';

/// Report model for Firebase integration
class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.name,
    super.description,
    required super.type,
    required super.format,
    required super.status,
    super.parameters,
    super.filters,
    super.data,
    super.fileUrl,
    super.fileName,
    super.fileSize,
    super.generatedAt,
    super.expiresAt,
    super.generatedBy,
    super.errorMessage,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  @override
  ReportModel copyWith({
    String? id,
    String? name,
    String? description,
    ReportType? type,
    ReportFormat? format,
    ReportStatus? status,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? data,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    DateTime? generatedAt,
    DateTime? expiresAt,
    String? generatedBy,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ReportModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      format: format ?? this.format,
      status: status ?? this.status,
      parameters: parameters ?? this.parameters,
      filters: filters ?? this.filters,
      data: data ?? this.data,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      generatedBy: generatedBy ?? this.generatedBy,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// Firestore DocumentSnapshot'tan ReportModel oluşturur
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      type: ReportType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ReportType.custom,
      ),
      format: ReportFormat.values.firstWhere(
        (e) => e.name == data['format'],
        orElse: () => ReportFormat.pdf,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReportStatus.pending,
      ),
      parameters: Map<String, dynamic>.from(data['parameters'] ?? {}),
      filters: Map<String, dynamic>.from(data['filters'] ?? {}),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      fileUrl: data['fileUrl'] as String?,
      fileName: data['fileName'] as String?,
      fileSize: data['fileSize'] as int?,
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      generatedBy: data['generatedBy'] as String?,
      errorMessage: data['errorMessage'] as String?,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  /// ReportModel'i Firestore'a uygun Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'format': format.name,
      'status': status.name,
      'parameters': parameters,
      'filters': filters,
      'data': data,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'generatedAt':
          generatedAt != null ? Timestamp.fromDate(generatedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'generatedBy': generatedBy,
      'errorMessage': errorMessage,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// ReportModel'i Report entity'sine dönüştürür
  Report toEntity() {
    return Report(
      id: id,
      name: name,
      description: description,
      type: type,
      format: format,
      status: status,
      parameters: parameters,
      filters: filters,
      data: data,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      generatedAt: generatedAt,
      expiresAt: expiresAt,
      generatedBy: generatedBy,
      errorMessage: errorMessage,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Report entity'sinden ReportModel oluşturur
  factory ReportModel.fromEntity(Report report) {
    return ReportModel(
      id: report.id,
      name: report.name,
      description: report.description,
      type: report.type,
      format: report.format,
      status: report.status,
      parameters: report.parameters,
      filters: report.filters,
      data: report.data,
      fileUrl: report.fileUrl,
      fileName: report.fileName,
      fileSize: report.fileSize,
      generatedAt: report.generatedAt,
      expiresAt: report.expiresAt,
      generatedBy: report.generatedBy,
      errorMessage: report.errorMessage,
      metadata: report.metadata,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
      createdBy: report.createdBy,
      updatedBy: report.updatedBy,
    );
  }
}
