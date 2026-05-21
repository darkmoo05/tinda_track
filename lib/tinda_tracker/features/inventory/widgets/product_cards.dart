import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/app_theme.dart';
import '../data/models/inventory_product.dart';

/// Full-width list tile for the List View mode.
class ProductListTile extends StatelessWidget {
  final InventoryProduct product;
  final bool isSelected;
  final bool bulkSelectMode;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onAdjustStock;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onAdjustStock,
    this.isSelected = false,
    this.bulkSelectMode = false,
  });

  static final _currency = NumberFormat.currency(symbol: '?', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final isLow = product.isLowStock;
    final isOut = product.isOutOfStock;
    final stockColor = isOut
        ? AppColors.error
        : isLow
        ? const Color(0xFFE65100)
        : AppColors.secondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.08)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : isOut || isLow
                ? stockColor.withValues(alpha: 0.4)
                : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Bulk-select checkbox OR product icon
            if (bulkSelectMode)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Checkbox(
                  value: isSelected,
                  activeColor: AppColors.secondary,
                  onChanged: (_) => onTap(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )
            else
              _ProductImage(product: product),
            const SizedBox(width: 12),

            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _currency.format(product.sellingPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _MiniChip(product.category),
                      if (product.shelfLocation.isNotEmpty)
                        _MiniChip(product.shelfLocation, icon: Icons.shelves),
                      if (product.sku.isNotEmpty)
                        _MiniChip(product.sku, icon: Icons.barcode_reader),
                      if (product.isExpired)
                        const _MiniChip(
                          'Expired',
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.error,
                        )
                      else if (product.isExpiringSoon)
                        _MiniChip(
                          'Exp ${_daysUntil(product.expirationDate!)}d',
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFE65100),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Stock count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${product.stockQuantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: stockColor,
                  ),
                ),
                Text(
                  product.unit,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (isOut)
                  const _StatusBadge('WALA', AppColors.error)
                else if (isLow)
                  const _StatusBadge('MABABA', Color(0xFFE65100)),
              ],
            ),
            const SizedBox(width: 4),

            // Action buttons
            if (!bulkSelectMode)
              Column(
                children: [
                  _IconBtn(
                    icon: Icons.edit_rounded,
                    onTap: onEdit,
                    tooltip: 'I-edit',
                  ),
                  const SizedBox(height: 4),
                  _IconBtn(
                    icon: Icons.add_circle_rounded,
                    onTap: onAdjustStock,
                    color: AppColors.secondary,
                    tooltip: 'Ayusin ang Stock',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------

/// 2-column card for Grid View mode.
class ProductGridCard extends StatelessWidget {
  final InventoryProduct product;
  final bool isSelected;
  final bool bulkSelectMode;
  final VoidCallback onTap;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isSelected = false,
    this.bulkSelectMode = false,
  });

  static final _currency = NumberFormat.currency(symbol: '?', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final isLow = product.isLowStock;
    final isOut = product.isOutOfStock;
    final stockColor = isOut
        ? AppColors.error
        : isLow
        ? const Color(0xFFE65100)
        : AppColors.secondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.08)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : isOut || isLow
                ? stockColor.withValues(alpha: 0.4)
                : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with stock badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: _ProductImage(product: product, large: true),
                  ),
                ),
                // Stock badge top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${product.stockQuantity} ${product.unit}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                // Bulk-select checkbox
                if (bulkSelectMode)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: AppColors.secondary,
                      onChanged: (_) => onTap(),
                      fillColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected)
                            ? AppColors.secondary
                            : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currency.format(product.sellingPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.secondary,
                    ),
                  ),
                  if (product.shelfLocation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _MiniChip(product.shelfLocation, icon: Icons.shelves),
                  ],
                  if (product.isExpired) ...[
                    const SizedBox(height: 4),
                    const _MiniChip(
                      'Expired',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                    ),
                  ] else if (product.isExpiringSoon) ...[
                    const SizedBox(height: 4),
                    _MiniChip(
                      'Exp ${_daysUntil(product.expirationDate!)}d',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFE65100),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shared private widgets
// -----------------------------------------------------------------------------

/// Product image that shows local file → remote URL → category icon fallback.
class _ProductImage extends StatelessWidget {
  final InventoryProduct product;
  final bool large;

  const _ProductImage({required this.product, this.large = false});

  @override
  Widget build(BuildContext context) {
    final size = large ? 100.0 : 46.0;

    Widget fallback = _ProductIcon(category: product.category, large: large);

    // Prefer local file
    if (product.imagePath != null) {
      final f = File(product.imagePath!);
      if (f.existsSync()) {
        return SizedBox(
          width: size,
          height: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(large ? 0 : 10),
            child: Image.file(
              f,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
          ),
        );
      }
    }

    // Fall back to remote URL (with persistent disk cache for offline support)
    if (product.imageUrl != null) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(large ? 0 : 10),
          child: CachedNetworkImage(
            imageUrl: product.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, _, _) => fallback,
          ),
        ),
      );
    }

    return SizedBox(width: size, height: size, child: fallback);
  }
}

/// Category-based product icon placeholder (no image).
class _ProductIcon extends StatelessWidget {
  final String category;
  final bool large;

  const _ProductIcon({required this.category, this.large = false});

  static IconData _iconFor(String cat) {
    switch (cat.toLowerCase()) {
      case 'drinks':
      case 'softdrinks':
        return Icons.local_drink_rounded;
      case 'cigarettes':
        return Icons.smoking_rooms_rounded;
      case 'toiletries':
        return Icons.soap_rounded;
      case 'condiments':
        return Icons.set_meal_rounded;
      case 'canned goods':
        return Icons.food_bank_rounded;
      case 'instant noodles':
        return Icons.ramen_dining_rounded;
      case 'coffee & tea':
        return Icons.coffee_rounded;
      case 'dairy':
        return Icons.egg_rounded;
      case 'medicine':
        return Icons.medication_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          _iconFor(category),
          size: large ? 40 : 28,
          color: AppColors.secondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const _MiniChip(this.label, {this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color != null
            ? color!.withValues(alpha: 0.12)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: color != null
            ? Border.all(color: color!.withValues(alpha: 0.4), width: 0.8)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: color != null ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

int _daysUntil(DateTime date) =>
    date.difference(DateTime.now()).inDays.clamp(0, 9999);

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String tooltip;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.color = AppColors.onSurfaceVariant,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
