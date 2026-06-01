import '../../../../../core/database/app_database.dart';

class ProductUnitConversion {
  final String id;
  final String syncId;
  final String productId;
  final String unitName;
  final double conversionFactor;
  final double costPrice;
  final double sellingPrice;

  const ProductUnitConversion({
    required this.id,
    required this.syncId,
    required this.productId,
    required this.unitName,
    required this.conversionFactor,
    required this.costPrice,
    required this.sellingPrice,
  });

  factory ProductUnitConversion.fromJson(Map<String, dynamic> json) {
    return ProductUnitConversion(
      id: (json['id'] as String?) ?? '',
      syncId: (json['syncId'] as String?) ?? '',
      productId: (json['productId'] as String?) ?? '',
      unitName: (json['unitName'] as String?) ?? '',
      conversionFactor: (json['conversionFactor'] as num?)?.toDouble() ?? 1,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  factory ProductUnitConversion.fromLocalDb(Map<String, dynamic> row) {
    return ProductUnitConversion(
      id: '${row['id']}',
      syncId: (row['sync_id'] as String?) ?? '',
      productId: (row['product_id'] as String?) ?? '',
      unitName: (row['unit_name'] as String?) ?? '',
      conversionFactor: (row['conversion_factor'] as num?)?.toDouble() ?? 1,
      costPrice: (row['cost_price'] as num?)?.toDouble() ?? 0,
      sellingPrice: (row['selling_price'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Typed Drift constructor — preferred over [fromLocalDb] for new code.
  factory ProductUnitConversion.fromRow(ProductUnitConversionRow row) {
    return ProductUnitConversion(
      id: row.id,
      syncId: row.syncId,
      productId: row.productId,
      unitName: row.unitName,
      conversionFactor: row.conversionFactor,
      costPrice: row.costPrice,
      sellingPrice: row.sellingPrice,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'syncId': syncId,
    'productId': productId,
    'unitName': unitName,
    'conversionFactor': conversionFactor,
    'costPrice': costPrice,
    'sellingPrice': sellingPrice,
  };
}
