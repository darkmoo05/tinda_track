// Transaction API Models and Data Layer

class TransactionPreviewResponse {
  final double chargeAmount;
  final double totalCollected;
  final double walletCredit;
  final double onHandChange;
  final String feeRoutingExplanation;
  final double currentWalletBalance;
  final double postTransactionWalletBalance;

  TransactionPreviewResponse({
    required this.chargeAmount,
    required this.totalCollected,
    required this.walletCredit,
    required this.onHandChange,
    required this.feeRoutingExplanation,
    required this.currentWalletBalance,
    required this.postTransactionWalletBalance,
  });

  factory TransactionPreviewResponse.fromJson(Map<String, dynamic> json) {
    return TransactionPreviewResponse(
      chargeAmount: (json['chargeAmount'] as num).toDouble(),
      totalCollected: (json['totalCollected'] as num).toDouble(),
      walletCredit: (json['walletCredit'] as num).toDouble(),
      onHandChange: (json['onHandChange'] as num).toDouble(),
      feeRoutingExplanation: json['feeRoutingExplanation'] as String,
      currentWalletBalance: (json['currentWalletBalance'] as num).toDouble(),
      postTransactionWalletBalance:
          (json['postTransactionWalletBalance'] as num).toDouble(),
    );
  }
}

class TransactionCreateRequest {
  final String walletProvider; // GCASH or MAYA
  final String direction; // CASH_IN or CASH_OUT
  final double amount;
  final String chargeHandling; // addOnTop or deductFromAmount
  final String? deviceId;
  final String? syncId;
  final String? reference;
  final String? note;
  final String? entryDate;
  final String? externalProvider;
  final String? externalTransactionId;
  final String? transactionTypeKey; // e.g., gcash_cashin, maya_paybills

  TransactionCreateRequest({
    required this.walletProvider,
    required this.direction,
    required this.amount,
    required this.chargeHandling,
    this.deviceId,
    this.syncId,
    this.reference,
    this.note,
    this.entryDate,
    this.externalProvider,
    this.externalTransactionId,
    this.transactionTypeKey,
  });

  Map<String, dynamic> toJson() => {
    'walletProvider': walletProvider,
    'direction': direction,
    'amount': amount,
    'chargeHandling': chargeHandling,
    if (deviceId != null) 'deviceId': deviceId,
    if (syncId != null) 'syncId': syncId,
    if (reference != null) 'reference': reference,
    if (note != null) 'note': note,
    if (entryDate != null) 'entryDate': entryDate,
    if (externalProvider != null) 'externalProvider': externalProvider,
    if (externalTransactionId != null)
      'externalTransactionId': externalTransactionId,
    if (transactionTypeKey != null) 'transactionTypeKey': transactionTypeKey,
  };
}

class TransactionCreateResponse {
  final String id;
  final double balanceBefore;
  final double balanceAfter;
  final String chargeHandling;
  final String? externalProvider;
  final String? externalTransactionId;

  TransactionCreateResponse({
    required this.id,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.chargeHandling,
    this.externalProvider,
    this.externalTransactionId,
  });

  factory TransactionCreateResponse.fromJson(Map<String, dynamic> json) {
    return TransactionCreateResponse(
      id: json['id'] as String,
      balanceBefore: (json['balanceBefore'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      chargeHandling: json['chargeHandling'] as String,
      externalProvider: json['externalProvider'] as String?,
      externalTransactionId: json['externalTransactionId'] as String?,
    );
  }
}
