import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Shared types
// ---------------------------------------------------------------------------

/// The three guide-frame aspect ratios the user can choose from.
enum CameraGuideRatio {
  square(1, 1, 'Square'),
  portrait(3, 4, 'Portrait'),
  landscape(4, 3, 'Landscape');

  const CameraGuideRatio(this.ratioW, this.ratioH, this.label);

  final int ratioW;
  final int ratioH;
  final String label;

  double get aspectRatio => ratioW / ratioH;
}

/// Returned by [GuidedCameraScreen] when the user captures a photo.
class GuidedCameraResult {
  final File file;
  final CameraGuideRatio ratio;

  /// Guide-frame rectangle in logical screen pixels at capture time.
  final Rect guideFrame;

  /// Screen size (logical pixels) at capture time.
  final Size screenSize;

  /// Camera preview size in portrait orientation
  /// (`previewSize!.height × previewSize!.width` from [CameraValue]).
  final Size previewSize;

  const GuidedCameraResult({
    required this.file,
    required this.ratio,
    required this.guideFrame,
    required this.screenSize,
    required this.previewSize,
  });
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Full-screen guided camera with:
///  - A semi-transparent overlay with bracket corners showing the crop area.
///  - An aspect-ratio toggle (Square / Portrait / Landscape).
///  - A shutter button that captures and returns a [GuidedCameraResult].
///
/// Callers should not use this directly — use [GuidedCameraService] instead.
class GuidedCameraScreen extends StatefulWidget {
  final String title;
  final CameraGuideRatio initialRatio;
  final bool showRatioToggle;
  final String overlayLabel;

  const GuidedCameraScreen({
    super.key,
    this.title = 'Take Photo',
    this.initialRatio = CameraGuideRatio.square,
    this.showRatioToggle = true,
    this.overlayLabel = 'Fit product inside the frame',
  });

  @override
  State<GuidedCameraScreen> createState() => _GuidedCameraScreenState();
}

class _GuidedCameraScreenState extends State<GuidedCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _ctrl;
  bool _isReady = false;
  bool _capturing = false;
  late CameraGuideRatio _ratio;
  FlashMode _flashMode = FlashMode.off;

  // Cached from the last build — used in _capture() to map screen→image coords.
  Rect _guideFrame = Rect.zero;
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    CameraController? ctrl;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      ctrl = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      await ctrl.setFlashMode(FlashMode.off);
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      _ctrl = ctrl;
      setState(() {
        _flashMode = FlashMode.off;
        _isReady = true;
      });
    } catch (e) {
      debugPrint('[GuidedCamera] init error: $e');
      try {
        await ctrl?.dispose();
      } catch (_) {}
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _ctrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _ctrl = null;
      if (mounted) setState(() => _isReady = false);
      ctrl.dispose().catchError((_) {});
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose().catchError((_) {});
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final ctrl = _ctrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    // torch keeps the LED on continuously, letting AE calibrate before
    // capture — avoids the overexposed-white-image problem of FlashMode.always.
    final next = switch (_flashMode) {
      FlashMode.off => FlashMode.torch,
      FlashMode.torch => FlashMode.off,
      _ => FlashMode.off,
    };
    try {
      await ctrl.setFlashMode(next);
      setState(() => _flashMode = next);
    } catch (_) {}
  }

  Future<void> _capture() async {
    final ctrl = _ctrl;
    if (_capturing || !_isReady || ctrl == null) return;
    setState(() => _capturing = true);
    try {
      // When flash is active give the hardware ~300 ms to arm and let AE
      // converge on the flash-lit scene before firing the shutter.
      // (setFlashMode is NOT repeated here — calling it again resets the
      // AE pipeline and is the primary cause of overexposed white images.)
      if (_flashMode != FlashMode.off) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
      final xfile = await ctrl.takePicture();
      if (mounted) {
        final ps = ctrl.value.previewSize!;
        Navigator.pop(
          context,
          GuidedCameraResult(
            file: File(xfile.path),
            ratio: _ratio,
            guideFrame: _guideFrame,
            screenSize: _screenSize,
            // Camera2 previewSize is always landscape; swap to portrait.
            previewSize: Size(ps.height, ps.width),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _capturing = false);
    }
  }

  // -- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Hide system UI for a full immersive camera feel.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return PopScope(
      onPopInvokedWithResult: (_, __) =>
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isReady ? _buildBody() : _buildLoading(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth;
        final sh = constraints.maxHeight;

        // Guide frame: 78% of screen width, height driven by selected ratio.
        final frameW = sw * 0.78;
        final frameH = frameW / _ratio.aspectRatio;
        // Position slightly above vertical center to leave room for controls.
        final frameTop = (sh - frameH) / 2 - 40;
        final frameLeft = (sw - frameW) / 2;
        final frame = Rect.fromLTWH(frameLeft, frameTop, frameW, frameH);

        // Cache for _capture() — safe to assign during build (no rebuild triggered).
        _guideFrame = frame;
        _screenSize = Size(sw, sh);

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Camera preview (cover fill) ────────────────────────────────
            _buildPreview(),

            // ── Dark overlay + bracket corners ─────────────────────────────
            CustomPaint(painter: _OverlayPainter(frame)),

            // ── Label below guide frame ────────────────────────────────────
            Positioned(
              left: frame.left,
              top: frame.bottom + 10,
              width: frame.width,
              child: Text(
                widget.overlayLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // ── Top bar ────────────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 20, 4, 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          switch (_flashMode) {
                            FlashMode.torch => Icons.flash_on,
                            _ => Icons.flash_off,
                          },
                          color: switch (_flashMode) {
                            FlashMode.torch => Colors.amber,
                            _ => Colors.white,
                          },
                        ),
                        onPressed: _isReady ? _toggleFlash : null,
                        tooltip: switch (_flashMode) {
                          FlashMode.torch => 'Flash: On',
                          _ => 'Flash: Off',
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom controls ────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showRatioToggle) ...[
                        _RatioToggle(
                          selected: _ratio,
                          onChanged: (r) => setState(() => _ratio = r),
                        ),
                        const SizedBox(height: 24),
                      ],
                      _ShutterButton(
                        capturing: _capturing,
                        onCapture: _capture,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreview() {
    final ctrl = _ctrl!;
    // Swap previewSize width/height: on Android, previewSize is always in
    // landscape orientation (even when the phone is held in portrait), so
    // we swap to produce the correct portrait aspect ratio for FittedBox.
    final ps = ctrl.value.previewSize!;
    final previewW = ps.height; // portrait width  = landscape height
    final previewH = ps.width; //  portrait height = landscape width

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewW,
          height: previewH,
          child: CameraPreview(ctrl),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

/// Three-button aspect-ratio pill toggle.
class _RatioToggle extends StatelessWidget {
  final CameraGuideRatio selected;
  final ValueChanged<CameraGuideRatio> onChanged;

  const _RatioToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CameraGuideRatio.values.map((r) {
          final active = r == selected;
          return GestureDetector(
            onTap: () => onChanged(r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                r.label,
                style: TextStyle(
                  color: active ? Colors.black87 : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Classic circular shutter button.
class _ShutterButton extends StatelessWidget {
  final bool capturing;
  final VoidCallback onCapture;

  const _ShutterButton({required this.capturing, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: capturing ? null : onCapture,
      child: SizedBox(
        width: 74,
        height: 74,
        child: capturing
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              )
            : Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overlay painter
// ---------------------------------------------------------------------------

/// Dims the area OUTSIDE the guide frame and draws L-shaped bracket corners.
class _OverlayPainter extends CustomPainter {
  final Rect frame;
  const _OverlayPainter(this.frame);

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.55);

    // Four rectangles surrounding the clear guide frame.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, frame.top), dim);
    canvas.drawRect(Rect.fromLTWH(0, frame.top, frame.left, frame.height), dim);
    canvas.drawRect(
      Rect.fromLTWH(
        frame.right,
        frame.top,
        size.width - frame.right,
        frame.height,
      ),
      dim,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, frame.bottom, size.width, size.height - frame.bottom),
      dim,
    );

    // L-shaped bracket corners.
    const len = 28.0;
    const thick = 3.5;
    final bracket = Paint()
      ..color = Colors.white
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    void corner(Offset o, double dx, double dy) {
      canvas.drawLine(o, o + Offset(dx * len, 0), bracket);
      canvas.drawLine(o, o + Offset(0, dy * len), bracket);
    }

    corner(frame.topLeft, 1, 1);
    corner(frame.topRight, -1, 1);
    corner(frame.bottomLeft, 1, -1);
    corner(frame.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.frame != frame;
}
