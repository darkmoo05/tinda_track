class CashTransferFeeComputation {
  const CashTransferFeeComputation({
    required this.feeConsumedWithinTransfer,
    required this.requestedExtraFeeTransfer,
    required this.extraFeeTransfer,
    required this.totalFeeMoved,
  });

  final double feeConsumedWithinTransfer;
  final double requestedExtraFeeTransfer;
  final double extraFeeTransfer;
  final double totalFeeMoved;
}

CashTransferFeeComputation computeCashTransferFeeComputation({
  required double onHandBalance,
  required double availableFeeOnHand,
  required double transferAmount,
}) {
  final safeOnHandBalance = onHandBalance
      .clamp(0.0, double.infinity)
      .toDouble();
  final safeAvailableFee = availableFeeOnHand
      .clamp(0.0, safeOnHandBalance)
      .toDouble();
  final safeTransferAmount = transferAmount
      .clamp(0.0, double.infinity)
      .toDouble();

  final nonFeePortion = (safeOnHandBalance - safeAvailableFee)
      .clamp(0.0, double.infinity)
      .toDouble();
  final feeConsumedWithinTransfer = (safeTransferAmount - nonFeePortion)
      .clamp(0.0, safeAvailableFee)
      .toDouble();

  final remainingOnHandAfterTransfer = (safeOnHandBalance - safeTransferAmount)
      .clamp(0.0, double.infinity)
      .toDouble();
  final requestedExtraFeeTransfer =
      (safeAvailableFee - feeConsumedWithinTransfer)
          .clamp(0.0, double.infinity)
          .toDouble();

  final extraFeeTransfer = requestedExtraFeeTransfer > 0
      ? (requestedExtraFeeTransfer > remainingOnHandAfterTransfer
            ? remainingOnHandAfterTransfer
            : requestedExtraFeeTransfer)
      : 0.0;

  return CashTransferFeeComputation(
    feeConsumedWithinTransfer: feeConsumedWithinTransfer,
    requestedExtraFeeTransfer: requestedExtraFeeTransfer,
    extraFeeTransfer: extraFeeTransfer,
    totalFeeMoved: feeConsumedWithinTransfer + extraFeeTransfer,
  );
}
