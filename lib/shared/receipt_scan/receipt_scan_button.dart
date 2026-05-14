import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_extension.dart';
import '../widgets/app_loading_modal.dart';
import 'receipt_draft.dart';
import 'receipt_scan_service.dart';

/// A self-contained "Scan Receipt" button.
///
/// Drop this anywhere in a form. When the user picks an image, the widget
/// runs OCR, shows a confirmation dialog, and — if the user accepts —
/// calls [onDraftReady] with the extracted [ReceiptDraft].
///
/// Example:
/// ```dart
/// ReceiptScanButton(
///   onDraftReady: (draft) {
///     if (draft.amount != null) {
///       _amountController.text =
///           ReceiptScanService.instance.formatAmountForInput(draft.amount!);
///     }
///     if (draft.reference != null) {
///       _referenceController.text = draft.reference!;
///     }
///   },
/// )
/// ```
class ReceiptScanButton extends StatefulWidget {
  const ReceiptScanButton({super.key, required this.onDraftReady});

  /// Called after the user confirms the scanned data.
  final void Function(ReceiptDraft draft) onDraftReady;

  @override
  State<ReceiptScanButton> createState() => _ReceiptScanButtonState();
}

class _ReceiptScanButtonState extends State<ReceiptScanButton> {
  bool _isScanning = false;

  Future<void> _onPressed() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    var stage = 'initialization';
    try {
      final service = ReceiptScanService.instance;

      stage = 'image selection';
      final imagePath = await service.pickImagePath(context);
      if (!mounted) return;

      if (imagePath == null || imagePath.isEmpty) {
        // User cancelled image picker
        return;
      }

      stage = 'OCR parsing';
      final loading = showAppLoadingModal(
        context,
        message: context.l10n.scanningReceiptModalMessage,
        caption: context.l10n.scanningReceipt,
      );
      // Give the dialog one frame to render before starting OCR,
      // so loading.close() is never called before the dialog is on the stack.
      await Future<void>.delayed(Duration.zero);

      ReceiptDraft? draft;
      try {
        draft = await service.scanFromImagePath(imagePath);
      } finally {
        loading.close();
      }

      if (!mounted || draft == null) return;

      if (!draft.hasAnySignal) {
        _showMessage(
          'OCR completed but no usable amount/account/reference was detected. Try a clearer receipt image.',
          isError: true,
        );
        return;
      }

      stage = 'confirmation dialog';
      final shouldApply = await _showConfirmationDialog(draft);
      if (!mounted || !shouldApply) return;

      widget.onDraftReady(draft);
    } catch (error, stackTrace) {
      debugPrint('Receipt scan failed at $stage: $error\n$stackTrace');
      if (!mounted) return;
      _showMessage(
        'Receipt scan failed during $stage. Please try again with a clearer image.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<bool> _showConfirmationDialog(ReceiptDraft draft) async {
    final service = ReceiptScanService.instance;
    final noteText = service.buildReceiptNote(draft);

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.receiptScanResult),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.receiptScanDescription,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (draft.amount != null)
                _infoRow(
                  context.l10n.amount,
                  service.formatAmountForDisplay(draft.amount!),
                ),
              if (draft.accountName != null)
                _infoRow(context.l10n.accountName, draft.accountName!),
              if (draft.accountNumber != null)
                _infoRow(context.l10n.accountId, draft.accountNumber!),
              if (draft.reference != null)
                _infoRow(context.l10n.referenceNo, draft.reference!),
              if (draft.walletLabel != null)
                _infoRow(context.l10n.walletLabel, draft.walletLabel!),
              if (draft.amount == null &&
                  draft.accountNumber == null &&
                  draft.reference == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.l10n.noRecognizableData,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 14),
              if (noteText.length > 10) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Note that will be added:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        noteText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                context.l10n.reviewAndEdit,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.apply),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    final m = ScaffoldMessenger.maybeOf(context);
    if (m == null) return;
    m
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? AppColors.error : AppColors.secondary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isScanning ? null : _onPressed,
      icon: _isScanning
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.document_scanner_outlined, size: 16),
      label: Text(
        _isScanning
            ? context.l10n.scanningReceipt
            : context.l10n.scanReceiptButton,
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
        foregroundColor: AppColors.primary,
      ),
    );
  }
}
