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
  String get gcashWallet => 'GCASH WALLET';

  @override
  String get mayaWallet => 'MAYA WALLET';

  @override
  String get onHandCash => 'CASH SA KAMOT';

  @override
  String get chargesEarnings => 'KITA SA BAYAD';

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
  String get accountNumber => 'Numero sa Account';

  @override
  String get searchOrEnterAccountNumber =>
      'Pangita o isulat ang numero sa account';

  @override
  String get scanningReceipt => 'Gi-scan ang resibo…';

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
  String get delete => 'Tangtangon';

  @override
  String get categoryDeleted => 'Natangtang ang kategorya.';

  @override
  String get enterCategoryName => 'Isulat ang ngalan sa kategorya.';

  @override
  String get movementTypePending => 'Wala pay napiling klase';

  @override
  String get categoryPending => 'Wala pay napiling kategorya';

  @override
  String get movements => 'Mga Lihok';

  @override
  String get reports => 'Mga Taho';

  @override
  String get transactions => 'MGA TRANSAKSYON';

  @override
  String get ownerMovements => 'MGA LIHOK SA TAG-IYA';

  @override
  String get noMatchingTransactions => 'Walay katugmang transaksyon';

  @override
  String get trySearchingBy =>
      'Sulayi ang pagpangita pinaagi sa titulo, numero sa account, ID sa reperensiya, nota, o petsa.';

  @override
  String get noHistoryYet => 'Wala pay kasaysayan';

  @override
  String get newEntriesWillAppear =>
      'Makita ang mga bag-ong entry dinhi kung maka-save ka na ug mga transaksyon o lihok sa tag-iya.';

  @override
  String get searchAccountRefParty =>
      'Pangita ug account, ref ID, party, o nota';

  @override
  String get beginningDate => 'Petsa sa Sugod';

  @override
  String get endDate => 'Petsa sa Katapusan';

  @override
  String get gcash => 'GCash';

  @override
  String get maya => 'Maya';

  @override
  String get onHand => 'Sa Kamot';

  @override
  String get pdf => 'PDF';

  @override
  String get excel => 'Excel';

  @override
  String get generate => 'Gumawa';

  @override
  String get close => 'Isira';

  @override
  String get chooseFolder => 'Pilia ang folder alang sa taho sa General Ledger';

  @override
  String get chargesManagement => 'Pagdumala sa Bayad';

  @override
  String get setServiceFeeBrackets =>
      'Itakda ang mga bracket sa bayad sa serbisyo alang sa matag klase sa transaksyon.';

  @override
  String get configureFeesFor => 'I-configure ang Bayad Alang sa';

  @override
  String get gcashWalletOption => 'GCash Wallet';

  @override
  String get mayaWalletOption => 'Maya Wallet';

  @override
  String get addNewBracket => 'Magdugang ug Bag-ong Bracket';

  @override
  String get lowerBound => 'Pinakaubos nga Utlanan (PHP)';

  @override
  String get lowerBoundHint => 'ex. 1000';

  @override
  String get upperBound => 'Pinakataas nga Utlanan (PHP)';

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
  String get registeredParties => 'Mga Naarehistrong Party';

  @override
  String get manageParties =>
      'Dumala ang imong ecosystem sa customer ug mga kasamahan.';

  @override
  String get activeEntities => 'MGA AKTIBONG ENTITY';

  @override
  String get addParty => 'MAGDUGANG UG PARTY';

  @override
  String get noMatchingParties => 'Walay nakit-an nga katugmang party';

  @override
  String get tryDifferentKeyword =>
      'Sulayi ang lain nga keyword alang sa ngalan, entity ID, account, o deskripsyon.';

  @override
  String get noPartiesSaved => 'Wala pay naarehistrong party';

  @override
  String get localDatabaseInfo =>
      'Gipakita na lang sa screen nga kini ang mga rekord nga gitipigan sa imong lokal nga database.';

  @override
  String get deleteParty => 'Tangtangon ang Party';

  @override
  String deletePartyConfirm(String name) {
    return 'Sigurado ka ba nga gusto mong tangtangon ang \"$name\"? Dili na kini mabawi.';
  }

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
  String get totalFunds => 'KINATIBUK-ANG PONDO';

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
  String get borrowingStatus => 'Kahimtang sa Pagpahulam';

  @override
  String ownerCreditOutstanding(String amount) {
    return 'Nahibilin nga Utang sa Tag-iya: $amount';
  }

  @override
  String get walletTrendPlaceholder =>
      'Makita ang trend data kung adunay narekord na aktibidad sa pitaka.';

  @override
  String capitalPlusCharges(String capital, String charges) {
    return 'Kapital $capital + Bayad $charges';
  }

  @override
  String get capitalComputation =>
      'Pagkwenta: Unang Kapital/Top-ups + Kinatibuk-ang Kita sa Bayad';
}
