// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Cebuano (`ceb`).
class AppLocalizationsCeb extends AppLocalizations {
  AppLocalizationsCeb([String locale = 'ceb']) : super(locale);

  @override
  String get appTitle => 'PocketLedger';

  @override
  String get syncingData => 'Gi-sync ang imong data…';

  @override
  String get walletOverview => 'Kinatibuk-ang Pitaka';

  @override
  String get gcashWallet => 'GCash Wallet';

  @override
  String get mayaWallet => 'Maya Wallet';

  @override
  String get onHandCash => 'Cash sa Kamot';

  @override
  String get chargesEarnings => 'Kita sa Bayad';

  @override
  String get availableBalance => 'Balanse nga magamit';

  @override
  String get physicalCash => 'Pisikanhong kwarta';

  @override
  String get walletCashBalanceTrend => 'Trend sa Pitaka ug Kwarta';

  @override
  String get borrowed => 'Gipahulam';

  @override
  String get repaid => 'Nabayaran';

  @override
  String get totalPersonalFundsTaken =>
      'Kinatibuk-ang personal nga pondo sa tag-iya';

  @override
  String get totalPersonalFundsReturned =>
      'Kinatibuk-ang pondo nga giuli sa negosyo';

  @override
  String get unableToLoadDashboard => 'Dili ma-load ang dashboard karon.';

  @override
  String get noDashboardData => 'Wala pay data sa dashboard.';

  @override
  String get newEntry => 'Bag-ong Entry';

  @override
  String get recordTransaction => 'I-rekord ang Transaksyon';

  @override
  String get transactionTypeLabel => 'Klase sa Transaksyon';

  @override
  String get accountNumber => 'Recipient Account';

  @override
  String get searchOrEnterAccountNumber => 'Numero';

  @override
  String get scanningReceipt => 'Gi-scan ang resibo…';

  @override
  String get scanningReceiptModalMessage =>
      'Gibasa ang hulagway ug gi-parse ang data sa resibo...';

  @override
  String get scanReceiptButton => 'I-scan ang Resibo (Camera/Gallery)';

  @override
  String get transactionAmount => 'Kantidad sa Transaksyon';

  @override
  String get amountHint => '0.00';

  @override
  String get reference => 'Reperensiya';

  @override
  String get enterReferenceNumber =>
      'Isulat ang numero sa resibo / reperensiya';

  @override
  String get notes => 'Mga Nota';

  @override
  String get optionalNotes => 'Opsyonal nga nota...';

  @override
  String get useCamera => 'Gamita ang Camera';

  @override
  String get takePicture => 'Kuha ug litrato sa resibo';

  @override
  String get pickFromGallery => 'Pilia gikan sa Gallery';

  @override
  String get chooseExistingPhoto => 'Pilia ang screenshot/litrato';

  @override
  String get browseFiles => 'Mag-browse ug Files';

  @override
  String get pickFromAnyFolder => 'Pilia gikan sa bisan unsang folder';

  @override
  String get receiptScanResult => 'Resulta sa Pag-scan';

  @override
  String get receiptScanDescription => 'Ania ang nakit-an sa imong resibo:';

  @override
  String get amount => 'Kantidad';

  @override
  String get accountName => 'Account / Ngalan';

  @override
  String get accountId => 'Account / ID';

  @override
  String get referenceNo => 'Num. sa Reperensiya';

  @override
  String get walletLabel => 'Pitaka';

  @override
  String get noRecognizableData => 'Walay nakit-an nga data sa resibo.';

  @override
  String get noteWillBeAdded => 'Nota nga idugang:';

  @override
  String get reviewAndEdit =>
      'Susihon ug i-edit ang mga field sa dili pa mag-save.';

  @override
  String get cancel => 'Kanselahon';

  @override
  String get apply => 'Ipatupad';

  @override
  String get customerPaysFee => 'Ang Customer ang Magbayad sa Bayad';

  @override
  String get deductFeeFromSent => 'Ibawas ang Bayad sa Kantidad nga Gipadala';

  @override
  String get goToCharges => 'Adto sa Charges';

  @override
  String get searchNameOrAccount => 'Pangita ug ngalan o numero sa account';

  @override
  String get noContactsFound => 'Walay nakit-an nga contact';

  @override
  String get noMatchingContact => 'Walay katugmang contact';

  @override
  String get fullNameEntity => 'Bug-os nga Ngalan / Entity';

  @override
  String get enterPartyFullName => 'Isulat ang bug-os nga ngalan sa party';

  @override
  String get enterAccountNumber => 'Isulat ang numero sa account';

  @override
  String get searchContacts => 'Pangita ug contacts';

  @override
  String get saving => 'Gi-save…';

  @override
  String get registerParty => 'I-register ang Party';

  @override
  String get partyRegisteredSaving =>
      'Nairehistro ang party. Gi-save na ang transaksyon...';

  @override
  String get unableToVerifyRegistration =>
      'Dili ma-verify ang pagparehistro. Sulayi pag-usab.';

  @override
  String get unableToSaveTransaction =>
      'Dili ma-save ang transaksyon. Sulayi pag-usab.';

  @override
  String transactionSaved(String name) {
    return 'Naluwas ang transaksyon alang kang $name.';
  }

  @override
  String selectService(String service) {
    return 'Pilia ang serbisyo: $service';
  }

  @override
  String get customerReceives => 'Modawat ang Customer';

  @override
  String get customerSends => 'Magpadala ang Customer';

  @override
  String get recordTransactionDetails => 'Setup sa Transaksyon';

  @override
  String get optionalDetailsSection =>
      'Magdagdag ug Reference o Notes (Opsyonal)';

  @override
  String get reviewTotals => 'Breakdown sa Kantidad';

  @override
  String get showDetails => 'Ipakita ang detalye';

  @override
  String get hideDetails => 'Itago ang detalye';

  @override
  String get whoPaysServiceFee => 'Fee Handling';

  @override
  String get customerPaysFeeLabel => 'Customer ang mobayad sa fee';

  @override
  String get deductedFromSentLabel => 'Isama sa kantidad';

  @override
  String get usingWallet => 'Gigamit nga wallet';

  @override
  String get serviceFee => 'Bayad na dapat bayaran';

  @override
  String get feeDestination => 'Gipadala ang fee sa';

  @override
  String get feeRange => 'Sakop sa fee';

  @override
  String get amountSentToCustomerWallet => 'Kantidad sa Customer';

  @override
  String get amountCustomerSends => 'Kantidad nga gipadala sa customer';

  @override
  String get customerPays => 'Bayran sa customer';

  @override
  String get cashPaidOut => 'Cash nga ihatag';

  @override
  String get cashAddedToDrawer => 'Sa Inyong Drawer';

  @override
  String get feeAddedExample =>
      'Idungag sa ibabaw ang service fee. Pananglitan: ₱100 transaksyon + ₱5 fee = kolektahon ang ₱105 gikan sa customer, ipadala ang ₱100.';

  @override
  String get feeDeductedExample =>
      'Ibawas una ang service fee sa dili pa magpadala. Pananglitan: ₱100 ang gisulod, ₱5 fee ang gibawas = ₱95 ra ang maabot sa wallet sa customer.';

  @override
  String get accountNotInContacts =>
      'Wala pa sa contacts kining account. I-tap dinhi aron idugang sa dili pa mag-save.';

  @override
  String get saveTransactionAction => 'I-record ang Transaksyon';

  @override
  String get walletAndService => 'Klase sa Transaksyon (Kinakalangan)';

  @override
  String verifiedAccountFound(String name) {
    return '$name - Nakumpirmang naa ang record sa account';
  }

  @override
  String get onHandCashLabel => 'Cash sa kamot';

  @override
  String get cashPaidOutTooltip =>
      'Cash nga imong ihatag sa customer gikan sa imong drawer.';

  @override
  String get cashAddedToDrawerTooltip =>
      'Cash nga musulod sa imong drawer human sa transaksyon.';

  @override
  String get noFeeRuleForAmount =>
      'Wala pay fee rule para ani nga kantidad. Ang fee kay ₱0. Pagdugang una ug fee rule.';

  @override
  String get receiptDataAppliedReview =>
      'Na-apply ang data sa resibo. Palihug susiha una sa dili pa i-save.';

  @override
  String get noFeeRangeFoundTitle => 'Walay fee range nga nakita';

  @override
  String get noFeeRangeFoundMessage =>
      'Ang gisulod nga kantidad wala mosulod sa bisan unsang fee range. Paghimo una ug bag-ong fee range.';

  @override
  String get accountNumberRequiredBeforeSaving =>
      'Kinahanglan ang numero sa account sa dili pa mag-save.';

  @override
  String get transactionAmountRequiredBeforeSaving =>
      'Kinahanglan ang kantidad sa transaksyon sa dili pa mag-save.';

  @override
  String get noFeeRangeFoundForAmount =>
      'Walay fee range para ani nga kantidad. Paghimo una ug bag-ong range.';

  @override
  String get amountToSendMustBeGreaterThanZero =>
      'Ang kantidad nga ipadala kinahanglan mas dako sa zero. Ayuha ang kantidad o fee setting.';

  @override
  String insufficientBalance(String source, String amount) {
    return 'Kulang ang balanse sa $source. Available: ₱ $amount';
  }

  @override
  String get partyNotRegisteredYet =>
      'Wala pa na-rehistro ang party. Irehistro una ang detalye.';

  @override
  String transactionSavedSyncRetry(String name) {
    return 'Na-save ang transaksyon para kang $name. Sulayan pag-usab ang backend sync.';
  }

  @override
  String get amountMustBeGreaterThanZero =>
      'Ang kantidad kinahanglan mas dako sa 0';

  @override
  String feeValidationFailedStatus(String status, String message) {
    return 'Napakyas ang fee validation$status: $message';
  }

  @override
  String feeValidationFailed(String error) {
    return 'Napakyas ang fee validation: $error';
  }

  @override
  String get backendPreviewUnavailable => 'Dili available ang backend preview';

  @override
  String get unableToValidateFeePreviewNow =>
      'Dili ma-validate ang fee preview gikan sa backend karon.';

  @override
  String get saveLocally => 'I-save lokal';

  @override
  String get feeBreakdownTitle => 'Breakdown sa fee';

  @override
  String get charge => 'Bayad';

  @override
  String get totalCollected => 'Kinatibuk-ang nakolekta';

  @override
  String get walletCredit => 'Credit sa wallet';

  @override
  String get onHandChange => 'Pagbag-o sa cash sa kamot';

  @override
  String get feeRouting => 'Asa moadto ang fee';

  @override
  String get confirmAndSave => 'Kumpirma ug i-save';

  @override
  String get selectRegisteredContact => 'Pilia ang na-rehistrong contact';

  @override
  String get registerPartyFirstThenSearch =>
      'Pagrehistro una ug party, dayon gamita ang search aron mopili ug account.';

  @override
  String get tryDifferentNameOrAccount =>
      'Sulayi ang laing ngalan o numero sa account sa pagpangita.';

  @override
  String accountWithNumber(String number) {
    return 'Account: $number';
  }

  @override
  String get completeNameAndAccount =>
      'Palihug kompletoha ang bug-os nga ngalan ug numero sa account.';

  @override
  String get unableToSaveParty => 'Dili ma-save ang party. Sulayi pag-usab.';

  @override
  String get accountAlreadyRegistered => 'Na-rehistro na ang account.';

  @override
  String get partyRegistrationTitle => 'Pagrehistro sa Party';

  @override
  String get defineFinancialEntityBeforeTransaction =>
      'Paghimo una ug bag-ong financial entity sa dili pa irekord ang transaksyon.';

  @override
  String get loadService => 'Load';

  @override
  String get payBillsService => 'Bayad Bills';

  @override
  String get qrPaymentService => 'QR Payment';

  @override
  String get stepOneChooseWallet => 'Lakáng 1: Pilia ang wallet';

  @override
  String get pickWalletHelper =>
      'Ang wallet buttons para mopili sa account nga gamiton.';

  @override
  String get stepTwoChooseService => 'Lakáng 2: Pilia ang serbisyo';

  @override
  String get pickServiceHelper =>
      'Ang service buttons para mopili sa klase sa transaksyon.';

  @override
  String selectedWalletService(String wallet, String service) {
    return 'Napili: $wallet • $service';
  }

  @override
  String get newOwnerMovement => 'Bag-ong Rekord sa Kwarta';

  @override
  String get recordOwnerMovement => 'Irekord ang Entry sa Kwarta';

  @override
  String get phase3Description =>
      'Sunda ang kwarta nga imong gidugang, gikuha, o gihulam gikan sa imong mga business wallet.';

  @override
  String get movementType => 'Unsa imong gibuhat?';

  @override
  String get chooseMovementType => 'Pilia kung unsay nahitabo';

  @override
  String get moneyDirection => 'Unsa ni nga epekto';

  @override
  String get cashIn => 'Sulod ang Cash';

  @override
  String get cashOut => 'Gawas ang Cash';

  @override
  String get borrowFrom => 'Pahulamon Gikan sa';

  @override
  String get repayTo => 'Bayaran ngadto sa';

  @override
  String get destination => 'Destinasyon';

  @override
  String get sourceAccount => 'Gikan gikuha';

  @override
  String get personal => 'Personal';

  @override
  String get business => 'Negosyo';

  @override
  String get expenseCategory => 'Kategorya sa Gasto';

  @override
  String get add => 'Dugangi';

  @override
  String get manage => 'Atimana';

  @override
  String get addCategoryFirst =>
      'Pagdugang una ug kategorya sa gasto (pananglitan: Pagkaon, Plete).';

  @override
  String get chooseExpenseCategory => 'Pilia ang Kategorya sa Gasto';

  @override
  String get referenceOptional => 'Reperensiya (Opsyonal)';

  @override
  String get notesOptional => 'Nota (Opsyonal)';

  @override
  String get additionalDetails => 'Dugang detalye...';

  @override
  String get categoryName => 'Ngalan sa kategorya';

  @override
  String get renameCategory => 'Ilisan ang Ngalan sa Kategorya';

  @override
  String get addCategory => 'Magdugang ug Kategorya';

  @override
  String get save => 'I-save';

  @override
  String get done => 'Nahuman';

  @override
  String get existingCategories => 'Mga Naa nga Kategorya';

  @override
  String get rename => 'Ilisan';

  @override
  String get delete => 'Tangtanga';

  @override
  String get categoryDeleted => 'Natangtang ang kategorya.';

  @override
  String get enterCategoryName => 'Isulat ang ngalan sa kategorya.';

  @override
  String get movementTypePending => 'Wala pay napiling klase';

  @override
  String get categoryPending => 'Wala pay napiling kategorya';

  @override
  String get movements => 'Kasaysayan sa Wallet';

  @override
  String get walletHistorySubtitle =>
      'Subaya ang lihok sa GCash, Maya, ug cash.';

  @override
  String get reports => 'I-download ang Taho';

  @override
  String get transactions => 'Mga Transaksyon';

  @override
  String get ownerMovements => 'Aktibidad sa Tag-iya';

  @override
  String get historyTransactionLabel => 'Transaksyon';

  @override
  String get historyOwnerActivityLabel => 'Aktibidad sa Tag-iya';

  @override
  String get historyTypeLabel => 'Klase';

  @override
  String get historyCategoryLabel => 'Kategorya';

  @override
  String get historyAccountLabel => 'Account';

  @override
  String get historyAmountShownLabel => 'Gipakitang kantidad';

  @override
  String get walletChangeLabel => 'Kausaban sa wallet';

  @override
  String get cashChangeLabel => 'Kausaban sa cash';

  @override
  String get savedOnLabel => 'Naluwas niadtong';

  @override
  String get transactionBreakdown => 'Breakdown sa Transaksyon';

  @override
  String get entryDetails => 'Detalye sa Entry';

  @override
  String includesFee(String amount) {
    return 'Apil ang bayad: $amount';
  }

  @override
  String get today => 'Karon';

  @override
  String get yesterday => 'Kagahapon';

  @override
  String get noMatchingTransactions => 'Walay nakit-ang resulta';

  @override
  String get trySearchingBy =>
      'Sulayi pag-usab pinaagi sa wallet, petsa, o pagpangita.';

  @override
  String get noHistoryYet => 'Wala pay kasaysayan';

  @override
  String get newEntriesWillAppear =>
      'Makita dinhi ang imong naluwas nga mga transaksyon ug aktibidad sa tag-iya.';

  @override
  String get searchAccountRefParty => 'Pangita pinaagi sa account, ref no.';

  @override
  String get beginningDate => 'Gikan sa petsa';

  @override
  String get endDate => 'Hangtod sa petsa';

  @override
  String get filterBeginDate => 'I-filter gikan sa petsa';

  @override
  String get filterEndDate => 'I-filter hangtod sa petsa';

  @override
  String get gcash => 'GCash';

  @override
  String get maya => 'Maya';

  @override
  String get onHand => 'Cash on hand';

  @override
  String get pdf => 'PDF';

  @override
  String get excel => 'Excel';

  @override
  String get generate => 'Gumawa';

  @override
  String get close => 'Isira';

  @override
  String get selectBeginningDate => 'Pilia ang gikan sa petsa';

  @override
  String get selectEndDate => 'Pilia ang hangtod sa petsa';

  @override
  String get generalLedgerReport => 'Taho sa General Ledger';

  @override
  String get generalLedgerReportDescription =>
      'Pilia ang sakop sa petsa, dayon pagpili ug PDF o Excel nga output.';

  @override
  String get fileFormat => 'Pormat sa file';

  @override
  String get endDateValidationMessage =>
      'Ang hangtod sa petsa kinahanglan pareho o mas ulahi kaysa gikan sa petsa.';

  @override
  String get preparingReport => 'Ginaandam ang taho...';

  @override
  String get noLedgerRecordsForDateRange =>
      'Walay ledger record alang sa napiling sakop sa petsa.';

  @override
  String get reportGenerationCanceled =>
      'Nakansela ang paghimo sa taho. Walay napiling folder.';

  @override
  String get generatingReport => 'Ginahimo ang taho...';

  @override
  String get reportShareUnavailable =>
      'Nahimo ang taho, pero dili available ang pag-share sa kini nga device. Naluwas ang file sa lokal.';

  @override
  String get reportGenerationFailed =>
      'Napakyas ang paghimo sa taho. Palihog sulayi pag-usab.';

  @override
  String reportSavedTo(String path) {
    return 'Malampuson nga nahimo ang taho. Naluwas sa $path';
  }

  @override
  String get walletHistoryReport => 'Taho sa Kasaysayan sa Wallet';

  @override
  String get walletHistorySheetName => 'Kasaysayan sa Wallet';

  @override
  String get walletFlowReport => 'Daloy sa Wallet';

  @override
  String get walletFlowSheetName => 'Daloy sa Wallet';

  @override
  String get periodLabel => 'Sakop';

  @override
  String get generatedLabel => 'Nahimo niadtong';

  @override
  String get legendTitle => 'Paspas nga giya';

  @override
  String get legendPlusMinus => 'Gamita ang + kung nisaka ug - kung niubos.';

  @override
  String get legendAmountShownNote =>
      'Ang kantidad parehas sa history. Sa cash out, posible nga apil na ang bayad.';

  @override
  String get reportDateTimeLabel => 'Petsa/Oras';

  @override
  String get reportTypeLabel => 'Klase';

  @override
  String get reportAmountLabel => 'Gipakitang kantidad';

  @override
  String get reportFeeLabel => 'Bayad';

  @override
  String get reportWalletDeltaLabel => 'Kausaban sa wallet';

  @override
  String get reportCashDeltaLabel => 'Kausaban sa cash';

  @override
  String get reportReferenceLabel => 'Ref #';

  @override
  String get reportDetailsLabel => 'Detalye';

  @override
  String get dateTimeLabel => 'Petsa ug Oras';

  @override
  String get walletUsedLabel => 'Wallet';

  @override
  String get amountShownLabel => 'Kantidad sa History';

  @override
  String get descriptionLabel => 'Deskripsyon';

  @override
  String get remarksLabel => 'Mga Pahimangno';

  @override
  String get moneyInLabel => 'Pera Sulod';

  @override
  String get moneyOutLabel => 'Pera Gawas';

  @override
  String get feeDetailsLabel => 'Detalye sa Bayad';

  @override
  String get balanceLabel => 'Balanse';

  @override
  String get totalsLabel => 'MGA TOTAL';

  @override
  String get gcashMovementLabel => 'Kausaban sa GCash';

  @override
  String get mayaMovementLabel => 'Kausaban sa Maya';

  @override
  String get cashOnHandMovementLabel => 'Kausaban sa Cash';

  @override
  String get feesRoutedLabel => 'Giadtoan sa Bayad';

  @override
  String get totalMoneyInLabel => 'Kinatibuk-ang Pera Sulod';

  @override
  String get totalMoneyOutLabel => 'Kinatibuk-ang Pera Gawas';

  @override
  String get netBalanceLabel => 'Netong Balanse';

  @override
  String get totalFeesPaidLabel => 'Kinatibuk-ang Bayad';

  @override
  String get chooseFolder => 'Pilia ang folder alang sa taho sa General Ledger';

  @override
  String get chargesManagement => 'I-setup ang Bayad';

  @override
  String get setServiceFeeBrackets =>
      'Pamahalaan ang presyo para sa lahat ng serbisyo';

  @override
  String get configureFeesFor => 'Nag-setup ng bayad para sa:';

  @override
  String get gcashWalletOption => 'GCash';

  @override
  String get mayaWalletOption => 'Maya';

  @override
  String get addNewBracket => 'Magdugang ug Bag-ong Tier';

  @override
  String get lowerBound => 'Simula ng Halaga (PHP)';

  @override
  String get lowerBoundHint => 'ex. 1000';

  @override
  String get upperBound => 'Katapusan ng Halaga (PHP)';

  @override
  String get upperBoundHint => 'ex. 1500';

  @override
  String get chargeAmount => 'Kantidad sa Bayad (PHP)';

  @override
  String get chargeAmountHint => 'ex. 25.00';

  @override
  String get backToTransaction => 'Balik sa Transaksyon';

  @override
  String get openMenu => 'Ablihan ang menu';

  @override
  String get dailyEarningsTrend => 'Adlaw-adlaw nga Trend sa Kita';

  @override
  String get goBack => 'Balik';

  @override
  String get serviceCashIn => 'Cash-In';

  @override
  String get serviceCashOut => 'Cash-Out';

  @override
  String get serviceLoad => 'Load';

  @override
  String get servicePayBills => 'Bayad Bills';

  @override
  String get serviceQrPayment => 'QR Payment';

  @override
  String selectFeeType(String type) {
    return 'Pilia ang klase sa bayad: $type';
  }

  @override
  String get selectWalletAndTransactionType =>
      'Pilia ang wallet ug klase sa transaksyon';

  @override
  String feePreview(String from, String fee) {
    return 'Preview: ₱$from → Bayad ₱$fee';
  }

  @override
  String get startingAmountLabel => 'Sugod nga Kantidad';

  @override
  String get endingAmountLabel => 'Kataposang Kantidad';

  @override
  String get feeAmountLabel => 'Kantidad sa Bayad';

  @override
  String totalTiers(String count) {
    return 'Total: $count ka tier';
  }

  @override
  String get smallTransactions => 'Gagmay nga Transaksyon';

  @override
  String get mediumTransactions => 'Tunga-tunga nga Transaksyon';

  @override
  String get largeTransactions => 'Dagko nga Transaksyon';

  @override
  String get availableForTransactions => '(Magamit alang sa mga transaksyon)';

  @override
  String get chargeInputInvalid =>
      'Isulod ang sakto nga sugod, katapusan, ug kantidad sa bayad.';

  @override
  String get chargeBracketAdded => 'Nadugang ang charge bracket.';

  @override
  String get chargeBracketDeleted => 'Natangtang ang charge bracket.';

  @override
  String get unableToDeleteBracket => 'Dili matangtang ang bracket.';

  @override
  String get deleteBracketTitle => 'Tangtanga ang Bracket';

  @override
  String deleteBracketMessage(String lower, String upper) {
    return 'Tangtangon ang charge range nga ₱$lower–₱$upper? Dili na kini mabawi.';
  }

  @override
  String get editChargeBracketTitle => 'Usba ang Charge Bracket';

  @override
  String get editChargeBracketHint =>
      'Usba ang eksaktong sugod ug katapusan sa kini nga charge range.';

  @override
  String get saveChanges => 'I-save ang mga Kausaban';

  @override
  String get chargeErrorOverlapRange =>
      'Nag-overlap kini nga range sa existing nga charge bracket para ani nga klase.';

  @override
  String get chargeErrorUpdateTargetMissing =>
      'Dili ma-update ang napiling bracket.';

  @override
  String get chargeErrorLowerBoundNonPositive =>
      'Ang sugod nga kantidad kinahanglan mas dako sa zero.';

  @override
  String get chargeErrorUpperBoundTooSmall =>
      'Ang kataposang kantidad kinahanglan mas dako o kapareho sa sugod nga kantidad.';

  @override
  String get chargeErrorNegative => 'Ang bayad dili pwede nga negatibo.';

  @override
  String chargeErrorTooHigh(String max, String upper) {
    return 'Ang bayad dili pwede molapas sa 50% sa upper bound (max ₱$max para sa upper bound nga ₱$upper).';
  }

  @override
  String get activeTiers => 'Active Fee Tiers';

  @override
  String get feeTierOverview => 'Tier Overview';

  @override
  String get switchService => 'Switch Service';

  @override
  String tierName(String number, String description) {
    return 'Tier $number: $description';
  }

  @override
  String feeAmount(String amount) {
    return 'Fee: ₱$amount';
  }

  @override
  String tierStatus(String status) {
    return 'Status: $status';
  }

  @override
  String usedXTimes(String count) {
    return '$count transactions used';
  }

  @override
  String get simpleMode => 'Simple Mode';

  @override
  String get advancedMode => 'Advanced Mode';

  @override
  String get whatTheseFieldsMean => 'What do these fields mean?';

  @override
  String get startingAmountHelp =>
      'The lowest transaction amount that this fee applies to';

  @override
  String get endingAmountHelp =>
      'The highest transaction amount that this fee applies to';

  @override
  String get feeAmountHelp =>
      'How much you earn from each transaction in this range';

  @override
  String get exampleTransactionText =>
      'Example: If ₱1,500 is sent, and your tier is ₱1,000-₱2,000 with fee ₱50, you earn ₱50.';

  @override
  String get noFeeTiersTitle => 'No Fee Tiers Configured Yet';

  @override
  String get noFeeTiersMessage =>
      'Start earning immediately by setting up your first fee structure.';

  @override
  String lastUsed(String time) {
    return 'Last used: $time';
  }

  @override
  String get registeredParties => 'Imong Mga Tao';

  @override
  String get yourPeople => 'Imong Mga Tao';

  @override
  String get manageParties =>
      'Dumala ang mga customer ug partner nga ka-transaksyon nimo';

  @override
  String get manageCustomersPartners =>
      'Dumala ang mga customer ug partner nga ka-transaksyon nimo';

  @override
  String get searchByNameAccount =>
      'Pangitaa gamit ang ngalan o account number...';

  @override
  String get activeEntities => 'Paspas nga Summary';

  @override
  String get addParty => 'Dugang Tao';

  @override
  String get addNewPerson => 'Dugang Tao';

  @override
  String get noMatchingParties => 'Walay tao nga nagtugma sa imong pagpangita';

  @override
  String get tryDifferentKeyword => 'Sulayi ang laing ngalan o account number';

  @override
  String get noPartiesSaved => 'Wala pay tao dinhi';

  @override
  String get localDatabaseInfo =>
      'Wala pay sulod ang imong listahan. Pagdugang sa unang customer o business partner.';

  @override
  String get deleteParty => 'Tangtanga ang Tao';

  @override
  String deletePartyConfirm(String name) {
    return 'Sigurado ka ba nga gusto nimo tangtangon si $name? Dili na kini mabawi.';
  }

  @override
  String get peopleSaved => 'ka tawo nga nasave';

  @override
  String get verified => 'Beripikado';

  @override
  String get waitingToVerify => 'naghulat ma-beripika';

  @override
  String get verificationStatus => 'Status sa Beripikasyon';

  @override
  String get statusVerified => 'Beripikado';

  @override
  String get statusPending => 'Naghulat sa Beripikasyon';

  @override
  String joinedDate(String date) {
    return 'Miapil niadtong $date';
  }

  @override
  String theirAccount(String account) {
    return 'Account: $account';
  }

  @override
  String get viewHistory => 'Tan-awa ang History';

  @override
  String get allPeople => 'Tanang Tao';

  @override
  String get pendingPeople => 'Naghulat';

  @override
  String get nobodyHereYet => 'Wala pay tao dinhi';

  @override
  String get letAddFirst =>
      'Wala pay sulod ang imong listahan. Pagdugang sa unang customer o business partner.';

  @override
  String get show => 'Ipakita';

  @override
  String get sort => 'Ihan-ay';

  @override
  String get newest => 'Pinakabag-o';

  @override
  String get oldest => 'Pinakaluma';

  @override
  String get all => 'Tanan';

  @override
  String get active => 'Aktibo';

  @override
  String get pending => 'Naghulat';

  @override
  String get partiesManagement => 'Pagdumala sa mga Tao';

  @override
  String get lastUpdated => 'Katapusang Update';

  @override
  String get total => 'Total';

  @override
  String get account => 'Account';

  @override
  String get status => 'Status';

  @override
  String get edit => 'Usba';

  @override
  String get history => 'History';

  @override
  String get name => 'Ngalan';

  @override
  String get backupSync => 'I-backup ug I-sync';

  @override
  String get serverConnection => 'Koneksyon sa Server';

  @override
  String get serverUrlInstruction =>
      'Isulat ang base URL sa imong Tinda Tracker server. Gamiton ang imong lokal nga IP (ex. http://192.168.1.24:8080/api) kung ang device ania sa parehas nga Wi-Fi sa imong computer.';

  @override
  String get serverApiUrl => 'URL sa Server API';

  @override
  String get serverApiUrlHint => 'http://192.168.1.x:8080/api';

  @override
  String get saveUrl => 'I-save ang URL';

  @override
  String get syncData => 'I-sync ang Data';

  @override
  String get syncInstruction =>
      'Itulod ang mga lokal nga pagbag-o sa server ug makuha ang mga update gikan sa ubang device.';

  @override
  String get syncing => 'Nag-si-sync…';

  @override
  String get syncNow => 'I-sync Karon';

  @override
  String get serverUrlSaved => 'Naluwas ang URL sa server.';

  @override
  String syncCompleted(int pushed, int pulled) {
    return 'Nahuman ang pag-sync — gitulod ang $pushed, gikuha ang $pulled.';
  }

  @override
  String syncFailed(Object error) {
    return 'Napakyas ang pag-sync: $error';
  }

  @override
  String get localBackup => 'Lokal nga Backup';

  @override
  String get exportBackup => 'I-export ang Backup';

  @override
  String get restoreBackup => 'I-restore ang Backup';

  @override
  String get aboutPocketLedger => 'Mahitungod sa PocketLedger';

  @override
  String get pocketLedgerDescription =>
      'Gitabangan ka sa PocketLedger nga sundan ang mga transaksyon, lihok sa tag-iya, ug daloy sa kwarta sa negosyo sa usa ka lugar.';

  @override
  String get version => 'Bersyon 1.0.0';

  @override
  String get buildInfo => 'Para sa Android, iOS, ug desktop nga platform';

  @override
  String get yourProfile => 'Imong Profile';

  @override
  String get profileDescription =>
      'Itakda ang imong display name, impormasyon sa kontak, ug mga setting sa pagkaila sa negosyo.';

  @override
  String get quickNavigation => 'Dali nga Nabigasyon';

  @override
  String get backupData => 'I-backup ang Data';

  @override
  String get profile => 'Profile';

  @override
  String get aboutApp => 'Mahitungod sa App';

  @override
  String get changeLanguage => 'Usba ang Pinulongan';

  @override
  String get recordOwnerMovementFab => 'Irekord ang Entry sa Kwarta';

  @override
  String get transaction => 'Transaksyon';

  @override
  String get languageEnglish => 'Iningles';

  @override
  String get languageFilipino => 'Filipino';

  @override
  String get languageCebuano => 'Cebuano';

  @override
  String get selectLanguage => 'Pilia ang Pinulongan';

  @override
  String get totalFunds => 'KARONG BUSINESS CASH';

  @override
  String get recentActivities => 'Bag-ong mga Aktibidad';

  @override
  String get filterAll => 'Tanan';

  @override
  String get filterBusiness => 'Negosyo';

  @override
  String get filterPersonal => 'Personal';

  @override
  String get filterTransactions => 'Mga Transaksyon';

  @override
  String get noActivitiesFilter =>
      'Walay aktibidad nga katugma sa gipiling filter.';

  @override
  String ownerCreditOutstanding(String amount) {
    return 'Nahibilin nga Utang sa Tag-iya: $amount';
  }

  @override
  String get walletTrendPlaceholder =>
      'Makita ang trend data kung adunay narekord na aktibidad sa pitaka.';

  @override
  String businessCashBreakdown(String wallets, String cash, String credit) {
    return 'Mga Wallet $wallets + Cash sa kamot $cash + Kredito sa tag-iya $credit';
  }

  @override
  String get businessCashComputation => 'Magamit karon para sa business use';

  @override
  String withdrawableEarningsNote(String amount) {
    return 'Withdrawable nga kita karon: $amount';
  }

  @override
  String get inventory => 'Imbentaryo';

  @override
  String get addProduct => 'Magdugang og Produkto';

  @override
  String get editProduct => 'I-edit ang Produkto';

  @override
  String get updateProduct => 'I-update ang Produkto';

  @override
  String get products => 'Mga Produkto';

  @override
  String get totalStock => 'Kinatibuk-ang Stock';

  @override
  String get lowStock => 'Ubos na Stock';

  @override
  String get outOfStock => 'Wala nay Stock';

  @override
  String get noProducts => 'Wala pay mga produkto.';

  @override
  String get searchProductHint => 'Pangita pinaagi sa ngalan o barcode...';

  @override
  String get archiveProductTitle => 'I-archive kini nga Produkto?';

  @override
  String archiveProductMessage(String name) {
    return 'Ang \"$name\" matago gikan sa lista. Mahimong ibalik kini sa ulahi.';
  }

  @override
  String archiveBulkTitle(int count) {
    return 'I-archive ang $count ka produkto?';
  }

  @override
  String get archive => 'I-archive';

  @override
  String get archiveProduct => 'I-archive ang Produkto';

  @override
  String get no => 'Dili';

  @override
  String get selectMultiple => 'Pili-on ang daghan';

  @override
  String nSelected(int count) {
    return '$count ang napili';
  }

  @override
  String nProducts(int count) {
    return '$count ka produkto';
  }

  @override
  String get adjustStock => 'Ayuhon ang Stock';

  @override
  String get stockHistory => 'Kasaysayan sa Stock';

  @override
  String get stock => 'Stock';

  @override
  String get currentStockLabel => 'Kasamtangang Stock';

  @override
  String get lowStockAlertStat => 'Pasidaan sa Ubos nga Stock';

  @override
  String get noStockHistory => 'Wala pay kasaysayan sa stock.';

  @override
  String get productInformation => 'Impormasyon sa Produkto';

  @override
  String get productName => 'Ngalan sa Produkto *';

  @override
  String get nameRequired => 'Kinahanglan ang ngalan';

  @override
  String get skuBarcode => 'SKU / Barcode *';

  @override
  String get skuRequired => 'Kinahanglan ang SKU/barcode';

  @override
  String get scanBarcode => 'I-scan ang Barcode';

  @override
  String get descriptionOptional => 'Paglalaragway (opsyonal)';

  @override
  String get category => 'Kategorya';

  @override
  String get unitLabel => 'Yunit';

  @override
  String get pricing => 'Presyo';

  @override
  String get costPrice => 'Gasto sa Pagpalit';

  @override
  String get sellingPrice => 'Presyo sa Pagbaligya *';

  @override
  String get fieldRequired => 'Kinahanglan';

  @override
  String get numbersOnly => 'Numero lang';

  @override
  String get initialStock => 'Sinugdanang Stock';

  @override
  String get useAdjustStockToChange => 'Gamita ang Ayuhon Stock aron mabag-o';

  @override
  String get lowStockAlert => 'Pasidaan sa Ubos nga Stock';

  @override
  String get activeLabel => 'Aktibo';

  @override
  String get activeHelperText => 'Makita sa lista ug POS';

  @override
  String get productAdded => 'Nadugang na ang produkto!';

  @override
  String get productUpdated => 'Na-update na ang produkto!';

  @override
  String get filters => 'Mga Filter';

  @override
  String get clearAll => 'I-clear tanan';

  @override
  String get stockAlerts => 'Mga Pasidaan sa Stock';

  @override
  String get lowStockOnly => 'Ubos nga Stock lamang';

  @override
  String get outOfStockOnly => 'Wala nay Stock lamang';

  @override
  String get noChange => 'Walay pagbag-o.';

  @override
  String get quickAdjust => 'Dali nga pagbag-o';

  @override
  String get reason => 'Hinungdan';

  @override
  String get saveStock => 'I-save ang Stock';

  @override
  String get manualAmount => 'Manwal nga kantidad (+ o -)';

  @override
  String get resetBtn => 'I-reset';

  @override
  String categoryAndUnit(String category, String unit) {
    return 'Kategorya: $category  |  $unit';
  }

  @override
  String get errEmptyCart => 'Walay butang sa cart.';

  @override
  String get errNegativePaidAmount => 'Dili pwede nga negatibo ang bayad.';

  @override
  String errUnitConversionNotSet(String unit, String product) {
    return 'Wala ma-set ang yunit conversion para sa yunit nga $unit sa produktong $product.';
  }

  @override
  String errEmptyRecipeIngredients(String product) {
    return 'Walay sangkap nga naka-set para sa recipe product: $product.';
  }

  @override
  String errInsufficientIngredientStock(
    String ingredient,
    String product,
    double needed,
    double available,
  ) {
    return 'Kulang ang stock sa sangkap nga $ingredient para sa recipe product: $product. Gikinahanglan: $needed, naa ra: $available.';
  }

  @override
  String errInsufficientProductStock(
    String product,
    double needed,
    double available,
  ) {
    return 'Kulang ang stock para sa $product. Gikinahanglan: $needed, naa ra: $available.';
  }

  @override
  String errSerialSelection(int required, String product, int selected) {
    return 'Kinahanglan mopili og eksaktong $required serial number(s) para sa $product. Kasamtangang napili: $selected.';
  }

  @override
  String errSerialNotAvailable(String serial) {
    return 'Ang serial number nga \"$serial\" dili magamit o nabaligya na.';
  }

  @override
  String errPaidAmountInsufficient(double paid, double total) {
    return 'Kulang ang bayad sa customer. Bayad: $paid, Total: $total.';
  }

  @override
  String get noIngredientsAvailable => 'Walay magamit nga sangkap';

  @override
  String get noIngredientsSet =>
      'Walay sangkap nga naka-set. Pagdugang og mga sangkap sa ubos.';

  @override
  String get noSerialsRegistered => 'Walay serial number nga narehistro.';

  @override
  String get noBarcodeRead => 'Walay barcode nga nabasahan. Sulayi pag-usab.';

  @override
  String noProductForBarcode(String code) {
    return 'Walay produkto nga na-link sa barcode nga \"$code\".';
  }

  @override
  String get addItemsFirst =>
      'Pagdugang og mga item sa cart sa dili pa mag-checkout.';

  @override
  String get cannotCheckoutNow =>
      'Dili makapadayon sa checkout karon. Palihog susiha pag-usab.';

  @override
  String get insufficientPayment =>
      'Kulang ang bayad. Palihog susiha pag-usab.';

  @override
  String checkoutFailed(String error) {
    return 'Napakyas ang checkout: $error';
  }

  @override
  String get failedToLoadProducts =>
      'Napakyas sa pag-load sa mga produkto. Palihog sulayi pag-usab.';

  @override
  String get noProductsFound => 'Walay nakit-an nga mga produkto.';

  @override
  String get lowStockWarningEditAllowed =>
      'Adunay mga item nga ubos ang stock. Pwede pa gihapon nimo kining usbon sa dili pa mag-checkout.';

  @override
  String get noSerialsAvailableForProduct =>
      'Walay magamit nga serial number para sa kini nga produkto.';

  @override
  String get noMatchingProducts => 'Walay nakit-an nga parehas nga produkto.';

  @override
  String get scanDuplicateWarning =>
      'Nabasahan na kini kaniadto lang. I-scan pag-usab human sa makadiyot.';

  @override
  String addedToQueue(String product) {
    return 'Nadugang sa queue: $product';
  }

  @override
  String saleCompleteWithChange(String change) {
    return 'Nahuman ang pagbaligya! Sukli: $change';
  }

  @override
  String selectSerialsRequired(int required, int selected) {
    return 'Pumili og eksaktong $required ka serial number(s). Napili: $selected';
  }

  @override
  String serialsLimitExceeded(int required) {
    return 'Limitado hangtod sa $required ka serials ra.';
  }

  @override
  String get continuousScan => 'Continuous scan';

  @override
  String get muteScanSound => 'I-mute ang tingog sa scan';

  @override
  String get enableScanSound => 'I-enable ang tingog sa scan';

  @override
  String get disableVibration => 'I-disable ang vibration';

  @override
  String get enableVibration => 'I-enable ang vibration';

  @override
  String get typeBarcodeManually => 'I-type ang barcode sa manwal';

  @override
  String get serialAlreadyAdded => 'Kining serial number gidugang na.';

  @override
  String stockMustMatchSerials(int stock, int count) {
    return 'Ang stock quantity ($stock) kinahanglan katumbas sa gidaghanon sa available serial numbers ($count).';
  }

  @override
  String get scanOrTypeSerial =>
      'Mag-scan o mag-type ug serial number aron idugang.';

  @override
  String get businessTypeRetail => 'Sari-Sari / Retail';

  @override
  String get businessTypeFoodService => 'Carinderia / Serbisyo sa Pagkaon';

  @override
  String get businessTypeAutoParts => 'Tindahan sa Piyesa / Serbisyo';

  @override
  String get businessTypeHardware => 'Tindahan sa Hardware';

  @override
  String get businessTypeMarketplace => 'Pwesto sa Merkado';

  @override
  String get businessTypeGeneral => 'Pangkalahatan / Uban pa';

  @override
  String get showPassword => 'Ipakita ang password';

  @override
  String get hidePassword => 'Itago ang password';

  @override
  String get usernameValidator =>
      'Ang username kinahanglan labing gamay 4 ka karakter ug letra o numero lamang';

  @override
  String get passwordValidator =>
      'Ang password kinahanglan labing gamay 6 ka karakter';

  @override
  String get authErrorConnection =>
      'Dili makakonektar sa server. Palihog susiha ang imong koneksyon sa internet.';

  @override
  String get authErrorTimeout =>
      'Na-timeout ang koneksyon. Palihog sulayi pag-usab sa laing higayon.';

  @override
  String get authErrorInvalidCredentials => 'Sayop nga username o password.';

  @override
  String get authErrorUsernameTaken =>
      'Kini nga username nakuha na. Palihog sulayi ang uban.';

  @override
  String get authErrorGeneric =>
      'Napakyas ang pag-authenticate. Palihog sulayi pag-usab.';

  @override
  String get tutorialWelcomeTitlePocketLedger =>
      'Maayong pag-abot sa PocketLedger!';

  @override
  String get tutorialWelcomeDescPocketLedger =>
      'Maghimo ta og dali nga 1-minuto nga tour aron makita kung unsaon pag-track ang imong cash drawer ug digital wallets (GCash/Maya) sa sayon nga paagi!';

  @override
  String get tutorialCashTitle => 'Kasalukuyang Kwarta sa Negosyo';

  @override
  String get tutorialCashDesc =>
      'Nagpakita kini sa kinatibuk-ang kwarta nga imong magamit sa pagpadagan sa imong tindahan. Gihiusa niini ang imong GCash, Maya, ug pisikal nga On-hand Cash, minus ang bisan unsang personal nga gasto nga imong gikuha.';

  @override
  String get tutorialWalletsTitle => 'GCash, Maya ug On-hand Cash';

  @override
  String get tutorialWalletsDesc =>
      'Ang GCash ug Maya mga digital nga kwarta sa imong telepono. Ang On-hand Cash mao ang pisikal nga kwarta sa imong drawer. Kung ang kustomer mobayad kanimo og cash para sa cash-in, ang imong GCash moubos apan ang imong cash drawer mosaka!';

  @override
  String get tutorialSampleTitlePocketLedger => 'Tan-awa Kini sa Aksyon!';

  @override
  String get tutorialSampleDescPocketLedger =>
      'Gusto ba nimo nga butangan og sample nga transaksyon (pananglitan: ₱100 GCash Cash-In nga adunay ₱10 nga fee) aron makita kung giunsa ang dashboard, mga tsart, ug nakolekta nga mga bayranan nga mo-update dayon?';

  @override
  String get addSampleDataButton => 'Idugang ang Sample nga Transaksyon';

  @override
  String get startEmptyButton => 'Sugod nga Walay Sulod';

  @override
  String get nextButton => 'Sunod';

  @override
  String get skipButton => 'Laktawan';
}
