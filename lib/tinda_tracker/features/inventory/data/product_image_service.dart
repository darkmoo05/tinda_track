import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/camera/guided_camera_service.dart';

export '../../../../shared/camera/guided_camera_service.dart'
    show CameraGuideRatio, GuidedCameraService;

/// Thin wrapper around [GuidedCameraService] scoped to the inventory feature.
///
/// For camera capture it delegates to the guided camera screen (overlay +
/// aspect-ratio toggle + WebP compression).
/// For gallery picks it opens a Flutter-native crop screen via [GuidedCameraService.pickFromGallery].
class ProductImageService {
  ProductImageService._();
  static final ProductImageService instance = ProductImageService._();

  /// Captures or picks a product image and returns a compressed WebP [File].
  ///
  /// [syncId]  — used as the output filename (`<syncId>.webp`).
  /// [context] — required when [useCamera] is true (for navigation).
  /// [useCamera] — `true` opens the guided camera, `false` opens the gallery.
  Future<File?> pickAndCompress({
    required String syncId,
    BuildContext? context,
    bool useCamera = false,
  }) async {
    if (useCamera) {
      if (context == null || !context.mounted) return null;
      return GuidedCameraService.capture(
        context: context,
        syncId: syncId,
        title: 'Product Photo',
        overlayLabel: 'Fit product inside the frame',
      );
    }
    return GuidedCameraService.pickFromGallery(
      context: context!,
      syncId: syncId,
    );
  }

  /// Derives the expected local file path for a given [syncId].
  static String buildDestPath(String syncId) => 'product_images/$syncId.webp';
}
