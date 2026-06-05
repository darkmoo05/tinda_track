import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:drift/drift.dart' show Value;

import 'package:uuid/uuid.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/database/providers/database_providers.dart';
import '../../../../../core/app_theme.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../core/sync/sync_orchestrator.dart';
import '../../../../shared/widgets/top_alert.dart';
import '../data/inventory_constants.dart';
import '../data/local_inventory_repository.dart';
import '../data/models/custom_category.dart';
import '../data/models/inventory_product.dart';
import '../data/models/product_unit_conversion.dart';
import '../data/product_image_service.dart';
import '../providers/inventory_providers.dart';
import '../widgets/manage_lookup_sheet.dart';

/// Create or edit a product. Pass [existing] to enter edit mode.
class AddEditProductScreen extends ConsumerStatefulWidget {
  final InventoryProduct? existing;

  const AddEditProductScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _sellCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _reorderCtrl;
  late final TextEditingController _baseUnitCtrl;

  final List<_AltUnitDraft> _altUnits = [];
  final List<_RecipeIngredientDraft> _recipeIngredients = [];
  final List<_SerialNumberDraft> _serialNumbers = [];
  final Map<String, TextEditingController> _customAttrControllers = {};
  late String _itemType;
  final _serialInputCtrl = TextEditingController();

  late String _category;
  late String _unit;
  late bool _isActive;
  late String _shelfLocation;
  DateTime? _expirationDate;

  /// Dual-mode SKU engine — when true, the SKU field is read-only and
  /// populated with a deterministic `TT-YYMMDD-XXXX` internal code. A
  /// successful barcode scan flips this off so the user can keep manually
  /// editing if they choose. Off by default for new products so users can
  /// scan or type a real barcode; for edits it stays off (their existing
  /// SKU is shown as-is).
  bool _autoGenerateSku = false;

  File? _localImageFile;
  String? _remoteImageUrl;
  bool _imageChanged = false;

  bool _saving = false;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _skuCtrl = TextEditingController(text: p?.sku ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _costCtrl = TextEditingController(
      text: p != null ? p.costPrice.toString() : '',
    );
    _sellCtrl = TextEditingController(
      text: p != null ? p.sellingPrice.toString() : '',
    );
    _stockCtrl = TextEditingController(
      text: p != null ? p.stockQuantity.toString() : '0',
    );
    _reorderCtrl = TextEditingController(
      text: p != null ? p.reorderPoint.toString() : '0',
    );

    _category = p?.category ?? '';
    _unit = p?.unit ?? kProductUnits.first;
    _isActive = p?.isActive ?? true;
    _shelfLocation = p?.shelfLocation ?? '';
    _baseUnitCtrl = TextEditingController(
      text: p?.baseUnit ?? p?.unit ?? 'pcs',
    );
    _expirationDate = p?.expirationDate;
    _remoteImageUrl = p?.imageUrl;
    for (final c in p?.unitConversions ?? const <ProductUnitConversion>[]) {
      _altUnits.add(
        _AltUnitDraft(
          unitName: c.unitName,
          factor: c.conversionFactor.toString(),
          costPrice: c.costPrice.toString(),
          sellingPrice: c.sellingPrice.toString(),
        ),
      );
    }
    _itemType = p?.itemType ?? 'standard';
    final initialAttrs = p?.customAttributes ?? const {};
    for (final entry in initialAttrs.entries) {
      _customAttrControllers[entry.key] = TextEditingController(text: entry.value?.toString());
    }

    if (p?.imagePath != null) {
      final f = File(p!.imagePath!);
      if (f.existsSync()) _localImageFile = f;
    }

    if (_isEdit) {
      _loadProductDetails();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    _sellCtrl.dispose();
    _stockCtrl.dispose();
    _reorderCtrl.dispose();
    _baseUnitCtrl.dispose();
    for (final d in _altUnits) {
      d.dispose();
    }
    for (final d in _recipeIngredients) {
      d.dispose();
    }
    _serialInputCtrl.dispose();
    _customAttrControllers.forEach((_, ctrl) => ctrl.dispose());
    super.dispose();
  }

  List<ProductUnitConversion> _buildConversionsForSave() {
    return _altUnits
        .map((d) => d.toModel())
        .whereType<ProductUnitConversion>()
        .toList(growable: false);
  }

  // -- Image picker --------------------------------------------------------

  Future<void> _pickImage({bool useCamera = false}) async {
    // Use the product's stable id so the compressed file is named
    // consistently; fall back to a temp ID for new (unsaved) products.
    final syncId =
        widget.existing?.id ?? 'tmp_${DateTime.now().millisecondsSinceEpoch}';
    final file = await ProductImageService.instance.pickAndCompress(
      syncId: syncId,
      useCamera: useCamera,
      context: context,
    );
    if (file != null && mounted) {
      // Evict the stale FileImage cache for this path so Image.file always
      // renders the new content (cache key is path-based, not content-based).
      PaintingBinding.instance.imageCache.evict(FileImage(file));
      setState(() {
        _localImageFile = file;
        _imageChanged = true;
      });
    }
  }

  /// Opens the full-screen image review screen. Returns an action (retake /
  /// gallery) that is forwarded to [_pickImage], or null if the user closes
  /// the viewer without changing the image.
  Future<void> _viewImage() async {
    final action = await Navigator.push<_ImageReviewAction>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImageReviewScreen(
          localFile: _localImageFile,
          remoteUrl: _remoteImageUrl,
        ),
      ),
    );
    if (!mounted) return;
    if (action == _ImageReviewAction.retake) {
      await _pickImage(useCamera: true);
    } else if (action == _ImageReviewAction.gallery) {
      await _pickImage();
    }
  }

  // -- Barcode scanner ------------------------------------------------------

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        // Any scanned value overrides auto-generate; the field becomes
        // editable again so the user can correct OCR-style misreads.
        _autoGenerateSku = false;
        _skuCtrl.text = result;
      });
    }
  }

  /// Generates a deterministic-looking SKU of the form `TT-YYMMDD-XXXX`
  /// where the trailing block is 4 random hex chars. Used when the user
  /// toggles the "Auto-generate" mode on; called once per toggle so the
  /// number stays stable while the user fills in the rest of the form.
  String _generateInternalSku() {
    final now = DateTime.now();
    final ymd =
        '${(now.year % 100).toString().padLeft(2, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final rand = (DateTime.now().microsecondsSinceEpoch ^ now.hashCode)
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(0, 4)
        .toUpperCase();
    return 'TT-$ymd-$rand';
  }

  void _toggleAutoGenerateSku(bool enabled) {
    setState(() {
      _autoGenerateSku = enabled;
      if (enabled) {
        // Always overwrite when entering auto mode so the user sees the
        // generated value; previous manual entry is preserved nowhere
        // because they've opted into the generator.
        _skuCtrl.text = _generateInternalSku();
      }
    });
  }

  /// Opens a bottom-sheet listing every (non-deleted) category so users can
  /// assign a product to a category that isn't pinned to the quick-access
  /// row. Tapping a row's body picks it as the product's category; tapping
  /// the trailing pin icon toggles whether that category appears in the
  /// quick-access chip strip (capped at [maxQuickAccessCategories]).
  Future<void> _pickCategoryFromAll(List<CustomCategory> cats) async {
    // Local working copy so pin-toggles update the sheet immediately
    // without waiting for the providers to re-emit.
    final working = List<CustomCategory>.of(cats);

    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: StatefulBuilder(
              builder: (ctx, setSheetState) {
                Future<void> togglePin(int index) async {
                  final cat = working[index];
                  final newPinned = !cat.isQuickAccess;
                  try {
                    final updated = await ref
                        .read(localInventoryRepositoryProvider)
                        .updateCategory(cat.localId, isQuickAccess: newPinned);
                    setSheetState(() => working[index] = updated);
                  } on QuickAccessLimitException catch (e) {
                    if (!mounted) return;
                    showTopAlert(
                      context,
                      'You can only pin up to ${e.limit} '
                      'quick-access categories.',
                    );
                  } catch (e) {
                    if (!mounted) return;
                    showTopAlert(context, e.toString());
                  }
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'All categories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        'Tap a category to use it. Tap the pin to add or '
                        'remove it from the quick-access row.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: working.length,
                        itemBuilder: (_, i) {
                          final cat = working[i];
                          final selected = cat.name == _category;
                          return ListTile(
                            leading: Icon(
                              Icons.label_outline,
                              size: 20,
                              color: AppColors.onSurfaceVariant,
                            ),
                            title: Text(cat.name),
                            subtitle: cat.description.isEmpty
                                ? null
                                : Text(
                                    cat.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selected)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                IconButton(
                                  tooltip: cat.isQuickAccess
                                      ? 'Unpin from quick access'
                                      : 'Pin to quick access',
                                  icon: Icon(
                                    cat.isQuickAccess
                                        ? Icons.push_pin
                                        : Icons.push_pin_outlined,
                                    size: 20,
                                    color: cat.isQuickAccess
                                        ? AppColors.secondary
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  onPressed: () => togglePin(i),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.pop(ctx, cat.name),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    // Pin state may have changed regardless of whether a category was picked,
    // so always refresh the providers that drive the chip strip and lists.
    ref.invalidate(allCategoriesProvider);
    ref.invalidate(quickAccessCategoriesProvider);
    ref.read(categoriesRefreshProvider.notifier).state++;
    // Push the pin toggle / new category to the server right away.
    unawaited(ref.read(syncOrchestratorProvider).runOnce());

    if (picked != null && mounted) setState(() => _category = picked);
  }

  Future<void> _loadProductDetails() async {
    final tindaDao = ref.read(tindaTrackerDaoProvider);
    final recipeIngs = await tindaDao.productRecipeIngredients.listForRecipe(widget.existing!.id);
    final serials = await tindaDao.productSerialNumbers.listForProduct(widget.existing!.id);
    
    // Load ingredient names for display
    final allProds = await ref.read(allProductsProvider.future);
    final prodMap = {for (final p in allProds) p.id: p};
    
    if (mounted) {
      setState(() {
        _recipeIngredients.clear();
        for (final row in recipeIngs) {
          final ingProd = prodMap[row.ingredientProductId];
          _recipeIngredients.add(
            _RecipeIngredientDraft(
              id: row.id,
              ingredientProductId: row.ingredientProductId,
              ingredientName: ingProd?.name ?? 'Unknown Product',
              quantityCtrl: TextEditingController(text: row.quantityNeeded.toString()),
              unit: ingProd?.unit ?? 'pcs',
            ),
          );
        }
        
        _serialNumbers.clear();
        for (final row in serials) {
          _serialNumbers.add(
            _SerialNumberDraft(
              id: row.id,
              serialNumber: row.serialNumber,
              status: row.status,
            ),
          );
        }
      });
    }
  }

  Future<void> _addIngredient() async {
    // Capture all context-dependent string values before any async gap.
    final noIngredientsMsg = context.l10n.noIngredientsAvailable;
    final allProds = await ref.read(allProductsProvider.future);
    // Filter out recipes and the current product to avoid loops
    final candidates = allProds.where((p) => p.itemType != 'recipe' && p.id != widget.existing?.id).toList();
    
    if (candidates.isEmpty) {
      if (mounted) showTopAlert(context, noIngredientsMsg);
      return;
    }
    if (!mounted) return;
    
    final picked = await showModalBottomSheet<InventoryProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Pumili ng Sangkap',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: candidates.length,
                    itemBuilder: (_, i) {
                      final p = candidates[i];
                      return ListTile(
                        leading: const Icon(Icons.restaurant_menu_rounded),
                        title: Text(p.name),
                        subtitle: Text('Stock: ${p.stockQuantity} ${p.unit}'),
                        onTap: () => Navigator.pop(ctx, p),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    if (picked != null && mounted) {
      // Check if already in recipe ingredients
      if (_recipeIngredients.any((d) => d.ingredientProductId == picked.id)) {
        showTopAlert(context, '${picked.name} ay nasa listahan na.');
        return;
      }
      setState(() {
        _recipeIngredients.add(
          _RecipeIngredientDraft(
            id: '',
            ingredientProductId: picked.id,
            ingredientName: picked.name,
            quantityCtrl: TextEditingController(text: '1.0'),
            unit: picked.unit,
          ),
        );
      });
    }
  }

  void _addSerialNumber(String code) {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) return;
    if (_serialNumbers.any((s) => s.serialNumber.toLowerCase() == cleanCode.toLowerCase())) {
      showTopAlert(context, context.l10n.serialAlreadyAdded);
      return;
    }
    setState(() {
      _serialNumbers.add(
        _SerialNumberDraft(
          id: '',
          serialNumber: cleanCode,
          status: 'AVAILABLE',
        ),
      );
      _serialInputCtrl.clear();
      
      // Auto-update stock quantity count to match serial numbers count (for new products)
      if (!_isEdit) {
        _stockCtrl.text = _serialNumbers.where((s) => s.status == 'AVAILABLE').length.toString();
      }
    });
  }

  Widget _buildCustomAttributesSection(String businessType) {
    if (businessType == 'auto_parts') {
      return _SectionCard(
        title: 'Auto Parts Compatibility & Details',
        child: Column(
          children: [
            _customField(
              key: 'compatibility',
              label: 'Compatibility (e.g. Toyota Vios 2018)',
              icon: Icons.directions_car_rounded,
            ),
            const SizedBox(height: 12),
            _customField(
              key: 'brand',
              label: 'Brand (e.g. Denso, Bosch)',
              icon: Icons.branding_watermark_rounded,
            ),
          ],
        ),
      );
    } else if (businessType == 'hardware') {
      return _SectionCard(
        title: 'Hardware Dimensions & Specifications',
        child: Column(
          children: [
            _customField(
              key: 'dimensions',
              label: 'Dimensions (e.g. 10mm x 50mm)',
              icon: Icons.square_foot_rounded,
            ),
            const SizedBox(height: 12),
            _customField(
              key: 'weight',
              label: 'Weight (e.g. 1.2kg)',
              icon: Icons.monitor_weight_rounded,
            ),
          ],
        ),
      );
    } else if (businessType == 'food_service') {
      return _SectionCard(
        title: 'Carinderia Prep Info',
        child: Column(
          children: [
            _customField(
              key: 'prepTime',
              label: 'Prep Time (e.g. 15 mins)',
              icon: Icons.timer_rounded,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _customField({
    required String key,
    required String label,
    required IconData icon,
  }) {
    final ctrl = _customAttrControllers.putIfAbsent(key, () => TextEditingController());
    return _field(
      controller: ctrl,
      label: label,
      icon: icon,
    );
  }

  // -- Save -----------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final activeAvailableCount = _serialNumbers.where((s) => s.status == 'AVAILABLE').length;
    final stockVal = _isEdit 
        ? (widget.existing!.stockInBaseUnit)
        : (double.tryParse(_stockCtrl.text) ?? 0.0);
    
    if (_serialNumbers.isNotEmpty && stockVal.toInt() != activeAvailableCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.stockMustMatchSerials(
              stockVal.toInt(),
              activeAvailableCount,
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(localInventoryRepositoryProvider);

      final customAttrs = <String, dynamic>{};
      _customAttrControllers.forEach((k, v) {
        if (v.text.trim().isNotEmpty) {
          customAttrs[k] = v.text.trim();
        }
      });

      final savedProduct = _isEdit
          ? await repo.updateProduct(
              widget.existing!.id,
              name: _nameCtrl.text.trim(),
              sku: _skuCtrl.text.trim(),
              description: _descCtrl.text.trim(),
              category: _category,
              unit: _baseUnitCtrl.text.trim().isEmpty
                  ? _unit
                  : _baseUnitCtrl.text.trim(),
              baseUnit: _baseUnitCtrl.text.trim().isEmpty
                  ? _unit
                  : _baseUnitCtrl.text.trim(),
              costPrice: double.tryParse(_costCtrl.text) ?? 0,
              sellingPrice: double.tryParse(_sellCtrl.text) ?? 0,
              stockInBaseUnit: double.tryParse(_stockCtrl.text) ?? 0,
              reorderPoint: int.tryParse(_reorderCtrl.text) ?? 0,
              isActive: _isActive,
              shelfLocation: _shelfLocation,
              // Only update imagePath when the user actually picked a new image.
              // Passing updateSentinel leaves the existing image_path/image_url untouched.
              imagePath: _imageChanged ? _localImageFile?.path : updateSentinel,
              expirationDate: _expirationDate,
              unitConversions: _buildConversionsForSave(),
              itemType: _itemType,
              customAttributes: customAttrs,
            )
          : await repo.createProduct(
              name: _nameCtrl.text.trim(),
              sku: _skuCtrl.text.trim(),
              description: _descCtrl.text.trim(),
              category: _category,
              unit: _baseUnitCtrl.text.trim().isEmpty
                  ? _unit
                  : _baseUnitCtrl.text.trim(),
              baseUnit: _baseUnitCtrl.text.trim().isEmpty
                  ? _unit
                  : _baseUnitCtrl.text.trim(),
              costPrice: double.tryParse(_costCtrl.text) ?? 0,
              sellingPrice: double.tryParse(_sellCtrl.text) ?? 0,
              stockQuantity: int.tryParse(_stockCtrl.text) ?? 0,
              stockInBaseUnit: double.tryParse(_stockCtrl.text) ?? 0,
              reorderPoint: int.tryParse(_reorderCtrl.text) ?? 0,
              isActive: _isActive,
              shelfLocation: _shelfLocation,
              imagePath: _localImageFile?.path,
              expirationDate: _expirationDate,
              unitConversions: _buildConversionsForSave(),
              itemType: _itemType,
              customAttributes: customAttrs,
            );

      final productId = savedProduct.id;
      final tindaDao = ref.read(tindaTrackerDaoProvider);
      final deviceId = await ref.read(appMetaDaoProvider).getOrCreateDeviceId();

      if (_itemType == 'recipe') {
        final existingIngs = await tindaDao.productRecipeIngredients.listForRecipe(productId);
        for (final row in existingIngs) {
          final stillExists = _recipeIngredients.any((d) => d.id == row.id);
          if (!stillExists) {
            await tindaDao.productRecipeIngredients.softDelete(row.id);
          }
        }
        for (final d in _recipeIngredients) {
          final qty = double.tryParse(d.quantityCtrl.text.trim()) ?? 0.0;
          if (qty <= 0) continue;
          final syncId = d.id.isNotEmpty ? d.id : const Uuid().v4();
          await tindaDao.productRecipeIngredients.upsertLocal(
            ProductRecipeIngredientsCompanion(
              id: Value(syncId),
              syncId: Value(syncId),
              deviceId: Value(deviceId),
              recipeProductId: Value(productId),
              ingredientProductId: Value(d.ingredientProductId),
              quantityNeeded: Value(qty),
              isDeleted: const Value(false),
            ),
          );
        }
      }

      final existingSerials = await tindaDao.productSerialNumbers.listForProduct(productId);
      for (final row in existingSerials) {
        final stillExists = _serialNumbers.any((d) => d.id == row.id);
        if (!stillExists) {
          await tindaDao.productSerialNumbers.softDelete(row.id);
        }
      }
      for (final d in _serialNumbers) {
        if (d.serialNumber.trim().isEmpty) continue;
        final syncId = d.id.isNotEmpty ? d.id : const Uuid().v4();
        await tindaDao.productSerialNumbers.upsertLocal(
          ProductSerialNumbersCompanion(
            id: Value(syncId),
            syncId: Value(syncId),
            deviceId: Value(deviceId),
            productId: Value(productId),
            serialNumber: Value(d.serialNumber.trim()),
            status: Value(d.status),
            isDeleted: const Value(false),
          ),
        );
      }

      // Refresh the products list
      ref.invalidate(allProductsProvider);
      // Fire-and-forget push so the new/edited product (and its conversions)
      // hit the server immediately instead of waiting for the next app
      // launch/exit lifecycle sync.
      unawaited(ref.read(syncOrchestratorProvider).runOnce());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit ? context.l10n.productUpdated : context.l10n.productAdded,
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pop(context, true);
      }
    } on DuplicateSkuException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        final restocked = await _showDuplicateSkuDialog(e.existing);
        if (restocked == true && mounted) Navigator.pop(context, true);
      }
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // -- Duplicate SKU dialog -------------------------------------------------

  Future<bool?> _showDuplicateSkuDialog(InventoryProduct existing) {
    final qtyCtrl = TextEditingController(
      text: _stockCtrl.text.isNotEmpty ? _stockCtrl.text : '1',
    );
    DateTime? expiryDate;
    String? expiryError;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> pickDate() async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              helpText: 'Select expiration date',
            );
            if (picked != null) {
              setDialogState(() {
                expiryDate = picked;
                expiryError = null;
              });
            }
          }

          return AlertDialog(
            title: const Text('Product Already Exists'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${existing.name}" (SKU: ${existing.sku}) is already in your inventory '
                    'with ${existing.stockQuantity} ${existing.unit} in stock.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How many units do you want to add to the existing stock?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity to add',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Expiration date (optional)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      expiryDate == null
                          ? 'No expiration date'
                          : '${expiryDate!.year}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                  if (expiryError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      expiryError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                  if (qty <= 0) {
                    setDialogState(
                      () => expiryError = 'Enter a quantity greater than 0',
                    );
                    return;
                  }
                  await ref
                      .read(localInventoryRepositoryProvider)
                      .adjustStock(
                        productId: existing.id,
                        quantityDelta: qty,
                        movementType: 'RESTOCK',
                        note: 'Manual restock via add-product form',
                        expirationDate: expiryDate,
                      );
                  ref.invalidate(allProductsProvider);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added $qty ${existing.unit} to "${existing.name}".',
                        ),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                    Navigator.pop(ctx, true);
                  }
                },
                child: const Text('Add to Existing Stock'),
              ),
            ],
          );
        },
      ),
    );
  }

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider).value;
    final showRecipes = profile?.showRecipes ?? false;
    final showSerialTracking = profile?.showSerialTracking ?? false;
    final businessType = profile?.businessType ?? 'retail';

    final itemTypeItems = showRecipes
        ? const ['standard', 'recipe', 'ingredient', 'service']
        : const ['standard', 'service'];

    final normalizedItemTypes = List<String>.from(itemTypeItems);
    if (!normalizedItemTypes.contains(_itemType)) {
      normalizedItemTypes.insert(0, _itemType);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          _isEdit ? context.l10n.editProduct : context.l10n.addProduct,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    context.l10n.save,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            // -- Basic info -----------------------------------------------
            _SectionCard(
              title: context.l10n.productInformation,
              child: Column(
                children: [
                  _field(
                    controller: _nameCtrl,
                    label: context.l10n.productName,
                    icon: Icons.label_rounded,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? context.l10n.nameRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // SKU / Barcode — dual-mode engine. Users either scan a
                  // real product barcode or generate an internal TT-* code
                  // for unbranded items (homemade, repacked, etc.).
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          controller: _skuCtrl,
                          label: context.l10n.skuBarcode,
                          icon: Icons.barcode_reader,
                          readOnly: _autoGenerateSku,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.l10n.skuRequired
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        tooltip: context.l10n.scanBarcode,
                        onPressed: _scanBarcode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Switch.adaptive(
                        value: _autoGenerateSku,
                        onChanged: _toggleAutoGenerateSku,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Auto-generate internal SKU',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      if (_autoGenerateSku)
                        IconButton(
                          tooltip: 'Regenerate',
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          onPressed: () => setState(
                            () => _skuCtrl.text = _generateInternalSku(),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _descCtrl,
                    label: context.l10n.descriptionOptional,
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            // -- Item Type Dropdown ---------------------------------------
            _SectionCard(
              title: 'Item Type',
              child: _dropdown(
                label: 'Item Type',
                value: _itemType,
                items: normalizedItemTypes,
                onChanged: (v) => setState(() => _itemType = v!),
                icon: Icons.merge_type_rounded,
              ),
            ),

            // -- Recipe ingredients builder -------------------------------
            if (_itemType == 'recipe')
              _SectionCard(
                title: 'Recipe Ingredients (BOM)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_recipeIngredients.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          AppLocalizations.of(context)!.noIngredientsSet,
                          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                        ),
                      )
                    else
                      ..._recipeIngredients.asMap().entries.map((entry) {
                        final index = entry.key;
                        final d = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  d.ingredientName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: d.quantityCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Qty',
                                    suffixText: d.unit,
                                    isDense: true,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    d.dispose();
                                    _recipeIngredients.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Ingredient'),
                    ),
                  ],
                ),
              ),

            // -- Category ------------------------------------------------
            _SectionCard(
              title: context.l10n.category,
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Manage categories',
                onPressed: () =>
                    showManageLookupSheet(context, isCategory: true),
              ),
              child: ref
                  .watch(allCategoriesProvider)
                  .when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (cats) {
                      // Only pinned categories appear as quick chips; the
                      // rest are reachable through the "More…" pill so the
                      // form stays compact even with a long master list.
                      final pinned = cats
                          .where((c) => c.isQuickAccess)
                          .toList();
                      final pinnedNames = pinned.map((c) => c.name).toSet();
                      final extraSelected =
                          _category.isNotEmpty &&
                          !pinnedNames.contains(_category);
                      // Default a brand-new product to the first pinned
                      // category once data arrives — prevents an empty save.
                      if (_category.isEmpty && pinned.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => setState(() => _category = pinned.first.name),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Concept B — Selected-first tile ──────────
                          // Full-width summary of the current selection.
                          // Tapping anywhere opens the all-categories
                          // picker, which is faster than scanning chips
                          // when the user already knows what to pick.
                          _CategorySelectedTile(
                            category: _category,
                            onTap: () => _pickCategoryFromAll(cats),
                          ),
                          const SizedBox(height: 12),
                          // Quick-access label keeps the role of the chip
                          // grid obvious now that the selected value lives
                          // in the tile above.
                          const Text(
                            'Quick access',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // ── Concept A — Uniform pill grid ────────────
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: [
                              ...pinned.map(
                                (cat) => _CategoryPill(
                                  label: cat.name,
                                  selected: _category == cat.name,
                                  onTap: () =>
                                      setState(() => _category = cat.name),
                                ),
                              ),
                              if (extraSelected)
                                _CategoryPill(
                                  label: _category,
                                  selected: true,
                                  onTap: () {},
                                  trailingIcon: Icons.push_pin_outlined,
                                ),
                              _CategoryPill(
                                label: 'More',
                                selected: false,
                                isAction: true,
                                leadingIcon: Icons.tune_rounded,
                                onTap: () => _pickCategoryFromAll(cats),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
            ),

            // -- Unit ----------------------------------------------------
            _SectionCard(
              title: context.l10n.unitLabel,
              child: _dropdown(
                label: context.l10n.unitLabel,
                value: _unit,
                items: kProductUnits,
                onChanged: (v) => setState(() => _unit = v!),
                icon: Icons.straighten_rounded,
              ),
            ),

            // -- Measurement Setup --------------------------------------
            _SectionCard(
              title: 'Measurement Setup',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field(
                    controller: _baseUnitCtrl,
                    label: 'Base Unit (e.g., pcs, grams)',
                    icon: Icons.straighten_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Base unit is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Alternative unit packages',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._altUnits.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AltUnitCard(
                        draft: entry.value,
                        baseUnitCtrl: _baseUnitCtrl,
                        onRemove: () {
                          setState(() {
                            entry.value.dispose();
                            _altUnits.removeAt(entry.key);
                          });
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _altUnits.add(_AltUnitDraft());
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Alternative Unit Package'),
                    ),
                  ),
                ],
              ),
            ),

            // -- Shelf Location ------------------------------------------
            _SectionCard(
              title: 'Shelf Location',
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Manage locations',
                onPressed: () =>
                    showManageLookupSheet(context, isCategory: false),
              ),
              child: ref
                  .watch(allShelfLocationsProvider)
                  .when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => _dropdown(
                      label: 'Shelf Location',
                      value: _shelfLocation,
                      items: const ['Counter'],
                      onChanged: (v) => setState(() => _shelfLocation = v!),
                      icon: Icons.shelves,
                    ),
                    data: (locs) {
                      final names = locs.map((l) => l.name).toList();
                      if (names.isNotEmpty && !names.contains(_shelfLocation)) {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => setState(() => _shelfLocation = names.first),
                        );
                      }
                      return _dropdown(
                        label: 'Shelf Location',
                        value: names.contains(_shelfLocation)
                            ? _shelfLocation
                            : (names.isNotEmpty ? names.first : _shelfLocation),
                        items: names.isNotEmpty ? names : [_shelfLocation],
                        onChanged: (v) => setState(() => _shelfLocation = v!),
                        icon: Icons.shelves,
                      );
                    },
                  ),
            ),

            // -- Custom Attributes ----------------------------------------
            _buildCustomAttributesSection(businessType),

            // -- Pricing -------------------------------------------------
            _SectionCard(
              title: context.l10n.pricing,
              child: Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _costCtrl,
                      label: context.l10n.costPrice,
                      icon: Icons.payments_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefix: '\u20B1',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _sellCtrl,
                      label: context.l10n.sellingPrice,
                      icon: Icons.sell_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefix: '\u20B1',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return context.l10n.fieldRequired;
                        }
                        if (double.tryParse(v) == null) {
                          return context.l10n.numbersOnly;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),

            // -- Stock ---------------------------------------------------
            _SectionCard(
              title: context.l10n.stock,
              child: Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _stockCtrl,
                      label: context.l10n.initialStock,
                      icon: Icons.inventory_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: !_isEdit,
                      helperText: _isEdit
                          ? context.l10n.useAdjustStockToChange
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _reorderCtrl,
                      label: context.l10n.lowStockAlert,
                      icon: Icons.warning_amber_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ),

            // -- Serial Numbers -------------------------------------------
            if (showSerialTracking || _serialNumbers.isNotEmpty)
              _SectionCard(
                title: 'Serial Numbers',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_serialNumbers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.noSerialsRegistered,
                          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _serialNumbers.length,
                          itemBuilder: (context, index) {
                            final s = _serialNumbers[index];
                            final isAvailable = s.status == 'AVAILABLE';
                            return ListTile(
                              dense: true,
                              title: Text(
                                s.serialNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: isAvailable ? null : TextDecoration.lineThrough,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      s.status,
                                      style: TextStyle(
                                        color: isAvailable ? Colors.green : Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isAvailable)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _serialNumbers.removeAt(index);
                                          if (!_isEdit) {
                                            _stockCtrl.text = _serialNumbers.where((sn) => sn.status == 'AVAILABLE').length.toString();
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _serialInputCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Add Serial Number',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: _addSerialNumber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          onPressed: () async {
                            final scanned = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
                            );
                            if (scanned != null) {
                              _addSerialNumber(scanned);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.add),
                          onPressed: () => _addSerialNumber(_serialInputCtrl.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.scanOrTypeSerial,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

            // -- More details (collapsible: image, expiration, status) ---
            // Groups optional/rarely-edited fields behind a single tap so
            // the form's first-screen view stays focused on the data that
            // every product needs.
            _MoreDetailsSection(
              initiallyExpanded:
                  _isEdit &&
                  (_localImageFile != null ||
                      (_remoteImageUrl != null &&
                          _remoteImageUrl!.isNotEmpty) ||
                      _expirationDate != null ||
                      !_isActive),
              children: [
                _SectionCard(
                  title: 'Product Image',
                  child: _ImagePickerWidget(
                    localFile: _localImageFile,
                    remoteUrl: _remoteImageUrl,
                    onPickGallery: () => _pickImage(),
                    onPickCamera: () => _pickImage(useCamera: true),
                    onRemove: () => setState(() => _localImageFile = null),
                    onViewImage: _viewImage,
                  ),
                ),
                _SectionCard(
                  title: 'Expiration Date (Optional)',
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  _expirationDate ??
                                  DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _expirationDate = picked);
                            }
                          },
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                          ),
                          label: Text(
                            _expirationDate == null
                                ? 'No expiration date'
                                : '${_expirationDate!.year}-${_expirationDate!.month.toString().padLeft(2, '0')}-${_expirationDate!.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      if (_expirationDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          tooltip: 'Clear expiration date',
                          onPressed: () =>
                              setState(() => _expirationDate = null),
                        ),
                      ],
                    ],
                  ),
                ),
                _SectionCard(
                  title: context.l10n.status,
                  child: SwitchListTile.adaptive(
                    title: Text(
                      context.l10n.activeLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(context.l10n.activeHelperText),
                    value: _isActive,
                    activeThumbColor: AppColors.secondary,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Save button
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      _isEdit
                          ? context.l10n.updateProduct
                          : context.l10n.addProduct,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Helpers ---------------------------------------------------------------

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    String? prefix,
    int maxLines = 1,
    bool enabled = true,
    bool readOnly = false,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        prefixText: prefix,
        helperText: helperText,
        helperMaxLines: 2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        filled: true,
        fillColor: enabled
            ? AppColors.surfaceContainerLowest
            : AppColors.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    // Guard against legacy/custom values (e.g. "pcs") and accidental
    // duplicates, which would otherwise throw DropdownButton assertions.
    final normalizedItems = <String>[];
    final seen = <String>{};
    for (final raw in items) {
      final item = raw.trim();
      if (item.isEmpty) continue;
      if (seen.add(item)) normalizedItems.add(item);
    }

    final normalizedValue = value.trim();
    if (normalizedValue.isNotEmpty && seen.add(normalizedValue)) {
      normalizedItems.insert(0, normalizedValue);
    }

    final safeValue = normalizedValue.isEmpty || normalizedItems.isEmpty
        ? null
        : normalizedValue;

    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      onChanged: onChanged,
      items: normalizedItems
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Image picker widget
// -----------------------------------------------------------------------------

class _ImagePickerWidget extends StatelessWidget {
  final File? localFile;
  final String? remoteUrl;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;
  final VoidCallback onViewImage;

  const _ImagePickerWidget({
    required this.localFile,
    required this.remoteUrl,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
    required this.onViewImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = localFile != null || remoteUrl != null;

    final imageContent = hasImage
        ? (localFile != null
              ? Image.file(
                  localFile!,
                  fit: BoxFit.cover,
                  key: ValueKey(localFile!.path),
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                )
              : Image.network(
                  resolveImageUrl(remoteUrl) ?? remoteUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image_rounded),
                ))
        : const Icon(
            Icons.add_photo_alternate_rounded,
            size: 32,
            color: AppColors.onSurfaceVariant,
          );

    return Row(
      children: [
        // Tapping the thumbnail opens the full-screen viewer when an image
        // exists; otherwise falls through to the gallery picker.
        GestureDetector(
          onTap: hasImage ? onViewImage : onPickGallery,
          child: Hero(
            tag: 'product_image_hero',
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageContent,
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Action buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: onPickGallery,
              icon: const Icon(Icons.photo_library_rounded, size: 16),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: onPickCamera,
              icon: const Icon(Icons.photo_camera_rounded, size: 16),
              label: const Text('Camera'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Section card wrapper
// -----------------------------------------------------------------------------

/// Collapsible "More details" group. Visually mimics a `_SectionCard` but its
/// body is gated by an `ExpansionTile`, so optional fields (image, expiration,
/// status) don't crowd the form's first screen on a phone.
class _MoreDetailsSection extends StatelessWidget {
  final List<Widget> children;
  final bool initiallyExpanded;

  const _MoreDetailsSection({
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Strip the default ExpansionTile divider lines so the section reads
        // as part of the surrounding card stack instead of a list row.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          title: const Text(
            'More details',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          subtitle: const Text(
            'Image · Expiration · Status',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          children: children,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Category selection widgets (Concept A pills + Concept B selected tile)
// -----------------------------------------------------------------------------

/// Selected-first summary tile (Concept B). Tapping anywhere opens the full
/// category picker; designed to dominate the section so the user can confirm
/// or change the choice at a glance without scanning chips.
class _CategorySelectedTile extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const _CategorySelectedTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasSelection = category.isNotEmpty;
    return Material(
      color: hasSelection
          ? AppColors.secondary.withValues(alpha: 0.08)
          : AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasSelection
                  ? AppColors.secondary.withValues(alpha: 0.4)
                  : AppColors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hasSelection
                      ? AppColors.secondary.withValues(alpha: 0.18)
                      : AppColors.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasSelection
                      ? Icons.category_rounded
                      : Icons.add_circle_outline_rounded,
                  size: 20,
                  color: hasSelection
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasSelection ? 'Selected category' : 'Choose a category',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasSelection ? category : 'Tap to browse all',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: hasSelection
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.unfold_more_rounded,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uniform-geometry quick-access pill (Concept A). All variants share the
/// same height (36) and corner radius so the row reads as a single button
/// family — solves the visual unevenness that ChoiceChip/ActionChip caused.
class _CategoryPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isAction;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isAction = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;
    if (selected) {
      bg = AppColors.secondary;
      fg = Colors.white;
      border = AppColors.secondary;
    } else if (isAction) {
      bg = AppColors.background;
      fg = AppColors.onSurfaceVariant;
      border = AppColors.outlineVariant;
    } else {
      bg = AppColors.surfaceContainerLowest;
      fg = AppColors.onSurface;
      border = AppColors.outlineVariant;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.2,
                  color: fg,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 6),
                Icon(trailingIcon, size: 14, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AltUnitDraft {
  final TextEditingController unitName;
  final TextEditingController factor;
  final TextEditingController costPrice;
  final TextEditingController sellingPrice;

  _AltUnitDraft({
    String unitName = '',
    String factor = '',
    String costPrice = '',
    String sellingPrice = '',
  }) : unitName = TextEditingController(text: unitName),
       factor = TextEditingController(text: factor),
       costPrice = TextEditingController(text: costPrice),
       sellingPrice = TextEditingController(text: sellingPrice);

  ProductUnitConversion? toModel() {
    final unit = unitName.text.trim();
    final f = double.tryParse(factor.text.trim()) ?? 0;
    if (unit.isEmpty || f <= 0) return null;
    return ProductUnitConversion(
      id: '',
      syncId: '',
      productId: '',
      unitName: unit,
      conversionFactor: f,
      costPrice: double.tryParse(costPrice.text.trim()) ?? 0,
      sellingPrice: double.tryParse(sellingPrice.text.trim()) ?? 0,
    );
  }

  void dispose() {
    unitName.dispose();
    factor.dispose();
    costPrice.dispose();
    sellingPrice.dispose();
  }
}

class _AltUnitCard extends StatelessWidget {
  final _AltUnitDraft draft;
  final TextEditingController baseUnitCtrl;
  final VoidCallback onRemove;

  const _AltUnitCard({
    required this.draft,
    required this.baseUnitCtrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Alternative package',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                tooltip: 'Remove package',
                icon: const Icon(Icons.delete_outline, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: draft.unitName,
            decoration: const InputDecoration(
              labelText: 'Unit Name (e.g., Box, Case, Sack)',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: draft.factor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText:
                  'Contains (e.g., 24 ${baseUnitCtrl.text.trim().isEmpty ? 'pcs' : baseUnitCtrl.text.trim()})',
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: draft.costPrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Wholesale Cost',
                    prefixText: '\u20B1',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: draft.sellingPrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Wholesale Sell',
                    prefixText: '\u20B1',
                    isDense: true,
                    border: OutlineInputBorder(),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Barcode scanner screen
// -----------------------------------------------------------------------------

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  final _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(context.l10n.scanBarcode),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_handled) return;
          final barcode = capture.barcodes.firstOrNull;
          if (barcode?.rawValue != null) {
            _handled = true;
            Navigator.pop(context, barcode!.rawValue);
          }
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Image review screen
// -----------------------------------------------------------------------------

enum _ImageReviewAction { retake, gallery }

/// Full-screen image viewer opened when the user taps the product thumbnail.
/// Supports pinch-to-zoom and pan. Returns an [_ImageReviewAction] when the
/// user chooses to retake or pick from gallery, or null if they just close.
class _ImageReviewScreen extends StatelessWidget {
  final File? localFile;
  final String? remoteUrl;

  const _ImageReviewScreen({this.localFile, this.remoteUrl});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final imageWidget = localFile != null
        ? Image.file(localFile!, fit: BoxFit.contain)
        : Image.network(
            resolveImageUrl(remoteUrl) ?? remoteUrl!,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.broken_image_rounded,
              size: 64,
              color: Colors.white38,
            ),
          );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Review Photo',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          // Zoomable image — Hero morphs from the 88×88 thumbnail.
          Positioned.fill(
            child: Center(
              child: Hero(
                tag: 'product_image_hero',
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5.0,
                  child: imageWidget,
                ),
              ),
            ),
          ),

          // Bottom action bar with gradient fade.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                  stops: [0.6, 1.0],
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 48, 24, bottomPadding + 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, _ImageReviewAction.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Change Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, _ImageReviewAction.retake),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Retake'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
}

class _RecipeIngredientDraft {
  final String id;
  final String ingredientProductId;
  final String ingredientName;
  final TextEditingController quantityCtrl;
  final String unit;

  _RecipeIngredientDraft({
    required this.id,
    required this.ingredientProductId,
    required this.ingredientName,
    required this.quantityCtrl,
    required this.unit,
  });

  void dispose() {
    quantityCtrl.dispose();
  }
}

class _SerialNumberDraft {
  final String id;
  final String serialNumber;
  final String status;

  _SerialNumberDraft({
    required this.id,
    required this.serialNumber,
    required this.status,
  });
}
