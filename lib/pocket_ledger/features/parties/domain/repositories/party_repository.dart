import '../entities/party.dart';

abstract class PartyRepository {
  Stream<List<Party>> watchAll();
  Future<Party?> findById(String id);
  Future<Party> save(Party party);
  Future<void> delete(String id);
}
