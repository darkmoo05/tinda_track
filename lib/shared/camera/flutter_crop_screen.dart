import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A shared, Flutter-native full-screen image crop screen.
///
/// Returns the cropped [File] via [Navigator.pop], or `null` if the user
/// cancels. Because [crop_your_image] renders entirely inside Flutter's widget
/// tree, [SafeArea] and [MediaQuery] handle all system-bar insets correctly —
/// no native Activity, no UCrop toolbar overlap issue.
///
/// Usage:
/// ```dart
/// final cropped = await Navigator.push<File?>(
///   context,
///   MaterialPageRoute(
///     fullscreenDialog: true,
///     builder: (_) => FlutterCropScreen(
///       file: pickedFile,
///       aspectRatio: 1.0, // square
///     ),
///   ),
/// );
/// ```
class FlutterCropScreen extends StatefulWidget {
  const FlutterCropScreen({
    super.key,
    required this.file,
    required this.aspectRatio,
    this.title = 'Adjust Photo',
  });

  /// The source image file to crop.
  final File file;

  /// Width ÷ height ratio the crop region is locked to (e.g. `1.0` = square).
  final double aspectRatio;

  /// Title shown in the app bar.
  final String title;

  @override
  State<FlutterCropScreen> createState() => _FlutterCropScreenState();
}

class _FlutterCropScreenState extends State<FlutterCropScreen> {
  final _cropController = CropController();
  Uint8List? _imageBytes;
  bool _cropping = false;

  @override
  void initState() {
    super.initState();
    widget.file.readAsBytes().then((bytes) {
      if (mounted) setState(() => _imageBytes = bytes);
    });
  }

  Future<void> _onCropped(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        final tmp = await getTemporaryDirectory();
        final outPath = p.join(
          tmp.path,
          'flutter_crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        final file = File(outPath)..writeAsBytesSync(croppedImage);
        if (mounted) Navigator.of(context).pop<File?>(file);
      case CropFailure(:final cause):
        debugPrint('[FlutterCropScreen] crop failed: $cause');
        if (mounted) {
          setState(() => _cropping = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to crop. Please try again.')),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        leading: CloseButton(
          onPressed: () => Navigator.of(context).pop<File?>(null),
        ),
      ),
      body: SafeArea(
        child: _imageBytes == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                children: [
                  Expanded(
                    child: Crop(
                      controller: _cropController,
                      image: _imageBytes!,
                      aspectRatio: widget.aspectRatio,
                      interactive: true,
                      baseColor: Colors.black,
                      maskColor: Colors.black.withValues(alpha: 0.5),
                      onCropped: _onCropped,
                      progressIndicator: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cropping
                                ? null
                                : () => Navigator.of(context).pop<File?>(null),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: _cropping
                                ? null
                                : () {
                                    setState(() => _cropping = true);
                                    _cropController.crop();
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: _cropping
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text('Crop'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
