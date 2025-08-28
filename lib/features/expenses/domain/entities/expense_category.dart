// ========== EXPENSE CATEGORY ENTITY ==========
// lib/features/expenses/domain/entities/expense_category.dart

/// Gider kategorisi entity'si
class ExpenseCategory {
  /// Kategori ID'si
  final String id;

  /// Kategori adı
  final String name;

  /// Kategori açıklaması
  final String? description;

  /// Kategori ikonu
  final String icon;

  /// Kategori rengi
  final String color;

  /// Kategori aktif mi?
  final bool isActive;

  /// Oluşturulma tarihi
  final DateTime createdAt;

  /// Güncellenme tarihi
  final DateTime updatedAt;

  const ExpenseCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ExpenseCategory kopyalama metodu
  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ExpenseCategory(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Varsayılan gider kategorileri
class DefaultExpenseCategories {
  static final List<ExpenseCategory> categories = [
    ExpenseCategory(
      id: 'office',
      name: 'Ofis Giderleri',
      description: 'Ofis malzemeleri, kırtasiye, temizlik vb.',
      icon: 'business',
      color: '#2196F3',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    ExpenseCategory(
      id: 'rent',
      name: 'Kira',
      description: 'Ofis, depo, mağaza kiraları',
      icon: 'home',
      color: '#4CAF50',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    ExpenseCategory(
      id: 'utilities',
      name: 'Faturalar',
      description: 'Elektrik, su, doğalgaz, internet vb.',
      icon: 'receipt',
      color: '#FF9800',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    ExpenseCategory(
      id: 'salary',
      name: 'Maaş ve Ücretler',
      description: 'Personel maaşları, komisyonlar, primler',
      icon: 'people',
      color: '#9C27B0',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    ExpenseCategory(
      id: 'marketing',
      name: 'Pazarlama',
      description: 'Reklam, promosyon, sosyal medya vb.',
      icon: 'campaign',
      color: '#E91E63',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    ExpenseCategory(
      id: 'travel',
      name: 'Seyahat',
      description: 'Ulaşım, konaklama, yemek vb.',
      icon: 'flight',
      color: '#607D8B',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    ExpenseCategory(
      id: 'equipment',
      name: 'Ekipman',
      description: 'Bilgisayar, yazıcı, mobilya vb.',
      icon: 'computer',
      color: '#795548',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    ExpenseCategory(
      id: 'insurance',
      name: 'Sigorta',
      description: 'Sağlık, işyeri, araç sigortası vb.',
      icon: 'security',
      color: '#3F51B5',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    ExpenseCategory(
      id: 'tax',
      name: 'Vergi ve Harçlar',
      description: 'KDV, gelir vergisi, harçlar vb.',
      icon: 'account_balance',
      color: '#F44336',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Diğer',
      description: 'Diğer giderler',
      icon: 'more_horiz',
      color: '#9E9E9E',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
  ];

  static final DateTime _defaultDate = DateTime(2024, 1, 1);
}
