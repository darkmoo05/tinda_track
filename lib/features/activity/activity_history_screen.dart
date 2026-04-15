import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/architect_app_bar.dart';
import 'widgets/activity_tile.dart';
import 'widgets/date_header.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: ArchitectAppBar(
          title: 'Financial Architect',
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildHistoryList(_getTransactions()),
                  _buildHistoryList(_getOwnerMovements()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceContainerLow, width: 1),
        ),
      ),
      child: TabBar(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant.withOpacity(0.5),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
        tabs: const [
          Tab(text: 'TRANSACTIONS'),
          Tab(text: 'OWNER MOVEMENTS'),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> items) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Movements',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSearchAndFilter(),
        ..._groupItemsByDate(items),
        const SizedBox(height: 100), // Bottom padding for FAB
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEF0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search party, account, or ref ID',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.onSurfaceVariant),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEF0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune_rounded, size: 24, color: AppColors.primary),
        ),
      ],
    );
  }

  List<Widget> _groupItemsByDate(List<Map<String, dynamic>> items) {
    List<Widget> grouped = [];
    String lastDate = '';

    for (var item in items) {
      if (item['date'] != lastDate) {
        lastDate = item['date'];
        grouped.add(ArchitectDateHeader(label: lastDate));
      }
      grouped.add(ArchitectActivityTile(
        title: item['title'],
        type: item['type'],
        reference: item['ref'],
        amount: item['amount'],
        time: item['time'],
        icon: item['icon'],
        iconColor: item['iconColor'],
      ));
    }
    return grouped;
  }

  List<Map<String, dynamic>> _getTransactions() {
    return [
      {
        'date': 'Today',
        'title': 'SM Mart - Grocery',
        'type': 'Cash Out',
        'ref': '9021-X99',
        'amount': '- ₱1,240.50',
        'time': '14:22',
        'icon': Icons.call_received_rounded,
        'iconColor': Colors.green,
      },
      {
        'date': 'Today',
        'title': 'Juan Dela Cruz',
        'type': 'Cash In',
        'ref': 'G-Save Transfer',
        'amount': '+ ₱5,000.00',
        'time': '09:15',
        'icon': Icons.call_made_rounded,
        'iconColor': Colors.blue,
      },
      {
        'date': 'Yesterday',
        'title': 'Meralco Bill',
        'type': 'Cash Out',
        'ref': 'Utilities',
        'amount': '- ₱4,562.18',
        'time': '18:45',
        'icon': Icons.bolt_rounded,
        'iconColor': Colors.amber[800],
      },
      {
        'date': 'Yesterday',
        'title': 'Shell Petron',
        'type': 'Cash Out',
        'ref': 'Fuel',
        'amount': '- ₱2,100.00',
        'time': '07:30',
        'icon': Icons.local_gas_station_rounded,
        'iconColor': Colors.green,
      },
      {
        'date': '20 May 2024',
        'title': 'Monthly Salary',
        'type': 'Cash In',
        'ref': 'Global Corp Inc.',
        'amount': '+ ₱45,000.00',
        'time': '08:00',
        'icon': Icons.account_balance_rounded,
        'iconColor': Colors.blue,
      },
    ];
  }

  List<Map<String, dynamic>> _getOwnerMovements() {
    return [
      {
        'date': 'Today',
        'title': 'Owner Capital Add',
        'type': 'Injection',
        'ref': 'FA-9921',
        'amount': '+ ₱10,000.00',
        'time': '10:00',
        'icon': Icons.add_circle_outline_rounded,
        'iconColor': Colors.purple,
      },
      {
        'date': 'Yesterday',
        'title': 'Owner Draw',
        'type': 'Withdrawal',
        'ref': 'FA-0021',
        'amount': '- ₱2,500.00',
        'time': '16:30',
        'icon': Icons.remove_circle_outline_rounded,
        'iconColor': Colors.red,
      },
      {
        'date': '15 May 2024',
        'title': 'Capital Reinvestment',
        'type': 'Adjustment',
        'ref': 'FA-1102',
        'amount': '+ ₱5,000.00',
        'time': '09:00',
        'icon': Icons.autorenew_rounded,
        'iconColor': Colors.indigo,
      },
    ];
  }
}
