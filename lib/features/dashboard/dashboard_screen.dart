import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/architect_app_bar.dart';
import '../../shared/widgets/app_side_drawer.dart';
import '../activity/activity_history_screen.dart';
import '../charges/charges_earnings_screen.dart';
import '../transactions/add_owner_movement_screen.dart';
import 'data/dashboard_repository.dart';
import 'widgets/activity_item.dart';
import 'widgets/alert_card.dart';
import 'widgets/income_architecture_card.dart';
import 'borrowing_expense_statement_screen.dart';

enum _DashboardActivityFilter { all, business, personal, transactions }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onDataChanged,
    this.onWalletPerspectiveSelected,
  });

  final VoidCallback? onDataChanged;
  final ValueChanged<HistoryWalletPerspective>? onWalletPerspectiveSelected;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardRepository _dashboardRepository = DashboardRepository();
  _DashboardActivityFilter _activityFilter = _DashboardActivityFilter.all;
  int _selectedDebtTab = 0; // 0 for Borrowing, 1 for Personal Expense
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
            drawer: const AppSideDrawer(),
            appBar: ArchitectAppBar(
              title: context.l10n.appTitle,
              onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            key: _scaffoldKey,
            drawer: const AppSideDrawer(),
            appBar: ArchitectAppBar(
              title: context.l10n.appTitle,
              onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            body: Center(child: Text(context.l10n.unableToLoadDashboard)),
          );
        }

        final dashboard = snapshot.data;
        if (dashboard == null) {
          return Scaffold(
            key: _scaffoldKey,
            drawer: const AppSideDrawer(),
            appBar: ArchitectAppBar(
              title: context.l10n.appTitle,
              onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            body: Center(child: Text(context.l10n.noDashboardData)),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppSideDrawer(),
          appBar: ArchitectAppBar(
            title: context.l10n.appTitle,
            onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
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
              _buildBorrowingRepaymentCard(context, dashboard),
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
        Text(
          context.l10n.walletOverview,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
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
                    _buildWalletMetricTile(
                      width: tileWidth,
                      title: context.l10n.gcashWallet,
                      value: _dashboardRepository.formatCurrency(
                        dashboard.walletBalance,
                      ),
                      caption: context.l10n.availableBalance,
                      icon: Icons.account_balance_wallet_rounded,
                      backgroundColor: AppColors.primary,
                      onTap: () => _openWalletPerspectiveHistory(
                        HistoryWalletPerspective.gcash,
                      ),
                    ),
                    _buildWalletMetricTile(
                      width: tileWidth,
                      title: context.l10n.mayaWallet,
                      value: _dashboardRepository.formatCurrency(
                        dashboard.mayaWalletBalance,
                      ),
                      caption: context.l10n.availableBalance,
                      icon: Icons.account_balance_rounded,
                      backgroundColor: AppColors.secondary,
                      onTap: () => _openWalletPerspectiveHistory(
                        HistoryWalletPerspective.maya,
                      ),
                    ),
                    _buildWalletMetricTile(
                      width: tileWidth,
                      title: context.l10n.onHandCash,
                      value: _dashboardRepository.formatCurrency(
                        dashboard.onHandCash,
                      ),
                      caption: context.l10n.physicalCash,
                      icon: Icons.payments_outlined,
                      backgroundColor: const Color(0xFF8E6C00),
                      onTap: () => _openWalletPerspectiveHistory(
                        HistoryWalletPerspective.onHand,
                      ),
                    ),
                    _buildWalletMetricTile(
                      width: tileWidth,
                      title: context.l10n.chargesEarnings,
                      value: _dashboardRepository.formatCurrency(
                        dashboard.remainingWithdrawableTotal,
                      ),
                      caption: 'Withdrawable fee now',
                      icon: Icons.trending_up_rounded,
                      backgroundColor: AppColors.primaryContainer,
                      titleMaxLines: 2,
                      titleSpacerHeight: 16,
                      onTap: () => _openChargesEarnings(dashboard),
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
    required Color backgroundColor,
    double titleFontSize = 12,
    double titleLetterSpacing = 1.2,
    int titleMaxLines = 1,
    double titleSpacerHeight = 40,
    VoidCallback? onTap,
  }) {
    final foregroundColor = AppColors.onPrimary;
    final mutedForegroundColor = AppColors.onPrimary.withValues(alpha: 0.78);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          width: width,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.26),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 168),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: titleMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: mutedForegroundColor,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: titleLetterSpacing,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, color: mutedForegroundColor, size: 22),
                    ],
                  ),
                  SizedBox(height: titleSpacerHeight),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mutedForegroundColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
    final totalCapital = dashboard.businessFundingTotal;
    final chargeEarnings = dashboard.recordedFlow;
    final computedTotalFunds = totalCapital + chargeEarnings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.22),
            blurRadius: 18,
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
                context.l10n.totalFunds,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _dashboardRepository.formatCurrency(computedTotalFunds),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Capital ${_dashboardRepository.formatCurrency(totalCapital)} + Charges ${_dashboardRepository.formatCurrency(chargeEarnings)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Computation: Initial Capital/Top-ups + Total Charge Earnings',
            style: TextStyle(color: Colors.white60, fontSize: 11),
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
      decoration: _minimalCardDecoration(),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
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
        decoration: _minimalCardDecoration(),
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

  Widget _buildBorrowingRepaymentCard(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    final tabs = ['Borrowing', 'Personal Expense'];

    return GestureDetector(
      onTap: _openStatementScreen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _minimalCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.borrowingStatus,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = _selectedDebtTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDebtTab = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            // Content based on selected tab
            _buildDebtTabContent(context, dashboard, _selectedDebtTab),
            const SizedBox(height: 16),
            // Quick action buttons
            _buildQuickActionButtons(context, dashboard, _selectedDebtTab),
          ],
        ),
      ),
    );
  }

  void _openStatementScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BorrowingExpenseStatementScreen(),
      ),
    );
  }

  Widget _buildDebtTabContent(
    BuildContext context,
    DashboardSnapshot dashboard,
    int tabIndex,
  ) {
    late final double taken;
    late final double returned;
    late final double outstanding;
    late final IconData takenIcon;
    late final IconData returnedIcon;

    if (tabIndex == 0) {
      // Borrowing
      taken = dashboard.borrowingAmount;
      returned = dashboard.borrowingRepaymentAmount;
      outstanding = dashboard.borrowingOutstanding;
      takenIcon = Icons.call_received_rounded;
      returnedIcon = Icons.call_made_rounded;
    } else {
      // Personal Expense
      taken = dashboard.personalExpenseAmount;
      returned = dashboard.personalExpensePaymentAmount;
      outstanding = dashboard.personalExpenseOutstanding;
      takenIcon = Icons.shopping_bag_rounded;
      returnedIcon = Icons.check_circle_rounded;
    }

    final effectiveOutstanding = outstanding <= 0 ? 0.0 : outstanding;
    final isFullyPaid = effectiveOutstanding == 0;
    final settledPercent = taken > 0
        ? (returned / taken * 100).clamp(0.0, 100.0)
        : 100.0;
    final statusColor = isFullyPaid ? AppColors.secondary : AppColors.error;
    final statusIcon = isFullyPaid
        ? Icons.check_circle_rounded
        : Icons.warning_rounded;
    final statusLabel = isFullyPaid
        ? 'Fully Paid'
        : '${settledPercent.toStringAsFixed(0)}% Settled';
    final statusHint = isFullyPaid
        ? 'No remaining balance.'
        : 'You still need to pay this amount.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Taken vs Returned comparison
        Row(
          children: [
            Expanded(
              child: _buildComparisonItem(
                label: 'Taken',
                amount: _dashboardRepository.formatCurrency(taken),
                icon: takenIcon,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonItem(
                label: 'Returned',
                amount: _dashboardRepository.formatCurrency(returned),
                icon: returnedIcon,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Outstanding status with percentage
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outstanding Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dashboardRepository.formatCurrency(effectiveOutstanding),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusHint,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        // Progress bar
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: settledPercent / 100,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(
              isFullyPaid ? AppColors.secondary : AppColors.error,
            ),
          ),
        ),
      ],
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

  Widget _buildQuickActionButtons(
    BuildContext context,
    DashboardSnapshot dashboard,
    int tabIndex,
  ) {
    final outstanding = tabIndex == 0
        ? dashboard.borrowingOutstanding
        : dashboard.personalExpenseOutstanding;
    final effectiveOutstanding = outstanding <= 0 ? 0.0 : outstanding;
    final isFullyPaid = effectiveOutstanding == 0;

    final label = isFullyPaid
        ? 'All Settled'
        : (tabIndex == 0 ? 'Pay Borrowing' : 'Pay Personal Expense');

    return SizedBox(
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
          _navigateToRepaymentScreen(tabIndex);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFullyPaid ? AppColors.secondary : AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isFullyPaid) ...[
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToRepaymentScreen(int tabIndex) async {
    final movementType = tabIndex == 0
        ? 'Borrowing Repayment'
        : 'Personal Expense Payment';

    final screen = AddOwnerMovementScreen(initialMovementType: movementType);

    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (context) => screen));

    if (result == true && mounted) {
      _reloadDashboardSnapshot();
    }
  }

  BoxDecoration _minimalCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.surfaceContainerHigh),
    );
  }
}
