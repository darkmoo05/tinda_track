import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/architect_card.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Activity History',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Income'),
            Tab(text: 'Expenses'),
            Tab(text: 'Charges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityList(context),
          _buildActivityList(context), // Dummy for other tabs
          _buildActivityList(context),
          _buildActivityList(context),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildDateHeader(context, 'Today'),
        _buildActivityItem(
          context,
          'GCash Transfer',
          'Juan Dela Cruz',
          '-₱500.00',
          '2:45 PM',
          Icons.account_balance_wallet_rounded,
        ),
        _buildActivityItem(
          context,
          'Direct Deposit',
          'Partner Payout',
          '+₱12,000.00',
          '11:30 AM',
          Icons.add_circle_outline_rounded,
        ),
        const SizedBox(height: 24),
        _buildDateHeader(context, 'Yesterday'),
        _buildActivityItem(
          context,
          'Service Charge',
          'Office Rental',
          '-₱5,000.00',
          'Apr 13',
          Icons.business_center_rounded,
        ),
        _buildActivityItem(
          context,
          'Owner Movement',
          'Capital Top-up',
          '+₱50,000.00',
          'Apr 13',
          Icons.trending_up_rounded,
        ),
        const SizedBox(height: 24),
        _buildDateHeader(context, 'April 12, 2026'),
        _buildActivityItem(
          context,
          'Water Bill',
          'PrimeWater',
          '-₱1,200.00',
          'Apr 12',
          Icons.water_drop_rounded,
        ),
      ],
    );
  }

  Widget _buildDateHeader(BuildContext context, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        date,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    String amount,
    String time,
    IconData icon,
  ) {
    final isPositive = amount.startsWith('+');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ArchitectCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPositive ? AppColors.secondary : AppColors.onSurface,
                  ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
