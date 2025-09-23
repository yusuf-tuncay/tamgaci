// ========== APPROVAL WORKFLOW ENTITY ==========
// lib/features/workflow/domain/entities/approval_workflow.dart

/// Onay akışı türü
enum ApprovalWorkflowType {
  sales('Satış Onayı'),
  purchase('Satınalma Onayı'),
  payment('Ödeme Onayı'),
  expense('Gider Onayı'),
  inventory('Stok Onayı'),
  document('Belge Onayı'),
  custom('Özel Onay');

  const ApprovalWorkflowType(this.displayName);
  final String displayName;
}

/// Onay akışı durumu
enum ApprovalWorkflowStatus {
  draft('Taslak'),
  pending('Beklemede'),
  inProgress('Devam Ediyor'),
  approved('Onaylandı'),
  rejected('Reddedildi'),
  cancelled('İptal Edildi'),
  expired('Süresi Doldu');

  const ApprovalWorkflowStatus(this.displayName);
  final String displayName;
}

/// Onay akışı entity'si
class ApprovalWorkflow {
  final String id;
  final String workflowNumber;
  final ApprovalWorkflowType type;
  final ApprovalWorkflowStatus status;
  final String title;
  final String? description;
  final String? documentId; // İlgili belge ID'si
  final String? documentType; // İlgili belge türü
  final String? documentNumber; // İlgili belge numarası
  final double? amount; // Onay tutarı
  final String? currency; // Para birimi
  final String? priority; // Öncelik (Low, Medium, High, Critical)
  final String? category; // Kategori
  final String? tags; // Etiketler
  final String? notes; // Notlar
  final List<ApprovalStep> steps; // Onay adımları
  final String? currentStepId; // Mevcut adım ID'si
  final String? assignedTo; // Atanan kullanıcı ID'si
  final String? assignedToName; // Atanan kullanıcı adı
  final String? createdBy; // Oluşturan kullanıcı ID'si
  final String? createdByName; // Oluşturan kullanıcı adı
  final DateTime? dueDate; // Son tarih
  final DateTime? completedDate; // Tamamlanma tarihi
  final Map<String, dynamic> metadata; // Ek veriler
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApprovalWorkflow({
    required this.id,
    required this.workflowNumber,
    required this.type,
    required this.status,
    required this.title,
    this.description,
    this.documentId,
    this.documentType,
    this.documentNumber,
    this.amount,
    this.currency,
    this.priority,
    this.category,
    this.tags,
    this.notes,
    this.steps = const [],
    this.currentStepId,
    this.assignedTo,
    this.assignedToName,
    this.createdBy,
    this.createdByName,
    this.dueDate,
    this.completedDate,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith metodu
  ApprovalWorkflow copyWith({
    String? id,
    String? workflowNumber,
    ApprovalWorkflowType? type,
    ApprovalWorkflowStatus? status,
    String? title,
    String? description,
    String? documentId,
    String? documentType,
    String? documentNumber,
    double? amount,
    String? currency,
    String? priority,
    String? category,
    String? tags,
    String? notes,
    List<ApprovalStep>? steps,
    String? currentStepId,
    String? assignedTo,
    String? assignedToName,
    String? createdBy,
    String? createdByName,
    DateTime? dueDate,
    DateTime? completedDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApprovalWorkflow(
      id: id ?? this.id,
      workflowNumber: workflowNumber ?? this.workflowNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      steps: steps ?? this.steps,
      currentStepId: currentStepId ?? this.currentStepId,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON'dan ApprovalWorkflow oluştur
  factory ApprovalWorkflow.fromJson(Map<String, dynamic> json) {
    return ApprovalWorkflow(
      id: json['id'] as String,
      workflowNumber: json['workflowNumber'] as String,
      type: ApprovalWorkflowType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ApprovalWorkflowType.sales,
      ),
      status: ApprovalWorkflowStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApprovalWorkflowStatus.draft,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      documentId: json['documentId'] as String?,
      documentType: json['documentType'] as String?,
      documentNumber: json['documentNumber'] as String?,
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] as String?,
      priority: json['priority'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] as String?,
      notes: json['notes'] as String?,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => ApprovalStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentStepId: json['currentStepId'] as String?,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// ApprovalWorkflow'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workflowNumber': workflowNumber,
      'type': type.name,
      'status': status.name,
      'title': title,
      'description': description,
      'documentId': documentId,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'amount': amount,
      'currency': currency,
      'priority': priority,
      'category': category,
      'tags': tags,
      'notes': notes,
      'steps': steps.map((e) => e.toJson()).toList(),
      'currentStepId': currentStepId,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Taslak mı?
  bool get isDraft => status == ApprovalWorkflowStatus.draft;

  /// Beklemede mi?
  bool get isPending => status == ApprovalWorkflowStatus.pending;

  /// Devam ediyor mu?
  bool get isInProgress => status == ApprovalWorkflowStatus.inProgress;

  /// Onaylandı mı?
  bool get isApproved => status == ApprovalWorkflowStatus.approved;

  /// Reddedildi mi?
  bool get isRejected => status == ApprovalWorkflowStatus.rejected;

  /// İptal edildi mi?
  bool get isCancelled => status == ApprovalWorkflowStatus.cancelled;

  /// Süresi doldu mu?
  bool get isExpired => status == ApprovalWorkflowStatus.expired;

  /// Satış onayı mı?
  bool get isSalesApproval => type == ApprovalWorkflowType.sales;

  /// Satınalma onayı mı?
  bool get isPurchaseApproval => type == ApprovalWorkflowType.purchase;

  /// Ödeme onayı mı?
  bool get isPaymentApproval => type == ApprovalWorkflowType.payment;

  /// Gider onayı mı?
  bool get isExpenseApproval => type == ApprovalWorkflowType.expense;

  /// Stok onayı mı?
  bool get isInventoryApproval => type == ApprovalWorkflowType.inventory;

  /// Belge onayı mı?
  bool get isDocumentApproval => type == ApprovalWorkflowType.document;

  /// Özel onay mı?
  bool get isCustomApproval => type == ApprovalWorkflowType.custom;

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Belge ID'si var mı?
  bool get hasDocumentId => documentId != null && documentId!.isNotEmpty;

  /// Belge türü var mı?
  bool get hasDocumentType => documentType != null && documentType!.isNotEmpty;

  /// Belge numarası var mı?
  bool get hasDocumentNumber =>
      documentNumber != null && documentNumber!.isNotEmpty;

  /// Tutar var mı?
  bool get hasAmount => amount != null && amount! > 0;

  /// Para birimi var mı?
  bool get hasCurrency => currency != null && currency!.isNotEmpty;

  /// Öncelik var mı?
  bool get hasPriority => priority != null && priority!.isNotEmpty;

  /// Kategori var mı?
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Etiket var mı?
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Adım var mı?
  bool get hasSteps => steps.isNotEmpty;

  /// Mevcut adım var mı?
  bool get hasCurrentStep => currentStepId != null && currentStepId!.isNotEmpty;

  /// Atanan kullanıcı var mı?
  bool get hasAssignedTo => assignedTo != null && assignedTo!.isNotEmpty;

  /// Oluşturan kullanıcı var mı?
  bool get hasCreatedBy => createdBy != null && createdBy!.isNotEmpty;

  /// Son tarih var mı?
  bool get hasDueDate => dueDate != null;

  /// Tamamlanma tarihi var mı?
  bool get hasCompletedDate => completedDate != null;

  /// Yüksek öncelik mi?
  bool get isHighPriority => priority == 'High' || priority == 'Critical';

  /// Düşük öncelik mi?
  bool get isLowPriority => priority == 'Low';

  /// Orta öncelik mi?
  bool get isMediumPriority => priority == 'Medium';

  /// Kritik öncelik mi?
  bool get isCriticalPriority => priority == 'Critical';

  /// Süresi doldu mu?
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && !isCompleted;
  }

  /// Tamamlandı mı?
  bool get isCompleted => isApproved || isRejected || isCancelled;

  /// Aktif mi?
  bool get isActive => isPending || isInProgress;

  /// Başlatılabilir mi?
  bool get canBeStarted {
    return status == ApprovalWorkflowStatus.draft && hasSteps && hasAssignedTo;
  }

  /// Onaylanabilir mi?
  bool get canBeApproved {
    return isActive && hasCurrentStep;
  }

  /// Reddedilebilir mi?
  bool get canBeRejected {
    return isActive && hasCurrentStep;
  }

  /// İptal edilebilir mi?
  bool get canBeCancelled {
    return isActive;
  }

  /// Toplam adım sayısı
  int get totalStepsCount => steps.length;

  /// Tamamlanan adım sayısı
  int get completedStepsCount => steps.where((step) => step.isCompleted).length;

  /// Kalan adım sayısı
  int get remainingStepsCount => totalStepsCount - completedStepsCount;

  /// İlerleme yüzdesi
  double get progressPercentage {
    if (totalStepsCount == 0) return 0;
    return (completedStepsCount / totalStepsCount) * 100;
  }

  /// Mevcut adım
  ApprovalStep? get currentStep {
    if (currentStepId == null) return null;
    try {
      return steps.firstWhere((step) => step.id == currentStepId);
    } catch (e) {
      return null;
    }
  }

  /// Son adım
  ApprovalStep? get lastStep {
    if (steps.isEmpty) return null;
    return steps.last;
  }

  /// İlk adım
  ApprovalStep? get firstStep {
    if (steps.isEmpty) return null;
    return steps.first;
  }

  /// Süre (gün)
  int? get durationInDays {
    if (completedDate == null) return null;
    return completedDate!.difference(createdAt).inDays;
  }

  /// Kalan süre (gün)
  int? get remainingDays {
    if (dueDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(dueDate!)) return 0;
    return dueDate!.difference(now).inDays;
  }

  @override
  String toString() {
    return 'ApprovalWorkflow(id: $id, workflowNumber: $workflowNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApprovalWorkflow && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Onay adımı
class ApprovalStep {
  final String id;
  final String stepName;
  final String? description;
  final int stepOrder; // Adım sırası
  final String? assignedTo; // Atanan kullanıcı ID'si
  final String? assignedToName; // Atanan kullanıcı adı
  final String? assignedToRole; // Atanan rol
  final String? assignedToDepartment; // Atanan departman
  final bool isRequired; // Zorunlu mu?
  final bool isParallel; // Paralel mi?
  final bool isConditional; // Koşullu mu?
  final String? condition; // Koşul
  final String? action; // Aksiyon (approve, reject, review, etc.)
  final String? notes; // Notlar
  final DateTime? assignedDate; // Atanma tarihi
  final DateTime? completedDate; // Tamamlanma tarihi
  final String? completedBy; // Tamamlayan kullanıcı ID'si
  final String? completedByName; // Tamamlayan kullanıcı adı
  final String? result; // Sonuç (approved, rejected, etc.)
  final String? comments; // Yorumlar
  final Map<String, dynamic> metadata; // Ek veriler

  const ApprovalStep({
    required this.id,
    required this.stepName,
    this.description,
    required this.stepOrder,
    this.assignedTo,
    this.assignedToName,
    this.assignedToRole,
    this.assignedToDepartment,
    this.isRequired = true,
    this.isParallel = false,
    this.isConditional = false,
    this.condition,
    this.action,
    this.notes,
    this.assignedDate,
    this.completedDate,
    this.completedBy,
    this.completedByName,
    this.result,
    this.comments,
    this.metadata = const {},
  });

  /// CopyWith metodu
  ApprovalStep copyWith({
    String? id,
    String? stepName,
    String? description,
    int? stepOrder,
    String? assignedTo,
    String? assignedToName,
    String? assignedToRole,
    String? assignedToDepartment,
    bool? isRequired,
    bool? isParallel,
    bool? isConditional,
    String? condition,
    String? action,
    String? notes,
    DateTime? assignedDate,
    DateTime? completedDate,
    String? completedBy,
    String? completedByName,
    String? result,
    String? comments,
    Map<String, dynamic>? metadata,
  }) {
    return ApprovalStep(
      id: id ?? this.id,
      stepName: stepName ?? this.stepName,
      description: description ?? this.description,
      stepOrder: stepOrder ?? this.stepOrder,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedToRole: assignedToRole ?? this.assignedToRole,
      assignedToDepartment: assignedToDepartment ?? this.assignedToDepartment,
      isRequired: isRequired ?? this.isRequired,
      isParallel: isParallel ?? this.isParallel,
      isConditional: isConditional ?? this.isConditional,
      condition: condition ?? this.condition,
      action: action ?? this.action,
      notes: notes ?? this.notes,
      assignedDate: assignedDate ?? this.assignedDate,
      completedDate: completedDate ?? this.completedDate,
      completedBy: completedBy ?? this.completedBy,
      completedByName: completedByName ?? this.completedByName,
      result: result ?? this.result,
      comments: comments ?? this.comments,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON'dan ApprovalStep oluştur
  factory ApprovalStep.fromJson(Map<String, dynamic> json) {
    return ApprovalStep(
      id: json['id'] as String,
      stepName: json['stepName'] as String,
      description: json['description'] as String?,
      stepOrder: json['stepOrder'] as int,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      assignedToRole: json['assignedToRole'] as String?,
      assignedToDepartment: json['assignedToDepartment'] as String?,
      isRequired: json['isRequired'] as bool? ?? true,
      isParallel: json['isParallel'] as bool? ?? false,
      isConditional: json['isConditional'] as bool? ?? false,
      condition: json['condition'] as String?,
      action: json['action'] as String?,
      notes: json['notes'] as String?,
      assignedDate: json['assignedDate'] != null
          ? DateTime.parse(json['assignedDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      completedBy: json['completedBy'] as String?,
      completedByName: json['completedByName'] as String?,
      result: json['result'] as String?,
      comments: json['comments'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// ApprovalStep'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepName': stepName,
      'description': description,
      'stepOrder': stepOrder,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'assignedToRole': assignedToRole,
      'assignedToDepartment': assignedToDepartment,
      'isRequired': isRequired,
      'isParallel': isParallel,
      'isConditional': isConditional,
      'condition': condition,
      'action': action,
      'notes': notes,
      'assignedDate': assignedDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'completedBy': completedBy,
      'completedByName': completedByName,
      'result': result,
      'comments': comments,
      'metadata': metadata,
    };
  }

  /// Açıklama var mı?
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Atanan kullanıcı var mı?
  bool get hasAssignedTo => assignedTo != null && assignedTo!.isNotEmpty;

  /// Atanan kullanıcı adı var mı?
  bool get hasAssignedToName =>
      assignedToName != null && assignedToName!.isNotEmpty;

  /// Atanan rol var mı?
  bool get hasAssignedToRole =>
      assignedToRole != null && assignedToRole!.isNotEmpty;

  /// Atanan departman var mı?
  bool get hasAssignedToDepartment =>
      assignedToDepartment != null && assignedToDepartment!.isNotEmpty;

  /// Koşul var mı?
  bool get hasCondition => condition != null && condition!.isNotEmpty;

  /// Aksiyon var mı?
  bool get hasAction => action != null && action!.isNotEmpty;

  /// Not var mı?
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Atanma tarihi var mı?
  bool get hasAssignedDate => assignedDate != null;

  /// Tamamlanma tarihi var mı?
  bool get hasCompletedDate => completedDate != null;

  /// Tamamlayan kullanıcı var mı?
  bool get hasCompletedBy => completedBy != null && completedBy!.isNotEmpty;

  /// Tamamlayan kullanıcı adı var mı?
  bool get hasCompletedByName =>
      completedByName != null && completedByName!.isNotEmpty;

  /// Sonuç var mı?
  bool get hasResult => result != null && result!.isNotEmpty;

  /// Yorum var mı?
  bool get hasComments => comments != null && comments!.isNotEmpty;

  /// Tamamlandı mı?
  bool get isCompleted => hasCompletedDate && hasResult;

  /// Beklemede mi?
  bool get isPending => !isCompleted && hasAssignedTo;

  /// Atanmamış mı?
  bool get isUnassigned => !hasAssignedTo;

  /// Onaylandı mı?
  bool get isApproved => result == 'approved';

  /// Reddedildi mi?
  bool get isRejected => result == 'rejected';

  /// İncelendi mi?
  bool get isReviewed => result == 'reviewed';

  /// Süre (gün)
  int? get durationInDays {
    if (assignedDate == null || completedDate == null) return null;
    return completedDate!.difference(assignedDate!).inDays;
  }

  @override
  String toString() {
    return 'ApprovalStep(id: $id, stepName: $stepName, stepOrder: $stepOrder, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApprovalStep && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
