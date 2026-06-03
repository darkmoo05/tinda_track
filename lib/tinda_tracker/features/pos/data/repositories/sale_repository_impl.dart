import 'package:uuid/uuid.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/database/daos/tinda_tracker/sale_items_dao.dart';
import '../../../../../core/database/daos/tinda_tracker/sales_dao.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/sale_repository.dart';
import '../mappers/sale_item_mapper.dart';
import '../mappers/sale_mapper.dart';

class SaleRepositoryImpl implements SaleRepository {
  SaleRepositoryImpl(this._db, this._salesDao, this._saleItemsDao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SalesDao _salesDao;
  final SaleItemsDao _saleItemsDao;
  final Uuid _uuid;

  @override
  Stream<List<Sale>> watchAll({int? limit}) {
    // Headers only — the UI typically lists sales without items expanded.
    return _salesDao
        .watchAll(limit: limit)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<Sale?> findById(String id) async {
    final header = await _salesDao.findById(id);
    if (header == null) return null;
    final items = await _saleItemsDao.listForSale(id);
    return header.toDomain(
      items: items.map((r) => r.toDomain()).toList(growable: false),
    );
  }

  @override
  Future<Sale> save(Sale sale) async {
    final now = DateTime.now();
    final saleId = sale.id.isEmpty ? _uuid.v4() : sale.id;
    final prepared = sale.copyWith(
      id: saleId,
      sync: sale.sync.copyWith(
        syncId: sale.sync.syncId.isEmpty ? _uuid.v4() : sale.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: sale.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : sale.sync.createdAt,
      ),
      items: sale.items
          .map(
            (item) => item.copyWith(
              id: item.id.isEmpty ? _uuid.v4() : item.id,
              saleId: saleId,
              createdAt: item.createdAt.millisecondsSinceEpoch == 0
                  ? now
                  : item.createdAt,
            ),
          )
          .toList(growable: false),
    );

    await _db.transaction(() async {
      await _salesDao.upsertLocal(prepared.toCompanion());
      // Replace any existing items for this sale to keep semantics simple.
      await _saleItemsDao.deleteForSale(saleId);
      if (prepared.items.isNotEmpty) {
        await _saleItemsDao.insertManyLocal(
          prepared.items
              .map((SaleItem i) => i.toCompanion(isDirty: true))
              .toList(growable: false),
        );
      }
    });

    return prepared;
  }

  @override
  Future<void> delete(String id) => _salesDao.softDelete(id);
}
