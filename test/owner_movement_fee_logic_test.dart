import 'package:flutter_test/flutter_test.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/logic/owner_movement_fee_logic.dart';

void main() {
  group('computeCashTransferFeeComputation', () {
    test('toggle OFF guard scenario source: transfer 400 vs non-fee 200', () {
      const onHand = 500.0;
      const availableFee = 300.0;
      const transfer = 400.0;
      final nonFeePortion = onHand - availableFee;

      expect(transfer > nonFeePortion, isTrue);
    });

    test('On-Hand 500, Fee 300, Transfer 400, toggle ON', () {
      final result = computeCashTransferFeeComputation(
        onHandBalance: 500,
        availableFeeOnHand: 300,
        transferAmount: 400,
      );

      expect(result.feeConsumedWithinTransfer, closeTo(200, 0.0001));
      expect(result.requestedExtraFeeTransfer, closeTo(100, 0.0001));
      expect(result.extraFeeTransfer, closeTo(100, 0.0001));
      expect(result.totalFeeMoved, closeTo(300, 0.0001));
    });

    test('On-Hand 500, Fee 300, Transfer 200, toggle OFF boundary', () {
      const onHand = 500.0;
      const availableFee = 300.0;
      const transfer = 200.0;
      final nonFeePortion = onHand - availableFee;

      expect(transfer <= nonFeePortion, isTrue);
    });

    test('On-Hand 500, Fee 300, Transfer 200, toggle ON', () {
      final result = computeCashTransferFeeComputation(
        onHandBalance: 500,
        availableFeeOnHand: 300,
        transferAmount: 200,
      );

      expect(result.feeConsumedWithinTransfer, closeTo(0, 0.0001));
      expect(result.requestedExtraFeeTransfer, closeTo(300, 0.0001));
      expect(result.extraFeeTransfer, closeTo(300, 0.0001));
      expect(result.totalFeeMoved, closeTo(300, 0.0001));
    });

    test('On-Hand 500, Fee 300, Transfer 500, toggle ON', () {
      final result = computeCashTransferFeeComputation(
        onHandBalance: 500,
        availableFeeOnHand: 300,
        transferAmount: 500,
      );

      expect(result.feeConsumedWithinTransfer, closeTo(300, 0.0001));
      expect(result.requestedExtraFeeTransfer, closeTo(0, 0.0001));
      expect(result.extraFeeTransfer, closeTo(0, 0.0001));
      expect(result.totalFeeMoved, closeTo(300, 0.0001));
    });

    test(
      'transfer > on-hand clamps extra fee to 0 and moves available fee only',
      () {
        final result = computeCashTransferFeeComputation(
          onHandBalance: 500,
          availableFeeOnHand: 300,
          transferAmount: 600,
        );

        expect(result.feeConsumedWithinTransfer, closeTo(300, 0.0001));
        expect(result.requestedExtraFeeTransfer, closeTo(0, 0.0001));
        expect(result.extraFeeTransfer, closeTo(0, 0.0001));
        expect(result.totalFeeMoved, closeTo(300, 0.0001));
      },
    );
  });
}
