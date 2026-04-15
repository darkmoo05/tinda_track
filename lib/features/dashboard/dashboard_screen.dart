import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/architect_app_bar.dart';
import 'widgets/alert_card.dart';
import 'widgets/balance_hero_card.dart';
import 'widgets/analytics_card.dart';
import 'widgets/activity_item.dart';
import 'widgets/income_architecture_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ArchitectAppBar(title: 'Financial Architect'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ArchitectAlertCard(
            title: 'Low GCash Balance Detected',
            message: 'Your current wallet is below the ₱500.00 threshold.',
            actionLabel: 'TOP UP NOW',
            onAction: () {},
          ),
          const SizedBox(height: 24),
          ArchitectBalanceHero(
            balance: '₱ 14,250.60',
            label: 'GCash Wallet Balance',
            onSend: () {},
            onReceive: () {},
          ),
          const SizedBox(height: 24),
          _buildOnHandCashCard(context),
          const SizedBox(height: 24),
          const ArchitectAnalyticsCard(
            title: 'Net Income',
            value: '₱ 1,840.00',
            trend: '+12%',
          ),
          const SizedBox(height: 24),
          const IncomeArchitectureCard(),
          const SizedBox(height: 32),
          _buildRecentActivityHeader(context),
          const SizedBox(height: 16),
          _buildActivityTabs(),
          const SizedBox(height: 24),
          _buildRecentActivityList(),
          const SizedBox(height: 16),
          _buildViewFullHistory(context),
          const SizedBox(height: 100), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildOnHandCashCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                const Text(
                  '₱ 3,420.00',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Physical currency on-site',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'Log Movement',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.green[700],
                        size: 16,
                      ),
                    ],
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
    return Row(
      children: [
        _buildPillTab('Transactions', true),
        const SizedBox(width: 12),
        _buildPillTab('Owner Movements', false),
      ],
    );
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

  Widget _buildRecentActivityList() {
    return Column(
      children: const [
        ArchitectActivityItem(
          title: 'Meralco Bill Payment',
          subtitle: 'REF: 902182210 • 13 Oct 2023',
          amount: '-₱ 4,520.15',
          tag: 'Merchant',
          icon: Icons.add_circle_outline,
          iconColor: Colors.green,
        ),
        ArchitectActivityItem(
          title: 'Maria Santos',
          subtitle: 'REF: 002133441 • 12 Oct 2023',
          amount: '+₱ 2,500.00',
          tag: 'Transfer',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.primary,
        ),
        ArchitectActivityItem(
          title: '7-Eleven Cash In',
          subtitle: 'REF: 221788222 • 11 Oct 2023',
          amount: '+₱ 1,000.00',
          tag: 'Ops',
          icon: Icons.storefront_rounded,
          iconColor: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildViewFullHistory(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'VIEW FULL ARCHITECTURE HISTORY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
