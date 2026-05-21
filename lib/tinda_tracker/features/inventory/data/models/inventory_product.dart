/// Plain Dart model matching the backend `products` table.
class InventoryProduct {
  final String id;
  final String name;
  final String sku; // barcode / SKU
  final String description;
  final String category;
  final String unit;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int reorderPoint; // min stock level
  final bool isActive;
  final bool isDeleted;

  /// Local file path of the compressed image (written by [ProductImageService]).
  /// Null until the user picks an image.
  final String? imagePath;

  /// Remote CDN / static-server URL returned after a successful image upload.
  /// Null until the background sync pushes the file.
  final String? imageUrl;

  /// Physical shelf / storage location inside the store.
  final String shelfLocation;

  /// Product-level expiration date. Set by the owner during product creation
  /// or editing to enable at-a-glance expiry alerts.
  final DateTime? expirationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryProduct({
    required this.id,
    required this.name,
    required this.sku,
    this.description = '',
    this.category = 'General',
    this.unit = 'pcs',
    this.costPrice = 0,
    required this.sellingPrice,
    this.stockQuantity = 0,
    this.reorderPoint = 0,
    this.isActive = true,
    this.isDeleted = false,
    this.imagePath,
    this.imageUrl,
    this.shelfLocation = 'Counter',
    this.expirationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => stockQuantity > 0 && stockQuantity <= reorderPoint;
  bool get isOutOfStock => stockQuantity == 0;
  double get profit => sellingPrice - costPrice;

  /// True when [expirationDate] is set and within the next 30 days.
  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    return !expirationDate!.isBefore(now) &&
        expirationDate!.isBefore(now.add(const Duration(days: 30)));
  }

  /// True when [expirationDate] is set and already in the past.
  bool get isExpired {
    if (expirationDate == null) return false;
    return expirationDate!.isBefore(DateTime.now());
  }

  factory InventoryProduct.fromJson(Map<String, dynamic> json) {
    return InventoryProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'General',
      unit: (json['unit'] as String?) ?? 'pcs',
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      reorderPoint: (json['reorderPoint'] as num?)?.toInt() ?? 0,
      isActive: (json['isActive'] as bool?) ?? true,
      isDeleted: (json['isDeleted'] as bool?) ?? false,
      imagePath: null, // server responses never carry the local file path
      imageUrl: json['imageUrl'] as String?,
      shelfLocation: (json['shelfLocation'] as String?) ?? 'Counter',
      expirationDate: json['expirationDate'] != null
          ? DateTime.tryParse(json['expirationDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Constructs an [InventoryProduct] from a local SQLite row in `tt_products`.
  /// The exposed [id] is the server UUID when available, otherwise the local sync_id.
  factory InventoryProduct.fromLocalDb(Map<String, dynamic> row) {
    final serverId = row['server_id'] as String?;
    final syncId = row['sync_id'] as String;
    return InventoryProduct(
      id: serverId ?? syncId,
      name: row['name'] as String,
      sku: row['sku'] as String,
      description: (row['description'] as String?) ?? '',
      category: (row['category'] as String?) ?? 'General',
      unit: (row['unit'] as String?) ?? 'pcs',
      costPrice: (row['cost_price'] as num?)?.toDouble() ?? 0,
      sellingPrice: (row['selling_price'] as num).toDouble(),
      stockQuantity: (row['stock_quantity'] as num?)?.toInt() ?? 0,
      reorderPoint: (row['reorder_point'] as num?)?.toInt() ?? 0,
      isActive: (row['is_active'] as int? ?? 1) == 1,
      isDeleted: (row['is_deleted'] as int? ?? 0) == 1,
      imagePath: row['image_path'] as String?,
      imageUrl: row['image_url'] as String?,
      shelfLocation: (row['shelf_location'] as String?) ?? 'Counter',
      expirationDate: row['expiration_date'] != null
          ? DateTime.tryParse(row['expiration_date'] as String)
          : null,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
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
    'isDeleted': isDeleted,
    'imageUrl': imageUrl,
    'shelfLocation': shelfLocation,
    'expirationDate': expirationDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  InventoryProduct copyWith({
    String? id,
    String? name,
    String? sku,
    String? description,
    String? category,
    String? unit,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    int? reorderPoint,
    bool? isActive,
    bool? isDeleted,
    Object? imagePath = _sentinel,
    Object? imageUrl = _sentinel,
    String? shelfLocation,
    Object? expirationDate = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
      imageUrl: imageUrl == _sentinel ? this.imageUrl : imageUrl as String?,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      expirationDate: expirationDate == _sentinel
          ? this.expirationDate
          : expirationDate as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const Object _sentinel = Object();
}
