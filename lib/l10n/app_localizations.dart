import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ceb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ceb'),
    Locale('en'),
    Locale('fil'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PocketLedger'**
  String get appTitle;

  /// No description provided for @syncingData.
  ///
  /// In en, this message translates to:
  /// **'Syncing your data…'**
  String get syncingData;

  /// No description provided for @walletOverview.
  ///
  /// In en, this message translates to:
  /// **'Wallet Overview'**
  String get walletOverview;

  /// No description provided for @gcashWallet.
  ///
  /// In en, this message translates to:
  /// **'GCASH WALLET'**
  String get gcashWallet;

  /// No description provided for @mayaWallet.
  ///
  /// In en, this message translates to:
  /// **'MAYA WALLET'**
  String get mayaWallet;

  /// No description provided for @onHandCash.
  ///
  /// In en, this message translates to:
  /// **'ON-HAND CASH'**
  String get onHandCash;

  /// No description provided for @chargesEarnings.
  ///
  /// In en, this message translates to:
  /// **'CHARGES EARNINGS'**
  String get chargesEarnings;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @physicalCash.
  ///
  /// In en, this message translates to:
  /// **'Physical cash'**
  String get physicalCash;

  /// No description provided for @walletCashBalanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Wallet and Cash Balance Trend'**
  String get walletCashBalanceTrend;

  /// No description provided for @borrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowed;

  /// No description provided for @repaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get repaid;

  /// No description provided for @totalPersonalFundsTaken.
  ///
  /// In en, this message translates to:
  /// **'Total personal funds taken by owner'**
  String get totalPersonalFundsTaken;

  /// No description provided for @totalPersonalFundsReturned.
  ///
  /// In en, this message translates to:
  /// **'Total personal funds returned to business'**
  String get totalPersonalFundsReturned;

  /// No description provided for @unableToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Unable to load dashboard right now.'**
  String get unableToLoadDashboard;

  /// No description provided for @noDashboardData.
  ///
  /// In en, this message translates to:
  /// **'No dashboard data available yet.'**
  String get noDashboardData;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @recordTransaction.
  ///
  /// In en, this message translates to:
  /// **'Record Transaction'**
  String get recordTransaction;

  /// No description provided for @transactionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionTypeLabel;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @searchOrEnterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Search or enter account number'**
  String get searchOrEnterAccountNumber;

  /// No description provided for @scanningReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scanning receipt…'**
  String get scanningReceipt;

  /// No description provided for @scanReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt (Camera/Gallery)'**
  String get scanReceiptButton;

  /// No description provided for @transactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Transaction Amount'**
  String get transactionAmount;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @enterReferenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter receipt / reference number'**
  String get enterReferenceNumber;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Optional notes...'**
  String get optionalNotes;

  /// No description provided for @useCamera.
  ///
  /// In en, this message translates to:
  /// **'Use Camera'**
  String get useCamera;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the receipt'**
  String get takePicture;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @chooseExistingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose existing screenshot/photo'**
  String get chooseExistingPhoto;

  /// No description provided for @browseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse Files'**
  String get browseFiles;

  /// No description provided for @pickFromAnyFolder.
  ///
  /// In en, this message translates to:
  /// **'Pick from any folder'**
  String get pickFromAnyFolder;

  /// No description provided for @receiptScanResult.
  ///
  /// In en, this message translates to:
  /// **'Receipt Scan Result'**
  String get receiptScanResult;

  /// No description provided for @receiptScanDescription.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what was found on your receipt:'**
  String get receiptScanDescription;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account / Name'**
  String get accountName;

  /// No description provided for @accountId.
  ///
  /// In en, this message translates to:
  /// **'Account / ID'**
  String get accountId;

  /// No description provided for @referenceNo.
  ///
  /// In en, this message translates to:
  /// **'Reference No.'**
  String get referenceNo;

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletLabel;

  /// No description provided for @noRecognizableData.
  ///
  /// In en, this message translates to:
  /// **'No recognizable data was found on this receipt.'**
  String get noRecognizableData;

  /// No description provided for @noteWillBeAdded.
  ///
  /// In en, this message translates to:
  /// **'Note that will be added:'**
  String get noteWillBeAdded;

  /// No description provided for @reviewAndEdit.
  ///
  /// In en, this message translates to:
  /// **'Review and edit the filled fields before saving.'**
  String get reviewAndEdit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @customerPaysFee.
  ///
  /// In en, this message translates to:
  /// **'Customer Pays the Fee'**
  String get customerPaysFee;

  /// No description provided for @deductFeeFromSent.
  ///
  /// In en, this message translates to:
  /// **'Deduct Fee from Sent Amount'**
  String get deductFeeFromSent;

  /// No description provided for @goToCharges.
  ///
  /// In en, this message translates to:
  /// **'Go to Charges'**
  String get goToCharges;

  /// No description provided for @searchNameOrAccount.
  ///
  /// In en, this message translates to:
  /// **'Search name or account number'**
  String get searchNameOrAccount;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFound;

  /// No description provided for @noMatchingContact.
  ///
  /// In en, this message translates to:
  /// **'No matching contact'**
  String get noMatchingContact;

  /// No description provided for @fullNameEntity.
  ///
  /// In en, this message translates to:
  /// **'Full Name / Entity'**
  String get fullNameEntity;

  /// No description provided for @enterPartyFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter party full name'**
  String get enterPartyFullName;

  /// No description provided for @enterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter account number'**
  String get enterAccountNumber;

  /// No description provided for @searchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get searchContacts;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @registerParty.
  ///
  /// In en, this message translates to:
  /// **'Register Party'**
  String get registerParty;

  /// No description provided for @partyRegisteredSaving.
  ///
  /// In en, this message translates to:
  /// **'Party registered. Saving transaction now...'**
  String get partyRegisteredSaving;

  /// No description provided for @unableToVerifyRegistration.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify registration. Please try again.'**
  String get unableToVerifyRegistration;

  /// No description provided for @unableToSaveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Unable to save transaction. Please try again.'**
  String get unableToSaveTransaction;

  /// No description provided for @transactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved for {name}.'**
  String transactionSaved(String name);

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select service: {service}'**
  String selectService(String service);

  /// No description provided for @customerReceives.
  ///
  /// In en, this message translates to:
  /// **'Customer Receives'**
  String get customerReceives;

  /// No description provided for @customerSends.
  ///
  /// In en, this message translates to:
  /// **'Customer Sends'**
  String get customerSends;

  /// No description provided for @newOwnerMovement.
  ///
  /// In en, this message translates to:
  /// **'New Money Record'**
  String get newOwnerMovement;

  /// No description provided for @recordOwnerMovement.
  ///
  /// In en, this message translates to:
  /// **'Record a Money Entry'**
  String get recordOwnerMovement;

  /// No description provided for @phase3Description.
  ///
  /// In en, this message translates to:
  /// **'Track money you put in, took out, or borrowed from your business wallets.'**
  String get phase3Description;

  /// No description provided for @movementType.
  ///
  /// In en, this message translates to:
  /// **'What did you do?'**
  String get movementType;

  /// No description provided for @chooseMovementType.
  ///
  /// In en, this message translates to:
  /// **'Choose what happened'**
  String get chooseMovementType;

  /// No description provided for @moneyDirection.
  ///
  /// In en, this message translates to:
  /// **'What this does'**
  String get moneyDirection;

  /// No description provided for @cashIn.
  ///
  /// In en, this message translates to:
  /// **'Cash In'**
  String get cashIn;

  /// No description provided for @cashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash Out'**
  String get cashOut;

  /// No description provided for @borrowFrom.
  ///
  /// In en, this message translates to:
  /// **'Borrow From'**
  String get borrowFrom;

  /// No description provided for @repayTo.
  ///
  /// In en, this message translates to:
  /// **'Repay To'**
  String get repayTo;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @sourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Taken from'**
  String get sourceAccount;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @addCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a spending category first (e.g. Food, Transport).'**
  String get addCategoryFirst;

  /// No description provided for @chooseExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose Expense Category'**
  String get chooseExpenseCategory;

  /// No description provided for @referenceOptional.
  ///
  /// In en, this message translates to:
  /// **'Reference (Optional)'**
  String get referenceOptional;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional details...'**
  String get additionalDetails;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename Category'**
  String get renameCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @existingCategories.
  ///
  /// In en, this message translates to:
  /// **'Existing Categories'**
  String get existingCategories;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted.'**
  String get categoryDeleted;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name.'**
  String get enterCategoryName;

  /// No description provided for @movementTypePending.
  ///
  /// In en, this message translates to:
  /// **'No type selected yet'**
  String get movementTypePending;

  /// No description provided for @categoryPending.
  ///
  /// In en, this message translates to:
  /// **'No category selected'**
  String get categoryPending;

  /// No description provided for @movements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get movements;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTIONS'**
  String get transactions;

  /// No description provided for @ownerMovements.
  ///
  /// In en, this message translates to:
  /// **'OWNER MOVEMENTS'**
  String get ownerMovements;

  /// No description provided for @noMatchingTransactions.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get noMatchingTransactions;

  /// No description provided for @trySearchingBy.
  ///
  /// In en, this message translates to:
  /// **'Try searching by title, account number, reference ID, notes, or date.'**
  String get trySearchingBy;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @newEntriesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'New entries will appear here once you save transactions or owner movements.'**
  String get newEntriesWillAppear;

  /// No description provided for @searchAccountRefParty.
  ///
  /// In en, this message translates to:
  /// **'Search account, ref ID, party, or note'**
  String get searchAccountRefParty;

  /// No description provided for @beginningDate.
  ///
  /// In en, this message translates to:
  /// **'Beginning Date'**
  String get beginningDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @gcash.
  ///
  /// In en, this message translates to:
  /// **'GCash'**
  String get gcash;

  /// No description provided for @maya.
  ///
  /// In en, this message translates to:
  /// **'Maya'**
  String get maya;

  /// No description provided for @onHand.
  ///
  /// In en, this message translates to:
  /// **'On-hand'**
  String get onHand;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @excel.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get excel;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder to save General Ledger report'**
  String get chooseFolder;

  /// No description provided for @chargesManagement.
  ///
  /// In en, this message translates to:
  /// **'Charges Management'**
  String get chargesManagement;

  /// No description provided for @setServiceFeeBrackets.
  ///
  /// In en, this message translates to:
  /// **'Set service fee brackets for each transaction type separately.'**
  String get setServiceFeeBrackets;

  /// No description provided for @configureFeesFor.
  ///
  /// In en, this message translates to:
  /// **'Configure Fees For'**
  String get configureFeesFor;

  /// No description provided for @gcashWalletOption.
  ///
  /// In en, this message translates to:
  /// **'GCash Wallet'**
  String get gcashWalletOption;

  /// No description provided for @mayaWalletOption.
  ///
  /// In en, this message translates to:
  /// **'Maya Wallet'**
  String get mayaWalletOption;

  /// No description provided for @addNewBracket.
  ///
  /// In en, this message translates to:
  /// **'Add New Bracket'**
  String get addNewBracket;

  /// No description provided for @lowerBound.
  ///
  /// In en, this message translates to:
  /// **'Lower Bound (PHP)'**
  String get lowerBound;

  /// No description provided for @lowerBoundHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1000'**
  String get lowerBoundHint;

  /// No description provided for @upperBound.
  ///
  /// In en, this message translates to:
  /// **'Upper Bound (PHP)'**
  String get upperBound;

  /// No description provided for @upperBoundHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1500'**
  String get upperBoundHint;

  /// No description provided for @chargeAmount.
  ///
  /// In en, this message translates to:
  /// **'Charge Amount (PHP)'**
  String get chargeAmount;

  /// No description provided for @chargeAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 25.00'**
  String get chargeAmountHint;

  /// No description provided for @backToTransaction.
  ///
  /// In en, this message translates to:
  /// **'Back to transaction'**
  String get backToTransaction;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get openMenu;

  /// No description provided for @dailyEarningsTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily Earnings Trend'**
  String get dailyEarningsTrend;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @registeredParties.
  ///
  /// In en, this message translates to:
  /// **'Registered Parties'**
  String get registeredParties;

  /// No description provided for @manageParties.
  ///
  /// In en, this message translates to:
  /// **'Manage your customer ecosystem and entity associations.'**
  String get manageParties;

  /// No description provided for @activeEntities.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ENTITIES'**
  String get activeEntities;

  /// No description provided for @addParty.
  ///
  /// In en, this message translates to:
  /// **'ADD PARTY'**
  String get addParty;

  /// No description provided for @noMatchingParties.
  ///
  /// In en, this message translates to:
  /// **'No matching parties found'**
  String get noMatchingParties;

  /// No description provided for @tryDifferentKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword for name, entity ID, account, or description.'**
  String get tryDifferentKeyword;

  /// No description provided for @noPartiesSaved.
  ///
  /// In en, this message translates to:
  /// **'No parties saved yet'**
  String get noPartiesSaved;

  /// No description provided for @localDatabaseInfo.
  ///
  /// In en, this message translates to:
  /// **'This screen now shows only records stored in your local database.'**
  String get localDatabaseInfo;

  /// No description provided for @deleteParty.
  ///
  /// In en, this message translates to:
  /// **'Delete Party'**
  String get deleteParty;

  /// No description provided for @deletePartyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deletePartyConfirm(String name);

  /// No description provided for @backupSync.
  ///
  /// In en, this message translates to:
  /// **'Backup & Sync'**
  String get backupSync;

  /// No description provided for @serverConnection.
  ///
  /// In en, this message translates to:
  /// **'Server connection'**
  String get serverConnection;

  /// No description provided for @serverUrlInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter the base URL of your Tinda Tracker server. Use your local IP (e.g. http://192.168.1.24:8080/api) when the device is on the same Wi-Fi as your computer.'**
  String get serverUrlInstruction;

  /// No description provided for @serverApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Server API URL'**
  String get serverApiUrl;

  /// No description provided for @serverApiUrlHint.
  ///
  /// In en, this message translates to:
  /// **'http://192.168.1.x:8080/api'**
  String get serverApiUrlHint;

  /// No description provided for @saveUrl.
  ///
  /// In en, this message translates to:
  /// **'Save URL'**
  String get saveUrl;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync data'**
  String get syncData;

  /// No description provided for @syncInstruction.
  ///
  /// In en, this message translates to:
  /// **'Push local changes to the server and pull updates from other devices.'**
  String get syncInstruction;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @serverUrlSaved.
  ///
  /// In en, this message translates to:
  /// **'Server URL saved.'**
  String get serverUrlSaved;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed — pushed {pushed}, pulled {pulled}.'**
  String syncCompleted(int pushed, int pulled);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(Object error);

  /// No description provided for @localBackup.
  ///
  /// In en, this message translates to:
  /// **'Local backup'**
  String get localBackup;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackup;

  /// No description provided for @aboutPocketLedger.
  ///
  /// In en, this message translates to:
  /// **'About PocketLedger'**
  String get aboutPocketLedger;

  /// No description provided for @pocketLedgerDescription.
  ///
  /// In en, this message translates to:
  /// **'PocketLedger helps you track transactions, owner movements, and business cash flow in one place.'**
  String get pocketLedgerDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @buildInfo.
  ///
  /// In en, this message translates to:
  /// **'Build for Android, iOS, and desktop platforms'**
  String get buildInfo;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your display name, contact details, and business identity settings.'**
  String get profileDescription;

  /// No description provided for @quickNavigation.
  ///
  /// In en, this message translates to:
  /// **'Quick navigation'**
  String get quickNavigation;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @recordOwnerMovementFab.
  ///
  /// In en, this message translates to:
  /// **'Record a Money Entry'**
  String get recordOwnerMovementFab;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFilipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get languageFilipino;

  /// No description provided for @languageCebuano.
  ///
  /// In en, this message translates to:
  /// **'Cebuano'**
  String get languageCebuano;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @totalFunds.
  ///
  /// In en, this message translates to:
  /// **'TOTAL FUNDS'**
  String get totalFunds;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get filterBusiness;

  /// No description provided for @filterPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get filterPersonal;

  /// No description provided for @filterTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get filterTransactions;

  /// No description provided for @noActivitiesFilter.
  ///
  /// In en, this message translates to:
  /// **'No activities match the selected filter yet.'**
  String get noActivitiesFilter;

  /// No description provided for @borrowingStatus.
  ///
  /// In en, this message translates to:
  /// **'Borrowing Status'**
  String get borrowingStatus;

  /// No description provided for @ownerCreditOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Owner Credit Outstanding: {amount}'**
  String ownerCreditOutstanding(String amount);

  /// No description provided for @walletTrendPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Trend data will appear once wallet activity has been recorded.'**
  String get walletTrendPlaceholder;

  /// No description provided for @capitalPlusCharges.
  ///
  /// In en, this message translates to:
  /// **'Capital {capital} + Charges {charges}'**
  String capitalPlusCharges(String capital, String charges);

  /// No description provided for @capitalComputation.
  ///
  /// In en, this message translates to:
  /// **'Computation: Initial Capital/Top-ups + Total Charge Earnings'**
  String get capitalComputation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ceb':
      return AppLocalizationsCeb();
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
