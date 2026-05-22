import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/app_theme.dart';
import '../../../../shared/widgets/top_alert.dart';
import '../data/models/custom_shelf_location.dart';
import '../data/models/inventory_product.dart';
import '../data/shelf_code.dart';
import '../providers/inventory_providers.dart';
import 'add_edit_product_screen.dart';

/// Phase 3 — full-screen detail for a single shelf location.
///
/// Opened by:
/// 1. Scanning a `TT-SHELF-<syncId>` QR via the inventory scan-to-locate
///    action, or
/// 2. Tapping a shelf entry from a "find" list (future enhancement).
///
/// Shows the shelf photo, the QR + short code (for re-scan), live stats
/// (product count / low-stock / out-of-stock), and the list of products
/// currently assigned to that shelf so the operator can verify physical
/// reality against the ledger.
class ShelfDetailScreen extends ConsumerWidget {
  final CustomShelfLocation shelf;

  const ShelfDetailScreen({super.key, required this.shelf});

  static final _currency = NumberFormat.currency(
    symbol: '\u20B1',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByShelfNameProvider(shelf.name));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          final lowCount = products.where((p) => p.isLowStock).length;
          final outCount = products.where((p) => p.isOutOfStock).length;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: _buildQrAndStats(
                  context,
                  productCount: products.length,
                  lowCount: lowCount,
                  outCount: outCount,
                ),
              ),
              if (products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _ProductRow(
                      product: products[i],
                      onTap: () => _openEdit(context, products[i]),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, InventoryProduct p) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditProductScreen(existing: p)),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Header (photo banner + back button)
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      title: Text(
        shelf.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      flexibleSpace: FlexibleSpaceBar(background: _shelfBanner()),
    );
  }

  Widget _shelfBanner() {
    final localPath = shelf.imagePath;
    Widget image;
    if (localPath != null && File(localPath).existsSync()) {
      image = Image.file(File(localPath), fit: BoxFit.cover);
    } else if (shelf.imageUrl != null && shelf.imageUrl!.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: shelf.imageUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => _placeholderBanner(),
      );
    } else {
      image = _placeholderBanner();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        // Soft gradient so the title text stays readable on bright photos.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.transparent, Colors.black38],
              stops: [0, 0.4, 1],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderBanner() => Container(
    color: AppColors.secondary.withValues(alpha: 0.85),
    alignment: Alignment.center,
    child: const Icon(Icons.shelves, size: 64, color: Colors.white70),
  );

  // ───────────────────────────────────────────────────────────────────────
  // QR + stats card
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildQrAndStats(
    BuildContext context, {
    required int productCount,
    required int lowCount,
    required int outCount,
  }) {
    final payload = shelfCodePayload(shelf.syncId);
    final shortLabel = shelfCodeShortLabel(shelf.syncId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QR card — large enough to scan from another device for quick
          // partner sharing.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: payload,
                    size: 110,
                    backgroundColor: Colors.white,
                    gapless: true,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shelf code',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        'TT-SHELF-$shortLabel',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(0, 32),
                        ),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy code'),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: payload));
                          if (!context.mounted) return;
                          showTopAlert(
                            context,
                            'Shelf code copied',
                            backgroundColor: AppColors.secondary,
                            icon: Icons.check_circle_outline,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (shelf.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                shelf.description,
                style: const TextStyle(color: AppColors.onSurface),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _StatChip(
                label: 'Products',
                value: '$productCount',
                color: AppColors.secondary,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Low stock',
                value: '$lowCount',
                color: const Color(0xFFE65100),
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Out',
                value: '$outCount',
                color: AppColors.error,
                icon: Icons.remove_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final InventoryProduct product;
  final VoidCallback onTap;

  const _ProductRow({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLow = product.isLowStock;
    final isOut = product.isOutOfStock;
    final stockColor = isOut
        ? AppColors.error
        : isLow
        ? const Color(0xFFE65100)
        : AppColors.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOut || isLow
                ? stockColor.withValues(alpha: 0.4)
                : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            _thumb(product),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.sku,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ShelfDetailScreen._currency.format(product.sellingPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${product.stockQuantity} ${product.unit}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: stockColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(InventoryProduct p) {
    final localPath = p.imagePath;
    Widget child;
    if (localPath != null && File(localPath).existsSync()) {
      child = Image.file(File(localPath), fit: BoxFit.cover);
    } else if (p.imageUrl != null && p.imageUrl!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: p.imageUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => const Icon(
          Icons.inventory_2_outlined,
          color: AppColors.onSurfaceVariant,
        ),
      );
    } else {
      child = const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.onSurfaceVariant,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        color: AppColors.surfaceContainerHigh,
        child: child,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 12),
            Text(
              'No products are assigned to this shelf yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Edit a product and set its shelf location to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
