import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'receipt_draft.dart';

// Top-level function – must be outside any class so compute() can spawn it in
// a separate isolate. Performs all CPU-heavy image decoding, cropping, and
// enhancement; returns JPEG byte arrays ready for ML Kit OCR.
List<Uint8List> _processReceiptSegments(Uint8List originalBytes) {
  final decoded = img.decodeImage(originalBytes);
  if (decoded == null || decoded.width < 80 || decoded.height < 80) return [];

  final results = <Uint8List>[];

  void addSegment({
    required double x,
    required double y,
    required double w,
    required double h,
    double scale = 3.0,
    double contrast = 1.5,
    bool invertIfDark = false,
  }) {
    final cropX = (decoded.width * x).round();
    final cropY = (decoded.height * y).round();
    final cropW = (decoded.width * w).round().clamp(1, decoded.width - cropX);
    final cropH = (decoded.height * h).round().clamp(1, decoded.height - cropY);

    final cropped = img.copyCrop(
      decoded,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );
    var grayscale = img.grayscale(cropped);

    if (invertIfDark) {
      int totalLum = 0;
      final sampleY = (grayscale.height * 0.4).round();
      final sampleH = (grayscale.height * 0.2)
          .clamp(1.0, grayscale.height.toDouble())
          .round();
      for (var py = sampleY; py < sampleY + sampleH; py++) {
        for (var px = 0; px < grayscale.width; px++) {
          totalLum += grayscale.getPixel(px, py).r.toInt();
        }
      }
      final avgLum = totalLum / (grayscale.width * sampleH);
      if (avgLum < 128) grayscale = img.invert(grayscale);
    }

    final resized = img.copyResize(
      grayscale,
      width: (grayscale.width * scale).round(),
    );
    final enhanced = img.adjustColor(
      resized,
      contrast: contrast,
      brightness: 1.06,
      saturation: 0,
    );
    results.add(img.encodeJpg(enhanced, quality: 94));
  }

  addSegment(
    x: 0.0,
    y: 0.0,
    w: 1.0,
    h: 1.0,
    scale: 2.5,
    contrast: 1.5,
    invertIfDark: true,
  );
  addSegment(
    x: 0.0,
    y: 0.12,
    w: 1.0,
    h: 0.76,
    scale: 3.0,
    contrast: 1.6,
    invertIfDark: true,
  );

  return results;
}

class ReceiptScanService {
  const ReceiptScanService._();
  static const instance = ReceiptScanService._();

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Shows the image source picker (camera / gallery / file), runs dual-pass
  /// OCR on the chosen image, and returns a [ReceiptDraft] or `null` if the
  /// user cancelled or no image was picked.
  Future<ReceiptDraft?> scan(BuildContext context) async {
    final path = await pickImagePath(context);
    if (path == null || path.isEmpty) return null;

    return scanFromImagePath(path);
  }

  /// Runs OCR + parsing on an already selected image path.
  ///
  /// This lets callers handle image picking and loading UI separately.
  Future<ReceiptDraft?> scanFromImagePath(String path) async {
    if (path.isEmpty) return null;

    final rawText = await runOcrOnImagePath(path);
    var mergedText = rawText;

    final quickDraft = parseReceiptDraftSafely(
      rawText,
      sourceName: p.basename(path),
    );
    final needsCropPass =
        quickDraft == null ||
        !quickDraft.hasAnyAutofillField ||
        !_isPlausibleScannedAmount(quickDraft.amount) ||
        quickDraft.amountConfidence == ReceiptFieldConfidence.low ||
        quickDraft.amountConfidence == ReceiptFieldConfidence.unknown;

    if (needsCropPass) {
      final croppedText = await runCroppedOcrPass(path);
      if (croppedText.isNotEmpty) {
        mergedText = '$rawText\n$croppedText';
      }
    }

    return parseReceiptDraftSafely(mergedText, sourceName: p.basename(path));
  }

  // ─── Image picking ────────────────────────────────────────────────────────

  Future<String?> pickImagePath(BuildContext context) async {
    final source = await showReceiptImageSourcePicker(context);
    if (source == null) return null;

    if (source == ReceiptImageSource.file) {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'heic'],
        withData: true,
      );
      final file = picked?.files.single;
      if (file == null) return null;
      if (file.path != null && file.path!.isNotEmpty) return file.path;

      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) return null;

      final tempDir = await getTemporaryDirectory();
      final ext = p.extension(file.name).isNotEmpty
          ? p.extension(file.name)
          : '.jpg';
      final tempPath = p.join(
        tempDir.path,
        'receipt_${DateTime.now().millisecondsSinceEpoch}$ext',
      );
      await File(tempPath).writeAsBytes(bytes, flush: true);
      return tempPath;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source == ReceiptImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 90,
    );
    return file?.path;
  }

  Future<ReceiptImageSource?> showReceiptImageSourcePicker(
    BuildContext context,
  ) {
    return showModalBottomSheet<ReceiptImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Use Camera'),
              subtitle: const Text('Take a photo of the receipt'),
              onTap: () => Navigator.of(ctx).pop(ReceiptImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pick from Gallery'),
              subtitle: const Text('Choose existing screenshot/photo'),
              onTap: () => Navigator.of(ctx).pop(ReceiptImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Browse Files'),
              subtitle: const Text('Pick from any folder'),
              onTap: () => Navigator.of(ctx).pop(ReceiptImageSource.file),
            ),
          ],
        ),
      ),
    );
  }

  // ─── OCR ─────────────────────────────────────────────────────────────────

  Future<String> runOcrOnImagePath(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognized = await recognizer.processImage(inputImage);
      return recognized.text;
    } finally {
      await recognizer.close();
    }
  }

  Future<String> runCroppedOcrPass(String originalPath) async {
    try {
      final originalBytes = await File(originalPath).readAsBytes();

      // Offload all CPU-heavy image decoding, cropping, and enhancement to a
      // background isolate so the UI spinner keeps animating uninterrupted.
      final segmentBytes = await compute(
        _processReceiptSegments,
        originalBytes,
      );
      if (segmentBytes.isEmpty) return '';

      final segmentTexts = <String>[];
      for (final jpegBytes in segmentBytes) {
        final text = await _runOcrOnTempImageBytes(jpegBytes, 'seg');
        if (text.trim().isNotEmpty) segmentTexts.add(text.trim());
      }

      return segmentTexts.join('\n');
    } catch (error, stackTrace) {
      debugPrint('Receipt crop OCR failed: $error\n$stackTrace');
      return '';
    }
  }

  Future<String> _runOcrOnTempImageBytes(
    Uint8List jpegBytes,
    String prefix,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final cropPath = p.join(
      tempDir.path,
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await File(cropPath).writeAsBytes(jpegBytes);
    return runOcrOnImagePath(cropPath);
  }

  // ─── Draft parsing ────────────────────────────────────────────────────────

  ReceiptDraft? parseReceiptDraftSafely(String rawText, {String? sourceName}) {
    try {
      return _parseReceiptDraft(rawText, sourceName: sourceName);
    } catch (error, stackTrace) {
      debugPrint('Receipt parse crashed, using fallback: $error\n$stackTrace');
      final fallbackText = [
        if (sourceName != null && sourceName.trim().isNotEmpty) sourceName,
        rawText,
      ].join('\n');
      try {
        return _buildFallbackDraftFromRaw(fallbackText);
      } catch (fallbackError, fallbackStackTrace) {
        debugPrint(
          'Receipt fallback parse failed: $fallbackError\n$fallbackStackTrace',
        );
        return null;
      }
    }
  }

  ReceiptDraft _buildFallbackDraftFromRaw(String text) {
    final normalized = text.trim();
    debugPrint('=== Receipt Parse Debug ===');
    debugPrint(
      'Normalized OCR text (first 500 chars): ${normalized.substring(0, (normalized.length < 500 ? normalized.length : 500))}',
    );

    final walletSelection = _detectWalletSelection(normalized);
    final flowDirection = _detectFlowDirection(normalized);
    final amountData = _extractLikelyAmountFromText(normalized);
    final accountData = _extractLikelyAccountNumber(normalized);
    final accountNameData = _extractLikelyAccountName(normalized);
    final referenceData = _extractLikelyReference(normalized);

    debugPrint(
      'Extracted: Amount=${amountData.value} (${amountData.confidence}), Account=${accountData.value} (${accountData.confidence}), Name=${accountNameData.value} (${accountNameData.confidence}), Ref=${referenceData.value} (${referenceData.confidence})',
    );
    debugPrint('Wallet=$walletSelection, Flow=$flowDirection');

    return ReceiptDraft(
      amount: amountData.value,
      amountConfidence: amountData.confidence,
      accountNumber: accountData.value,
      accountConfidence: accountData.confidence,
      accountName: accountNameData.value,
      accountNameConfidence: accountNameData.confidence,
      reference: referenceData.value,
      referenceConfidence: referenceData.confidence,
      walletSelection: walletSelection,
      flowDirection: flowDirection,
      rawOcrPreview: normalized,
    );
  }

  ReceiptDraft? _parseReceiptDraft(String rawText, {String? sourceName}) {
    final normalized = rawText.trim();
    if (normalized.isEmpty) return null;

    final combinedText = sourceName == null || sourceName.trim().isEmpty
        ? normalized
        : '$sourceName\n$normalized';
    final safeText = combinedText
        .replaceAll('\u0000', ' ')
        .replaceAll(RegExp(r'\uFFFD'), ' ')
        .trim();

    ({double? value, ReceiptFieldConfidence confidence}) amountData = (
      value: null,
      confidence: ReceiptFieldConfidence.unknown,
    );
    ({String? value, ReceiptFieldConfidence confidence}) accountData = (
      value: null,
      confidence: ReceiptFieldConfidence.unknown,
    );
    ({String? value, ReceiptFieldConfidence confidence}) referenceData = (
      value: null,
      confidence: ReceiptFieldConfidence.unknown,
    );
    ({String? value, ReceiptFieldConfidence confidence}) accountNameData = (
      value: null,
      confidence: ReceiptFieldConfidence.unknown,
    );
    ReceiptWalletSelection? walletSelection;
    ReceiptFlowDirection? flowDirection;

    try {
      amountData = _extractLikelyAmountFromText(safeText);
    } catch (e, s) {
      debugPrint('Receipt parse amount failed: $e\n$s');
    }
    try {
      accountData = _extractLikelyAccountNumber(safeText);
    } catch (e, s) {
      debugPrint('Receipt parse account failed: $e\n$s');
    }
    try {
      referenceData = _extractLikelyReference(safeText);
    } catch (e, s) {
      debugPrint('Receipt parse reference failed: $e\n$s');
    }
    try {
      walletSelection = _detectWalletSelection(safeText);
    } catch (e, s) {
      debugPrint('Receipt parse wallet failed: $e\n$s');
    }
    try {
      flowDirection = _detectFlowDirection(safeText);
    } catch (e, s) {
      debugPrint('Receipt parse flow failed: $e\n$s');
    }
    try {
      accountNameData = _extractLikelyAccountName(safeText);
    } catch (e, s) {
      debugPrint('Receipt parse account name failed: $e\n$s');
    }

    return ReceiptDraft(
      amount: amountData.value,
      amountConfidence: amountData.confidence,
      accountNumber: accountData.value,
      accountConfidence: accountData.confidence,
      accountName: accountNameData.value,
      accountNameConfidence: accountNameData.confidence,
      reference: referenceData.value,
      referenceConfidence: referenceData.confidence,
      walletSelection: walletSelection,
      flowDirection: flowDirection,
      rawOcrPreview: safeText,
    );
  }

  // ─── Detection helpers ────────────────────────────────────────────────────

  ReceiptFlowDirection? _detectFlowDirection(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('cash out') ||
        lower.contains('withdraw') ||
        lower.contains('withdrawal') ||
        lower.contains('sent money') ||
        lower.contains('sent to') ||
        lower.contains('purchased from') ||
        lower.contains('purchase')) {
      return ReceiptFlowDirection.outflow;
    }
    if (lower.contains('cash in') ||
        lower.contains('cashin') ||
        lower.contains('received') ||
        lower.contains('sent by')) {
      return ReceiptFlowDirection.inflow;
    }
    return null;
  }

  ReceiptWalletSelection? _detectWalletSelection(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('maya') || lower.contains('paymaya')) {
      return ReceiptWalletSelection.maya;
    }
    if (lower.contains('gcash') || lower.contains('g-cash')) {
      return ReceiptWalletSelection.gcash;
    }
    if (lower.contains('shopeepay') ||
        lower.contains('shopee pay') ||
        lower.contains('seabank')) {
      return ReceiptWalletSelection.maya;
    }
    return null;
  }

  // ─── Amount extraction ────────────────────────────────────────────────────

  ({double? value, ReceiptFieldConfidence confidence})
  _extractLikelyAmountFromText(String text) {
    final flat = text
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'  +'), ' ')
        .trim();
    debugPrint(
      '[Amount] Input text sample: ${flat.substring(0, (flat.length < 200 ? flat.length : 200))}',
    );

    final candidates = <({double value, int score})>[];
    const decimalAmt = r'\d{1,3}(?:,\d{3})*\.\d{1,2}';

    // 0a. OCR misread -PI00.00 (₱ → P, 1 → I)
    final piMisreadPattern = RegExp(
      r'-PI(\d{2,}\.\d{1,2})',
      caseSensitive: false,
    );
    for (final m in piMisreadPattern.allMatches(flat)) {
      final corrected = '1${m.group(1)!}';
      final parsed = double.tryParse(corrected.replaceAll(',', ''));
      if (_isPlausibleScannedAmount(parsed)) {
        debugPrint('[Amount] PI-misread corrected: $corrected');
        candidates.add((value: parsed!, score: 13));
      }
    }

    // 0. Simple minus+currency
    final simpleMinusPattern = RegExp(
      '-\\s*(?:pi|p|php|₱)?\\s*($decimalAmt)',
      caseSensitive: false,
    );
    for (final m in simpleMinusPattern.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        candidates.add((value: parsed!, score: 13));
      }
    }

    // 1. Minus-prefixed currency (Maya format: -₱100.00)
    final minusCurrencyPattern = RegExp(
      '-\\s*(?:php|₱|PI|P)\\s*($decimalAmt)',
      caseSensitive: false,
    );
    for (final m in minusCurrencyPattern.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        candidates.add((value: parsed!, score: 13));
      }
    }

    // 2. Currency prefix: PHP / ₱ / P
    final currencyPattern = RegExp(
      '(?:php|₱|PI|(?<![a-zA-Z])P)\\s*($decimalAmt)',
      caseSensitive: false,
    );
    for (final m in currencyPattern.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        final score = m.group(1)!.contains(',') ? 14 : 12;
        candidates.add((value: parsed!, score: score));
      }
    }

    // 2b. Keyword label on next line
    final lineList = text.split(RegExp(r'[\r\n]+'));
    for (var i = 0; i < lineList.length - 1; i++) {
      final lineLower = lineList[i].toLowerCase().trim();
      final isAmountLabel =
          lineLower == 'amount' ||
          lineLower == 'total amount' ||
          lineLower == 'total amount sent' ||
          lineLower == 'total' ||
          lineLower == 'grand total' ||
          lineLower == 'net amount' ||
          lineLower == 'subtotal' ||
          lineLower == 'payment' ||
          lineLower == 'paid' ||
          lineLower == 'charge' ||
          lineLower == 'price' ||
          lineLower == 'fee' ||
          lineLower == 'transaction amount' ||
          lineLower.startsWith('amount:') ||
          lineLower.startsWith('total amount:') ||
          lineLower.startsWith('total:') ||
          lineLower.startsWith('grand total:') ||
          lineLower.startsWith('subtotal:') ||
          lineLower.startsWith('payment:') ||
          lineLower.startsWith('paid:') ||
          lineLower.startsWith('net amount:') ||
          lineLower.startsWith('transaction amount:');
      if (isAmountLabel) {
        for (var j = i + 1; j <= i + 2 && j < lineList.length; j++) {
          final nextLine = lineList[j].trim();
          final nextLineAmountTokens = RegExp(
            r'(?:php|₱|P)?\s*(\d{1,3}(?:,\d{3})*\.\d{1,2})',
            caseSensitive: false,
          );
          for (final token in nextLineAmountTokens.allMatches(nextLine)) {
            final parsed = _parseAmountToken(token.group(1));
            if (_isPlausibleScannedAmount(parsed)) {
              candidates.add((value: parsed!, score: 13));
              break;
            }
          }
        }
      }
    }

    // 3. Keyword + amount on same line
    final keywordSameLine = RegExp(
      '(?:sent|total\\s+amount\\s+sent|transaction\\s+amount|grand\\s+total|net\\s+amount|total\\s+amount|subtotal|total|amount|payment|paid|charge|price|fee)\\s{0,4}[:\\-]?\\s{0,4}(?:php|₱|P)?\\s{0,2}(\\d{1,3}(?:,\\d{3})*\\.\\d{1,2})',
      caseSensitive: false,
    );
    for (final m in keywordSameLine.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        candidates.add((value: parsed!, score: 10));
      }
    }

    // 4. Comma-formatted amounts (e.g. 5,000.00)
    final commaFormatted = RegExp(r'\b(\d{1,3}(?:,\d{3})+\.\d{1,2})\b');
    for (final m in commaFormatted.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        candidates.add((value: parsed!, score: 8));
      }
    }

    if (candidates.isNotEmpty) {
      candidates.sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        return b.value.compareTo(a.value);
      });
      final top = candidates.first;
      debugPrint('[Amount] Found with score ${top.score}: ${top.value}');
      final confidence = switch (top.score) {
        >= 12 => ReceiptFieldConfidence.high,
        >= 10 => ReceiptFieldConfidence.medium,
        _ => ReceiptFieldConfidence.low,
      };
      return (value: top.value, confidence: confidence);
    }

    // 5. Last resort: any decimal number
    final generic = RegExp(r'\b(\d{1,3}(?:,\d{3})*\.\d{2})\b');
    double? best;
    for (final m in generic.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (!_isPlausibleScannedAmount(parsed)) continue;
      final parsedValue = parsed!;
      if (parsedValue >= 2000 &&
          parsedValue <= 2100 &&
          m.group(1)!.endsWith('.00')) {
        continue;
      }
      if (best == null || parsedValue > best) best = parsedValue;
    }
    if (best != null) {
      debugPrint('[Amount] Found (generic fallback): $best');
      return (value: best, confidence: ReceiptFieldConfidence.low);
    }
    debugPrint('[Amount] Not found');
    return (value: null, confidence: ReceiptFieldConfidence.unknown);
  }

  double? _parseAmountToken(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final normalized = _normalizeOcrDigits(
      raw,
    ).replaceAll(' ', '').replaceAll('P', '').replaceAll('p', '');
    final cleaned = normalized
        .replaceAll(RegExp(r'[^0-9\.,]'), '')
        .replaceAll(',', '')
        .trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  bool _isPlausibleScannedAmount(double? value) {
    if (value == null || !value.isFinite) return false;
    return value >= 1 && value <= 500000;
  }

  String _normalizeOcrDigits(String value) {
    return value
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('Q', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('|', '1')
        .replaceAll('S', '5')
        .replaceAll('s', '5')
        .replaceAll('B', '8');
  }

  // ─── Account extraction ───────────────────────────────────────────────────

  ({String? value, ReceiptFieldConfidence confidence})
  _extractLikelyAccountNumber(String text) {
    // 0. Destination label (Maya Sent Money)
    final destinationPattern = RegExp(
      r'destination[:\s]+(\+?6?3?9\d{2}[\s-]?\d{3}[\s-]?\d{4}|0?9\d{9})',
      caseSensitive: false,
    );
    final destMatch = destinationPattern.firstMatch(text);
    if (destMatch != null) {
      final raw = destMatch.group(1)!.replaceAll(RegExp(r'[^0-9]'), '');
      final normalized = _normalizeAccountDigits(raw);
      if (normalized != null) {
        return (value: normalized, confidence: ReceiptFieldConfidence.high);
      }
    }

    // Source number to skip
    final sourceNumPattern = RegExp(
      r'(?:source|my wallet)[^\n]{0,40}(\+63[\s-]9\d{2}[\s-]\d{3}[\s-]\d{4}|\+639\d{9}|\b0?9\d{9}\b)',
      caseSensitive: false,
    );
    final sourceNumMatch = sourceNumPattern.firstMatch(text);
    final sourceNumber = sourceNumMatch
        ?.group(1)!
        .replaceAll(RegExp(r'[^0-9]'), '');

    final hasMayaSentLayout =
        text.toLowerCase().contains('destination') ||
        text.toLowerCase().contains('sent money');

    if (hasMayaSentLayout) {
      final intlCompactFirst = RegExp(r'\+639\d{9}');
      for (final m in intlCompactFirst.allMatches(text)) {
        final digits = m.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
        if (sourceNumber != null && digits == sourceNumber) continue;
        final normalized = _normalizeAccountDigits(digits);
        if (normalized != null) {
          return (value: normalized, confidence: ReceiptFieldConfidence.high);
        }
      }
    }

    // 1. International format with spaces: +63 975 307 9315
    final intlSpaced = RegExp(r'\+63[\s-]?9\d{2}[\s-]\d{3}[\s-]\d{4}');
    for (final m in intlSpaced.allMatches(text)) {
      final digits = m.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      if (sourceNumber != null && digits == sourceNumber) continue;
      final normalized = _normalizeAccountDigits(digits);
      if (normalized != null) {
        return (value: normalized, confidence: ReceiptFieldConfidence.high);
      }
    }

    // 2. International compact: +639753079315
    final intlCompact = RegExp(r'\+639\d{9}');
    for (final m in intlCompact.allMatches(text)) {
      final digits = m.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      if (sourceNumber != null && digits == sourceNumber) continue;
      final normalized = _normalizeAccountDigits(digits);
      if (normalized != null) {
        return (value: normalized, confidence: ReceiptFieldConfidence.high);
      }
    }

    // 3. Local format with spaces: 0975 307 9315
    final localPhone = RegExp(r'\b0?9\d{2}[\s-]?\d{3}[\s-]?\d{4}\b');
    final localMatch = localPhone.firstMatch(text);
    if (localMatch != null) {
      final digits = localMatch.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      final normalized = _normalizeAccountDigits(digits);
      if (normalized != null) {
        return (value: normalized, confidence: ReceiptFieldConfidence.medium);
      }
    }

    // 4. Contextual keyword
    final contextualPattern = RegExp(
      r'(?:mobile|account|number|recipient|to|from|sent\s+(?:php|₱)?\s*[\d.]+\s+to)[^0-9]{0,20}(\+?6?3?9\d{2}[\s-]?\d{3}[\s-]?\d{4}|0?9\d{9})',
      caseSensitive: false,
    );
    final contextMatch = contextualPattern.firstMatch(text);
    if (contextMatch != null) {
      final raw = contextMatch.group(1) ?? '';
      final normalized = _normalizeAccountDigits(
        raw.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (normalized != null) {
        return (value: normalized, confidence: ReceiptFieldConfidence.high);
      }
    }

    // 5. Maya QR Payment ID
    final paymentIdPattern = RegExp(
      r'payment\s+id[:\s]+([A-Z0-9]{4}(?:\s+[A-Z0-9]{4}){2}|[A-Z0-9]{12,16})',
      caseSensitive: false,
    );
    final paymentIdMatch = paymentIdPattern.firstMatch(text);
    if (paymentIdMatch != null) {
      final value = paymentIdMatch
          .group(1)!
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ')
          .toUpperCase();
      if (!value.startsWith('MAYA ')) {
        return (value: value, confidence: ReceiptFieldConfidence.high);
      }
    }

    // 5a. OCR two-column Payment ID fallback
    final lower = text.toLowerCase();
    if (lower.contains('payment id')) {
      final referenceCanonical = _extractLikelyReference(
        text,
      ).value?.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      final spacedIdPattern = RegExp(
        r'\b([A-Z0-9]{4}(?:\s+[A-Z0-9]{4}){2})\b',
        caseSensitive: false,
      );
      final compactIdPattern = RegExp(r'\b([A-Z0-9]{12,24})\b');
      final candidates = <({String value, int start})>[];

      for (final m in spacedIdPattern.allMatches(text)) {
        final token = (m.group(1) ?? '').trim();
        final canonical = token.replaceAll(RegExp(r'\s+'), '').toUpperCase();
        if (canonical.length < 12 || canonical.length > 24) continue;
        if (!RegExp(r'[A-Z]').hasMatch(canonical) ||
            !RegExp(r'\d').hasMatch(canonical)) {
          continue;
        }
        if (canonical.startsWith('MAYA')) continue;
        if (referenceCanonical != null && canonical == referenceCanonical) {
          continue;
        }
        candidates.add((value: token.toUpperCase(), start: m.start));
      }

      for (final m in compactIdPattern.allMatches(text.toUpperCase())) {
        final token = (m.group(1) ?? '').trim();
        if (token.length < 12 || token.length > 24) continue;
        if (!RegExp(r'[A-Z]').hasMatch(token) ||
            !RegExp(r'\d').hasMatch(token)) {
          continue;
        }
        if (token.startsWith('MAYA')) continue;
        if (referenceCanonical != null && token == referenceCanonical) continue;
        if (token.startsWith('SCALED') || token.startsWith('IMG')) continue;
        candidates.add((value: token, start: m.start));
      }

      if (candidates.isNotEmpty) {
        final paymentPos = lower.indexOf('payment id');
        candidates.sort((a, b) {
          final aAfter = a.start >= paymentPos;
          final bAfter = b.start >= paymentPos;
          if (aAfter != bAfter) return aAfter ? -1 : 1;
          return (a.start - paymentPos).abs().compareTo(
            (b.start - paymentPos).abs(),
          );
        });
        final best = candidates.first.value.replaceAll(RegExp(r'\s+'), ' ');
        return (value: best, confidence: ReceiptFieldConfidence.medium);
      }
    }

    // 6. Merchant ID
    final merchantIdPattern = RegExp(
      r'merchant\s+id[:\s]+(\d{8,20})',
      caseSensitive: false,
    );
    final merchantIdMatch = merchantIdPattern.firstMatch(text);
    if (merchantIdMatch != null) {
      return (
        value: merchantIdMatch.group(1)!.trim(),
        confidence: ReceiptFieldConfidence.medium,
      );
    }

    // 6a. Merchant ID two-column fallback
    if (text.toLowerCase().contains('merchant id')) {
      final longDigits = RegExp(r'\b\d{12,20}\b');
      for (final m in longDigits.allMatches(text)) {
        final start = m.start > 50 ? m.start - 50 : 0;
        final context = text.substring(start, m.start).toLowerCase();
        if (!context.contains('reference id') &&
            !context.contains('payment id') &&
            !context.contains('invoice')) {
          return (
            value: m.group(0)!,
            confidence: ReceiptFieldConfidence.medium,
          );
        }
      }
    }

    // 7. Filename phone fallback
    final filenamePhone = RegExp(
      r'(?:GCash|Maya|Pay)[^0-9]*(63)?9(\d{9})',
      caseSensitive: false,
    );
    final fnMatch = filenamePhone.firstMatch(text);
    if (fnMatch != null) {
      final prefix = fnMatch.group(1) ?? '';
      final rest = fnMatch.group(2) ?? '';
      final normalized = _normalizeAccountDigits(
        '${prefix}9$rest'.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (normalized != null) {
        return (value: normalized, confidence: ReceiptFieldConfidence.low);
      }
    }

    return (value: null, confidence: ReceiptFieldConfidence.unknown);
  }

  String? _normalizeAccountDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('63') && digits.length == 12) {
      return '0${digits.substring(2)}';
    }
    if (digits.length == 10 && digits.startsWith('9')) return '0$digits';
    if (digits.length >= 10 && digits.length <= 13) return digits;
    return null;
  }

  // ─── Reference extraction ─────────────────────────────────────────────────

  ({String? value, ReceiptFieldConfidence confidence}) _extractLikelyReference(
    String text,
  ) {
    debugPrint('[Reference] Looking for Maya Reference ID pattern...');

    // 1a. Standalone Maya-style reference: 4-char groups "1D6D BA77 DA29"
    final mayaStandalonePattern = RegExp(
      r'\b([A-Z0-9]{4} [A-Z0-9]{4} [A-Z0-9]{4})\b',
      caseSensitive: false,
    );
    final mayaStandaloneMatch = mayaStandalonePattern.firstMatch(text);
    if (mayaStandaloneMatch != null) {
      final value = mayaStandaloneMatch.group(1)!.trim().replaceAll(' ', '');
      debugPrint('[Reference] Maya standalone pattern: $value');
      return (value: value, confidence: ReceiptFieldConfidence.high);
    }

    // 1a2. Compact Maya reference: "Reference ID  1D6DBA77DA29"
    final mayaCompactPattern = RegExp(
      r'reference\s+id\s+([A-Z0-9]{9,15})(?:\s|$)',
      caseSensitive: false,
    );
    final mayaCompactMatch = mayaCompactPattern.firstMatch(text);
    if (mayaCompactMatch != null) {
      final value = mayaCompactMatch.group(1)!.trim();
      debugPrint('[Reference] Maya compact pattern: $value');
      return (value: value, confidence: ReceiptFieldConfidence.high);
    }

    // 1b. "Reference ID" same line
    final referenceIdSameLine = RegExp(
      r'reference\s+(?:id|no)[:\s]+([A-Z0-9][A-Z0-9 ]{3,24}?)(?=\s*(?:Sent|money|to|Share|$|\n))',
      caseSensitive: false,
    );
    final refSameLineMatch = referenceIdSameLine.firstMatch(text);
    if (refSameLineMatch != null) {
      final raw = refSameLineMatch.group(1)?.trim() ?? '';
      final value = raw.replaceAll(RegExp(r'\s+'), '');
      final isCommon = RegExp(
        r'^(Sent|money|to|Share|Completed)$',
        caseSensitive: false,
      ).hasMatch(value);
      if (value.length >= 6 &&
          value.length <= 30 &&
          RegExp(r'^[A-Z0-9]+$').hasMatch(value) &&
          !isCommon) {
        debugPrint('[Reference] Maya same-line pattern: $value');
        return (value: value, confidence: ReceiptFieldConfidence.high);
      }
    }

    // 1c. "Reference ID" next line
    final referenceIdNextLine = RegExp(
      r'reference\s+(?:id|no)\s*\n\s*([A-Z0-9][A-Z0-9 ]{3,24})',
      caseSensitive: false,
    );
    final refNextLineMatch = referenceIdNextLine.firstMatch(text);
    if (refNextLineMatch != null) {
      final raw = refNextLineMatch.group(1)?.trim() ?? '';
      final value = raw.replaceAll(RegExp(r'\s+'), '');
      if (value.length >= 6 &&
          value.length <= 30 &&
          RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
        debugPrint('[Reference] Maya next-line pattern: $value');
        return (value: value, confidence: ReceiptFieldConfidence.high);
      }
    }

    // 2. "Ref. No." pattern (SMS receipts)
    final refNoPattern = RegExp(
      r'ref\.?\s+no\.[\s:.-]*([\d][\d\s\-]{7,})',
      caseSensitive: false,
    );
    final refNoMatch = refNoPattern.firstMatch(text);
    if (refNoMatch != null) {
      final raw = refNoMatch.group(1) ?? '';
      final allDigits = RegExp(r'\d+')
          .allMatches(raw.split(RegExp(r'[A-Za-z]')).first)
          .map((m) => m.group(0)!)
          .join();
      if (allDigits.length >= 8) {
        debugPrint('[Reference] Found via Ref. No. pattern: $allDigits');
        return (value: allDigits, confidence: ReceiptFieldConfidence.high);
      }
    }

    // 3. Generic ref keyword
    final refKeywordPattern = RegExp(
      r'(?:ref(?:erence)?(?:\s*no\.?|\s*num(?:ber)?|\s*#|\s*id)?|transaction\s*(?:no\.?|id|num(?:ber)?)?|trx\s*(?:no\.?|id)?|trace\s*(?:no\.?|num(?:ber)?)?|control\s*(?:no\.?|num(?:ber)?)?|receipt\s*(?:no\.?|num(?:ber)?)?|or\s*(?:no\.?|num(?:ber)?)?|o\.r\.?\s*(?:no\.?|num(?:ber)?)?|txn\s*(?:no\.?|id)?|approval\s*(?:no\.?|code)?|auth(?:orization)?\s*(?:no\.?|code)?|rrn|stan)[\s:.-]*([\d][\d\s\-]{7,})',
      caseSensitive: false,
    );
    final refMatch = refKeywordPattern.firstMatch(text);
    if (refMatch != null) {
      final raw = refMatch.group(1) ?? '';
      final allDigits = RegExp(r'\d+')
          .allMatches(raw.split(RegExp(r'[A-Za-z]')).first)
          .map((m) => m.group(0)!)
          .join();
      if (allDigits.length >= 8) {
        debugPrint('[Reference] Found via keyword pattern: $allDigits');
        return (value: allDigits, confidence: ReceiptFieldConfidence.high);
      }
    }

    // 4. Alphanumeric ref after keyword
    final alphaRefPattern = RegExp(
      r'\b(?:reference|ref)\b(?:\s*(?:no\.?|num(?:ber)?|#|id))?[\s:.-]*([A-Z0-9][A-Z0-9\-]{5,})',
      caseSensitive: false,
    );
    final alphaMatch = alphaRefPattern.firstMatch(text);
    if (alphaMatch != null) {
      final value = alphaMatch.group(1)?.trim();
      final isCommonWord = RegExp(
        r'^(sent|money|share|initial|capital|completed|from|to|help|erence)$',
        caseSensitive: false,
      ).hasMatch(value ?? '');
      if (value != null && value.isNotEmpty && !isCommonWord) {
        debugPrint('[Reference] Found via alpha pattern: $value');
        return (value: value, confidence: ReceiptFieldConfidence.medium);
      }
    }

    // 5. Long digit-only sequence (12+ digits)
    final longDigits = RegExp(r'\b(\d{12,})\b');
    for (final longMatch in longDigits.allMatches(text)) {
      final value = longMatch.group(1)!;
      final isPhonePatternStart =
          value.startsWith('0') ||
          value.startsWith('63') ||
          value.startsWith('639');
      final isPhoneLength = value.length >= 10 && value.length <= 13;
      if (isPhonePatternStart || isPhoneLength) continue;
      final isYearLike =
          value.startsWith('2') &&
          ((value.length == 8 && int.tryParse(value.substring(4)) != null) ||
              (value.length == 10 && value.endsWith('00')));
      if (isYearLike) continue;
      if (value.length <= 20) {
        return (value: value, confidence: ReceiptFieldConfidence.low);
      }
    }

    // 6. Standalone mixed alphanumeric (9–15 chars, letters + digits)
    final standaloneAlphaNum = RegExp(
      r'\b([A-Z0-9]{9,15})\b',
      caseSensitive: false,
    );
    final commonWords = RegExp(
      r'^(completed|destination|transaction|reference|my wallet|sent|money|details|initial|capital|contacts|wallet|source|share|add)$',
      caseSensitive: false,
    );
    for (final m in standaloneAlphaNum.allMatches(text)) {
      final token = m.group(1)!;
      if (!RegExp(r'[A-Za-z]').hasMatch(token) ||
          !RegExp(r'[0-9]').hasMatch(token)) {
        continue;
      }
      if (token.startsWith('639') || token.startsWith('09')) continue;
      if (commonWords.hasMatch(token)) continue;
      debugPrint('[Reference] Found via standalone alphanumeric: $token');
      return (
        value: token.toUpperCase(),
        confidence: ReceiptFieldConfidence.medium,
      );
    }

    debugPrint('[Reference] Not found');
    return (value: null, confidence: ReceiptFieldConfidence.unknown);
  }

  // ─── Account name extraction ──────────────────────────────────────────────

  ({String? value, ReceiptFieldConfidence confidence})
  _extractLikelyAccountName(String text) {
    final purchasedFromTitle = RegExp(
      r'purchased\s+from',
      caseSensitive: false,
    );
    if (purchasedFromTitle.hasMatch(text)) {
      final sameLinePattern = RegExp(
        r'[-–]\s*[₱P]\s*[\d,]+\.?\d*\s+([A-Z0-9][A-Z0-9&\.]{0,29}(?:\s+[A-Z0-9&\.]{1,20}){0,3}?)\s+(?:Paid\s+using|You\s+may)',
        caseSensitive: false,
      );
      final sameLineMatch = sameLinePattern.firstMatch(text);
      if (sameLineMatch != null) {
        final name = sameLineMatch.group(1)?.trim();
        if (name != null &&
            name.isNotEmpty &&
            name.length >= 2 &&
            name.length <= 50) {
          return (value: name, confidence: ReceiptFieldConfidence.high);
        }
      }

      final purchasedFromInline = RegExp(
        r'purchased\s+from[^A-Za-z0-9]{0,12}([A-Za-z][A-Za-z0-9&\.\-]{1,39})(?:\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|\d{4}|paid\s+using|merchant\s+id|you\s+may)|$)',
        caseSensitive: false,
      );
      final purchasedInlineMatch = purchasedFromInline.firstMatch(text);
      if (purchasedInlineMatch != null) {
        final name = purchasedInlineMatch.group(1)?.trim();
        if (name != null &&
            name.isNotEmpty &&
            name.length >= 2 &&
            name.length <= 50) {
          return (value: name, confidence: ReceiptFieldConfidence.high);
        }
      }

      final lines = text.split(RegExp(r'[\r\n]+'));
      for (var i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        final nextLine = lines[i + 1].trim();
        final isAmountLine = RegExp(r'^[-–]\s*[₱P]?\s*\d').hasMatch(line);
        if (isAmountLine && nextLine.isNotEmpty && nextLine.length <= 50) {
          final isDate = RegExp(
            r'\d{4}|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\b',
            caseSensitive: false,
          ).hasMatch(nextLine);
          final isUiText = RegExp(
            r'completed|confirm|paid|fee|reference|payment|invoice|merchant|bank|qr',
            caseSensitive: false,
          ).hasMatch(nextLine);
          if (!isDate && !isUiText && RegExp(r'[A-Za-z]').hasMatch(nextLine)) {
            return (value: nextLine, confidence: ReceiptFieldConfidence.high);
          }
        }
      }
    }

    // GCash header format: name followed by phone on next line
    final lineList = text.split(RegExp(r'[\r\n]+'));
    for (var i = 0; i < lineList.length - 1; i++) {
      final line = lineList[i].trim();
      final nextLine = lineList[i + 1].trim();
      final hasPhoneNext = RegExp(r'\+?63|09\d{2}').hasMatch(nextLine);
      final hasCurrency = RegExp(r'[₱P\-][\s]?\d').hasMatch(line);
      final looksLikeAmount = line.contains(RegExp(r'^\s*[-₱PI]'));
      final isUiLabel = RegExp(
        r'^(my wallet|source|destination|transaction|reference|completed|add to contacts|get help|share|sent money)$',
        caseSensitive: false,
      ).hasMatch(line);
      if (!looksLikeAmount &&
          !hasCurrency &&
          !isUiLabel &&
          hasPhoneNext &&
          line.isNotEmpty &&
          line.length >= 2 &&
          line.length <= 100 &&
          RegExp(r'[A-Za-z]').hasMatch(line) &&
          (line.contains('.') ||
              line.contains('*') ||
              RegExp(r'\s').hasMatch(line))) {
        return (value: line, confidence: ReceiptFieldConfidence.high);
      }
    }

    // SMS: "sent PHP 100.00 to JO*E A. +639..."
    final toPattern = RegExp(
      r'(?:sent\s+(?:php|₱)?[\d.\s]+)?to\s+([A-Za-z\s\.\*\-]+?)(?:\s+\+?63|\s+09)',
      caseSensitive: false,
    );
    final toMatch = toPattern.firstMatch(text);
    if (toMatch != null) {
      final name = toMatch.group(1)?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name.length >= 2 &&
          name.length <= 100 &&
          RegExp(r'[A-Za-z]').hasMatch(name)) {
        return (value: name, confidence: ReceiptFieldConfidence.high);
      }
    }

    // "received from", "from NAME"
    final fromPattern = RegExp(
      r'(?:received\s+from|cash\s+from|payment\s+from|transfer\s+from|money\s+from|-\s+from|from)\s+([A-Za-z\s\.\*\-]{2,}?)(?:\s*[\+0-9]|\.|$|\n)',
      caseSensitive: false,
    );
    final fromMatch = fromPattern.firstMatch(text);
    if (fromMatch != null) {
      final name = fromMatch.group(1)?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name.length >= 2 &&
          name.length <= 100 &&
          RegExp(r'[A-Za-z]').hasMatch(name)) {
        return (value: name, confidence: ReceiptFieldConfidence.high);
      }
    }

    // "recipient:", "account holder:", "account name:"
    final recipientPattern = RegExp(
      r'(?:recipient|account\s+holder|account\s+name|full\s+name|from)[\s:.-]+([A-Za-z\s\.\*\-]{2,}?)(?:\s*[\+0-9]|$)',
      caseSensitive: false,
    );
    final recipientMatch = recipientPattern.firstMatch(text);
    if (recipientMatch != null) {
      final name = recipientMatch.group(1)?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name.length >= 2 &&
          name.length <= 100 &&
          RegExp(r'[A-Za-z]').hasMatch(name)) {
        return (value: name, confidence: ReceiptFieldConfidence.medium);
      }
    }

    // Name before phone number
    final beforePhonePattern = RegExp(
      r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)\s*[\*\.]?\s*(?:A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z)[\.\s]*(?:\+?639|09)\d',
      caseSensitive: true,
    );
    final beforePhoneMatch = beforePhonePattern.firstMatch(text);
    if (beforePhoneMatch != null) {
      final name = beforePhoneMatch.group(1)?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name.length >= 2 &&
          name.length <= 100) {
        return (value: name, confidence: ReceiptFieldConfidence.medium);
      }
    }

    return (value: null, confidence: ReceiptFieldConfidence.unknown);
  }

  // ─── Utility ──────────────────────────────────────────────────────────────

  String formatAmountForInput(double amount) {
    if (!amount.isFinite || amount <= 0) return '';
    try {
      return amount.toStringAsFixed(2);
    } catch (_) {
      return amount.toString();
    }
  }

  String formatAmountForDisplay(double amount) {
    if (!amount.isFinite || amount <= 0) return 'Not found';
    try {
      return '₱ ${amount.toStringAsFixed(2)}';
    } catch (_) {
      return '₱ ${amount.toString()}';
    }
  }

  String? extractReceiptDate(String text) {
    final datePattern = RegExp(
      r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2},\s+\d{4}(?:,?\s+\d{1,2}:\d{2}\s*(?:am|pm))?\b',
      caseSensitive: false,
    );
    return datePattern.firstMatch(text)?.group(0)?.trim();
  }

  String buildReceiptNote(ReceiptDraft draft) {
    final segments = <String>[];

    final date = draft.rawOcrPreview != null
        ? extractReceiptDate(draft.rawOcrPreview!)
        : null;
    if (date != null) segments.add('Transaction on $date');

    if (draft.walletLabel != null) segments.add('via ${draft.walletLabel}');

    if (draft.amount != null && draft.amount!.isFinite && draft.amount! > 0) {
      segments.add('for ₱${draft.amount!.toStringAsFixed(2)}');
    }

    if (draft.accountName != null && draft.accountNumber != null) {
      segments.add('to ${draft.accountName} (${draft.accountNumber})');
    } else if (draft.accountName != null) {
      segments.add('to ${draft.accountName}');
    } else if (draft.accountNumber != null) {
      segments.add('account ${draft.accountNumber}');
    }

    if (draft.reference != null) segments.add('Ref: ${draft.reference}');

    if (segments.isEmpty) return '';
    final joined = segments.join(', ');
    return joined[0].toUpperCase() + joined.substring(1);
  }
}
