import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/data/app_database.dart';
import '../../core/app_theme.dart';
import '../../core/l10n_extension.dart';
import '../../shared/receipt_scan/receipt_draft.dart';
import '../../shared/receipt_scan/receipt_scan_button.dart';
import '../../shared/receipt_scan/receipt_scan_service.dart';
import '../charges/data/charge_repository.dart';
import '../charges/charges_screen.dart';
import '../parties/data/party_repository.dart';
import 'data/transaction_repository.dart';
import 'data/transaction_models.dart';

enum _ChargeHandlingMode { addOnTop, deductFromEnteredAmount }

enum _WalletSelection { gcash, maya }

enum _FlowDirection { inflow, outflow }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const List<MapEntry<String, String>> _serviceOptions = [
    MapEntry('cashin', 'Cash-In'),
    MapEntry('cashout', 'Cash-Out'),
    MapEntry('load', 'Load'),
    MapEntry('paybills', 'Pay Bills'),
    MapEntry('qrpayment', 'QR Payment'),
  ];

  final _accountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _principalController = TextEditingController();
  final _notesController = TextEditingController();
  final PartyRepository _partyRepository = PartyRepository.instance;
  final ChargeRepository _chargeRepository = ChargeRepository.instance;
  final TransactionRepository _transactionRepository =
      TransactionRepository.instance;
  final AppDatabase _database = AppDatabase.instance;
  bool _missingRangeAlertVisible = false;
  bool _missingRangeAlertShownForCurrentInput = false;
  String? _lastScannedAccountName;
  bool _showRequiredIndicators = false;
  bool _isSaving = false;
  TransactionPreviewResponse? _lastPreview;
  String? _previewErrorMessage;
  _ChargeHandlingMode _chargeHandlingMode = _ChargeHandlingMode.addOnTop;

  String _selectedTypeKey = 'gcash_cashin';
  PartyRecord? _matchedParty;

  _WalletSelection get _selectedWallet {
    return FixedTransactionType.forKey(_selectedTypeKey).wallet == 'Maya Wallet'
        ? _WalletSelection.maya
        : _WalletSelection.gcash;
  }

  _FlowDirection get _selectedFlowDirection {
    return FixedTransactionType.forKey(_selectedTypeKey).isOutflow
        ? _FlowDirection.outflow
        : _FlowDirection.inflow;
  }

  ChargeBracketRecord? get _matchedChargeBracket {
    final principal = double.tryParse(_principalController.text) ?? 0;
    if (principal <= 0) {
      return null;
    }

    for (final bracket in _chargeRepository.brackets.value) {
      if (bracket.transactionTypeKey != _selectedTypeKey) continue;
      if (principal >= bracket.lowerBound && principal <= bracket.upperBound) {
        return bracket;
      }
    }
    return null;
  }

  double get _chargeFee {
    final principal = double.tryParse(_principalController.text) ?? 0;
    if (principal <= 0) {
      return 0;
    }
    return _matchedChargeBracket?.chargeAmount ?? 0;
  }

  double get _enteredAmount {
    return double.tryParse(_principalController.text) ?? 0;
  }

  double get _amountToSend {
    if (_effectiveChargeHandlingMode ==
        _ChargeHandlingMode.deductFromEnteredAmount) {
      final amount = _enteredAmount - _chargeFee;
      return amount > 0 ? amount : 0;
    }
    return _enteredAmount;
  }

  double get _totalCollected {
    if (_effectiveChargeHandlingMode ==
        _ChargeHandlingMode.deductFromEnteredAmount) {
      return _enteredAmount;
    }
    return _enteredAmount + _chargeFee;
  }

  String get _selectedService {
    return _selectedTypeKey.replaceFirst(
      _selectedTypeKey.startsWith('maya_') ? 'maya_' : 'gcash_',
      '',
    );
  }

  bool get _canCustomizeFeeHandling {
    return _selectedService == 'cashin' || _selectedService == 'cashout';
  }

  _ChargeHandlingMode get _effectiveChargeHandlingMode {
    if (_canCustomizeFeeHandling) {
      return _chargeHandlingMode;
    }
    return _ChargeHandlingMode.addOnTop;
  }

  double get _netCashToDrawer {
    return _isOutflowSelection ? _amountToSend : _totalCollected;
  }

  String get _chargeDestinationAccount {
    // Inflow: fee always goes to on-hand (store receives cash)
    // Outflow: fee always goes to wallet (customer's wallet is charged)
    return _isOutflowSelection ? _selectedWalletAccount : 'On-hand Cash';
  }

  bool get _hasTypedAccount => _accountController.text.trim().isNotEmpty;

  bool get _isRegisteredAccount => _matchedParty != null;

  bool get _isAccountNumberMissing =>
      _showRequiredIndicators && _accountController.text.trim().isEmpty;

  bool get _isPrincipalMissing =>
      _showRequiredIndicators &&
      (double.tryParse(_principalController.text.trim()) ?? 0) <= 0;

  bool get _isOutflowSelection =>
      _selectedFlowDirection == _FlowDirection.outflow;

  String get _selectedWalletAccount {
    return _selectedWallet == _WalletSelection.maya ? 'Maya Wallet' : 'GCash';
  }

  Color get _selectedWalletColor {
    return _selectedWalletAccount == 'Maya Wallet'
        ? AppColors.secondary
        : AppColors.primary;
  }

  String get _selectedFlowLabel {
    return _isOutflowSelection
        ? 'Customer Receives from Wallet'
        : 'Customer Sends to Wallet';
  }

  String get _pesoLabel => '\u20B1';

  @override
  void initState() {
    super.initState();
    _partyRepository.ensureLoaded().then((_) {
      if (!mounted) {
        return;
      }
      if (_accountController.text.trim().isNotEmpty) {
        _resolvePartyFromAccount(_accountController.text);
      }
    });
    _chargeRepository.ensureLoaded().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _referenceController.dispose();
    _principalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.newEntry,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                context.l10n.recordTransaction,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _accountController,
                      label: context.l10n.accountNumber,
                      hint: context.l10n.searchOrEnterAccountNumber,
                      suffixIcon: Icons.search_rounded,
                      onSuffixPressed: _openAccountSearchPicker,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _resolvePartyFromAccount,
                      isRequired: true,
                      hasError: _isAccountNumberMissing,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ReceiptScanButton(
                        onDraftReady: _applyReceiptDraft,
                      ),
                    ),
                    if (_hasTypedAccount && _isRegisteredAccount) ...[
                      const SizedBox(height: 8),
                      _buildPartyFoundBanner(_matchedParty!.name),
                    ] else if (_hasTypedAccount) ...[
                      const SizedBox(height: 8),
                      _buildPartyNotRegisteredAlert(),
                    ],
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _principalController,
                      label: context.l10n.transactionAmount,
                      hint: '0.00',
                      prefixText: '$_pesoLabel  ',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: _onPrincipalChanged,
                      isRequired: true,
                      hasError: _isPrincipalMissing,
                    ),
                    if (_canCustomizeFeeHandling) ...[
                      const SizedBox(height: 16),
                      _buildChargeHandlingSelector(),
                    ],
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _referenceController,
                      label: context.l10n.referenceOptional,
                      hint: context.l10n.enterReferenceNumber,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _notesController,
                      label: context.l10n.notesOptional,
                      hint: context.l10n.additionalDetails,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCalculationPreview(context),
              const SizedBox(height: 24),
              _buildSaveButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartyFoundBanner(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: AppColors.secondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$name - Verified account record found',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyNotRegisteredAlert() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final registered = await _openPartyRegistrationPopup(
            prefilledAccountNumber: _accountController.text.trim(),
            prefilledAccountName: _lastScannedAccountName,
          );
          if (!mounted) {
            return;
          }
          if (registered) {
            await _resolvePartyFromAccount(_accountController.text);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Party not registered. Tap here to register details before saving.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.error,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationPreview(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Calculation Preview',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPreviewRow(
            'Service Fee Mode',
            _effectiveChargeHandlingMode == _ChargeHandlingMode.addOnTop
                ? 'Fee charged to customer'
                : 'Fee taken from amount sent',
          ),
          const SizedBox(height: 4),
          _buildPreviewRow('Using Wallet', _selectedWalletAccount),
          const SizedBox(height: 4),
          _buildPreviewRow(
            'Service Fee',
            '$_pesoLabel ${_chargeFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 4),
          _buildPreviewRow('Fee Goes To', _chargeDestinationAccount),
          if (_matchedChargeBracket != null) ...[
            const SizedBox(height: 4),
            _buildPreviewRow(
              'Fee Bracket',
              '$_pesoLabel ${_matchedChargeBracket!.lowerBound.toStringAsFixed(2)} - $_pesoLabel ${_matchedChargeBracket!.upperBound.toStringAsFixed(2)}',
            ),
          ],
          const SizedBox(height: 4),
          _buildHighlightedPreviewRow(
            _isOutflowSelection
                ? 'E-money Received from Customer'
                : 'E-money You Send to Customer',
            '$_pesoLabel ${(_isOutflowSelection ? _totalCollected : _amountToSend).toStringAsFixed(2)}',
            _selectedWalletColor,
          ),
          if (_enteredAmount > 0 && _matchedChargeBracket == null) ...[
            const SizedBox(height: 8),
            _buildNoBracketWarning(),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.outlineVariant, thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _isOutflowSelection
                      ? 'E-money to Receive from Customer'
                      : 'Total to Collect from Customer',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_pesoLabel ${_totalCollected.toStringAsFixed(2)}',

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _isOutflowSelection ? 'Cash to Pay Out' : 'Cash You Keep',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: _isOutflowSelection
                        ? 'Cash you hand out to the customer from your drawer.'
                        : 'Cash that goes into your drawer after this transaction.',
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Text(
                '$_pesoLabel ${_netCashToDrawer.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _effectiveChargeHandlingMode == _ChargeHandlingMode.addOnTop
                ? 'Service fee is added on top. Example: ${_pesoLabel}100 transaction + ${_pesoLabel}5 fee = collect ${_pesoLabel}105 from customer, send ${_pesoLabel}100.'
                : 'Fee is deducted before sending. Example: ${_pesoLabel}100 entered, ${_pesoLabel}5 fee deducted = only ${_pesoLabel}95 is sent to the customer\'s wallet.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedPreviewRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBracketWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'No fee range set for this amount. Fee shown as ₱0. Create a fee range first.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeHandlingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Fee Handling'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(context.l10n.customerPaysFee),
              selected: _chargeHandlingMode == _ChargeHandlingMode.addOnTop,
              onSelected: (_) {
                setState(() {
                  _chargeHandlingMode = _ChargeHandlingMode.addOnTop;
                });
              },
            ),
            ChoiceChip(
              label: Text(context.l10n.deductFeeFromSent),
              selected:
                  _chargeHandlingMode ==
                  _ChargeHandlingMode.deductFromEnteredAmount,
              onSelected: (_) {
                setState(() {
                  _chargeHandlingMode =
                      _ChargeHandlingMode.deductFromEnteredAmount;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onSaveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'SAVE TRANSACTION',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTypeSelector() {
    final walletPrefix = _selectedWallet == _WalletSelection.maya
        ? 'maya'
        : 'gcash';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Wallet & Service', isRequired: true),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('GCash'),
              selected: _selectedWallet == _WalletSelection.gcash,
              onSelected: (_) {
                setState(() {
                  _selectedTypeKey = 'gcash_$_selectedService';
                });
              },
            ),
            ChoiceChip(
              label: const Text('Maya Wallet'),
              selected: _selectedWallet == _WalletSelection.maya,
              onSelected: (_) {
                setState(() {
                  _selectedTypeKey = 'maya_$_selectedService';
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _serviceOptions
              .map((entry) {
                final selected = _selectedService == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedTypeKey = '${walletPrefix}_${entry.key}';
                    });
                  },
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefixText,
    IconData? suffixIcon,
    Future<void> Function()? onSuffixPressed,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
    bool isRequired = false,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(
          label,
          isRequired: isRequired,
          showErrorIndicator: hasError,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: _inputDecoration(hasError: hasError).copyWith(
            hintText: hint,
            prefixText: prefixText,
            suffixIcon: suffixIcon == null
                ? null
                : IconButton(
                    icon: Icon(
                      suffixIcon,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: onSuffixPressed == null
                        ? null
                        : () async {
                            await onSuffixPressed();
                          },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _openAccountSearchPicker() async {
    await _partyRepository.ensureLoaded();
    if (!mounted) return;

    final selected = await showModalBottomSheet<PartyRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _PartyContactPickerSheet(
        parties: _partyRepository.parties.value,
        initialQuery: _accountController.text.trim(),
      ),
    );

    if (!mounted || selected == null) return;

    _accountController.text = selected.accountNumber;
    _accountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _accountController.text.length),
    );
    _lastScannedAccountName = selected.name;
    await _resolvePartyFromAccount(selected.accountNumber);
  }

  String _pickBestTypeKey(ReceiptDraft draft) {
    final walletPrefix = switch (draft.walletSelection) {
      ReceiptWalletSelection.gcash => 'gcash',
      ReceiptWalletSelection.maya => 'maya',
      null => (_selectedWallet == _WalletSelection.maya ? 'maya' : 'gcash'),
    };

    var serviceKey = _selectedService;
    if (draft.flowDirection == ReceiptFlowDirection.outflow) {
      serviceKey = 'cashout';
    } else if (draft.flowDirection == ReceiptFlowDirection.inflow &&
        serviceKey == 'cashout') {
      serviceKey = 'cashin';
    }

    return '${walletPrefix}_$serviceKey';
  }

  Future<void> _applyReceiptDraft(ReceiptDraft draft) async {
    final service = ReceiptScanService.instance;
    final nextType = _pickBestTypeKey(draft);

    setState(() {
      _selectedTypeKey = nextType;

      if (draft.amount != null && draft.amount! > 0) {
        _principalController.text = service.formatAmountForInput(draft.amount!);
      }

      if (draft.accountNumber != null && draft.accountNumber!.isNotEmpty) {
        _accountController.text = draft.accountNumber!;
      }

      if (draft.reference != null && draft.reference!.trim().isNotEmpty) {
        _referenceController.text = draft.reference!.trim();
      }

      if (draft.accountName != null && draft.accountName!.trim().isNotEmpty) {
        _lastScannedAccountName = draft.accountName!.trim();
      }

      final noteText = service.buildReceiptNote(draft);
      if (noteText.isNotEmpty && _notesController.text.trim().isEmpty) {
        _notesController.text = noteText;
      }
    });

    _accountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _accountController.text.length),
    );
    _principalController.selection = TextSelection.fromPosition(
      TextPosition(offset: _principalController.text.length),
    );

    await _resolvePartyFromAccount(_accountController.text);
    _onPrincipalChanged(_principalController.text);

    if (!mounted) return;
    _showMessage('Receipt data applied. Please review before saving.');
  }

  Future<void> _resolvePartyFromAccount(String accountNumber) async {
    final requestedAccount = accountNumber.trim();
    final matchedParty = await _partyRepository.findByAccount(requestedAccount);
    if (!mounted) {
      return;
    }

    if (_accountController.text.trim() != requestedAccount) {
      return;
    }

    setState(() {
      _matchedParty = matchedParty;
    });
  }

  void _onPrincipalChanged(String _) {
    setState(() {});

    final principal = double.tryParse(_principalController.text.trim()) ?? 0;
    final hasRange = _matchedChargeBracket != null;

    if (principal <= 0 || hasRange) {
      _missingRangeAlertShownForCurrentInput = false;
      return;
    }

    if (_missingRangeAlertShownForCurrentInput || _missingRangeAlertVisible) {
      return;
    }

    _missingRangeAlertShownForCurrentInput = true;
    _showMissingChargeRangeAlert();
  }

  Future<void> _showMissingChargeRangeAlert() async {
    if (!mounted || _missingRangeAlertVisible) {
      return;
    }

    _missingRangeAlertVisible = true;
    final goToCharges = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'No Fee Range Found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The entered amount does not match any configured fee range. Please create a new fee range first.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        content: const SizedBox.shrink(),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  icon: const Icon(Icons.payments_outlined, size: 16),
                  label: Text(context.l10n.goToCharges),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    _missingRangeAlertVisible = false;

    if (!mounted || goToCharges != true) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChargesScreen(
          launchedFromTransaction: true,
          initialTypeKey: _selectedTypeKey,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _chargeRepository.ensureLoaded();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _onSaveTransaction() async {
    if (_isSaving) return;
    setState(() {
      _showRequiredIndicators = true;
      _isSaving = true;
    });
    try {
      await _runSaveTransaction();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _runSaveTransaction() async {
    final accountNumber = _accountController.text.trim();
    final principal = double.tryParse(_principalController.text.trim()) ?? 0;

    if (accountNumber.isEmpty) {
      _showMessage('Account number is required before saving.', isError: true);
      return;
    }

    if (principal <= 0) {
      _showMessage(
        'Transaction amount is required before saving.',
        isError: true,
      );
      return;
    }

    if (_matchedChargeBracket == null) {
      _showMessage(
        'No fee range found for this amount. Create a new range first.',
        isError: true,
      );
      _showMissingChargeRangeAlert();
      return;
    }

    if (_amountToSend <= 0) {
      _showMessage(
        'Amount to send must be greater than zero. Adjust entered amount or charge handling.',
        isError: true,
      );
      return;
    }

    final isOutflow = _isOutflowSelection;
    final (gcashBalance, mayaWalletBalance, onHandBalance) =
        await _loadCurrentBalances();
    if (!mounted) {
      return;
    }

    final selectedWalletAccount = _selectedWalletAccount;
    final selectedWalletBalance = selectedWalletAccount == 'Maya Wallet'
        ? mayaWalletBalance
        : gcashBalance;
    final sourceLabel = isOutflow ? 'On-hand Cash' : selectedWalletAccount;
    final requiredSourceAmount =
        _effectiveChargeHandlingMode ==
            _ChargeHandlingMode.deductFromEnteredAmount
        ? _enteredAmount - _chargeFee
        : _enteredAmount;
    final available = isOutflow ? onHandBalance : selectedWalletBalance;
    if (requiredSourceAmount > available) {
      _showMessage(
        'Insufficient $sourceLabel balance. Available: ₱ ${available.toStringAsFixed(2)}',
        isError: true,
      );
      return;
    }

    // Capture messenger before any async gap to avoid 'attached' assertion.
    final messenger = ScaffoldMessenger.maybeOf(context);

    await _resolvePartyFromAccount(accountNumber);

    if (!_isRegisteredAccount) {
      _showMessage(
        'Party is not registered yet. Register details first.',
        isError: true,
        messenger: messenger,
      );
      final registered = await _openPartyRegistrationPopup(
        prefilledAccountNumber: accountNumber,
        prefilledAccountName: _lastScannedAccountName,
      );
      if (!registered) {
        return;
      }

      if (!mounted) return;

      await _resolvePartyFromAccount(_accountController.text);

      if (!mounted) return;

      if (_isRegisteredAccount) {
        _showMessage(context.l10n.partyRegisteredSaving, messenger: messenger);
      } else {
        _showMessage(
          context.l10n.unableToVerifyRegistration,
          isError: true,
          messenger: messenger,
        );
        return;
      }
    }

    if (!mounted) return;

    // Load and validate transaction preview from backend
    final previewLoaded = await _loadAndValidatePreview();
    if (!previewLoaded) {
      if (!mounted) return;
      _showMessage(
        _previewErrorMessage ?? 'Failed to validate transaction fees.',
        isError: true,
        messenger: messenger,
      );
      return;
    }

    // Show fee breakdown dialog - user must confirm before proceeding
    final userConfirmed = await _showFeeBreakdownDialog();
    if (!userConfirmed) {
      if (!mounted) return;
      return; // User cancelled
    }

    if (!mounted) return;

    final saved = await _saveTransactionRecord();
    if (!saved) {
      if (!mounted) return;
      _showMessage(
        context.l10n.unableToSaveTransaction,
        isError: true,
        messenger: messenger,
      );
      return;
    }

    if (!mounted) return;

    // Sync transaction to backend - now awaited with error handling
    final synced = await _syncTransactionToBackendAwaited();
    if (!synced) {
      if (!mounted) return;
      _showMessage(
        'Transaction saved locally but backend sync failed. It will be retried on next sync.',
        isError: false,
        messenger: messenger,
      );
    } else {
      if (!mounted) return;
      _showMessage(
        'Transaction saved and synced to backend successfully.',
        messenger: messenger,
      );
    }

    if (!mounted) return;

    _showMessage(
      context.l10n.transactionSaved(_matchedParty!.name),
      messenger: messenger,
    );
    Navigator.of(context).pop(true);
  }

  Future<bool> _saveTransactionRecord() async {
    final principal = _amountToSend;
    final chargeFee = _chargeFee;
    final totalCollected = _totalCollected;
    final accountNumber = _accountController.text.trim();
    final referenceText = _referenceController.text.trim();
    final notes = _notesController.text.trim();

    if (principal <= 0 || _matchedParty == null) {
      return false;
    }

    final selectedType = FixedTransactionType.forKey(_selectedTypeKey).label;
    final isOutflow = _isOutflowSelection;
    final walletAccount = _selectedWalletAccount;
    final usesMayaWallet = walletAccount == 'Maya Wallet';
    final amount = _enteredAmount;
    final isDeductFromAmount =
        _effectiveChargeHandlingMode ==
        _ChargeHandlingMode.deductFromEnteredAmount;

    // Inflow (Cash In):  store sends e-money to customer, receives cash.
    //   wallet decreases, on-hand increases (all cash goes to on-hand).
    //   addOnTop:          walletDelta = -amount,        onHandDelta = +(amount + fee)
    //   deductFromAmount:  walletDelta = -(amount - fee), onHandDelta = +amount
    //
    // Outflow (Cash Out): customer's wallet is charged, store pays cash.
    //   wallet increases, on-hand decreases (all e-money goes to wallet).
    //   addOnTop:          walletDelta = +(amount + fee), onHandDelta = -amount
    //   deductFromAmount:  walletDelta = +amount,         onHandDelta = -(amount - fee)
    final double selectedWalletDelta;
    final double onHandDelta;
    if (!isOutflow) {
      selectedWalletDelta = isDeductFromAmount
          ? -(amount - chargeFee)
          : -amount;
      onHandDelta = isDeductFromAmount ? amount : amount + chargeFee;
    } else {
      selectedWalletDelta = isDeductFromAmount ? amount : amount + chargeFee;
      onHandDelta = isDeductFromAmount ? -(amount - chargeFee) : -amount;
    }

    final walletDelta = usesMayaWallet ? 0.0 : selectedWalletDelta;
    final mayaWalletDelta = usesMayaWallet ? selectedWalletDelta : 0.0;
    final now = DateTime.now();
    final reference = referenceText.isNotEmpty ? referenceText : accountNumber;
    final iconKey = isOutflow ? 'cash_out' : 'cash_in';
    final title = selectedType;
    final noteBase = notes.isEmpty
        ? 'Account $accountNumber \u2022 ${_matchedParty!.name}'
        : notes;
    // Transaction note shows only wallet flow (no fee breakdown)
    final persistedNote =
        '$noteBase \u2022 $_selectedFlowLabel \u2022 Wallet ${selectedWalletDelta >= 0 ? 'increased' : 'decreased'} by \u20b1${selectedWalletDelta.abs().toStringAsFixed(2)} \u2022 On-hand ${onHandDelta >= 0 ? 'increased' : 'decreased'} by \u20b1${onHandDelta.abs().toStringAsFixed(2)}';

    final db = await _database.database;
    try {
      await _database.ensureWalletSchema(db);
      final deviceId = await _database.getOrCreateDeviceId();
      final nowMs = now.millisecondsSinceEpoch;
      final transactionId = await db.insert(AppDatabase.ledgerTable, {
        'entry_type': 'transaction',
        'title': title,
        'note': persistedNote,
        'reference': reference,
        'amount': totalCollected,
        'wallet_delta': walletDelta,
        'maya_wallet_delta': mayaWalletDelta,
        'on_hand_delta': onHandDelta,
        'recorded_flow': totalCollected,
        'tag': 'Transaction',
        'icon_key': iconKey,
        'wallet_account': walletAccount,
        AppDatabase.syncIdColumn: AppDatabase.generateSyncId('entry'),
        AppDatabase.deviceIdColumn: deviceId,
        AppDatabase.updatedAtMsColumn: nowMs,
        AppDatabase.isDeletedColumn: 0,
        AppDatabase.isDirtyColumn: 1,
        'created_at': now.toIso8601String(),
      });

      // Save fee as separate record if fee exists
      if (chargeFee > 0) {
        await db.insert(AppDatabase.feeTransactionsTable, {
          'related_transaction_id': transactionId,
          'fee_amount': chargeFee,
          'fee_type': title,
          'charge_destination': _chargeDestinationAccount,
          AppDatabase.syncIdColumn: AppDatabase.generateSyncId('fee'),
          AppDatabase.deviceIdColumn: deviceId,
          AppDatabase.updatedAtMsColumn: nowMs,
          AppDatabase.isDeletedColumn: 0,
          AppDatabase.isDirtyColumn: 1,
          'created_at': now.toIso8601String(),
        });
      }

      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('Failed to save transaction record: $error\n$stackTrace');
      return false;
    }
  }

  /// Submit transaction to backend after local save (awaited version with error handling).
  /// Returns true if sync succeeds, false if it fails.
  Future<bool> _syncTransactionToBackendAwaited() async {
    try {
      final db = await _database.database;
      final rows = await db.query(
        AppDatabase.ledgerTable,
        orderBy: 'id DESC',
        limit: 1,
        columns: [AppDatabase.syncIdColumn, AppDatabase.deviceIdColumn],
      );

      if (rows.isEmpty) {
        debugPrint('⚠ No transaction found to sync');
        return false;
      }

      final syncId = rows.first[AppDatabase.syncIdColumn] as String;
      final deviceId = rows.first[AppDatabase.deviceIdColumn] as String;
      final isOutflow = _isOutflowSelection;
      final walletProvider = _selectedWallet == _WalletSelection.maya
          ? 'MAYA'
          : 'GCASH';
      final direction = isOutflow ? 'CASH_OUT' : 'CASH_IN';
      final amount = _enteredAmount;
      final isDeductFromAmount =
          _effectiveChargeHandlingMode ==
          _ChargeHandlingMode.deductFromEnteredAmount;

      await _transactionRepository.createTransaction(
        walletProvider: walletProvider,
        direction: direction,
        amount: amount,
        chargeHandling: isDeductFromAmount ? 'deductFromAmount' : 'addOnTop',
        syncId: syncId,
        deviceId: deviceId,
        transactionTypeKey: _selectedTypeKey,
        reference: _referenceController.text.trim(),
        note: _notesController.text.trim(),
        entryDate: DateTime.now().toIso8601String(),
      );
      debugPrint('✓ Transaction synced to backend: $syncId');
      return true;
    } on Exception catch (e) {
      debugPrint('✗ Failed to sync transaction to backend: $e');
      if (e.toString().contains('409')) {
        debugPrint('  Error: Duplicate transaction (syncId already exists)');
      } else if (e.toString().contains('400')) {
        debugPrint(
          '  Error: Invalid transaction (may be insufficient balance)',
        );
      }
      return false;
    }
  }

  /// Load and validate preview from backend.
  /// Returns true if preview succeeds, false otherwise.
  /// Stores preview data in [_lastPreview] for display.
  Future<bool> _loadAndValidatePreview() async {
    final amount = _enteredAmount;
    if (amount <= 0) {
      setState(() => _previewErrorMessage = 'Amount must be greater than 0');
      return false;
    }

    try {
      final isOutflow = _isOutflowSelection;
      final walletProvider = _selectedWallet == _WalletSelection.maya
          ? 'MAYA'
          : 'GCASH';
      final direction = isOutflow ? 'CASH_OUT' : 'CASH_IN';

      final preview = await _transactionRepository.previewTransaction(
        walletProvider: walletProvider,
        direction: direction,
        amount: amount,
        chargeHandling:
            _effectiveChargeHandlingMode ==
                _ChargeHandlingMode.deductFromEnteredAmount
            ? 'deductFromAmount'
            : 'addOnTop',
        transactionTypeKey: _selectedTypeKey,
      );

      setState(() {
        _lastPreview = preview;
        _previewErrorMessage = null;
      });
      return true;
    } catch (e) {
      setState(() => _previewErrorMessage = 'Fee validation failed: $e');
      return false;
    }
  }

  /// Show fee breakdown dialog to user with backend-calculated details.
  Future<bool> _showFeeBreakdownDialog() async {
    if (_lastPreview == null) return false;

    final preview = _lastPreview!;
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Fee Breakdown'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewField(
                    'Amount',
                    '₱${preview.chargeAmount.toStringAsFixed(2)}',
                  ),
                  _buildPreviewField(
                    'Charge',
                    '₱${preview.chargeAmount.toStringAsFixed(2)}',
                  ),
                  _buildPreviewField(
                    'Total Collected',
                    '₱${preview.totalCollected.toStringAsFixed(2)}',
                  ),
                  _buildPreviewField(
                    'Wallet Credit',
                    '₱${preview.walletCredit.toStringAsFixed(2)}',
                  ),
                  _buildPreviewField(
                    'On-Hand Change',
                    '₱${preview.onHandChange.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Fee Routing',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    preview.feeRoutingExplanation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Post-Transaction Balance: ₱${preview.postTransactionWalletBalance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm & Save'),
              ),
            ],
          ),
        ) ??
        false;

    return confirmed;
  }

  Widget _buildPreviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<(double walletBalance, double mayaWalletBalance, double onHandBalance)>
  _loadCurrentBalances() async {
    final db = await _database.database;
    await _database.ensureWalletSchema(db);
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(wallet_delta), 0) AS wallet_balance,
        COALESCE(SUM(maya_wallet_delta), 0) AS maya_wallet_balance,
        COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ${AppDatabase.ledgerTable}
      WHERE ${AppDatabase.isDeletedColumn} = 0
    ''');

    if (rows.isEmpty) {
      return (0.0, 0.0, 0.0);
    }

    final row = rows.first;
    final walletBalance = (row['wallet_balance'] as num?)?.toDouble() ?? 0.0;
    final mayaWalletBalance =
        (row['maya_wallet_balance'] as num?)?.toDouble() ?? 0.0;
    final onHandBalance = (row['on_hand_balance'] as num?)?.toDouble() ?? 0.0;
    return (walletBalance, mayaWalletBalance, onHandBalance);
  }

  Future<bool> _openPartyRegistrationPopup({
    required String prefilledAccountNumber,
    String? prefilledAccountName,
  }) async {
    if (!mounted) return false;

    // Use a proper StatefulWidget dialog so that mounted/setState
    // are reliably scoped to the dialog's own element lifecycle,
    // preventing the 'attached' RenderObject assertion after awaits.
    final registeredAccount = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PartyRegistrationDialog(
        prefilledAccountNumber: prefilledAccountNumber,
        prefilledAccountName: prefilledAccountName,
        repository: _partyRepository,
      ),
    );

    if (registeredAccount != null && mounted) {
      _accountController.text = registeredAccount;
      return true;
    }
    return false;
  }

  void _showMessage(
    String message, {
    bool isError = false,
    ScaffoldMessengerState? messenger,
  }) {
    final m =
        messenger ?? (mounted ? ScaffoldMessenger.maybeOf(context) : null);
    if (m == null) return;
    m
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? AppColors.error : const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Widget _fieldLabel(
    String label, {
    bool isRequired = false,
    bool showErrorIndicator = false,
  }) {
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: showErrorIndicator ? AppColors.error : AppColors.onSurfaceVariant,
    );

    if (!isRequired) {
      return Text(label, style: labelStyle);
    }

    return RichText(
      text: TextSpan(
        style: labelStyle,
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({bool hasError = false}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : Colors.transparent,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : AppColors.primary,
          width: hasError ? 1.6 : 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: AppColors.outlineVariant, fontSize: 13),
    );
  }
}

class _PartyContactPickerSheet extends StatefulWidget {
  const _PartyContactPickerSheet({
    required this.parties,
    required this.initialQuery,
  });

  final List<PartyRecord> parties;
  final String initialQuery;

  @override
  State<_PartyContactPickerSheet> createState() =>
      _PartyContactPickerSheetState();
}

class _PartyContactPickerSheetState extends State<_PartyContactPickerSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PartyRecord> get _filteredParties {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.parties;
    }

    return widget.parties
        .where((party) {
          final name = party.name.toLowerCase();
          final account = party.accountNumber.toLowerCase();
          return name.contains(query) || account.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredParties;
    final maxHeight = MediaQuery.of(context).size.height * 0.78;

    return SafeArea(
      child: SizedBox(
        height: maxHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select Registered Contact',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search name or account number',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: widget.parties.isEmpty
                    ? _PartyPickerEmptyState(
                        title: context.l10n.noContactsFound,
                        subtitle:
                            'Register a party first, then use search to pick an account.',
                      )
                    : (filtered.isEmpty
                          ? _PartyPickerEmptyState(
                              title: context.l10n.noMatchingContact,
                              subtitle:
                                  'Try searching with a different name or account number.',
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: AppColors.outlineVariant,
                              ),
                              itemBuilder: (context, index) {
                                final party = filtered[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    party.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Account: ${party.accountNumber}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: party.isVerified
                                      ? const Icon(
                                          Icons.verified_rounded,
                                          color: AppColors.secondary,
                                          size: 18,
                                        )
                                      : null,
                                  onTap: () => Navigator.of(context).pop(party),
                                );
                              },
                            )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartyPickerEmptyState extends StatelessWidget {
  const _PartyPickerEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 32,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyRegistrationDialog extends StatefulWidget {
  const _PartyRegistrationDialog({
    required this.prefilledAccountNumber,
    this.prefilledAccountName,
    required this.repository,
  });

  final String prefilledAccountNumber;
  final String? prefilledAccountName;
  final PartyRepository repository;

  @override
  State<_PartyRegistrationDialog> createState() =>
      _PartyRegistrationDialogState();
}

class _PartyRegistrationDialogState extends State<_PartyRegistrationDialog> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _accountController;
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.prefilledAccountName ?? '',
    );
    _accountController = TextEditingController(
      text: widget.prefilledAccountNumber,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    final fullName = _fullNameController.text.trim();
    final accountNumber = _accountController.text.trim();

    if (fullName.isEmpty || accountNumber.isEmpty) {
      setState(() {
        _errorText = 'Please complete full name and account number.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final bool inserted;
    try {
      inserted = await widget.repository.registerParty(
        fullName: fullName,
        accountNumber: accountNumber,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = 'Unable to save party. Please try again.';
      });
      return;
    }

    if (!mounted) return;

    if (!inserted) {
      setState(() {
        _isSaving = false;
        _errorText = 'Account already registered.';
      });
      return;
    }

    Navigator.of(context).pop(accountNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Party Registration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Define a new financial entity before recording this transaction.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _dialogField(
            controller: _fullNameController,
            label: context.l10n.fullNameEntity,
            hint: context.l10n.enterPartyFullName,
          ),
          const SizedBox(height: 12),
          _dialogField(
            controller: _accountController,
            label: context.l10n.accountNumber,
            hint: context.l10n.enterAccountNumber,
            keyboardType: TextInputType.number,
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSaving
                    ? null
                    : () => Navigator.of(context).pop(null),
                child: Text(context.l10n.cancel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSaving ? null : _onRegister,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                label: Text(_isSaving ? 'Saving\u2026' : 'Register Party'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}
