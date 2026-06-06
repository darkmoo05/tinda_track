// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PocketLedger';

  @override
  String get syncingData => 'Syncing your data…';

  @override
  String get walletOverview => 'Wallet Overview';

  @override
  String get gcashWallet => 'GCash Wallet';

  @override
  String get mayaWallet => 'Maya Wallet';

  @override
  String get onHandCash => 'On-hand Cash';

  @override
  String get chargesEarnings => 'Charges Earnings';

  @override
  String get availableBalance => 'Available balance';

  @override
  String get physicalCash => 'Physical cash';

  @override
  String get walletCashBalanceTrend => 'Wallet and Cash Balance Trend';

  @override
  String get borrowed => 'Borrowed';

  @override
  String get repaid => 'Repaid';

  @override
  String get totalPersonalFundsTaken => 'Total personal funds taken by owner';

  @override
  String get totalPersonalFundsReturned =>
      'Total personal funds returned to business';

  @override
  String get unableToLoadDashboard => 'Unable to load dashboard right now.';

  @override
  String get noDashboardData => 'No dashboard data available yet.';

  @override
  String get newEntry => 'New Entry';

  @override
  String get recordTransaction => 'Record Transaction';

  @override
  String get transactionTypeLabel => 'Transaction Type';

  @override
  String get accountNumber => 'Recipient Account';

  @override
  String get searchOrEnterAccountNumber => 'Number';

  @override
  String get scanningReceipt => 'Scanning receipt…';

  @override
  String get scanningReceiptModalMessage =>
      'Reading image and parsing receipt data...';

  @override
  String get scanReceiptButton => 'Scan Receipt (Camera/Gallery)';

  @override
  String get transactionAmount => 'Transaction Amount';

  @override
  String get amountHint => '0.00';

  @override
  String get reference => 'Reference';

  @override
  String get enterReferenceNumber => 'Enter receipt / reference number';

  @override
  String get notes => 'Notes';

  @override
  String get optionalNotes => 'Optional notes...';

  @override
  String get useCamera => 'Use Camera';

  @override
  String get takePicture => 'Take a photo of the receipt';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get chooseExistingPhoto => 'Choose existing screenshot/photo';

  @override
  String get browseFiles => 'Browse Files';

  @override
  String get pickFromAnyFolder => 'Pick from any folder';

  @override
  String get receiptScanResult => 'Receipt Scan Result';

  @override
  String get receiptScanDescription =>
      'Here\'s what was found on your receipt:';

  @override
  String get amount => 'Amount';

  @override
  String get accountName => 'Account / Name';

  @override
  String get accountId => 'Account / ID';

  @override
  String get referenceNo => 'Reference No.';

  @override
  String get walletLabel => 'Wallet';

  @override
  String get noRecognizableData =>
      'No recognizable data was found on this receipt.';

  @override
  String get noteWillBeAdded => 'Note that will be added:';

  @override
  String get reviewAndEdit =>
      'Review and edit the filled fields before saving.';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get customerPaysFee => 'Customer Pays the Fee';

  @override
  String get deductFeeFromSent => 'Deduct Fee from Sent Amount';

  @override
  String get goToCharges => 'Go to Charges';

  @override
  String get searchNameOrAccount => 'Search name or account number';

  @override
  String get noContactsFound => 'No contacts found';

  @override
  String get noMatchingContact => 'No matching contact';

  @override
  String get fullNameEntity => 'Full Name / Entity';

  @override
  String get enterPartyFullName => 'Enter party full name';

  @override
  String get enterAccountNumber => 'Enter account number';

  @override
  String get searchContacts => 'Search contacts';

  @override
  String get saving => 'Saving…';

  @override
  String get registerParty => 'Register Party';

  @override
  String get partyRegisteredSaving =>
      'Party registered. Saving transaction now...';

  @override
  String get unableToVerifyRegistration =>
      'Unable to verify registration. Please try again.';

  @override
  String get unableToSaveTransaction =>
      'Unable to save transaction. Please try again.';

  @override
  String transactionSaved(String name) {
    return 'Transaction saved for $name.';
  }

  @override
  String selectService(String service) {
    return 'Select service: $service';
  }

  @override
  String get customerReceives => 'Customer Receives';

  @override
  String get customerSends => 'Customer Sends';

  @override
  String get recordTransactionDetails => 'Transaction Setup';

  @override
  String get optionalDetailsSection => 'Add Reference or Notes (Optional)';

  @override
  String get reviewTotals => 'Total Breakdown';

  @override
  String get showDetails => 'Show details';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get whoPaysServiceFee => 'Fee Handling';

  @override
  String get customerPaysFeeLabel => 'Customer bears fee';

  @override
  String get deductedFromSentLabel => 'Include in amount';

  @override
  String get usingWallet => 'Using wallet';

  @override
  String get serviceFee => 'Applicable fee';

  @override
  String get feeDestination => 'Fee Sent To';

  @override
  String get feeRange => 'Fee range';

  @override
  String get amountSentToCustomerWallet => 'Customer Total';

  @override
  String get amountCustomerSends => 'Amount customer sends';

  @override
  String get customerPays => 'Customer pays';

  @override
  String get cashPaidOut => 'Cash paid out';

  @override
  String get cashAddedToDrawer => 'Your Drawer';

  @override
  String get feeAddedExample =>
      'Service fee is added on top. Example: ₱100 transaction + ₱5 fee = collect ₱105 from customer, send ₱100.';

  @override
  String get feeDeductedExample =>
      'Service fee is deducted before sending. Example: ₱100 entered, ₱5 fee deducted = only ₱95 is sent to customer wallet.';

  @override
  String get accountNotInContacts =>
      'This account is not in contacts yet. Tap here to add contact before saving.';

  @override
  String get saveTransactionAction => 'Record Transaction';

  @override
  String get walletAndService => 'Transaction Type (Required)';

  @override
  String verifiedAccountFound(String name) {
    return '$name - Verified account record found';
  }

  @override
  String get onHandCashLabel => 'On-hand cash';

  @override
  String get cashPaidOutTooltip =>
      'Cash you hand out to the customer from your drawer.';

  @override
  String get cashAddedToDrawerTooltip =>
      'Cash that goes into your drawer after this transaction.';

  @override
  String get noFeeRuleForAmount =>
      'No fee rule for this amount yet. Fee is ₱0. Add a fee rule first.';

  @override
  String get receiptDataAppliedReview =>
      'Receipt data applied. Please review before saving.';

  @override
  String get noFeeRangeFoundTitle => 'No fee range found';

  @override
  String get noFeeRangeFoundMessage =>
      'The entered amount does not match any configured fee range. Please create a new fee range first.';

  @override
  String get accountNumberRequiredBeforeSaving =>
      'Account number is required before saving.';

  @override
  String get transactionAmountRequiredBeforeSaving =>
      'Transaction amount is required before saving.';

  @override
  String get noFeeRangeFoundForAmount =>
      'No fee range found for this amount. Create a new range first.';

  @override
  String get amountToSendMustBeGreaterThanZero =>
      'Amount to send must be greater than zero. Adjust entered amount or charge handling.';

  @override
  String insufficientBalance(String source, String amount) {
    return 'Insufficient $source balance. Available: ₱ $amount';
  }

  @override
  String get partyNotRegisteredYet =>
      'Party is not registered yet. Register details first.';

  @override
  String transactionSavedSyncRetry(String name) {
    return 'Transaction saved for $name. Backend sync will retry automatically.';
  }

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than 0';

  @override
  String feeValidationFailedStatus(String status, String message) {
    return 'Fee validation failed$status: $message';
  }

  @override
  String feeValidationFailed(String error) {
    return 'Fee validation failed: $error';
  }

  @override
  String get backendPreviewUnavailable => 'Backend Preview Unavailable';

  @override
  String get unableToValidateFeePreviewNow =>
      'Unable to validate fee preview from backend right now.';

  @override
  String get saveLocally => 'Save locally';

  @override
  String get feeBreakdownTitle => 'Fee breakdown';

  @override
  String get charge => 'Charge';

  @override
  String get totalCollected => 'Total collected';

  @override
  String get walletCredit => 'Wallet credit';

  @override
  String get onHandChange => 'On-hand change';

  @override
  String get feeRouting => 'Where the Fee Goes';

  @override
  String get confirmAndSave => 'Confirm and save';

  @override
  String get selectRegisteredContact => 'Select Registered Contact';

  @override
  String get registerPartyFirstThenSearch =>
      'Register a party first, then use search to pick an account.';

  @override
  String get tryDifferentNameOrAccount =>
      'Try searching with a different name or account number.';

  @override
  String accountWithNumber(String number) {
    return 'Account: $number';
  }

  @override
  String get completeNameAndAccount =>
      'Please complete full name and account number.';

  @override
  String get unableToSaveParty => 'Unable to save party. Please try again.';

  @override
  String get accountAlreadyRegistered => 'Account already registered.';

  @override
  String get partyRegistrationTitle => 'Party Registration';

  @override
  String get defineFinancialEntityBeforeTransaction =>
      'Define a new financial entity before recording this transaction.';

  @override
  String get loadService => 'Load';

  @override
  String get payBillsService => 'Pay Bills';

  @override
  String get qrPaymentService => 'QR Payment';

  @override
  String get stepOneChooseWallet => 'Step 1: Choose wallet';

  @override
  String get pickWalletHelper => 'Wallet buttons choose which account to use.';

  @override
  String get stepTwoChooseService => 'Step 2: Choose service';

  @override
  String get pickServiceHelper =>
      'Service buttons choose what transaction to perform.';

  @override
  String selectedWalletService(String wallet, String service) {
    return 'Selected: $wallet • $service';
  }

  @override
  String get newOwnerMovement => 'New Money Record';

  @override
  String get recordOwnerMovement => 'Record a Money Entry';

  @override
  String get phase3Description =>
      'Track money you put in, took out, or borrowed from your business wallets.';

  @override
  String get movementType => 'What did you do?';

  @override
  String get chooseMovementType => 'Choose what happened';

  @override
  String get moneyDirection => 'What this does';

  @override
  String get cashIn => 'Cash In';

  @override
  String get cashOut => 'Cash Out';

  @override
  String get borrowFrom => 'Borrow From';

  @override
  String get repayTo => 'Repay To';

  @override
  String get destination => 'Destination';

  @override
  String get sourceAccount => 'Taken from';

  @override
  String get personal => 'Personal';

  @override
  String get business => 'Business';

  @override
  String get expenseCategory => 'Expense Category';

  @override
  String get add => 'Add';

  @override
  String get manage => 'Manage';

  @override
  String get addCategoryFirst =>
      'Add a spending category first (e.g. Food, Transport).';

  @override
  String get chooseExpenseCategory => 'Choose Expense Category';

  @override
  String get referenceOptional => 'Reference (Optional)';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get additionalDetails => 'Additional details...';

  @override
  String get categoryName => 'Category name';

  @override
  String get renameCategory => 'Rename Category';

  @override
  String get addCategory => 'Add Category';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get existingCategories => 'Existing Categories';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get categoryDeleted => 'Category deleted.';

  @override
  String get enterCategoryName => 'Enter a category name.';

  @override
  String get movementTypePending => 'No type selected yet';

  @override
  String get categoryPending => 'No category selected';

  @override
  String get movements => 'Wallet History';

  @override
  String get walletHistorySubtitle => 'Track GCash, Maya, and cash movement.';

  @override
  String get reports => 'Download Report';

  @override
  String get transactions => 'Transactions';

  @override
  String get ownerMovements => 'Owner Activity';

  @override
  String get historyTransactionLabel => 'Transaction';

  @override
  String get historyOwnerActivityLabel => 'Owner Activity';

  @override
  String get historyTypeLabel => 'Type';

  @override
  String get historyCategoryLabel => 'Category';

  @override
  String get historyAccountLabel => 'Account';

  @override
  String get historyAmountShownLabel => 'Amount shown';

  @override
  String get walletChangeLabel => 'Wallet change';

  @override
  String get cashChangeLabel => 'Cash change';

  @override
  String get savedOnLabel => 'Saved on';

  @override
  String get transactionBreakdown => 'Transaction Breakdown';

  @override
  String get entryDetails => 'Entry Details';

  @override
  String includesFee(String amount) {
    return 'Includes fee: $amount';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noMatchingTransactions => 'No results found';

  @override
  String get trySearchingBy => 'Try changing the wallet, date, or search.';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get newEntriesWillAppear =>
      'Your saved transactions and owner activity will appear here.';

  @override
  String get searchAccountRefParty => 'Search by account, ref no., or note';

  @override
  String get beginningDate => 'From date';

  @override
  String get endDate => 'To date';

  @override
  String get filterBeginDate => 'Filter from date';

  @override
  String get filterEndDate => 'Filter to date';

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
  String get generate => 'Generate';

  @override
  String get close => 'Close';

  @override
  String get selectBeginningDate => 'Select from date';

  @override
  String get selectEndDate => 'Select to date';

  @override
  String get generalLedgerReport => 'General Ledger Report';

  @override
  String get generalLedgerReportDescription =>
      'Pick a date range, then choose PDF or Excel output.';

  @override
  String get fileFormat => 'File format';

  @override
  String get endDateValidationMessage =>
      'To date must be the same as or later than from date.';

  @override
  String get preparingReport => 'Preparing report...';

  @override
  String get noLedgerRecordsForDateRange =>
      'No ledger records were found for the selected date range.';

  @override
  String get reportGenerationCanceled =>
      'Report generation canceled. No folder was selected.';

  @override
  String get generatingReport => 'Generating report...';

  @override
  String get reportShareUnavailable =>
      'Report generated, but sharing is not available on this device. The file was saved locally.';

  @override
  String get reportGenerationFailed =>
      'Failed to generate the report. Please try again.';

  @override
  String reportSavedTo(String path) {
    return 'Report generated successfully. Saved to $path';
  }

  @override
  String get walletHistoryReport => 'Wallet History Report';

  @override
  String get walletHistorySheetName => 'Wallet History';

  @override
  String get walletFlowReport => 'Wallet Flow';

  @override
  String get walletFlowSheetName => 'Wallet Flow';

  @override
  String get periodLabel => 'Period';

  @override
  String get generatedLabel => 'Generated';

  @override
  String get legendTitle => 'Quick guide';

  @override
  String get legendPlusMinus => 'Use + for increase and - for decrease.';

  @override
  String get legendAmountShownNote =>
      'Amount matches history. Cash out may already include fee.';

  @override
  String get reportDateTimeLabel => 'Date/Time';

  @override
  String get reportTypeLabel => 'Type';

  @override
  String get reportAmountLabel => 'Amount shown';

  @override
  String get reportFeeLabel => 'Fee';

  @override
  String get reportWalletDeltaLabel => 'Wallet change';

  @override
  String get reportCashDeltaLabel => 'Cash change';

  @override
  String get reportReferenceLabel => 'Ref #';

  @override
  String get reportDetailsLabel => 'Details';

  @override
  String get dateTimeLabel => 'Date & Time';

  @override
  String get walletUsedLabel => 'Wallet';

  @override
  String get amountShownLabel => 'History Amount';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get remarksLabel => 'Remarks';

  @override
  String get moneyInLabel => 'Money In';

  @override
  String get moneyOutLabel => 'Money Out';

  @override
  String get feeDetailsLabel => 'Fee Details';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get totalsLabel => 'TOTALS';

  @override
  String get gcashMovementLabel => 'GCash Change';

  @override
  String get mayaMovementLabel => 'Maya Change';

  @override
  String get cashOnHandMovementLabel => 'Cash Change';

  @override
  String get feesRoutedLabel => 'Fee Destination';

  @override
  String get totalMoneyInLabel => 'Total Money In';

  @override
  String get totalMoneyOutLabel => 'Total Money Out';

  @override
  String get netBalanceLabel => 'Net Balance';

  @override
  String get totalFeesPaidLabel => 'Total Fees Paid';

  @override
  String get chooseFolder => 'Choose folder to save General Ledger report';

  @override
  String get chargesManagement => 'Fee Configuration';

  @override
  String get setServiceFeeBrackets => 'Manage pricing for all services';

  @override
  String get configureFeesFor => 'Configuring fees for:';

  @override
  String get gcashWalletOption => 'GCash';

  @override
  String get mayaWalletOption => 'Maya';

  @override
  String get addNewBracket => 'Add New Fee Tier';

  @override
  String get lowerBound => 'Starting Amount (PHP)';

  @override
  String get lowerBoundHint => 'e.g. 1000';

  @override
  String get upperBound => 'Ending Amount (PHP)';

  @override
  String get upperBoundHint => 'e.g. 1500';

  @override
  String get chargeAmount => 'Fee Amount (PHP)';

  @override
  String get chargeAmountHint => 'e.g. 25.00';

  @override
  String get backToTransaction => 'Back to transaction';

  @override
  String get openMenu => 'Open menu';

  @override
  String get dailyEarningsTrend => 'Daily Earnings Trend';

  @override
  String get goBack => 'Go back';

  @override
  String get serviceCashIn => 'Cash-In';

  @override
  String get serviceCashOut => 'Cash-Out';

  @override
  String get serviceLoad => 'Load';

  @override
  String get servicePayBills => 'Pay Bills';

  @override
  String get serviceQrPayment => 'QR Payment';

  @override
  String selectFeeType(String type) {
    return 'Select fee type: $type';
  }

  @override
  String get selectWalletAndTransactionType =>
      'Select a wallet and transaction type';

  @override
  String feePreview(String from, String fee) {
    return 'Preview: ₱$from → Fee ₱$fee';
  }

  @override
  String get startingAmountLabel => 'Starting Amount';

  @override
  String get endingAmountLabel => 'Ending Amount';

  @override
  String get feeAmountLabel => 'Fee Amount';

  @override
  String totalTiers(String count) {
    return 'Total: $count tiers';
  }

  @override
  String get smallTransactions => 'Small Transactions';

  @override
  String get mediumTransactions => 'Medium Transactions';

  @override
  String get largeTransactions => 'Large Transactions';

  @override
  String get availableForTransactions => '(Available for transactions)';

  @override
  String get chargeInputInvalid =>
      'Enter valid lower bound, upper bound, and charge amount.';

  @override
  String get chargeBracketAdded => 'Charge bracket added.';

  @override
  String get chargeBracketDeleted => 'Charge bracket deleted.';

  @override
  String get unableToDeleteBracket => 'Unable to delete bracket.';

  @override
  String get deleteBracketTitle => 'Delete Bracket';

  @override
  String deleteBracketMessage(String lower, String upper) {
    return 'Delete the ₱$lower–₱$upper charge range? This cannot be undone.';
  }

  @override
  String get editChargeBracketTitle => 'Edit Charge Bracket';

  @override
  String get editChargeBracketHint =>
      'Update the exact lower and upper bounds for this charge range.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get chargeErrorOverlapRange =>
      'This range overlaps with an existing charge bracket for this type.';

  @override
  String get chargeErrorUpdateTargetMissing =>
      'Unable to update the selected bracket.';

  @override
  String get chargeErrorLowerBoundNonPositive =>
      'Lower bound must be greater than zero.';

  @override
  String get chargeErrorUpperBoundTooSmall =>
      'Upper bound must be greater than or equal to lower bound.';

  @override
  String get chargeErrorNegative => 'Charge amount cannot be negative.';

  @override
  String chargeErrorTooHigh(String max, String upper) {
    return 'Charge amount cannot exceed 50% of the upper bound (max ₱$max for a ₱$upper upper bound).';
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
  String get registeredParties => 'Your People';

  @override
  String get yourPeople => 'Your People';

  @override
  String get manageParties => 'Manage customers & partners you work with';

  @override
  String get manageCustomersPartners =>
      'Manage customers & partners you work with';

  @override
  String get searchByNameAccount => 'Search by name or account number...';

  @override
  String get activeEntities => 'Quick Stats';

  @override
  String get addParty => 'Add New Person';

  @override
  String get addNewPerson => 'Add New Person';

  @override
  String get noMatchingParties => 'No people match that search';

  @override
  String get tryDifferentKeyword => 'Try a different name or account number';

  @override
  String get noPartiesSaved => 'Nobody Here Yet! 👋';

  @override
  String get localDatabaseInfo =>
      'Your contact list is empty. Let\'s add your first customer or business partner.';

  @override
  String get deleteParty => 'Delete Person';

  @override
  String deletePartyConfirm(String name) {
    return 'Are you sure you want to delete $name? This action cannot be undone.';
  }

  @override
  String get peopleSaved => 'people saved';

  @override
  String get verified => 'Verified';

  @override
  String get waitingToVerify => 'waiting to verify';

  @override
  String get verificationStatus => 'Verification Status';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusPending => 'Waiting for Verification';

  @override
  String joinedDate(String date) {
    return 'Joined $date';
  }

  @override
  String theirAccount(String account) {
    return 'Account: $account';
  }

  @override
  String get viewHistory => 'View History';

  @override
  String get allPeople => 'All People';

  @override
  String get pendingPeople => 'Pending';

  @override
  String get nobodyHereYet => 'Nobody Here Yet! 👋';

  @override
  String get letAddFirst =>
      'Your contact list is empty. Let\'s add your first customer or business partner.';

  @override
  String get show => 'Show';

  @override
  String get sort => 'Sort';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get pending => 'Pending';

  @override
  String get partiesManagement => 'Parties Management';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get total => 'Total';

  @override
  String get account => 'Account';

  @override
  String get status => 'Status';

  @override
  String get edit => 'Edit';

  @override
  String get history => 'History';

  @override
  String get name => 'Name';

  @override
  String get backupSync => 'Backup & Sync';

  @override
  String get serverConnection => 'Server connection';

  @override
  String get serverUrlInstruction =>
      'Enter the base URL of your Tinda Tracker server. Use your local IP (e.g. http://192.168.1.24:8080/api) when the device is on the same Wi-Fi as your computer.';

  @override
  String get serverApiUrl => 'Server API URL';

  @override
  String get serverApiUrlHint => 'http://192.168.1.x:8080/api';

  @override
  String get saveUrl => 'Save URL';

  @override
  String get syncData => 'Sync data';

  @override
  String get syncInstruction =>
      'Push local changes to the server and pull updates from other devices.';

  @override
  String get syncing => 'Syncing…';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get serverUrlSaved => 'Server URL saved.';

  @override
  String syncCompleted(int pushed, int pulled) {
    return 'Sync completed — pushed $pushed, pulled $pulled.';
  }

  @override
  String syncFailed(Object error) {
    return 'Sync failed: $error';
  }

  @override
  String get localBackup => 'Local backup';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get aboutPocketLedger => 'About PocketLedger';

  @override
  String get pocketLedgerDescription =>
      'PocketLedger helps you track transactions, owner movements, and business cash flow in one place.';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get buildInfo => 'Build for Android, iOS, and desktop platforms';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get profileDescription =>
      'Set your display name, contact details, and business identity settings.';

  @override
  String get quickNavigation => 'Quick navigation';

  @override
  String get backupData => 'Backup Data';

  @override
  String get profile => 'Profile';

  @override
  String get aboutApp => 'About App';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get recordOwnerMovementFab => 'Record a Money Entry';

  @override
  String get transaction => 'Transaction';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFilipino => 'Filipino';

  @override
  String get languageCebuano => 'Cebuano';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get totalFunds => 'CURRENT BUSINESS CASH';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get filterAll => 'All';

  @override
  String get filterBusiness => 'Business';

  @override
  String get filterPersonal => 'Personal';

  @override
  String get filterTransactions => 'Transactions';

  @override
  String get noActivitiesFilter =>
      'No activities match the selected filter yet.';

  @override
  String ownerCreditOutstanding(String amount) {
    return 'Owner Credit Outstanding: $amount';
  }

  @override
  String get walletTrendPlaceholder =>
      'Trend data will appear once wallet activity has been recorded.';

  @override
  String businessCashBreakdown(String wallets, String cash, String credit) {
    return 'Wallets $wallets + On-hand $cash + Owner Credit $credit';
  }

  @override
  String get businessCashComputation => 'Available now for business use';

  @override
  String withdrawableEarningsNote(String amount) {
    return 'Withdrawable earnings right now: $amount';
  }

  @override
  String get inventory => 'Inventory';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get updateProduct => 'Update Product';

  @override
  String get products => 'Products';

  @override
  String get totalStock => 'Total Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get noProducts => 'No products yet.';

  @override
  String get searchProductHint => 'Search by name or barcode...';

  @override
  String get archiveProductTitle => 'Archive this Product?';

  @override
  String archiveProductMessage(String name) {
    return '\"$name\" will be hidden from the list. It can be restored later.';
  }

  @override
  String archiveBulkTitle(int count) {
    return 'Archive $count products?';
  }

  @override
  String get archive => 'Archive';

  @override
  String get archiveProduct => 'Archive Product';

  @override
  String get no => 'No';

  @override
  String get selectMultiple => 'Select multiple';

  @override
  String nSelected(int count) {
    return '$count selected';
  }

  @override
  String nProducts(int count) {
    return '$count products';
  }

  @override
  String get adjustStock => 'Adjust Stock';

  @override
  String get stockHistory => 'Stock History';

  @override
  String get stock => 'Stock';

  @override
  String get currentStockLabel => 'Current Stock';

  @override
  String get lowStockAlertStat => 'Low Stock Alert';

  @override
  String get noStockHistory => 'No stock history yet.';

  @override
  String get productInformation => 'Product Information';

  @override
  String get productName => 'Product Name *';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get skuBarcode => 'SKU / Barcode *';

  @override
  String get skuRequired => 'SKU/barcode is required';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get category => 'Category';

  @override
  String get unitLabel => 'Unit';

  @override
  String get pricing => 'Pricing';

  @override
  String get costPrice => 'Cost Price';

  @override
  String get sellingPrice => 'Selling Price *';

  @override
  String get fieldRequired => 'Required';

  @override
  String get numbersOnly => 'Numbers only';

  @override
  String get initialStock => 'Initial Stock';

  @override
  String get useAdjustStockToChange => 'Use Adjust Stock to change';

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String get activeLabel => 'Active';

  @override
  String get activeHelperText => 'Will appear in the list and POS';

  @override
  String get productAdded => 'Product added!';

  @override
  String get productUpdated => 'Product updated!';

  @override
  String get filters => 'Filters';

  @override
  String get clearAll => 'Clear all';

  @override
  String get stockAlerts => 'Stock Alerts';

  @override
  String get lowStockOnly => 'Low Stock only';

  @override
  String get outOfStockOnly => 'Out of Stock only';

  @override
  String get noChange => 'No change.';

  @override
  String get quickAdjust => 'Quick adjustment';

  @override
  String get reason => 'Reason';

  @override
  String get saveStock => 'Save Stock';

  @override
  String get manualAmount => 'Manual amount (+ or -)';

  @override
  String get resetBtn => 'Reset';

  @override
  String categoryAndUnit(String category, String unit) {
    return 'Category: $category  |  $unit';
  }

  @override
  String get errEmptyCart =>
      'No items in checkout queue. Add items before checking out.';

  @override
  String get errNegativePaidAmount => 'Paid amount cannot be negative.';

  @override
  String errUnitConversionNotSet(String unit, String product) {
    return 'Unit $unit is not configured for $product.';
  }

  @override
  String errEmptyRecipeIngredients(String product) {
    return 'No ingredients configured for recipe $product.';
  }

  @override
  String errInsufficientIngredientStock(
    String ingredient,
    String product,
    double needed,
    double available,
  ) {
    return 'Insufficient stock for ingredient $ingredient of $product. Needed: $needed, Available: $available.';
  }

  @override
  String errInsufficientProductStock(
    String product,
    double needed,
    double available,
  ) {
    return 'Insufficient stock for $product. Needed: $needed, Available: $available.';
  }

  @override
  String errSerialSelection(int required, String product, int selected) {
    return 'Please select exactly $required serial number(s) for $product. Selected: $selected.';
  }

  @override
  String errSerialNotAvailable(String serial) {
    return 'Serial number \"$serial\" is not available.';
  }

  @override
  String errPaidAmountInsufficient(double paid, double total) {
    return 'Insufficient payment. Paid: $paid, Total: $total.';
  }

  @override
  String get noIngredientsAvailable => 'No ingredients available.';

  @override
  String get noIngredientsSet => 'No ingredients set. Add ingredients below.';

  @override
  String get noSerialsRegistered => 'No serial numbers registered.';

  @override
  String get noBarcodeRead => 'No barcode detected. Try again.';

  @override
  String noProductForBarcode(String code) {
    return 'No product linked to barcode \"$code\".';
  }

  @override
  String get addItemsFirst => 'Add items to the cart before checking out.';

  @override
  String get cannotCheckoutNow => 'Cannot checkout now. Please check again.';

  @override
  String get insufficientPayment => 'Insufficient payment. Please check again.';

  @override
  String checkoutFailed(String error) {
    return 'Checkout failed: $error';
  }

  @override
  String get failedToLoadProducts =>
      'Failed to load products. Please try again.';

  @override
  String get noProductsFound => 'No products found.';

  @override
  String get lowStockWarningEditAllowed =>
      'Some items are low on stock. You can still edit them before checkout.';

  @override
  String get noSerialsAvailableForProduct =>
      'No available serial numbers for this product.';

  @override
  String get noMatchingProducts => 'No matching products found.';

  @override
  String get scanDuplicateWarning =>
      'This was scanned just recently. Scan again after a moment.';

  @override
  String addedToQueue(String product) {
    return 'Added to queue: $product';
  }

  @override
  String saleCompleteWithChange(String change) {
    return 'Sale complete! Change: $change';
  }

  @override
  String selectSerialsRequired(int required, int selected) {
    return 'Please select exactly $required serial number(s). Selected: $selected';
  }

  @override
  String serialsLimitExceeded(int required) {
    return 'Limit is up to $required serials only.';
  }

  @override
  String get continuousScan => 'Continuous scan';

  @override
  String get muteScanSound => 'Mute scan sound';

  @override
  String get enableScanSound => 'Enable scan sound';

  @override
  String get disableVibration => 'Disable vibration';

  @override
  String get enableVibration => 'Enable vibration';

  @override
  String get typeBarcodeManually => 'Type barcode manually';

  @override
  String get serialAlreadyAdded => 'This serial number has already been added.';

  @override
  String stockMustMatchSerials(int stock, int count) {
    return 'Stock quantity ($stock) must equal the number of available serial numbers ($count).';
  }

  @override
  String get scanOrTypeSerial => 'Scan or type a serial number to add.';
}
