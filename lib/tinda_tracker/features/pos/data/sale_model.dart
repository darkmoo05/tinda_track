class TtSaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const TtSaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory TtSaleItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return TtSaleItem(
      productId: json['productId'] as String,
      productName: product?['name'] as String? ?? '',
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }

  factory TtSaleItem.fromLocalDb(Map<String, dynamic> row) {
    return TtSaleItem(
      productId:
          (row['product_server_id'] as String?) ??
          row['product_sync_id'] as String,
      productName: row['product_name'] as String? ?? '',
      quantity: row['quantity'] as int,
      unitPrice: (row['unit_price'] as num).toDouble(),
      lineTotal: (row['line_total'] as num).toDouble(),
    );
  }
}

class TtSale {
  final String id;
  final String reference;
  final double subtotal;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final int totalItems;
  final String note;
  final DateTime createdAt;
  final List<TtSaleItem> saleItems;

  const TtSale({
    required this.id,
    required this.reference,
    required this.subtotal,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.totalItems,
    required this.note,
    required this.createdAt,
    required this.saleItems,
  });

  factory TtSale.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['saleItems'] as List? ?? [];
    return TtSale(
      id: json['id'] as String,
      reference: json['reference'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0,
      totalItems: json['totalItems'] as int,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      saleItems: itemsJson
          .map((e) => TtSaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory TtSale.fromLocalDb(Map<String, dynamic> row, List<TtSaleItem> items) {
    return TtSale(
      id: (row['server_id'] as String?) ?? row['sync_id'] as String,
      reference: row['reference'] as String,
      subtotal: (row['subtotal'] as num).toDouble(),
      totalAmount: (row['total_amount'] as num).toDouble(),
      paidAmount: (row['paid_amount'] as num).toDouble(),
      changeAmount: (row['change_amount'] as num?)?.toDouble() ?? 0,
      totalItems: row['total_items'] as int,
      note: row['note'] as String? ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
      saleItems: items,
    );
  }
}

class TtCartItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final double costPrice;
  int quantity;

  TtCartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.costPrice,
    this.quantity = 1,
  });

  double get lineTotal => unitPrice * quantity;
}
