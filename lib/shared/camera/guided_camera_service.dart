import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'flutter_crop_screen.dart';
import 'guided_camera_screen.dart';

export 'guided_camera_screen.dart' show CameraGuideRatio;

/// Reusable camera capture service used by any feature in the app.
///
/// **Camera (guided):**
/// ```dart
/// final file = await GuidedCameraService.capture(
///   context: context,
///   syncId: product.syncId,
///   title: 'Product Photo',
/// );
/// ```
///
/// **Gallery:**
/// ```dart
/// final file = await GuidedCameraService.pickFromGallery(syncId: product.syncId);
/// ```
///
/// Both methods return a WebP [File] saved under
/// `<documents>/product_images/<syncId>.webp`, or `null` if the user cancelled.
class GuidedCameraService {
  GuidedCameraService._();

  static const int _maxDim = 600;
  static const int _quality = 85;

  // --------------------------------------------------------------------------
  // Public API
  // --------------------------------------------------------------------------

  /// Opens the guided camera → auto-crops to the chosen ratio →
  /// shows [ImageCropper] for fine-tuning → compresses to WebP.
  ///
  /// [syncId]   — used as the output filename (`<syncId>.webp`).
  /// [title]    — shown in the camera screen app bar.
  /// [initialRatio] — default frame shape; user can change it on-screen unless
  ///                  [showRatioToggle] is false.
  /// [overlayLabel] — hint text shown inside the guide frame.
  static Future<File?> capture({
    required BuildContext context,
    required String syncId,
    String title = 'Take Photo',
    CameraGuideRatio initialRatio = CameraGuideRatio.square,
    bool showRatioToggle = true,
    String overlayLabel = 'Fit product inside the frame',
  }) async {
    // Step 0 — Request camera permission (Android runtime permission).
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status.isPermanentlyDenied
                  ? 'Camera permission denied. Enable it in app settings.'
                  : 'Camera permission is required to take photos.',
            ),
            action: status.isPermanentlyDenied
                ? SnackBarAction(label: 'Settings', onPressed: openAppSettings)
                : null,
          ),
        );
      }
      return null;
    }

    if (!context.mounted) {
      return null;
    }

    // Step 1 — Guided camera screen.
    final result = await Navigator.push<GuidedCameraResult>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => GuidedCameraScreen(
          title: title,
          initialRatio: initialRatio,
          showRatioToggle: showRatioToggle,
          overlayLabel: overlayLabel,
        ),
      ),
    );
    if (result == null) return null;

    // Step 2 — Crop the captured image to exactly the guide-frame area.
    final cropped = await _preciseCrop(result);
    if (cropped == null) return null;

    // Step 3 — Compress to WebP.
    return _compress(cropped, syncId);
  }

  /// Opens the device gallery → Flutter-native crop screen → compress to WebP.
  ///
  /// [context] is required to push the [FlutterCropScreen] route.
  static Future<File?> pickFromGallery({
    required BuildContext context,
    required String syncId,
    CameraGuideRatio ratio = CameraGuideRatio.square,
  }) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    if (!context.mounted) return null;

    final cropped = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FlutterCropScreen(
          file: File(picked.path),
          aspectRatio: ratio.ratioW / ratio.ratioH,
        ),
      ),
    );
    if (cropped == null) return null;

    return _compress(cropped, syncId);
  }

  // --------------------------------------------------------------------------
  // Private helpers
  // --------------------------------------------------------------------------

  /// Crops the captured image to the exact pixel region that was visible
  /// inside the guide frame on screen.
  ///
  /// Maths:
  ///   The preview is rendered with [BoxFit.cover] so it fills the screen.
  ///   scale = max(screenW/previewW, screenH/previewH)
  ///   The overflow on each side (screen px) = (previewDim * scale - screenDim) / 2
  ///   A screen coordinate (sx, sy) maps to preview pixels:
  ///     px = (sx + overflowX) / scale
  ///     py = (sy + overflowY) / scale
  ///   Then scale preview → captured image resolution:
  ///     imgX = px * (image.width  / previewW)
  ///     imgY = py * (image.height / previewH)
  static Future<File?> _preciseCrop(GuidedCameraResult result) async {
    try {
      final bytes = await result.file.readAsBytes();
      // decodeImage applies EXIF rotation — result is portrait after decode.
      final original = img.decodeImage(bytes);
      if (original == null) return result.file;

      final sw = result.screenSize.width;
      final sh = result.screenSize.height;
      final previewW = result.previewSize.width; // portrait width
      final previewH = result.previewSize.height; // portrait height

      // BoxFit.cover scale.
      final scale = math.max(sw / previewW, sh / previewH);

      // Overflow on each side in screen pixels (one axis will be 0).
      final overflowX = math.max(0.0, previewW * scale - sw) / 2;
      final overflowY = math.max(0.0, previewH * scale - sh) / 2;

      // Ratio of captured resolution to preview resolution.
      final imgScaleX = original.width / previewW;
      final imgScaleY = original.height / previewH;

      // Map guide frame screen rect → image pixel rect.
      final imgX = ((result.guideFrame.left + overflowX) / scale * imgScaleX)
          .round();
      final imgY = ((result.guideFrame.top + overflowY) / scale * imgScaleY)
          .round();
      final imgW = (result.guideFrame.width / scale * imgScaleX).round();
      final imgH = (result.guideFrame.height / scale * imgScaleY).round();

      // Clamp to image bounds.
      final x = imgX.clamp(0, original.width - 1);
      final y = imgY.clamp(0, original.height - 1);
      final w = imgW.clamp(1, original.width - x);
      final h = imgH.clamp(1, original.height - y);

      final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);

      final tmp = await getTemporaryDirectory();
      final outPath = p.join(
        tmp.path,
        'guided_crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      return File(outPath)
        ..writeAsBytesSync(img.encodeJpg(cropped, quality: 92));
    } catch (e) {
      debugPrint('[GuidedCamera] preciseCrop error: $e');
      return result.file; // fall back to full image
    }
  }

  /// Compresses [source] to WebP at max 600×600 and saves to
  /// `<documents>/product_images/<syncId>.webp`.
  static Future<File?> _compress(File source, String syncId) async {
    final dir = await getApplicationDocumentsDirectory();
    final destDir = Directory(p.join(dir.path, 'product_images'))
      ..createSync(recursive: true);
    final destPath = p.join(destDir.path, '$syncId.webp');

    final result = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      destPath,
      format: CompressFormat.webp,
      quality: _quality,
      minWidth: _maxDim,
      minHeight: _maxDim,
    );
    // If WebP compression fails, fall back to the cropped JPEG so the UI
    // always receives a displayable file instead of null.
    return result != null ? File(result.path) : source;
  }
}
