/// Plain Dart model matching the backend `stock_movements` table.
class StockMovement {
  final String id;
  final String productId;
  final String movementType; // RESTOCK | ADJUSTMENT | SALE
  final int quantity; // delta (positive or negative)
  final int previousQuantity;
  final int newQuantity;
  final String note;
  final String reference;
  final DateTime createdAt;
  final DateTime? expirationDate;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantity,
    required this.previousQuantity,
    required this.newQuantity,
    this.note = '',
    this.reference = '',
    required this.createdAt,
    this.expirationDate,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      productId: json['productId'] as String,
      movementType: json['movementType'] as String,
      quantity: (json['quantity'] as num).toInt(),
      previousQuantity: (json['previousQuantity'] as num).toInt(),
      newQuantity: (json['newQuantity'] as num).toInt(),
      note: (json['note'] as String?) ?? '',
      reference: (json['reference'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
    );
  }
}
