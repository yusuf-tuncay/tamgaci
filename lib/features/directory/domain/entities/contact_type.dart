// ========== CONTACT TYPE ENUM ==========
// lib/features/directory/domain/entities/contact_type.dart

/// Contact type enum for categorizing contacts
enum ContactType {
  /// Customer contact
  customer(0, 'Müşteri'),

  /// Supplier contact
  supplier(1, 'Tedarikçi'),

  /// Both customer and supplier
  both(2, 'Her İkisi');

  const ContactType(this.value, this.displayName);

  /// Integer value for database storage
  final int value;

  /// Display name for UI
  final String displayName;

  /// Get ContactType from integer value
  static ContactType fromValue(int value) {
    return ContactType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ContactType.customer,
    );
  }

  /// Get ContactType from string name
  static ContactType fromString(String name) {
    return ContactType.values.firstWhere(
      (type) => type.name == name.toLowerCase(),
      orElse: () => ContactType.customer,
    );
  }

  @override
  String toString() => displayName;
}
