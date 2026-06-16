import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/database/app_database.dart' show MonitoringSessionRow;
import '../../../../core/di/database_providers.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/dashboard_tutorial_overlay.dart';
import '../../../../shared/widgets/tutorial_spotlight.dart';
import '../../more/logic/monitoring_session_provider.dart';
import '../logic/onboarding_provider.dart';

import '../../activity/screens/activity_history_screen.dart';
import '../../charges/screens/charges_earnings_screen.dart';
import '../../transactions/screens/add_owner_movement_screen.dart';
import '../data/dashboard_repository.dart';
import 'personal_expense_statement_screen.dart';
import '../widgets/activity_item.dart';
import '../widgets/alert_card.dart';
import '../widgets/income_architecture_card.dart';

enum _DashboardActivityFilter { all, business, personal, transactions }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
    this.openDrawer,
    this.onDataChanged,
    this.onWalletPerspectiveSelected,
    this.refreshToken = 0,
  });

  final VoidCallback? openDrawer;
  final VoidCallback? onDataChanged;
  final ValueChanged<HistoryWalletPerspective>? onWalletPerspectiveSelected;
  final int refreshToken;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final DashboardRepository _dashboardRepository = DashboardRepository(
    database: ref.read(currentAppDatabaseProvider),
  );
  _DashboardActivityFilter _activityFilter = _DashboardActivityFilter.all;
  late Future<DashboardSnapshot> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    final initialSession = ref.read(selectedSessionProvider).value;
    _dashboardFuture = _dashboardRepository.loadSnapshot(session: initialSession);
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) {
      _reloadDashboardSnapshot();
    }
  }

  void _reloadDashboardSnapshot() {
    final isAllTime = ref.read(allTimeViewProvider);
    final selectedSession = isAllTime ? null : ref.read(selectedSessionProvider).value;
    setState(() {
      _dashboardFuture = _dashboardRepository.loadSnapshot(session: selectedSession);
    });
  }


  Widget _buildDemoModeBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerBg = isDark ? const Color(0xFF1E293B) : Colors.yellow.shade50;
    final borderCol = isDark ? const Color(0xFFFBBF24).withValues(alpha: 0.4) : Colors.yellow.shade200;
    
    return Container(
      key: ref.read(onboardingKeysProvider).demoModeBannerKey,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo Mode Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'These are sample transactions. You can clear them or keep them.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () async {
              await ref.read(onboardingProvider.notifier).clearSampleData();
              _reloadDashboardSnapshot();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () async {
              await ref.read(onboardingProvider.notifier).promoteDemoDataToReal();
              _reloadDashboardSnapshot();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF059669),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Keep', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlySessionBanner(BuildContext context, MonitoringSessionRow session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerBg = isDark ? const Color(0xFF1E293B) : Colors.red.shade50;
    final borderCol = isDark ? const Color(0xFFEF4444).withValues(alpha: 0.4) : Colors.red.shade200;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_clock_rounded, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historical Session: ${session.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You are viewing a closed session. Transaction recording is disabled.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF7F1D1D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () async {
              await ref.read(selectedSessionProvider.notifier).resetToActive();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Go Live', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTimeBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerBg = isDark ? const Color(0xFF1E1B3A) : const Color(0xFFF5F3FF);
    final borderCol = isDark
        ? const Color(0xFF7C3AED).withValues(alpha: 0.4)
        : const Color(0xFFC4B5FD);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: Color(0xFF7C3AED), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Sessions — All Time View',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Showing combined history from every monitoring session.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF5B21B6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              ref.read(allTimeViewProvider.notifier).state = false;
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Go Live', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingKeys = ref.watch(onboardingKeysProvider);
    final selectedSessionAsync = ref.watch(selectedSessionProvider);
    final selectedSession = selectedSessionAsync.value;
    final isAllTime = ref.watch(allTimeViewProvider);

    ref.listen(selectedSessionProvider, (previous, next) {
      final prevId = previous?.value?.id;
      final nextId = next.value?.id;
      final prevStart = previous?.value?.startDateMs;
      final nextStart = next.value?.startDateMs;
      // Reload whenever the session ID or start timestamp changes — this
      // catches the new-session case where startDateMs differs even if the
      // ID comparison alone might be skipped due to async ordering.
      if (prevId != nextId || prevStart != nextStart) {
        final allTime = ref.read(allTimeViewProvider);
        setState(() {
          _dashboardFuture = _dashboardRepository.loadSnapshot(
            session: allTime ? null : next.value,
          );
        });
      }
    });

    // React when the user switches to/from All-Time view.
    ref.listen<bool>(allTimeViewProvider, (prev, next) {
      if (prev == next) return;
      setState(() {
        _dashboardFuture = _dashboardRepository.loadSnapshot(
          session: next ? null : ref.read(selectedSessionProvider).value,
        );
      });
    });

    return FutureBuilder<DashboardSnapshot>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: ArchitectAppBar(
              title: context.l10n.appTitle,
              onSettingsPressed: widget.openDrawer,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: ArchitectAppBar(
              title: context.l10n.appTitle,
              onSettingsPressed: widget.openDrawer,
            ),
            body: Center(child: Text(context.l10n.unableToLoadDashboard)),
          );
        }

        final dashboard = snapshot.data;
        if (dashboard == null) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: ArchitectAppBar(
              title: context.l10n.appTitle,
              onSettingsPressed: widget.openDrawer,
            ),
            body: Center(child: Text(context.l10n.noDashboardData)),
          );
        }

        final scaffold = Scaffold(
          key: _scaffoldKey,
          appBar: ArchitectAppBar(
            title: context.l10n.appTitle,
            onSettingsPressed: widget.openDrawer,
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (isAllTime)
                _buildAllTimeBanner(context)
              else if (selectedSession != null && selectedSession.status == 'CLOSED')
                _buildReadOnlySessionBanner(context, selectedSession),
              if (onboardingState.hasDemoData)
                _buildDemoModeBanner(context),
              _buildBusinessCashHeroCard(context, dashboard),

              const SizedBox(height: 16),
              if (dashboard.showAlertCard)
                ArchitectAlertCard(
                  title: dashboard.alertTitle,
                  message: dashboard.alertMessage,
                  actionLabel: dashboard.alertActionLabel,
                  onAction: () => _onAlertAction(dashboard.alertActionLabel),
                ),
              if (dashboard.showAlertCard) const SizedBox(height: 16),
              _buildWalletSummarySection(context, dashboard),
              const SizedBox(height: 16),
              _buildChargesEarningsAllocationCard(context, dashboard),
              const SizedBox(height: 16),
              _buildBalanceTrendSection(dashboard),
              const SizedBox(height: 16),
              _buildPersonalExpenseCard(context, dashboard),
              const SizedBox(height: 24),
              _buildRecentActivityHeader(context),
              const SizedBox(height: 16),
              _buildActivityTabs(context),
              const SizedBox(height: 16),
              _buildRecentActivityList(context, dashboard),
              const SizedBox(height: 100),
            ],
          ),
        );

        return Stack(
          children: [
            scaffold,
            if (onboardingState.step == OnboardingStep.welcome)
              DashboardTutorialOverlay(
                onSkip: () {
                  ref.read(onboardingProvider.notifier).startTour();
                },
              ),
            if (onboardingState.step == OnboardingStep.setupCapitalPrompt)
              TutorialSpotlight(
                targetKey: onboardingKeys.topUpButtonKey,
                title: 'Set Up Your Capital',
                description: 'First, let\'s record your starting shop funds. Tap the \'Top-Up\' button to continue.',
                onNext: () {
                  _onAlertAction('RESTOCK FUNDS');
                },
                onSkip: () => ref.read(onboardingProvider.notifier).completeTour(),
                nextLabel: 'Next',
                showNext: true,
                shape: BoxShape.rectangle,
                borderRadius: 24.0,
              ),
            if (onboardingState.step == OnboardingStep.explainDeltas)
              TutorialSpotlight(
                targetKey: onboardingKeys.walletGridKey,
                title: 'Observe Balance Deltas',
                description: 'Notice the math:\n'
                    '• Your GCash balance decreased because you sent GCash to the customer.\n'
                    '• Your physical On-Hand Cash increased because you collected cash plus your fee.\n'
                    '• Your overall Business Cash grew by your service fee earnings!',
                onNext: () {
                  ref.read(onboardingProvider.notifier).setStep(OnboardingStep.explainChargesPrompt);
                },
                onSkip: () => ref.read(onboardingProvider.notifier).completeTour(),
                nextLabel: 'Next',
                borderRadius: 16.0,
                shape: BoxShape.rectangle,
              ),
            if (onboardingState.step == OnboardingStep.explainChargesPrompt)
              TutorialSpotlight(
                targetKey: onboardingKeys.manageEarningsButtonKey,
                title: 'Track Your Earnings',
                description: 'Let\'s view your collected service fees. Tap the \'Manage Earnings\' button.',
                onNext: () {
                  _openChargesEarnings(dashboard);
                },
                onSkip: () => ref.read(onboardingProvider.notifier).completeTour(),
                nextLabel: 'Manage',
                showNext: true,
                shape: BoxShape.rectangle,
                borderRadius: 12.0,
              ),
            if (onboardingState.step == OnboardingStep.demoDataPrompt && onboardingState.hasDemoData)
              TutorialSpotlight(
                targetKey: onboardingKeys.demoModeBannerKey,
                title: 'Demo Data Options',
                description: 'You are currently viewing demo data. To complete your setup, please choose how to handle the sample transactions:\n\n'
                    '• Tap "Clear" inside the highlighted banner to wipe all demo data and start with a fresh, empty ledger.\n'
                    '• Tap "Keep" inside the highlighted banner to save these sample entries as part of your real business records.\n\n'
                    'Note: Tapping either button will execute that action and automatically complete the tutorial!',
                onNext: () {
                  ref.read(onboardingProvider.notifier).completeTour();
                },
                onSkip: () => ref.read(onboardingProvider.notifier).completeTour(),
                nextLabel: 'Finish Tour',
                showNext: true,
                shape: BoxShape.rectangle,
                borderRadius: 16.0,
                allowPassThrough: true,
              ),
          ],
        );
      },
    );
  }

  Future<void> _onAlertAction(String actionLabel) async {
    final selectedSession = ref.read(selectedSessionProvider).value;
    if (selectedSession != null && selectedSession.status == 'CLOSED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot perform movements on a closed monitoring session.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    AddOwnerMovementScreen? screen;


    if (actionLabel == 'LOAD WALLET' || actionLabel == 'LOAD GCASH WALLET') {
      screen = const AddOwnerMovementScreen(
        initialMovementType: 'Top-up',
        initialDestination: 'GCash',
      );
    } else if (actionLabel == 'LOAD MAYA WALLET') {
      screen = const AddOwnerMovementScreen(
        initialMovementType: 'Top-up',
        initialDestination: 'Maya Wallet',
      );
    } else if (actionLabel == 'ADD CASH') {
      screen = const AddOwnerMovementScreen(
        initialMovementType: 'Top-up',
        initialDestination: 'On-hand Cash',
      );
    } else if (actionLabel == 'RESTOCK FUNDS') {
      screen = const AddOwnerMovementScreen(initialMovementType: 'Top-up');
    } else if (actionLabel == 'TRANSFER FUNDS') {
      screen = const AddOwnerMovementScreen(
        initialMovementType: 'Cash Transfer (on-hand to wallet)',
      );
    }

    if (screen == null) {
      return;
    }

    final resolvedScreen = screen;

    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => resolvedScreen));

    if (saved == true && mounted) {
      widget.onDataChanged?.call();
      _reloadDashboardSnapshot();
    }
  }

  Future<void> _openChargesEarnings(DashboardSnapshot dashboard) async {
    final onboarding = ref.read(onboardingProvider);
    if (onboarding.step == OnboardingStep.explainChargesPrompt) {
      ref.read(onboardingProvider.notifier).setStep(OnboardingStep.chargesScreenPrompt);
    }
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChargesEarningsScreen(
          totalEarnings: dashboard.recordedFlow,
          transactionCount: dashboard.transactionCount,
          chargesToOnHand: dashboard.chargesToOnHand,
          chargesToGcash: dashboard.chargesToGcash,
          chargesToMaya: dashboard.chargesToMaya,
          remainingWithdrawableOnHand: dashboard.remainingWithdrawableOnHand,
          remainingWithdrawableGcash: dashboard.remainingWithdrawableGcash,
          remainingWithdrawableMaya: dashboard.remainingWithdrawableMaya,
          remainingWithdrawableTotal: dashboard.remainingWithdrawableTotal,
          flowSpots: dashboard.flowSpots,
          flowLabels: dashboard.flowLabels,
          flowDates: dashboard.flowDates,
          chargeTransactions: dashboard.chargeTransactions,
        ),
      ),
    );

    if (saved == true && mounted) {
      widget.onDataChanged?.call();
      _reloadDashboardSnapshot();
    }
  }

  Future<void> _openWalletPerspectiveHistory(
    HistoryWalletPerspective perspective,
  ) async {
    final onWalletPerspectiveSelected = widget.onWalletPerspectiveSelected;
    if (onWalletPerspectiveSelected != null) {
      onWalletPerspectiveSelected(perspective);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ActivityHistoryScreen(initialWalletPerspective: perspective),
      ),
    );
  }

  Widget _buildWalletSummarySection(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    final selectedSession = ref.watch(selectedSessionProvider).value;

    final gcashStart = selectedSession?.startGcash ?? 0.0;
    final gcashChange = dashboard.walletBalance - gcashStart;
    final gcashChangeSign = gcashChange >= 0 ? '+' : '';
    final gcashCaption = selectedSession != null
        ? 'Started: ${_dashboardRepository.formatCurrency(gcashStart)} ($gcashChangeSign${_dashboardRepository.formatCurrency(gcashChange)})'
        : context.l10n.availableBalance;

    final mayaStart = selectedSession?.startMaya ?? 0.0;
    final mayaChange = dashboard.mayaWalletBalance - mayaStart;
    final mayaChangeSign = mayaChange >= 0 ? '+' : '';
    final mayaCaption = selectedSession != null
        ? 'Started: ${_dashboardRepository.formatCurrency(mayaStart)} ($mayaChangeSign${_dashboardRepository.formatCurrency(mayaChange)})'
        : context.l10n.availableBalance;

    final onHandStart = selectedSession?.startOnHand ?? 0.0;
    final onHandChange = dashboard.onHandCash - onHandStart;
    final onHandChangeSign = onHandChange >= 0 ? '+' : '';
    final onHandCaption = selectedSession != null
        ? 'Started: ${_dashboardRepository.formatCurrency(onHandStart)} ($onHandChangeSign${_dashboardRepository.formatCurrency(onHandChange)})'
        : context.l10n.physicalCash;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final tileWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              key: ref.read(onboardingKeysProvider).walletGridKey,
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _WalletCardAnimator(
                  delay: const Duration(milliseconds: 0),
                  child: _buildWalletMetricTile(
                    width: tileWidth,
                    title: context.l10n.gcashWallet,
                    value: _dashboardRepository.formatCurrency(
                      dashboard.walletBalance,
                    ),
                    caption: gcashCaption,
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: AppColors.primary,
                    onTap: () => _openWalletPerspectiveHistory(
                      HistoryWalletPerspective.gcash,
                    ),
                  ),
                ),
                _WalletCardAnimator(
                  delay: const Duration(milliseconds: 80),
                  child: _buildWalletMetricTile(
                    width: tileWidth,
                    title: context.l10n.mayaWallet,
                    value: _dashboardRepository.formatCurrency(
                      dashboard.mayaWalletBalance,
                    ),
                    caption: mayaCaption,
                    icon: Icons.account_balance_rounded,
                    accentColor: AppColors.secondary,
                    onTap: () => _openWalletPerspectiveHistory(
                      HistoryWalletPerspective.maya,
                    ),
                  ),
                ),
                _WalletCardAnimator(
                  delay: const Duration(milliseconds: 160),
                  child: _buildWalletMetricTile(
                    width: constraints.maxWidth,
                    title: context.l10n.onHandCash,
                    value: _dashboardRepository.formatCurrency(
                      dashboard.onHandCash,
                    ),
                    caption: onHandCaption,
                    icon: Icons.payments_outlined,
                    accentColor: AppColors.onHand,
                    onTap: () => _openWalletPerspectiveHistory(
                      HistoryWalletPerspective.onHand,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWalletMetricTile({
    required double width,
    required String title,
    required String value,
    required String caption,
    required IconData icon,
    required Color accentColor,
    int titleMaxLines = 1,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.4);
    Color adaptiveAccent = accentColor;
    if (isDark) {
      if (accentColor == AppColors.primary) {
        adaptiveAccent = const Color(0xFF60A5FA);
      } else if (accentColor == AppColors.secondary) {
        adaptiveAccent = const Color(0xFF34D399);
      } else if (accentColor == AppColors.onHand) {
        adaptiveAccent = const Color(0xFFFBBF24);
      } else if (accentColor == AppColors.softNavy) {
        adaptiveAccent = const Color(0xFF94A3B8);
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            width: width,
            decoration: BoxDecoration(
              color: tileBg,
              border: Border(
                left: BorderSide(color: adaptiveAccent, width: 4),
                top: BorderSide(color: borderColor),
                right: BorderSide(color: borderColor),
                bottom: BorderSide(color: borderColor),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 120),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: titleMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: adaptiveAccent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: adaptiveAccent, size: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: TextStyle(
                          color: adaptiveAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessCashHeroCard(BuildContext context, DashboardSnapshot dashboard) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalBusinessCash = dashboard.businessUsableCash;

    final selectedSession = ref.watch(selectedSessionProvider).value;
    final startingBusinessCash = (selectedSession?.startGcash ?? 0.0) +
        (selectedSession?.startMaya ?? 0.0) +
        (selectedSession?.startOnHand ?? 0.0);
    final businessChange = totalBusinessCash - startingBusinessCash;
    final changeSign = businessChange >= 0 ? '+' : '';
    final changeStr = changeSign + _dashboardRepository.formatCurrency(businessChange);

    final subtitle = selectedSession != null
        ? '${selectedSession.name} • Started: ${_dashboardRepository.formatCurrency(startingBusinessCash)} ($changeStr)'
        : 'Available now for business operations';

    final heroGradient = const LinearGradient(
      colors: [AppColors.primary, Color(0xFF0F172A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      key: ref.read(onboardingKeysProvider).topUpButtonKey,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT BUSINESS CASH',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _dashboardRepository.formatCurrency(totalBusinessCash),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onAlertAction('RESTOCK FUNDS'),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Top-Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _onAlertAction('TRANSFER FUNDS'),
                  icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                  label: const Text('Transfer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChargesEarningsAllocationCard(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final withdrawable = dashboard.remainingWithdrawableTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF60A5FA) : AppColors.primary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Charges & Collected Fees',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sub-allocation of your wallet balances',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dashboardRepository.formatCurrency(withdrawable),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Withdrawable Earnings',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                key: ref.read(onboardingKeysProvider).manageEarningsButtonKey,
                onPressed: () => _openChargesEarnings(dashboard),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF334155) : AppColors.primary.withValues(alpha: 0.08),
                  foregroundColor: isDark ? const Color(0xFFF8FAFC) : AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                child: const Text('Manage Earnings'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Collected fees are already physically inside your GCash, Maya, or On-hand Cash balances.',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceTrendSection(DashboardSnapshot dashboard) {
    final hasTrendData =
        dashboard.xLabels.isNotEmpty &&
        (dashboard.walletSpots.length == dashboard.xLabels.length ||
            dashboard.mayaSpots.length == dashboard.xLabels.length ||
            dashboard.cashSpots.length == dashboard.xLabels.length);

    if (!hasTrendData) {
      return _buildChartPlaceholder(
        title: context.l10n.walletCashBalanceTrend,
        message: context.l10n.walletTrendPlaceholder,
      );
    }

    return IncomeArchitectureCard(
      walletSpots: dashboard.walletSpots,
      mayaSpots: dashboard.mayaSpots,
      cashSpots: dashboard.cashSpots,
      xLabels: dashboard.xLabels,
    );
  }

  Widget _buildChartPlaceholder({
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _minimalCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    return Text(
      context.l10n.recentActivities,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildActivityTabs(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPillTab(
          context.l10n.filterAll,
          _activityFilter == _DashboardActivityFilter.all,
          () {
            setState(() => _activityFilter = _DashboardActivityFilter.all);
          },
        ),
        _buildPillTab(
          context.l10n.filterBusiness,
          _activityFilter == _DashboardActivityFilter.business,
          () {
            setState(() => _activityFilter = _DashboardActivityFilter.business);
          },
        ),
        _buildPillTab(
          context.l10n.filterPersonal,
          _activityFilter == _DashboardActivityFilter.personal,
          () {
            setState(() => _activityFilter = _DashboardActivityFilter.personal);
          },
        ),
        _buildPillTab(
          context.l10n.filterTransactions,
          _activityFilter == _DashboardActivityFilter.transactions,
          () {
            setState(
              () => _activityFilter = _DashboardActivityFilter.transactions,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPillTab(String label, bool isActive, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final inactiveBg = isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainerLow;
    final activeText = isDark ? const Color(0xFF0B0F19) : Colors.white;
    final inactiveText = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? activeText : inactiveText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    final activities =
        dashboard.activities
            .where((activity) {
              switch (_activityFilter) {
                case _DashboardActivityFilter.all:
                  return true;
                case _DashboardActivityFilter.business:
                  return activity.scope.toLowerCase() != 'personal';
                case _DashboardActivityFilter.personal:
                  return activity.scope.toLowerCase() == 'personal';
                case _DashboardActivityFilter.transactions:
                  return activity.tag.toLowerCase().contains('transaction');
              }
            })
            .toList(growable: false)
          ..sort((a, b) {
            final byDate = b.createdAt.compareTo(a.createdAt);
            if (byDate != 0) {
              return byDate;
            }
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          });

    final recentActivities = activities.take(3).toList(growable: false);

    if (recentActivities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _minimalCardDecoration(context),
        child: Text(
          context.l10n.noActivitiesFilter,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: recentActivities
          .map(
            (activity) => ArchitectActivityItem(
              title: activity.title,
              subtitle: activity.subtitle,
              amount: activity.amount,
              tag: activity.tag,
              icon: activity.icon,
              iconColor: activity.iconColor,
            ),
          )
          .toList(),
    );
  }

  Widget _buildPersonalExpenseCard(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    final taken = dashboard.personalExpenseAmount;
    final returned = dashboard.personalExpensePaymentAmount;
    final outstanding = dashboard.personalExpenseOutstanding <= 0
        ? 0.0
        : dashboard.personalExpenseOutstanding;
    final isFullyPaid = outstanding == 0;
    final settledPercent = taken > 0
        ? (returned / taken * 100).clamp(0.0, 100.0)
        : 100.0;
    final statusColor = isFullyPaid ? AppColors.secondary : AppColors.error;
    final statusLabel = isFullyPaid
        ? 'Fully Paid'
        : '${settledPercent.toStringAsFixed(0)}% Settled';

    return GestureDetector(
      onTap: _openPersonalExpenseStatementScreen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _minimalCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Borrowed Funds Status',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildComparisonItem(
                    label: 'Taken',
                    amount: _dashboardRepository.formatCurrency(taken),
                    icon: Icons.shopping_bag_rounded,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildComparisonItem(
                    label: 'Paid Back',
                    amount: _dashboardRepository.formatCurrency(returned),
                    icon: Icons.check_circle_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Outstanding Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dashboardRepository.formatCurrency(outstanding),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: settledPercent / 100,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isFullyPaid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No outstanding balance to pay.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  _navigateToPersonalExpensePayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFullyPaid
                      ? AppColors.secondary
                      : AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isFullyPaid ? 'All Settled' : 'Pay Borrowed Funds',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem({
    required String label,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _openPersonalExpenseStatementScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PersonalExpenseStatementScreen()),
    );
  }

  Future<void> _navigateToPersonalExpensePayment() async {
    final selectedSession = ref.read(selectedSessionProvider).value;
    if (selectedSession != null && selectedSession.status == 'CLOSED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot pay borrowed funds on a closed monitoring session.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final screen = const AddOwnerMovementScreen(

      initialMovementType: 'Borrowed Funds Repayment',
    );

    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (context) => screen));

    if (result == true && mounted) {
      widget.onDataChanged?.call();
      _reloadDashboardSnapshot();
    }
  }

  BoxDecoration _minimalCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF161D30) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.surfaceContainerHigh,
      ),
    );
  }
}

// ── Stagger animation wrapper for wallet cards ──────────────────────────────
class _WalletCardAnimator extends StatefulWidget {
  const _WalletCardAnimator({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<_WalletCardAnimator> createState() => _WalletCardAnimatorState();
}

class _WalletCardAnimatorState extends State<_WalletCardAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
