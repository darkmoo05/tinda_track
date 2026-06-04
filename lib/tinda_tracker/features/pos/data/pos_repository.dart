import 'dart:math';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/app_meta_dao.dart';
import '../../../../core/di/database_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../inventory/data/models/inventory_product.dart';
import 'models/cart_item.dart';
import 'sale_model.dart';

/// Riverpod provider that hands out a singleton [PosRepository] bound to the
/// app's Drift database. Consumers should obtain the repo via
/// `ref.read(posRepositoryProvider)` rather than instantiating it directly.
final posRepositoryProvider = Provider<PosRepository>((ref) {
  return PosRepository(database: ref.watch(currentAppDatabaseProvider));
});

class CheckoutRequest {
  final List<CartItem> items;
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

/// POS-domain service. Owns sale checkout, barcode lookup, and aggregate
/// reporting against the local Drift database.
class PosRepository {
  PosRepository({required AppDatabase database})
    : _database = database,
      _appMeta = AppMetaDao(database);

  final AppDatabase _database;
  final AppMetaDao _appMeta;
  static const _uuid = Uuid();

  // ───── SQL helpers ─────────────────────────────────────────────────────────

  /// `created_at_ms` (int) projected as an ISO-8601 string so legacy
  /// `*.fromLocalDb` factories keep working unchanged after the Drift cutover.
  static const String _createdAtAlias =
      "strftime('%Y-%m-%dT%H:%M:%fZ', created_at_ms / 1000.0, 'unixepoch') "
      "AS created_at";

  static const String _updatedAtAlias =
      "strftime('%Y-%m-%dT%H:%M:%fZ', updated_at_ms / 1000.0, 'unixepoch') "
      "AS updated_at";

  static const String _expirationDateAlias =
      "CASE WHEN expiration_date_ms IS NULL THEN NULL ELSE "
      "strftime('%Y-%m-%dT%H:%M:%fZ', expiration_date_ms / 1000.0, "
      "'unixepoch') END AS expiration_date";

  /// Column list that translates the new `products` schema back to the legacy
  /// shape consumed by [InventoryProduct.fromLocalDb].
  static const String _productProjection =
      'id AS sync_id, id AS server_id, name, sku, description, category, '
      'base_unit, cost_price, selling_price, stock_in_base_unit, '
      'reorder_point, is_active, is_deleted, image_url, '
      'image_local_path AS image_path, shelf_location, '
      "$_expirationDateAlias, $_createdAtAlias, $_updatedAtAlias";

  static const String _saleProjection =
      'id AS sync_id, id AS server_id, reference, note, subtotal, '
      'total_amount, paid_amount, change_amount, total_items, '
      "$_createdAtAlias";

  Future<List<Map<String, Object?>>> _selectRows(
    String sql, {
    List<Variable> variables = const [],
  }) async {
    final result = await _database
        .customSelect(sql, variables: variables)
        .get();
    return result
        .map((row) => Map<String, Object?>.from(row.data))
        .toList(growable: false);
  }

  // ───── helpers ─────────────────────────────────────────────────────────────

  String _generateReference() {
    final now = DateTime.now();
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'TXN-${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-$rand';
  }

  Future<TtSale> _buildSale(Map<String, Object?> saleRow) async {
    final saleId = saleRow['sync_id'] as String;
    final itemRows = await _selectRows(
      'SELECT si.*, si.sale_id AS sale_sync_id, '
      'si.product_id AS product_sync_id, NULL AS product_server_id, '
      "p.name AS product_name "
      'FROM sale_items si '
      'LEFT JOIN products p ON p.id = si.product_id '
      'WHERE si.sale_id = ?',
      variables: [Variable<String>(saleId)],
    );
    final items = itemRows.map(TtSaleItem.fromLocalDb).toList();
    return TtSale.fromLocalDb(saleRow, items);
  }

  String _normalizeBarcode(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').trim();
  }

  String _stripLeadingZeros(String value) {
    final stripped = value.replaceFirst(RegExp(r'^0+'), '');
    return stripped.isEmpty ? '0' : stripped;
  }

  bool _isBarcodeMatch(String sku, String scanned) {
    if (sku == scanned) return true;
    return _stripLeadingZeros(sku) == _stripLeadingZeros(scanned);
  }

  // ───── public API ──────────────────────────────────────────────────────────

  Future<InventoryProduct?> findProductBySku(String scannedCode) async {
    final normalizedInput = _normalizeBarcode(scannedCode);
    if (normalizedInput.isEmpty) return null;

    final rows = await _selectRows(
      'SELECT $_productProjection FROM products '
      'WHERE COALESCE(is_deleted, 0) = 0 AND COALESCE(is_active, 1) = 1 '
      'ORDER BY name ASC',
    );

    for (final row in rows) {
      final product = InventoryProduct.fromLocalDb(row);
      final productSku = _normalizeBarcode(product.sku);
      if (productSku.isEmpty) continue;
      if (_isBarcodeMatch(productSku, normalizedInput)) {
        return product;
      }
    }
    return null;
  }

  Future<TtSale> checkout(CheckoutRequest request) async {
    if (request.items.isEmpty) {
      throw Exception(
        'Walang item sa checkout queue. Mag-add muna bago mag-checkout.',
      );
    }
    if (request.paidAmount < 0) {
      throw Exception('Hindi puwedeng negative ang amount received.');
    }

    final deviceId = request.deviceId ?? await _appMeta.getOrCreateDeviceId();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final saleId = _uuid.v4();
    final reference = _generateReference();

    double subtotal = 0;
    final totalItems = request.items.length;
    final enrichedItems = <_EnrichedSaleItem>[];

    await _database.transaction(() async {
      for (final item in request.items) {
        // Look up product row by canonical id.
        final productRows = await _selectRows(
          'SELECT id, name, base_unit, stock_in_base_unit '
          'FROM products WHERE id = ? LIMIT 1',
          variables: [Variable<String>(item.product.id)],
        );
        if (productRows.isEmpty) {
          throw Exception('Product not found: ${item.product.name}');
        }
        final pRow = productRows.first;
        final productId = pRow['id'] as String;
        final baseUnit = (pRow['base_unit'] as String?) ?? 'pc';
        final selectedUnit = item.selectedUnitName;

        double conversionFactor = 1;
        if (selectedUnit.toLowerCase() != baseUnit.toLowerCase()) {
          final conversionRows = await _selectRows(
            'SELECT conversion_factor FROM product_unit_conversions '
            'WHERE product_id = ? AND LOWER(unit_name) = LOWER(?) '
            'AND COALESCE(is_deleted, 0) = 0 LIMIT 1',
            variables: [
              Variable<String>(productId),
              Variable<String>(selectedUnit),
            ],
          );
          if (conversionRows.isEmpty) {
            throw Exception(
              'Hindi naka-set ang unit na $selectedUnit para sa '
              '${item.product.name}.',
            );
          }
          conversionFactor = (conversionRows.first['conversion_factor'] as num)
              .toDouble();
        }

        final computedBaseQuantity = item.quantity * conversionFactor;
        final currentBaseStock =
            (pRow['stock_in_base_unit'] as num?)?.toDouble() ?? 0;
        if (computedBaseQuantity > currentBaseStock) {
          throw Exception('Kulang ang stocks para sa ${item.product.name}.');
        }

        final lineTotal = item.appliedPrice * item.quantity;
        subtotal += lineTotal;

        enrichedItems.add(
          _EnrichedSaleItem(
            productId: productId,
            selectedUnit: selectedUnit,
            quantity: item.quantity,
            unitPrice: item.appliedPrice,
            computedBaseQuantity: computedBaseQuantity,
            lineTotal: lineTotal,
          ),
        );

        final newBaseStock = currentBaseStock - computedBaseQuantity;
        await _database.customStatement(
          'UPDATE products SET stock_in_base_unit = ?, is_dirty = 1, '
          'updated_at_ms = ? WHERE id = ?',
          [newBaseStock, nowMs, productId],
        );
      }

      final totalAmount = subtotal;
      if (request.paidAmount < totalAmount) {
        throw Exception(
          'Kulangan ang binayad. Paki-check ulit bago mag-checkout.',
        );
      }
      final changeAmount = request.paidAmount - totalAmount;

      await _database.customStatement(
        'INSERT INTO sales ('
        'id, reference, note, subtotal, total_amount, paid_amount, '
        'change_amount, total_items, '
        'sync_id, device_id, is_deleted, is_dirty, '
        'created_at_ms, updated_at_ms'
        ') VALUES (?,?,?,?,?,?,?,?,?,?,0,1,?,?)',
        [
          saleId,
          reference,
          request.note ?? '',
          subtotal,
          totalAmount,
          request.paidAmount,
          changeAmount,
          totalItems,
          saleId,
          deviceId,
          nowMs,
          nowMs,
        ],
      );

      for (final item in enrichedItems) {
        await _database.customStatement(
          'INSERT INTO sale_items ('
          'id, sale_id, product_id, selected_unit, quantity, unit_price, '
          'computed_base_quantity, line_total, created_at_ms, is_dirty'
          ') VALUES (?,?,?,?,?,?,?,?,?,1)',
          [
            _uuid.v4(),
            saleId,
            item.productId,
            item.selectedUnit,
            item.quantity,
            item.unitPrice,
            item.computedBaseQuantity,
            item.lineTotal,
            nowMs,
          ],
        );
      }
    });

    final saleRows = await _selectRows(
      'SELECT $_saleProjection FROM sales WHERE id = ? LIMIT 1',
      variables: [Variable<String>(saleId)],
    );
    return _buildSale(saleRows.first);
  }

  Future<List<TtSale>> listSales({int? limit, String? from, String? to}) async {
    final whereClauses = <String>['COALESCE(is_deleted, 0) = 0'];
    final variables = <Variable>[];
    if (from != null) {
      whereClauses.add('created_at_ms > ?');
      variables.add(Variable<int>(DateTime.parse(from).millisecondsSinceEpoch));
    }
    if (to != null) {
      whereClauses.add('created_at_ms < ?');
      variables.add(Variable<int>(DateTime.parse(to).millisecondsSinceEpoch));
    }
    final limitClause = limit == null ? '' : ' LIMIT $limit';
    final rows = await _selectRows(
      'SELECT $_saleProjection FROM sales '
      'WHERE ${whereClauses.join(' AND ')} '
      'ORDER BY created_at_ms DESC$limitClause',
      variables: variables,
    );
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
    final today = DateTime.now();
    final todayStartMs = DateTime(
      today.year,
      today.month,
      today.day,
    ).millisecondsSinceEpoch;

    final salesAgg = await _selectRows(
      'SELECT COALESCE(SUM(total_amount), 0) AS total_sales, '
      'COUNT(*) AS tx_count FROM sales '
      'WHERE COALESCE(is_deleted, 0) = 0 AND created_at_ms >= ?',
      variables: [Variable<int>(todayStartMs)],
    );
    final totalSales = (salesAgg.first['total_sales'] as num).toDouble();
    final transactions = (salesAgg.first['tx_count'] as num).toInt();

    final lowStockRows = await _selectRows(
      'SELECT id, name, stock_in_base_unit, reorder_point FROM products '
      'WHERE COALESCE(is_deleted, 0) = 0 AND COALESCE(is_active, 1) = 1 '
      'AND stock_in_base_unit > 0 '
      'AND stock_in_base_unit <= reorder_point',
    );
    final lowStock = lowStockRows
        .map(
          (r) => LowStockProduct(
            id: r['id'] as String,
            name: r['name'] as String,
            stockQuantity: ((r['stock_in_base_unit'] as num).toDouble())
                .floor(),
            reorderPoint: (r['reorder_point'] as num).toInt(),
          ),
        )
        .toList();

    final utangAgg = await _selectRows(
      'SELECT COALESCE(SUM(amount), 0) AS total_utang FROM utang_records '
      'WHERE COALESCE(is_deleted, 0) = 0',
    );
    final totalUtang = (utangAgg.first['total_utang'] as num).toDouble();

    return DashboardStats(
      today: TodayStats(
        totalSales: totalSales,
        profit: 0,
        transactions: transactions,
      ),
      lowStockProducts: lowStock,
      totalOutstandingUtang: totalUtang,
      topProductsThisWeek: const [],
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
      return const ReportsData(
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
}

class _EnrichedSaleItem {
  final String productId;
  final String selectedUnit;
  final double quantity;
  final double unitPrice;
  final double computedBaseQuantity;
  final double lineTotal;

  const _EnrichedSaleItem({
    required this.productId,
    required this.selectedUnit,
    required this.quantity,
    required this.unitPrice,
    required this.computedBaseQuantity,
    required this.lineTotal,
  });
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
