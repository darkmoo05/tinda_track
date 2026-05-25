import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/app_theme.dart';
import '../../inventory/data/models/inventory_product.dart';
import '../data/models/cart_item.dart';
import '../data/pos_repository.dart';
import '../providers/pos_providers.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  DateTime? _lastScanAt;
  String? _lastScannedCode;
  bool _isLaunchingScanner = false;
  bool _isGridView = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCartSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CartSheet(
        currency: _currency,
        onCheckout: _showCheckoutDialog,
        onScanBarcode: _scanBarcodeAndAdd,
      ),
    );
  }

  Future<void> _scanBarcodeAndAdd() async {
    if (_isLaunchingScanner) return;
    _isLaunchingScanner = true;

    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              _PosBarcodeScannerScreen(onCodeDetected: _addItemFromScannedCode),
        ),
      );
    } finally {
      _isLaunchingScanner = false;
    }
  }

  Future<_ScanAddResult> _addItemFromScannedCode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) {
      return const _ScanAddResult(
        success: false,
        message: 'Walang nabasang barcode. Subukan ulit.',
        historyLabel: 'Invalid code',
      );
    }

    final now = DateTime.now();
    final isDuplicate =
        _lastScannedCode == code &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(milliseconds: 700);
    if (isDuplicate) {
      return _ScanAddResult(
        success: false,
        message:
            'Nabasa na ito kanina lang. I-scan ulit pagkatapos ng sandali.',
        historyLabel: code,
      );
    }

    _lastScannedCode = code;
    _lastScanAt = now;

    final product = await PosRepository.instance.findProductBySku(code);
    if (product == null) {
      return _ScanAddResult(
        success: false,
        message: 'Walang product na naka-link sa barcode na "$code".',
        historyLabel: code,
      );
    }

    final beforeQty = ref
        .read(cartProvider)
        .where((item) => item.product.id == product.id)
        .fold<double>(0, (sum, item) => sum + item.quantity);

    ref.read(cartProvider.notifier).addProduct(product);

    final afterQty = ref
        .read(cartProvider)
        .where((item) => item.product.id == product.id)
        .fold<double>(0, (sum, item) => sum + item.quantity);

    if (afterQty <= beforeQty) {
      return _ScanAddResult(
        success: false,
        message: 'Kulang ang stocks para sa ${product.name}.',
        historyLabel: code,
      );
    }

    return _ScanAddResult(
      success: true,
      message: 'Na-add sa queue: ${product.name}',
      historyLabel: product.name,
    );
  }

  void _showCheckoutDialog() {
    Navigator.pop(context);

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mag-add muna ng item bago mag-checkout.'),
        ),
      );
      return;
    }

    final total = ref.read(cartTotalProvider);
    final canCheckout = ref.read(canCheckoutProvider);
    final disabledReason = ref.read(checkoutDisabledReasonProvider);

    if (!canCheckout) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            disabledReason ??
                'Hindi puwedeng mag-checkout ngayon. Paki-check ulit.',
          ),
        ),
      );
      return;
    }

    final paidController = TextEditingController(
      text: total.toStringAsFixed(2),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Complete Sale',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 15)),
                Text(
                  _currency.format(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Amount Received',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: paidController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '₱ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isProcessing
                ? null
                : () async {
                    final paid = double.tryParse(paidController.text) ?? 0;
                    if (paid < total) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Kulangan ang binayad. Paki-check ulit.',
                          ),
                        ),
                      );
                      return;
                    }
                    await _processCheckout(paid);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
            child: const Text('Complete Sale'),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout(double paidAmount) async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    try {
      setState(() => _isProcessing = true);
      final sale = await PosRepository.instance.checkout(
        CheckoutRequest(
          items: List<CartItem>.from(cart),
          paidAmount: paidAmount,
        ),
      );

      if (!mounted) return;
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(posProductsProvider);
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text(
            'Sale complete! Sukli: ${_currency.format(sale.changeAmount)}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hindi natuloy ang checkout: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(posProductsProvider);
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: const Text(
          'Sell',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Scan barcode',
            onPressed: _scanBarcodeAndAdd,
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(
              _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.secondary,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Colors.white70,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Hindi ma-load ang products ngayon. Paki-try ulit.',
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (products) {
                final filtered = _filterProducts(products);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Walang nahanap na products',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  );
                }

                if (_isGridView) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const horizontalPadding = 24.0;
                      const crossAxisSpacing = 10.0;
                      const crossAxisCount = 2;
                      final cardWidth =
                          (constraints.maxWidth -
                              horizontalPadding -
                              crossAxisSpacing) /
                          crossAxisCount;
                      final adaptiveAspectRatio = (cardWidth / 250)
                          .clamp(0.62, 0.78)
                          .toDouble();

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: adaptiveAspectRatio,
                          crossAxisSpacing: crossAxisSpacing,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, index) {
                          final product = filtered[index];
                          final inCartQty = cart
                              .where((item) => item.product.id == product.id)
                              .fold<double>(
                                0,
                                (sum, item) => sum + item.quantity,
                              );
                          return _ProductCard(
                            product: product,
                            inCartQty: inCartQty,
                            currency: _currency,
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .addProduct(product),
                          );
                        },
                      );
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final product = filtered[index];
                    final inCartQty = cart
                        .where((item) => item.product.id == product.id)
                        .fold<double>(0, (sum, item) => sum + item.quantity);
                    return _ProductListTile(
                      product: product,
                      inCartQty: inCartQty,
                      currency: _currency,
                      onTap: () =>
                          ref.read(cartProvider.notifier).addProduct(product),
                    );
                  },
                );
              },
            ),
          ),
          if (cart.isNotEmpty)
            GestureDetector(
              onTap: _openCartSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                color: AppColors.secondary,
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${cartCount.toStringAsFixed(cartCount == cartCount.roundToDouble() ? 0 : 2)} items',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _currency.format(cartTotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<InventoryProduct> _filterProducts(List<InventoryProduct> products) {
    final query = _searchController.text.trim().toLowerCase();
    final active = products
        .where((p) => p.isActive && !p.isDeleted && p.stockInBaseUnit > 0)
        .toList();

    if (query.isEmpty) return active;
    return active
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.sku.toLowerCase().contains(query),
        )
        .toList();
  }
}

class _ProductCard extends StatelessWidget {
  final InventoryProduct product;
  final double inCartQty;
  final NumberFormat currency;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.inCartQty,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 360;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: inCartQty > 0
              ? Border.all(color: AppColors.secondary, width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 96,
              child: _ProductImage(
                imagePath: product.imagePath,
                imageUrl: product.imageUrl,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: isNarrowScreen ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              currency.format(product.sellingPrice),
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              '${product.stockInBaseUnit.floor()} ${product.baseUnit} available',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: product.isLowStock
                    ? AppColors.error
                    : AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final InventoryProduct product;
  final double inCartQty;
  final NumberFormat currency;
  final VoidCallback onTap;

  const _ProductListTile({
    required this.product,
    required this.inCartQty,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: inCartQty > 0
              ? Border.all(color: AppColors.secondary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: _ProductImage(
                imagePath: product.imagePath,
                imageUrl: product.imageUrl,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${product.stockInBaseUnit.floor()} ${product.baseUnit} available',
                    style: TextStyle(
                      color: product.isLowStock
                          ? AppColors.error
                          : AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              currency.format(product.sellingPrice),
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSheet extends ConsumerWidget {
  final NumberFormat currency;
  final VoidCallback onCheckout;
  final VoidCallback onScanBarcode;

  const _CartSheet({
    required this.currency,
    required this.onCheckout,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final total = ref.watch(cartTotalProvider);
    final hasStockIssue = ref.watch(hasStockIssueProvider);
    final canCheckout = ref.watch(canCheckoutProvider);
    final checkoutDisabledReason = ref.watch(checkoutDisabledReasonProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Checkout Queue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onScanBarcode();
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: const Text('Scan item barcode'),
                ),
              ),
            ),
            if (hasStockIssue)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kulang ang stocks sa ilang item. Pwede ka pa ring mag-edit bago mag-checkout.',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                itemCount: cart.length,
                itemBuilder: (_, index) {
                  final item = cart[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 42,
                              height: 42,
                              child: _ProductImage(
                                imagePath: item.product.imagePath,
                                imageUrl: item.product.imageUrl,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  notifier.removeItem(item.product.id),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: notifier.unitOptionsFor(item).map((unit) {
                            final selected =
                                unit.toLowerCase() ==
                                item.selectedUnitName.toLowerCase();
                            final price = _priceForUnit(item, unit);
                            return ChoiceChip(
                              selected: selected,
                              onSelected: (_) => notifier.updateItemUnit(
                                item.product.id,
                                unit,
                              ),
                              selectedColor: AppColors.secondary.withValues(
                                alpha: 0.16,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? AppColors.secondary
                                    : AppColors.outlineVariant,
                              ),
                              label: Text('${currency.format(price)} / $unit'),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _QtyButton(
                              icon: Icons.remove_rounded,
                              onTap: () => notifier.decrement(item.product.id),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 72,
                              child: TextFormField(
                                key: ValueKey(
                                  '${item.product.id}-${item.quantity}-${item.selectedUnitName}',
                                ),
                                initialValue: item.quantity.toStringAsFixed(
                                  item.quantity == item.quantity.roundToDouble()
                                      ? 0
                                      : 2,
                                ),
                                textAlign: TextAlign.center,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onFieldSubmitted: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed == null || parsed <= 0) {
                                    notifier.removeItem(item.product.id);
                                    return;
                                  }
                                  notifier.updateQuantity(
                                    item.product.id,
                                    parsed,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            _QtyButton(
                              icon: Icons.add_rounded,
                              onTap: () => notifier.increment(item.product.id),
                            ),
                            const Spacer(),
                            Text(
                              currency.format(item.lineTotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Builder(
                          builder: (_) {
                            final message = notifier.validationMessage(item);
                            if (message == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      message,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Bill',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        currency.format(total),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canCheckout ? onCheckout : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  if (!canCheckout && checkoutDisabledReason != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      checkoutDisabledReason,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  double _priceForUnit(CartItem item, String unit) {
    if (unit.toLowerCase() == item.product.baseUnit.toLowerCase()) {
      return item.product.sellingPrice;
    }
    for (final conversion in item.product.unitConversions) {
      if (conversion.unitName.toLowerCase() == unit.toLowerCase()) {
        if (conversion.sellingPrice > 0) return conversion.sellingPrice;
        return item.product.sellingPrice * conversion.conversionFactor;
      }
    }
    return item.product.sellingPrice;
  }
}

class _ProductImage extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;

  const _ProductImage({required this.imagePath, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final provider = _resolveImageProvider();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: provider == null
          ? const Center(
              child: Icon(
                Icons.inventory_2_rounded,
                color: AppColors.secondary,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(image: provider, fit: BoxFit.cover),
            ),
    );
  }

  ImageProvider? _resolveImageProvider() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      if (file.existsSync()) return FileImage(file);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    return null;
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _PosBarcodeScannerScreen extends StatefulWidget {
  final Future<_ScanAddResult> Function(String code) onCodeDetected;

  const _PosBarcodeScannerScreen({required this.onCodeDetected});

  @override
  State<_PosBarcodeScannerScreen> createState() =>
      _PosBarcodeScannerScreenState();
}

class _PosBarcodeScannerScreenState extends State<_PosBarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  static const _beepAssetPath = 'sounds/barcode_scanner_beep.wav';
  static const _minBeepGate = Duration(milliseconds: 550);

  final _controller = MobileScannerController();
  final _manualCodeController = TextEditingController();
  final List<_ScanHistoryEntry> _recentScans = [];
  late final AudioPlayer _feedbackPlayer;
  late final AnimationController _pulseController;
  bool _continuousMode = true;
  bool _isHandlingCode = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _deviceCanVibrate = false;
  bool _deviceHasCustomVibration = false;
  bool _deviceHasAmplitudeControl = false;
  DateTime? _lastLocalScanAt;
  String? _lastLocalScanCode;
  String? _feedbackMessage;
  bool _feedbackIsSuccess = true;
  Color _pulseColor = Colors.greenAccent;

  @override
  void initState() {
    super.initState();
    _feedbackPlayer = AudioPlayer(playerId: 'pos-scan-feedback');
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    unawaited(_prepareFeedback());
  }

  @override
  void dispose() {
    unawaited(_feedbackPlayer.dispose());
    _pulseController.dispose();
    _manualCodeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _prepareFeedback() async {
    try {
      // Route through the media stream so the beep volume follows the phone's
      // media volume buttons. gainTransientMayDuck is correct for a short UI
      // beep — it briefly ducks other audio instead of claiming exclusive focus.
      await _feedbackPlayer.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      await _feedbackPlayer.setReleaseMode(ReleaseMode.stop);
      await _feedbackPlayer.setVolume(1);
      // Pre-cache the asset to a temp file so the first beep has no load delay.
      await _feedbackPlayer.setSourceAsset(_beepAssetPath);
    } catch (_) {
      // Pre-load failed; play() will cache on demand when first scan fires.
    }

    try {
      _deviceCanVibrate = await Vibration.hasVibrator();
      if (_deviceCanVibrate) {
        _deviceHasCustomVibration =
            await Vibration.hasCustomVibrationsSupport();
        _deviceHasAmplitudeControl = await Vibration.hasAmplitudeControl();
      }
    } catch (_) {
      _deviceCanVibrate = false;
      _deviceHasCustomVibration = false;
      _deviceHasAmplitudeControl = false;
    }
  }

  Future<void> _playSuccessBeep() async {
    if (!_soundEnabled) return;

    try {
      await _feedbackPlayer.stop();
      await _feedbackPlayer.play(AssetSource(_beepAssetPath));

      // Await completion and also enforce a minimum gate so rapid camera
      // detections cannot preempt audibility.
      await _feedbackPlayer.onPlayerComplete.first.timeout(
        const Duration(milliseconds: 1200),
      );
    } catch (_) {
      // Keep scanner responsive even if audio playback fails unexpectedly.
    } finally {
      await Future<void>.delayed(_minBeepGate);
    }
  }

  Future<void> _playVibration({required bool isSuccess}) async {
    if (!_vibrationEnabled || !_deviceCanVibrate) return;

    try {
      if (isSuccess && _deviceHasCustomVibration) {
        await Vibration.vibrate(
          pattern: const [0, 70, 30, 70, 30, 70],
          intensities: _deviceHasAmplitudeControl
              ? const [0, 255, 0, 255, 0, 255]
              : const [],
        );
        return;
      }

      if (!isSuccess && _deviceHasCustomVibration) {
        await Vibration.vibrate(
          pattern: const [0, 55],
          intensities: _deviceHasAmplitudeControl ? const [0, 160] : const [],
        );
        return;
      }

      await Vibration.vibrate(
        duration: isSuccess ? 180 : 70,
        amplitude: _deviceHasAmplitudeControl ? (isSuccess ? 255 : 160) : -1,
      );
    } catch (_) {
      // Ignore device-specific vibration failures and keep scanning responsive.
    }
  }

  Future<void> _handleCode(String rawCode, {bool fromManual = false}) async {
    final code = rawCode.trim();
    if (code.isEmpty || _isHandlingCode) return;

    final now = DateTime.now();
    if (!fromManual &&
        _lastLocalScanCode == code &&
        _lastLocalScanAt != null &&
        now.difference(_lastLocalScanAt!) < const Duration(milliseconds: 600)) {
      return;
    }

    _lastLocalScanCode = code;
    _lastLocalScanAt = now;

    setState(() {
      _isHandlingCode = true;
    });

    final result = await widget.onCodeDetected(code);

    await _playScanFeedback(result.success);
    // In continuous mode keep the scan gate closed for a brief quiet gap after
    // the beep so the full sound settles before the scanner can fire again.
    if (_continuousMode && result.success) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
    _triggerVisualPulse(result.success);

    if (!mounted) return;
    setState(() {
      _feedbackMessage = result.message;
      _feedbackIsSuccess = result.success;
      _pushScanHistory(
        _ScanHistoryEntry(
          code: code,
          label: result.historyLabel,
          success: result.success,
          message: result.message,
          scannedAt: DateTime.now(),
        ),
      );
      _isHandlingCode = false;
      if (fromManual) {
        _manualCodeController.clear();
      }
    });

    if (!_continuousMode && result.success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _playScanFeedback(bool isSuccess) async {
    if (isSuccess) {
      await Future.wait<void>([
        _playSuccessBeep(),
        _playVibration(isSuccess: true),
      ]);
      return;
    }

    await _playVibration(isSuccess: false);
  }

  void _triggerVisualPulse(bool isSuccess) {
    _pulseColor = isSuccess ? Colors.greenAccent : Colors.orangeAccent;
    unawaited(_pulseController.forward(from: 0));
  }

  void _pushScanHistory(_ScanHistoryEntry entry) {
    _recentScans.insert(0, entry);
    if (_recentScans.length > 3) {
      _recentScans.removeRange(3, _recentScans.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Barcode'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) return;
              final value = capture.barcodes.first.rawValue;
              if (value == null || value.trim().isEmpty) return;
              _handleCode(value);
            },
          ),
          IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final opacity = (1 - _pulseController.value).clamp(0.0, 1.0);
                  final scale = 1 + (_pulseController.value * 0.06);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _pulseColor.withValues(alpha: opacity),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _pulseColor.withValues(
                              alpha: opacity * 0.45,
                            ),
                            blurRadius: 22,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Continuous scan',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: _continuousMode,
                      onChanged: (value) {
                        setState(() => _continuousMode = value);
                      },
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: _soundEnabled
                          ? 'Mute scan sound'
                          : 'Enable scan sound',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() => _soundEnabled = !_soundEnabled);
                      },
                      icon: Icon(
                        _soundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      tooltip: _vibrationEnabled
                          ? 'Disable vibration'
                          : 'Enable vibration',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() => _vibrationEnabled = !_vibrationEnabled);
                      },
                      icon: Icon(
                        _vibrationEnabled
                            ? Icons.vibration_rounded
                            : Icons.do_not_disturb_on_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_feedbackMessage != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (_feedbackIsSuccess
                                      ? Colors.green
                                      : Colors.orange)
                                  .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _feedbackIsSuccess
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                          ),
                        ),
                        child: Text(
                          _feedbackMessage!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    if (_recentScans.isNotEmpty)
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recentScans.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, index) {
                            final scan = _recentScans[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (scan.success
                                            ? Colors.green
                                            : Colors.orange)
                                        .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: scan.success
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    scan.success
                                        ? Icons.check_circle
                                        : Icons.error_outline,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 180,
                                    ),
                                    child: Text(
                                      scan.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    if (_recentScans.isNotEmpty) const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _manualCodeController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Type barcode manually',
                              hintStyle: const TextStyle(color: Colors.white70),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (value) =>
                                _handleCode(value, fromManual: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isHandlingCode
                              ? null
                              : () => _handleCode(
                                  _manualCodeController.text,
                                  fromManual: true,
                                ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanAddResult {
  final bool success;
  final String message;
  final String historyLabel;

  const _ScanAddResult({
    required this.success,
    required this.message,
    required this.historyLabel,
  });
}

class _ScanHistoryEntry {
  final String code;
  final String label;
  final bool success;
  final String message;
  final DateTime scannedAt;

  const _ScanHistoryEntry({
    required this.code,
    required this.label,
    required this.success,
    required this.message,
    required this.scannedAt,
  });
}
