import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/app_theme.dart';
import '../../../../../core/l10n/l10n_extension.dart';
import '../data/models/inventory_product.dart';
import '../data/models/stock_movement.dart';
import '../providers/inventory_providers.dart';

class StockHistoryScreen extends ConsumerWidget {
  final InventoryProduct product;

  const StockHistoryScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(stockMovementsProvider(product.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.stockHistory,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              product.name,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref.invalidate(stockMovementsProvider(product.id)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _StatBox(
                  label: context.l10n.currentStockLabel,
                  value: '${product.stockQuantity}',
                  unit: product.unit,
                  color: product.isOutOfStock
                      ? AppColors.error
                      : product.isLowStock
                      ? const Color(0xFFE65100)
                      : AppColors.secondary,
                ),
                const SizedBox(width: 16),
                _StatBox(
                  label: context.l10n.lowStockAlertStat,
                  value: '<= ${product.reorderPoint}',
                  unit: product.unit,
                  color: const Color(0xFFE65100),
                ),
              ],
            ),
          ),
          Expanded(
            child: movementsAsync.when(
              data: (movements) {
                if (movements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 52,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.noStockHistory,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: movements.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _MovementTile(movement: movements[i]),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final StockMovement movement;

  static final _dateFormat = DateFormat('MMM d, y  h:mm a');

  const _MovementTile({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isAdd = movement.quantity > 0;
    final color = isAdd ? AppColors.secondary : AppColors.error;
    final sign = isAdd ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAdd ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.movementType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
                if (movement.note.isNotEmpty)
                  Text(
                    movement.note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  _dateFormat.format(movement.createdAt.toLocal()),
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
                '$sign${movement.quantity}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: color,
                ),
              ),
              Text(
                '${movement.previousQuantity} -> ${movement.newQuantity}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
