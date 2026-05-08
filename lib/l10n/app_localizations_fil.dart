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
  String get gcashWallet => 'GCASH WALLET';

  @override
  String get mayaWallet => 'MAYA WALLET';

  @override
  String get onHandCash => 'CASH SA KAMAY';

  @override
  String get chargesEarnings => 'KITA SA BAYAD';

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
  String get accountNumber => 'Numero ng Account';

  @override
  String get searchOrEnterAccountNumber =>
      'Maghanap o maglagay ng numero ng account';

  @override
  String get scanningReceipt => 'Nini-scan ang resibo…';

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
  String get movements => 'Mga Galaw';

  @override
  String get reports => 'Mga Ulat';

  @override
  String get transactions => 'MGA TRANSAKSYON';

  @override
  String get ownerMovements => 'MGA GALAW NG MAY-ARI';

  @override
  String get noMatchingTransactions => 'Walang katugmang transaksyon';

  @override
  String get trySearchingBy =>
      'Subukang maghanap ayon sa pamagat, numero ng account, ID ng sanggunian, tala, o petsa.';

  @override
  String get noHistoryYet => 'Wala pang kasaysayan';

  @override
  String get newEntriesWillAppear =>
      'Lalabas ang mga bagong entry dito kapag nai-save mo ang mga transaksyon o galaw ng may-ari.';

  @override
  String get searchAccountRefParty =>
      'Maghanap ng account, ref ID, partido, o tala';

  @override
  String get beginningDate => 'Petsa ng Simula';

  @override
  String get endDate => 'Petsa ng Katapusan';

  @override
  String get gcash => 'GCash';

  @override
  String get maya => 'Maya';

  @override
  String get onHand => 'Sa Kamay';

  @override
  String get pdf => 'PDF';

  @override
  String get excel => 'Excel';

  @override
  String get generate => 'Gumawa';

  @override
  String get close => 'Isara';

  @override
  String get chooseFolder => 'Pumili ng folder para sa ulat ng General Ledger';

  @override
  String get chargesManagement => 'Pamamahala ng Bayad';

  @override
  String get setServiceFeeBrackets =>
      'Itakda ang mga bracket ng bayad sa serbisyo para sa bawat uri ng transaksyon nang hiwalay.';

  @override
  String get configureFeesFor => 'I-configure ang Bayad Para sa';

  @override
  String get gcashWalletOption => 'GCash Wallet';

  @override
  String get mayaWalletOption => 'Maya Wallet';

  @override
  String get addNewBracket => 'Magdagdag ng Bagong Bracket';

  @override
  String get lowerBound => 'Pinakamababang Hangganan (PHP)';

  @override
  String get lowerBoundHint => 'hal. 1000';

  @override
  String get upperBound => 'Pinakamataas na Hangganan (PHP)';

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
  String get registeredParties => 'Mga Nakarehistrong Partido';

  @override
  String get manageParties =>
      'Pamahalaan ang inyong ecosystem ng customer at mga kasamahan.';

  @override
  String get activeEntities => 'MGA AKTIBONG ENTITY';

  @override
  String get addParty => 'MAGDAGDAG NG PARTIDO';

  @override
  String get noMatchingParties => 'Walang nahanap na katugmang partido';

  @override
  String get tryDifferentKeyword =>
      'Subukan ang ibang keyword para sa pangalan, entity ID, account, o paglalarawan.';

  @override
  String get noPartiesSaved => 'Wala pang nakarehistrong partido';

  @override
  String get localDatabaseInfo =>
      'Ipinapakita na lang ng screen na ito ang mga rekord na nakaimbak sa iyong lokal na database.';

  @override
  String get deleteParty => 'Burahin ang Partido';

  @override
  String deletePartyConfirm(String name) {
    return 'Sigurado ka bang gusto mong burahin ang \"$name\"? Hindi na mababawi ang pagkilos na ito.';
  }

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
  String get totalFunds => 'KABUUANG PONDO';

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
  String get borrowingStatus => 'Katayuan ng Pagpapahiram';

  @override
  String ownerCreditOutstanding(String amount) {
    return 'Natitirang Utang ng May-ari: $amount';
  }

  @override
  String get walletTrendPlaceholder =>
      'Lalabas ang data ng trend kapag may naitala nang aktibidad sa pitaka.';

  @override
  String capitalPlusCharges(String capital, String charges) {
    return 'Puhunan $capital + Bayad $charges';
  }

  @override
  String get capitalComputation =>
      'Pagkukuwenta: Paunang Puhunan/Top-ups + Kabuuang Kita sa Bayad';
}
