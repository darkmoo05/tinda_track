import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../core/data/app_database.dart';
import '../../shared/widgets/architect_app_bar.dart';
import 'widgets/activity_tile.dart';
import 'widgets/date_header.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final AppDatabase _database = AppDatabase.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );
  final DateFormat _fullDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  late Future<List<_HistoryRow>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

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
              icon: const Icon(
                Icons.search_rounded,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: FutureBuilder<List<_HistoryRow>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allRows = snapshot.data!;
            final transactions = allRows
                .where((row) => row.entryType == 'transaction')
                .toList();
            final ownerMovements = allRows
                .where((row) => row.entryType == 'owner_movement')
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildHistoryList(transactions),
                      _buildHistoryList(ownerMovements),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
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

  Widget _buildHistoryList(List<_HistoryRow> items) {
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSearchAndFilter(),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 32,
                  color: AppColors.onSurfaceVariant,
                ),
                SizedBox(height: 12),
                Text(
                  'No history yet',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 6),
                Text(
                  'New entries will appear here once you save transactions or owner movements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildSearchAndFilter(),
        ..._groupItemsByDate(items),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildHeader() {
    return const Row(
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
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
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
          child: const Icon(
            Icons.tune_rounded,
            size: 24,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  List<Widget> _groupItemsByDate(List<_HistoryRow> items) {
    final grouped = <Widget>[];
    String lastDate = '';

    for (final item in items) {
      final dateLabel = _dateLabel(item.createdAt);
      if (dateLabel != lastDate) {
        lastDate = dateLabel;
        grouped.add(ArchitectDateHeader(label: dateLabel));
      }

      final isOutgoing = item.iconKey == 'cash_out';
      grouped.add(
        ArchitectActivityTile(
          title: item.title,
          type: item.tag,
          reference: item.reference,
          amount:
              '${isOutgoing ? '-' : '+'} ${_currencyFormat.format(item.amount)}',
          time: _timeFormat.format(item.createdAt),
          icon: _iconFor(item.iconKey),
          iconColor: _colorFor(item.iconKey),
        ),
      );
    }

    return grouped;
  }

  Future<List<_HistoryRow>> _loadHistory() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.ledgerTable,
      orderBy: 'created_at DESC, id DESC',
    );

    return rows
        .map((row) {
          final entryType = row['entry_type'] as String;
          final reference = row['reference'] as String;
          final displayReference = entryType == 'transaction'
              ? _resolveTransactionAccountNumber(
                  reference,
                  (row['note'] as String?) ?? '',
                )
              : reference;

          return _HistoryRow(
            entryType: entryType,
            title: row['title'] as String,
            reference: displayReference,
            amount: (row['amount'] as num).toDouble(),
            tag: row['tag'] as String,
            iconKey: row['icon_key'] as String,
            createdAt: DateTime.parse(row['created_at'] as String),
          );
        })
        .toList(growable: false);
  }

  String _resolveTransactionAccountNumber(String reference, String note) {
    final numericRef = reference.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericRef.isNotEmpty) {
      return numericRef;
    }

    final match = RegExp(
      r'Account\s*([0-9]+)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }

    return reference;
  }

  String _dateLabel(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return _fullDateFormat.format(dateTime);
  }

  IconData _iconFor(String iconKey) {
    switch (iconKey) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'cash':
        return Icons.payments_outlined;
      case 'cash_in':
        return Icons.call_made_rounded;
      case 'cash_out':
        return Icons.call_received_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _colorFor(String iconKey) {
    switch (iconKey) {
      case 'wallet':
        return AppColors.primary;
      case 'cash':
        return AppColors.secondary;
      case 'cash_in':
        return AppColors.secondary;
      case 'cash_out':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}

class _HistoryRow {
  const _HistoryRow({
    required this.entryType,
    required this.title,
    required this.reference,
    required this.amount,
    required this.tag,
    required this.iconKey,
    required this.createdAt,
  });

  final String entryType;
  final String title;
  final String reference;
  final double amount;
  final String tag;
  final String iconKey;
  final DateTime createdAt;
}
