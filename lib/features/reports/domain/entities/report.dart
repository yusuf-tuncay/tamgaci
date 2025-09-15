import 'package:equatable/equatable.dart';

/// Rapor türü
enum ReportType {
  sales('Satış Raporu'),
  purchases('Alış Raporu'),
  cashFlow('Nakit Akış Raporu'),
  inventory('Envanter Raporu'),
  profitLoss('Kar/Zarar Raporu'),
  balanceSheet('Bilanço Raporu'),
  customer('Müşteri Raporu'),
  supplier('Tedarikçi Raporu'),
  product('Ürün Raporu'),
  custom('Özel Rapor');

  const ReportType(this.displayName);
  final String displayName;
}

/// Rapor formatı
enum ReportFormat {
  pdf('PDF'),
  excel('Excel'),
  csv('CSV'),
  json('JSON');

  const ReportFormat(this.displayName);
  final String displayName;
}

/// Rapor durumu
enum ReportStatus {
  pending('Beklemede'),
  generating('Oluşturuluyor'),
  completed('Tamamlandı'),
  failed('Başarısız'),
  expired('Süresi Dolmuş');

  const ReportStatus(this.displayName);
  final String displayName;
}

/// Rapor entity'si
class Report extends Equatable {
  final String id;
  final String name;
  final String? description;
  final ReportType type;
  final ReportFormat format;
  final ReportStatus status;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> data;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime? generatedAt;
  final DateTime? expiresAt;
  final String? generatedBy;
  final String? errorMessage;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const Report({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.format,
    required this.status,
    this.parameters = const {},
    this.filters = const {},
    this.data = const {},
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.generatedAt,
    this.expiresAt,
    this.generatedBy,
    this.errorMessage,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  Report copyWith({
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
    return Report(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'generatedAt': generatedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'generatedBy': generatedBy,
      'errorMessage': errorMessage,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.custom,
      ),
      format: ReportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ReportFormat.pdf,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      filters: Map<String, dynamic>.from(json['filters'] ?? {}),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      generatedBy: json['generatedBy'] as String?,
      errorMessage: json['errorMessage'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        format,
        status,
        parameters,
        filters,
        data,
        fileUrl,
        fileName,
        fileSize,
        generatedAt,
        expiresAt,
        generatedBy,
        errorMessage,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
