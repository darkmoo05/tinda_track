import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/app_meta_dao.dart';
import '../../../../core/di/database_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../inventory/data/models/inventory_product.dart';
import 'sale_model.dart';
import 'exceptions/pos_exceptions.dart';

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
      throw CheckoutEmptyCartException();
    }
    if (request.paidAmount < 0) {
      throw NegativePaidAmountException();
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
        final pRow = await (_database.select(_database.products)
              ..where((t) => t.id.equals(item.product.id))
              ..limit(1))
            .getSingleOrNull();

        if (pRow == null) {
          throw Exception('Product not found: ${item.product.name}');
        }
        final productId = pRow.id;
        final baseUnit = pRow.baseUnit;
        final selectedUnit = item.selectedUnitName;
        final itemType = pRow.itemType;

        double conversionFactor = 1;
        if (selectedUnit.toLowerCase() != baseUnit.toLowerCase()) {
          final conversionRow = await (_database.select(_database.productUnitConversions)
                ..where((t) => t.productId.equals(productId) & t.unitName.lower().equals(selectedUnit.toLowerCase()) & t.isDeleted.equals(false))
                ..limit(1))
              .getSingleOrNull();
          if (conversionRow == null) {
            throw UnitConversionNotSetException(selectedUnit, item.product.name);
          }
          conversionFactor = conversionRow.conversionFactor;
        }

        final computedBaseQuantity = item.quantity * conversionFactor;
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

        if (itemType == 'recipe') {
          // Deduct ingredients instead of parent product stock
          final ingredientsQuery = _database.select(_database.productRecipeIngredients).join([
            leftOuterJoin(
              _database.products,
              _database.products.id.equalsExp(_database.productRecipeIngredients.ingredientProductId),
            ),
          ])..where(_database.productRecipeIngredients.recipeProductId.equals(productId) & _database.productRecipeIngredients.isDeleted.equals(false));

          final ingredientRows = await ingredientsQuery.get();

          if (ingredientRows.isEmpty) {
            throw EmptyRecipeIngredientsException(item.product.name);
          }

          for (final row in ingredientRows) {
            final pri = row.readTable(_database.productRecipeIngredients);
            final p = row.readTableOrNull(_database.products);
            if (p == null) continue;

            final ingId = pri.ingredientProductId;
            final quantityNeeded = pri.quantityNeeded;
            final ingName = p.name;
            final ingCurrentStock = p.stockInBaseUnit;

            final totalIngDeduction = quantityNeeded * computedBaseQuantity;
            if (totalIngDeduction > ingCurrentStock) {
              throw InsufficientIngredientStockException(
                ingredientName: ingName,
                productName: item.product.name,
                needed: totalIngDeduction,
                available: ingCurrentStock,
              );
            }

            final newIngStock = ingCurrentStock - totalIngDeduction;
            await (_database.update(_database.products)..where((t) => t.id.equals(ingId))).write(
              ProductsCompanion(
                stockInBaseUnit: Value(newIngStock),
                isDirty: const Value(true),
                updatedAtMs: Value(nowMs),
              ),
            );

            // Record PRODUCTION_DEDUCTION stock movement locally
            await _database.into(_database.stockMovements).insert(
              StockMovementsCompanion.insert(
                id: _uuid.v4(),
                productId: ingId,
                movementType: 'PRODUCTION_DEDUCTION',
                quantity: totalIngDeduction,
                previousQuantity: ingCurrentStock,
                newQuantity: newIngStock,
                note: Value('Ingredient for recipe ${pRow.name}'),
                reference: Value(reference),
                createdAtMs: nowMs,
                isDirty: const Value(true),
              ),
            );
          }
        } else {
          // Standard product stock deduction
          final currentBaseStock = pRow.stockInBaseUnit;
          if (computedBaseQuantity > currentBaseStock) {
            throw InsufficientProductStockException(
              productName: item.product.name,
              needed: computedBaseQuantity,
              available: currentBaseStock,
            );
          }

          final newBaseStock = currentBaseStock - computedBaseQuantity;
          await (_database.update(_database.products)..where((t) => t.id.equals(productId))).write(
            ProductsCompanion(
              stockInBaseUnit: Value(newBaseStock),
              isDirty: const Value(true),
              updatedAtMs: Value(nowMs),
            ),
          );

          // Handle serial tracking if applicable
          final serialsInDb = await (_database.select(_database.productSerialNumbers)
                ..where((t) => t.productId.equals(productId) & t.isDeleted.equals(false)))
              .get();
          final hasSerialsCount = serialsInDb.length;

          if (hasSerialsCount > 0) {
            final requiredSerials = computedBaseQuantity.toInt();
            if (item.selectedSerials.length != requiredSerials) {
              throw SerialSelectionException(
                productName: item.product.name,
                requiredCount: requiredSerials,
                selectedCount: item.selectedSerials.length,
              );
            }

            for (final serial in item.selectedSerials) {
              final serialRow = await (_database.select(_database.productSerialNumbers)
                    ..where((t) => t.productId.equals(productId) & t.serialNumber.equals(serial) & t.isDeleted.equals(false))
                    ..limit(1))
                  .getSingleOrNull();

              if (serialRow == null || serialRow.status != 'AVAILABLE') {
                throw SerialNotAvailableException(serial);
              }

              await (_database.update(_database.productSerialNumbers)
                    ..where((t) => t.productId.equals(productId) & t.serialNumber.equals(serial)))
                  .write(
                ProductSerialNumbersCompanion(
                  status: const Value('SOLD'),
                  isDirty: const Value(true),
                  updatedAtMs: Value(nowMs),
                ),
              );
            }
          }
        }
      }

      final totalAmount = subtotal;
      if (request.paidAmount < totalAmount) {
        throw PaidAmountInsufficientException(request.paidAmount, totalAmount);
      }
      final changeAmount = request.paidAmount - totalAmount;

      await _database.into(_database.sales).insert(
        SaleRow(
          id: saleId,
          reference: reference,
          note: request.note ?? '',
          subtotal: subtotal,
          totalAmount: totalAmount,
          paidAmount: request.paidAmount,
          changeAmount: changeAmount,
          totalItems: totalItems,
          syncId: saleId,
          deviceId: deviceId,
          isDeleted: false,
          isDirty: true,
          createdAtMs: nowMs,
          updatedAtMs: nowMs,
        ),
      );

      for (final item in enrichedItems) {
        await _database.into(_database.saleItems).insert(
          SaleItemRow(
            id: _uuid.v4(),
            saleId: saleId,
            productId: item.productId,
            selectedUnit: item.selectedUnit,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            computedBaseQuantity: item.computedBaseQuantity,
            lineTotal: item.lineTotal,
            createdAtMs: nowMs,
            isDirty: true,
          ),
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
