import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/app_theme.dart';
import '../../../../../core/l10n/l10n_extension.dart';
import '../data/inventory_constants.dart';
import '../data/local_inventory_repository.dart';
import '../data/models/inventory_product.dart';
import '../providers/inventory_providers.dart';

Future<void> showQuickStockSheet(
  BuildContext context,
  WidgetRef ref,
  InventoryProduct product,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuickStockSheet(product: product, ref: ref),
  );
}

class _QuickStockSheet extends StatefulWidget {
  final InventoryProduct product;
  final WidgetRef ref;

  const _QuickStockSheet({required this.product, required this.ref});

  @override
  State<_QuickStockSheet> createState() => _QuickStockSheetState();
}

class _QuickStockSheetState extends State<_QuickStockSheet> {
  final _manualController = TextEditingController();
  String _reason = kStockAdjustmentReasons.first;
  bool _loading = false;
  int _previewDelta = 0;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  int get _currentPreview =>
      (widget.product.stockQuantity + _previewDelta).clamp(0, 9999999);

  Future<void> _save() async {
    final manual = int.tryParse(_manualController.text) ?? 0;
    final total = _previewDelta + manual;
    if (total == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.noChange)));
      return;
    }
    setState(() => _loading = true);
    try {
      final movementType = _reasonToType(_reason);
      await LocalInventoryRepository.instance.adjustStock(
        productId: widget.product.id,
        quantityDelta: total,
        movementType: movementType,
        note: _reason,
      );
      widget.ref.invalidate(allProductsProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _reasonToType(String reason) {
    if (reason == 'Restock') return 'RESTOCK';
    if (reason == 'Sale Adjustment') return 'SALE';
    return 'ADJUSTMENT';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.categoryAndUnit(
                    widget.product.category,
                    widget.product.unit,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Column(
                    children: [
                      Text(
                        '$_currentPreview',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: _currentPreview <= widget.product.reorderPoint
                              ? AppColors.error
                              : AppColors.secondary,
                          height: 1,
                        ),
                      ),
                      Text(
                        widget.product.unit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (_previewDelta != 0)
                        Text(
                          _previewDelta > 0
                              ? '+$_previewDelta ${context.l10n.quickAdjust}'
                              : '$_previewDelta ${context.l10n.quickAdjust}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _previewDelta > 0
                                ? AppColors.secondary
                                : AppColors.error,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  context.l10n.quickAdjust,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _QuickBtn(
                      label: '-10',
                      color: AppColors.error,
                      onTap: () => setState(() => _previewDelta -= 10),
                    ),
                    _QuickBtn(
                      label: '-5',
                      color: AppColors.error,
                      onTap: () => setState(() => _previewDelta -= 5),
                    ),
                    _QuickBtn(
                      label: '-1',
                      color: AppColors.error,
                      onTap: () => setState(() => _previewDelta -= 1),
                    ),
                    _QuickBtn(
                      label: '+1',
                      color: AppColors.secondary,
                      onTap: () => setState(() => _previewDelta += 1),
                    ),
                    _QuickBtn(
                      label: '+5',
                      color: AppColors.secondary,
                      onTap: () => setState(() => _previewDelta += 5),
                    ),
                    _QuickBtn(
                      label: '+10',
                      color: AppColors.secondary,
                      onTap: () => setState(() => _previewDelta += 10),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualController,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                        ],
                        decoration: InputDecoration(
                          labelText: context.l10n.manualAmount,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.secondary,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.edit_rounded),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_previewDelta != 0) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => setState(() => _previewDelta = 0),
                        child: Text(context.l10n.resetBtn),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  context.l10n.reason,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kStockAdjustmentReasons.map((r) {
                    final selected = _reason == r;
                    return ChoiceChip(
                      label: Text(r),
                      selected: selected,
                      onSelected: (_) => setState(() => _reason = r),
                      selectedColor: AppColors.secondary.withValues(
                        alpha: 0.15,
                      ),
                      checkmarkColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.secondary
                            : AppColors.onSurface,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            context.l10n.saveStock,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: color,
          ),
        ),
      ),
    );
  }
}
