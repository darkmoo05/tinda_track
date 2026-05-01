import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../core/app_theme.dart';
import '../../core/data/app_database.dart';
import '../../shared/widgets/architect_app_bar.dart';
import '../../shared/widgets/app_side_drawer.dart';
import 'widgets/activity_tile.dart';
import 'widgets/date_header.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  DateTime? _beginDateFilter;
  DateTime? _endDateFilter;
  String? _selectedWalletFilter;

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
        key: _scaffoldKey,
        drawer: const AppSideDrawer(),
        appBar: ArchitectAppBar(
          title: 'PocketLedger',
          onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
                      _buildHistoryList(transactions, showWalletFilters: true),
                      _buildHistoryList(
                        ownerMovements,
                        showWalletFilters: false,
                      ),
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
        unselectedLabelColor: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
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

  Widget _buildHistoryList(
    List<_HistoryRow> items, {
    required bool showWalletFilters,
  }) {
    final filteredItems = _filterItems(
      items,
      applyWalletFilter: showWalletFilters,
    );

    if (items.isNotEmpty && filteredItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSearchAndFilter(showWalletFilters: showWalletFilters),
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
          _buildSearchAndFilter(showWalletFilters: showWalletFilters),
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
        _buildSearchAndFilter(showWalletFilters: showWalletFilters),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Movements',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        FilledButton.icon(
          onPressed: _openLedgerReportSheet,
          icon: const Icon(Icons.assessment_outlined, size: 18),
          label: const Text('Reports'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter({required bool showWalletFilters}) {
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
              color: _beginDateFilter == null && _endDateFilter == null
                  ? const Color(0xFFEEEEF0)
                  : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _pickBeginDateFilter,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 24,
                    color: _beginDateFilter == null && _endDateFilter == null
                        ? AppColors.primary
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (showWalletFilters)
          Row(
            children: [
              Expanded(
                child: _buildWalletFilterCard(
                  label: 'GCash',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  walletKey: 'gcash',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildWalletFilterCard(
                  label: 'Maya',
                  icon: Icons.wallet_rounded,
                  color: AppColors.secondary,
                  walletKey: 'maya',
                ),
              ),
            ],
          ),
        if (_beginDateFilter != null || _endDateFilter != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_beginDateFilter != null)
                Chip(
                  label: Text(
                    'Begin: ${_fullDateFormat.format(_beginDateFilter!)}',
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
                      _beginDateFilter = null;
                    });
                  },
                ),
              if (_endDateFilter != null)
                Chip(
                  label: Text(
                    'End: ${_fullDateFormat.format(_endDateFilter!)}',
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
                      _endDateFilter = null;
                    });
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickBeginDateFilter,
                icon: const Icon(Icons.event_available_rounded, size: 16),
                label: Text(
                  _beginDateFilter == null
                      ? 'Beginning Date'
                      : _fullDateFormat.format(_beginDateFilter!),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickEndDateFilter,
                icon: const Icon(Icons.event_rounded, size: 16),
                label: Text(
                  _endDateFilter == null
                      ? 'End Date'
                      : _fullDateFormat.format(_endDateFilter!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletFilterCard({
    required String label,
    required IconData icon,
    required Color color,
    required String walletKey,
  }) {
    final isSelected = _selectedWalletFilter == walletKey;

    return Material(
      color: isSelected
          ? color.withValues(alpha: 0.14)
          : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedWalletFilter = isSelected ? null : walletKey;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? color : AppColors.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }

  List<_HistoryRow> _filterItems(
    List<_HistoryRow> items, {
    required bool applyWalletFilter,
  }) {
    if (_searchQuery.isEmpty &&
        _beginDateFilter == null &&
        _endDateFilter == null &&
        _selectedWalletFilter == null) {
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
            item.walletAccount,
            item.note,
          ];

          final matchesSearch =
              _searchQuery.isEmpty ||
              fields.any((field) => field.toLowerCase().contains(_searchQuery));
          final itemDate = DateTime(
            item.createdAt.year,
            item.createdAt.month,
            item.createdAt.day,
          );
          final matchesBeginDate =
              _beginDateFilter == null || !itemDate.isBefore(_beginDateFilter!);
          final matchesEndDate =
              _endDateFilter == null || !itemDate.isAfter(_endDateFilter!);
          final isTransaction = item.entryType == 'transaction';
          final isMayaTransaction = _isMayaTransaction(item);
          final matchesWallet =
              !applyWalletFilter ||
              _selectedWalletFilter == null ||
              !isTransaction ||
              (_selectedWalletFilter == 'maya' && isMayaTransaction) ||
              (_selectedWalletFilter == 'gcash' && !isMayaTransaction);

          return matchesSearch &&
              matchesBeginDate &&
              matchesEndDate &&
              matchesWallet;
        })
        .toList(growable: false);
  }

  Future<void> _pickBeginDateFilter() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _beginDateFilter ?? _endDateFilter ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Filter Begin Date',
    );

    if (pickedDate == null) {
      return;
    }

    final normalized = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );

    setState(() {
      _beginDateFilter = normalized;
      if (_endDateFilter != null && _endDateFilter!.isBefore(normalized)) {
        _endDateFilter = normalized;
      }
    });
  }

  Future<void> _pickEndDateFilter() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDateFilter ?? _beginDateFilter ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Filter End Date',
    );

    if (pickedDate == null) {
      return;
    }

    final normalized = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );

    setState(() {
      _endDateFilter = normalized;
      if (_beginDateFilter != null && _beginDateFilter!.isAfter(normalized)) {
        _beginDateFilter = normalized;
      }
    });
  }

  bool _isMayaTransaction(_HistoryRow item) {
    if (item.entryType != 'transaction') {
      return false;
    }

    final walletLabel = item.walletAccount.trim().toLowerCase();
    if (walletLabel.contains('maya')) {
      return true;
    }

    return item.iconKey.startsWith('maya_');
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

      final isOutgoing =
          item.iconKey == 'cash_out' || item.iconKey == 'maya_cash_out';
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
    final isOutgoing =
        item.iconKey == 'cash_out' || item.iconKey == 'maya_cash_out';
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
    final hasWalletAccount = item.walletAccount.trim().isNotEmpty;
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
                          if (hasWalletAccount)
                            _buildDetailRow(
                              'Wallet Account',
                              item.walletAccount,
                            ),
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
          final walletAccount = (row['wallet_account'] as String?) ?? '';
          final rawIconKey = row['icon_key'] as String;
          final iconKey = walletAccount == 'Maya Wallet'
              ? (rawIconKey == 'cash_in'
                    ? 'maya_cash_in'
                    : rawIconKey == 'cash_out'
                    ? 'maya_cash_out'
                    : rawIconKey == 'wallet'
                    ? 'maya_wallet'
                    : rawIconKey)
              : rawIconKey;
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
            walletAccount: walletAccount,
            note: (row['note'] as String?) ?? '',
            amount: (row['amount'] as num).toDouble(),
            tag: row['tag'] as String,
            iconKey: iconKey,
            createdAt: DateTime.parse(row['created_at'] as String),
          );
        })
        .toList(growable: false);
  }

  Future<void> _openLedgerReportSheet() async {
    final now = DateTime.now();
    DateTime beginDate = DateTime(now.year, now.month, 1);
    DateTime endDate = DateTime(now.year, now.month, now.day);
    _ReportFileType selectedType = _ReportFileType.pdf;

    final request = await showModalBottomSheet<_LedgerReportRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickBeginDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: beginDate,
                firstDate: DateTime(now.year - 10),
                lastDate: DateTime(now.year + 10),
                helpText: 'Select Beginning Date',
              );
              if (picked == null) {
                return;
              }
              setSheetState(() {
                beginDate = DateTime(picked.year, picked.month, picked.day);
                if (endDate.isBefore(beginDate)) {
                  endDate = beginDate;
                }
              });
            }

            Future<void> pickEndDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: endDate,
                firstDate: DateTime(now.year - 10),
                lastDate: DateTime(now.year + 10),
                helpText: 'Select End Date',
              );
              if (picked == null) {
                return;
              }
              setSheetState(() {
                endDate = DateTime(picked.year, picked.month, picked.day);
                if (endDate.isBefore(beginDate)) {
                  beginDate = endDate;
                }
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.assessment_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'General Ledger Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pick a beginning and end date, then choose PDF or Excel file output.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDatePickerTile(
                      label: 'Beginning Date',
                      value: _fullDateFormat.format(beginDate),
                      onTap: pickBeginDate,
                    ),
                    const SizedBox(height: 10),
                    _buildDatePickerTile(
                      label: 'End Date',
                      value: _fullDateFormat.format(endDate),
                      onTap: pickEndDate,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'File Format',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('PDF'),
                          selected: selectedType == _ReportFileType.pdf,
                          onSelected: (_) => setSheetState(() {
                            selectedType = _ReportFileType.pdf;
                          }),
                        ),
                        ChoiceChip(
                          label: const Text('Excel'),
                          selected: selectedType == _ReportFileType.excel,
                          onSelected: (_) => setSheetState(() {
                            selectedType = _ReportFileType.excel;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(sheetContext).pop(
                                _LedgerReportRequest(
                                  beginDate: beginDate,
                                  endDate: endDate,
                                  fileType: selectedType,
                                ),
                              );
                            },
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: const Text('Generate'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (request == null || !mounted) {
      return;
    }

    if (request.endDate.isBefore(request.beginDate)) {
      _showSnack(
        'End date must be the same or later than beginning date.',
        isError: true,
      );
      return;
    }

    await _generateGeneralLedgerReport(request);
  }

  Widget _buildDatePickerTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateGeneralLedgerReport(
    _LedgerReportRequest request,
  ) async {
    _showSnack('Preparing report...');

    try {
      final entries = await _loadLedgerEntriesForRange(
        request.beginDate,
        request.endDate,
      );

      if (entries.isEmpty) {
        if (!mounted) {
          return;
        }
        _showSnack('No ledger records found for the selected date range.');
        return;
      }

      final reportsDir = await _resolveSaveDirectory();
      if (reportsDir == null) {
        _showSnack('Report generation canceled. No folder selected.');
        return;
      }

      _showSnack('Generating general ledger report...');

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = path.join(
        reportsDir.path,
        request.fileType == _ReportFileType.pdf
            ? 'general_ledger_$timestamp.pdf'
            : 'general_ledger_$timestamp.xlsx',
      );

      if (request.fileType == _ReportFileType.pdf) {
        final bytes = await _buildPdfReport(
          entries: entries,
          beginDate: request.beginDate,
          endDate: request.endDate,
          totals: _calculateLedgerTotals(entries),
        );
        await File(filePath).writeAsBytes(bytes, flush: true);
      } else {
        final bytes = _buildExcelReport(
          entries: entries,
          beginDate: request.beginDate,
          endDate: request.endDate,
          totals: _calculateLedgerTotals(entries),
        );
        await File(filePath).writeAsBytes(bytes, flush: true);
      }

      if (!mounted) {
        return;
      }

      _showSnack('Report generated successfully. Saved to $filePath');

      if (!_supportsShareSheet) {
        return;
      }

      try {
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              'General Ledger Report (${_fullDateFormat.format(request.beginDate)} - ${_fullDateFormat.format(request.endDate)})',
        );
      } catch (shareError, shareStack) {
        debugPrint(
          'Share failed for generated report: $shareError\n$shareStack',
        );
        _showSnack(
          'Report generated, but sharing is unavailable on this device. File is saved locally.',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Report generation failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      _showSnack('Failed to generate report. Please try again.', isError: true);
    }
  }

  Future<Directory?> _resolveSaveDirectory() async {
    try {
      final fallbackDir = await _resolveReportsDirectory();
      final selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose folder to save General Ledger report',
        initialDirectory: fallbackDir.path,
      );

      if (selectedPath == null || selectedPath.trim().isEmpty) {
        return null;
      }

      final selectedDir = Directory(selectedPath);
      if (!await selectedDir.exists()) {
        await selectedDir.create(recursive: true);
      }
      return selectedDir;
    } catch (error, stackTrace) {
      debugPrint('Directory picker failed: $error\n$stackTrace');
      // Fall back to the app reports folder when directory picker is unavailable.
      return _resolveReportsDirectory();
    }
  }

  bool get _supportsShareSheet => Platform.isAndroid || Platform.isIOS;

  Future<Directory> _resolveReportsDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final reportDir = Directory(path.join(root.path, 'reports'));
    if (!await reportDir.exists()) {
      await reportDir.create(recursive: true);
    }
    return reportDir;
  }

  Future<List<_LedgerExportRow>> _loadLedgerEntriesForRange(
    DateTime beginDate,
    DateTime endDate,
  ) async {
    final start = DateTime(beginDate.year, beginDate.month, beginDate.day);
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.ledgerTable,
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at ASC, id ASC',
    );

    double runningBalance = 0;
    return rows
        .map((row) {
          final createdAt = DateTime.parse(row['created_at'] as String);
          final entryType = row['entry_type'] as String;
          final notes = (row['note'] as String?) ?? '';
          final iconKey = row['icon_key'] as String;
          final amount = (row['amount'] as num).toDouble();
          final isOutflow = iconKey == 'cash_out';
          final inflow = isOutflow ? 0.0 : amount;
          final outflow = isOutflow ? amount : 0.0;
          final chargeAmount = entryType == 'transaction'
              ? _extractChargeAmountFromNote(notes)
              : 0.0;
          final chargeDestination = entryType == 'transaction'
              ? _extractChargeDestinationFromNote(notes)
              : '';
          runningBalance += inflow - outflow;

          return _LedgerExportRow(
            createdAt: createdAt,
            entryType: entryType,
            title: row['title'] as String,
            tag: row['tag'] as String,
            reference: (row['reference'] as String?) ?? '',
            notes: notes,
            inflow: inflow,
            outflow: outflow,
            chargeAmount: chargeAmount,
            chargeDestination: chargeDestination,
            chargeBreakdown: _buildChargeBreakdown(
              amount: amount,
              chargeAmount: chargeAmount,
              chargeDestination: chargeDestination,
              entryType: entryType,
            ),
            runningBalance: runningBalance,
          );
        })
        .toList(growable: false);
  }

  Future<List<int>> _buildPdfReport({
    required List<_LedgerExportRow> entries,
    required DateTime beginDate,
    required DateTime endDate,
    required _LedgerTotals totals,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now());
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            pw.Text(
              'Transaction History Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Period: ${_fullDateFormat.format(beginDate)} - ${_fullDateFormat.format(endDate)}',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              'Generated: $timestamp',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              headers: const [
                'Date & Time',
                'Type',
                'Description',
                'Category',
                'Reference No.',
                'Remarks',
                'Money In',
                'Money Out',
                'Service Fee',
                'Fee Destination',
                'Fee Details',
                'Balance',
              ],
              data: entries
                  .map(
                    (entry) => [
                      dateFormat.format(entry.createdAt),
                      _pdfSafeText(
                        entry.entryType == 'owner_movement'
                            ? 'Owner Movement'
                            : 'Transaction',
                      ),
                      _pdfSafeText(entry.title),
                      _pdfSafeText(entry.tag),
                      _pdfSafeText(entry.reference),
                      _pdfSafeText(entry.notes),
                      entry.inflow > 0 ? _reportCurrency(entry.inflow) : '',
                      entry.outflow > 0 ? _reportCurrency(entry.outflow) : '',
                      entry.chargeAmount > 0
                          ? _reportCurrency(entry.chargeAmount)
                          : '',
                      _pdfSafeText(entry.chargeDestination),
                      _pdfSafeText(entry.chargeBreakdown),
                      _reportCurrency(entry.runningBalance),
                    ],
                  )
                  .toList(growable: false),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Money In: ${_reportCurrency(totals.totalInflow)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Total Money Out: ${_reportCurrency(totals.totalOutflow)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Net Balance: ${_reportCurrency(totals.net)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Total Fees Paid: ${_reportCurrency(totals.totalCharges)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  List<int> _buildExcelReport({
    required List<_LedgerExportRow> entries,
    required DateTime beginDate,
    required DateTime endDate,
    required _LedgerTotals totals,
  }) {
    final excel = ex.Excel.createExcel();
    final sheet = excel['Transaction History'];
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    sheet.appendRow([
      ex.TextCellValue('Transaction History Report'),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
    ]);
    sheet.appendRow([
      ex.TextCellValue(
        'Period: ${_fullDateFormat.format(beginDate)} - ${_fullDateFormat.format(endDate)}',
      ),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
    ]);
    sheet.appendRow([
      ex.TextCellValue(
        'Generated: ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}',
      ),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
    ]);
    sheet.appendRow([
      ex.TextCellValue('Date & Time'),
      ex.TextCellValue('Type'),
      ex.TextCellValue('Description'),
      ex.TextCellValue('Category'),
      ex.TextCellValue('Reference No.'),
      ex.TextCellValue('Remarks'),
      ex.TextCellValue('Money In'),
      ex.TextCellValue('Money Out'),
      ex.TextCellValue('Service Fee'),
      ex.TextCellValue('Fee Destination'),
      ex.TextCellValue('Fee Details'),
      ex.TextCellValue('Balance'),
    ]);

    for (final entry in entries) {
      sheet.appendRow([
        ex.TextCellValue(dateFormat.format(entry.createdAt)),
        ex.TextCellValue(
          entry.entryType == 'owner_movement'
              ? 'Owner Movement'
              : 'Transaction',
        ),
        ex.TextCellValue(entry.title),
        ex.TextCellValue(entry.tag),
        ex.TextCellValue(entry.reference),
        ex.TextCellValue(entry.notes),
        ex.TextCellValue(entry.inflow > 0 ? _reportCurrency(entry.inflow) : ''),
        ex.TextCellValue(
          entry.outflow > 0 ? _reportCurrency(entry.outflow) : '',
        ),
        ex.TextCellValue(
          entry.chargeAmount > 0 ? _reportCurrency(entry.chargeAmount) : '',
        ),
        ex.TextCellValue(entry.chargeDestination),
        ex.TextCellValue(entry.chargeBreakdown),
        ex.TextCellValue(_reportCurrency(entry.runningBalance)),
      ]);
    }

    sheet.appendRow([
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue('TOTALS'),
      ex.TextCellValue(_reportCurrency(totals.totalInflow)),
      ex.TextCellValue(_reportCurrency(totals.totalOutflow)),
      ex.TextCellValue(_reportCurrency(totals.totalCharges)),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(_reportCurrency(totals.net)),
    ]);

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Unable to encode excel bytes.');
    }
    return bytes;
  }

  _LedgerTotals _calculateLedgerTotals(List<_LedgerExportRow> entries) {
    double totalInflow = 0;
    double totalOutflow = 0;
    double totalCharges = 0;

    for (final entry in entries) {
      totalInflow += entry.inflow;
      totalOutflow += entry.outflow;
      totalCharges += entry.chargeAmount;
    }

    return _LedgerTotals(
      totalInflow: totalInflow,
      totalOutflow: totalOutflow,
      totalCharges: totalCharges,
      net: totalInflow - totalOutflow,
    );
  }

  double _extractChargeAmountFromNote(String note) {
    final match = RegExp(
      r'Charge\s*(?:₱|PHP)?\s*([0-9]+(?:,[0-9]{3})*(?:\.[0-9]+)?)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match == null || match.groupCount < 1) {
      return 0;
    }

    final rawAmount = (match.group(1) ?? '').replaceAll(',', '');
    return double.tryParse(rawAmount) ?? 0;
  }

  String _extractChargeDestinationFromNote(String note) {
    final match = RegExp(
      r'Charge\s+routed\s+to\s*([^•]+)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match == null || match.groupCount < 1) {
      return '';
    }
    return (match.group(1) ?? '').trim();
  }

  String _buildChargeBreakdown({
    required double amount,
    required double chargeAmount,
    required String chargeDestination,
    required String entryType,
  }) {
    if (entryType != 'transaction' || chargeAmount <= 0) {
      return '';
    }

    if (chargeDestination.isEmpty) {
      return 'Recorded: ${_reportCurrency(amount)} | Charge: ${_reportCurrency(chargeAmount)}';
    }
    return 'Recorded: ${_reportCurrency(amount)} | Charge: ${_reportCurrency(chargeAmount)} | Routed to: $chargeDestination';
  }

  String _reportCurrency(double amount) {
    return 'PHP ${amount.toStringAsFixed(2)}';
  }

  String _pdfSafeText(String value) {
    return value
        .replaceAll('₱', 'PHP ')
        .replaceAll(RegExp(r'[\u2018\u2019\u201C\u201D]'), '"')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ')
        .trim();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      case 'maya_wallet':
        return Icons.wallet_rounded;
      case 'cash':
        return Icons.payments_outlined;
      case 'cash_in':
        return Icons.call_made_rounded;
      case 'maya_cash_in':
        return Icons.call_made_rounded;
      case 'cash_out':
        return Icons.call_received_rounded;
      case 'maya_cash_out':
        return Icons.call_received_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _colorFor(String iconKey) {
    switch (iconKey) {
      case 'wallet':
        return AppColors.primary;
      case 'maya_wallet':
        return AppColors.secondary;
      case 'cash':
        return AppColors.secondary;
      case 'cash_in':
        return AppColors.secondary;
      case 'maya_cash_in':
        return AppColors.secondary;
      case 'cash_out':
        return AppColors.error;
      case 'maya_cash_out':
        return AppColors.secondary;
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
    required this.walletAccount,
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
  final String walletAccount;
  final String note;
  final String? accountNumber;
  final double amount;
  final String tag;
  final String iconKey;
  final DateTime createdAt;
}

enum _ReportFileType { pdf, excel }

class _LedgerReportRequest {
  const _LedgerReportRequest({
    required this.beginDate,
    required this.endDate,
    required this.fileType,
  });

  final DateTime beginDate;
  final DateTime endDate;
  final _ReportFileType fileType;
}

class _LedgerExportRow {
  const _LedgerExportRow({
    required this.createdAt,
    required this.entryType,
    required this.title,
    required this.tag,
    required this.reference,
    required this.notes,
    required this.inflow,
    required this.outflow,
    required this.chargeAmount,
    required this.chargeBreakdown,
    required this.runningBalance,
    required this.chargeDestination,
  });

  final DateTime createdAt;
  final String entryType;
  final String title;
  final String tag;
  final String reference;
  final String notes;
  final double inflow;
  final double outflow;
  final double chargeAmount;
  final String chargeDestination;
  final String chargeBreakdown;
  final double runningBalance;
}

class _LedgerTotals {
  const _LedgerTotals({
    required this.totalInflow,
    required this.totalOutflow,
    required this.totalCharges,
    required this.net,
  });

  final double totalInflow;
  final double totalOutflow;
  final double totalCharges;
  final double net;
}
