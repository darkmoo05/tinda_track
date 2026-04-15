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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardRepository _dashboardRepository = DashboardRepository();

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

  void _onAlertAction(String actionLabel) {
    if (actionLabel == 'ADD CASH') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AddOwnerMovementScreen()));
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

  Widget _buildActivityTabs() {
    return Row(children: [_buildPillTab('Transactions', true)]);
  }

  Widget _buildPillTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(DashboardSnapshot dashboard) {
    return Column(
      children: dashboard.activities
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
}
