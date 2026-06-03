import '../entities/utang_record.dart';

abstract class UtangRecordRepository {
  Stream<List<UtangRecord>> watchAll();
  Stream<List<UtangRecord>> watchForCustomer(String customerId);
  Future<UtangRecord?> findById(String id);
  Future<UtangRecord> save(UtangRecord record);
  Future<void> delete(String id);
}
