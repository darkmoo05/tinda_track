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
  /// **'GCash Wallet'**
  String get gcashWallet;

  /// No description provided for @mayaWallet.
  ///
  /// In en, this message translates to:
  /// **'Maya Wallet'**
  String get mayaWallet;

  /// No description provided for @onHandCash.
  ///
  /// In en, this message translates to:
  /// **'On-hand Cash'**
  String get onHandCash;

  /// No description provided for @chargesEarnings.
  ///
  /// In en, this message translates to:
  /// **'Charges Earnings'**
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
  /// **'Recipient Account'**
  String get accountNumber;

  /// No description provided for @searchOrEnterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get searchOrEnterAccountNumber;

  /// No description provided for @scanningReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scanning receipt…'**
  String get scanningReceipt;

  /// No description provided for @scanningReceiptModalMessage.
  ///
  /// In en, this message translates to:
  /// **'Reading image and parsing receipt data...'**
  String get scanningReceiptModalMessage;

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

  /// No description provided for @recordTransactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Setup'**
  String get recordTransactionDetails;

  /// No description provided for @optionalDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Add Reference or Notes (Optional)'**
  String get optionalDetailsSection;

  /// No description provided for @reviewTotals.
  ///
  /// In en, this message translates to:
  /// **'Total Breakdown'**
  String get reviewTotals;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get showDetails;

  /// No description provided for @hideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get hideDetails;

  /// No description provided for @whoPaysServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Fee Handling'**
  String get whoPaysServiceFee;

  /// No description provided for @customerPaysFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer bears fee'**
  String get customerPaysFeeLabel;

  /// No description provided for @deductedFromSentLabel.
  ///
  /// In en, this message translates to:
  /// **'Include in amount'**
  String get deductedFromSentLabel;

  /// No description provided for @usingWallet.
  ///
  /// In en, this message translates to:
  /// **'Using wallet'**
  String get usingWallet;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Applicable fee'**
  String get serviceFee;

  /// No description provided for @feeDestination.
  ///
  /// In en, this message translates to:
  /// **'Fee Sent To'**
  String get feeDestination;

  /// No description provided for @feeRange.
  ///
  /// In en, this message translates to:
  /// **'Fee range'**
  String get feeRange;

  /// No description provided for @amountSentToCustomerWallet.
  ///
  /// In en, this message translates to:
  /// **'Customer Total'**
  String get amountSentToCustomerWallet;

  /// No description provided for @amountCustomerSends.
  ///
  /// In en, this message translates to:
  /// **'Amount customer sends'**
  String get amountCustomerSends;

  /// No description provided for @customerPays.
  ///
  /// In en, this message translates to:
  /// **'Customer pays'**
  String get customerPays;

  /// No description provided for @cashPaidOut.
  ///
  /// In en, this message translates to:
  /// **'Cash paid out'**
  String get cashPaidOut;

  /// No description provided for @cashAddedToDrawer.
  ///
  /// In en, this message translates to:
  /// **'Your Drawer'**
  String get cashAddedToDrawer;

  /// No description provided for @feeAddedExample.
  ///
  /// In en, this message translates to:
  /// **'Service fee is added on top. Example: ₱100 transaction + ₱5 fee = collect ₱105 from customer, send ₱100.'**
  String get feeAddedExample;

  /// No description provided for @feeDeductedExample.
  ///
  /// In en, this message translates to:
  /// **'Service fee is deducted before sending. Example: ₱100 entered, ₱5 fee deducted = only ₱95 is sent to customer wallet.'**
  String get feeDeductedExample;

  /// No description provided for @accountNotInContacts.
  ///
  /// In en, this message translates to:
  /// **'This account is not in contacts yet. Tap here to add contact before saving.'**
  String get accountNotInContacts;

  /// No description provided for @saveTransactionAction.
  ///
  /// In en, this message translates to:
  /// **'Record Transaction'**
  String get saveTransactionAction;

  /// No description provided for @walletAndService.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type (Required)'**
  String get walletAndService;

  /// No description provided for @verifiedAccountFound.
  ///
  /// In en, this message translates to:
  /// **'{name} - Verified account record found'**
  String verifiedAccountFound(String name);

  /// No description provided for @onHandCashLabel.
  ///
  /// In en, this message translates to:
  /// **'On-hand cash'**
  String get onHandCashLabel;

  /// No description provided for @cashPaidOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cash you hand out to the customer from your drawer.'**
  String get cashPaidOutTooltip;

  /// No description provided for @cashAddedToDrawerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cash that goes into your drawer after this transaction.'**
  String get cashAddedToDrawerTooltip;

  /// No description provided for @noFeeRuleForAmount.
  ///
  /// In en, this message translates to:
  /// **'No fee rule for this amount yet. Fee is ₱0. Add a fee rule first.'**
  String get noFeeRuleForAmount;

  /// No description provided for @receiptDataAppliedReview.
  ///
  /// In en, this message translates to:
  /// **'Receipt data applied. Please review before saving.'**
  String get receiptDataAppliedReview;

  /// No description provided for @noFeeRangeFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No fee range found'**
  String get noFeeRangeFoundTitle;

  /// No description provided for @noFeeRangeFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The entered amount does not match any configured fee range. Please create a new fee range first.'**
  String get noFeeRangeFoundMessage;

  /// No description provided for @accountNumberRequiredBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Account number is required before saving.'**
  String get accountNumberRequiredBeforeSaving;

  /// No description provided for @transactionAmountRequiredBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Transaction amount is required before saving.'**
  String get transactionAmountRequiredBeforeSaving;

  /// No description provided for @noFeeRangeFoundForAmount.
  ///
  /// In en, this message translates to:
  /// **'No fee range found for this amount. Create a new range first.'**
  String get noFeeRangeFoundForAmount;

  /// No description provided for @amountToSendMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount to send must be greater than zero. Adjust entered amount or charge handling.'**
  String get amountToSendMustBeGreaterThanZero;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient {source} balance. Available: ₱ {amount}'**
  String insufficientBalance(String source, String amount);

  /// No description provided for @partyNotRegisteredYet.
  ///
  /// In en, this message translates to:
  /// **'Party is not registered yet. Register details first.'**
  String get partyNotRegisteredYet;

  /// No description provided for @transactionSavedSyncRetry.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved for {name}. Backend sync will retry automatically.'**
  String transactionSavedSyncRetry(String name);

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @feeValidationFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Fee validation failed{status}: {message}'**
  String feeValidationFailedStatus(String status, String message);

  /// No description provided for @feeValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Fee validation failed: {error}'**
  String feeValidationFailed(String error);

  /// No description provided for @backendPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Backend Preview Unavailable'**
  String get backendPreviewUnavailable;

  /// No description provided for @unableToValidateFeePreviewNow.
  ///
  /// In en, this message translates to:
  /// **'Unable to validate fee preview from backend right now.'**
  String get unableToValidateFeePreviewNow;

  /// No description provided for @saveLocally.
  ///
  /// In en, this message translates to:
  /// **'Save locally'**
  String get saveLocally;

  /// No description provided for @feeBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee breakdown'**
  String get feeBreakdownTitle;

  /// No description provided for @charge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get charge;

  /// No description provided for @totalCollected.
  ///
  /// In en, this message translates to:
  /// **'Total collected'**
  String get totalCollected;

  /// No description provided for @walletCredit.
  ///
  /// In en, this message translates to:
  /// **'Wallet credit'**
  String get walletCredit;

  /// No description provided for @onHandChange.
  ///
  /// In en, this message translates to:
  /// **'On-hand change'**
  String get onHandChange;

  /// No description provided for @feeRouting.
  ///
  /// In en, this message translates to:
  /// **'Where the Fee Goes'**
  String get feeRouting;

  /// No description provided for @confirmAndSave.
  ///
  /// In en, this message translates to:
  /// **'Confirm and save'**
  String get confirmAndSave;

  /// No description provided for @selectRegisteredContact.
  ///
  /// In en, this message translates to:
  /// **'Select Registered Contact'**
  String get selectRegisteredContact;

  /// No description provided for @registerPartyFirstThenSearch.
  ///
  /// In en, this message translates to:
  /// **'Register a party first, then use search to pick an account.'**
  String get registerPartyFirstThenSearch;

  /// No description provided for @tryDifferentNameOrAccount.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or account number.'**
  String get tryDifferentNameOrAccount;

  /// No description provided for @accountWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Account: {number}'**
  String accountWithNumber(String number);

  /// No description provided for @completeNameAndAccount.
  ///
  /// In en, this message translates to:
  /// **'Please complete full name and account number.'**
  String get completeNameAndAccount;

  /// No description provided for @unableToSaveParty.
  ///
  /// In en, this message translates to:
  /// **'Unable to save party. Please try again.'**
  String get unableToSaveParty;

  /// No description provided for @accountAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Account already registered.'**
  String get accountAlreadyRegistered;

  /// No description provided for @partyRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Party Registration'**
  String get partyRegistrationTitle;

  /// No description provided for @defineFinancialEntityBeforeTransaction.
  ///
  /// In en, this message translates to:
  /// **'Define a new financial entity before recording this transaction.'**
  String get defineFinancialEntityBeforeTransaction;

  /// No description provided for @loadService.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get loadService;

  /// No description provided for @payBillsService.
  ///
  /// In en, this message translates to:
  /// **'Pay Bills'**
  String get payBillsService;

  /// No description provided for @qrPaymentService.
  ///
  /// In en, this message translates to:
  /// **'QR Payment'**
  String get qrPaymentService;

  /// No description provided for @stepOneChooseWallet.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Choose wallet'**
  String get stepOneChooseWallet;

  /// No description provided for @pickWalletHelper.
  ///
  /// In en, this message translates to:
  /// **'Wallet buttons choose which account to use.'**
  String get pickWalletHelper;

  /// No description provided for @stepTwoChooseService.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Choose service'**
  String get stepTwoChooseService;

  /// No description provided for @pickServiceHelper.
  ///
  /// In en, this message translates to:
  /// **'Service buttons choose what transaction to perform.'**
  String get pickServiceHelper;

  /// No description provided for @selectedWalletService.
  ///
  /// In en, this message translates to:
  /// **'Selected: {wallet} • {service}'**
  String selectedWalletService(String wallet, String service);

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
  /// **'Wallet History'**
  String get movements;

  /// No description provided for @walletHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track GCash, Maya, and cash movements.'**
  String get walletHistorySubtitle;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get reports;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @ownerMovements.
  ///
  /// In en, this message translates to:
  /// **'Owner Activity'**
  String get ownerMovements;

  /// No description provided for @historyTransactionLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get historyTransactionLabel;

  /// No description provided for @historyOwnerActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner Activity'**
  String get historyOwnerActivityLabel;

  /// No description provided for @historyTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get historyTypeLabel;

  /// No description provided for @historyCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get historyCategoryLabel;

  /// No description provided for @historyAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get historyAccountLabel;

  /// No description provided for @historyAmountShownLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount shown'**
  String get historyAmountShownLabel;

  /// No description provided for @walletChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet change'**
  String get walletChangeLabel;

  /// No description provided for @cashChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash change'**
  String get cashChangeLabel;

  /// No description provided for @savedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved on'**
  String get savedOnLabel;

  /// No description provided for @transactionBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Transaction Breakdown'**
  String get transactionBreakdown;

  /// No description provided for @entryDetails.
  ///
  /// In en, this message translates to:
  /// **'Entry Details'**
  String get entryDetails;

  /// No description provided for @includesFee.
  ///
  /// In en, this message translates to:
  /// **'Includes fee: {amount}'**
  String includesFee(String amount);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noMatchingTransactions.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noMatchingTransactions;

  /// No description provided for @trySearchingBy.
  ///
  /// In en, this message translates to:
  /// **'Try changing the wallet, date, or search.'**
  String get trySearchingBy;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @newEntriesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your saved transactions and owner activity will appear here.'**
  String get newEntriesWillAppear;

  /// No description provided for @searchAccountRefParty.
  ///
  /// In en, this message translates to:
  /// **'Search by account, ref no.'**
  String get searchAccountRefParty;

  /// No description provided for @beginningDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get beginningDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get endDate;

  /// No description provided for @filterBeginDate.
  ///
  /// In en, this message translates to:
  /// **'Filter from date'**
  String get filterBeginDate;

  /// No description provided for @filterEndDate.
  ///
  /// In en, this message translates to:
  /// **'Filter to date'**
  String get filterEndDate;

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
  /// **'Cash on hand'**
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

  /// No description provided for @selectBeginningDate.
  ///
  /// In en, this message translates to:
  /// **'Select from date'**
  String get selectBeginningDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select to date'**
  String get selectEndDate;

  /// No description provided for @generalLedgerReport.
  ///
  /// In en, this message translates to:
  /// **'General Ledger Report'**
  String get generalLedgerReport;

  /// No description provided for @generalLedgerReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a date range, then choose PDF or Excel output.'**
  String get generalLedgerReportDescription;

  /// No description provided for @fileFormat.
  ///
  /// In en, this message translates to:
  /// **'File format'**
  String get fileFormat;

  /// No description provided for @endDateValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'To date must be the same as or later than from date.'**
  String get endDateValidationMessage;

  /// No description provided for @preparingReport.
  ///
  /// In en, this message translates to:
  /// **'Preparing report...'**
  String get preparingReport;

  /// No description provided for @noLedgerRecordsForDateRange.
  ///
  /// In en, this message translates to:
  /// **'No ledger records were found for the selected date range.'**
  String get noLedgerRecordsForDateRange;

  /// No description provided for @reportGenerationCanceled.
  ///
  /// In en, this message translates to:
  /// **'Report generation canceled. No folder was selected.'**
  String get reportGenerationCanceled;

  /// No description provided for @generatingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get generatingReport;

  /// No description provided for @reportShareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Report generated, but sharing is not available on this device. The file was saved locally.'**
  String get reportShareUnavailable;

  /// No description provided for @reportGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate the report. Please try again.'**
  String get reportGenerationFailed;

  /// No description provided for @reportSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully. Saved to {path}'**
  String reportSavedTo(String path);

  /// No description provided for @walletHistoryReport.
  ///
  /// In en, this message translates to:
  /// **'Wallet History Report'**
  String get walletHistoryReport;

  /// No description provided for @walletHistorySheetName.
  ///
  /// In en, this message translates to:
  /// **'Wallet History'**
  String get walletHistorySheetName;

  /// No description provided for @walletFlowReport.
  ///
  /// In en, this message translates to:
  /// **'Wallet Flow'**
  String get walletFlowReport;

  /// No description provided for @walletFlowSheetName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Flow'**
  String get walletFlowSheetName;

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodLabel;

  /// No description provided for @generatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get generatedLabel;

  /// No description provided for @legendTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick guide'**
  String get legendTitle;

  /// No description provided for @legendPlusMinus.
  ///
  /// In en, this message translates to:
  /// **'Use + for increase and - for decrease.'**
  String get legendPlusMinus;

  /// No description provided for @legendAmountShownNote.
  ///
  /// In en, this message translates to:
  /// **'Amount matches history. Cash out may already include fee.'**
  String get legendAmountShownNote;

  /// No description provided for @reportDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get reportDateTimeLabel;

  /// No description provided for @reportTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reportTypeLabel;

  /// No description provided for @reportAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount shown'**
  String get reportAmountLabel;

  /// No description provided for @reportFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get reportFeeLabel;

  /// No description provided for @reportWalletDeltaLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet change'**
  String get reportWalletDeltaLabel;

  /// No description provided for @reportCashDeltaLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash change'**
  String get reportCashDeltaLabel;

  /// No description provided for @reportReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Ref #'**
  String get reportReferenceLabel;

  /// No description provided for @reportDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get reportDetailsLabel;

  /// No description provided for @dateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTimeLabel;

  /// No description provided for @walletUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletUsedLabel;

  /// No description provided for @amountShownLabel.
  ///
  /// In en, this message translates to:
  /// **'History Amount'**
  String get amountShownLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @remarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarksLabel;

  /// No description provided for @moneyInLabel.
  ///
  /// In en, this message translates to:
  /// **'Money In'**
  String get moneyInLabel;

  /// No description provided for @moneyOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Money Out'**
  String get moneyOutLabel;

  /// No description provided for @feeDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee Details'**
  String get feeDetailsLabel;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @totalsLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTALS'**
  String get totalsLabel;

  /// No description provided for @gcashMovementLabel.
  ///
  /// In en, this message translates to:
  /// **'GCash Change'**
  String get gcashMovementLabel;

  /// No description provided for @mayaMovementLabel.
  ///
  /// In en, this message translates to:
  /// **'Maya Change'**
  String get mayaMovementLabel;

  /// No description provided for @cashOnHandMovementLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash Change'**
  String get cashOnHandMovementLabel;

  /// No description provided for @feesRoutedLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee Destination'**
  String get feesRoutedLabel;

  /// No description provided for @totalMoneyInLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Money In'**
  String get totalMoneyInLabel;

  /// No description provided for @totalMoneyOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Money Out'**
  String get totalMoneyOutLabel;

  /// No description provided for @netBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalanceLabel;

  /// No description provided for @totalFeesPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Fees Paid'**
  String get totalFeesPaidLabel;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder to save General Ledger report'**
  String get chooseFolder;

  /// No description provided for @chargesManagement.
  ///
  /// In en, this message translates to:
  /// **'Fee Configuration'**
  String get chargesManagement;

  /// No description provided for @setServiceFeeBrackets.
  ///
  /// In en, this message translates to:
  /// **'Manage pricing for all services'**
  String get setServiceFeeBrackets;

  /// No description provided for @configureFeesFor.
  ///
  /// In en, this message translates to:
  /// **'Configuring fees for:'**
  String get configureFeesFor;

  /// No description provided for @gcashWalletOption.
  ///
  /// In en, this message translates to:
  /// **'GCash'**
  String get gcashWalletOption;

  /// No description provided for @mayaWalletOption.
  ///
  /// In en, this message translates to:
  /// **'Maya'**
  String get mayaWalletOption;

  /// No description provided for @addNewBracket.
  ///
  /// In en, this message translates to:
  /// **'Add New Fee Tier'**
  String get addNewBracket;

  /// No description provided for @lowerBound.
  ///
  /// In en, this message translates to:
  /// **'Starting Amount (PHP)'**
  String get lowerBound;

  /// No description provided for @lowerBoundHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1000'**
  String get lowerBoundHint;

  /// No description provided for @upperBound.
  ///
  /// In en, this message translates to:
  /// **'Ending Amount (PHP)'**
  String get upperBound;

  /// No description provided for @upperBoundHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1500'**
  String get upperBoundHint;

  /// No description provided for @chargeAmount.
  ///
  /// In en, this message translates to:
  /// **'Fee Amount (PHP)'**
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

  /// No description provided for @serviceCashIn.
  ///
  /// In en, this message translates to:
  /// **'Cash-In'**
  String get serviceCashIn;

  /// No description provided for @serviceCashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash-Out'**
  String get serviceCashOut;

  /// No description provided for @serviceLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get serviceLoad;

  /// No description provided for @servicePayBills.
  ///
  /// In en, this message translates to:
  /// **'Pay Bills'**
  String get servicePayBills;

  /// No description provided for @serviceQrPayment.
  ///
  /// In en, this message translates to:
  /// **'QR Payment'**
  String get serviceQrPayment;

  /// No description provided for @selectFeeType.
  ///
  /// In en, this message translates to:
  /// **'Select fee type: {type}'**
  String selectFeeType(String type);

  /// No description provided for @selectWalletAndTransactionType.
  ///
  /// In en, this message translates to:
  /// **'Select a wallet and transaction type'**
  String get selectWalletAndTransactionType;

  /// No description provided for @feePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview: ₱{from} → Fee ₱{fee}'**
  String feePreview(String from, String fee);

  /// No description provided for @startingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Amount'**
  String get startingAmountLabel;

  /// No description provided for @endingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Ending Amount'**
  String get endingAmountLabel;

  /// No description provided for @feeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee Amount'**
  String get feeAmountLabel;

  /// No description provided for @totalTiers.
  ///
  /// In en, this message translates to:
  /// **'Total: {count} tiers'**
  String totalTiers(String count);

  /// No description provided for @smallTransactions.
  ///
  /// In en, this message translates to:
  /// **'Small Transactions'**
  String get smallTransactions;

  /// No description provided for @mediumTransactions.
  ///
  /// In en, this message translates to:
  /// **'Medium Transactions'**
  String get mediumTransactions;

  /// No description provided for @largeTransactions.
  ///
  /// In en, this message translates to:
  /// **'Large Transactions'**
  String get largeTransactions;

  /// No description provided for @availableForTransactions.
  ///
  /// In en, this message translates to:
  /// **'(Available for transactions)'**
  String get availableForTransactions;

  /// No description provided for @chargeInputInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid lower bound, upper bound, and charge amount.'**
  String get chargeInputInvalid;

  /// No description provided for @chargeBracketAdded.
  ///
  /// In en, this message translates to:
  /// **'Charge bracket added.'**
  String get chargeBracketAdded;

  /// No description provided for @chargeBracketDeleted.
  ///
  /// In en, this message translates to:
  /// **'Charge bracket deleted.'**
  String get chargeBracketDeleted;

  /// No description provided for @unableToDeleteBracket.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete bracket.'**
  String get unableToDeleteBracket;

  /// No description provided for @deleteBracketTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Bracket'**
  String get deleteBracketTitle;

  /// No description provided for @deleteBracketMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the ₱{lower}–₱{upper} charge range? This cannot be undone.'**
  String deleteBracketMessage(String lower, String upper);

  /// No description provided for @editChargeBracketTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Charge Bracket'**
  String get editChargeBracketTitle;

  /// No description provided for @editChargeBracketHint.
  ///
  /// In en, this message translates to:
  /// **'Update the exact lower and upper bounds for this charge range.'**
  String get editChargeBracketHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @chargeErrorOverlapRange.
  ///
  /// In en, this message translates to:
  /// **'This range overlaps with an existing charge bracket for this type.'**
  String get chargeErrorOverlapRange;

  /// No description provided for @chargeErrorUpdateTargetMissing.
  ///
  /// In en, this message translates to:
  /// **'Unable to update the selected bracket.'**
  String get chargeErrorUpdateTargetMissing;

  /// No description provided for @chargeErrorLowerBoundNonPositive.
  ///
  /// In en, this message translates to:
  /// **'Lower bound must be greater than zero.'**
  String get chargeErrorLowerBoundNonPositive;

  /// No description provided for @chargeErrorUpperBoundTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Upper bound must be greater than or equal to lower bound.'**
  String get chargeErrorUpperBoundTooSmall;

  /// No description provided for @chargeErrorNegative.
  ///
  /// In en, this message translates to:
  /// **'Charge amount cannot be negative.'**
  String get chargeErrorNegative;

  /// No description provided for @chargeErrorTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Charge amount cannot exceed 50% of the upper bound (max ₱{max} for a ₱{upper} upper bound).'**
  String chargeErrorTooHigh(String max, String upper);

  /// No description provided for @activeTiers.
  ///
  /// In en, this message translates to:
  /// **'Active Fee Tiers'**
  String get activeTiers;

  /// No description provided for @feeTierOverview.
  ///
  /// In en, this message translates to:
  /// **'Tier Overview'**
  String get feeTierOverview;

  /// No description provided for @switchService.
  ///
  /// In en, this message translates to:
  /// **'Switch Service'**
  String get switchService;

  /// No description provided for @tierName.
  ///
  /// In en, this message translates to:
  /// **'Tier {number}: {description}'**
  String tierName(String number, String description);

  /// No description provided for @feeAmount.
  ///
  /// In en, this message translates to:
  /// **'Fee: ₱{amount}'**
  String feeAmount(String amount);

  /// No description provided for @tierStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String tierStatus(String status);

  /// No description provided for @usedXTimes.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions used'**
  String usedXTimes(String count);

  /// No description provided for @simpleMode.
  ///
  /// In en, this message translates to:
  /// **'Simple Mode'**
  String get simpleMode;

  /// No description provided for @advancedMode.
  ///
  /// In en, this message translates to:
  /// **'Advanced Mode'**
  String get advancedMode;

  /// No description provided for @whatTheseFieldsMean.
  ///
  /// In en, this message translates to:
  /// **'What do these fields mean?'**
  String get whatTheseFieldsMean;

  /// No description provided for @startingAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'The lowest transaction amount that this fee applies to'**
  String get startingAmountHelp;

  /// No description provided for @endingAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'The highest transaction amount that this fee applies to'**
  String get endingAmountHelp;

  /// No description provided for @feeAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'How much you earn from each transaction in this range'**
  String get feeAmountHelp;

  /// No description provided for @exampleTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Example: If ₱1,500 is sent, and your tier is ₱1,000-₱2,000 with fee ₱50, you earn ₱50.'**
  String get exampleTransactionText;

  /// No description provided for @noFeeTiersTitle.
  ///
  /// In en, this message translates to:
  /// **'No Fee Tiers Configured Yet'**
  String get noFeeTiersTitle;

  /// No description provided for @noFeeTiersMessage.
  ///
  /// In en, this message translates to:
  /// **'Start earning immediately by setting up your first fee structure.'**
  String get noFeeTiersMessage;

  /// No description provided for @lastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used: {time}'**
  String lastUsed(String time);

  /// No description provided for @registeredParties.
  ///
  /// In en, this message translates to:
  /// **'Your People'**
  String get registeredParties;

  /// No description provided for @yourPeople.
  ///
  /// In en, this message translates to:
  /// **'Your People'**
  String get yourPeople;

  /// No description provided for @manageParties.
  ///
  /// In en, this message translates to:
  /// **'Manage customers & partners you work with'**
  String get manageParties;

  /// No description provided for @manageCustomersPartners.
  ///
  /// In en, this message translates to:
  /// **'Manage customers & partners you work with'**
  String get manageCustomersPartners;

  /// No description provided for @searchByNameAccount.
  ///
  /// In en, this message translates to:
  /// **'Search by name or account number...'**
  String get searchByNameAccount;

  /// No description provided for @activeEntities.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get activeEntities;

  /// No description provided for @addParty.
  ///
  /// In en, this message translates to:
  /// **'Add New Person'**
  String get addParty;

  /// No description provided for @addNewPerson.
  ///
  /// In en, this message translates to:
  /// **'Add New Person'**
  String get addNewPerson;

  /// No description provided for @noMatchingParties.
  ///
  /// In en, this message translates to:
  /// **'No people match that search'**
  String get noMatchingParties;

  /// No description provided for @tryDifferentKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try a different name or account number'**
  String get tryDifferentKeyword;

  /// No description provided for @noPartiesSaved.
  ///
  /// In en, this message translates to:
  /// **'Nobody Here Yet! 👋'**
  String get noPartiesSaved;

  /// No description provided for @localDatabaseInfo.
  ///
  /// In en, this message translates to:
  /// **'Your contact list is empty. Let\'s add your first customer or business partner.'**
  String get localDatabaseInfo;

  /// No description provided for @deleteParty.
  ///
  /// In en, this message translates to:
  /// **'Delete Person'**
  String get deleteParty;

  /// No description provided for @deletePartyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This action cannot be undone.'**
  String deletePartyConfirm(String name);

  /// No description provided for @peopleSaved.
  ///
  /// In en, this message translates to:
  /// **'people saved'**
  String get peopleSaved;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @waitingToVerify.
  ///
  /// In en, this message translates to:
  /// **'waiting to verify'**
  String get waitingToVerify;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get verificationStatus;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Verification'**
  String get statusPending;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedDate(String date);

  /// No description provided for @theirAccount.
  ///
  /// In en, this message translates to:
  /// **'Account: {account}'**
  String theirAccount(String account);

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @allPeople.
  ///
  /// In en, this message translates to:
  /// **'All People'**
  String get allPeople;

  /// No description provided for @pendingPeople.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingPeople;

  /// No description provided for @nobodyHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody Here Yet! 👋'**
  String get nobodyHereYet;

  /// No description provided for @letAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Your contact list is empty. Let\'s add your first customer or business partner.'**
  String get letAddFirst;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @partiesManagement.
  ///
  /// In en, this message translates to:
  /// **'Parties Management'**
  String get partiesManagement;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

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
  /// **'CURRENT BUSINESS CASH'**
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

  /// No description provided for @businessCashBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Wallets {wallets} + On-hand {cash} + Owner Credit {credit}'**
  String businessCashBreakdown(String wallets, String cash, String credit);

  /// No description provided for @businessCashComputation.
  ///
  /// In en, this message translates to:
  /// **'Available now for business use'**
  String get businessCashComputation;

  /// No description provided for @withdrawableEarningsNote.
  ///
  /// In en, this message translates to:
  /// **'Withdrawable earnings right now: {amount}'**
  String withdrawableEarningsNote(String amount);

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @totalStock.
  ///
  /// In en, this message translates to:
  /// **'Total Stock'**
  String get totalStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet.'**
  String get noProducts;

  /// No description provided for @searchProductHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or barcode...'**
  String get searchProductHint;

  /// No description provided for @archiveProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive this Product?'**
  String get archiveProductTitle;

  /// No description provided for @archiveProductMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be hidden from the list. It can be restored later.'**
  String archiveProductMessage(String name);

  /// No description provided for @archiveBulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive {count} products?'**
  String archiveBulkTitle(int count);

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archiveProduct.
  ///
  /// In en, this message translates to:
  /// **'Archive Product'**
  String get archiveProduct;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @selectMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select multiple'**
  String get selectMultiple;

  /// No description provided for @nSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String nSelected(int count);

  /// No description provided for @nProducts.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String nProducts(int count);

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStock;

  /// No description provided for @stockHistory.
  ///
  /// In en, this message translates to:
  /// **'Stock History'**
  String get stockHistory;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @currentStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStockLabel;

  /// No description provided for @lowStockAlertStat.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlertStat;

  /// No description provided for @noStockHistory.
  ///
  /// In en, this message translates to:
  /// **'No stock history yet.'**
  String get noStockHistory;

  /// No description provided for @productInformation.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get productInformation;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name *'**
  String get productName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @skuBarcode.
  ///
  /// In en, this message translates to:
  /// **'SKU / Barcode *'**
  String get skuBarcode;

  /// No description provided for @skuRequired.
  ///
  /// In en, this message translates to:
  /// **'SKU/barcode is required'**
  String get skuRequired;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get costPrice;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price *'**
  String get sellingPrice;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @numbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Numbers only'**
  String get numbersOnly;

  /// No description provided for @initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock'**
  String get initialStock;

  /// No description provided for @useAdjustStockToChange.
  ///
  /// In en, this message translates to:
  /// **'Use Adjust Stock to change'**
  String get useAdjustStockToChange;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @activeHelperText.
  ///
  /// In en, this message translates to:
  /// **'Will appear in the list and POS'**
  String get activeHelperText;

  /// No description provided for @productAdded.
  ///
  /// In en, this message translates to:
  /// **'Product added!'**
  String get productAdded;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated!'**
  String get productUpdated;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @stockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Stock Alerts'**
  String get stockAlerts;

  /// No description provided for @lowStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Low Stock only'**
  String get lowStockOnly;

  /// No description provided for @outOfStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock only'**
  String get outOfStockOnly;

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No change.'**
  String get noChange;

  /// No description provided for @quickAdjust.
  ///
  /// In en, this message translates to:
  /// **'Quick adjustment'**
  String get quickAdjust;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @saveStock.
  ///
  /// In en, this message translates to:
  /// **'Save Stock'**
  String get saveStock;

  /// No description provided for @manualAmount.
  ///
  /// In en, this message translates to:
  /// **'Manual amount (+ or -)'**
  String get manualAmount;

  /// No description provided for @resetBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetBtn;

  /// No description provided for @categoryAndUnit.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}  |  {unit}'**
  String categoryAndUnit(String category, String unit);

  /// No description provided for @errEmptyCart.
  ///
  /// In en, this message translates to:
  /// **'No items in checkout queue. Add items before checking out.'**
  String get errEmptyCart;

  /// No description provided for @errNegativePaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid amount cannot be negative.'**
  String get errNegativePaidAmount;

  /// No description provided for @errUnitConversionNotSet.
  ///
  /// In en, this message translates to:
  /// **'Unit {unit} is not configured for {product}.'**
  String errUnitConversionNotSet(String unit, String product);

  /// No description provided for @errEmptyRecipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients configured for recipe {product}.'**
  String errEmptyRecipeIngredients(String product);

  /// No description provided for @errInsufficientIngredientStock.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock for ingredient {ingredient} of {product}. Needed: {needed}, Available: {available}.'**
  String errInsufficientIngredientStock(
    String ingredient,
    String product,
    double needed,
    double available,
  );

  /// No description provided for @errInsufficientProductStock.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock for {product}. Needed: {needed}, Available: {available}.'**
  String errInsufficientProductStock(
    String product,
    double needed,
    double available,
  );

  /// No description provided for @errSerialSelection.
  ///
  /// In en, this message translates to:
  /// **'Please select exactly {required} serial number(s) for {product}. Selected: {selected}.'**
  String errSerialSelection(int required, String product, int selected);

  /// No description provided for @errSerialNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Serial number \"{serial}\" is not available.'**
  String errSerialNotAvailable(String serial);

  /// No description provided for @errPaidAmountInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient payment. Paid: {paid}, Total: {total}.'**
  String errPaidAmountInsufficient(double paid, double total);

  /// No description provided for @noIngredientsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No ingredients available.'**
  String get noIngredientsAvailable;

  /// No description provided for @noIngredientsSet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients set. Add ingredients below.'**
  String get noIngredientsSet;

  /// No description provided for @noSerialsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No serial numbers registered.'**
  String get noSerialsRegistered;

  /// No description provided for @noBarcodeRead.
  ///
  /// In en, this message translates to:
  /// **'No barcode detected. Try again.'**
  String get noBarcodeRead;

  /// No description provided for @noProductForBarcode.
  ///
  /// In en, this message translates to:
  /// **'No product linked to barcode \"{code}\".'**
  String noProductForBarcode(String code);

  /// No description provided for @addItemsFirst.
  ///
  /// In en, this message translates to:
  /// **'Add items to the cart before checking out.'**
  String get addItemsFirst;

  /// No description provided for @cannotCheckoutNow.
  ///
  /// In en, this message translates to:
  /// **'Cannot checkout now. Please check again.'**
  String get cannotCheckoutNow;

  /// No description provided for @insufficientPayment.
  ///
  /// In en, this message translates to:
  /// **'Insufficient payment. Please check again.'**
  String get insufficientPayment;

  /// No description provided for @checkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed: {error}'**
  String checkoutFailed(String error);

  /// No description provided for @failedToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products. Please try again.'**
  String get failedToLoadProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @lowStockWarningEditAllowed.
  ///
  /// In en, this message translates to:
  /// **'Some items are low on stock. You can still edit them before checkout.'**
  String get lowStockWarningEditAllowed;

  /// No description provided for @noSerialsAvailableForProduct.
  ///
  /// In en, this message translates to:
  /// **'No available serial numbers for this product.'**
  String get noSerialsAvailableForProduct;

  /// No description provided for @noMatchingProducts.
  ///
  /// In en, this message translates to:
  /// **'No matching products found.'**
  String get noMatchingProducts;

  /// No description provided for @scanDuplicateWarning.
  ///
  /// In en, this message translates to:
  /// **'This was scanned just recently. Scan again after a moment.'**
  String get scanDuplicateWarning;

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to queue: {product}'**
  String addedToQueue(String product);

  /// No description provided for @saleCompleteWithChange.
  ///
  /// In en, this message translates to:
  /// **'Sale complete! Change: {change}'**
  String saleCompleteWithChange(String change);

  /// No description provided for @selectSerialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select exactly {required} serial number(s). Selected: {selected}'**
  String selectSerialsRequired(int required, int selected);

  /// No description provided for @serialsLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Limit is up to {required} serials only.'**
  String serialsLimitExceeded(int required);

  /// No description provided for @continuousScan.
  ///
  /// In en, this message translates to:
  /// **'Continuous scan'**
  String get continuousScan;

  /// No description provided for @muteScanSound.
  ///
  /// In en, this message translates to:
  /// **'Mute scan sound'**
  String get muteScanSound;

  /// No description provided for @enableScanSound.
  ///
  /// In en, this message translates to:
  /// **'Enable scan sound'**
  String get enableScanSound;

  /// No description provided for @disableVibration.
  ///
  /// In en, this message translates to:
  /// **'Disable vibration'**
  String get disableVibration;

  /// No description provided for @enableVibration.
  ///
  /// In en, this message translates to:
  /// **'Enable vibration'**
  String get enableVibration;

  /// No description provided for @typeBarcodeManually.
  ///
  /// In en, this message translates to:
  /// **'Type barcode manually'**
  String get typeBarcodeManually;

  /// No description provided for @serialAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'This serial number has already been added.'**
  String get serialAlreadyAdded;

  /// No description provided for @stockMustMatchSerials.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity ({stock}) must equal the number of available serial numbers ({count}).'**
  String stockMustMatchSerials(int stock, int count);

  /// No description provided for @scanOrTypeSerial.
  ///
  /// In en, this message translates to:
  /// **'Scan or type a serial number to add.'**
  String get scanOrTypeSerial;

  /// No description provided for @businessTypeRetail.
  ///
  /// In en, this message translates to:
  /// **'Sari-Sari / Retail'**
  String get businessTypeRetail;

  /// No description provided for @businessTypeFoodService.
  ///
  /// In en, this message translates to:
  /// **'Carinderia / Food Service'**
  String get businessTypeFoodService;

  /// No description provided for @businessTypeAutoParts.
  ///
  /// In en, this message translates to:
  /// **'Auto Shop / Services'**
  String get businessTypeAutoParts;

  /// No description provided for @businessTypeHardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware Store'**
  String get businessTypeHardware;

  /// No description provided for @businessTypeMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Public Market Stall'**
  String get businessTypeMarketplace;

  /// No description provided for @businessTypeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General / Other'**
  String get businessTypeGeneral;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show Password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide Password'**
  String get hidePassword;

  /// No description provided for @usernameValidator.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 4 characters and contain only letters and numbers'**
  String get usernameValidator;

  /// No description provided for @passwordValidator.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordValidator;

  /// No description provided for @authErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the server. Please check your internet connection.'**
  String get authErrorConnection;

  /// No description provided for @authErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please try again later.'**
  String get authErrorTimeout;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Please try another one.'**
  String get authErrorUsernameTaken;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @tutorialWelcomeTitlePocketLedger.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PocketLedger!'**
  String get tutorialWelcomeTitlePocketLedger;

  /// No description provided for @tutorialWelcomeDescPocketLedger.
  ///
  /// In en, this message translates to:
  /// **'Let\'s take a quick 1-minute tour to see how to track your cash drawer and digital wallets (GCash/Maya) easily!'**
  String get tutorialWelcomeDescPocketLedger;

  /// No description provided for @tutorialCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Business Cash'**
  String get tutorialCashTitle;

  /// No description provided for @tutorialCashDesc.
  ///
  /// In en, this message translates to:
  /// **'This shows the total money you have available to run your shop. It combines your GCash, Maya, and physical On-hand Cash, minus any personal expenses you withdrew.'**
  String get tutorialCashDesc;

  /// No description provided for @tutorialWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'GCash, Maya & On-hand Cash'**
  String get tutorialWalletsTitle;

  /// No description provided for @tutorialWalletsDesc.
  ///
  /// In en, this message translates to:
  /// **'GCash and Maya are digital money in your phone. On-hand Cash is the physical cash in your drawer. When a customer pays you cash to cash-in, your GCash goes down, but your cash drawer goes up!'**
  String get tutorialWalletsDesc;

  /// No description provided for @tutorialSampleTitlePocketLedger.
  ///
  /// In en, this message translates to:
  /// **'See it in Action!'**
  String get tutorialSampleTitlePocketLedger;

  /// No description provided for @tutorialSampleDescPocketLedger.
  ///
  /// In en, this message translates to:
  /// **'Would you like to pre-populate a sample transaction (e.g. ₱100 GCash Cash-In with a ₱10 fee) to see how the dashboard, charts, and collected fees update instantly?'**
  String get tutorialSampleDescPocketLedger;

  /// No description provided for @addSampleDataButton.
  ///
  /// In en, this message translates to:
  /// **'Add Sample Transaction'**
  String get addSampleDataButton;

  /// No description provided for @startEmptyButton.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh (Empty)'**
  String get startEmptyButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;
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
