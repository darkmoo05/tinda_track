import '../../../../core/network/api_client.dart';
import 'product_model.dart';

class InventoryRepository {
  InventoryRepository._();
  static final InventoryRepository instance = InventoryRepository._();

  Future<List<TtProduct>> listProducts({
    String? search,
    bool includeDeleted = false,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (includeDeleted) params['includeDeleted'] = 'true';
    final response = await ApiClient.instance.get(
      '/inventory/products',
      params: params,
    );
    final list = (response.data['data'] as List);
    return list
        .map((e) => TtProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TtProduct> createProduct(TtProduct product) async {
    final response = await ApiClient.instance.post(
      '/inventory/products',
      product.toCreateJson(),
    );
    return TtProduct.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<TtProduct> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.instance.patch(
      '/inventory/products/$id',
      data,
    );
    return TtProduct.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> adjustStock(String id, int delta, {String? note}) async {
    final payload = <String, Object?>{'quantityDelta': delta};
    if (note != null) {
      payload['note'] = note;
    }
    await ApiClient.instance.post(
      '/inventory/products/$id/adjust-stock',
      payload,
    );
  }

  Future<void> deleteProduct(String id) async {
    await ApiClient.instance.delete('/inventory/products/$id');
  }
}
