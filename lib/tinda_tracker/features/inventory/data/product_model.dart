class TtProduct {
  final String id;
  final String name;
  final String sku;
  final String description;
  final String category;
  final String unit;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int reorderPoint;
  final bool isActive;

  const TtProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.category,
    required this.unit,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.reorderPoint,
    required this.isActive,
  });

  bool get isLowStock => stockQuantity <= reorderPoint;

  factory TtProduct.fromJson(Map<String, dynamic> json) {
    return TtProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      unit: json['unit'] as String? ?? 'pcs',
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      reorderPoint: json['reorderPoint'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'sku': sku,
      'description': description,
      'category': category,
      'unit': unit,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stockQuantity': stockQuantity,
      'reorderPoint': reorderPoint,
      'isActive': isActive,
    };
  }
}
