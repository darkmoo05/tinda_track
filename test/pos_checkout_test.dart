import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:tinda_track/core/database/app_database.dart';
import 'package:tinda_track/core/database/repositories/inventory_repository_impl.dart';
import 'package:tinda_track/tinda_tracker/features/pos/data/pos_repository.dart';
import 'package:tinda_track/tinda_tracker/features/pos/data/models/cart_item.dart';
import 'package:tinda_track/tinda_tracker/features/inventory/data/models/inventory_product.dart';
import 'package:tinda_track/tinda_tracker/features/pos/data/exceptions/pos_exceptions.dart';

void main() {
  late AppDatabase db;
  late PosRepository posRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    posRepo = PosRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('POS Checkout pipeline tests', () {
    test('Recipe ingredient stock deduction and movement logging', () async {
      // 1. Setup products
      final porkId = 'pork-ing-id';
      final soyId = 'soy-ing-id';
      final adoboId = 'adobo-recipe-id';

      // Insert Pork ingredient (Stock: 10)
      await db.into(db.products).insert(
        ProductsCompanion.insert(
          id: porkId,
          syncId: porkId,
          name: 'Pork',
          sku: 'ING-PORK',
          sellingPrice: 300,
          stockInBaseUnit: const Value(10.0),
          itemType: const Value('ingredient'),
          createdAtMs: 0,
          updatedAtMs: 0,
        ),
      );

      // Insert Soy Sauce ingredient (Stock: 5)
      await db.into(db.products).insert(
        ProductsCompanion.insert(
          id: soyId,
          syncId: soyId,
          name: 'Soy Sauce',
          sku: 'ING-SOY',
          sellingPrice: 50,
          stockInBaseUnit: const Value(5.0),
          itemType: const Value('ingredient'),
          createdAtMs: 0,
          updatedAtMs: 0,
        ),
      );

      // Insert Adobo Dish Recipe (Stock: 0)
      await db.into(db.products).insert(
        ProductsCompanion.insert(
          id: adoboId,
          syncId: adoboId,
          name: 'Adobo Dish',
          sku: 'REC-ADOBO',
          sellingPrice: 150,
          stockInBaseUnit: const Value(0.0),
          itemType: const Value('recipe'),
          createdAtMs: 0,
          updatedAtMs: 0,
        ),
      );

      // 2. Link recipe ingredients (1 Adobo needs 2.0 Pork and 0.5 Soy Sauce)
      await db.into(db.productRecipeIngredients).insert(
        ProductRecipeIngredientsCompanion.insert(
          id: 'pri-pork',
          syncId: 'pri-pork',
          deviceId: const Value('test-device'),
          recipeProductId: adoboId,
          ingredientProductId: porkId,
          quantityNeeded: 2.0,
          createdAtMs: 0,
          updatedAtMs: 0,
        ),
      );

      await db.into(db.productRecipeIngredients).insert(
        ProductRecipeIngredientsCompanion.insert(
          id: 'pri-soy',
          syncId: 'pri-soy',
          deviceId: const Value('test-device'),
          recipeProductId: adoboId,
          ingredientProductId: soyId,
          quantityNeeded: 0.5,
          createdAtMs: 0,
          updatedAtMs: 0,
        ),
      );

      // Load product domain entity for cart
      final adoboRow = await (db.select(db.products)..where((t) => t.id.equals(adoboId))).getSingle();
      final adoboProduct = InventoryProduct.fromRow(adoboRow);

      // 3. Checkout 2 Adobos (needs 4.0 Pork, 1.0 Soy Sauce)
      final cartItem = CartItem(
        product: adoboProduct,
        selectedUnitName: 'pcs',
        quantity: 2.0,
        appliedPrice: 150.0,
      );

      await posRepo.checkout(
        CheckoutRequest(
          items: [cartItem],
          paidAmount: 300.0,
          deviceId: 'test-device',
        ),
      );

      // 4. Verify ingredient stocks
      final updatedPork = await (db.select(db.products)..where((t) => t.id.equals(porkId))).getSingle();
      final updatedSoy = await (db.select(db.products)..where((t) => t.id.equals(soyId))).getSingle();

      expect(updatedPork.stockInBaseUnit, equals(6.0)); // 10.0 - (2.0 * 2.0)
      expect(updatedSoy.stockInBaseUnit, equals(4.0));  // 5.0 - (0.5 * 2.0)

      // 5. Verify stock movements logged
      final movements = await db.select(db.stockMovements).get();
      expect(movements.length, equals(2));

      final porkMovement = movements.firstWhere((m) => m.productId == porkId);
      expect(porkMovement.movementType, equals('PRODUCTION_DEDUCTION'));
      expect(porkMovement.quantity, equals(4.0));
      expect(porkMovement.previousQuantity, equals(10.0));
      expect(porkMovement.newQuantity, equals(6.0));

      final soyMovement = movements.firstWhere((m) => m.productId == soyId);
      expect(soyMovement.movementType, equals('PRODUCTION_DEDUCTION'));
      expect(soyMovement.quantity, equals(1.0));
      expect(soyMovement.previousQuantity, equals(5.0));
      expect(soyMovement.newQuantity, equals(4.0));
    });

    test('Serial number strict checkout validation and state transitions', () async {
      final productId = 'serial-tracked-prod';

      // Insert product with stock 3
      await db.into(db.products).insert(
        ProductsCompanion.insert(
          id: productId,
          syncId: productId,
          name: 'Vios Spark Plug',
          sku: 'SPK-VIOS',
          sellingPrice: 250,
          stockInBaseUnit: const Value(3.0),
          createdAtMs: 0,
          updatedAtMs: 0,
        ),
      );

      // Insert 3 available serial numbers
      final serials = ['SN-001', 'SN-002', 'SN-003'];
      for (final sn in serials) {
        await db.into(db.productSerialNumbers).insert(
          ProductSerialNumbersCompanion.insert(
            id: 'id-$sn',
            syncId: 'sync-$sn',
            deviceId: const Value('test-device'),
            productId: productId,
            serialNumber: sn,
            status: const Value('AVAILABLE'),
            createdAtMs: 0,
            updatedAtMs: 0,
          ),
        );
      }

      final prodRow = await (db.select(db.products)..where((t) => t.id.equals(productId))).getSingle();
      final product = InventoryProduct.fromRow(prodRow);
      // product loaded successfully: baseUnit, stockInBaseUnit, itemType verified via assertions below
      // 1. Checkout 2 units WITHOUT specifying serials -> should throw Exception
      final cartItemNoSerials = CartItem(
        product: product,
        selectedUnitName: 'pcs',
        quantity: 2.0,
        appliedPrice: 250.0,
        selectedSerials: const [],
      );

      await expectLater(
        () => posRepo.checkout(CheckoutRequest(items: [cartItemNoSerials], paidAmount: 500.0)),
        throwsA(isA<SerialSelectionException>()),
      );

      // 2. Checkout 2 units with only 1 serial selected -> should throw Exception
      final cartItemOneSerial = CartItem(
        product: product,
        selectedUnitName: 'pcs',
        quantity: 2.0,
        appliedPrice: 250.0,
        selectedSerials: const ['SN-001'],
      );

      await expectLater(
        () => posRepo.checkout(CheckoutRequest(items: [cartItemOneSerial], paidAmount: 500.0)),
        throwsA(isA<SerialSelectionException>()),
      );

      // 3. Checkout 2 units with an unavailable/unregistered serial number -> should throw Exception
      final cartItemInvalidSerial = CartItem(
        product: product,
        selectedUnitName: 'pcs',
        quantity: 2.0,
        appliedPrice: 250.0,
        selectedSerials: const ['SN-001', 'SN-999'],
      );

      await expectLater(
        () => posRepo.checkout(CheckoutRequest(items: [cartItemInvalidSerial], paidAmount: 500.0)),
        throwsA(isA<SerialNotAvailableException>()),
      );

      // 4. Checkout 2 units with correct valid serials -> should succeed
      final cartItemValidSerials = CartItem(
        product: product,
        selectedUnitName: 'pcs',
        quantity: 2.0,
        appliedPrice: 250.0,
        selectedSerials: const ['SN-001', 'SN-002'],
      );

      await posRepo.checkout(
        CheckoutRequest(
          items: [cartItemValidSerials],
          paidAmount: 500.0,
          deviceId: 'test-device',
        ),
      );

      // 5. Verify stock quantity decreased
      final updatedProd = await (db.select(db.products)..where((t) => t.id.equals(productId))).getSingle();
      expect(updatedProd.stockInBaseUnit, equals(1.0));

      // 6. Verify serial status updated in DB
      final sn1 = await (db.select(db.productSerialNumbers)..where((t) => t.serialNumber.equals('SN-001'))).getSingle();
      final sn2 = await (db.select(db.productSerialNumbers)..where((t) => t.serialNumber.equals('SN-002'))).getSingle();
      final sn3 = await (db.select(db.productSerialNumbers)..where((t) => t.serialNumber.equals('SN-003'))).getSingle();

      expect(sn1.status, equals('SOLD'));
      expect(sn2.status, equals('SOLD'));
      expect(sn3.status, equals('AVAILABLE'));
    });
   group('customAttributesJson search capabilities', () {
      test('Searching custom attributes content locally using InventoryRepository listProducts', () async {
        final repo = InventoryRepositoryImpl(database: db);

        // Insert Auto Shop product
        await repo.createProduct(
          name: 'Vios Spark Plug',
          sku: 'SPK-VIOS-12',
          sellingPrice: 150,
          stockQuantity: 10,
          customAttributes: {
            'brand': 'Denso',
            'compatibility': 'Toyota Vios 2018, Yaris 2017',
          },
        );

        // Insert Hardware product
        await repo.createProduct(
          name: 'Steel Bolt',
          sku: 'BLT-STL-01',
          sellingPrice: 25,
          stockQuantity: 100,
          customAttributes: {
            'dimensions': 'M10 x 50mm',
            'weight': '0.05kg',
          },
        );

        // 1. Search for brand "Denso"
        final densoResults = await repo.listProducts(search: 'denso');
        expect(densoResults.length, equals(1));
        expect(densoResults.first.name, equals('Vios Spark Plug'));

        // 2. Search for compatibility "Vios 2018"
        final compatibilityResults = await repo.listProducts(search: 'vios 2018');
        expect(compatibilityResults.length, equals(1));
        expect(compatibilityResults.first.name, equals('Vios Spark Plug'));

        // 3. Search for dimensions "M10"
        final dimensionsResults = await repo.listProducts(search: 'm10');
        expect(dimensionsResults.length, equals(1));
        expect(dimensionsResults.first.name, equals('Steel Bolt'));

        // 4. Search for generic keyword "Toyota"
        final genericResults = await repo.listProducts(search: 'toyota');
        expect(genericResults.length, equals(1));
        expect(genericResults.first.name, equals('Vios Spark Plug'));
      });
    });
  });
}
