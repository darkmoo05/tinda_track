import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sale_item_repository_impl.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/sale_item_repository.dart';
import 'sale_providers.dart';

final saleItemRepositoryProvider = Provider<SaleItemRepository>((ref) {
  return SaleItemRepositoryImpl(ref.watch(saleItemsDaoProvider));
});

final saleItemsForSaleStreamProvider = StreamProvider.autoDispose
    .family<List<SaleItem>, String>((ref, saleId) {
      return ref.watch(saleItemRepositoryProvider).watchForSale(saleId);
    });
