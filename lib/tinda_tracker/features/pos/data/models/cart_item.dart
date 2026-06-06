import '../../../inventory/data/models/inventory_product.dart';
import '../../../inventory/data/models/product_unit_conversion.dart';

class CartItem {
  final InventoryProduct product;
  final String selectedUnitName;
  final double quantity;
  final double appliedPrice;
  final List<String> selectedSerials;

  const CartItem({
    required this.product,
    required this.selectedUnitName,
    required this.quantity,
    required this.appliedPrice,
    this.selectedSerials = const [],
  });

  factory CartItem.fromProduct(InventoryProduct product) {
    return CartItem(
      product: product,
      selectedUnitName: product.baseUnit,
      quantity: 1,
      appliedPrice: product.sellingPrice,
      selectedSerials: const [],
    );
  }

  ProductUnitConversion? get selectedConversion {
    final selected = selectedUnitName.toLowerCase();
    for (final conversion in product.unitConversions) {
      if (conversion.unitName.toLowerCase() == selected) {
        return conversion;
      }
    }
    return null;
  }

  double get conversionFactor {
    if (selectedUnitName.toLowerCase() == product.baseUnit.toLowerCase()) {
      return 1;
    }
    return selectedConversion?.conversionFactor ?? 1;
  }

  double get computedBaseQuantity => quantity * conversionFactor;

  double get lineTotal => appliedPrice * quantity;

  CartItem copyWith({
    InventoryProduct? product,
    String? selectedUnitName,
    double? quantity,
    double? appliedPrice,
    List<String>? selectedSerials,
  }) {
    return CartItem(
      product: product ?? this.product,
      selectedUnitName: selectedUnitName ?? this.selectedUnitName,
      quantity: quantity ?? this.quantity,
      appliedPrice: appliedPrice ?? this.appliedPrice,
      selectedSerials: selectedSerials ?? this.selectedSerials,
    );
  }
}
