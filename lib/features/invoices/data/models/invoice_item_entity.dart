// ========== lib/features/invoices/data/models/invoice_item_entity.dart ==========
import 'package:tamgaci/features/invoices/data/models/invoice_entity.dart';
import 'package:floor/floor.dart';

/// Fatura kalemi varlığı - Database entity sınıfı
@Entity(
  tableName: 'invoice_items',
  foreignKeys: [
    ForeignKey(
      childColumns: ['invoice_id'],
      parentColumns: ['id'],
      entity: InvoiceEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
  indices: [
    Index(value: ['invoice_id']),
    Index(value: ['item_order']),
  ],
)
class InvoiceItemEntity {
  /// Fatura kalemi benzersiz ID'si (Primary Key)
  @PrimaryKey()
  final String id;

  /// Fatura ID'si (Foreign Key)
  @ColumnInfo(name: 'invoice_id')
  final String invoiceId;

  /// Kalem sıra numarası
  @ColumnInfo(name: 'item_order')
  final int itemOrder;

  /// Ürün/Hizmet adı
  @ColumnInfo(name: 'product_name')
  final String productName;

  /// Açıklama
  @ColumnInfo(name: 'description')
  final String? description;

  /// Miktar
  @ColumnInfo(name: 'quantity')
  final double quantity;

  /// Birim
  @ColumnInfo(name: 'unit')
  final String? unit;

  /// Birim fiyat - kuruş cinsinden
  @ColumnInfo(name: 'unit_price')
  final int unitPrice;

  /// KDV oranı (örn: 18.0 = %18)
  @ColumnInfo(name: 'tax_rate')
  final double taxRate;

  /// KDV tutarı - kuruş cinsinden
  @ColumnInfo(name: 'tax_amount')
  final int taxAmount;

  /// Toplam tutar (KDV hariç) - kuruş cinsinden
  @ColumnInfo(name: 'line_total')
  final int lineTotal;

  /// Oluşturulma tarihi (milisaniye cinsinden)
  @ColumnInfo(name: 'created_at')
  final int createdAt;

  /// InvoiceItemEntity constructor
  const InvoiceItemEntity({
    required this.id,
    required this.invoiceId,
    required this.itemOrder,
    required this.productName,
    this.description,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    required this.taxRate,
    required this.taxAmount,
    required this.lineTotal,
    required this.createdAt,
  });

  /// CopyWith metodu
  InvoiceItemEntity copyWith({
    String? id,
    String? invoiceId,
    int? itemOrder,
    String? productName,
    String? description,
    double? quantity,
    String? unit,
    int? unitPrice,
    double? taxRate,
    int? taxAmount,
    int? lineTotal,
    int? createdAt,
  }) {
    return InvoiceItemEntity(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      itemOrder: itemOrder ?? this.itemOrder,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      lineTotal: lineTotal ?? this.lineTotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'InvoiceItemEntity(id: $id, invoiceId: $invoiceId, productName: $productName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceItemEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}