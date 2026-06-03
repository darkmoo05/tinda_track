/// Hard-coded list of well-known transaction-type keys used by the
/// pocket-ledger UI. Mirrors the rows seeded in the `transaction_types`
/// table; kept here so screens can render labels / detect outflow direction
/// synchronously without awaiting a DB load.
class FixedTransactionType {
  const FixedTransactionType({
    required this.key,
    required this.label,
    required this.isOutflow,
  });

  final String key;
  final String label;
  final bool isOutflow;

  static const List<FixedTransactionType> all = <FixedTransactionType>[
    FixedTransactionType(
      key: 'gcash_cashin',
      label: 'GCash · Cash In',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'gcash_cashout',
      label: 'GCash · Cash Out',
      isOutflow: true,
    ),
    FixedTransactionType(
      key: 'gcash_load',
      label: 'GCash · Load',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'gcash_paybills',
      label: 'GCash · Pay Bills',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'gcash_qrpayment',
      label: 'GCash · QR Payment',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'maya_cashin',
      label: 'Maya · Cash In',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'maya_cashout',
      label: 'Maya · Cash Out',
      isOutflow: true,
    ),
    FixedTransactionType(
      key: 'maya_load',
      label: 'Maya · Load',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'maya_paybills',
      label: 'Maya · Pay Bills',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'maya_qrpayment',
      label: 'Maya · QR Payment',
      isOutflow: false,
    ),
  ];

  static FixedTransactionType forKey(String key) {
    for (final t in all) {
      if (t.key == key) return t;
    }
    return all.first;
  }
}
