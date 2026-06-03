import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../data/models/custom_shelf_location.dart';
import '../data/shelf_code.dart';
import '../providers/inventory_providers.dart';

/// Phase 2 — bulk printable QR-code labels for shelf locations.
///
/// Workflow:
/// 1. Pick which shelves to print (multi-select; "Select all" shortcut).
/// 2. Optionally tweak layout (cols × rows per A4 page).
/// 3. Preview the generated PDF inline.
/// 4. Tap **Print** to open the OS print dialog, or **Share** to send to a
///    Bluetooth printer / messaging app.
///
/// Everything is generated on-device; no network round-trip required.
class ShelfLabelsScreen extends ConsumerStatefulWidget {
  /// If provided, those shelf sync_ids start out selected. Used by the
  /// per-row "Print label" shortcut on the manage sheet.
  final Set<String>? initialSelectionSyncIds;

  const ShelfLabelsScreen({super.key, this.initialSelectionSyncIds});

  @override
  ConsumerState<ShelfLabelsScreen> createState() => _ShelfLabelsScreenState();
}

class _ShelfLabelsScreenState extends ConsumerState<ShelfLabelsScreen> {
  // Operator-tunable grid. Defaults to 2×4 = 8 labels per A4 page, a sweet
  // spot for 50mm × 60mm shelf-edge labels printed on plain paper and cut
  // by hand.
  int _cols = 2;
  int _rows = 4;
  bool _includePhoto = true;

  /// Sync ids of selected shelves. Empty = none picked yet.
  final Set<String> _selected = <String>{};
  bool _initialApplied = false;

  @override
  Widget build(BuildContext context) {
    final shelvesAsync = ref.watch(allShelfLocationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: const Text(
          'Print Shelf Labels',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: shelvesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (shelves) {
          // Apply one-shot initial selection after the first data load.
          if (!_initialApplied) {
            _initialApplied = true;
            final initial = widget.initialSelectionSyncIds;
            if (initial != null && initial.isNotEmpty) {
              for (final s in shelves) {
                if (initial.contains(s.syncId)) _selected.add(s.syncId);
              }
            }
          }

          if (shelves.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No shelf locations yet. Add some from the Inventory '
                  'filter sheet before printing labels.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            );
          }

          return Column(
            children: [
              _buildToolbar(shelves),
              const Divider(height: 1),
              Expanded(child: _buildShelfList(shelves)),
              _buildBottomBar(shelves),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // UI pieces
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildToolbar(List<CustomShelfLocation> shelves) {
    final allSelected = _selected.length == shelves.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          TextButton.icon(
            icon: Icon(
              allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
              size: 18,
            ),
            label: Text(allSelected ? 'Clear' : 'Select all'),
            onPressed: () {
              setState(() {
                if (allSelected) {
                  _selected.clear();
                } else {
                  _selected
                    ..clear()
                    ..addAll(shelves.map((s) => s.syncId));
                }
              });
            },
          ),
          const Spacer(),
          Text(
            '${_selected.length} / ${shelves.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelfList(List<CustomShelfLocation> shelves) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: shelves.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final shelf = shelves[i];
        final isSel = _selected.contains(shelf.syncId);
        return Container(
          decoration: BoxDecoration(
            color: isSel
                ? AppColors.secondary.withValues(alpha: 0.08)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSel ? AppColors.secondary : AppColors.outlineVariant,
            ),
          ),
          child: CheckboxListTile(
            value: isSel,
            onChanged: (v) {
              setState(() {
                if (v ?? false) {
                  _selected.add(shelf.syncId);
                } else {
                  _selected.remove(shelf.syncId);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            secondary: _shelfThumb(shelf),
            title: Text(
              shelf.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'TT-SHELF-${shelfCodeShortLabel(shelf.syncId)}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shelfThumb(CustomShelfLocation shelf) {
    final localPath = shelf.imagePath;
    if (localPath != null && File(localPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(localPath),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    if (shelf.imageUrl != null && shelf.imageUrl!.isNotEmpty) {
      final resolved = resolveImageUrl(shelf.imageUrl);
      if (resolved == null) return _placeholderThumb();
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          resolved,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholderThumb(),
        ),
      );
    }
    return _placeholderThumb();
  }

  Widget _placeholderThumb() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Icon(
      Icons.shelves,
      size: 20,
      color: AppColors.onSurfaceVariant,
    ),
  );

  Widget _buildBottomBar(List<CustomShelfLocation> shelves) {
    final canPrint = _selected.isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Layout',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                _layoutChip('2×4', 2, 4),
                const SizedBox(width: 6),
                _layoutChip('2×5', 2, 5),
                const SizedBox(width: 6),
                _layoutChip('3×6', 3, 6),
                const Spacer(),
                Switch.adaptive(
                  value: _includePhoto,
                  onChanged: (v) => setState(() => _includePhoto = v),
                ),
                const Text(
                  'Photo',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share'),
                    onPressed: canPrint ? () => _sharePdf(shelves) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Preview & Print'),
                    onPressed: canPrint
                        ? () => _openPrintDialog(shelves)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _layoutChip(String label, int cols, int rows) {
    final selected = _cols == cols && _rows == rows;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() {
        _cols = cols;
        _rows = rows;
      }),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // PDF generation / printing
  // ───────────────────────────────────────────────────────────────────────

  List<CustomShelfLocation> _selectedShelves(
    List<CustomShelfLocation> shelves,
  ) => shelves.where((s) => _selected.contains(s.syncId)).toList();

  Future<void> _openPrintDialog(List<CustomShelfLocation> shelves) async {
    final picked = _selectedShelves(shelves);
    await Printing.layoutPdf(
      name: 'shelf-labels',
      onLayout: (format) => _buildPdf(format, picked),
    );
  }

  Future<void> _sharePdf(List<CustomShelfLocation> shelves) async {
    final picked = _selectedShelves(shelves);
    final bytes = await _buildPdf(PdfPageFormat.a4, picked);
    await Printing.sharePdf(bytes: bytes, filename: 'shelf-labels.pdf');
  }

  /// Builds an A4 PDF with one label per grid cell. Each label shows the
  /// shelf name, optional photo, the QR code, and the short text fallback
  /// so a human can re-type it if the camera fails.
  Future<Uint8List> _buildPdf(
    PdfPageFormat format,
    List<CustomShelfLocation> shelves,
  ) async {
    final doc = pw.Document();

    // Pre-load any image bytes off the main isolate-equivalent boundary
    // so we don't block the PDF builder closure.
    final imageByShelf = <String, pw.ImageProvider?>{};
    if (_includePhoto) {
      for (final s in shelves) {
        imageByShelf[s.syncId] = await _loadShelfImage(s);
      }
    }

    final perPage = _cols * _rows;
    for (var start = 0; start < shelves.length; start += perPage) {
      final pageShelves = shelves.sublist(
        start,
        (start + perPage).clamp(0, shelves.length),
      );
      doc.addPage(
        pw.Page(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(16),
          build: (ctx) {
            return pw.GridView(
              crossAxisCount: _cols,
              childAspectRatio: 1.4,
              children: List<pw.Widget>.generate(perPage, (i) {
                if (i >= pageShelves.length) return pw.SizedBox();
                final shelf = pageShelves[i];
                final img = imageByShelf[shelf.syncId];
                return _pdfLabel(shelf, img);
              }),
            );
          },
        ),
      );
    }

    return doc.save();
  }

  pw.Widget _pdfLabel(CustomShelfLocation shelf, pw.ImageProvider? image) {
    final payload = shelfCodePayload(shelf.syncId);
    return pw.Container(
      margin: const pw.EdgeInsets.all(4),
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
            width: 70,
            height: 70,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: payload,
              drawText: false,
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  shelf.name,
                  maxLines: 2,
                  overflow: pw.TextOverflow.clip,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'TT-SHELF-${shelfCodeShortLabel(shelf.syncId)}',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey700,
                  ),
                ),
                if (_includePhoto && image != null) ...[
                  pw.SizedBox(height: 4),
                  pw.ClipRRect(
                    horizontalRadius: 3,
                    verticalRadius: 3,
                    child: pw.Image(
                      image,
                      width: 50,
                      height: 30,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a PDF image provider for the shelf. Tries the local file
  /// first (works offline) and falls back to the server URL via the
  /// [printing] package's [networkImage] helper. Returns null when no
  /// source is reachable — the label then prints with no photo.
  Future<pw.ImageProvider?> _loadShelfImage(CustomShelfLocation shelf) async {
    try {
      final localPath = shelf.imagePath;
      if (localPath != null) {
        final f = File(localPath);
        if (await f.exists()) {
          return pw.MemoryImage(await f.readAsBytes());
        }
      }
      final url = resolveImageUrl(shelf.imageUrl);
      if (url != null && url.isNotEmpty) {
        return await networkImage(url);
      }
    } on Object {
      // Best-effort; label still prints with QR + name.
    }
    return null;
  }
}
