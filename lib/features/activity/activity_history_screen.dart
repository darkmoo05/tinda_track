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
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );
  final DateFormat _fullDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  late Future<List<_HistoryRow>> _historyFuture;
  String _searchQuery = '';
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final filteredItems = _filterItems(items);

    if (items.isNotEmpty && filteredItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSearchAndFilter(),
          const SizedBox(height: 20),
          _buildEmptyState(
            title: 'No matching transactions',
            message:
                'Try searching by title, account number, reference ID, notes, or date.',
          ),
          const SizedBox(height: 100),
        ],
      );
    }

    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSearchAndFilter(),
          const SizedBox(height: 20),
          _buildEmptyState(
            title: 'No history yet',
            message:
                'New entries will appear here once you save transactions or owner movements.',
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
        ..._groupItemsByDate(filteredItems),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEmptyState({required String title, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.history_rounded,
            size: 32,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEF0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search account, ref ID, party, or note',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: _selectedDateFilter == null
                  ? const Color(0xFFEEEEF0)
                  : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _pickDateFilter,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 24,
                    color: _selectedDateFilter == null
                        ? AppColors.primary
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_selectedDateFilter != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(
                  'Date: ${_fullDateFormat.format(_selectedDateFilter!)}',
                ),
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                side: BorderSide.none,
                deleteIcon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                onDeleted: () {
                  setState(() {
                    _selectedDateFilter = null;
                  });
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<_HistoryRow> _filterItems(List<_HistoryRow> items) {
    if (_searchQuery.isEmpty && _selectedDateFilter == null) {
      return items;
    }

    return items
        .where((item) {
          final fields = [
            item.title,
            item.tag,
            item.reference,
            item.rawReference,
            item.accountNumber ?? '',
            item.note,
          ];

          final matchesSearch =
              _searchQuery.isEmpty ||
              fields.any((field) => field.toLowerCase().contains(_searchQuery));
          final matchesDate =
              _selectedDateFilter == null ||
              _isSameDate(item.createdAt, _selectedDateFilter!);

          return matchesSearch && matchesDate;
        })
        .toList(growable: false);
  }

  Future<void> _pickDateFilter() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Filter Transactions By Date',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDateFilter = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
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
          onTap: () => _showTransactionDetails(item),
        ),
      );
    }

    return grouped;
  }

  Future<void> _showTransactionDetails(_HistoryRow item) async {
    final isOutgoing = item.iconKey == 'cash_out';
    final accentColor = isOutgoing ? AppColors.error : AppColors.secondary;
    final amountText =
        '${isOutgoing ? '-' : '+'} ${_currencyFormat.format(item.amount)}';
    final dateTimeText =
        '${_fullDateFormat.format(item.createdAt)} ${_timeFormat.format(item.createdAt)}';
    final entryTypeLabel = item.entryType == 'transaction'
        ? 'Transaction'
        : 'Owner Movement';
    final hasDistinctReferenceId =
        item.rawReference.trim().isNotEmpty &&
        item.rawReference.trim() != (item.accountNumber ?? '').trim();
    final hasAccountNumber = (item.accountNumber ?? '').trim().isNotEmpty;
    final hasNotes = item.note.trim().isNotEmpty;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              color: AppColors.surfaceContainerLowest,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  entryTypeLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                amountText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Title', item.title),
                          _buildDetailRow('Category', item.tag),
                          if (hasDistinctReferenceId)
                            _buildDetailRow('Reference ID', item.rawReference),
                          if (hasAccountNumber)
                            _buildDetailRow(
                              'Account Number',
                              item.accountNumber!,
                            ),
                          if (!hasDistinctReferenceId && !hasAccountNumber)
                            _buildDetailRow('Reference ID', item.rawReference),
                          _buildDetailRow(
                            'Amount',
                            amountText,
                            valueColor: accentColor,
                          ),
                          _buildDetailRow('Date & Time', dateTimeText),
                          if (hasNotes) _buildNotesSection(item.note),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: 6),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.06),
                  AppColors.surfaceContainerLowest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurface,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
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
            rawReference: reference,
            accountNumber: entryType == 'transaction' ? displayReference : null,
            note: (row['note'] as String?) ?? '',
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
    required this.rawReference,
    required this.note,
    required this.amount,
    required this.tag,
    required this.iconKey,
    required this.createdAt,
    this.accountNumber,
  });

  final String entryType;
  final String title;
  final String reference;
  final String rawReference;
  final String note;
  final String? accountNumber;
  final double amount;
  final String tag;
  final String iconKey;
  final DateTime createdAt;
}
