import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/di/database_providers.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
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
  });

  final VoidCallback? openDrawer;
  final VoidCallback? onDataChanged;
  final ValueChanged<HistoryWalletPerspective>? onWalletPerspectiveSelected;

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
    _dashboardFuture = _dashboardRepository.loadSnapshot();
  }

  void _reloadDashboardSnapshot() {
    setState(() {
      _dashboardFuture = _dashboardRepository.loadSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) {
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

        return Scaffold(
          key: _scaffoldKey,
          appBar: ArchitectAppBar(
            title: context.l10n.appTitle,
            onSettingsPressed: widget.openDrawer,
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ScreenHeaderCard(
                title: context.l10n.walletOverview,
                subtitle: context.l10n.walletCashBalanceTrend,
              ),
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
      },
    );
  }

  Future<void> _onAlertAction(String actionLabel) async {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final tileWidth = (constraints.maxWidth - spacing) / 2;

            return Column(
              children: [
                Wrap(
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
                        caption: context.l10n.availableBalance,
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
                        caption: context.l10n.availableBalance,
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
                        width: tileWidth,
                        title: context.l10n.onHandCash,
                        value: _dashboardRepository.formatCurrency(
                          dashboard.onHandCash,
                        ),
                        caption: context.l10n.physicalCash,
                        icon: Icons.payments_outlined,
                        accentColor: AppColors.onHand,
                        onTap: () => _openWalletPerspectiveHistory(
                          HistoryWalletPerspective.onHand,
                        ),
                      ),
                    ),
                    _WalletCardAnimator(
                      delay: const Duration(milliseconds: 240),
                      child: _buildWalletMetricTile(
                        width: tileWidth,
                        title: context.l10n.chargesEarnings,
                        value: _dashboardRepository.formatCurrency(
                          dashboard.remainingWithdrawableTotal,
                        ),
                        caption: 'Withdrawable now',
                        icon: Icons.trending_up_rounded,
                        accentColor: AppColors.softNavy,
                        titleMaxLines: 2,
                        onTap: () => _openChargesEarnings(dashboard),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTotalFundsTile(context, dashboard),
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

  Widget _buildTotalFundsTile(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    final totalBusinessCash = dashboard.businessUsableCash;
    final withdrawableEarnings = dashboard.remainingWithdrawableTotal;
    const accentColor = AppColors.darkNavyTile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.4);
    final totalColor = isDark ? const Color(0xFFF8FAFC) : AppColors.darkNavyTile;
    final textVarColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
        decoration: BoxDecoration(
          color: tileBg,
          border: Border(
            left: BorderSide(color: isDark ? const Color(0xFF94A3B8) : accentColor, width: 4),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.totalFunds,
                    style: TextStyle(
                      color: textVarColor,
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
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: isDark ? const Color(0xFF94A3B8) : accentColor,
                    size: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _dashboardRepository.formatCurrency(totalBusinessCash),
                maxLines: 1,
                style: TextStyle(
                  color: totalColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.businessCashComputation,
              style: TextStyle(
                color: textVarColor,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.withdrawableEarningsNote(
                _dashboardRepository.formatCurrency(withdrawableEarnings),
              ),
              style: TextStyle(
                color: textVarColor,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
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
