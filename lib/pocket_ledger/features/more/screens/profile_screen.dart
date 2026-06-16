import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/database/app_database.dart' show MonitoringSessionRow;
import '../../../../core/database/providers/auth_providers.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/sync/sync_orchestrator.dart';
import '../logic/monitoring_session_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final username = authState.username ?? 'User';
    final role = authState.role ?? 'OWNER';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Role: $role',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.profileDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildMonitoringSessionsSection(context, ref),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context, ref),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('LOG OUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Monitoring Sessions Section ────────────────────────────────────────────

  Widget _buildMonitoringSessionsSection(BuildContext context, WidgetRef ref) {
    final selectedSessionAsync = ref.watch(selectedSessionProvider);
    final sessionsAsync = ref.watch(monitoringSessionsStreamProvider);
    final selectedBalancesAsync = ref.watch(selectedSessionBalancesProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.5);

    return selectedSessionAsync.when(
      data: (selectedSession) {
        if (selectedSession == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No Active Monitoring Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Start a new session to begin monitoring your wallets and transaction history.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _showStartSessionDialog(context, ref, 1),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Start New Session'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final isClosed = selectedSession.status.toUpperCase() == 'CLOSED';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Session name row ─────────────────────────────────────
                  Row(
                    children: [
                      Icon(
                        isClosed ? Icons.lock_clock_rounded : Icons.play_circle_outline_rounded,
                        color: isClosed ? Colors.redAccent : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedSession.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      // Rename button (available for all sessions)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        tooltip: 'Rename session',
                        color: AppColors.onSurfaceVariant,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _showRenameSessionDialog(context, ref, selectedSession),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isClosed ? Colors.redAccent : Colors.green).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isClosed ? 'CLOSED' : 'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isClosed ? Colors.redAccent : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Started: ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(selectedSession.startDateMs))}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (selectedSession.endDateMs != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ended: ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(selectedSession.endDateMs!))}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Divider(height: 24, thickness: 1, color: AppColors.surfaceContainerHigh),
                  // ── Balances ─────────────────────────────────────────────
                  Builder(builder: (context) {
                    final isActive = !isClosed;
                    // Show a mini spinner instead of ₱0.00 during the first stream
                    // emission so users never see a misleading zero-balance flash.
                    final isLoadingBalances = isActive && selectedBalancesAsync.isLoading;
                    final balances = selectedBalancesAsync.value;
                    final gcash = (isActive && balances != null) ? balances.gcash : selectedSession.startGcash;
                    final maya  = (isActive && balances != null) ? balances.maya  : selectedSession.startMaya;
                    final onHand = (isActive && balances != null) ? balances.onHand : selectedSession.startOnHand;
                    final label = isActive ? 'CURRENT BALANCES' : 'STARTING BALANCES';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isLoadingBalances)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          _buildBalanceRow('GCash Wallet', gcash, currencyFormat, AppColors.primary, isDark),
                          const SizedBox(height: 6),
                          _buildBalanceRow('Maya Wallet', maya, currencyFormat, AppColors.secondary, isDark),
                          const SizedBox(height: 6),
                          _buildBalanceRow('On-hand Cash', onHand, currencyFormat, AppColors.onHand, isDark),
                        ],
                      ],
                    );
                  }),
                  if (isClosed) ...[
                    const Divider(height: 24, thickness: 1, color: AppColors.surfaceContainerHigh),
                    const Text(
                      'ENDING BALANCES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBalanceRow('GCash Wallet', selectedSession.endGcash ?? 0.0, currencyFormat, AppColors.primary, isDark),
                    const SizedBox(height: 6),
                    _buildBalanceRow('Maya Wallet', selectedSession.endMaya ?? 0.0, currencyFormat, AppColors.secondary, isDark),
                    const SizedBox(height: 6),
                    _buildBalanceRow('On-hand Cash', selectedSession.endOnHand ?? 0.0, currencyFormat, AppColors.onHand, isDark),
                  ],
                  const SizedBox(height: 18),
                  // ── Action buttons ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showSwitchSessionDialog(context, ref),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                          label: const Text('Switch Session', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isClosed)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              final container = ProviderScope.containerOf(context);
                              await container.read(selectedSessionProvider.notifier).resetToActive();
                            },
                            icon: const Icon(Icons.flash_on_rounded, size: 16),
                            label: const Text('Go Live', style: TextStyle(fontSize: 12)),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _showStartSessionDialog(
                              context, ref,
                              (sessionsAsync.value?.length ?? 0) + 1,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('New Session', style: TextStyle(fontSize: 12)),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, s) {
        final errorStr = e.toString();
        final isMigrationError = errorStr.contains('no such table: monitoring_sessions');
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isMigrationError ? 'Full Restart Required' : 'Error Loading Sessions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isMigrationError
                        ? 'A database update is required. Please stop the application and run it again (Full Restart) to apply database changes.'
                        : 'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Section header with info icon ─────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'MONITORING SESSIONS',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showSessionInfoSheet(context),
          child: const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ── Info bottom sheet (Fix 1) ─────────────────────────────────────────────

  void _showSessionInfoSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.track_changes_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'What is a Monitoring Session?',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'A monitoring session is like a reporting period — similar to a business "cut-off" or "cycle." It lets you compare your wallet balances and transaction activity between different periods of time.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildInfoPoint(Icons.play_circle_outline_rounded, Colors.green,
              'Active Session',
              'Your current period. All new transactions are tracked here. Dashboard shows only this period\'s activity.',
            ),
            const SizedBox(height: 12),
            _buildInfoPoint(Icons.lock_clock_rounded, Colors.orange,
              'Closed Session',
              'A past period you can browse in read-only mode. Your wallet balances from that period are safely preserved.',
            ),
            const SizedBox(height: 12),
            _buildInfoPoint(Icons.add_circle_outline_rounded, AppColors.primary,
              'New Session',
              'Start a fresh reporting period. Your starting balances reset to zero to track only new activity. Nothing is deleted — old data is archived.',
            ),
            const SizedBox(height: 12),
            _buildInfoPoint(Icons.history_rounded, AppColors.onSurfaceVariant,
              'All Sessions (All Time)',
              'Combine every session into one view to see your complete business history at a glance.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(IconData icon, Color color, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: 2),
              Text(body, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Balance row helper ────────────────────────────────────────────────────

  Widget _buildBalanceRow(String label, double amount, NumberFormat format, Color indicatorColor, bool isDark) {
    Color adaptiveColor = indicatorColor;
    if (isDark) {
      if (indicatorColor == AppColors.primary) {
        adaptiveColor = const Color(0xFF60A5FA);
      } else if (indicatorColor == AppColors.secondary) {
        adaptiveColor = const Color(0xFF34D399);
      } else if (indicatorColor == AppColors.onHand) {
        adaptiveColor = const Color(0xFFFBBF24);
      }
    }
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: adaptiveColor),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          format.format(amount),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
      ],
    );
  }

  // ── Switch Session dialog (Fix 8 — rich metrics, Fix 3 — All Time option) ─

  void _showSwitchSessionDialog(BuildContext context, WidgetRef screenRef) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    showDialog(
      context: context,
      builder: (dialogCtx) => Consumer(
        builder: (dialogConsumerCtx, dialogRef, _) {
          final sessionsAsync = dialogRef.watch(monitoringSessionsStreamProvider);
          final selectedSessionAsync = dialogRef.watch(selectedSessionProvider);

          return sessionsAsync.when(
            data: (sessions) {
              final selectedSession = selectedSessionAsync.value;
              return AlertDialog(
                backgroundColor: dialogBg,
                title: const Text('Select Monitoring Session', style: TextStyle(fontWeight: FontWeight.bold)),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sessions.length + 1, // +1 for the "All Time" option
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      // ── All Time option (index 0) ─────────────────────────────────
                      if (index == 0) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
                          ),
                          title: const Text(
                            'All Sessions (All Time)',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14),
                          ),
                          subtitle: const Text(
                            'Combined view of every session — no time filter',
                            style: TextStyle(fontSize: 11),
                          ),
                          trailing: Consumer(
                            builder: (_, r, _) {
                              final isAllTime = r.watch(allTimeViewProvider);
                              return isAllTime
                                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18)
                                  : const SizedBox.shrink();
                            },
                          ),
                          onTap: () {
                            ProviderScope.containerOf(context).read(allTimeViewProvider.notifier).state = true;
                            if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                          },
                        );
                      }

                      // ── Specific session tile ─────────────────────────────────────
                      final session = sessions[index - 1];
                      final isClosed = session.status.toUpperCase() == 'CLOSED';
                      final isCurrentlySelected = selectedSession?.id == session.id;

                      final summaryAsync = dialogRef.watch(sessionSummaryProvider(session.id));
                      final started = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(session.startDateMs));
                      final ended = session.endDateMs != null
                          ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(session.endDateMs!))
                          : 'Ongoing';

                      final subtitleStr = summaryAsync.when(
                        data: (s) {
                          final sign = s.netChange >= 0 ? '+' : '';
                          return '$started → $ended\n${s.txCount} entries • Net $sign${currencyFmt.format(s.netChange)}';
                        },
                        loading: () => '$started → $ended\nLoading summary…',
                        error: (_, _) => '$started → $ended',
                      );

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        title: Text(
                          session.name,
                          style: TextStyle(
                            fontWeight: isCurrentlySelected ? FontWeight.bold : FontWeight.w500,
                            color: isCurrentlySelected ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          subtitleStr,
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isClosed ? Colors.redAccent : Colors.green).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isClosed ? 'CLOSED' : 'ACTIVE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isClosed ? Colors.redAccent : Colors.green,
                                ),
                              ),
                            ),
                            // Options menu (rename / delete)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.onSurfaceVariant),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'rename', child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 16),
                                    SizedBox(width: 8),
                                    Text('Rename', style: TextStyle(fontSize: 13)),
                                  ],
                                )),
                                if (isClosed)
                                  const PopupMenuItem(value: 'delete', child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                                    ],
                                  )),
                              ],
                              onSelected: (action) async {
                                if (action == 'rename') {
                                  if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                                  await _showRenameSessionDialog(context, screenRef, session);
                                } else if (action == 'delete') {
                                  if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                                  await _confirmDeleteSession(context, screenRef, session);
                                }
                              },
                            ),
                            if (isCurrentlySelected) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                            ],
                          ],
                        ),
                        onTap: () async {
                          // Selecting a specific session clears the All-Time view.
                          final container = ProviderScope.containerOf(context);
                          container.read(allTimeViewProvider.notifier).state = false;
                          await container.read(selectedSessionProvider.notifier).selectSession(session);
                          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text('CLOSE'),
                  ),
                ],
              );
            },
            loading: () => AlertDialog(
              backgroundColor: dialogBg,
              content: const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),
            error: (err, _) => AlertDialog(
              backgroundColor: dialogBg,
              content: Text('Error loading sessions: $err'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── New Session dialog (Fix 2 — reassurance + checkbox) ───────────────────

  Future<void> _showStartSessionDialog(
    BuildContext context,
    WidgetRef ref,
    int nextSessionNumber,
  ) async {
    final container = ProviderScope.containerOf(context);
    // Fetch current session summary before showing the dialog.
    final activeSession = container.read(selectedSessionProvider).value;
    int txCount = 0;
    if (activeSession != null) {
      try {
        final summary = await container.read(sessionSummaryProvider(activeSession.id).future);
        txCount = summary.txCount;
      } catch (_) {}
    }
    if (!context.mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
    final currencyFmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
    final controller = TextEditingController(text: 'Cycle #$nextSessionNumber');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool confirmed = false;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Start New Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Current state summary card ────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Your data is safe — nothing is deleted',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$txCount transaction${txCount == 1 ? '' : 's'} will be archived in "${activeSession?.name ?? 'Current Session'}".',
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Your starting balances will reset to zero:',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          _buildMiniBalance('GCash', 0.0, currencyFmt),
                          _buildMiniBalance('Maya', 0.0, currencyFmt),
                          _buildMiniBalance('On-hand', 0.0, currencyFmt),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ── What happens next ─────────────────────────────────────
                    const Text(
                      'What will happen:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 6),
                    _buildWhatHappensBullet('Current session is closed and archived'),
                    _buildWhatHappensBullet('Dashboard resets to show only new activity'),
                    _buildWhatHappensBullet('Old sessions remain accessible via Switch Session'),
                    const SizedBox(height: 14),
                    // ── Name input ────────────────────────────────────────────
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'New Session Name',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.label_outline_rounded),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ── Confirmation checkbox ─────────────────────────────────
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => confirmed = !confirmed),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: confirmed,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => confirmed = v ?? false),
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'I understand the Dashboard will reset to zero and show only new activity. I can view old data via Switch Session.',
                                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  // Disabled until the checkbox is ticked.
                  onPressed: confirmed
                      ? () async {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          Navigator.of(dialogCtx).pop();

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );

                          await container.read(selectedSessionProvider.notifier).startNewSession(name);

                          if (context.mounted) {
                            Navigator.of(context).pop(); // dismiss spinner
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Session "$name" started! Your previous data is safely archived.'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: const Text('START SESSION'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMiniBalance(String label, double amount, NumberFormat fmt) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          Text(fmt.format(amount), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildWhatHappensBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  // ── Rename dialog (Fix 6, Fix 10) ─────────────────────────────────────────

  Future<void> _showRenameSessionDialog(
    BuildContext context,
    WidgetRef ref,
    MonitoringSessionRow session,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
    final controller = TextEditingController(text: session.name);

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogBg,
        title: const Text('Rename Session', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Session Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty || name == session.name) {
                Navigator.of(dialogCtx).pop();
                return;
              }
              Navigator.of(dialogCtx).pop();
              final container = ProviderScope.containerOf(context);
              await container.read(selectedSessionProvider.notifier).renameSession(session.id, name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Renamed to "$name"'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation (Fix 6) ───────────────────────────────────────────

  Future<void> _confirmDeleteSession(
    BuildContext context,
    WidgetRef ref,
    MonitoringSessionRow session,
  ) async {
    debugPrint('[DeleteUI] User triggered delete for session: id=${session.id}, syncId=${session.syncId}, name="${session.name}", status=${session.status}, isDeleted=${session.isDeleted}, isDirty=${session.isDirty}');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogBg,
        title: const Text('Delete Session?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'This will permanently delete "${session.name}" and all its metadata.\n\n'
          'Your wallet transactions are NOT deleted — only the session record itself.',
          style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    debugPrint('[DeleteUI] Dialog confirmed: $confirmed');
    if (confirmed == true && context.mounted) {
      final container = ProviderScope.containerOf(context);
      final deleteError = await container.read(selectedSessionProvider.notifier).deleteClosedSession(session.id);
      debugPrint('[DeleteUI] deleteClosedSession result error message: $deleteError');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deleteError == null ? '"${session.name}" deleted.' : 'Failed to delete: $deleteError'),
            backgroundColor: deleteError == null ? Colors.green : Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context);

    // Reset ephemeral UI state so a subsequent login always starts from the
    // active session, not a stale All-Time view from the previous user.
    container.read(allTimeViewProvider.notifier).state = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    int pending = 0;
    try {
      pending = await container.read(syncEngineProvider).getPendingPushCount();
    } catch (_) {
      // Ignored
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading indicator
      }
    }

    if (pending == 0) {
      await container.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Unsynced Changes'),
        content: Text(
          'You have $pending offline changes that are not synced to the cloud. '
          'Logging out now will permanently delete these changes. What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await container.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('LOG OUT ANYWAY'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(width: 20),
                      Text('Syncing changes...'),
                    ],
                  ),
                ),
              );

              bool syncSuccess = false;
              try {
                final results = await container.read(syncEngineProvider).runOnce();
                syncSuccess = results.every((r) => r.error == null);
              } catch (_) {
                syncSuccess = false;
              } finally {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }

              if (syncSuccess) {
                int remaining = 0;
                try {
                  remaining = await container.read(syncEngineProvider).getPendingPushCount();
                } catch (_) {}

                if (remaining == 0) {
                  await container.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  return;
                }
              }

              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Sync failed. Please check your connection and try again.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('SYNC & LOG OUT'),
          ),
        ],
      ),
    );
  }
}
