import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../core/l10n/l10n_extension.dart';

class DashboardTutorialOverlay extends StatefulWidget {
  const DashboardTutorialOverlay({
    super.key,
    required this.onSkip,
  });

  final VoidCallback onSkip;

  @override
  State<DashboardTutorialOverlay> createState() => _DashboardTutorialOverlayState();
}

class _DashboardTutorialOverlayState extends State<DashboardTutorialOverlay> {
  int _currentStep = 0;
  static const int _totalSteps = 3;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface;
    final textColor = isDark ? const Color(0xFFCBD5E1) : AppColors.onSurfaceVariant;
    final dotColor = isDark ? const Color(0xFF475569) : AppColors.outlineVariant;
    final dotActiveColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;

    return Stack(
      children: [
        // Semi-transparent solid backdrop
        GestureDetector(
          onTap: () {}, // Blocks taps through to elements behind
          child: Container(
            color: Colors.black.withValues(alpha: 0.85),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Onboarding Card
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height - 80,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step-specific Illustration Icon / Banner
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildStepIcon(_currentStep, isDark),
                    ),
                    const SizedBox(height: 20),
                    // Sliding Step-specific Content using PageView
                    SizedBox(
                      height: 150,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentStep = index;
                          });
                        },
                        itemCount: _totalSteps,
                        itemBuilder: (context, index) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getStepTitle(index, context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getStepDescription(index, context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textColor,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalSteps, (index) {
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: _currentStep == index ? 16 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _currentStep == index ? dotActiveColor : dotColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    _buildActionButtons(context, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIcon(int step, bool isDark) {
    IconData icon;
    Color color;

    switch (step) {
      case 0:
        icon = Icons.storefront_rounded;
        color = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
        break;
      case 1:
        icon = Icons.trending_up_rounded;
        color = isDark ? const Color(0xFF34D399) : AppColors.secondary;
        break;
      case 2:
      default:
        icon = Icons.compare_arrows_rounded;
        color = isDark ? const Color(0xFFFBBF24) : AppColors.onHand;
        break;
    }

    return Container(
      key: ValueKey<int>(step),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 36,
      ),
    );
  }

  String _getStepTitle(int step, BuildContext context) {
    switch (step) {
      case 0:
        return context.l10n.tutorialWelcomeTitlePocketLedger;
      case 1:
        return context.l10n.tutorialCashTitle;
      case 2:
      default:
        return context.l10n.tutorialWalletsTitle;
    }
  }

  String _getStepDescription(int step, BuildContext context) {
    switch (step) {
      case 0:
        return context.l10n.tutorialWelcomeDescPocketLedger;
      case 1:
        return context.l10n.tutorialCashDesc;
      case 2:
      default:
        return context.l10n.tutorialWalletsDesc;
    }
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    final activeColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;

    if (_currentStep == _totalSteps - 1) {
      // Last Step: Start the tutorial
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            widget.onSkip();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: activeColor,
            foregroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, size: 18),
              SizedBox(width: 8),
              Text('Start Tutorial'),
            ],
          ),
        ),
      );
    }

    // Intermediate steps: Skip and Next buttons
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onSkip();
            },
            style: TextButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            child: Text(context.l10n.skipButton),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: activeColor,
              foregroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
            ),
            child: Text(context.l10n.nextButton),
          ),
        ),
      ],
    );
  }
}
