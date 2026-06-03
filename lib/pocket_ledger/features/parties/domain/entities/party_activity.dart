import 'party.dart';

/// Aggregated activity metrics for a [Party], computed from ledger entries.
class PartyActivityRecord {
  const PartyActivityRecord({
    required this.party,
    required this.transactionCount,
    required this.totalRecordedFlow,
  });

  final Party party;
  final int transactionCount;
  final double totalRecordedFlow;
}
