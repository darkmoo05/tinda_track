import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/di/database_providers.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_app_bar.dart';

import '../../transactions/screens/add_owner_movement_screen.dart';
import '../data/dashboard_repository.dart';
import '../data/statement_entry.dart';

class PersonalExpenseStatementScreen extends ConsumerStatefulWidget {
  const PersonalExpenseStatementScreen({super.key});

  @override
  ConsumerState<PersonalExpenseStatementScreen> createState() =>
      _PersonalExpenseStatementScreenState();
}

enum _RecentRange { today, sevenDays, thirtyDays }

class _PersonalExpenseStatementScreenState
    extends ConsumerState<PersonalExpenseStatementScreen> {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_PH',
    symbol: 'PHP ',
    decimalDigits: 2,
  );
  static final DateFormat _dayHeaderDate = DateFormat('EEE, dd MMM yyyy');
  static const String _lastSeenKey = 'personal_expense_statement_last_seen_ms';

  late Future<List<StatementEntry>> _entriesFuture;
  _RecentRange _selectedRange = _RecentRange.today;
  DateTime? _lastSeenCutoff;
  bool _didPersistLastSeen = false;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _outlineColor => _isDark ? const Color(0xFF334155) : AppColors.outlineVariant;
  Color get _textOnSurfaceVar => _isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;
  Color get _cardBgInfo => _isDark ? const Color(0xFF1E293B) : AppColors.lightBlueBackground;

  @override
  void initState() {
    super.initState();
    _entriesFuture = DashboardRepository(
      database: ref.read(currentAppDatabaseProvider),
    ).loadStatementEntries();
    _loadLastSeen();
  }

  Future<void> _reload() async {
    setState(() {
      _didPersistLastSeen = false;
      _entriesFuture = DashboardRepository(
        database: ref.read(currentAppDatabaseProvider),
      ).loadStatementEntries();
    });
  }

  Future<void> _loadLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastSeenKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _lastSeenCutoff = ms == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ms);
    });
  }

  Future<void> _persistLastSeenOnce(List<StatementEntry> entries) async {
    if (_didPersistLastSeen || entries.isEmpty) {
      return;
    }

    _didPersistLastSeen = true;
    final newest = entries
        .map((e) => e.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSeenKey, newest.millisecondsSinceEpoch);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ArchitectAppBar(title: context.l10n.appTitle, actions: const []),
      body: FutureBuilder<List<StatementEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load statement entries.'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          final summary = _summarize(entries);
          _persistLastSeenOnce(entries);

          final personalEntries = entries
              .where((e) => _isPersonalType(e.type))
              .toList();
          final filteredPersonal = _applyRecentFilter(personalEntries);

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              _buildHeroCard(summary),
              const SizedBox(height: 14),
              _buildMetricsGrid(summary),
              const SizedBox(height: 14),
              _buildTimelineSection(
                allEntries: entries,
                personalEntries: filteredPersonal,
              ),
              const SizedBox(height: 14),
              _buildInfoCard(),
            ],
          );
        },
      ),
    );
  }

  _StatementSummary _summarize(List<StatementEntry> entries) {
    var expenseTaken = 0.0;
    var expensePaid = 0.0;

    for (final entry in entries) {
      final type = entry.type.toLowerCase().trim();
      final amount = _parseAmount(entry.amount);
      if (amount <= 0) {
        continue;
      }

      if (type == 'personal expense' || type == 'borrowed funds') {
        expenseTaken += amount;
      } else if (type == 'personal expense payment' ||
          type == 'borrowed funds repayment') {
        expensePaid += amount;
      }
    }

    return _StatementSummary(
      expenseTaken: expenseTaken,
      expensePaid: expensePaid,
    );
  }

  double _parseAmount(String amountText) {
    final cleaned = amountText
        .replaceAll(RegExp(r'[^0-9.,]'), '')
        .replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _fmt(double value) => _currency.format(value);

  List<StatementEntry> _applyRecentFilter(List<StatementEntry> entries) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    DateTime start;
    if (_selectedRange == _RecentRange.today) {
      start = todayStart;
    } else if (_selectedRange == _RecentRange.sevenDays) {
      start = todayStart.subtract(const Duration(days: 6));
    } else {
      start = todayStart.subtract(const Duration(days: 29));
    }

    return entries.where((entry) => !entry.createdAt.isBefore(start)).toList();
  }

  int _countNewEntries(List<StatementEntry> entries) {
    final cutoff = _lastSeenCutoff;
    if (cutoff == null) {
      return 0;
    }
    return entries.where((entry) => entry.createdAt.isAfter(cutoff)).length;
  }

  Future<void> _navigateToAddMovement(String movementType) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddOwnerMovementScreen(
          initialMovementType: movementType,
        ),
      ),
    );

    if (saved == true && mounted) {
      _reload();
    }
  }

  Widget _buildHeroCard(_StatementSummary summary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTaken = summary.expenseTaken;
    final totalPaid = summary.expensePaid;
    final outstanding = summary.totalOutstanding;
    final repaymentProgress = totalTaken > 0 ? (totalPaid / totalTaken).clamp(0.0, 1.0) : 0.0;
    
    final heroGradient = const LinearGradient(
      colors: [AppColors.primary, Color(0xFF0F172A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUTSTANDING DEBT BALANCE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _fmt(outstanding),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repayment Progress',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(repaymentProgress * 100).toStringAsFixed(0)}% Paid',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.16),
              child: Row(
                children: [
                  if (repaymentProgress > 0)
                    Expanded(
                      flex: (repaymentProgress * 100).round(),
                      child: Container(
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
                      ),
                    ),
                  if (repaymentProgress < 1)
                    Expanded(
                      flex: ((1 - repaymentProgress) * 100).round(),
                      child: const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Paid ${_fmt(totalPaid)} of ${_fmt(totalTaken)} total borrowed',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: outstanding > 0 ? () => _navigateToAddMovement('Borrowed Funds Repayment') : null,
                  icon: const Icon(Icons.settings_backup_restore_rounded, size: 16),
                  label: const Text('Repay Debt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToAddMovement('Borrowed Funds'),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                  label: const Text('Borrow More'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(_StatementSummary summary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTaken = summary.expenseTaken;
    final totalPaid = summary.expensePaid;
    final outstanding = summary.totalOutstanding;
    final repaymentRate = totalTaken > 0 ? (totalPaid / totalTaken * 100) : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Borrowed',
                value: _fmt(totalTaken),
                icon: Icons.payments_outlined,
                color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Total Repaid',
                value: _fmt(totalPaid),
                icon: Icons.check_circle_outline_rounded,
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Repayment Rate',
                value: '${repaymentRate.toStringAsFixed(1)}%',
                icon: Icons.speed_rounded,
                color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Remaining Debt',
                value: _fmt(outstanding),
                icon: Icons.timelapse_rounded,
                color: outstanding > 0 
                    ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)) 
                    : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection({
    required List<StatementEntry> allEntries,
    required List<StatementEntry> personalEntries,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newCount = _countNewEntries(allEntries);
    final groupedEntries = _groupEntriesByDay(personalEntries);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Timeline',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      newCount > 0 
                          ? '$newCount new update${newCount == 1 ? '' : 's'} since last visit' 
                          : 'No new updates',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: newCount > 0 
                            ? (isDark ? const Color(0xFF38BDF8) : AppColors.primary) 
                            : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              if (newCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRangeChips(),
          const SizedBox(height: 16),
          if (personalEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No transactions found in this range.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Column(
              children: groupedEntries.map((group) {
                return _buildFlatDateGroup(
                  title: _dayHeaderDate.format(group.day),
                  entries: group.entries,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRangeChips() {
    Widget chip(_RecentRange value, String label) {
      return ChoiceChip(
        label: Text(label),
        selected: _selectedRange == value,
        onSelected: (selected) {
          if (!selected) {
            return;
          }
          setState(() {
            _selectedRange = value;
          });
        },
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(_RecentRange.today, 'Today'),
        chip(_RecentRange.sevenDays, '7 Days'),
        chip(_RecentRange.thirtyDays, '30 Days'),
      ],
    );
  }

  Widget _buildFlatDateGroup({
    required String title,
    required List<StatementEntry> entries,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF64748B) : AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              letterSpacing: 0.3,
            ),
          ),
        ),
        Column(
          children: List.generate(entries.length, (index) {
            return _buildTimelineRow(entries[index]);
          }),
        ),
      ],
    );
  }

  Widget _buildTimelineRow(StatementEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPayment = _isPaymentType(entry.type);
    
    final badgeText = isPayment ? 'Repayment' : 'Borrowed';
    final badgeColor = isPayment 
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444));
        
    final icon = isPayment
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: badgeColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _friendlyType(entry.type),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.note == null || entry.note!.trim().isEmpty
                      ? entry.date
                      : '${entry.date} • ${entry.note}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.amount,
                style: TextStyle(
                  color: isPayment 
                      ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)) 
                      : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: badgeColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBgInfo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outlineColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Borrowed Funds is money you take for personal use from the store. Remaining means Taken minus Paid Back.',
              style: TextStyle(fontSize: 12, color: _textOnSurfaceVar),
            ),
          ),
        ],
      ),
    );
  }

  List<_DateEntryGroup> _groupEntriesByDay(List<StatementEntry> entries) {
    final grouped = <DateTime, List<StatementEntry>>{};
    for (final entry in entries) {
      final day = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      grouped.putIfAbsent(day, () => <StatementEntry>[]).add(entry);
    }

    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return days
        .map(
          (day) => _DateEntryGroup(
            day: day,
            entries: grouped[day]!
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
          ),
        )
        .toList(growable: false);
  }

  bool _isPersonalType(String type) {
    final normalized = type.toLowerCase().trim();
    return normalized == 'personal expense' ||
        normalized == 'personal expense payment' ||
        normalized == 'borrowed funds' ||
        normalized == 'borrowed funds repayment';
  }

  bool _isPaymentType(String type) {
    final normalized = type.toLowerCase().trim();
    return normalized.contains('payment');
  }

  String _friendlyType(String type) {
    final normalized = type.toLowerCase().trim();
    if (normalized == 'personal expense' || normalized == 'borrowed funds') {
      return 'Borrowed Funds Taken';
    }
    if (normalized == 'personal expense payment' ||
        normalized == 'borrowed funds repayment') {
      return 'Borrowed Funds Repayment';
    }
    return type;
  }
}

class _StatementSummary {
  const _StatementSummary({
    required this.expenseTaken,
    required this.expensePaid,
  });

  final double expenseTaken;
  final double expensePaid;

  _TypeSummary get personal =>
      _TypeSummary(taken: expenseTaken, paid: expensePaid);

  double get expenseOutstanding => expenseTaken - expensePaid;
  double get totalOutstanding => expenseOutstanding;
}

class _TypeSummary {
  const _TypeSummary({required this.taken, required this.paid});

  final double taken;
  final double paid;

  double get remaining => taken - paid;

  double get ratio => taken > 0 ? (paid / taken).clamp(0.0, 1.0) : 0.0;

  double get ratioPercent => ratio * 100;
}

class _DateEntryGroup {
  final DateTime day;
  final List<StatementEntry> entries;

  _DateEntryGroup({required this.day, required this.entries});
}
