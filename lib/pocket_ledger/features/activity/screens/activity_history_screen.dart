import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'dart:io';

import '../../../../core/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
import '../widgets/activity_tile.dart';
import '../widgets/date_header.dart';

enum HistoryWalletPerspective { gcash, maya, onHand }

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({
    super.key,
    this.openDrawer,
    this.initialWalletPerspective,
  });

  final VoidCallback? openDrawer;
  final HistoryWalletPerspective? initialWalletPerspective;

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

  Timer? _debounce;
  bool _isLoading = true;
  List<_HistoryRow> _transactions = [];
  List<_HistoryRow> _ownerMovements = [];
  List<Object> _txDisplayList = [];
  List<Object> _movDisplayList = [];
  String _searchQuery = '';
  DateTime? _beginDateFilter;
  DateTime? _endDateFilter;
  String? _selectedWalletFilter;

  @override
  void initState() {
    super.initState();
    _selectedWalletFilter = _walletFilterFromPerspective(
      widget.initialWalletPerspective,
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: ArchitectAppBar(
          title: context.l10n.appTitle,
          onSettingsPressed: widget.openDrawer,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildHistoryList(
                          _transactions,
                          _txDisplayList,
                          showWalletFilters: true,
                        ),
                        _buildHistoryList(
                          _ownerMovements,
                          _movDisplayList,
                          showWalletFilters: false,
                        ),
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
        tabs: [
          Tab(text: context.l10n.transactions),
          Tab(text: context.l10n.ownerMovements),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    List<_HistoryRow> allItems,
    List<Object> displayList, {
    required bool showWalletFilters,
  }) {
    if (allItems.isNotEmpty && displayList.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSearchAndFilter(showWalletFilters: showWalletFilters),
          const SizedBox(height: 20),
          _buildEmptyState(
            title: context.l10n.noMatchingTransactions,
            message: context.l10n.trySearchingBy,
          ),
          const SizedBox(height: 100),
        ],
      );
    }

    if (allItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildEmptyState(
            title: context.l10n.noHistoryYet,
            message: context.l10n.newEntriesWillAppear,
          ),
          const SizedBox(height: 100),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: displayList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchAndFilter(showWalletFilters: showWalletFilters),
              const SizedBox(height: 20),
            ],
          );
        }
        final item = displayList[index - 1];
        if (item is String) {
          return ArchitectDateHeader(label: item);
        }
        return _buildTile(item as _HistoryRow);
      },
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
    return ScreenHeaderCard(
      title: context.l10n.movements,
      subtitle: context.l10n.walletHistorySubtitle,
      trailing: OutlinedButton.icon(
        onPressed: _openLedgerReportSheet,
        icon: const Icon(Icons.download_rounded, size: 18, color: Colors.white),
        label: Text(
          context.l10n.reports,
          style: const TextStyle(color: Colors.white),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white54),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter({required bool showWalletFilters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              final newQuery = value.trim().toLowerCase();
              if (newQuery == _searchQuery) return;
              setState(() => _searchQuery = newQuery);
              _debounce?.cancel();
              _debounce = Timer(
                const Duration(milliseconds: 300),
                _applyFilters,
              );
            },
            decoration: InputDecoration(
              hintText: context.l10n.searchAccountRefParty,
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
                        _debounce?.cancel();
                        setState(() => _searchQuery = '');
                        _applyFilters();
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
        if (showWalletFilters) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildWalletFilterChip(
                label: context.l10n.filterAll,
                icon: Icons.grid_view_rounded,
                color: AppColors.primary,
                walletKey: null,
              ),
              _buildWalletFilterChip(
                label: context.l10n.gcash,
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                walletKey: 'gcash',
              ),
              _buildWalletFilterChip(
                label: context.l10n.maya,
                icon: Icons.wallet_rounded,
                color: AppColors.secondary,
                walletKey: 'maya',
              ),
              _buildWalletFilterChip(
                label: context.l10n.onHand,
                icon: Icons.payments_outlined,
                color: const Color(0xFF8E6C00),
                walletKey: 'on_hand',
              ),
            ],
          ),
        ],
        if (_beginDateFilter != null || _endDateFilter != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_beginDateFilter != null)
                Chip(
                  label: Text(
                    '${context.l10n.beginningDate}: ${_fullDateFormat.format(_beginDateFilter!)}',
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
                    _beginDateFilter = null;
                    _applyFilters();
                  },
                ),
              if (_endDateFilter != null)
                Chip(
                  label: Text(
                    '${context.l10n.endDate}: ${_fullDateFormat.format(_endDateFilter!)}',
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
                    _endDateFilter = null;
                    _applyFilters();
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickBeginDateFilter,
                icon: const Icon(Icons.event_available_rounded, size: 16),
                label: Text(
                  _beginDateFilter == null
                      ? context.l10n.beginningDate
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
                      ? context.l10n.endDate
                      : _fullDateFormat.format(_endDateFilter!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletFilterChip({
    required String label,
    required IconData icon,
    required Color color,
    required String? walletKey,
  }) {
    final isSelected = _selectedWalletFilter == walletKey;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) {
        _selectedWalletFilter = walletKey == null || isSelected
            ? null
            : walletKey;
        _applyFilters();
      },
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? color : AppColors.onSurfaceVariant,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isSelected ? color : AppColors.onSurface,
        ),
      ),
      selectedColor: color.withValues(alpha: 0.14),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected
            ? color.withValues(alpha: 0.35)
            : AppColors.outlineVariant.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  List<_HistoryRow> _filterItems(
    List<_HistoryRow> items, {
    required bool applyWalletFilter,
  }) {
    final hideTopUpRowsInTransactionsView =
        applyWalletFilter && _selectedWalletFilter == null;

    if (_searchQuery.isEmpty &&
        _beginDateFilter == null &&
        _endDateFilter == null &&
        _selectedWalletFilter == null) {
      if (!hideTopUpRowsInTransactionsView) {
        return items;
      }

      return items
          .where((item) => !_isTopUpPerspectiveRow(item))
          .toList(growable: false);
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
          final matchesWallet =
              !applyWalletFilter ||
              _selectedWalletFilter == null ||
              _matchesWalletPerspective(item, _selectedWalletFilter!);
          final matchesTopUpVisibility =
              !hideTopUpRowsInTransactionsView || !_isTopUpPerspectiveRow(item);

          return matchesSearch &&
              matchesBeginDate &&
              matchesEndDate &&
              matchesWallet &&
              matchesTopUpVisibility;
        })
        .toList(growable: false);
  }

  bool _isTopUpPerspectiveRow(_HistoryRow item) {
    if (item.entryType != 'owner_movement') {
      return false;
    }

    final movementType = (item.ownerMovementType ?? '').trim().toLowerCase();
    return movementType == 'top-up' || movementType == 'initial capital';
  }

  bool _isCashTransferPerspectiveRow(_HistoryRow item) {
    if (item.entryType != 'owner_movement') {
      return false;
    }

    final movementType = (item.ownerMovementType ?? '').trim().toLowerCase();
    return movementType == 'cash transfer (on-hand to wallet)';
  }

  bool _isBorrowedFundsPerspectiveRow(_HistoryRow item) {
    if (item.entryType != 'owner_movement') {
      return false;
    }

    final movementType = (item.ownerMovementType ?? '').trim().toLowerCase();
    return movementType == 'borrowed funds' ||
        movementType == 'borrowed funds repayment';
  }

  bool _isFeeMovementPerspectiveRow(_HistoryRow item) {
    if (item.entryType != 'owner_movement') {
      return false;
    }

    final movementType = (item.ownerMovementType ?? '').trim().toLowerCase();
    return movementType == 'fee withdrawal' || movementType == 'fee transfer';
  }

  bool _isTransactionLogRow(_HistoryRow item) {
    return item.entryType == 'transaction' ||
        _isCashTransferPerspectiveRow(item) ||
        _isBorrowedFundsPerspectiveRow(item) ||
        _isFeeMovementPerspectiveRow(item);
  }

  Future<void> _pickBeginDateFilter() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _beginDateFilter ?? _endDateFilter ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: context.l10n.filterBeginDate,
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
    _applyFilters();
  }

  Future<void> _pickEndDateFilter() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDateFilter ?? _beginDateFilter ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: context.l10n.filterEndDate,
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
    _applyFilters();
  }

  bool _isTransactionPerspectiveRow(_HistoryRow item) {
    if (item.entryType == 'transaction') {
      return true;
    }

    if (item.entryType != 'owner_movement') {
      return false;
    }

    final movementType = (item.ownerMovementType ?? '').trim().toLowerCase();
    return movementType == 'top-up' ||
        movementType == 'initial capital' ||
        movementType == 'cash transfer (on-hand to wallet)' ||
        movementType == 'borrowed funds' ||
        movementType == 'borrowed funds repayment' ||
        movementType == 'fee withdrawal' ||
        movementType == 'fee transfer';
  }

  bool _matchesWalletPerspective(_HistoryRow item, String walletFilter) {
    final normalizedFilter = walletFilter.toLowerCase();
    final walletKey = _normalizeWalletKey(item.walletAccount);

    if (item.entryType == 'transaction') {
      if (normalizedFilter == 'on_hand') {
        // On-hand cash card logs all inflow/outflow movements AND any
        // transaction that carries a service fee — the fee always has an
        // on-hand cash dimension (either the fee is received as cash or it
        // reduces the cash the customer receives).
        return item.onHandDelta != 0 || item.chargeAmount > 0;
      }

      if (walletKey == normalizedFilter) {
        return true;
      }

      // Also surface transactions whose fee is routed to this wallet
      // (e.g. a cash-out where the fee stays in GCash).
      return item.chargeAmount > 0 &&
          item.chargeDestinationKey == normalizedFilter;
    }

    if (item.entryType == 'owner_movement') {
      final movementType = (item.ownerMovementType ?? '').trim().toLowerCase();
      final isTopUp =
          movementType == 'top-up' || movementType == 'initial capital';
      final isCashTransfer =
          movementType == 'cash transfer (on-hand to wallet)';
      final isBorrowedFunds =
          movementType == 'borrowed funds' ||
          movementType == 'borrowed funds repayment';
      final isFeeMovement =
          movementType == 'fee withdrawal' || movementType == 'fee transfer';
      if (!isTopUp && !isCashTransfer && !isBorrowedFunds && !isFeeMovement) {
        return false;
      }

      if (isCashTransfer && normalizedFilter == 'on_hand') {
        return item.onHandDelta != 0 || item.chargeAmount > 0;
      }

      // Fee withdrawals/transfers: match the source wallet (walletAccount)
      // AND surface in on_hand if the fee itself is routed there.
      if (isFeeMovement) {
        if (walletKey == normalizedFilter) return true;
        if (normalizedFilter == 'on_hand') {
          return item.onHandDelta != 0;
        }
        return false;
      }

      if (walletKey == normalizedFilter) {
        return true;
      }

      // Surface owner movements whose fee is routed to a different wallet/cash.
      return item.chargeAmount > 0 &&
          item.chargeDestinationKey == normalizedFilter;
    }

    return false;
  }

  String? _walletFilterFromPerspective(HistoryWalletPerspective? perspective) {
    switch (perspective) {
      case HistoryWalletPerspective.gcash:
        return 'gcash';
      case HistoryWalletPerspective.maya:
        return 'maya';
      case HistoryWalletPerspective.onHand:
        return 'on_hand';
      case null:
        return null;
    }
  }

  String _normalizeWalletKey(String walletAccount) {
    final normalized = walletAccount.trim().toLowerCase();
    if (normalized.contains('maya')) {
      return 'maya';
    }
    if (normalized.contains('gcash')) {
      return 'gcash';
    }
    if (normalized.contains('on-hand') || normalized.contains('on hand')) {
      return 'on_hand';
    }
    return '';
  }

  void _applyFilters() {
    if (!mounted) return;
    final filteredTx = _filterItems(_transactions, applyWalletFilter: true);
    final filteredMov = _filterItems(_ownerMovements, applyWalletFilter: false);
    setState(() {
      _txDisplayList = _buildGroupedDisplayList(filteredTx);
      _movDisplayList = _buildGroupedDisplayList(filteredMov);
    });
  }

  List<Object> _buildGroupedDisplayList(List<_HistoryRow> items) {
    final result = <Object>[];
    String lastDate = '';
    for (final item in items) {
      final dateLabel = _dateLabel(item.createdAt);
      if (dateLabel != lastDate) {
        lastDate = dateLabel;
        result.add(dateLabel);
      }
      result.add(item);
    }
    return result;
  }

  Widget _buildTile(_HistoryRow item) {
    final displayAmount = _resolveDisplayAmount(item);
    final isWalletOutflow = _isWalletOutflow(item);
    final tileColor = _isTransactionLogRow(item)
        ? (isWalletOutflow ? AppColors.error : AppColors.secondary)
        : (isWalletOutflow ? AppColors.error : _colorFor(item.iconKey));
    return ArchitectActivityTile(
      title: item.title,
      subtitle: _buildTileSubtitle(item),
      supportingText: _buildTileSupportingText(item),
      amount:
          '${isWalletOutflow ? '−' : '+'} ${_currencyFormat.format(displayAmount)}',
      time: _timeFormat.format(item.createdAt),
      icon: _iconFor(item.iconKey),
      iconColor: tileColor,
      onTap: () => _showTransactionDetails(item),
    );
  }

  Future<void> _showTransactionDetails(_HistoryRow item) async {
    final isWalletOutflow = _isWalletOutflow(item);
    final accentColor = _isTransactionLogRow(item)
        ? (isWalletOutflow ? AppColors.error : AppColors.secondary)
        : (isWalletOutflow ? AppColors.error : _colorFor(item.iconKey));
    final displayAmount = _resolveDisplayAmount(item);
    final amountText =
        '${isWalletOutflow ? '−' : '+'} ${_currencyFormat.format(displayAmount)}';
    final dateTimeText =
        '${_fullDateFormat.format(item.createdAt)} ${_timeFormat.format(item.createdAt)}';
    final entryTypeLabel = _isTransactionLogRow(item)
        ? context.l10n.historyTransactionLabel
        : context.l10n.historyOwnerActivityLabel;
    final detailsTitle = _isTransactionLogRow(item)
        ? context.l10n.transactionBreakdown
        : context.l10n.entryDetails;
    final hasDistinctReferenceId =
        item.rawReference.trim().isNotEmpty &&
        item.rawReference.trim() != (item.accountNumber ?? '').trim();
    final hasAccountNumber = (item.accountNumber ?? '').trim().isNotEmpty;
    final hasWalletAccount = item.walletAccount.trim().isNotEmpty;
    final hasNotes = item.note.trim().isNotEmpty;

    final isMaya = _normalizeWalletKey(item.walletAccount) == 'maya';
    final double walletDelta = isMaya ? item.mayaWalletDelta : item.walletDelta;
    final double afterWalletBalance = isMaya
        ? item.postMayaBalance
        : item.postGcashBalance;
    final double beforeWalletBalance = afterWalletBalance - walletDelta;
    final double afterOnHandBalance = item.postOnHandBalance;
    final double beforeOnHandBalance = afterOnHandBalance - item.onHandDelta;
    final walletLabel = hasWalletAccount
        ? _displayWalletAccountLabel(item.walletAccount)
        : '';
    final categoryLine = hasWalletAccount
        ? '${item.title} · $walletLabel'
        : item.title;

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
                    // ── Gradient Header ─────────────────────────────────
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
                          Text(
                            detailsTitle,
                            style: const TextStyle(
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

                    // ── Body ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Info Card ──────────────────────────────
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildIconInfoRow(
                                  Icons.sell_outlined,
                                  categoryLine,
                                  hasDivider: true,
                                ),
                                if (hasDistinctReferenceId)
                                  _buildIconInfoRow(
                                    Icons.tag_rounded,
                                    '${context.l10n.referenceNo}: ${item.rawReference}',
                                    hasDivider:
                                        hasAccountNumber ||
                                        item.chargeAmount > 0,
                                  ),
                                if (hasAccountNumber)
                                  _buildIconInfoRow(
                                    Icons.person_outline_rounded,
                                    '${context.l10n.historyAccountLabel}: ${item.accountNumber!}',
                                    hasDivider: item.chargeAmount > 0,
                                  ),
                                if (!hasDistinctReferenceId &&
                                    !hasAccountNumber &&
                                    item.rawReference.trim().isNotEmpty)
                                  _buildIconInfoRow(
                                    Icons.tag_rounded,
                                    '${context.l10n.referenceNo}: ${item.rawReference}',
                                    hasDivider: item.chargeAmount > 0,
                                  ),
                                if (item.chargeAmount > 0)
                                  _buildIconInfoRow(
                                    Icons.receipt_long_outlined,
                                    '${context.l10n.serviceFee}: ${_currencyFormat.format(item.chargeAmount)}',
                                    valueColor: accentColor,
                                    hasDivider: true,
                                  ),
                                _buildIconInfoRow(
                                  Icons.schedule_rounded,
                                  dateTimeText,
                                  hasDivider: false,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Balance Monitor ─────────────────────────
                          const Text(
                            'BALANCE MONITOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasWalletAccount) ...[
                                Expanded(
                                  child: _buildBalanceCard(
                                    label: walletLabel,
                                    icon: Icons.account_balance_wallet_outlined,
                                    beforeBalance: beforeWalletBalance,
                                    afterBalance: afterWalletBalance,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: _buildBalanceCard(
                                  label: context.l10n.onHand,
                                  icon: Icons.payments_outlined,
                                  beforeBalance: beforeOnHandBalance,
                                  afterBalance: afterOnHandBalance,
                                ),
                              ),
                            ],
                          ),

                          // ── Notes ───────────────────────────────────
                          if (hasNotes) _buildNotesSection(item.note),
                        ],
                      ),
                    ),

                    // ── Close Button ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(context.l10n.close),
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

  Widget _buildIconInfoRow(
    IconData icon,
    String text, {
    Color? valueColor,
    bool hasDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: valueColor ?? AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 14,
            endIndent: 14,
            color: AppColors.surfaceContainerHigh,
          ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required String label,
    required IconData icon,
    required double beforeBalance,
    required double afterBalance,
  }) {
    final beforeText = _currencyFormat.format(beforeBalance);
    final afterText = _currencyFormat.format(afterBalance);
    final diff = afterBalance - beforeBalance;
    final isIncreased = diff > 0;
    final isUnchanged = diff == 0;
    final trendIcon = isUnchanged
        ? Icons.trending_flat_rounded
        : isIncreased
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final trendColor = isUnchanged
        ? AppColors.onSurfaceVariant
        : isIncreased
        ? AppColors.secondary
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Before',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            beforeText,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'After',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(trendIcon, size: 12, color: trendColor),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            afterText,
            style: TextStyle(
              fontSize: 13,
              color: trendColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.sticky_note_2_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                SizedBox(width: 5),
                Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadHistory() async {
    final db = await _database.database;
    // Load ASC so we can compute accurate running (post) balances.
    final rows = await db.query(
      AppDatabase.ledgerTable,
      orderBy: 'created_at ASC, id ASC',
    );

    double runningGcash = 0;
    double runningMaya = 0;
    double runningOnHand = 0;

    final allRows = <_HistoryRow>[];
    for (final row in rows) {
      final entryType = row['entry_type'] as String;
      final reference = row['reference'] as String;
      final walletAccount = (row['wallet_account'] as String?) ?? '';
      final note = (row['note'] as String?) ?? '';
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
          ? _resolveTransactionAccountNumber(reference, note)
          : reference;

      final walletDelta = (row['wallet_delta'] as num?)?.toDouble() ?? 0;
      final mayaWalletDelta =
          (row['maya_wallet_delta'] as num?)?.toDouble() ?? 0;
      final onHandDelta = (row['on_hand_delta'] as num?)?.toDouble() ?? 0;

      runningGcash += walletDelta;
      runningMaya += mayaWalletDelta;
      runningOnHand += onHandDelta;

      allRows.add(
        _HistoryRow(
          entryType: entryType,
          title: row['title'] as String,
          reference: displayReference,
          rawReference: reference,
          accountNumber: entryType == 'transaction' ? displayReference : null,
          walletAccount: walletAccount,
          note: note,
          amount: (row['amount'] as num).toDouble(),
          tag: row['tag'] as String,
          iconKey: iconKey,
          createdAt: DateTime.parse(row['created_at'] as String),
          ownerMovementType: row['owner_movement_type'] as String?,
          onHandDelta: onHandDelta,
          walletDelta: walletDelta,
          mayaWalletDelta: mayaWalletDelta,
          chargeAmount: _extractChargeAmountFromNote(note),
          chargeDestinationKey: _extractChargeDestinationKeyFromNote(note),
          postGcashBalance: runningGcash,
          postMayaBalance: runningMaya,
          postOnHandBalance: runningOnHand,
        ),
      );
    }

    // Reverse for DESC display order.
    final allRowsDesc = allRows.reversed.toList(growable: false);

    if (!mounted) return;
    final txRows = allRowsDesc.where(_isTransactionPerspectiveRow).toList();
    final movRows = allRowsDesc
        .where((row) => row.entryType == 'owner_movement')
        .toList();
    setState(() {
      _transactions = txRows;
      _ownerMovements = movRows;
      _isLoading = false;
      _txDisplayList = _buildGroupedDisplayList(
        _filterItems(txRows, applyWalletFilter: true),
      );
      _movDisplayList = _buildGroupedDisplayList(
        _filterItems(movRows, applyWalletFilter: false),
      );
    });
  }

  String? _extractChargeDestinationKeyFromNote(String note) {
    final match = RegExp(
      r'Charge\s+routed\s+to\s*([^•]+)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match == null || match.groupCount < 1) {
      return null;
    }

    return _normalizeWalletKey((match.group(1) ?? '').trim());
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
                helpText: context.l10n.selectBeginningDate,
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
                helpText: context.l10n.selectEndDate,
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
                      children: [
                        const Icon(
                          Icons.assessment_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.generalLedgerReport,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.generalLedgerReportDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDatePickerTile(
                      label: context.l10n.beginningDate,
                      value: _fullDateFormat.format(beginDate),
                      onTap: pickBeginDate,
                    ),
                    const SizedBox(height: 10),
                    _buildDatePickerTile(
                      label: context.l10n.endDate,
                      value: _fullDateFormat.format(endDate),
                      onTap: pickEndDate,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.fileFormat,
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
                          label: Text(context.l10n.pdf),
                          selected: selectedType == _ReportFileType.pdf,
                          onSelected: (_) => setSheetState(() {
                            selectedType = _ReportFileType.pdf;
                          }),
                        ),
                        ChoiceChip(
                          label: Text(context.l10n.excel),
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
                            child: Text(context.l10n.cancel),
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
                            label: Text(context.l10n.generate),
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
      _showSnack(context.l10n.endDateValidationMessage, isError: true);
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
    _showSnack(context.l10n.preparingReport);

    try {
      final entries = await _loadLedgerEntriesForRange(
        request.beginDate,
        request.endDate,
      );

      if (entries.isEmpty) {
        if (!mounted) {
          return;
        }
        _showSnack(context.l10n.noLedgerRecordsForDateRange);
        return;
      }

      final reportsDir = await _resolveSaveDirectory();
      if (reportsDir == null) {
        _showSnack(context.l10n.reportGenerationCanceled);
        return;
      }

      _showSnack(context.l10n.generatingReport);

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

      _showSnack(context.l10n.reportSavedTo(filePath));

      if (!_supportsShareSheet) {
        return;
      }

      try {
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              '${context.l10n.generalLedgerReport} (${_fullDateFormat.format(request.beginDate)} - ${_fullDateFormat.format(request.endDate)})',
        );
      } catch (shareError, shareStack) {
        debugPrint(
          'Share failed for generated report: $shareError\n$shareStack',
        );
        _showSnack(context.l10n.reportShareUnavailable);
      }
    } catch (error, stackTrace) {
      debugPrint('Report generation failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.reportGenerationFailed, isError: true);
    }
  }

  Future<Directory?> _resolveSaveDirectory() async {
    try {
      final fallbackDir = await _resolveReportsDirectory();
      final selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: context.l10n.chooseFolder,
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
          final walletAccount = (row['wallet_account'] as String?) ?? '';
          final walletDelta = (row['wallet_delta'] as num?)?.toDouble() ?? 0;
          final mayaWalletDelta =
              (row['maya_wallet_delta'] as num?)?.toDouble() ?? 0;
          final onHandDelta = (row['on_hand_delta'] as num?)?.toDouble() ?? 0;
          final isOutflow = iconKey == 'cash_out';
          final inflow = isOutflow ? 0.0 : amount;
          final outflow = isOutflow ? amount : 0.0;
          final chargeAmount =
              entryType == 'transaction' ||
                  ((row['owner_movement_type'] as String?) ?? '').trim() ==
                      'Cash Transfer (On-hand to Wallet)'
              ? _extractChargeAmountFromNote(notes)
              : 0.0;
          final chargeDestination =
              entryType == 'transaction' ||
                  ((row['owner_movement_type'] as String?) ?? '').trim() ==
                      'Cash Transfer (On-hand to Wallet)'
              ? _extractChargeDestinationFromNote(notes)
              : '';
          runningBalance += inflow - outflow;

          return _LedgerExportRow(
            createdAt: createdAt,
            entryType: entryType,
            title: row['title'] as String,
            tag: row['tag'] as String,
            reference: (row['reference'] as String?) ?? '',
            walletAccount: walletAccount,
            notes: notes,
            inflow: inflow,
            outflow: outflow,
            amountShown: amount,
            gcashChange: walletDelta,
            mayaChange: mayaWalletDelta,
            cashChange: onHandDelta,
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
    final l10n = context.l10n;
    final timestamp = DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now());
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (_) {
          return [
            pw.Text(
              _pdfSafeText(l10n.walletFlowReport),
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${_pdfSafeText(l10n.periodLabel)}: ${_fullDateFormat.format(beginDate)} - ${_fullDateFormat.format(endDate)}',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '${_pdfSafeText(l10n.generatedLabel)}: $timestamp',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: PdfColors.blue100),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _pdfSafeText(l10n.legendTitle),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _pdfSafeText(l10n.legendPlusMinus),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    _pdfSafeText(l10n.legendAmountShownNote),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
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
              headers: [
                _pdfSafeText(l10n.reportDateTimeLabel),
                _pdfSafeText(l10n.reportTypeLabel),
                _pdfSafeText(l10n.walletUsedLabel),
                _pdfSafeText(l10n.reportAmountLabel),
                _pdfSafeText(l10n.reportFeeLabel),
                _pdfSafeText(l10n.reportWalletDeltaLabel),
                _pdfSafeText(l10n.reportCashDeltaLabel),
                _pdfSafeText(l10n.reportReferenceLabel),
                _pdfSafeText(l10n.reportDetailsLabel),
              ],
              data: entries
                  .map(
                    (entry) => [
                      dateFormat.format(entry.createdAt),
                      _pdfSafeText(
                        entry.entryType == 'owner_movement'
                            ? l10n.historyOwnerActivityLabel
                            : l10n.historyTransactionLabel,
                      ),
                      _pdfSafeText(
                        _displayWalletAccountLabel(entry.walletAccount),
                      ),
                      _reportCurrency(entry.amountShown),
                      entry.chargeAmount > 0
                          ? _reportCurrency(entry.chargeAmount)
                          : '',
                      _reportSignedCurrency(entry.walletChange),
                      _reportSignedCurrency(entry.cashChange),
                      _pdfSafeText(entry.reference),
                      _pdfSafeText(entry.title),
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
                    '${_pdfSafeText(l10n.gcashMovementLabel)}: ${_reportSignedCurrency(totals.gcashMovement)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${_pdfSafeText(l10n.mayaMovementLabel)}: ${_reportSignedCurrency(totals.mayaMovement)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${_pdfSafeText(l10n.cashOnHandMovementLabel)}: ${_reportSignedCurrency(totals.cashMovement)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${_pdfSafeText(l10n.totalFeesPaidLabel)}: ${_reportCurrency(totals.totalCharges)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '${_pdfSafeText(l10n.feesRoutedLabel)}: ${_pdfSafeText(_formatFeeRoutingSummary(totals))}',
              style: const pw.TextStyle(fontSize: 9),
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
    final sheet = excel[context.l10n.walletFlowSheetName];
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    sheet.appendRow([
      ex.TextCellValue(context.l10n.walletFlowReport),
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
        '${context.l10n.periodLabel}: ${_fullDateFormat.format(beginDate)} - ${_fullDateFormat.format(endDate)}',
      ),
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
        '${context.l10n.generatedLabel}: ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}',
      ),
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
      ex.TextCellValue(context.l10n.legendTitle),
      ex.TextCellValue(context.l10n.legendPlusMinus),
      ex.TextCellValue(context.l10n.legendAmountShownNote),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
    ]);
    sheet.appendRow([
      ex.TextCellValue(context.l10n.reportDateTimeLabel),
      ex.TextCellValue(context.l10n.reportTypeLabel),
      ex.TextCellValue(context.l10n.walletUsedLabel),
      ex.TextCellValue(context.l10n.reportAmountLabel),
      ex.TextCellValue(context.l10n.reportFeeLabel),
      ex.TextCellValue(context.l10n.reportWalletDeltaLabel),
      ex.TextCellValue(context.l10n.reportCashDeltaLabel),
      ex.TextCellValue(context.l10n.reportReferenceLabel),
      ex.TextCellValue(context.l10n.reportDetailsLabel),
    ]);

    for (final entry in entries) {
      sheet.appendRow([
        ex.TextCellValue(dateFormat.format(entry.createdAt)),
        ex.TextCellValue(
          entry.entryType == 'owner_movement'
              ? context.l10n.historyOwnerActivityLabel
              : context.l10n.historyTransactionLabel,
        ),
        ex.TextCellValue(_displayWalletAccountLabel(entry.walletAccount)),
        ex.TextCellValue(_reportCurrency(entry.amountShown)),
        ex.TextCellValue(
          entry.chargeAmount > 0 ? _reportCurrency(entry.chargeAmount) : '',
        ),
        ex.TextCellValue(_reportSignedCurrency(entry.walletChange)),
        ex.TextCellValue(_reportSignedCurrency(entry.cashChange)),
        ex.TextCellValue(entry.reference),
        ex.TextCellValue(entry.title),
      ]);
    }

    sheet.appendRow([
      ex.TextCellValue(context.l10n.gcashMovementLabel),
      ex.TextCellValue(_reportSignedCurrency(totals.gcashMovement)),
      ex.TextCellValue(context.l10n.mayaMovementLabel),
      ex.TextCellValue(_reportSignedCurrency(totals.mayaMovement)),
      ex.TextCellValue(context.l10n.cashOnHandMovementLabel),
      ex.TextCellValue(_reportSignedCurrency(totals.cashMovement)),
      ex.TextCellValue(context.l10n.totalFeesPaidLabel),
      ex.TextCellValue(_reportCurrency(totals.totalCharges)),
      ex.TextCellValue(''),
    ]);
    sheet.appendRow([
      ex.TextCellValue(context.l10n.feesRoutedLabel),
      ex.TextCellValue(_formatFeeRoutingSummary(totals)),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
      ex.TextCellValue(''),
    ]);

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Unable to encode excel bytes.');
    }
    return bytes;
  }

  _LedgerTotals _calculateLedgerTotals(List<_LedgerExportRow> entries) {
    double gcashMovement = 0;
    double mayaMovement = 0;
    double cashMovement = 0;
    double totalCharges = 0;
    double routedToGcash = 0;
    double routedToMaya = 0;
    double routedToCash = 0;

    for (final entry in entries) {
      gcashMovement += entry.gcashChange;
      mayaMovement += entry.mayaChange;
      cashMovement += entry.cashChange;
      totalCharges += entry.chargeAmount;

      final destinationKey = _normalizeWalletKey(entry.chargeDestination);
      if (destinationKey == 'gcash') {
        routedToGcash += entry.chargeAmount;
      } else if (destinationKey == 'maya') {
        routedToMaya += entry.chargeAmount;
      } else if (destinationKey == 'on_hand') {
        routedToCash += entry.chargeAmount;
      }
    }

    return _LedgerTotals(
      gcashMovement: gcashMovement,
      mayaMovement: mayaMovement,
      cashMovement: cashMovement,
      totalCharges: totalCharges,
      routedToGcash: routedToGcash,
      routedToMaya: routedToMaya,
      routedToCash: routedToCash,
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
    if (chargeAmount <= 0) {
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

  String _reportSignedCurrency(double amount) {
    final sign = amount < 0 ? '-' : '+';
    return '$sign ${_reportCurrency(amount.abs())}';
  }

  String _formatFeeRoutingSummary(_LedgerTotals totals) {
    final parts = <String>[];
    if (totals.routedToGcash > 0) {
      parts.add(
        '${context.l10n.gcash}: ${_reportCurrency(totals.routedToGcash)}',
      );
    }
    if (totals.routedToMaya > 0) {
      parts.add(
        '${context.l10n.maya}: ${_reportCurrency(totals.routedToMaya)}',
      );
    }
    if (totals.routedToCash > 0) {
      parts.add(
        '${context.l10n.onHand}: ${_reportCurrency(totals.routedToCash)}',
      );
    }
    if (parts.isEmpty) {
      return '-';
    }
    return parts.join(' | ');
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

    if (difference == 0) return context.l10n.today;
    if (difference == 1) return context.l10n.yesterday;
    return _fullDateFormat.format(dateTime);
  }

  String _buildTileSubtitle(_HistoryRow item) {
    final parts = <String>[];
    final movementType = _friendlyOwnerMovementType(item.ownerMovementType);
    final walletLabel = _displayWalletAccountLabel(item.walletAccount);
    final reference = item.reference.trim();

    if (movementType != null) {
      parts.add(movementType);
    }

    if (walletLabel.isNotEmpty) {
      parts.add(walletLabel);
    }
    if (reference.isNotEmpty) {
      parts.add(reference);
    }

    if (parts.isNotEmpty) {
      return parts.join(' • ');
    }

    final fallback = item.tag.trim();
    return fallback.isNotEmpty ? fallback : item.title;
  }

  String? _buildTileSupportingText(_HistoryRow item) {
    if (item.entryType == 'transaction' && item.chargeAmount > 0) {
      final feeText = _currencyFormat.format(item.chargeAmount);
      final destLabel = _walletLabelFromKey(item.chargeDestinationKey);
      final base = context.l10n.includesFee(feeText);
      return destLabel != null ? '$base → $destLabel' : base;
    }

    if (_isCashTransferPerspectiveRow(item)) {
      final base =
          'On-hand cash moved into ${_displayWalletAccountLabel(item.walletAccount)}';
      return _appendFeeToText(item, base);
    }

    final friendlyOwnerMovementType = _friendlyOwnerMovementType(
      item.ownerMovementType,
    );
    if (friendlyOwnerMovementType != null) {
      return _appendFeeToText(item, friendlyOwnerMovementType);
    }

    // Any other owner movement that carries a fee.
    if (item.chargeAmount > 0) {
      final feeText = _currencyFormat.format(item.chargeAmount);
      final destLabel = _walletLabelFromKey(item.chargeDestinationKey);
      final base = context.l10n.includesFee(feeText);
      return destLabel != null ? '$base → $destLabel' : base;
    }

    final tag = item.tag.trim();
    if (tag.isEmpty || tag.toLowerCase() == 'transaction') {
      return null;
    }

    return tag;
  }

  /// Appends "• Fee: ₱X → Destination" to [base] if [item] has a charge.
  String _appendFeeToText(_HistoryRow item, String base) {
    if (item.chargeAmount <= 0) return base;
    final feeText = _currencyFormat.format(item.chargeAmount);
    final destLabel = _walletLabelFromKey(item.chargeDestinationKey);
    final feePart = destLabel != null
        ? 'Fee: $feeText → $destLabel'
        : 'Fee: $feeText';
    return '$base • $feePart';
  }

  String? _friendlyOwnerMovementType(String? movementType) {
    final normalized = (movementType ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized == 'borrowed funds' || normalized == 'personal expense') {
      return 'Borrowed Funds Taken';
    }
    if (normalized == 'borrowed funds repayment' ||
        normalized == 'personal expense payment') {
      return 'Borrowed Funds Repayment';
    }
    if (normalized == 'fee withdrawal') {
      return 'Fee Withdrawal';
    }
    if (normalized == 'fee transfer') {
      return 'Fee Transfer';
    }
    return null;
  }

  String _displayWalletAccountLabel(String walletAccount) {
    switch (_normalizeWalletKey(walletAccount)) {
      case 'gcash':
        return context.l10n.gcash;
      case 'maya':
        return context.l10n.maya;
      case 'on_hand':
        return context.l10n.onHand;
      default:
        return walletAccount.trim();
    }
  }

  String? _walletLabelFromKey(String? key) {
    switch (key) {
      case 'gcash':
        return context.l10n.gcash;
      case 'maya':
        return context.l10n.maya;
      case 'on_hand':
        return context.l10n.onHand;
      default:
        return null;
    }
  }

  double _walletDeltaForItem(_HistoryRow item) {
    if (item.mayaWalletDelta != 0) {
      return item.mayaWalletDelta;
    }
    return item.walletDelta;
  }

  String _signedCurrency(double amount) {
    final sign = amount < 0 ? '−' : '+';
    return '$sign ${_currencyFormat.format(amount.abs())}';
  }

  bool _isWalletOutflow(_HistoryRow item) {
    if (item.entryType == 'transaction') {
      if (_selectedWalletFilter == 'on_hand') {
        // On-hand perspective: cash_out drains physical cash (−), cash_in adds physical cash (+).
        return item.iconKey == 'cash_out' || item.iconKey == 'maya_cash_out';
      }
      // GCash / Maya perspective: cash_in drains wallet (−), cash_out grows wallet (+).
      return item.iconKey == 'cash_in' || item.iconKey == 'maya_cash_in';
    }

    if (_selectedWalletFilter == 'on_hand' && item.onHandDelta != 0) {
      return item.onHandDelta < 0;
    }

    final walletDelta = _walletDeltaForItem(item);
    if (walletDelta != 0) {
      return walletDelta < 0;
    }

    if (item.onHandDelta != 0) {
      return item.onHandDelta < 0;
    }

    return item.iconKey == 'cash_out' || item.iconKey == 'maya_cash_out';
  }

  double _resolveDisplayAmount(_HistoryRow item) {
    if (item.entryType != 'transaction') {
      return item.amount;
    }

    // On-hand perspective: show the full on-hand cash impact, which includes
    // the charge portion that feeds into physical cash (e.g. fee kept on-hand
    // during a cash-in). This gives a complete log of what actually moved.
    if (_selectedWalletFilter == 'on_hand') {
      final onHandAbs = item.onHandDelta.abs();
      if (onHandAbs > 0) return onHandAbs;
    }

    // GCash / Maya perspective: show the net transaction amount
    // (excluding the store's service fee).
    //
    // For cash-in: wallet/maya delta is smaller (fee kept as on-hand)
    // For cash-out: on-hand delta is smaller (fee kept from wallet)
    // In both cases, the net amount = min(abs(walletOrMaya), abs(onHand)).
    final walletOrMayaAbs = item.walletDelta != 0
        ? item.walletDelta.abs()
        : item.mayaWalletDelta.abs();
    final onHandAbs = item.onHandDelta.abs();
    final isWalletPerspective =
        _selectedWalletFilter == null ||
        _selectedWalletFilter == 'gcash' ||
        _selectedWalletFilter == 'maya';
    final isCashOut =
        item.iconKey == 'cash_out' || item.iconKey == 'maya_cash_out';

    if (isWalletPerspective && isCashOut && walletOrMayaAbs > 0) {
      return walletOrMayaAbs;
    }

    if (walletOrMayaAbs > 0 && onHandAbs > 0) {
      return walletOrMayaAbs < onHandAbs ? walletOrMayaAbs : onHandAbs;
    }

    // Fallback for edge cases (zero-fee or partial data).
    return item.amount;
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
        return AppColors.error;
      case 'maya_cash_in':
        return AppColors.error;
      case 'cash_out':
        return AppColors.secondary;
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
    required this.onHandDelta,
    required this.walletDelta,
    required this.mayaWalletDelta,
    required this.chargeAmount,
    required this.chargeDestinationKey,
    required this.postGcashBalance,
    required this.postMayaBalance,
    required this.postOnHandBalance,
    this.accountNumber,
    this.ownerMovementType,
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
  final String? ownerMovementType;
  final double onHandDelta;
  final double walletDelta;
  final double mayaWalletDelta;
  final double chargeAmount;
  final String? chargeDestinationKey;
  final double postGcashBalance;
  final double postMayaBalance;
  final double postOnHandBalance;
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
    required this.walletAccount,
    required this.notes,
    required this.inflow,
    required this.outflow,
    required this.amountShown,
    required this.gcashChange,
    required this.mayaChange,
    required this.cashChange,
    required this.chargeAmount,
    required this.chargeDestination,
    required this.chargeBreakdown,
    required this.runningBalance,
    this.chargeDestinationKey,
  });

  final DateTime createdAt;
  final String entryType;
  final String title;
  final String tag;
  final String reference;
  final String walletAccount;
  final String notes;
  final double inflow;
  final double outflow;
  final double amountShown;
  final double gcashChange;
  final double mayaChange;
  final double cashChange;
  double get walletChange => mayaChange != 0 ? mayaChange : gcashChange;
  final double chargeAmount;
  final String chargeDestination;
  final String chargeBreakdown;
  final double runningBalance;
  final String? chargeDestinationKey;
}

class _LedgerTotals {
  const _LedgerTotals({
    required this.gcashMovement,
    required this.mayaMovement,
    required this.cashMovement,
    required this.totalCharges,
    required this.routedToGcash,
    required this.routedToMaya,
    required this.routedToCash,
  });

  final double gcashMovement;
  final double mayaMovement;
  final double cashMovement;
  final double totalCharges;
  final double routedToGcash;
  final double routedToMaya;
  final double routedToCash;
}
