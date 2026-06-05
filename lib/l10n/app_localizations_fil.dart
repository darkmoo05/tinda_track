// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appTitle => 'PocketLedger';

  @override
  String get syncingData => 'Sine-sync ang iyong data…';

  @override
  String get walletOverview => 'Pangkalahatang-tanaw ng Pitaka';

  @override
  String get gcashWallet => 'GCash Wallet';

  @override
  String get mayaWallet => 'Maya Wallet';

  @override
  String get onHandCash => 'Cash sa Kamay';

  @override
  String get chargesEarnings => 'Kita sa Bayad';

  @override
  String get availableBalance => 'Magagamit na balanse';

  @override
  String get physicalCash => 'Pisikal na pera';

  @override
  String get walletCashBalanceTrend => 'Trend ng Pitaka at Pera';

  @override
  String get borrowed => 'Hiniram';

  @override
  String get repaid => 'Nabayaran';

  @override
  String get totalPersonalFundsTaken => 'Kabuuang personal na pondo ng may-ari';

  @override
  String get totalPersonalFundsReturned =>
      'Kabuuang pondo na ibinalik sa negosyo';

  @override
  String get unableToLoadDashboard => 'Hindi ma-load ang dashboard ngayon.';

  @override
  String get noDashboardData => 'Wala pang data sa dashboard.';

  @override
  String get newEntry => 'Bagong Entry';

  @override
  String get recordTransaction => 'I-rekord ang Transaksyon';

  @override
  String get transactionTypeLabel => 'Uri ng Transaksyon';

  @override
  String get accountNumber => 'Recipient Account';

  @override
  String get searchOrEnterAccountNumber => 'Numero';

  @override
  String get scanningReceipt => 'Nini-scan ang resibo…';

  @override
  String get scanningReceiptModalMessage =>
      'Binabasa ang larawan at pini-parse ang data ng resibo...';

  @override
  String get scanReceiptButton => 'I-scan ang Resibo (Camera/Gallery)';

  @override
  String get transactionAmount => 'Halaga ng Transaksyon';

  @override
  String get amountHint => '0.00';

  @override
  String get reference => 'Sanggunian';

  @override
  String get enterReferenceNumber => 'Ilagay ang numero ng resibo / sanggunian';

  @override
  String get notes => 'Tala';

  @override
  String get optionalNotes => 'Opsyonal na tala...';

  @override
  String get useCamera => 'Gumamit ng Camera';

  @override
  String get takePicture => 'Kumuha ng larawan ng resibo';

  @override
  String get pickFromGallery => 'Pumili mula sa Gallery';

  @override
  String get chooseExistingPhoto => 'Pumili ng screenshot/larawan';

  @override
  String get browseFiles => 'Mag-browse ng Files';

  @override
  String get pickFromAnyFolder => 'Pumili mula sa kahit saang folder';

  @override
  String get receiptScanResult => 'Resulta ng Pag-scan';

  @override
  String get receiptScanDescription => 'Narito ang nahanap sa inyong resibo:';

  @override
  String get amount => 'Halaga';

  @override
  String get accountName => 'Account / Pangalan';

  @override
  String get accountId => 'Account / ID';

  @override
  String get referenceNo => 'Blg. ng Sanggunian';

  @override
  String get walletLabel => 'Pitaka';

  @override
  String get noRecognizableData => 'Walang nakilalang data sa resibong ito.';

  @override
  String get noteWillBeAdded => 'Tala na idadagdag:';

  @override
  String get reviewAndEdit => 'Suriin at i-edit ang mga field bago i-save.';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get apply => 'Ilapat';

  @override
  String get customerPaysFee => 'Nagbabayad ng Bayad ang Customer';

  @override
  String get deductFeeFromSent => 'Ibawas ang Bayad mula sa Halagang Ipinadala';

  @override
  String get goToCharges => 'Pumunta sa Charges';

  @override
  String get searchNameOrAccount => 'Maghanap ng pangalan o numero ng account';

  @override
  String get noContactsFound => 'Walang nahanap na contact';

  @override
  String get noMatchingContact => 'Walang katugmang contact';

  @override
  String get fullNameEntity => 'Buong Pangalan / Entity';

  @override
  String get enterPartyFullName => 'Ilagay ang buong pangalan ng partido';

  @override
  String get enterAccountNumber => 'Ilagay ang numero ng account';

  @override
  String get searchContacts => 'Maghanap ng contacts';

  @override
  String get saving => 'Sine-save…';

  @override
  String get registerParty => 'I-register ang Partido';

  @override
  String get partyRegisteredSaving =>
      'Nairehistro ang partido. Sine-save na ang transaksyon...';

  @override
  String get unableToVerifyRegistration =>
      'Hindi ma-verify ang pagpaparehistro. Subukan muli.';

  @override
  String get unableToSaveTransaction =>
      'Hindi ma-save ang transaksyon. Subukan muli.';

  @override
  String transactionSaved(String name) {
    return 'Nai-save ang transaksyon para kay $name.';
  }

  @override
  String selectService(String service) {
    return 'Piliin ang serbisyo: $service';
  }

  @override
  String get customerReceives => 'Tumatanggap ang Customer';

  @override
  String get customerSends => 'Nagpapadala ang Customer';

  @override
  String get recordTransactionDetails => 'Setup ng Transaksyon';

  @override
  String get optionalDetailsSection =>
      'Magdagdag ng Reference o Notes (Opsyonal)';

  @override
  String get reviewTotals => 'Breakdown ng Halaga';

  @override
  String get showDetails => 'Ipakita ang detalye';

  @override
  String get hideDetails => 'Itago ang detalye';

  @override
  String get whoPaysServiceFee => 'Fee Handling';

  @override
  String get customerPaysFeeLabel => 'Customer ang nagbabayad ng fee';

  @override
  String get deductedFromSentLabel => 'Isama sa halaga';

  @override
  String get usingWallet => 'Gamit na wallet';

  @override
  String get serviceFee => 'Bayad na dapat bayaran';

  @override
  String get feeDestination => 'Ipinapadala ang fee sa';

  @override
  String get feeRange => 'Saklaw ng fee';

  @override
  String get amountSentToCustomerWallet => 'Halaga ng Customer';

  @override
  String get amountCustomerSends => 'Halagang ipinapadala ng customer';

  @override
  String get customerPays => 'Babayaran ng customer';

  @override
  String get cashPaidOut => 'Cash na ibibigay';

  @override
  String get cashAddedToDrawer => 'Sa Inyong Drawer';

  @override
  String get feeAddedExample =>
      'Idinadagdag sa itaas ang service fee. Halimbawa: ₱100 transaksyon + ₱5 fee = kokolektahin ang ₱105 sa customer, ipapadala ang ₱100.';

  @override
  String get feeDeductedExample =>
      'Ibinabawas muna ang service fee bago magpadala. Halimbawa: ₱100 ang inilagay, ₱5 fee ang ibinawas = ₱95 lang ang mapupunta sa wallet ng customer.';

  @override
  String get accountNotInContacts =>
      'Wala pa sa contacts ang account na ito. I-tap dito para idagdag bago mag-save.';

  @override
  String get saveTransactionAction => 'I-record ang Transaksyon';

  @override
  String get walletAndService => 'Uri ng Transaksyon (Kailangan)';

  @override
  String verifiedAccountFound(String name) {
    return '$name - May napatunayang account record';
  }

  @override
  String get onHandCashLabel => 'Cash sa kamay';

  @override
  String get cashPaidOutTooltip =>
      'Cash na ibinibigay mo sa customer mula sa drawer.';

  @override
  String get cashAddedToDrawerTooltip =>
      'Cash na napupunta sa drawer mo pagkatapos ng transaksyong ito.';

  @override
  String get noFeeRuleForAmount =>
      'Wala pang fee rule para sa halagang ito. Ang fee ay ₱0. Magdagdag muna ng fee rule.';

  @override
  String get receiptDataAppliedReview =>
      'Na-apply ang data mula sa resibo. Suriin muna bago i-save.';

  @override
  String get noFeeRangeFoundTitle => 'Walang fee range na nahanap';

  @override
  String get noFeeRangeFoundMessage =>
      'Ang inilagay na halaga ay hindi pasok sa anumang fee range. Gumawa muna ng bagong fee range.';

  @override
  String get accountNumberRequiredBeforeSaving =>
      'Kailangan ang numero ng account bago mag-save.';

  @override
  String get transactionAmountRequiredBeforeSaving =>
      'Kailangan ang halaga ng transaksyon bago mag-save.';

  @override
  String get noFeeRangeFoundForAmount =>
      'Walang fee range para sa halagang ito. Gumawa muna ng bagong range.';

  @override
  String get amountToSendMustBeGreaterThanZero =>
      'Ang halagang ipapadala ay dapat mas mataas sa zero. Ayusin ang halaga o fee setting.';

  @override
  String insufficientBalance(String source, String amount) {
    return 'Kulang ang balanse sa $source. Available: ₱ $amount';
  }

  @override
  String get partyNotRegisteredYet =>
      'Hindi pa rehistrado ang party. Irehistro muna ang detalye.';

  @override
  String transactionSavedSyncRetry(String name) {
    return 'Nai-save ang transaksyon para kay $name. Susubukan ulit ang backend sync.';
  }

  @override
  String get amountMustBeGreaterThanZero =>
      'Ang halaga ay dapat mas mataas sa 0';

  @override
  String feeValidationFailedStatus(String status, String message) {
    return 'Nabigo ang fee validation$status: $message';
  }

  @override
  String feeValidationFailed(String error) {
    return 'Nabigo ang fee validation: $error';
  }

  @override
  String get backendPreviewUnavailable => 'Hindi available ang backend preview';

  @override
  String get unableToValidateFeePreviewNow =>
      'Hindi ma-validate ang fee preview mula sa backend ngayon.';

  @override
  String get saveLocally => 'I-save lokal';

  @override
  String get feeBreakdownTitle => 'Breakdown ng fee';

  @override
  String get charge => 'Bayad';

  @override
  String get totalCollected => 'Kabuuang nakolekta';

  @override
  String get walletCredit => 'Credit sa wallet';

  @override
  String get onHandChange => 'Pagbabago sa cash sa kamay';

  @override
  String get feeRouting => 'Saan napupunta ang fee';

  @override
  String get confirmAndSave => 'Kumpirmahin at i-save';

  @override
  String get selectRegisteredContact => 'Pumili ng nakarehistrong contact';

  @override
  String get registerPartyFirstThenSearch =>
      'Magrehistro muna ng party, saka gumamit ng search para pumili ng account.';

  @override
  String get tryDifferentNameOrAccount =>
      'Subukang maghanap gamit ang ibang pangalan o numero ng account.';

  @override
  String accountWithNumber(String number) {
    return 'Account: $number';
  }

  @override
  String get completeNameAndAccount =>
      'Pakikumpleto ang buong pangalan at numero ng account.';

  @override
  String get unableToSaveParty => 'Hindi ma-save ang party. Subukan muli.';

  @override
  String get accountAlreadyRegistered => 'Rehistrado na ang account.';

  @override
  String get partyRegistrationTitle => 'Pagrehistro ng Party';

  @override
  String get defineFinancialEntityBeforeTransaction =>
      'Maglagay muna ng bagong financial entity bago i-record ang transaksyon.';

  @override
  String get loadService => 'Load';

  @override
  String get payBillsService => 'Magbayad ng Bills';

  @override
  String get qrPaymentService => 'QR Payment';

  @override
  String get stepOneChooseWallet => 'Hakbang 1: Piliin ang wallet';

  @override
  String get pickWalletHelper =>
      'Ang mga wallet button ay para pumili ng account na gagamitin.';

  @override
  String get stepTwoChooseService => 'Hakbang 2: Piliin ang serbisyo';

  @override
  String get pickServiceHelper =>
      'Ang mga service button ay para pumili ng uri ng transaksyon.';

  @override
  String selectedWalletService(String wallet, String service) {
    return 'Napili: $wallet • $service';
  }

  @override
  String get newOwnerMovement => 'Bagong Talaan ng Pera';

  @override
  String get recordOwnerMovement => 'Mag-record ng Entry sa Pera';

  @override
  String get phase3Description =>
      'Subaybayan ang perang idinagdag, kinuha, o hiniram mula sa mga business wallet mo.';

  @override
  String get movementType => 'Ano ang ginawa mo?';

  @override
  String get chooseMovementType => 'Piliin kung ano ang nangyari';

  @override
  String get moneyDirection => 'Ano ang epekto nito';

  @override
  String get cashIn => 'Pasok ng Cash';

  @override
  String get cashOut => 'Labas ng Cash';

  @override
  String get borrowFrom => 'Humiram Mula sa';

  @override
  String get repayTo => 'Bayaran sa';

  @override
  String get destination => 'Patutunguhan';

  @override
  String get sourceAccount => 'Kinuha mula sa';

  @override
  String get personal => 'Personal';

  @override
  String get business => 'Negosyo';

  @override
  String get expenseCategory => 'Kategorya ng Gastos';

  @override
  String get add => 'Dagdagan';

  @override
  String get manage => 'Pamahalaan';

  @override
  String get addCategoryFirst =>
      'Magdagdag muna ng kategorya ng gastos (hal. Pagkain, Pamasahe).';

  @override
  String get chooseExpenseCategory => 'Pumili ng Kategorya ng Gastos';

  @override
  String get referenceOptional => 'Sanggunian (Opsyonal)';

  @override
  String get notesOptional => 'Tala (Opsyonal)';

  @override
  String get additionalDetails => 'Karagdagang detalye...';

  @override
  String get categoryName => 'Pangalan ng kategorya';

  @override
  String get renameCategory => 'Palitan ang Pangalan ng Kategorya';

  @override
  String get addCategory => 'Magdagdag ng Kategorya';

  @override
  String get save => 'I-save';

  @override
  String get done => 'Tapos';

  @override
  String get existingCategories => 'Mga Umiiral na Kategorya';

  @override
  String get rename => 'Palitan';

  @override
  String get delete => 'Burahin';

  @override
  String get categoryDeleted => 'Nabura ang kategorya.';

  @override
  String get enterCategoryName => 'Ilagay ang pangalan ng kategorya.';

  @override
  String get movementTypePending => 'Wala pang napiling uri';

  @override
  String get categoryPending => 'Wala pang napiling kategorya';

  @override
  String get movements => 'Kasaysayan ng Wallet';

  @override
  String get walletHistorySubtitle =>
      'Subaybayan ang galaw ng GCash, Maya, at cash.';

  @override
  String get reports => 'I-download ang Ulat';

  @override
  String get transactions => 'Mga Transaksyon';

  @override
  String get ownerMovements => 'Aktibidad ng May-ari';

  @override
  String get historyTransactionLabel => 'Transaksyon';

  @override
  String get historyOwnerActivityLabel => 'Aktibidad ng May-ari';

  @override
  String get historyTypeLabel => 'Uri';

  @override
  String get historyCategoryLabel => 'Kategorya';

  @override
  String get historyAccountLabel => 'Account';

  @override
  String get historyAmountShownLabel => 'Ipinakitang halaga';

  @override
  String get walletChangeLabel => 'Pagbabago sa wallet';

  @override
  String get cashChangeLabel => 'Pagbabago sa cash';

  @override
  String get savedOnLabel => 'Na-save noong';

  @override
  String get transactionBreakdown => 'Breakdown ng Transaksyon';

  @override
  String get entryDetails => 'Detalye ng Entry';

  @override
  String includesFee(String amount) {
    return 'Kasama ang bayad: $amount';
  }

  @override
  String get today => 'Ngayon';

  @override
  String get yesterday => 'Kahapon';

  @override
  String get noMatchingTransactions => 'Walang nahanap na resulta';

  @override
  String get trySearchingBy =>
      'Subukang baguhin ang wallet, petsa, o paghahanap.';

  @override
  String get noHistoryYet => 'Wala pang kasaysayan';

  @override
  String get newEntriesWillAppear =>
      'Lalabas dito ang mga nai-save mong transaksyon at aktibidad ng may-ari.';

  @override
  String get searchAccountRefParty =>
      'Maghanap ayon sa account, ref no., o tala';

  @override
  String get beginningDate => 'Mula petsa';

  @override
  String get endDate => 'Hanggang petsa';

  @override
  String get filterBeginDate => 'Salain mula petsa';

  @override
  String get filterEndDate => 'Salain hanggang petsa';

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
  String get close => 'Isara';

  @override
  String get selectBeginningDate => 'Piliin ang mula petsa';

  @override
  String get selectEndDate => 'Piliin ang hanggang petsa';

  @override
  String get generalLedgerReport => 'Ulat ng General Ledger';

  @override
  String get generalLedgerReportDescription =>
      'Pumili ng saklaw ng petsa, pagkatapos ay pumili ng PDF o Excel na output.';

  @override
  String get fileFormat => 'Format ng file';

  @override
  String get endDateValidationMessage =>
      'Ang hanggang petsa ay dapat kapareho o mas huli kaysa mula petsa.';

  @override
  String get preparingReport => 'Inihahanda ang ulat...';

  @override
  String get noLedgerRecordsForDateRange =>
      'Walang ledger record para sa napiling saklaw ng petsa.';

  @override
  String get reportGenerationCanceled =>
      'Kinansela ang paggawa ng ulat. Walang napiling folder.';

  @override
  String get generatingReport => 'Ginagawa ang ulat...';

  @override
  String get reportShareUnavailable =>
      'Nagawa ang ulat, pero hindi available ang pag-share sa device na ito. Nai-save ang file nang lokal.';

  @override
  String get reportGenerationFailed =>
      'Hindi nagawa ang ulat. Pakisubukang muli.';

  @override
  String reportSavedTo(String path) {
    return 'Matagumpay na nagawa ang ulat. Nai-save sa $path';
  }

  @override
  String get walletHistoryReport => 'Ulat ng Kasaysayan ng Wallet';

  @override
  String get walletHistorySheetName => 'Kasaysayan ng Wallet';

  @override
  String get walletFlowReport => 'Daloy ng Wallet';

  @override
  String get walletFlowSheetName => 'Daloy ng Wallet';

  @override
  String get periodLabel => 'Saklaw';

  @override
  String get generatedLabel => 'Ginawa noong';

  @override
  String get legendTitle => 'Mabilis na gabay';

  @override
  String get legendPlusMinus =>
      'Gamitin ang + para sa pagtaas at - para sa pagbaba.';

  @override
  String get legendAmountShownNote =>
      'Ang halaga ay kapareho ng history. Sa cash out, puwedeng kasama na ang bayad.';

  @override
  String get reportDateTimeLabel => 'Petsa/Oras';

  @override
  String get reportTypeLabel => 'Uri';

  @override
  String get reportAmountLabel => 'Ipinakitang halaga';

  @override
  String get reportFeeLabel => 'Bayad';

  @override
  String get reportWalletDeltaLabel => 'Pagbabago sa wallet';

  @override
  String get reportCashDeltaLabel => 'Pagbabago sa cash';

  @override
  String get reportReferenceLabel => 'Ref #';

  @override
  String get reportDetailsLabel => 'Detalye';

  @override
  String get dateTimeLabel => 'Petsa at Oras';

  @override
  String get walletUsedLabel => 'Wallet';

  @override
  String get amountShownLabel => 'Halaga sa History';

  @override
  String get descriptionLabel => 'Paglalarawan';

  @override
  String get remarksLabel => 'Puna';

  @override
  String get moneyInLabel => 'Pumasok na Pera';

  @override
  String get moneyOutLabel => 'Lumabas na Pera';

  @override
  String get feeDetailsLabel => 'Detalye ng Bayad';

  @override
  String get balanceLabel => 'Balanse';

  @override
  String get totalsLabel => 'MGA KABUUAN';

  @override
  String get gcashMovementLabel => 'Pagbabago sa GCash';

  @override
  String get mayaMovementLabel => 'Pagbabago sa Maya';

  @override
  String get cashOnHandMovementLabel => 'Pagbabago sa Cash';

  @override
  String get feesRoutedLabel => 'Pinuntahan ng Bayad';

  @override
  String get totalMoneyInLabel => 'Kabuuang Pumasok na Pera';

  @override
  String get totalMoneyOutLabel => 'Kabuuang Lumabas na Pera';

  @override
  String get netBalanceLabel => 'Netong Balanse';

  @override
  String get totalFeesPaidLabel => 'Kabuuang Bayad';

  @override
  String get chooseFolder => 'Pumili ng folder para sa ulat ng General Ledger';

  @override
  String get chargesManagement => 'Itakda ang Bayad';

  @override
  String get setServiceFeeBrackets =>
      'Pamahalaan ang presyo para sa lahat ng serbisyo';

  @override
  String get configureFeesFor => 'Nag-itakda ng bayad para sa:';

  @override
  String get gcashWalletOption => 'GCash';

  @override
  String get mayaWalletOption => 'Maya';

  @override
  String get addNewBracket => 'Magdagdag ng Bagong Tier';

  @override
  String get lowerBound => 'Simula ng Halaga (PHP)';

  @override
  String get lowerBoundHint => 'hal. 1000';

  @override
  String get upperBound => 'Katapusan ng Halaga (PHP)';

  @override
  String get upperBoundHint => 'hal. 1500';

  @override
  String get chargeAmount => 'Halaga ng Bayad (PHP)';

  @override
  String get chargeAmountHint => 'hal. 25.00';

  @override
  String get backToTransaction => 'Bumalik sa Transaksyon';

  @override
  String get openMenu => 'Buksan ang menu';

  @override
  String get dailyEarningsTrend => 'Pang-araw-araw na Trend ng Kita';

  @override
  String get goBack => 'Bumalik';

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
    return 'Piliin ang uri ng bayad: $type';
  }

  @override
  String get selectWalletAndTransactionType =>
      'Pumili ng wallet at uri ng transaksyon';

  @override
  String feePreview(String from, String fee) {
    return 'Preview: ₱$from → Bayad ₱$fee';
  }

  @override
  String get startingAmountLabel => 'Simulang Halaga';

  @override
  String get endingAmountLabel => 'Huling Halaga';

  @override
  String get feeAmountLabel => 'Halaga ng Bayad';

  @override
  String totalTiers(String count) {
    return 'Kabuuan: $count tier';
  }

  @override
  String get smallTransactions => 'Maliit na Transaksyon';

  @override
  String get mediumTransactions => 'Katamtamang Transaksyon';

  @override
  String get largeTransactions => 'Malaking Transaksyon';

  @override
  String get availableForTransactions => '(Available para sa transaksyon)';

  @override
  String get chargeInputInvalid =>
      'Maglagay ng tamang simula, katapusan, at halaga ng bayad.';

  @override
  String get chargeBracketAdded => 'Nadagdag ang charge bracket.';

  @override
  String get chargeBracketDeleted => 'Nabura ang charge bracket.';

  @override
  String get unableToDeleteBracket => 'Hindi mabura ang bracket.';

  @override
  String get deleteBracketTitle => 'Burahin ang Bracket';

  @override
  String deleteBracketMessage(String lower, String upper) {
    return 'Burahin ang charge range na ₱$lower–₱$upper? Hindi na ito maibabalik.';
  }

  @override
  String get editChargeBracketTitle => 'I-edit ang Charge Bracket';

  @override
  String get editChargeBracketHint =>
      'I-update ang eksaktong simula at katapusan ng charge range na ito.';

  @override
  String get saveChanges => 'I-save ang Pagbabago';

  @override
  String get chargeErrorOverlapRange =>
      'Sumasapaw ang range na ito sa existing na charge bracket para sa uring ito.';

  @override
  String get chargeErrorUpdateTargetMissing =>
      'Hindi ma-update ang napiling bracket.';

  @override
  String get chargeErrorLowerBoundNonPositive =>
      'Ang simulang halaga ay dapat higit sa zero.';

  @override
  String get chargeErrorUpperBoundTooSmall =>
      'Ang huling halaga ay dapat mas mataas o kapantay ng simulang halaga.';

  @override
  String get chargeErrorNegative => 'Ang bayad ay hindi puwedeng negatibo.';

  @override
  String chargeErrorTooHigh(String max, String upper) {
    return 'Ang bayad ay hindi puwedeng lumampas sa 50% ng upper bound (max ₱$max para sa upper bound na ₱$upper).';
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
  String get registeredParties => 'Iyong Mga Tao';

  @override
  String get yourPeople => 'Iyong Mga Tao';

  @override
  String get manageParties =>
      'Pamahalaan ang mga customer at partner na ka-transaksyon mo';

  @override
  String get manageCustomersPartners =>
      'Pamahalaan ang mga customer at partner na ka-transaksyon mo';

  @override
  String get searchByNameAccount =>
      'Maghanap gamit ang pangalan o account number...';

  @override
  String get activeEntities => 'Mabilis na Buod';

  @override
  String get addParty => 'Magdagdag ng Tao';

  @override
  String get addNewPerson => 'Magdagdag ng Tao';

  @override
  String get noMatchingParties => 'Walang tumugmang tao sa iyong hinanap';

  @override
  String get tryDifferentKeyword =>
      'Subukan ang ibang pangalan o account number';

  @override
  String get noPartiesSaved => 'Wala pang tao dito';

  @override
  String get localDatabaseInfo =>
      'Wala pang laman ang listahan mo. Magdagdag ng unang customer o business partner.';

  @override
  String get deleteParty => 'Burahin ang Tao';

  @override
  String deletePartyConfirm(String name) {
    return 'Sigurado ka bang gusto mong burahin si $name? Hindi na ito mababawi.';
  }

  @override
  String get peopleSaved => 'taong naka-save';

  @override
  String get verified => 'Beripikado';

  @override
  String get waitingToVerify => 'naghihintay ma-beripika';

  @override
  String get verificationStatus => 'Status ng Beripikasyon';

  @override
  String get statusVerified => 'Beripikado';

  @override
  String get statusPending => 'Naghihintay ng Beripikasyon';

  @override
  String joinedDate(String date) {
    return 'Sumali noong $date';
  }

  @override
  String theirAccount(String account) {
    return 'Account: $account';
  }

  @override
  String get viewHistory => 'Tingnan ang History';

  @override
  String get allPeople => 'Lahat ng Tao';

  @override
  String get pendingPeople => 'Naghihintay';

  @override
  String get nobodyHereYet => 'Wala pang tao dito';

  @override
  String get letAddFirst =>
      'Wala pang laman ang listahan mo. Magdagdag ng unang customer o business partner.';

  @override
  String get show => 'Ipakita';

  @override
  String get sort => 'Ayos';

  @override
  String get newest => 'Pinakabago';

  @override
  String get oldest => 'Pinakaluma';

  @override
  String get all => 'Lahat';

  @override
  String get active => 'Aktibo';

  @override
  String get pending => 'Naghihintay';

  @override
  String get partiesManagement => 'Pamamahala ng Mga Tao';

  @override
  String get lastUpdated => 'Huling Update';

  @override
  String get total => 'Kabuuan';

  @override
  String get account => 'Account';

  @override
  String get status => 'Status';

  @override
  String get edit => 'I-edit';

  @override
  String get history => 'History';

  @override
  String get name => 'Pangalan';

  @override
  String get backupSync => 'I-backup at I-sync';

  @override
  String get serverConnection => 'Koneksyon sa Server';

  @override
  String get serverUrlInstruction =>
      'Ilagay ang base URL ng iyong Tinda Tracker server. Gamitin ang iyong lokal na IP (hal. http://192.168.1.24:8080/api) kapag ang device ay nasa parehong Wi-Fi ng iyong computer.';

  @override
  String get serverApiUrl => 'URL ng Server API';

  @override
  String get serverApiUrlHint => 'http://192.168.1.x:8080/api';

  @override
  String get saveUrl => 'I-save ang URL';

  @override
  String get syncData => 'I-sync ang Data';

  @override
  String get syncInstruction =>
      'Itulak ang mga lokal na pagbabago sa server at hilahin ang mga update mula sa ibang device.';

  @override
  String get syncing => 'Nag-si-sync…';

  @override
  String get syncNow => 'I-sync Ngayon';

  @override
  String get serverUrlSaved => 'Nai-save ang URL ng server.';

  @override
  String syncCompleted(int pushed, int pulled) {
    return 'Natapos ang pag-sync — itinulak ang $pushed, hinila ang $pulled.';
  }

  @override
  String syncFailed(Object error) {
    return 'Nabigo ang pag-sync: $error';
  }

  @override
  String get localBackup => 'Lokal na Backup';

  @override
  String get exportBackup => 'I-export ang Backup';

  @override
  String get restoreBackup => 'I-restore ang Backup';

  @override
  String get aboutPocketLedger => 'Tungkol sa PocketLedger';

  @override
  String get pocketLedgerDescription =>
      'Tinutulungan ka ng PocketLedger na subaybayan ang mga transaksyon, galaw ng may-ari, at daloy ng pera ng negosyo sa isang lugar.';

  @override
  String get version => 'Bersyon 1.0.0';

  @override
  String get buildInfo => 'Para sa Android, iOS, at desktop na platform';

  @override
  String get yourProfile => 'Iyong Profile';

  @override
  String get profileDescription =>
      'Itakda ang iyong display name, impormasyon sa pakikipag-ugnayan, at mga setting ng pagkakakilanlan ng negosyo.';

  @override
  String get quickNavigation => 'Mabilis na Navigasyon';

  @override
  String get backupData => 'I-backup ang Data';

  @override
  String get profile => 'Profile';

  @override
  String get aboutApp => 'Tungkol sa App';

  @override
  String get changeLanguage => 'Baguhin ang Wika';

  @override
  String get recordOwnerMovementFab => 'Mag-record ng Entry sa Pera';

  @override
  String get transaction => 'Transaksyon';

  @override
  String get languageEnglish => 'Ingles';

  @override
  String get languageFilipino => 'Filipino';

  @override
  String get languageCebuano => 'Cebuano';

  @override
  String get selectLanguage => 'Pumili ng Wika';

  @override
  String get totalFunds => 'KASALUKUYANG BUSINESS CASH';

  @override
  String get recentActivities => 'Mga Kamakailan na Aktibidad';

  @override
  String get filterAll => 'Lahat';

  @override
  String get filterBusiness => 'Negosyo';

  @override
  String get filterPersonal => 'Personal';

  @override
  String get filterTransactions => 'Mga Transaksyon';

  @override
  String get noActivitiesFilter =>
      'Walang aktibidad na tumutugma sa napiling filter.';

  @override
  String ownerCreditOutstanding(String amount) {
    return 'Natitirang Utang ng May-ari: $amount';
  }

  @override
  String get walletTrendPlaceholder =>
      'Lalabas ang data ng trend kapag may naitala nang aktibidad sa pitaka.';

  @override
  String businessCashBreakdown(String wallets, String cash, String credit) {
    return 'Mga Wallet $wallets + Cash sa kamay $cash + Kredito ng may-ari $credit';
  }

  @override
  String get businessCashComputation =>
      'Available na ngayon para sa business use';

  @override
  String withdrawableEarningsNote(String amount) {
    return 'Withdrawable na kita sa ngayon: $amount';
  }

  @override
  String get inventory => 'Imbentaryo';

  @override
  String get addProduct => 'Magdagdag ng Produkto';

  @override
  String get editProduct => 'I-edit ang Produkto';

  @override
  String get updateProduct => 'I-update ang Produkto';

  @override
  String get products => 'Produkto';

  @override
  String get totalStock => 'Total Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Ubos';

  @override
  String get noProducts => 'Wala pang produkto.';

  @override
  String get searchProductHint => 'Maghanap ng pangalan o barcode...';

  @override
  String get archiveProductTitle => 'I-archive ang Produkto?';

  @override
  String archiveProductMessage(String name) {
    return 'Ang \"$name\" ay itatago sa listahan. Maaari itong ibalik mamaya.';
  }

  @override
  String archiveBulkTitle(int count) {
    return 'I-archive ang $count produkto?';
  }

  @override
  String get archive => 'I-archive';

  @override
  String get archiveProduct => 'I-archive ang Produkto';

  @override
  String get no => 'Huwag';

  @override
  String get selectMultiple => 'Pumili ng marami';

  @override
  String nSelected(int count) {
    return '$count napili';
  }

  @override
  String nProducts(int count) {
    return '$count produkto';
  }

  @override
  String get adjustStock => 'Ayusin ang Stock';

  @override
  String get stockHistory => 'Kasaysayan ng Stock';

  @override
  String get stock => 'Stock';

  @override
  String get currentStockLabel => 'Kasalukuyang Stock';

  @override
  String get lowStockAlertStat => 'Low Stock Alert';

  @override
  String get noStockHistory => 'Wala pang kasaysayan ng stock.';

  @override
  String get productInformation => 'Impormasyon ng Produkto';

  @override
  String get productName => 'Pangalan ng Produkto *';

  @override
  String get nameRequired => 'Kailangan ang pangalan';

  @override
  String get skuBarcode => 'SKU / Barcode *';

  @override
  String get skuRequired => 'Kailangan ang SKU/barcode';

  @override
  String get scanBarcode => 'I-scan ang Barcode';

  @override
  String get descriptionOptional => 'Paglalarawan (opsyonal)';

  @override
  String get category => 'Kategorya';

  @override
  String get unitLabel => 'Unit';

  @override
  String get pricing => 'Presyo';

  @override
  String get costPrice => 'Halaga ng Bili (Cost)';

  @override
  String get sellingPrice => 'Presyo ng Benta *';

  @override
  String get fieldRequired => 'Kailangan';

  @override
  String get numbersOnly => 'Numero lang';

  @override
  String get initialStock => 'Initial Stock';

  @override
  String get useAdjustStockToChange => 'Gamitin ang Ayusin Stock para magbago';

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String get activeLabel => 'Aktibo';

  @override
  String get activeHelperText => 'Lalabas sa listahan at POS';

  @override
  String get productAdded => 'Naidagdag ang produkto!';

  @override
  String get productUpdated => 'Na-update ang produkto!';

  @override
  String get filters => 'Mga Filter';

  @override
  String get clearAll => 'I-clear lahat';

  @override
  String get stockAlerts => 'Alerto ng Stock';

  @override
  String get lowStockOnly => 'Low Stock lamang';

  @override
  String get outOfStockOnly => 'Ubos na Stock lamang';

  @override
  String get noChange => 'Walang pagbabago.';

  @override
  String get quickAdjust => 'Mabilis na pagbabago';

  @override
  String get reason => 'Dahilan';

  @override
  String get saveStock => 'I-save ang Stock';

  @override
  String get manualAmount => 'Manual na bilang (+ o -)';

  @override
  String get resetBtn => 'I-reset';

  @override
  String categoryAndUnit(String category, String unit) {
    return 'Kategorya: $category  |  $unit';
  }

  @override
  String get errEmptyCart => 'Walang item sa iyong cart.';

  @override
  String get errNegativePaidAmount => 'Hindi puwedeng negative ang binayad.';

  @override
  String errUnitConversionNotSet(String unit, String product) {
    return 'Hindi naka-set ang unit conversion para sa unit na $unit sa produktong $product.';
  }

  @override
  String errEmptyRecipeIngredients(String product) {
    return 'Walang sangkap na naka-set para sa recipe product: $product.';
  }

  @override
  String errInsufficientIngredientStock(
    String ingredient,
    String product,
    double needed,
    double available,
  ) {
    return 'Kulang ang stock ng sangkap na $ingredient para sa recipe product: $product. Kailangan: $needed, mayroon lang: $available.';
  }

  @override
  String errInsufficientProductStock(
    String product,
    double needed,
    double available,
  ) {
    return 'Kulang ang stocks para sa $product. Kailangan: $needed, mayroon lang: $available.';
  }

  @override
  String errSerialSelection(int required, String product, int selected) {
    return 'Kailangang mag-select ng eksaktong $required serial number(s) para sa $product. Kasalukuyang pinili: $selected.';
  }

  @override
  String errSerialNotAvailable(String serial) {
    return 'Ang serial number na \"$serial\" ay hindi available o nabenta na.';
  }

  @override
  String errPaidAmountInsufficient(double paid, double total) {
    return 'Kulang ang binayad ng customer. Binayad: $paid, Total: $total.';
  }

  @override
  String get noIngredientsAvailable => 'Walang available na sangkap';

  @override
  String get noIngredientsSet =>
      'Walang sangkap na naka-set. Magdagdag ng mga sangkap sa ibaba.';

  @override
  String get noSerialsRegistered => 'Walang serial numbers na nakarehistro.';

  @override
  String get noBarcodeRead => 'Walang barcode na nabasa. Subukan ulit.';

  @override
  String noProductForBarcode(String code) {
    return 'Walang produktong may barcode na \"$code\".';
  }

  @override
  String get addItemsFirst =>
      'Magdagdag muna ng items sa cart bago mag-checkout.';

  @override
  String get cannotCheckoutNow =>
      'Hindi makapag-checkout sa ngayon. Pakisuri muli.';

  @override
  String get insufficientPayment => 'Kulang ang bayad. Pakisuri muli.';

  @override
  String checkoutFailed(String error) {
    return 'Pakyas ang checkout: $error';
  }

  @override
  String get failedToLoadProducts =>
      'Pakyas sa pag-load ng mga produkto. Pakisubukan muli.';

  @override
  String get noProductsFound => 'Walang nahanap na mga produkto.';

  @override
  String get lowStockWarningEditAllowed =>
      'May mga item na mababa ang stock. Maaari mo pa rin silang i-edit bago mag-checkout.';

  @override
  String get noSerialsAvailableForProduct =>
      'Walang magagamit na mga serial number para sa produktong ito.';

  @override
  String get noMatchingProducts => 'Walang nahanap na tugmang produkto.';

  @override
  String get scanDuplicateWarning =>
      'Nabasa na ito kanina lang. I-scan ulit pagkatapos ng sandali.';

  @override
  String addedToQueue(String product) {
    return 'Na-add sa queue: $product';
  }

  @override
  String saleCompleteWithChange(String change) {
    return 'Kumpleto ang benta! Sukli: $change';
  }

  @override
  String selectSerialsRequired(int required, int selected) {
    return 'Pumili ng eksaktong $required serial number(s). Naka-select: $selected';
  }

  @override
  String serialsLimitExceeded(int required) {
    return 'Limitadong hanggang $required serials lang.';
  }

  @override
  String get continuousScan => 'Continuous scan';

  @override
  String get muteScanSound => 'I-mute ang tunog ng scan';

  @override
  String get enableScanSound => 'I-enable ang tunog ng scan';

  @override
  String get disableVibration => 'I-disable ang vibration';

  @override
  String get enableVibration => 'I-enable ang vibration';

  @override
  String get typeBarcodeManually => 'I-type ang barcode nang manu-mano';

  @override
  String get serialAlreadyAdded => 'Ang serial number na ito ay naidagdag na.';

  @override
  String stockMustMatchSerials(int stock, int count) {
    return 'Ang stock quantity ($stock) ay kailangang katumbas ng bilang ng available serial numbers ($count).';
  }

  @override
  String get scanOrTypeSerial =>
      'Mag-scan o mag-type ng serial number upang idagdag.';
}
