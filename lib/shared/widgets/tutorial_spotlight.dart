import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import '../../core/app_theme.dart';

class TutorialSpotlight extends StatefulWidget {
  const TutorialSpotlight({
    super.key,
    required this.targetKey,
    required this.title,
    required this.description,
    required this.onNext,
    required this.onSkip,
    this.nextLabel = 'Next',
    this.showNext = true,
    this.shape = BoxShape.circle,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = 12.0,
    this.allowPassThrough = false,
  });

  final GlobalKey targetKey;
  final String title;
  final String description;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;
  final bool showNext;
  final BoxShape shape;
  final EdgeInsets padding;
  final double borderRadius;
  final bool allowPassThrough;

  @override
  State<TutorialSpotlight> createState() => _TutorialSpotlightState();
}

class _TutorialSpotlightState extends State<TutorialSpotlight> {
  Offset _targetOffset = Offset.zero;
  Size _targetSize = Size.zero;
  bool _initialized = false;
  int _calcCount = 0;
  bool _hasScrolledIntoView = false;

  @override
  void initState() {
    super.initState();
    _calcCount = 0;
    _hasScrolledIntoView = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTargetPosition());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calcCount = 0;
    _calculateTargetPosition();
  }

  @override
  void didUpdateWidget(covariant TutorialSpotlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calcCount = 0;
    if (oldWidget.targetKey != widget.targetKey) {
      _hasScrolledIntoView = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTargetPosition());
  }

  void _calculateTargetPosition() {
    if (!mounted) return;
    
    final context = widget.targetKey.currentContext;
    if (context != null) {
      if (!_hasScrolledIntoView) {
        _hasScrolledIntoView = true;
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5,
          curve: Curves.easeInOut,
        );
      }
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final globalPosition = box.localToGlobal(Offset.zero);
        final myBox = this.context.findRenderObject() as RenderBox?;
        final position = (myBox != null && myBox.hasSize)
            ? myBox.globalToLocal(globalPosition)
            : globalPosition;
        if (position != _targetOffset || box.size != _targetSize) {
          setState(() {
            _targetOffset = position;
            _targetSize = box.size;
            _initialized = true;
          });
        }
      }
    }
    // Periodically re-calculate for the first 2000ms (40 * 50ms) to ensure
    // accurate layout dimensions during transition animations (e.g. FAB scale up)
    if (_calcCount < 40) {
      _calcCount++;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _calculateTargetPosition();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = Colors.black.withValues(alpha: 0.75);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface;
    final textColor = isDark ? const Color(0xFFCBD5E1) : AppColors.onSurfaceVariant;
    final primaryAccent = isDark ? const Color(0xFF60A5FA) : AppColors.primary;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Calculate spotlight rect (incorporating custom padding)
    final spotlightRect = Rect.fromLTWH(
      _targetOffset.dx - widget.padding.left,
      _targetOffset.dy - widget.padding.top,
      _targetSize.width + widget.padding.horizontal,
      _targetSize.height + widget.padding.vertical,
    );

    // Calculate optimal position for the tooltip speech bubble (above or below target)
    final spaceAbove = spotlightRect.top;
    final spaceBelow = screenHeight - spotlightRect.bottom;
    final showTooltipBelow = spaceBelow > spaceAbove;

    final tooltipY = showTooltipBelow 
        ? spotlightRect.bottom + 12.0 
        : spotlightRect.top - 170.0; // Estimate height

    // Keep tooltip horizontally centered or within screen boundaries
    double tooltipX = spotlightRect.center.dx - 150.0; // tooltip default width is ~300
    if (tooltipX < 16.0) tooltipX = 16.0;
    if (tooltipX + 300.0 > screenWidth - 16.0) {
      tooltipX = screenWidth - 300.0 - 16.0;
    }

    return Stack(
      children: [
        // Transparent Mask Overlay with optional pass-through hit testing
        _PassThroughHitTest(
          ignoreRect: spotlightRect,
          enabled: widget.allowPassThrough,
          child: GestureDetector(
            onTapDown: (details) {
              final tapPos = details.globalPosition;
              if (spotlightRect.contains(tapPos)) {
                HapticFeedback.lightImpact();
                widget.onNext();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: _SpotlightPainter(
                rect: spotlightRect,
                color: overlayColor,
                shape: widget.shape,
                borderRadius: widget.borderRadius,
              ),
            ),
          ),
        ),
        
        // Tooltip Speech Bubble
        Positioned(
          left: tooltipX,
          top: tooltipY.clamp(16.0, screenHeight - 230.0),
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: (screenWidth - 32.0).clamp(280.0, 320.0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        child: const Text('Skip'),
                      ),
                      if (widget.showNext) ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: widget.onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccent,
                            foregroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            elevation: 0,
                          ),
                          child: Text(widget.nextLabel),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect rect;
  final Color color;
  final BoxShape shape;
  final double borderRadius;

  _SpotlightPainter({
    required this.rect,
    required this.color,
    required this.shape,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (shape == BoxShape.circle) {
      // Circle spotlight centered on the target
      final radius = rect.width > rect.height ? rect.width / 2 : rect.height / 2;
      path.addOval(Rect.fromCircle(center: rect.center, radius: radius));
    } else {
      // Rounded rect spotlight
      path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));
    }

    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.rect != rect ||
        oldDelegate.color != color ||
        oldDelegate.shape != shape ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class _PassThroughHitTest extends SingleChildRenderObjectWidget {
  final Rect ignoreRect;
  final bool enabled;

  const _PassThroughHitTest({
    required this.ignoreRect,
    required this.enabled,
    required super.child,
  });

  @override
  _RenderPassThroughHitTest createRenderObject(BuildContext context) {
    return _RenderPassThroughHitTest(ignoreRect: ignoreRect, enabled: enabled);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderPassThroughHitTest renderObject) {
    renderObject.ignoreRect = ignoreRect;
    renderObject.enabled = enabled;
  }
}

class _RenderPassThroughHitTest extends RenderProxyBox {
  Rect ignoreRect;
  bool enabled;

  _RenderPassThroughHitTest({
    required this.ignoreRect,
    required this.enabled,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (enabled && ignoreRect.contains(position)) {
      return false;
    }
    return super.hitTest(result, position: position);
  }
}
