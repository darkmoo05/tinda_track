// Backend-aligned enums. Stored as TEXT in Drift and serialized as the
// exact uppercase strings the NestJS API returns (`GCASH`, `CASH_IN`, …).

enum WalletProvider {
  gcash('GCASH'),
  maya('MAYA');

  const WalletProvider(this.wire);
  final String wire;

  static WalletProvider fromWire(String value) =>
      WalletProvider.values.firstWhere((e) => e.wire == value);
}

enum TransactionDirection {
  cashIn('CASH_IN'),
  cashOut('CASH_OUT');

  const TransactionDirection(this.wire);
  final String wire;

  static TransactionDirection fromWire(String value) =>
      TransactionDirection.values.firstWhere((e) => e.wire == value);
}

enum OcrStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  failed('FAILED');

  const OcrStatus(this.wire);
  final String wire;

  static OcrStatus fromWire(String value) => OcrStatus.values.firstWhere(
    (e) => e.wire == value,
    orElse: () => OcrStatus.pending,
  );
}

enum TransactionStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const TransactionStatus(this.wire);
  final String wire;

  static TransactionStatus fromWire(String value) =>
      TransactionStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => TransactionStatus.completed,
      );
}

enum StockMovementType {
  restock('RESTOCK'),
  adjustment('ADJUSTMENT'),
  sale('SALE');

  const StockMovementType(this.wire);
  final String wire;

  static StockMovementType fromWire(String value) =>
      StockMovementType.values.firstWhere((e) => e.wire == value);
}
