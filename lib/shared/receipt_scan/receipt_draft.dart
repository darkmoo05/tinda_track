enum ReceiptImageSource { camera, gallery, file }

enum ReceiptFieldConfidence { unknown, low, medium, high }

enum ReceiptWalletSelection { gcash, maya }

enum ReceiptFlowDirection { inflow, outflow }

class ReceiptDraft {
  const ReceiptDraft({
    this.amount,
    this.amountConfidence = ReceiptFieldConfidence.unknown,
    this.accountNumber,
    this.accountConfidence = ReceiptFieldConfidence.unknown,
    this.accountName,
    this.accountNameConfidence = ReceiptFieldConfidence.unknown,
    this.reference,
    this.referenceConfidence = ReceiptFieldConfidence.unknown,
    this.walletSelection,
    this.flowDirection,
    this.rawOcrPreview,
  });

  final double? amount;
  final ReceiptFieldConfidence amountConfidence;
  final String? accountNumber;
  final ReceiptFieldConfidence accountConfidence;
  final String? accountName;
  final ReceiptFieldConfidence accountNameConfidence;
  final String? reference;
  final ReceiptFieldConfidence referenceConfidence;
  final ReceiptWalletSelection? walletSelection;
  final ReceiptFlowDirection? flowDirection;
  final String? rawOcrPreview;

  String? get walletLabel {
    return switch (walletSelection) {
      ReceiptWalletSelection.gcash => 'GCash',
      ReceiptWalletSelection.maya => 'Maya Wallet',
      null => null,
    };
  }

  String? get flowLabel {
    return switch (flowDirection) {
      ReceiptFlowDirection.inflow => 'Cash In',
      ReceiptFlowDirection.outflow => 'Cash Out',
      null => null,
    };
  }

  bool get hasAnySignal {
    return amount != null ||
        accountNumber != null ||
        accountName != null ||
        reference != null ||
        walletSelection != null ||
        flowDirection != null;
  }

  bool get hasAnyAutofillField {
    return amount != null || accountNumber != null || reference != null;
  }
}
