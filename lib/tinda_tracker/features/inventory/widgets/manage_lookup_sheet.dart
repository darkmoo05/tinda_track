import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/app_theme.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/sync/sync_orchestrator.dart';
import '../../../../shared/widgets/top_alert.dart';
import '../data/local_inventory_repository.dart';
import '../data/models/custom_category.dart';
import '../data/models/custom_shelf_location.dart';
import '../data/product_image_service.dart';
import '../data/shelf_code.dart';
import '../providers/inventory_providers.dart';
import '../screens/shelf_labels_screen.dart';

/// Opens a draggable bottom-sheet that lets the user manage the list of
/// product categories (when [isCategory] is true) or shelf locations.
///
/// The redesigned sheet exposes each row as an expandable card so the user
/// can author a short description, list a few example items, and (for
/// categories) toggle quick-access pinning capped at
/// [maxQuickAccessCategories] entries. Shelf locations gain a small photo
/// thumbnail captured via the same guided camera flow used by products.
Future<void> showManageLookupSheet(
  BuildContext context, {
  required bool isCategory,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ManageLookupSheet(isCategory: isCategory),
  );
}

class _ManageLookupSheet extends ConsumerStatefulWidget {
  final bool isCategory;
  const _ManageLookupSheet({required this.isCategory});

  @override
  ConsumerState<_ManageLookupSheet> createState() => _ManageLookupSheetState();
}

class _ManageLookupSheetState extends ConsumerState<_ManageLookupSheet> {
  final _newNameCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _adding = false;

  String get _title => widget.isCategory ? 'Categories' : 'Shelf Locations';

  // True when the new-name field has at least one non-whitespace character.
  // Used to enable/disable the Add button so the user can't tap it on an
  // empty input (and gets a visual cue that input is required).
  bool get _canAdd => _newNameCtrl.text.trim().isNotEmpty && !_adding;

  @override
  void initState() {
    super.initState();
    // Rebuild the Add button as the user types so it enables/disables live.
    _newNameCtrl.addListener(_onNewNameChanged);
  }

  void _onNewNameChanged() {
    if (mounted) setState(() {});
  }

  void _invalidate() {
    if (widget.isCategory) {
      ref.invalidate(allCategoriesProvider);
      ref.read(categoriesRefreshProvider.notifier).state++;
    } else {
      ref.invalidate(allShelfLocationsProvider);
      ref.read(shelfLocationsRefreshProvider.notifier).state++;
    }
    // Fire-and-forget push to the server. Without this, the new/changed row
    // sits on the device with is_dirty=1 until the next app launch / exit
    // lifecycle sync — leaving other devices unaware until then.
    unawaited(ref.read(syncOrchestratorProvider).runOnce());
  }

  Future<void> _add() async {
    final name = _newNameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _adding = true);
    try {
      if (widget.isCategory) {
        await ref.read(localInventoryRepositoryProvider).createCategory(name);
      } else {
        await ref
            .read(localInventoryRepositoryProvider)
            .createShelfLocation(name);
      }
      _newNameCtrl.clear();
      _invalidate();
    } on Object catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    final String msg;
    if (e is QuickAccessLimitException) {
      // Tell the user the cap *and* the next step (unpin one).
      msg =
          'Quick access is full. You can only pin up to ${e.limit} '
          'categories — unpin one first, then try again.';
    } else if (e is DuplicateNameException) {
      // Plain wording: avoid the word "duplicate" and suggest what to do.
      msg =
          'You already have a ${e.kind} named "${e.name}". '
          'Please choose a different name.';
    } else {
      // Hide the raw exception text from end-users; log via toString() but
      // show a calm, actionable message instead.
      msg = 'Sorry, we couldn\'t save your changes. Please try again.';
    }
    // Top-anchored banner so the alert is visible above this bottom sheet
    // and the on-screen keyboard — a default SnackBar would be hidden.
    showTopAlert(context, msg);
  }

  @override
  void dispose() {
    _newNameCtrl.removeListener(_onNewNameChanged);
    _newNameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = widget.isCategory
        ? ref.watch(allCategoriesProvider)
        : ref.watch(allShelfLocationsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (!widget.isCategory)
                      // Print Shelf Labels entry point. Opens a dedicated
                      // screen so the operator can multi-select shelves,
                      // preview the sheet, and export/share/print to a
                      // Bluetooth or wired printer.
                      IconButton(
                        tooltip: 'Print shelf labels',
                        icon: const Icon(Icons.print_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ShelfLabelsScreen(),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newNameCtrl,
                        decoration: InputDecoration(
                          hintText: widget.isCategory
                              ? 'New category name'
                              : 'New shelf / location name',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add button — disabled (greyed out) when the input is
                    // empty so the user gets an immediate visual cue that a
                    // name is required before they can tap.
                    Tooltip(
                      message: _canAdd
                          ? 'Add'
                          : (widget.isCategory
                                ? 'Type a category name first'
                                : 'Type a shelf or location name first'),
                      child: FilledButton(
                        onPressed: _canAdd ? _add : null,
                        child: _adding
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ),
              // Search field — lets the user filter the existing list to
              // quickly find a category or shelf without scrolling. Matches
              // on name, description, and examples (case-insensitive).
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: widget.isCategory
                        ? 'Search categories'
                        : 'Search shelf locations',
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: itemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) {
                    // Apply the search filter. For categories we also match
                    // description and examples; for shelves the name is the
                    // only searchable text.
                    final q = _query.toLowerCase();
                    final filtered = q.isEmpty
                        ? items
                        : items.where((item) {
                            if (item is CustomCategory) {
                              return item.name.toLowerCase().contains(q) ||
                                  item.description.toLowerCase().contains(q) ||
                                  item.examples.toLowerCase().contains(q);
                            }
                            if (item is CustomShelfLocation) {
                              return item.name.toLowerCase().contains(q);
                            }
                            return true;
                          }).toList();

                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'No items yet. Add one above.',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      );
                    }
                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No matches for "$_query"',
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        if (widget.isCategory) {
                          return _CategoryTile(
                            category: item as CustomCategory,
                            onChanged: (err) {
                              if (err != null) _showError(err);
                              _invalidate();
                            },
                          );
                        }
                        return _ShelfLocationTile(
                          location: item as CustomShelfLocation,
                          onChanged: (err) {
                            if (err != null) _showError(err);
                            _invalidate();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-row editors
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTile extends ConsumerStatefulWidget {
  final CustomCategory category;
  // [err] is non-null when the underlying mutation threw — typically a
  // [QuickAccessLimitException]. Always called so the host can refresh.
  final void Function(Object? err) onChanged;
  const _CategoryTile({required this.category, required this.onChanged});

  @override
  ConsumerState<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends ConsumerState<_CategoryTile> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _examples;
  late bool _quick;
  bool _busy = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category.name);
    _desc = TextEditingController(text: widget.category.description);
    _examples = TextEditingController(text: widget.category.examples);
    _quick = widget.category.isQuickAccess;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _examples.dispose();
    super.dispose();
  }

  Future<void> _save({bool? quickOverride}) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(localInventoryRepositoryProvider)
          .updateCategory(
            widget.category.localId,
            name: _name.text.trim(),
            description: _desc.text.trim(),
            examples: _examples.text.trim(),
            isQuickAccess: quickOverride ?? _quick,
          );
      widget.onChanged(null);
    } on Object catch (e) {
      // Roll back UI state for the failed toggle so the checkbox reflects
      // server-side truth (cap exceeded → stays unpinned).
      if (quickOverride != null) {
        setState(() => _quick = !quickOverride);
      }
      widget.onChanged(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await _confirmDelete(context, widget.category.name);
    if (ok != true) return;
    await ref
        .read(localInventoryRepositoryProvider)
        .deleteCategory(widget.category.localId);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.category.name;
    final desc = widget.category.description;
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row — tap anywhere (except the action buttons) to expand.
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  // Letter avatar — colored when pinned (secondary green),
                  // otherwise primary blue tint.
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _quick
                          ? AppColors.secondary.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _quick ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title + optional "Quick" badge + description (2 lines).
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (_quick) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Quick',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Pin toggle — the only "state" control in the header.
                  IconButton(
                    tooltip: _quick
                        ? 'Unpin from quick access'
                        : 'Pin to quick access',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      _quick ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 20,
                      color: _quick
                          ? AppColors.secondary
                          : AppColors.onSurfaceVariant,
                    ),
                    onPressed: _busy
                        ? null
                        : () {
                            final next = !_quick;
                            setState(() => _quick = next);
                            _save(quickOverride: next);
                          },
                  ),
                  // Plain chevron — visual hint only; the whole row is tappable.
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          // Expanded edit body — fields + Delete (left) / Save (right) row.
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _textField(_name, 'Name'),
                  const SizedBox(height: 8),
                  _textField(_desc, 'Description', maxLines: 2),
                  const SizedBox(height: 8),
                  _textField(
                    _examples,
                    'Examples (comma-separated)',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _busy ? null : _delete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.tonal(
                        onPressed: _busy ? null : () => _save(),
                        child: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ShelfLocationTile extends ConsumerStatefulWidget {
  final CustomShelfLocation location;
  final void Function(Object? err) onChanged;
  const _ShelfLocationTile({required this.location, required this.onChanged});

  @override
  ConsumerState<_ShelfLocationTile> createState() => _ShelfLocationTileState();
}

class _ShelfLocationTileState extends ConsumerState<_ShelfLocationTile> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _examples;
  String? _imagePath;
  String? _imageUrl;
  // Bumped on every image change so the [Image] widgets get a fresh key and
  // bypass Flutter's in-memory image cache (which keys [FileImage] by path,
  // and the file path here is deterministic per shelf location).
  int _imageVersion = 0;
  bool _busy = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.location.name);
    _desc = TextEditingController(text: widget.location.description);
    _examples = TextEditingController(text: widget.location.examples);
    _imagePath = widget.location.imagePath;
    _imageUrl = widget.location.imageUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _examples.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto({required bool useCamera}) async {
    // Key the compressed file by sync_id so each shelf location ends up with
    // a single deterministic file (no orphan cleanup needed when the user
    // retakes the photo locally).
    final syncId = 'shelf_${widget.location.syncId}';
    final file = await ProductImageService.instance.pickAndCompress(
      syncId: syncId,
      useCamera: useCamera,
      context: context,
    );
    if (file == null || !mounted) return;
    // The new compressed image is written to the same path as the previous
    // one (sync_id-keyed). Flutter's image cache would otherwise keep
    // serving the stale bytes, so evict it before rebuilding the thumb.
    await FileImage(file).evict();
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      await NetworkImage(_imageUrl!).evict();
    }
    setState(() {
      _imagePath = file.path;
      _imageUrl = null; // force re-upload by the sync worker
      _imageVersion++;
    });
    await ref
        .read(localInventoryRepositoryProvider)
        .updateShelfLocation(widget.location.localId, imagePath: file.path);
    widget.onChanged(null);
  }

  /// Clears the current image. The sync worker will propagate the null
  /// `imagePath` to the server on the next push.
  Future<void> _removePhoto() async {
    if (_imagePath == null && (_imageUrl == null || _imageUrl!.isEmpty)) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove image?'),
        content: Text(
          'The photo for "${widget.location.name}" will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // Drop cached bytes so the placeholder appears immediately.
    if (_imagePath != null) {
      await FileImage(File(_imagePath!)).evict();
    }
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      await NetworkImage(_imageUrl!).evict();
    }
    setState(() {
      _imagePath = null;
      _imageUrl = null;
      _imageVersion++;
    });
    await ref
        .read(localInventoryRepositoryProvider)
        .updateShelfLocation(widget.location.localId, imagePath: null);
    widget.onChanged(null);
  }

  /// Opens an action sheet so the user picks the image source (or removes
  /// the existing photo). Single entry-point used by both the "Update
  /// Image" button and the tap-to-edit thumbnail.
  Future<void> _showImageActions() async {
    final hasImage =
        _imagePath != null || (_imageUrl != null && _imageUrl!.isNotEmpty);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(useCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(useCamera: false);
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Remove image',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _removePhoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(localInventoryRepositoryProvider)
          .updateShelfLocation(
            widget.location.localId,
            name: _name.text.trim(),
            description: _desc.text.trim(),
            examples: _examples.text.trim(),
          );
      widget.onChanged(null);
    } on Object catch (e) {
      widget.onChanged(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await _confirmDelete(context, widget.location.name);
    if (ok != true) return;
    await ref
        .read(localInventoryRepositoryProvider)
        .deleteShelfLocation(widget.location.localId);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return _LookupCard(
      leading: _thumb(),
      title: widget.location.name,
      subtitle: widget.location.description.isEmpty
          ? null
          : widget.location.description,
      expanded: _expanded,
      onTapHeader: () => setState(() => _expanded = !_expanded),
      onDelete: _delete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tap the thumbnail itself to update — a familiar gesture
              // borrowed from profile/avatar editors.
              GestureDetector(
                onTap: _showImageActions,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _thumb(size: 72),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: Text(
                    _imagePath != null ||
                            (_imageUrl != null && _imageUrl!.isNotEmpty)
                        ? 'Update Image'
                        : 'Add Image',
                  ),
                  onPressed: _showImageActions,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ShelfQrSection(location: widget.location),
          const SizedBox(height: 12),
          _textField(_name, 'Name'),
          const SizedBox(height: 8),
          _textField(_desc, 'Description', maxLines: 2),
          const SizedBox(height: 8),
          _textField(_examples, 'Examples (comma-separated)', maxLines: 2),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb({double size = 36}) {
    final radius = BorderRadius.circular(size * 0.18);
    Widget child;
    final localPath = _imagePath;
    if (localPath != null && File(localPath).existsSync()) {
      // ValueKey ties the widget instance to [_imageVersion]; bumping the
      // version on replace forces Flutter to dispose the old [FileImage]
      // stream and load fresh bytes from disk.
      child = Image.file(
        File(localPath),
        key: ValueKey('shelf-${widget.location.syncId}-file-$_imageVersion'),
        fit: BoxFit.cover,
      );
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      final resolved = resolveImageUrl(_imageUrl);
      child = resolved == null
          ? const Icon(Icons.image_outlined, color: AppColors.onSurfaceVariant)
          : Image.network(
              resolved,
              key: ValueKey(
                'shelf-${widget.location.syncId}-net-$_imageVersion',
              ),
              fit: BoxFit.cover,
            );
    } else {
      child = const Icon(
        Icons.image_outlined,
        color: AppColors.onSurfaceVariant,
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: AppColors.surfaceContainerHigh,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared row card
// ─────────────────────────────────────────────────────────────────────────────

class _LookupCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final bool expanded;
  final VoidCallback onTapHeader;
  final VoidCallback onDelete;
  final Widget child;

  const _LookupCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onTapHeader,
    required this.onDelete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTapHeader,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (subtitle case final subtitleText?)
                          Text(
                            subtitleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: onTapHeader,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: child,
            ),
        ],
      ),
    );
  }
}

Widget _textField(TextEditingController c, String label, {int maxLines = 1}) {
  return TextField(
    controller: c,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

Future<bool?> _confirmDelete(BuildContext context, String name) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete?'),
      content: Text('Remove "$name"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 1: inline QR section rendered in the expanded shelf-location card
// ─────────────────────────────────────────────────────────────────────────────

/// Renders a small QR code, the human-readable short label, and quick
/// actions ("Copy code", "Print label") for a single shelf location.
///
/// The QR is generated on-device by [qr_flutter] so it works offline; the
/// payload comes from [shelfCodePayload] and stays stable across renames
/// or re-photos because it is keyed by the immutable `sync_id`.
class _ShelfQrSection extends StatelessWidget {
  final CustomShelfLocation location;
  const _ShelfQrSection({required this.location});

  @override
  Widget build(BuildContext context) {
    final payload = shelfCodePayload(location.syncId);
    final shortLabel = shelfCodeShortLabel(location.syncId);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Solid white background guarantees scannable contrast even when
          // the parent theme renders dark surfaces.
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: QrImageView(
              data: payload,
              size: 80,
              version: QrVersions.auto,
              gapless: true,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Shelf code',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'TT-SHELF-$shortLabel',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
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
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text('Print'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShelfLabelsScreen(
                              initialSelectionSyncIds: {location.syncId},
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
