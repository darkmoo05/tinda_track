import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/data/local_inventory_repository.dart';
import '../../inventory/data/models/inventory_product.dart';
import '../data/models/cart_item.dart';

final posProductsProvider = FutureProvider.autoDispose<List<InventoryProduct>>((
  ref,
) {
  return ref.read(localInventoryRepositoryProvider).listProducts();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  void addProduct(InventoryProduct product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index < 0) {
      state = [...state, CartItem.fromProduct(product)];
      return;
    }

    final existing = state[index];
    final next = existing.copyWith(quantity: existing.quantity + 1);
    if (next.computedBaseQuantity > next.product.stockInBaseUnit) return;

    final updated = [...state];
    updated[index] = next;
    state = updated;
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void increment(String productId) {
    _mutateItem(productId, (item) {
      final next = item.copyWith(quantity: item.quantity + 1);
      if (next.computedBaseQuantity > next.product.stockInBaseUnit) {
        return item;
      }
      return next;
    });
  }

  void decrement(String productId) {
    final current = state.firstWhere((item) => item.product.id == productId);
    if (current.quantity <= 1) {
      removeItem(productId);
      return;
    }
    _mutateItem(
      productId,
      (item) => item.copyWith(quantity: item.quantity - 1),
    );
  }

  void updateQuantity(String productId, double quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    _mutateItem(productId, (item) {
      final next = item.copyWith(quantity: quantity);
      if (next.computedBaseQuantity > next.product.stockInBaseUnit) {
        // Keep the new quantity so users can clearly see/edit what exceeded stock.
        return next;
      }
      return next;
    });
  }

  void updateItemUnit(String productId, String unitName) {
    _mutateItem(productId, (item) {
      final normalized = unitName.trim();
      final nextPrice = _priceForUnit(item.product, normalized);
      return item.copyWith(
        selectedUnitName: normalized,
        appliedPrice: nextPrice,
      );
    });
  }

  void clear() => state = const [];

  List<String> unitOptionsFor(CartItem item) {
    final options = <String>[item.product.baseUnit];
    for (final conversion in item.product.unitConversions) {
      if (!options.any(
        (u) => u.toLowerCase() == conversion.unitName.toLowerCase(),
      )) {
        options.add(conversion.unitName);
      }
    }
    return options;
  }

  String? validationMessage(CartItem item) {
    if (item.computedBaseQuantity <= item.product.stockInBaseUnit) {
      return null;
    }
    return 'Kulang ang stocks para sa ${item.product.name}.';
  }

  bool hasStockIssue() {
    return state.any(
      (item) => item.computedBaseQuantity > item.product.stockInBaseUnit,
    );
  }

  double _priceForUnit(InventoryProduct product, String unitName) {
    if (unitName.toLowerCase() == product.baseUnit.toLowerCase()) {
      return product.sellingPrice;
    }

    for (final conversion in product.unitConversions) {
      if (conversion.unitName.toLowerCase() == unitName.toLowerCase()) {
        if (conversion.sellingPrice > 0) return conversion.sellingPrice;
        return product.sellingPrice * conversion.conversionFactor;
      }
    }
    return product.sellingPrice;
  }

  void _mutateItem(String productId, CartItem Function(CartItem item) mutate) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    final updated = [...state];
    updated[index] = mutate(updated[index]);
    state = updated;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider.autoDispose<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.lineTotal);
});

final cartItemCountProvider = Provider.autoDispose<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final hasStockIssueProvider = Provider.autoDispose<bool>((ref) {
  final notifier = ref.read(cartProvider.notifier);
  ref.watch(cartProvider);
  return notifier.hasStockIssue();
});

final isCartEmptyProvider = Provider.autoDispose<bool>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.isEmpty;
});

final canCheckoutProvider = Provider.autoDispose<bool>((ref) {
  final isEmpty = ref.watch(isCartEmptyProvider);
  final hasStockIssue = ref.watch(hasStockIssueProvider);
  return !isEmpty && !hasStockIssue;
});

final checkoutDisabledReasonProvider = Provider.autoDispose<String?>((ref) {
  final isEmpty = ref.watch(isCartEmptyProvider);
  if (isEmpty) return 'Mag-add muna ng item bago mag-checkout.';

  final hasStockIssue = ref.watch(hasStockIssueProvider);
  if (hasStockIssue) {
    return 'Kulang ang stocks sa ilang item. Paki-adjust muna.';
  }

  return null;
});
