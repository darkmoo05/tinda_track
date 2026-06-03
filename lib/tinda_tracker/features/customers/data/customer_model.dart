class TtUtangRecord {
  final String id;
  final String customerId;
  final String description;
  final double amount;
  final DateTime createdAt;

  const TtUtangRecord({
    required this.id,
    required this.customerId,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  bool get isPayment => amount < 0;

  factory TtUtangRecord.fromJson(Map<String, dynamic> json) {
    return TtUtangRecord(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory TtUtangRecord.fromLocalDb(
    Map<String, dynamic> row,
    String customerId,
  ) {
    final serverId = row['server_id'] as String?;
    final syncId = row['sync_id'] as String;
    return TtUtangRecord(
      id: serverId ?? syncId,
      customerId: customerId,
      description: (row['description'] as String?) ?? '',
      amount: (row['amount'] as num).toDouble(),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

class TtCustomer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String notes;
  final double balance;
  final List<TtUtangRecord> utangRecords;

  const TtCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
    required this.balance,
    required this.utangRecords,
  });

  factory TtCustomer.fromJson(Map<String, dynamic> json) {
    final records = (json['utangRecords'] as List? ?? [])
        .map((e) => TtUtangRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    return TtCustomer(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      balance:
          (json['balance'] as num?)?.toDouble() ??
          records.fold(0.0, (sum, r) => sum + r.amount),
      utangRecords: records,
    );
  }

  factory TtCustomer.fromLocalDb(
    Map<String, dynamic> row,
    List<TtUtangRecord> records,
  ) {
    final serverId = row['server_id'] as String?;
    final syncId = row['sync_id'] as String;
    return TtCustomer(
      id: serverId ?? syncId,
      name: row['name'] as String,
      phone: (row['phone'] as String?) ?? '',
      address: (row['address'] as String?) ?? '',
      notes: (row['notes'] as String?) ?? '',
      balance: (row['balance'] as num?)?.toDouble() ?? 0.0,
      utangRecords: records,
    );
  }
}
