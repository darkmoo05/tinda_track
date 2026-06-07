import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme.dart';
import '../../inventory/providers/inventory_providers.dart';
import '../../pos/data/pos_repository.dart';

class TtDashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback? onGoToSell;
  final VoidCallback? onGoToInventory;

  const TtDashboardScreen({super.key, this.onGoToSell, this.onGoToInventory});

  @override
  ConsumerState<TtDashboardScreen> createState() => _TtDashboardScreenState();
}

class _TtDashboardScreenState extends ConsumerState<TtDashboardScreen> {
  late Future<DashboardStats> _statsFuture;
  
  String get _currencySymbol => ref.watch(businessProfileProvider).value?.defaultCurrency == 'USD' ? r'$' : '₱';
  NumberFormat get _currency => NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);
  NumberFormat get _compact => NumberFormat.compactCurrency(symbol: _currencySymbol, decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _statsFuture = ref.read(posRepositoryProvider).getDashboardStats();
  }

  void _refresh() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: () async => _refresh(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: const Text(
              'TindaTracker',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _refresh,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<DashboardStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }
                final stats = snapshot.data!;
                return _buildBody(stats);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load dashboard',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DashboardStats stats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    ref.watch(businessProfileProvider).value?.businessName ?? 'My Store',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: "Today's Sales",
                  value: _compact.format(stats.today.totalSales),
                  icon: Icons.point_of_sale_rounded,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Profit',
                  value: _compact.format(stats.today.profit),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Transactions',
                  value: stats.today.transactions.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Total Utang',
                  value: _compact.format(stats.totalOutstandingUtang),
                  icon: Icons.people_rounded,
                  color: const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.shopping_cart_rounded,
                  label: 'New Sale',
                  color: AppColors.secondary,
                  onTap: widget.onGoToSell,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add_box_rounded,
                  label: 'Add Stock',
                  color: const Color(0xFF1565C0),
                  onTap: widget.onGoToInventory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Low stock alerts
          if (stats.lowStockProducts.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...stats.lowStockProducts.map((p) => _LowStockCard(product: p)),
            const SizedBox(height: 24),
          ],

          // Top 5 sellers this week
          if (stats.topProductsThisWeek.isNotEmpty) ...[
            const Text(
              'Top Sellers This Week',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ...stats.topProductsThisWeek.asMap().entries.map(
              (entry) => _TopProductRow(
                rank: entry.key + 1,
                product: entry.value,
                currency: _currency,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest;
    final textVarColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;
    Color adaptiveColor = color;
    if (isDark) {
      if (color == AppColors.secondary) {
        adaptiveColor = const Color(0xFF34D399);
      } else if (color == const Color(0xFF1565C0)) {
        adaptiveColor = const Color(0xFF60A5FA);
      } else if (color == const Color(0xFF6A1B9A)) {
        adaptiveColor = const Color(0xFFC084FC);
      } else if (color == const Color(0xFFC62828)) {
        adaptiveColor = const Color(0xFFF87171);
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: adaptiveColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: adaptiveColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: adaptiveColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textVarColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  final LowStockProduct product;

  const _LowStockCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${product.stockQuantity} left',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final int rank;
  final TopProduct product;
  final NumberFormat currency;

  const _TopProductRow({
    required this.rank,
    required this.product,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1
                  ? const Color(0xFFFFC107)
                  : rank == 2
                  ? const Color(0xFFB0BEC5)
                  : rank == 3
                  ? const Color(0xFFBE8A60)
                  : (isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainerHigh),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? Colors.white : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '${product.qty} sold',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currency.format(product.revenue),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
