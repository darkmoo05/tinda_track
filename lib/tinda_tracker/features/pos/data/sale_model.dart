export 'models/cart_item.dart';

class TtSaleItem {
  final String productId;
  final String productName;
  final String selectedUnit;
  final double quantity;
  final double unitPrice;
  final double computedBaseQuantity;
  final double lineTotal;

  const TtSaleItem({
    required this.productId,
    required this.productName,
    required this.selectedUnit,
    required this.quantity,
    required this.unitPrice,
    required this.computedBaseQuantity,
    required this.lineTotal,
  });

  factory TtSaleItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return TtSaleItem(
      productId: json['productId'] as String,
      productName: product?['name'] as String? ?? '',
      selectedUnit:
          (json['selectedUnit'] as String?) ??
          (product?['baseUnit'] as String?) ??
          'pc',
      quantity: _toDouble(json['quantity']),
      unitPrice: _toDouble(json['unitPrice']),
      computedBaseQuantity: _toDouble(json['computedBaseQuantity']) != 0
          ? _toDouble(json['computedBaseQuantity'])
          : _toDouble(json['quantity']),
      lineTotal: _toDouble(json['lineTotal']),
    );
  }

  factory TtSaleItem.fromLocalDb(Map<String, dynamic> row) {
    return TtSaleItem(
      productId:
          (row['product_server_id'] as String?) ??
          row['product_sync_id'] as String,
      productName: row['product_name'] as String? ?? '',
      selectedUnit: (row['selected_unit'] as String?) ?? 'pc',
      quantity: (row['quantity'] as num).toDouble(),
      unitPrice: (row['unit_price'] as num).toDouble(),
      computedBaseQuantity:
          (row['computed_base_quantity'] as num?)?.toDouble() ??
          (row['quantity'] as num).toDouble(),
      lineTotal: (row['line_total'] as num).toDouble(),
    );
  }

  static double _toDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
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
