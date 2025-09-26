// ========== AUDIT LOG ENTITY ==========
// lib/features/products/domain/entities/audit_log.dart

/// Audit log entity - Tüm değişiklikleri takip eder
class AuditLog {
  final String id;
  final String entityType; // 'product', 'sale', 'purchase' etc.
  final String entityId;
  final String action; // 'create', 'update', 'delete', 'view'
  final String userId;
  final String? userName;
  final DateTime timestamp;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? reason;
  final String? ipAddress;
  final String? userAgent;

  AuditLog({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.userId,
    this.userName,
    required this.timestamp,
    this.oldValues,
    this.newValues,
    this.reason,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'action': action,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
      'oldValues': oldValues,
      'newValues': newValues,
      'reason': reason,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      action: json['action'],
      userId: json['userId'],
      userName: json['userName'],
      timestamp: DateTime.parse(json['timestamp']),
      oldValues: json['oldValues'] != null
          ? Map<String, dynamic>.from(json['oldValues'])
          : null,
      newValues: json['newValues'] != null
          ? Map<String, dynamic>.from(json['newValues'])
          : null,
      reason: json['reason'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
    );
  }
}
