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
  String get gcashWallet => 'GCASH WALLET';

  @override
  String get mayaWallet => 'MAYA WALLET';

  @override
  String get onHandCash => 'ON-HAND CASH';

  @override
  String get chargesEarnings => 'CHARGES EARNINGS';

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
  String get accountNumber => 'Account Number';

  @override
  String get searchOrEnterAccountNumber => 'Search or enter account number';

  @override
  String get scanningReceipt => 'Scanning receipt…';

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
  String get movements => 'Movements';

  @override
  String get reports => 'Reports';

  @override
  String get transactions => 'TRANSACTIONS';

  @override
  String get ownerMovements => 'OWNER MOVEMENTS';

  @override
  String get noMatchingTransactions => 'No matching transactions';

  @override
  String get trySearchingBy =>
      'Try searching by title, account number, reference ID, notes, or date.';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get newEntriesWillAppear =>
      'New entries will appear here once you save transactions or owner movements.';

  @override
  String get searchAccountRefParty => 'Search account, ref ID, party, or note';

  @override
  String get beginningDate => 'Beginning Date';

  @override
  String get endDate => 'End Date';

  @override
  String get gcash => 'GCash';

  @override
  String get maya => 'Maya';

  @override
  String get onHand => 'On-hand';

  @override
  String get pdf => 'PDF';

  @override
  String get excel => 'Excel';

  @override
  String get generate => 'Generate';

  @override
  String get close => 'Close';

  @override
  String get chooseFolder => 'Choose folder to save General Ledger report';

  @override
  String get chargesManagement => 'Charges Management';

  @override
  String get setServiceFeeBrackets =>
      'Set service fee brackets for each transaction type separately.';

  @override
  String get configureFeesFor => 'Configure Fees For';

  @override
  String get gcashWalletOption => 'GCash Wallet';

  @override
  String get mayaWalletOption => 'Maya Wallet';

  @override
  String get addNewBracket => 'Add New Bracket';

  @override
  String get lowerBound => 'Lower Bound (PHP)';

  @override
  String get lowerBoundHint => 'e.g. 1000';

  @override
  String get upperBound => 'Upper Bound (PHP)';

  @override
  String get upperBoundHint => 'e.g. 1500';

  @override
  String get chargeAmount => 'Charge Amount (PHP)';

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
  String get registeredParties => 'Registered Parties';

  @override
  String get manageParties =>
      'Manage your customer ecosystem and entity associations.';

  @override
  String get activeEntities => 'ACTIVE ENTITIES';

  @override
  String get addParty => 'ADD PARTY';

  @override
  String get noMatchingParties => 'No matching parties found';

  @override
  String get tryDifferentKeyword =>
      'Try a different keyword for name, entity ID, account, or description.';

  @override
  String get noPartiesSaved => 'No parties saved yet';

  @override
  String get localDatabaseInfo =>
      'This screen now shows only records stored in your local database.';

  @override
  String get deleteParty => 'Delete Party';

  @override
  String deletePartyConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

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
  String get totalFunds => 'TOTAL FUNDS';

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
  String get borrowingStatus => 'Borrowing Status';

  @override
  String ownerCreditOutstanding(String amount) {
    return 'Owner Credit Outstanding: $amount';
  }

  @override
  String get walletTrendPlaceholder =>
      'Trend data will appear once wallet activity has been recorded.';

  @override
  String capitalPlusCharges(String capital, String charges) {
    return 'Capital $capital + Charges $charges';
  }

  @override
  String get capitalComputation =>
      'Computation: Initial Capital/Top-ups + Total Charge Earnings';
}
