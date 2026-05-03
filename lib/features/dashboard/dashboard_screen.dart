import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../shared/widgets/architect_app_bar.dart';
import '../../shared/widgets/app_side_drawer.dart';
import '../activity/activity_history_screen.dart';
import '../transactions/add_owner_movement_screen.dart';
import 'data/dashboard_repository.dart';
import 'widgets/activity_item.dart';
import 'widgets/alert_card.dart';
import 'widgets/analytics_card.dart';
import 'widgets/income_architecture_card.dart';

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
              title: 'PocketLedger',
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
              title: 'PocketLedger',
              onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            body: const Center(
              child: Text('Unable to load dashboard right now.'),
            ),
          );
        }

        final dashboard = snapshot.data;
        if (dashboard == null) {
          return Scaffold(
            key: _scaffoldKey,
            drawer: const AppSideDrawer(),
            appBar: ArchitectAppBar(
              title: 'PocketLedger',
              onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            body: const Center(child: Text('No dashboard data available yet.')),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppSideDrawer(),
          appBar: ArchitectAppBar(
            title: 'PocketLedger',
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
              _buildChargesAnalyticsSection(dashboard),
              const SizedBox(height: 16),
              _buildBorrowingRepaymentCard(context, dashboard),
              const SizedBox(height: 24),
              _buildRecentActivityHeader(context),
              const SizedBox(height: 16),
              _buildActivityTabs(),
              const SizedBox(height: 16),
              _buildRecentActivityList(dashboard),
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
          'Wallet Overview',
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
                      title: 'GCASH WALLET',
                      value: _dashboardRepository.formatCurrency(
                        dashboard.walletBalance,
                      ),
                      caption: 'Available balance',
                      icon: Icons.account_balance_wallet_rounded,
                      backgroundColor: AppColors.primary,
                      onTap: () => _openWalletPerspectiveHistory(
                        HistoryWalletPerspective.gcash,
                      ),
                    ),
                    _buildWalletMetricTile(
                      width: tileWidth,
                      title: 'MAYA WALLET',
                      value: _dashboardRepository.formatCurrency(
                        dashboard.mayaWalletBalance,
                      ),
                      caption: 'Available balance',
                      icon: Icons.account_balance_rounded,
                      backgroundColor: AppColors.secondary,
                      onTap: () => _openWalletPerspectiveHistory(
                        HistoryWalletPerspective.maya,
                      ),
                    ),
                    _buildWalletMetricTile(
                      width: tileWidth,
                      title: 'ON-HAND CASH',
                      value: _dashboardRepository.formatCurrency(
                        dashboard.onHandCash,
                      ),
                      caption: 'Physical cash',
                      icon: Icons.payments_outlined,
                      backgroundColor: const Color(0xFF8E6C00),
                      onTap: () => _openWalletPerspectiveHistory(
                        HistoryWalletPerspective.onHand,
                      ),
                    ),
                    _buildWalletMetricTile(
                      width: tileWidth,
                      title: 'CHARGES EARNINGS',
                      value: _dashboardRepository.formatCurrency(
                        dashboard.recordedFlow,
                      ),
                      caption: dashboard.flowTrendLabel,
                      icon: Icons.trending_up_rounded,
                      backgroundColor: AppColors.primaryContainer,
                      titleFontSize: 11,
                      titleLetterSpacing: 0.8,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTotalFundsTile(dashboard),
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
                          maxLines: 1,
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
                  const SizedBox(height: 40),
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

  Widget _buildTotalFundsTile(DashboardSnapshot dashboard) {
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
              const Text(
                'TOTAL FUNDS',
                style: TextStyle(
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
        title: 'Wallet and Cash Balance Trend',
        message:
            'Trend data will appear once wallet activity has been recorded.',
      );
    }

    return IncomeArchitectureCard(
      walletSpots: dashboard.walletSpots,
      mayaSpots: dashboard.mayaSpots,
      cashSpots: dashboard.cashSpots,
      xLabels: dashboard.xLabels,
    );
  }

  Widget _buildChargesAnalyticsSection(DashboardSnapshot dashboard) {
    final safeLength = [
      dashboard.flowSpots.length,
      dashboard.flowLabels.length,
      dashboard.flowDates.length,
    ].reduce((a, b) => a < b ? a : b);

    if (safeLength == 0) {
      return _buildChartPlaceholder(
        title: 'Charges Collected',
        message: 'Charges analytics will appear after transactions are added.',
      );
    }

    return ArchitectAnalyticsCard(
      title: 'Charges\nCollected',
      value: _dashboardRepository.formatCurrency(dashboard.recordedFlow),
      trend: dashboard.flowTrendLabel,
      subtitle: dashboard.flowCaption,
      spots: dashboard.flowSpots.take(safeLength).toList(growable: false),
      xLabels: dashboard.flowLabels.take(safeLength).toList(growable: false),
      dates: dashboard.flowDates.take(safeLength).toList(growable: false),
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
      'Recent Activities',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildActivityTabs() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPillTab(
          'All',
          _activityFilter == _DashboardActivityFilter.all,
          () {
            setState(() => _activityFilter = _DashboardActivityFilter.all);
          },
        ),
        _buildPillTab(
          'Business',
          _activityFilter == _DashboardActivityFilter.business,
          () {
            setState(() => _activityFilter = _DashboardActivityFilter.business);
          },
        ),
        _buildPillTab(
          'Personal',
          _activityFilter == _DashboardActivityFilter.personal,
          () {
            setState(() => _activityFilter = _DashboardActivityFilter.personal);
          },
        ),
        _buildPillTab(
          'Transactions',
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

  Widget _buildRecentActivityList(DashboardSnapshot dashboard) {
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

    final recentActivities = activities.take(5).toList(growable: false);

    if (recentActivities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _minimalCardDecoration(),
        child: const Text(
          'No activities match the selected filter yet.',
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
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
    final outstanding = dashboard.netBorrowOutstanding;
    final outstandingColor = outstanding > 0
        ? AppColors.error
        : (outstanding < 0 ? AppColors.secondary : AppColors.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _minimalCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Borrowing Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSplitCard(
                title: 'Borrowed',
                subtitle: 'Total personal funds taken by owner',
                value: _dashboardRepository.formatCurrency(
                  dashboard.totalBorrowed,
                ),
                accentColor: AppColors.primary,
                icon: Icons.call_received_rounded,
              ),
              _buildSplitCard(
                title: 'Repaid',
                subtitle: 'Total personal funds returned to business',
                value: _dashboardRepository.formatCurrency(
                  dashboard.totalRepaid,
                ),
                accentColor: AppColors.secondary,
                icon: Icons.call_made_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Owner Credit Outstanding: ${_dashboardRepository.formatCurrency(outstanding)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: outstandingColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitCard({
    required String title,
    required String subtitle,
    required String value,
    required Color accentColor,
    required IconData icon,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _minimalCardDecoration(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
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

  BoxDecoration _minimalCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.surfaceContainerHigh),
    );
  }
}
