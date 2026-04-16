import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../shared/widgets/architect_app_bar.dart';
import 'data/dashboard_repository.dart';
import 'widgets/activity_item.dart';
import 'widgets/alert_card.dart';
import 'widgets/analytics_card.dart';
import 'widgets/balance_hero_card.dart';
import 'widgets/income_architecture_card.dart';
import '../transactions/add_owner_movement_screen.dart';

enum _DashboardActivityFilter { all, business, personal }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onDataChanged});

  final VoidCallback? onDataChanged;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardRepository _dashboardRepository = DashboardRepository();
  _DashboardActivityFilter _activityFilter = _DashboardActivityFilter.all;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSnapshot>(
      future: _dashboardRepository.loadSnapshot(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            appBar: ArchitectAppBar(title: 'Financial Architect'),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final dashboard = snapshot.data!;

        return Scaffold(
          appBar: const ArchitectAppBar(title: 'Financial Architect'),
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
              if (dashboard.showAlertCard) const SizedBox(height: 24),
              ArchitectBalanceHero(
                balance: _dashboardRepository.formatCurrency(
                  dashboard.walletBalance,
                ),
                label: 'GCash Wallet Balance',
              ),
              const SizedBox(height: 24),
              _buildOnHandCashCard(context, dashboard),
              const SizedBox(height: 24),
              _buildBusinessUsableCashCard(context, dashboard),
              const SizedBox(height: 24),
              ArchitectAnalyticsCard(
                title: 'Charges\nCollected',
                value: _dashboardRepository.formatCurrency(
                  dashboard.recordedFlow,
                ),
                trend: dashboard.flowTrendLabel,
                subtitle: dashboard.flowCaption,
                spots: dashboard.flowSpots,
                xLabels: dashboard.flowLabels,
                dates: dashboard.flowDates,
              ),
              const SizedBox(height: 24),
              _buildOwnerMovementSplit(context, dashboard),
              const SizedBox(height: 24),
              _buildBorrowingRepaymentCard(context, dashboard),
              const SizedBox(height: 24),
              IncomeArchitectureCard(
                walletSpots: dashboard.walletSpots,
                cashSpots: dashboard.cashSpots,
                xLabels: dashboard.xLabels,
                walletTotal: dashboard.walletBalance,
                onHandTotal: dashboard.onHandCash,
              ),
              const SizedBox(height: 32),
              _buildRecentActivityHeader(context),
              const SizedBox(height: 16),
              _buildActivityTabs(),
              const SizedBox(height: 24),
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

    if (actionLabel == 'LOAD WALLET') {
      screen = const AddOwnerMovementScreen(
        initialMovementType: 'Top-up',
        initialDestination: 'GCash',
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

    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => screen!));

    if (saved == true && mounted) {
      widget.onDataChanged?.call();
      setState(() {});
    }
  }

  Widget _buildOnHandCashCard(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ON-HAND CASH',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Icon(
                      Icons.payments_outlined,
                      color: Colors.green[700],
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _dashboardRepository.formatCurrency(dashboard.onHandCash),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Physical currency on-site',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    return Text(
      'Recent Activities',
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBusinessUsableCashCard(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business_center_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Business-Usable Cash',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _dashboardRepository.formatCurrency(dashboard.businessUsableCash),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Excludes personal owner expenses from available business cash.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBreakdownChip(
                label: 'Wallet',
                value: _dashboardRepository.formatCurrency(
                  dashboard.businessWalletBalance,
                ),
              ),
              _buildBreakdownChip(
                label: 'On-hand',
                value: _dashboardRepository.formatCurrency(
                  dashboard.businessOnHandCash,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
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
      ],
    );
  }

  Widget _buildPillTab(String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.surfaceContainerHigh,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(DashboardSnapshot dashboard) {
    final activities = dashboard.activities
        .where((activity) {
          switch (_activityFilter) {
            case _DashboardActivityFilter.all:
              return true;
            case _DashboardActivityFilter.business:
              return activity.scope.toLowerCase() != 'personal';
            case _DashboardActivityFilter.personal:
              return activity.scope.toLowerCase() == 'personal';
          }
        })
        .toList(growable: false);

    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No activities match the selected filter yet.',
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return Column(
      children: activities
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

  Widget _buildOwnerMovementSplit(
    BuildContext context,
    DashboardSnapshot dashboard,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Owner Movement Split',
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
              title: 'Business Funding',
              subtitle: 'Top-up baseline and refills',
              value: _dashboardRepository.formatCurrency(
                dashboard.businessFundingTotal,
              ),
              accentColor: AppColors.secondary,
              icon: Icons.trending_up_rounded,
            ),
            _buildSplitCard(
              title: 'Personal Draws',
              subtitle: 'Owner expenses outside business use',
              value: _dashboardRepository.formatCurrency(
                dashboard.personalExpenseTotal,
              ),
              accentColor: AppColors.error,
              icon: Icons.person_off_rounded,
            ),
          ],
        ),
      ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
}
