import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/sync/sync_config.dart';
import 'sale_model.dart';

class CheckoutRequest {
  final List<TtCartItem> items;
  final double paidAmount;
  final String? note;
  final String? deviceId;

  const CheckoutRequest({
    required this.items,
    required this.paidAmount,
    this.note,
    this.deviceId,
  });
}

class PosRepository {
  PosRepository._();
  static final PosRepository instance = PosRepository._();

  static const _uuid = Uuid();
  static const _timeout = Duration(seconds: 15);
  final _db = AppDatabase.instance;

  // ─── helpers ──────────────────────────────────────────────────────────────

  String _generateReference() {
    final now = DateTime.now();
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'TXN-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$rand';
  }

  Future<TtSale> _buildSale(Map<String, Object?> row) async {
    final db = await _db.database;
    final saleSyncId = row['sync_id'] as String;
    final itemRows = await db.query(
      AppDatabase.ttSaleItemsTable,
      where: 'sale_sync_id = ?',
      whereArgs: [saleSyncId],
    );
    final items = itemRows.map(TtSaleItem.fromLocalDb).toList();
    return TtSale.fromLocalDb(row, items);
  }

  // ─── public API ───────────────────────────────────────────────────────────

  Future<TtSale> checkout(CheckoutRequest request) async {
    final db = await _db.database;
    final deviceId = request.deviceId ?? await _db.getOrCreateDeviceId();
    final now = DateTime.now().toIso8601String();
    final saleSyncId = _uuid.v4();
    final reference = _generateReference();

    double subtotal = 0;
    int totalItems = 0;
    final enrichedItems = <Map<String, Object?>>[];

    for (final item in request.items) {
      // Look up the product row to get sync_id / server_id
      final productRows = await db.query(
        AppDatabase.ttProductsTable,
        where: 'server_id = ? OR sync_id = ?',
        whereArgs: [item.productId, item.productId],
        limit: 1,
      );
      if (productRows.isEmpty) {
        throw Exception('Product not found: ${item.productId}');
      }
      final pRow = productRows.first;
      final pSyncId = pRow['sync_id'] as String;
      final pServerId = pRow['server_id'] as String?;
      final lineTotal = item.unitPrice * item.quantity;
      subtotal += lineTotal;
      totalItems += item.quantity;

      enrichedItems.add({
        'sale_sync_id': saleSyncId,
        'product_sync_id': pSyncId,
        'product_server_id': pServerId,
        'product_name': item.productName,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'line_total': lineTotal,
      });

      // Deduct stock locally
      final currentStock = pRow['stock_quantity'] as int;
      await db.update(
        AppDatabase.ttProductsTable,
        {
          'stock_quantity': max(0, currentStock - item.quantity),
          'is_dirty': 1,
          'updated_at': now,
        },
        where: 'sync_id = ?',
        whereArgs: [pSyncId],
      );
    }

    final totalAmount = subtotal;
    final changeAmount = request.paidAmount - totalAmount;

    await db.insert(AppDatabase.ttSalesTable, {
      'sync_id': saleSyncId,
      'server_id': null,
      'device_id': deviceId,
      'reference': reference,
      'note': request.note ?? '',
      'subtotal': subtotal,
      'total_amount': totalAmount,
      'paid_amount': request.paidAmount,
      'change_amount': changeAmount,
      'total_items': totalItems,
      'is_dirty': 1,
      'created_at': now,
    });

    for (final item in enrichedItems) {
      await db.insert(AppDatabase.ttSaleItemsTable, item);
    }

    final saleRows = await db.query(
      AppDatabase.ttSalesTable,
      where: 'sync_id = ?',
      whereArgs: [saleSyncId],
      limit: 1,
    );
    final sale = await _buildSale(saleRows.first);
    unawaited(_pushCheckout(saleSyncId));
    return sale;
  }

  Future<List<TtSale>> listSales({int? limit, String? from, String? to}) async {
    final db = await _db.database;
    var rows = await db.query(
      AppDatabase.ttSalesTable,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    if (from != null) {
      final fromDt = DateTime.parse(from);
      rows = rows
          .where(
            (r) => DateTime.parse(r['created_at'] as String).isAfter(fromDt),
          )
          .toList();
    }
    if (to != null) {
      final toDt = DateTime.parse(to);
      rows = rows
          .where(
            (r) => DateTime.parse(r['created_at'] as String).isBefore(toDt),
          )
          .toList();
    }
    return Future.wait(rows.map(_buildSale));
  }

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await ApiClient.instance.get('/pos/dashboard');
      return DashboardStats.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (_) {
      return _localDashboardStats();
    }
  }

  Future<DashboardStats> _localDashboardStats() async {
    final db = await _db.database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final salesRows = await db.query(AppDatabase.ttSalesTable);
    final todaySales = salesRows
        .where(
          (r) => DateTime.parse(r['created_at'] as String).isAfter(todayStart),
        )
        .toList();

    final totalSales = todaySales.fold<double>(
      0,
      (s, r) => s + (r['total_amount'] as num).toDouble(),
    );
    final transactions = todaySales.length;

    final productRows = await db.query(
      AppDatabase.ttProductsTable,
      where: 'is_deleted = 0 AND is_active = 1',
    );
    final lowStock = productRows
        .where(
          (r) =>
              (r['stock_quantity'] as int) <= (r['reorder_point'] as int) &&
              (r['stock_quantity'] as int) > 0,
        )
        .map(
          (r) => LowStockProduct(
            id: (r['server_id'] as String?) ?? r['sync_id'] as String,
            name: r['name'] as String,
            stockQuantity: r['stock_quantity'] as int,
            reorderPoint: r['reorder_point'] as int,
          ),
        )
        .toList();

    final customerRows = await db.query(
      AppDatabase.ttCustomersTable,
      where: 'is_deleted = 0',
    );
    final totalUtang = customerRows.fold<double>(
      0,
      (s, r) => s + (r['balance'] as num).toDouble(),
    );

    return DashboardStats(
      today: TodayStats(
        totalSales: totalSales,
        profit: 0,
        transactions: transactions,
      ),
      lowStockProducts: lowStock,
      totalOutstandingUtang: totalUtang,
      topProductsThisWeek: [],
    );
  }

  Future<ReportsData> getReports({String? from, String? to}) async {
    try {
      final params = <String, dynamic>{};
      if (from != null) params['from'] = from;
      if (to != null) params['to'] = to;
      final response = await ApiClient.instance.get(
        '/pos/reports',
        params: params,
      );
      return ReportsData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (_) {
      return ReportsData(
        summary: ReportSummary(
          totalSales: 0,
          totalProfit: 0,
          totalTransactions: 0,
        ),
        daily: [],
        topProducts: [],
      );
    }
  }

  // ─── background push ──────────────────────────────────────────────────────

  Future<void> _pushCheckout(String saleSyncId) async {
    try {
      final db = await _db.database;
      final saleRows = await db.query(
        AppDatabase.ttSalesTable,
        where: 'sync_id = ?',
        whereArgs: [saleSyncId],
        limit: 1,
      );
      if (saleRows.isEmpty) return;
      final sale = saleRows.first;

      final itemRows = await db.query(
        AppDatabase.ttSaleItemsTable,
        where: 'sale_sync_id = ?',
        whereArgs: [saleSyncId],
      );

      // Refresh product_server_id in case products were pushed concurrently
      for (final item in itemRows) {
        if (item['product_server_id'] != null) continue;
        final pSyncId = item['product_sync_id'] as String;
        final pRows = await db.query(
          AppDatabase.ttProductsTable,
          where: 'sync_id = ?',
          whereArgs: [pSyncId],
          limit: 1,
        );
        if (pRows.isNotEmpty && pRows.first['server_id'] != null) {
          await db.update(
            AppDatabase.ttSaleItemsTable,
            {'product_server_id': pRows.first['server_id']},
            where: 'sale_sync_id = ? AND product_sync_id = ?',
            whereArgs: [saleSyncId, pSyncId],
          );
        }
      }

      // Re-query after refresh
      final refreshedItems = await db.query(
        AppDatabase.ttSaleItemsTable,
        where: 'sale_sync_id = ?',
        whereArgs: [saleSyncId],
      );

      // Only push if all products have server_ids (else SyncService will retry)
      final allHaveServerIds = refreshedItems.every(
        (r) => r['product_server_id'] != null,
      );
      if (!allHaveServerIds) return;

      final baseUrl = await SyncConfig.getBaseApiUrl();
      final res = await http
          .post(
            Uri.parse('$baseUrl/pos/checkout'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'reference': sale['reference'],
              'paidAmount': sale['paid_amount'],
              if ((sale['note'] as String).isNotEmpty) 'note': sale['note'],
              'deviceId': sale['device_id'],
              'items': refreshedItems
                  .map(
                    (r) => {
                      'productId': r['product_server_id'],
                      'quantity': r['quantity'],
                    },
                  )
                  .toList(),
            }),
          )
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        await db.update(
          AppDatabase.ttSalesTable,
          {'server_id': data['id'] as String, 'is_dirty': 0},
          where: 'sync_id = ?',
          whereArgs: [saleSyncId],
        );
      }
    } catch (_) {}
  }
}

class TodayStats {
  final double totalSales;
  final double profit;
  final int transactions;

  const TodayStats({
    required this.totalSales,
    required this.profit,
    required this.transactions,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      totalSales: (json['totalSales'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      transactions: json['transactions'] as int,
    );
  }
}

class LowStockProduct {
  final String id;
  final String name;
  final int stockQuantity;
  final int reorderPoint;

  const LowStockProduct({
    required this.id,
    required this.name,
    required this.stockQuantity,
    required this.reorderPoint,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      stockQuantity: json['stockQuantity'] as int,
      reorderPoint: json['reorderPoint'] as int,
    );
  }
}

class TopProduct {
  final String productId;
  final String name;
  final int qty;
  final double revenue;

  const TopProduct({
    required this.productId,
    required this.name,
    required this.qty,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'] as String,
      name: json['name'] as String,
      qty: json['qty'] as int,
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}

class DashboardStats {
  final TodayStats today;
  final List<LowStockProduct> lowStockProducts;
  final double totalOutstandingUtang;
  final List<TopProduct> topProductsThisWeek;

  const DashboardStats({
    required this.today,
    required this.lowStockProducts,
    required this.totalOutstandingUtang,
    required this.topProductsThisWeek,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      today: TodayStats.fromJson(json['today'] as Map<String, dynamic>),
      lowStockProducts: (json['lowStockProducts'] as List)
          .map((e) => LowStockProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalOutstandingUtang: (json['totalOutstandingUtang'] as num).toDouble(),
      topProductsThisWeek: (json['topProductsThisWeek'] as List)
          .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyStats {
  final String date;
  final double sales;
  final double profit;
  final int transactions;

  const DailyStats({
    required this.date,
    required this.sales,
    required this.profit,
    required this.transactions,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] as String,
      sales: (json['sales'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      transactions: json['transactions'] as int,
    );
  }
}

class ReportSummary {
  final double totalSales;
  final double totalProfit;
  final int totalTransactions;

  const ReportSummary({
    required this.totalSales,
    required this.totalProfit,
    required this.totalTransactions,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalSales: (json['totalSales'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
      totalTransactions: json['totalTransactions'] as int,
    );
  }
}

class ReportsData {
  final ReportSummary summary;
  final List<DailyStats> daily;
  final List<TopProduct> topProducts;

  const ReportsData({
    required this.summary,
    required this.daily,
    required this.topProducts,
  });

  factory ReportsData.fromJson(Map<String, dynamic> json) {
    return ReportsData(
      summary: ReportSummary.fromJson(json['summary'] as Map<String, dynamic>),
      daily: (json['daily'] as List)
          .map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      topProducts: (json['topProducts'] as List)
          .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
