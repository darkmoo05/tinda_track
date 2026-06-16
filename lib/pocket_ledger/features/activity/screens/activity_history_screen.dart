import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../more/logic/monitoring_session_provider.dart';

import 'package:share_plus/share_plus.dart';

import 'dart:async';
import 'dart:io';

import '../../../../core/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/database_providers.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
import '../../../../shared/widgets/tutorial_spotlight.dart';
import '../widgets/activity_tile.dart';
import '../widgets/date_header.dart';

enum HistoryWalletPerspective { gcash, maya, onHand }

enum _HistoryOnboardingStep {
  inactive,
  tabBar,
  filters,
  export,
  completed,
}

class ActivityHistoryScreen extends ConsumerStatefulWidget {
  const ActivityHistoryScreen({
    super.key,
    this.openDrawer,
    this.initialWalletPerspective,
    this.refreshToken = 0,
    this.viewToken = 0,
  });

  final VoidCallback? openDrawer;
  final HistoryWalletPerspective? initialWalletPerspective;
  final int refreshToken;
  final int viewToken;

  @override
  ConsumerState<ActivityHistoryScreen> createState() =>
      _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends ConsumerState<ActivityHistoryScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppDatabase get _database => ref.read(currentAppDatabaseProvider);
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );
  final DateFormat _fullDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  late TabController _tabController;
  String _activeDatePreset = 'All';

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

  _HistoryOnboardingStep _onboardingStep = _HistoryOnboardingStep.inactive;

  final GlobalKey _tabBarKey = GlobalKey(debugLabel: 'historyTabBar');
  final GlobalKey _filtersKey = GlobalKey(debugLabel: 'historyFilters');
  final GlobalKey _exportKey = GlobalKey(debugLabel: 'historyExport');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _selectedWalletFilter = _walletFilterFromPerspective(
      widget.initialWalletPerspective,
    );
    _loadHistory();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    try {
      final appMeta = ref.read(databaseAppMetaDaoProvider);
      final completed = await appMeta.get('tutorial_completed_history_screen');
      if (completed != 'true' && mounted) {
        setState(() {
          _onboardingStep = _HistoryOnboardingStep.tabBar;
        });
      }
    } catch (_) {}
  }

  Future<void> _completeTutorial() async {
    setState(() {
      _onboardingStep = _HistoryOnboardingStep.completed;
    });
    try {
      final appMeta = ref.read(databaseAppMetaDaoProvider);
      await appMeta.set('tutorial_completed_history_screen', 'true');
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant ActivityHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialWalletPerspective != oldWidget.initialWalletPerspective) {
      setState(() {
        _selectedWalletFilter = _walletFilterFromPerspective(
          widget.initialWalletPerspective,
        );
      });
      _loadHistory();
    } else if (widget.refreshToken != oldWidget.refreshToken ||
        widget.viewToken != oldWidget.viewToken) {
      _loadHistory();
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _quickExportReport(_ReportFileType type) async {
    final now = DateTime.now();
    final start = _beginDateFilter ?? DateTime(now.year, now.month, 1);
    final end = _endDateFilter ?? now;
    await _generateGeneralLedgerReport(
      _LedgerReportRequest(
        beginDate: start,
        endDate: end,
        fileType: type,
      ),
    );
  }

  Widget _buildSample3HeroBanner() {
    final now = DateTime.now();
    final start = _beginDateFilter ?? DateTime(now.year, now.month, 1);
    final end = _endDateFilter ?? now;
    final dateRangeText = _beginDateFilter == null && _endDateFilter == null
        ? context.l10n.walletHistorySubtitle
        : '${_fullDateFormat.format(start)} - ${_fullDateFormat.format(end)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: ScreenHeaderCard(
        title: context.l10n.movements,
        subtitle: dateRangeText,
        trailing: Row(
          key: _exportKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickIconButton(
              icon: Icons.picture_as_pdf_rounded,
              tooltip: 'Export PDF',
              onTap: () => _quickExportReport(_ReportFileType.pdf),
              bgColor: Colors.red.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 8),
            _buildQuickIconButton(
              icon: Icons.table_chart_rounded,
              tooltip: 'Export Excel',
              onTap: () => _quickExportReport(_ReportFileType.excel),
              bgColor: Colors.green.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color bgColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlySessionBanner(BuildContext context, MonitoringSessionRow session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerBg = isDark ? const Color(0xFF1E293B) : Colors.red.shade50;
    final borderCol = isDark ? const Color(0xFFEF4444).withValues(alpha: 0.4) : Colors.red.shade200;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_clock_rounded, color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Viewing Closed Session: ${session.name} (Read-Only)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              await ref.read(selectedSessionProvider.notifier).resetToActive();
              _loadHistory();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Go Live', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final selectedSessionAsync = ref.watch(selectedSessionProvider);
    final selectedSession = selectedSessionAsync.value;

    ref.listen(selectedSessionProvider, (previous, next) {
      if (previous?.value?.id != next.value?.id) {
        _loadHistory();
      }
    });

    final scaffold = Scaffold(
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
                _buildSample3HeroBanner(),
                if (selectedSession != null && selectedSession.status == 'CLOSED')
                  _buildReadOnlySessionBanner(context, selectedSession),
                _buildTabBar(),

                _buildSearchAndFilters(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
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
    );

    return Stack(
      children: [
        scaffold,
        if (_onboardingStep == _HistoryOnboardingStep.tabBar)
          TutorialSpotlight(
            targetKey: _tabBarKey,
            title: 'Switch Views',
            description: 'Toggle between customer Transactions and internal Owner Movements (capital top-ups or withdrawals).',
            onNext: () {
              setState(() {
                _onboardingStep = _HistoryOnboardingStep.filters;
              });
            },
            onSkip: _completeTutorial,
            nextLabel: 'Next',
            showNext: true,
            shape: BoxShape.rectangle,
            borderRadius: 14.0,
          ),
        if (_onboardingStep == _HistoryOnboardingStep.filters)
          TutorialSpotlight(
            targetKey: _filtersKey,
            title: 'Filter and Audit',
            description: 'Search for specific references, parties, or filter the list by date preset and wallet source to quickly audit records.',
            onNext: () {
              setState(() {
                _onboardingStep = _HistoryOnboardingStep.export;
              });
            },
            onSkip: _completeTutorial,
            nextLabel: 'Next',
            showNext: true,
            shape: BoxShape.rectangle,
            borderRadius: 14.0,
          ),
        if (_onboardingStep == _HistoryOnboardingStep.export)
          TutorialSpotlight(
            targetKey: _exportKey,
            title: 'Export Ledger Reports',
            description: 'Generate premium PDF reports or Excel sheets of your ledger movements for printing, sharing, or offline bookkeeping.',
            onNext: _completeTutorial,
            onSkip: _completeTutorial,
            nextLabel: 'Finish',
            showNext: true,
            shape: BoxShape.rectangle,
            borderRadius: 10.0,
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabBarBg = isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainerLow;
    final indicatorBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
    final labelColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final unselectedLabelColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant.withValues(alpha: 0.7);

    return Container(
      key: _tabBarKey,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: tabBarBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelColor: labelColor,
        unselectedLabelColor: unselectedLabelColor,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        indicator: BoxDecoration(
          color: indicatorBg,
          borderRadius: BorderRadius.circular(10),
          border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(context.l10n.transactions),
            ),
          ),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(context.l10n.ownerMovements),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.4);
    final hintColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

    return Column(
      key: _filtersKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: searchBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
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
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: hintColor,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: hintColor,
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
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: hintColor,
                        ),
                      ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // Date Presets horizontal scroll
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildPresetChip('All'),
              const SizedBox(width: 8),
              _buildPresetChip('Today'),
              const SizedBox(width: 8),
              _buildPresetChip('Yesterday'),
              const SizedBox(width: 8),
              _buildPresetChip('This Week'),
              const SizedBox(width: 8),
              _buildPresetChip('Custom 📅'),
            ],
          ),
        ),

        // Wallet filters (if Transactions is active)
        if (_tabController.index == 0) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildWalletFilterChip(
                  label: context.l10n.filterAll,
                  icon: Icons.grid_view_rounded,
                  color: AppColors.primary,
                  walletKey: null,
                ),
                const SizedBox(width: 8),
                _buildWalletFilterChip(
                  label: context.l10n.gcash,
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  walletKey: 'gcash',
                ),
                const SizedBox(width: 8),
                _buildWalletFilterChip(
                  label: context.l10n.maya,
                  icon: Icons.wallet_rounded,
                  color: AppColors.secondary,
                  walletKey: 'maya',
                ),
                const SizedBox(width: 8),
                _buildWalletFilterChip(
                  label: context.l10n.onHand,
                  icon: Icons.payments_outlined,
                  color: AppColors.onHand,
                  walletKey: 'on_hand',
                ),
              ],
            ),
          ),
        ],

        // Custom Date Range Picker buttons (if custom is selected)
        if (_activeDatePreset == 'Custom 📅') ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
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
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Active custom date range chips to easily clear them
        if (_activeDatePreset == 'Custom 📅' &&
            (_beginDateFilter != null || _endDateFilter != null)) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
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
                      fontSize: 11,
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide.none,
                    deleteIcon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    onDeleted: () {
                      setState(() {
                        _beginDateFilter = null;
                      });
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
                      fontSize: 11,
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide.none,
                    deleteIcon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    onDeleted: () {
                      setState(() {
                        _endDateFilter = null;
                      });
                      _applyFilters();
                    },
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPresetChip(String presetName) {
    final isSelected = _activeDatePreset == presetName;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final labelColor = isSelected
        ? primaryColor
        : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant);
    final selectedColor = isDark
        ? const Color(0xFF60A5FA).withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.08);
    final unselectedBg = isDark
        ? const Color(0xFF1E293B)
        : AppColors.surfaceContainerLow;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => _selectDatePreset(presetName),
      showCheckmark: false,
      label: Text(
        presetName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: labelColor,
        ),
      ),
      selectedColor: selectedColor,
      backgroundColor: unselectedBg,
      side: BorderSide(
        color: isSelected
            ? primaryColor
            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.transparent),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _selectDatePreset(String preset) {
    setState(() {
      _activeDatePreset = preset;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (preset == 'All') {
        _beginDateFilter = null;
        _endDateFilter = null;
      } else if (preset == 'Today') {
        _beginDateFilter = today;
        _endDateFilter = today;
      } else if (preset == 'Yesterday') {
        final yesterday = today.subtract(const Duration(days: 1));
        _beginDateFilter = yesterday;
        _endDateFilter = yesterday;
      } else if (preset == 'This Week') {
        final daysToSubtract = today.weekday - 1;
        _beginDateFilter = today.subtract(Duration(days: daysToSubtract));
        _endDateFilter = today;
      }
      // If 'Custom 📅', we don't modify date filters immediately
    });
    _applyFilters();
  }

  Widget _buildWalletFilterChip({
    required String label,
    required IconData icon,
    required Color color,
    required String? walletKey,
  }) {
    final isSelected = _selectedWalletFilter == walletKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color adaptiveColor = color;
    if (isDark) {
      if (color == AppColors.primary) {
        adaptiveColor = const Color(0xFF60A5FA);
      } else if (color == AppColors.secondary) {
        adaptiveColor = const Color(0xFF34D399);
      } else if (color == AppColors.onHand) {
        adaptiveColor = const Color(0xFFFBBF24);
      }
    }

    final unselectedBg = isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainerLow;
    final avatarColor = isSelected ? adaptiveColor : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant);
    final textColor = isSelected ? adaptiveColor : (isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface);
    final borderColor = isSelected
        ? adaptiveColor.withValues(alpha: 0.35)
        : (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.5));

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
        color: avatarColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      selectedColor: adaptiveColor.withValues(alpha: 0.14),
      backgroundColor: unselectedBg,
      side: BorderSide(
        color: borderColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildHistoryList(
    List<_HistoryRow> allItems,
    List<Object> displayList, {
    required bool showWalletFilters,
  }) {
    if (allItems.isNotEmpty && displayList.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          _buildEmptyState(
            title: context.l10n.noMatchingTransactions,
            message: context.l10n.trySearchingBy,
          ),
        ],
      );
    }

    if (allItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          _buildEmptyState(
            title: context.l10n.noHistoryYet,
            message: context.l10n.newEntriesWillAppear,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];
        if (item is String) {
          return ArchitectDateHeader(label: item);
        }
        return _buildTile(item as _HistoryRow);
      },
    );
  }

  Widget _buildEmptyState({required String title, required String message}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant),
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

  List<_HistoryRow> _filterItems(
    List<_HistoryRow> items, {
    required bool applyWalletFilter,
  }) {
    return items.where((item) {
      // 1. Transaction tab perspective filtering
      if (applyWalletFilter && !_isTransactionPerspectiveRow(item)) {
        return false;
      }

      // 2. Search query filter
      if (_searchQuery.isNotEmpty) {
        final fields = [
          item.title,
          item.tag,
          item.reference,
          item.rawReference,
          item.accountNumber ?? '',
          item.walletAccount,
          item.note,
        ];
        final matchesSearch = fields.any((field) =>
            field.toLowerCase().contains(_searchQuery));
        if (!matchesSearch) return false;
      }

      // 3. Date range filters
      final itemDate = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      if (_beginDateFilter != null && itemDate.isBefore(_beginDateFilter!)) {
        return false;
      }
      if (_endDateFilter != null && itemDate.isAfter(_endDateFilter!)) {
        return false;
      }

      // 4. Wallet perspective filter
      if (applyWalletFilter && _selectedWalletFilter != null) {
        final matchesWallet = _matchesWalletPerspective(item, _selectedWalletFilter!);
        if (!matchesWallet) return false;
      }

      return true;
    }).toList(growable: false);
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
    if (_selectedWalletFilter == null) {
      return item.entryType == 'transaction';
    }

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
    final isAllViewTx = _selectedWalletFilter == null && item.entryType == 'transaction';

    final amountText = isAllViewTx
        ? _currencyFormat.format(displayAmount)
        : '${isWalletOutflow ? '−' : '+'} ${_currencyFormat.format(displayAmount)}';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountColor = isAllViewTx
        ? (isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface)
        : null;

    final tileColor = isAllViewTx
        ? _walletColor(item.walletAccount)
        : (_isTransactionLogRow(item)
            ? (isWalletOutflow ? AppColors.error : AppColors.secondary)
            : (isWalletOutflow ? AppColors.error : _colorFor(item.iconKey)));

    final supportingText = isAllViewTx
        ? _buildDualImpactText(item)
        : _buildTileSupportingText(item);

    String? runningBalanceText;
    if (_selectedWalletFilter != null) {
      final currentBal = switch (_selectedWalletFilter!) {
        'gcash' => item.postGcashBalance,
        'maya' => item.postMayaBalance,
        'on_hand' => item.postOnHandBalance,
        _ => 0.0,
      };
      runningBalanceText = 'Bal: ${_currencyFormat.format(currentBal)}';
    }

    final isDemo = const ['CAP-INITIAL-3D', 'SAMPLE-REF-CASHIN-2D', 'SAMPLE-REF-CASHOUT-1D']
        .contains(item.rawReference);
    final displayTitle = isDemo ? '${item.title} (Demo)' : item.title;

    return ArchitectActivityTile(
      title: displayTitle,
      subtitle: _buildTileSubtitle(item),
      supportingText: supportingText,
      amount: amountText,
      amountColor: amountColor,
      runningBalance: runningBalanceText,
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dialogBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
        final cardBg = isDark ? const Color(0xFF0B0F19) : AppColors.surfaceContainerLowest;
        final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.5);

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
              color: dialogBg,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      entryTypeLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    amountText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
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
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: borderColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final trendColor = isUnchanged
        ? (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant)
        : isIncreased
        ? AppColors.secondary
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: primaryColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: primaryColor,
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              beforeText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              afterText,
              style: TextStyle(
                fontSize: 13,
                color: trendColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sticky_note_2_outlined,
                  size: 14,
                  color: primaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 11,
                    color: primaryColor,
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
    // Load ASC so we can compute accurate running (post) balances.
    final selectedSession = ref.read(selectedSessionProvider).value;
    String sql = '''
      SELECT
        le.id,
        le.entry_type,
        le.title,
        le.reference,
        le.wallet_account,
        le.note,
        le.amount,
        le.tag,
        le.icon_key,
        le.owner_movement_type,
        le.wallet_delta,
        le.maya_wallet_delta,
        le.on_hand_delta,
        strftime('%Y-%m-%dT%H:%M:%fZ', le.created_at_ms / 1000.0, 'unixepoch') AS created_at,
        ft.fee_amount,
        ft.charge_destination
      FROM ledger_entries le
      LEFT JOIN fee_transactions ft ON ft.related_transaction_sync_id = le.id AND ft.is_deleted = 0
      WHERE le.is_deleted = 0
    ''';
    List<Variable> vars = [];
    if (selectedSession != null) {
      sql += ' AND le.created_at_ms >= ?';
      vars.add(Variable.withInt(selectedSession.startDateMs));
      if (selectedSession.endDateMs != null) {
        sql += ' AND le.created_at_ms <= ?';
        vars.add(Variable.withInt(selectedSession.endDateMs!));
      }
    }
    sql += ' ORDER BY le.created_at_ms ASC, le.id ASC';

    final rawRows = await _database.customSelect(sql, variables: vars).get();

    final rows = rawRows
        .map((r) => Map<String, Object?>.from(r.data))
        .toList(growable: false);

    double runningGcash = selectedSession?.startGcash ?? 0.0;
    double runningMaya = selectedSession?.startMaya ?? 0.0;
    double runningOnHand = selectedSession?.startOnHand ?? 0.0;


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
      final dbFee = (row['fee_amount'] as num?)?.toDouble() ?? 0.0;
      final dbDest = (row['charge_destination'] as String?) ?? '';

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
          createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
          ownerMovementType: row['owner_movement_type'] as String?,
          onHandDelta: onHandDelta,
          walletDelta: walletDelta,
          mayaWalletDelta: mayaWalletDelta,
          chargeAmount: dbFee > 0 ? dbFee : _extractChargeAmountFromNote(note),
          chargeDestinationKey: dbDest.isNotEmpty
              ? _normalizeWalletKey(dbDest)
              : _extractChargeDestinationKeyFromNote(note),
          postGcashBalance: runningGcash,
          postMayaBalance: runningMaya,
          postOnHandBalance: runningOnHand,
        ),
      );
    }

    // Reverse for DESC display order.
    final allRowsDesc = allRows.reversed.toList(growable: false);

    if (!mounted) return;
    final txRows = allRowsDesc;
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



  Future<void> _generateGeneralLedgerReport(
    _LedgerReportRequest request,
  ) async {
    final l10n = context.l10n;
    _showSnack(l10n.preparingReport);

    try {
      final entries = await _loadLedgerEntriesForRange(
        request.beginDate,
        request.endDate,
      );

      if (entries.isEmpty) {
        if (!mounted) {
          return;
        }
        _showSnack(l10n.noLedgerRecordsForDateRange);
        return;
      }

      final reportsDir = await _resolveSaveDirectory();
      if (!mounted) {
        return;
      }
      if (reportsDir == null) {
        _showSnack(l10n.reportGenerationCanceled);
        return;
      }

      _showSnack(l10n.generatingReport);

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

      _showSnack(l10n.reportSavedTo(filePath));

      if (!_supportsShareSheet) {
        return;
      }

      try {
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              '${l10n.generalLedgerReport} (${_fullDateFormat.format(request.beginDate)} - ${_fullDateFormat.format(request.endDate)})',
        );
      } catch (shareError, shareStack) {
        debugPrint(
          'Share failed for generated report: $shareError\n$shareStack',
        );
        _showSnack(l10n.reportShareUnavailable);
      }
    } catch (error, stackTrace) {
      debugPrint('Report generation failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      _showSnack(l10n.reportGenerationFailed, isError: true);
    }
  }

  Future<Directory?> _resolveSaveDirectory() async {
    try {
      final l10n = context.l10n;
      final fallbackDir = await _resolveReportsDirectory();
      final selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: l10n.chooseFolder,
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

    final selectedSession = ref.read(selectedSessionProvider).value;
    int sessionStart = selectedSession?.startDateMs ?? 0;
    int sessionEnd = selectedSession?.endDateMs ?? DateTime.now().millisecondsSinceEpoch;

    final startMs = start.millisecondsSinceEpoch.clamp(sessionStart, sessionEnd);
    final endMs = end.millisecondsSinceEpoch.clamp(sessionStart, sessionEnd);

    final rawRows = await _database
        .customSelect(
          '''
      SELECT
        le.id,
        le.entry_type,
        le.title,
        le.reference,
        le.wallet_account,
        le.note,
        le.amount,
        le.tag,
        le.icon_key,
        le.owner_movement_type,
        le.wallet_delta,
        le.maya_wallet_delta,
        le.on_hand_delta,
        strftime('%Y-%m-%dT%H:%M:%fZ', le.created_at_ms / 1000.0, 'unixepoch') AS created_at,
        ft.fee_amount,
        ft.charge_destination
      FROM ledger_entries le
      LEFT JOIN fee_transactions ft ON ft.related_transaction_sync_id = le.id AND ft.is_deleted = 0
      WHERE le.is_deleted = 0
        AND le.created_at_ms >= ?
        AND le.created_at_ms <= ?
      ORDER BY le.created_at_ms ASC, le.id ASC
      ''',
          variables: [
            Variable.withInt(startMs),
            Variable.withInt(endMs),
          ],
        )
        .get();

    final rows = rawRows
        .map((r) => Map<String, Object?>.from(r.data))
        .toList(growable: false);

    double runningBalance = 0;
    return rows
        .map((row) {
          final createdAt = DateTime.parse(row['created_at'] as String).toLocal();
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

          final dbFee = (row['fee_amount'] as num?)?.toDouble() ?? 0.0;
          final chargeAmount = dbFee > 0
              ? dbFee
              : (entryType == 'transaction' ||
                  ((row['owner_movement_type'] as String?) ?? '').trim() ==
                      'Cash Transfer (On-hand to Wallet)'
                  ? _extractChargeAmountFromNote(notes)
                  : 0.0);
          final dbDest = (row['charge_destination'] as String?) ?? '';
          final chargeDestination = dbDest.isNotEmpty
              ? dbDest
              : (entryType == 'transaction' ||
                  ((row['owner_movement_type'] as String?) ?? '').trim() ==
                      'Cash Transfer (On-hand to Wallet)'
                  ? _extractChargeDestinationFromNote(notes)
                  : '');

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
    final dateFormat = DateFormat('MM/dd/yyyy, HH:mm');

    // 1. Calculate stats for the KPI trend percentages
    double cashInflow = 0;
    double cashOutflow = 0;
    double gcashInflow = 0;
    double gcashOutflow = 0;
    double mayaInflow = 0;
    double mayaOutflow = 0;
    double totalVolume = 0;

    for (final entry in entries) {
      if (entry.cashChange > 0) cashInflow += entry.cashChange;
      if (entry.cashChange < 0) cashOutflow += entry.cashChange.abs();
      if (entry.gcashChange > 0) gcashInflow += entry.gcashChange;
      if (entry.gcashChange < 0) gcashOutflow += entry.gcashChange.abs();
      if (entry.mayaChange > 0) mayaInflow += entry.mayaChange;
      if (entry.mayaChange < 0) mayaOutflow += entry.mayaChange.abs();
      totalVolume += entry.inflow + entry.outflow;
    }

    final double cashTrend = (cashInflow + cashOutflow > 0)
        ? (totals.cashMovement / (cashInflow + cashOutflow)) * 100
        : 0.0;
    final double gcashTrend = (gcashInflow + gcashOutflow > 0)
        ? (totals.gcashMovement / (gcashInflow + gcashOutflow)) * 100
        : 0.0;
    final double mayaTrend = (mayaInflow + mayaOutflow > 0)
        ? (totals.mayaMovement / (mayaInflow + mayaOutflow)) * 100
        : 0.0;
    final double feeTrend = (totalVolume > 0)
        ? (totals.totalCharges / totalVolume) * 100
        : 0.0;

    // Define colors matching the mockup
    final darkBgColor = PdfColor.fromHex('#0f172a'); // Slate 900

    // Split transactions for Page 1 and continuation pages
    // Page 1 displays up to 10 rows
    final int firstPageLimit = 10;
    final List<_LedgerExportRow> firstPageEntries = entries.take(firstPageLimit).toList();
    final List<_LedgerExportRow> remainingEntries = entries.skip(firstPageLimit).toList();

    // Define Page Theme with dark slate background
    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(16),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: darkBgColor),
      ),
    );

    final int totalPages = 1 + (remainingEntries.isEmpty ? 0 : (remainingEntries.length / 20).ceil());

    // Page 1: Dashboard
    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Block
              _buildPdfDashboardHeader(l10n, beginDate, endDate, timestamp),
              pw.SizedBox(height: 12),

              // KPI Summary Cards
              pw.Row(
                children: [
                  _buildPdfKpiCard(
                    title: 'On-Hand Cash:',
                    value: _reportSignedCurrency(totals.cashMovement),
                    trendPercent: cashTrend,
                    isFeatured: true,
                  ),
                  pw.SizedBox(width: 10),
                  _buildPdfKpiCard(
                    title: 'GCash Net Change:',
                    value: _reportSignedCurrency(totals.gcashMovement),
                    trendPercent: gcashTrend,
                    isFeatured: false,
                    isGcash: true,
                  ),
                  pw.SizedBox(width: 10),
                  _buildPdfKpiCard(
                    title: 'Maya Net Change:',
                    value: _reportSignedCurrency(totals.mayaMovement),
                    trendPercent: mayaTrend,
                    isFeatured: false,
                    isMaya: true,
                  ),
                  pw.SizedBox(width: 10),
                  _buildPdfKpiCard(
                    title: 'Total Service Fees:',
                    value: _reportCurrency(totals.totalCharges),
                    trendPercent: feeTrend,
                    isFeatured: false,
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // Side-by-Side Analytics Section
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // Left Column: Donut Chart
                    _buildPdfChartCard(totals, entries),
                    pw.SizedBox(width: 12),
                    // Right Column: Table
                    pw.Expanded(
                      child: _buildPdfTableCard(firstPageEntries, dateFormat, isContinuation: false),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                    style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 8),
                  ),
                  pw.Text(
                    'Page 1 of $totalPages',
                    style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 8),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Page 2+: Table continuation
    if (remainingEntries.isNotEmpty) {
      final int itemsPerPage = 20;
      for (int i = 0; i < remainingEntries.length; i += itemsPerPage) {
        final chunk = remainingEntries.skip(i).take(itemsPerPage).toList();
        final pageNum = 2 + (i / itemsPerPage).floor();

        pdf.addPage(
          pw.Page(
            pageTheme: pageTheme,
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfDashboardHeader(l10n, beginDate, endDate, timestamp, isContinued: true),
                  pw.SizedBox(height: 12),
                  pw.Expanded(
                    child: _buildPdfTableCard(chunk, dateFormat, isContinuation: true),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                        style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 8),
                      ),
                      pw.Text(
                        'Page $pageNum of $totalPages',
                        style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 8),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  pw.Widget _buildPdfDashboardHeader(
    AppLocalizations l10n,
    DateTime beginDate,
    DateTime endDate,
    String timestamp, {
    bool isContinued = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              isContinued
                  ? 'POCKET LEDGER - Business Financial Report (Continued)'
                  : 'POCKET LEDGER - Business Financial Report',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Period: ${_fullDateFormat.format(beginDate)} - ${_fullDateFormat.format(endDate)}',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColor.fromHex('#94a3b8'),
              ),
            ),
          ],
        ),
        // Pocket Ledger Logo
        pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Container(
              width: 18,
              height: 15,
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue600,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              child: pw.Center(
                child: pw.Container(
                  width: 8,
                  height: 4,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.teal400,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(1)),
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Pocket',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.Text(
                  'Ledger',
                  style: pw.TextStyle(
                    color: PdfColors.blue400,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfKpiCard({
    required String title,
    required String value,
    required double trendPercent,
    required bool isFeatured,
    bool isGcash = false,
    bool isMaya = false,
  }) {
    final cardBgColor = isFeatured
        ? null
        : PdfColor.fromHex('#1e293b');
    final cardBorderColor = isFeatured
        ? null
        : PdfColor.fromHex('#334155');
    final titleTextColor = isFeatured
        ? PdfColor.fromHex('#e2e8f0')
        : PdfColor.fromHex('#94a3b8');
    final valueTextColor = PdfColors.white;

    final String trendSign = trendPercent > 0 ? '+' : '';
    final String trendArrow = trendPercent > 0 ? '^' : (trendPercent < 0 ? 'v' : '-');
    final String trendText = '$trendSign${trendPercent.toStringAsFixed(1)}% $trendArrow';

    final PdfColor trendColor = isFeatured
        ? PdfColor.fromHex('#e2e8f0')
        : (trendPercent > 0
            ? PdfColor.fromHex('#4ade80')
            : (trendPercent < 0 ? PdfColor.fromHex('#fca5a5') : PdfColor.fromHex('#94a3b8')));

    pw.Widget iconWidget;
    if (isFeatured) {
      iconWidget = pw.Container(
        width: 28,
        height: 28,
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#ffffff33'),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Center(
          child: pw.Container(
            width: 14,
            height: 8,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.white, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
            ),
            child: pw.Center(
              child: pw.Container(
                width: 4,
                height: 4,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                  shape: pw.BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (isGcash) {
      iconWidget = pw.Container(
        width: 28,
        height: 28,
        decoration: const pw.BoxDecoration(
          color: PdfColors.blue800,
          shape: pw.BoxShape.circle,
        ),
        child: pw.Center(
          child: pw.Text(
            'G',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else if (isMaya) {
      iconWidget = pw.Container(
        width: 28,
        height: 28,
        decoration: const pw.BoxDecoration(
          color: PdfColors.teal800,
          shape: pw.BoxShape.circle,
        ),
        child: pw.Center(
          child: pw.Text(
            'm',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else {
      iconWidget = pw.Container(
        width: 28,
        height: 28,
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#475569'),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Center(
          child: pw.Text(
            '%',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: pw.BoxDecoration(
          color: cardBgColor,
          gradient: isFeatured
              ? pw.LinearGradient(
                  colors: [PdfColor.fromHex('#22c55e'), PdfColor.fromHex('#059669')],
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                )
              : null,
          border: cardBorderColor != null ? pw.Border.all(color: cardBorderColor, width: 1) : null,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            iconWidget,
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: titleTextColor,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                  pw.SizedBox(height: 1),
                  pw.Text(
                    value,
                    style: pw.TextStyle(
                      fontSize: 12.5,
                      color: valueTextColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'KPI summary',
                        style: pw.TextStyle(
                          fontSize: 7,
                          color: isFeatured ? PdfColor.fromHex('#cbd5e1') : PdfColor.fromHex('#64748b'),
                        ),
                      ),
                      pw.Text(
                        trendText,
                        style: pw.TextStyle(
                          fontSize: 7,
                          color: trendColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfChartCard(_LedgerTotals totals, List<_LedgerExportRow> entries) {
    final absGcash = totals.gcashMovement.abs();
    final absMaya = totals.mayaMovement.abs();
    final absCash = totals.cashMovement.abs();
    final totalVol = absGcash + absMaya + absCash;

    final double gcashPct = totalVol > 0 ? (absGcash / totalVol) * 100 : 0.0;
    final double mayaPct = totalVol > 0 ? (absMaya / totalVol) * 100 : 0.0;
    final double cashPct = totalVol > 0 ? (absCash / totalVol) * 100 : 0.0;

    return pw.Container(
      width: 220,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1e293b'),
        border: pw.Border.all(color: PdfColor.fromHex('#334155'), width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Payment Method Share',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Expanded(
            child: pw.Center(
              child: totalVol <= 0
                  ? pw.Text(
                      'No wallet movements',
                      style: pw.TextStyle(color: PdfColor.fromHex('#94a3b8'), fontSize: 8),
                    )
                  : pw.SizedBox(
                      width: 110,
                      height: 110,
                      child: pw.Chart(
                        grid: pw.PieGrid(startAngle: 1.5),
                        datasets: [
                          if (absGcash > 0)
                            pw.PieDataSet(
                              legend: '${gcashPct.toStringAsFixed(0)}%',
                              value: absGcash,
                              color: PdfColor.fromHex('#2563eb'),
                              innerRadius: 36.0,
                              legendStyle: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9,
                              ),
                              legendPosition: pw.PieLegendPosition.inside,
                            ),
                          if (absMaya > 0)
                            pw.PieDataSet(
                              legend: '${mayaPct.toStringAsFixed(0)}%',
                              value: absMaya,
                              color: PdfColor.fromHex('#10b981'),
                              innerRadius: 36.0,
                              legendStyle: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9,
                              ),
                              legendPosition: pw.PieLegendPosition.inside,
                            ),
                          if (absCash > 0)
                            pw.PieDataSet(
                              legend: '${cashPct.toStringAsFixed(0)}%',
                              value: absCash,
                              color: PdfColor.fromHex('#4ade80'),
                              innerRadius: 36.0,
                              legendStyle: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9,
                              ),
                              legendPosition: pw.PieLegendPosition.inside,
                            ),
                        ],
                      ),
                    ),
            ),
          ),
          pw.SizedBox(height: 12),
          if (totalVol > 0)
            pw.Column(
              children: [
                if (absGcash > 0)
                  _buildLegendRow('GCash', '${gcashPct.toStringAsFixed(0)}%', PdfColor.fromHex('#2563eb')),
                if (absMaya > 0)
                  _buildLegendRow('Maya', '${mayaPct.toStringAsFixed(0)}%', PdfColor.fromHex('#10b981')),
                if (absCash > 0)
                  _buildLegendRow('Cash On-Hand', '${cashPct.toStringAsFixed(0)}%', PdfColor.fromHex('#4ade80')),
              ],
            ),
        ],
      ),
    );
  }

  pw.Widget _buildLegendRow(String label, String value, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 7,
                height: 7,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                label,
                style: pw.TextStyle(
                  color: PdfColor.fromHex('#cbd5e1'),
                  fontSize: 7.5,
                ),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7.5,
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Container(
                width: 3,
                height: 3,
                decoration: pw.BoxDecoration(
                  color: color,
                  shape: pw.BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTableCard(
    List<_LedgerExportRow> entries,
    DateFormat dateFormat, {
    required bool isContinuation,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1e293b'),
        border: pw.Border.all(color: PdfColor.fromHex('#334155'), width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            isContinuation ? 'Transaction History Log (Continued)' : 'Transaction History Log',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            columnWidths: const {
              0: pw.FixedColumnWidth(80),
              1: pw.FixedColumnWidth(65),
              2: pw.FixedColumnWidth(60),
              3: pw.FlexColumnWidth(),
              4: pw.FixedColumnWidth(85),
              5: pw.FixedColumnWidth(55),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#0f172a'),
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(6),
                    topRight: pw.Radius.circular(6),
                  ),
                ),
                children: [
                  _buildPdfTableHeader('Date/Time'),
                  _buildPdfTableHeader('Transaction ID'),
                  _buildPdfTableHeader('Money Flow'),
                  _buildPdfTableHeader('Description'),
                  _buildPdfTableHeader('Amount'),
                  _buildPdfTableHeader('Status'),
                ],
              ),
              ...entries.map((entry) {
                final isOutflow = entry.outflow > 0;
                final rowBgColor = isOutflow
                    ? PdfColor.fromHex('#2d1a1a')
                    : PdfColor.fromHex('#13251e');
                final rowTextColor = isOutflow
                    ? PdfColor.fromHex('#fca5a5')
                    : PdfColor.fromHex('#86efac');

                final typeText = isOutflow ? 'Money Out' : 'Money In';
                final prefix = isOutflow ? '-' : '+';
                final txId = entry.reference.isNotEmpty ? entry.reference : '-';

                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: rowBgColor),
                  children: [
                    _buildPdfTableCell(dateFormat.format(entry.createdAt), rowTextColor),
                    _buildPdfTableCell(txId, rowTextColor),
                    _buildPdfTableCell(typeText, rowTextColor, fontWeight: pw.FontWeight.bold),
                    _buildPdfTableCell(_pdfSafeText(entry.title), rowTextColor),
                    _buildPdfTableCell(
                      '$prefix${_reportCurrency(entry.amountShown)}',
                      rowTextColor,
                      fontWeight: pw.FontWeight.bold,
                      alignRight: true,
                    ),
                    _buildPdfTableCell('Completed', rowTextColor),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          fontSize: 7.5,
        ),
      ),
    );
  }

  pw.Widget _buildPdfTableCell(
    String text,
    PdfColor textColor, {
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    bool alignRight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Container(
        alignment: alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: textColor,
            fontWeight: fontWeight,
            fontSize: 7,
          ),
        ),
      ),
    );
  }

  List<int> _buildExcelReport({
    required List<_LedgerExportRow> entries,
    required DateTime beginDate,
    required DateTime endDate,
    required _LedgerTotals totals,
  }) {
    final excel = ex.Excel.createExcel();
    final sheet = excel[context.l10n.walletFlowSheetName];
    final dateFormat = DateFormat('MM/dd/yyyy, HH:mm');

    // Create styles using the compiler-verified excelColor extension method
    final titleStyle = ex.CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: 'FFFFFFFF'.excelColor,
      backgroundColorHex: 'FF0F172A'.excelColor, // Slate 900
    );
    final subtitleStyle = ex.CellStyle(
      fontSize: 10,
      fontColorHex: 'FF94A3B8'.excelColor, // Slate 400
      backgroundColorHex: 'FF0F172A'.excelColor, // Slate 900
    );
    final cardHeaderStyle = ex.CellStyle(
      bold: true,
      fontSize: 9,
      fontColorHex: 'FFFFFFFF'.excelColor,
      backgroundColorHex: 'FF1E293B'.excelColor, // Slate 800
    );
    final cashCardHeaderStyle = ex.CellStyle(
      bold: true,
      fontSize: 9,
      fontColorHex: 'FFFFFFFF'.excelColor,
      backgroundColorHex: 'FF10B981'.excelColor, // Emerald 500
    );
    final cardValueStyle = ex.CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: 'FFFFFFFF'.excelColor,
      backgroundColorHex: 'FF1E293B'.excelColor, // Slate 800
    );
    final cashCardValueStyle = ex.CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: 'FFFFFFFF'.excelColor,
      backgroundColorHex: 'FF10B981'.excelColor, // Emerald 500
    );
    final cardSubStyle = ex.CellStyle(
      fontSize: 8,
      fontColorHex: 'FF94A3B8'.excelColor, // Slate 400
      backgroundColorHex: 'FF1E293B'.excelColor, // Slate 800
    );
    final cashCardSubStyle = ex.CellStyle(
      fontSize: 8,
      fontColorHex: 'FFD1FAE5'.excelColor, // Light green
      backgroundColorHex: 'FF10B981'.excelColor, // Emerald 500
    );
    final tableHeaderStyle = ex.CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: 'FFFFFFFF'.excelColor,
      backgroundColorHex: 'FF334155'.excelColor, // Slate 700
    );
    final inflowStyle = ex.CellStyle(
      fontSize: 9,
      fontColorHex: 'FF065F46'.excelColor, // Dark green
      backgroundColorHex: 'FFD1FAE5'.excelColor, // Light green
    );
    final outflowStyle = ex.CellStyle(
      fontSize: 9,
      fontColorHex: 'FF991B1B'.excelColor, // Dark red
      backgroundColorHex: 'FFFEE2E2'.excelColor, // Light red
    );
    final legendLabelStyle = ex.CellStyle(
      fontSize: 9,
      fontColorHex: 'FFCBD5E1'.excelColor, // Slate 300
      backgroundColorHex: 'FF1E293B'.excelColor, // Slate 800
    );
    final legendValueStyle = ex.CellStyle(
      bold: true,
      fontSize: 9,
      fontColorHex: 'FFFFFFFF'.excelColor,
      backgroundColorHex: 'FF1E293B'.excelColor, // Slate 800
    );
    final totalsStyle = ex.CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: 'FF0F172A'.excelColor, // Slate 900
      backgroundColorHex: 'FFF1F5F9'.excelColor, // Slate 100
    );

    // Calculate stats for the KPI trend percentages (same as PDF)
    double cashInflow = 0;
    double cashOutflow = 0;
    double gcashInflow = 0;
    double gcashOutflow = 0;
    double mayaInflow = 0;
    double mayaOutflow = 0;
    double totalVolume = 0;

    for (final entry in entries) {
      if (entry.cashChange > 0) cashInflow += entry.cashChange;
      if (entry.cashChange < 0) cashOutflow += entry.cashChange.abs();
      if (entry.gcashChange > 0) gcashInflow += entry.gcashChange;
      if (entry.gcashChange < 0) gcashOutflow += entry.gcashChange.abs();
      if (entry.mayaChange > 0) mayaInflow += entry.mayaChange;
      if (entry.mayaChange < 0) mayaOutflow += entry.mayaChange.abs();
      totalVolume += entry.inflow + entry.outflow;
    }

    final double cashTrend = (cashInflow + cashOutflow > 0)
        ? (totals.cashMovement / (cashInflow + cashOutflow)) * 100
        : 0.0;
    final double gcashTrend = (gcashInflow + gcashOutflow > 0)
        ? (totals.gcashMovement / (gcashInflow + gcashOutflow)) * 100
        : 0.0;
    final double mayaTrend = (mayaInflow + mayaOutflow > 0)
        ? (totals.mayaMovement / (mayaInflow + mayaOutflow)) * 100
        : 0.0;
    final double feeTrend = (totalVolume > 0)
        ? (totals.totalCharges / totalVolume) * 100
        : 0.0;

    String getTrendText(double trendPercent) {
      final String trendSign = trendPercent > 0 ? '+' : '';
      final String trendArrow = trendPercent > 0 ? '^' : (trendPercent < 0 ? 'v' : '-');
      return '$trendSign${trendPercent.toStringAsFixed(1)}% $trendArrow';
    }

    // Payment method share calculation
    final absGcash = totals.gcashMovement.abs();
    final absMaya = totals.mayaMovement.abs();
    final absCash = totals.cashMovement.abs();
    final totalVol = absGcash + absMaya + absCash;

    final double gcashPct = totalVol > 0 ? (absGcash / totalVol) * 100 : 0.0;
    final double mayaPct = totalVol > 0 ? (absMaya / totalVol) * 100 : 0.0;
    final double cashPct = totalVol > 0 ? (absCash / totalVol) * 100 : 0.0;

    void setCell(int col, int row, ex.CellValue value, ex.CellStyle style) {
      final cell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = value;
      cell.cellStyle = style;
    }

    // 1. Header block
    for (int col = 0; col < 9; col++) {
      setCell(col, 0, ex.TextCellValue(col == 0 ? 'POCKET LEDGER - Business Financial Report' : ''), titleStyle);
      setCell(col, 1, ex.TextCellValue(col == 0 ? 'Period: ${_fullDateFormat.format(beginDate)} - ${_fullDateFormat.format(endDate)}' : ''), subtitleStyle);
      setCell(col, 2, ex.TextCellValue(col == 0 ? 'Generated: ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}' : ''), subtitleStyle);
    }

    // 2. KPI Cards Row (Row 4-6)
    // Card 1: On-Hand Cash (A-B)
    setCell(0, 4, ex.TextCellValue('On-Hand Cash:'), cashCardHeaderStyle);
    setCell(1, 4, ex.TextCellValue(''), cashCardHeaderStyle);
    setCell(0, 5, ex.TextCellValue(_reportSignedCurrency(totals.cashMovement)), cashCardValueStyle);
    setCell(1, 5, ex.TextCellValue(''), cashCardValueStyle);
    setCell(0, 6, ex.TextCellValue('KPI summary  ${getTrendText(cashTrend)}'), cashCardSubStyle);
    setCell(1, 6, ex.TextCellValue(''), cashCardSubStyle);

    // Card 2: GCash Net Change (D-E)
    setCell(3, 4, ex.TextCellValue('GCash Net Change:'), cardHeaderStyle);
    setCell(4, 4, ex.TextCellValue(''), cardHeaderStyle);
    setCell(3, 5, ex.TextCellValue(_reportSignedCurrency(totals.gcashMovement)), cardValueStyle);
    setCell(4, 5, ex.TextCellValue(''), cardValueStyle);
    setCell(3, 6, ex.TextCellValue('KPI summary  ${getTrendText(gcashTrend)}'), cardSubStyle);
    setCell(4, 6, ex.TextCellValue(''), cardSubStyle);

    // Card 3: Maya Net Change (F-G)
    setCell(5, 4, ex.TextCellValue('Maya Net Change:'), cardHeaderStyle);
    setCell(6, 4, ex.TextCellValue(''), cardHeaderStyle);
    setCell(5, 5, ex.TextCellValue(_reportSignedCurrency(totals.mayaMovement)), cardValueStyle);
    setCell(6, 5, ex.TextCellValue(''), cardValueStyle);
    setCell(5, 6, ex.TextCellValue('KPI summary  ${getTrendText(mayaTrend)}'), cardSubStyle);
    setCell(6, 6, ex.TextCellValue(''), cardSubStyle);

    // Card 4: Total Service Fees (H-I)
    setCell(7, 4, ex.TextCellValue('Total Service Fees:'), cardHeaderStyle);
    setCell(8, 4, ex.TextCellValue(''), cardHeaderStyle);
    setCell(7, 5, ex.TextCellValue(_reportCurrency(totals.totalCharges)), cardValueStyle);
    setCell(8, 5, ex.TextCellValue(''), cardValueStyle);
    setCell(7, 6, ex.TextCellValue('KPI summary  ${getTrendText(feeTrend)}'), cardSubStyle);
    setCell(8, 6, ex.TextCellValue(''), cardSubStyle);

    // 3. Side-by-Side Analytics Section
    // Row 8 Header Row
    setCell(0, 8, ex.TextCellValue('Payment Method Share'), cardHeaderStyle);
    setCell(1, 8, ex.TextCellValue(''), cardHeaderStyle);

    setCell(3, 8, ex.TextCellValue('Date/Time'), tableHeaderStyle);
    setCell(4, 8, ex.TextCellValue('Transaction ID'), tableHeaderStyle);
    setCell(5, 8, ex.TextCellValue('Money Flow'), tableHeaderStyle);
    setCell(6, 8, ex.TextCellValue('Description'), tableHeaderStyle);
    setCell(7, 8, ex.TextCellValue('Amount'), tableHeaderStyle);
    setCell(8, 8, ex.TextCellValue('Status'), tableHeaderStyle);

    // Row 9, 10, 11: Left Legend
    setCell(0, 9, ex.TextCellValue('GCash'), legendLabelStyle);
    setCell(1, 9, ex.TextCellValue('${gcashPct.toStringAsFixed(0)}%'), legendValueStyle);

    setCell(0, 10, ex.TextCellValue('Maya'), legendLabelStyle);
    setCell(1, 10, ex.TextCellValue('${mayaPct.toStringAsFixed(0)}%'), legendValueStyle);

    setCell(0, 11, ex.TextCellValue('Cash On-Hand'), legendLabelStyle);
    setCell(1, 11, ex.TextCellValue('${cashPct.toStringAsFixed(0)}%'), legendValueStyle);

    // Fill remaining rows of Left Column with blank space or default cell style
    for (int r = 12; r < 9 + entries.length; r++) {
      setCell(0, r, ex.TextCellValue(''), legendLabelStyle);
      setCell(1, r, ex.TextCellValue(''), legendLabelStyle);
    }

    // Right Column transaction log rows (starting at Row 9)
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final r = 9 + i;
      final isOutflow = entry.outflow > 0;
      final style = isOutflow ? outflowStyle : inflowStyle;
      final flowText = isOutflow ? 'Money Out' : 'Money In';
      final txId = entry.reference.isNotEmpty ? entry.reference : '-';
      final displayAmount = isOutflow ? -entry.amountShown : entry.amountShown;

      setCell(3, r, ex.TextCellValue(dateFormat.format(entry.createdAt)), style);
      setCell(4, r, ex.TextCellValue(txId), style);
      setCell(5, r, ex.TextCellValue(flowText), style);
      setCell(6, r, ex.TextCellValue(entry.title), style);
      setCell(7, r, ex.DoubleCellValue(displayAmount), style);
      setCell(8, r, ex.TextCellValue('Completed'), style);
    }

    // 4. Totals Row at the bottom of Right Table
    final rTotals = 9 + entries.length;
    setCell(3, rTotals, ex.TextCellValue(''), totalsStyle);
    setCell(4, rTotals, ex.TextCellValue(''), totalsStyle);
    setCell(5, rTotals, ex.TextCellValue(''), totalsStyle);
    setCell(6, rTotals, ex.TextCellValue('Net Business Change:'), totalsStyle);
    setCell(7, rTotals, ex.DoubleCellValue(totals.cashMovement + totals.gcashMovement + totals.mayaMovement), totalsStyle);
    setCell(8, rTotals, ex.TextCellValue(''), totalsStyle);

    // 5. Fee Destination summary row below totals
    final rFeeRouting = rTotals + 2;
    setCell(3, rFeeRouting, ex.TextCellValue('Fee Destination:'), totalsStyle);
    setCell(4, rFeeRouting, ex.TextCellValue(_formatFeeRoutingSummary(totals)), totalsStyle);
    setCell(5, rFeeRouting, ex.TextCellValue(''), totalsStyle);
    setCell(6, rFeeRouting, ex.TextCellValue(''), totalsStyle);
    setCell(7, rFeeRouting, ex.TextCellValue(''), totalsStyle);
    setCell(8, rFeeRouting, ex.TextCellValue(''), totalsStyle);

    // Set human-readable column widths to avoid cell truncation
    final colWidths = [18.0, 12.0, 4.0, 18.0, 16.0, 14.0, 25.0, 15.0, 12.0];
    for (var col = 0; col < colWidths.length; col++) {
      sheet.setColumnWidth(col, colWidths[col]);
    }

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
    final parts = amount.toStringAsFixed(2).split('.');
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = parts[0].replaceAllMapped(reg, (Match m) => '${m[1]},');
    return 'PHP $formattedInt.${parts[1]}';
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
          backgroundColor: isError ? AppColors.error : AppColors.success,
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

  bool _isWalletOutflow(_HistoryRow item) {
    if (item.entryType == 'transaction') {
      final isQr = item.onHandDelta == 0 && (item.walletDelta != 0 || item.mayaWalletDelta != 0);
      if (isQr) {
        // QR payment increases the merchant's wallet, so it is never an outflow.
        return false;
      }

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

  Color _walletColor(String walletAccount) {
    final key = _normalizeWalletKey(walletAccount);
    switch (key) {
      case 'gcash':
        return AppColors.primary;
      case 'maya':
        return AppColors.secondary;
      case 'on_hand':
        return AppColors.onHand;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _buildDualImpactText(_HistoryRow item) {
    final isMaya = _normalizeWalletKey(item.walletAccount) == 'maya';
    final walletLabel = isMaya ? context.l10n.maya : context.l10n.gcash;
    final walletDelta = isMaya ? item.mayaWalletDelta : item.walletDelta;
    final onHandDelta = item.onHandDelta;
    final fee = item.chargeAmount;
    final isCashOut = item.iconKey == 'cash_out' || item.iconKey == 'maya_cash_out';

    if (item.entryType == 'transaction') {
      final isQr = onHandDelta == 0 && walletDelta != 0;
      if (isQr) {
        return 'Received ${_currencyFormat.format(walletDelta.abs())} $walletLabel via QR • Earned: ${_currencyFormat.format(fee)}';
      }
      if (isCashOut) {
        return 'Received ${_currencyFormat.format(walletDelta.abs())} $walletLabel • Paid ${_currencyFormat.format(onHandDelta.abs())} Cash • Earned: ${_currencyFormat.format(fee)}';
      } else {
        return 'Sent ${_currencyFormat.format(walletDelta.abs())} $walletLabel • Received ${_currencyFormat.format(onHandDelta.abs())} Cash • Earned: ${_currencyFormat.format(fee)}';
      }
    }

    final parts = <String>[];
    if (walletDelta != 0) {
      parts.add('$walletLabel: ${walletDelta > 0 ? '+' : '−'}${_currencyFormat.format(walletDelta.abs())}');
    }
    if (onHandDelta != 0) {
      parts.add('${context.l10n.onHand}: ${onHandDelta > 0 ? '+' : '−'}${_currencyFormat.format(onHandDelta.abs())}');
    }
    return parts.join(' • ');
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
