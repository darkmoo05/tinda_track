import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_theme.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/architect_app_bar.dart';
import '../../shared/widgets/screen_header_card.dart';
import 'data/dashboard_repository.dart';
import 'data/statement_entry.dart';

class PersonalExpenseStatementScreen extends StatefulWidget {
  const PersonalExpenseStatementScreen({super.key});

  @override
  State<PersonalExpenseStatementScreen> createState() =>
      _PersonalExpenseStatementScreenState();
}

enum _RecentRange { today, sevenDays, thirtyDays }

class _PersonalExpenseStatementScreenState
    extends State<PersonalExpenseStatementScreen> {
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
  final Set<String> _showAllGroupKeys = <String>{};
  final Map<String, GlobalKey> _expansionKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _entriesFuture = DashboardRepository().loadStatementEntries();
    _loadLastSeen();
  }

  Future<void> _reload() async {
    setState(() {
      _didPersistLastSeen = false;
      _entriesFuture = DashboardRepository().loadStatementEntries();
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

  GlobalKey _keyFor(String id) {
    return _expansionKeys.putIfAbsent(id, () => GlobalKey());
  }

  void _scrollToSection(String id, {bool followExpansion = false}) {
    void runScroll() {
      if (!mounted) {
        return;
      }
      final targetContext = _expansionKeys[id]?.currentContext;
      if (targetContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.08,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => runScroll());

    if (followExpansion) {
      Future<void>.delayed(const Duration(milliseconds: 220), runScroll);
    }
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
              _buildPageHeader(summary),
              const SizedBox(height: 16),
              _buildCurrentBalanceSection(summary),
              const SizedBox(height: 16),
              _buildHowChangedSection(summary),
              const SizedBox(height: 16),
              _buildRecentUpdatesSection(
                allEntries: entries,
                personalEntries: filteredPersonal,
              ),
              const SizedBox(height: 16),
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

  Widget _buildPageHeader(_StatementSummary summary) {
    return ScreenHeaderCard(
      title: 'Borrowed Funds Statement',
      subtitle: 'Outstanding balance · ${_fmt(summary.totalOutstanding)}',
      gradientColors: const [Color(0xFFB71C1C), Color(0xFFE53935)],
    );
  }

  Widget _buildCurrentBalanceSection(_StatementSummary summary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Borrowed Funds Balance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _buildLargeBalanceTile(
            title: 'Borrowed Funds',
            summary: summary.personal,
            accent: AppColors.primary,
            cardColor: const Color(0xFFEBF3FF),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeBalanceTile({
    required String title,
    required _TypeSummary summary,
    required Color accent,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          _buildMetricLine('Taken', _fmt(summary.taken)),
          const SizedBox(height: 4),
          _buildMetricLine('Paid Back', _fmt(summary.paid)),
          const SizedBox(height: 4),
          _buildMetricLine('Remaining', _fmt(summary.remaining), isBold: true),
          const SizedBox(height: 8),
          Text(
            'Paid ${summary.ratioPercent.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: summary.ratio,
              color: accent,
              backgroundColor: AppColors.surfaceContainerHigh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricLine(String label, String amount, {bool isBold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildHowChangedSection(_StatementSummary summary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How This Changed',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          const Text(
            'Each expense has its own flow: Taken -> Paid Back -> Remaining',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          _buildTypeFlowCard(
            title: 'Borrowed Funds Flow',
            typeSummary: summary.personal,
            accent: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFlowCard({
    required String title,
    required _TypeSummary typeSummary,
    required Color accent,
  }) {
    final takenSafe = typeSummary.taken <= 0 ? 1.0 : typeSummary.taken;
    final paidRatio = (typeSummary.paid / takenSafe).clamp(0.0, 1.0);
    final remainingRatio = (typeSummary.remaining / takenSafe).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          _buildFlowRow(
            title: '1) Taken',
            amount: _fmt(typeSummary.taken),
            barColor: accent,
            ratio: 1,
          ),
          const SizedBox(height: 8),
          _buildFlowRow(
            title: '2) Paid Back',
            amount: _fmt(typeSummary.paid),
            barColor: AppColors.secondary,
            ratio: paidRatio,
          ),
          const SizedBox(height: 8),
          _buildFlowRow(
            title: '3) Remaining',
            amount: _fmt(typeSummary.remaining),
            barColor: AppColors.error,
            ratio: remainingRatio,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowRow({
    required String title,
    required String amount,
    required Color barColor,
    required double ratio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: ratio,
            color: barColor,
            backgroundColor: AppColors.surfaceContainerHigh,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentUpdatesSection({
    required List<StatementEntry> allEntries,
    required List<StatementEntry> personalEntries,
  }) {
    final newCount = _countNewEntries(allEntries);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Updates',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                newCount > 0
                    ? 'New since last visit: $newCount'
                    : 'No new updates since last visit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: newCount > 0
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (newCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
          const SizedBox(height: 10),
          _buildRangeChips(),
          const SizedBox(height: 10),
          _buildUpdatesAccordion(
            title: 'Borrowed Funds Updates',
            accent: AppColors.primary,
            entries: personalEntries,
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

  Widget _buildUpdatesAccordion({
    required String title,
    required Color accent,
    required List<StatementEntry> entries,
  }) {
    final groupedEntries = _groupEntriesByDay(entries);
    final accordionKeyId = 'accordion-$title';

    return Container(
      key: _keyFor(accordionKeyId),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          iconColor: accent,
          collapsedIconColor: accent,
          onExpansionChanged: (expanded) {
            if (expanded) {
              _scrollToSection(accordionKeyId, followExpansion: true);
            }
          },
          expansionAnimationStyle: const AnimationStyle(
            duration: Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
          title: Text(
            '$title (${entries.length})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          children: entries.isEmpty
              ? const [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'No updates yet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ]
              : groupedEntries
                    .map(
                      (group) => _buildDateGroupTile(
                        groupKey: '$title-${group.day.millisecondsSinceEpoch}',
                        title: _dayHeaderDate.format(group.day),
                        entries: group.entries,
                        accent: accent,
                      ),
                    )
                    .toList(growable: false),
        ),
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

  Widget _buildDateGroupTile({
    required String groupKey,
    required String title,
    required List<StatementEntry> entries,
    required Color accent,
  }) {
    final showAll = _showAllGroupKeys.contains(groupKey);
    final visibleEntries = showAll ? entries : entries.take(12).toList();

    return Container(
      key: _keyFor(groupKey),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        iconColor: accent,
        collapsedIconColor: accent,
        onExpansionChanged: (expanded) {
          if (expanded) {
            _scrollToSection(groupKey, followExpansion: true);
          }
        },
        expansionAnimationStyle: const AnimationStyle(
          duration: Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
        title: Text(
          '$title (${entries.length})',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            child: Column(
              children: [
                ...visibleEntries.asMap().entries.map(
                  (item) => _buildAnimatedTimelineRow(
                    entry: item.value,
                    index: item.key,
                  ),
                ),
                if (entries.length > 12)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          if (showAll) {
                            _showAllGroupKeys.remove(groupKey);
                          } else {
                            _showAllGroupKeys.add(groupKey);
                          }
                        });
                      },
                      icon: Icon(
                        showAll
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                      ),
                      label: Text(
                        showAll ? 'Show Less' : 'Show All (${entries.length})',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTimelineRow({
    required StatementEntry entry,
    required int index,
  }) {
    final clampedIndex = index > 8 ? 8 : index;
    final duration = Duration(milliseconds: 150 + (clampedIndex * 35));

    return TweenAnimationBuilder<double>(
      key: ValueKey(
        '${entry.createdAt.millisecondsSinceEpoch}-${entry.type}-$index',
      ),
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final y = (1 - value) * 8;
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, y), child: child),
        );
      },
      child: _buildTimelineRow(entry),
    );
  }

  Widget _buildTimelineRow(StatementEntry entry) {
    final isPayment = _isPaymentType(entry.type);
    final badgeText = isPayment ? 'Payment Made' : 'Money Taken';
    final badgeColor = isPayment ? AppColors.secondary : AppColors.error;
    final icon = isPayment
        ? Icons.arrow_circle_up_rounded
        : Icons.arrow_circle_down_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: badgeColor, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _friendlyType(entry.type),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.note == null || entry.note!.trim().isEmpty
                      ? entry.date
                      : '${entry.date} • ${entry.note}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            entry.amount,
            style: TextStyle(
              color: entry.amountColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Borrowed Funds is money you take for personal use from the store. Remaining means Taken minus Paid Back.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
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
