class CheckoutEmptyCartException implements Exception {
  @override
  String toString() => 'CheckoutEmptyCartException';
}

class NegativePaidAmountException implements Exception {
  @override
  String toString() => 'NegativePaidAmountException';
}

class UnitConversionNotSetException implements Exception {
  final String unitName;
  final String productName;

  UnitConversionNotSetException(this.unitName, this.productName);

  @override
  String toString() => 'UnitConversionNotSetException: $unitName para sa $productName';
}

class EmptyRecipeIngredientsException implements Exception {
  final String productName;

  EmptyRecipeIngredientsException(this.productName);

  @override
  String toString() => 'EmptyRecipeIngredientsException: $productName';
}

class InsufficientIngredientStockException implements Exception {
  final String ingredientName;
  final String productName;
  final double needed;
  final double available;

  InsufficientIngredientStockException({
    required this.ingredientName,
    required this.productName,
    required this.needed,
    required this.available,
  });

  @override
  String toString() => 'InsufficientIngredientStockException: $ingredientName para sa $productName';
}

class InsufficientProductStockException implements Exception {
  final String productName;
  final double needed;
  final double available;

  InsufficientProductStockException({
    required this.productName,
    required this.needed,
    required this.available,
  });

  @override
  String toString() => 'InsufficientProductStockException: $productName';
}

class SerialSelectionException implements Exception {
  final String productName;
  final int requiredCount;
  final int selectedCount;

  SerialSelectionException({
    required this.productName,
    required this.requiredCount,
    required this.selectedCount,
  });

  @override
  String toString() => 'SerialSelectionException: $productName';
}

class SerialNotAvailableException implements Exception {
  final String serialNumber;

  SerialNotAvailableException(this.serialNumber);

  @override
  String toString() => 'SerialNotAvailableException: $serialNumber';
}

class PaidAmountInsufficientException implements Exception {
  final double paidAmount;
  final double totalAmount;

  PaidAmountInsufficientException(this.paidAmount, this.totalAmount);

  @override
  String toString() => 'PaidAmountInsufficientException: paid $paidAmount, needed $totalAmount';
}
