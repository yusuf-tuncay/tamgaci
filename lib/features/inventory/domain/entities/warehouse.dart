/// Depo domain entity'si
class Warehouse {
  final int? id;
  final String name;
  final String? code;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? manager;
  final double? capacity;
  final String? capacityUnit;
  final String currency; // Para birimi desteği
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Warehouse({
    this.id,
    required this.name,
    this.code,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.manager,
    this.capacity,
    this.capacityUnit,
    this.currency = 'TRY', // Varsayılan para birimi
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Kopyalama metodu
  Warehouse copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? manager,
    double? capacity,
    String? capacityUnit,
    String? currency,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      manager: manager ?? this.manager,
      capacity: capacity ?? this.capacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
