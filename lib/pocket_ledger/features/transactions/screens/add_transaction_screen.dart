import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/receipt_scan/receipt_draft.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
import '../../../../shared/receipt_scan/receipt_scan_button.dart';
import '../../../../shared/receipt_scan/receipt_scan_service.dart';
import '../../charges/data/charge_repository.dart';
import '../../charges/screens/charges_screen.dart';
import '../../parties/data/party_repository.dart';
import '../data/transaction_repository.dart';
import '../data/transaction_models.dart';

enum _ChargeHandlingMode { addOnTop, deductFromEnteredAmount }

enum _WalletSelection { gcash, maya }

enum _FlowDirection { inflow, outflow }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const List<String> _serviceOptions = [
    'cashin',
    'cashout',
    'load',
    'paybills',
    'qrpayment',
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
  _ChargeHandlingMode? _chargeHandlingMode;
  bool _showSummaryDetails = false;

  _WalletSelection _selectedWalletSelection = _WalletSelection.gcash;
  String? _selectedServiceKey;
  PartyRecord? _matchedParty;

  _WalletSelection get _selectedWallet {
    return _selectedWalletSelection;
  }

  String? get _selectedTypeKey {
    final serviceKey = _selectedServiceKey;
    if (serviceKey == null) {
      return null;
    }

    final walletPrefix = _selectedWalletSelection == _WalletSelection.maya
        ? 'maya'
        : 'gcash';
    return '${walletPrefix}_$serviceKey';
  }

  String get _effectiveTypeKey {
    final serviceKey = _selectedServiceKey ?? 'cashin';
    final walletPrefix = _selectedWalletSelection == _WalletSelection.maya
        ? 'maya'
        : 'gcash';
    return '${walletPrefix}_$serviceKey';
  }

  _FlowDirection get _selectedFlowDirection {
    final typeKey = _selectedTypeKey;
    if (typeKey == null) {
      return _FlowDirection.inflow;
    }

    return FixedTransactionType.forKey(typeKey).isOutflow
        ? _FlowDirection.outflow
        : _FlowDirection.inflow;
  }

  ChargeBracketRecord? get _matchedChargeBracket {
    final principal = _parseAmount(_principalController.text);
    if (principal <= 0) {
      return null;
    }

    final typeKey = _selectedTypeKey;
    if (typeKey == null) {
      return null;
    }

    for (final bracket in _chargeRepository.brackets.value) {
      if (bracket.transactionTypeKey != typeKey) continue;
      if (principal >= bracket.lowerBound && principal <= bracket.upperBound) {
        return bracket;
      }
    }
    return null;
  }

  double get _chargeFee {
    final principal = _parseAmount(_principalController.text);
    if (principal <= 0) {
      return 0;
    }
    return _matchedChargeBracket?.chargeAmount ?? 0;
  }

  double get _enteredAmount {
    return _parseAmount(_principalController.text);
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
    return _selectedServiceKey ?? '';
  }

  bool get _canCustomizeFeeHandling {
    return _selectedServiceKey == 'cashin' || _selectedServiceKey == 'cashout';
  }

  // QR Payment is a top-up style service: customer pays digitally,
  // store wallet receives the full amount + fee, no cash changes hands.
  bool get _isQrPayment => _selectedServiceKey == 'qrpayment';

  _ChargeHandlingMode get _effectiveChargeHandlingMode {
    if (_canCustomizeFeeHandling) {
      return _chargeHandlingMode ?? _ChargeHandlingMode.addOnTop;
    }
    return _ChargeHandlingMode.addOnTop;
  }

  String get _chargeHandlingDisplayLabel {
    if (_chargeHandlingMode == null) {
      return 'Select fee handling';
    }
    return _chargeHandlingMode == _ChargeHandlingMode.addOnTop
        ? context.l10n.customerPaysFeeLabel
        : context.l10n.deductedFromSentLabel;
  }

  double get _walletDeltaPreview {
    final amount = _enteredAmount;
    final fee = _chargeFee;
    if (!_isOutflowSelection) {
      return _effectiveChargeHandlingMode ==
              _ChargeHandlingMode.deductFromEnteredAmount
          ? -(amount - fee)
          : -amount;
    }
    return _effectiveChargeHandlingMode ==
            _ChargeHandlingMode.deductFromEnteredAmount
        ? amount
        : amount + fee;
  }

  double get _cashDeltaPreview {
    // QR Payment: customer pays everything digitally — no cash changes hands.
    if (_isQrPayment) return 0;
    final amount = _enteredAmount;
    final fee = _chargeFee;
    if (!_isOutflowSelection) {
      return _effectiveChargeHandlingMode ==
              _ChargeHandlingMode.deductFromEnteredAmount
          ? amount
          : amount + fee;
    }
    return _effectiveChargeHandlingMode ==
            _ChargeHandlingMode.deductFromEnteredAmount
        ? -(amount - fee)
        : -amount;
  }

  String _signedMoney(double value) {
    final sign = value < 0 ? '-' : '+';
    return '$sign$_pesoLabel ${value.abs().toStringAsFixed(2)}';
  }

  bool get _useLocalBreakdownInDialog => !_canCustomizeFeeHandling;

  double _dialogFeeAmount(TransactionPreviewResponse preview) {
    return _useLocalBreakdownInDialog ? _chargeFee : preview.chargeAmount;
  }

  double _dialogWalletChange(TransactionPreviewResponse preview) {
    return _useLocalBreakdownInDialog
        ? _walletDeltaPreview
        : preview.walletCredit;
  }

  double _dialogCashChange(TransactionPreviewResponse preview) {
    return _useLocalBreakdownInDialog
        ? _cashDeltaPreview
        : preview.onHandChange;
  }

  double get _netCashToDrawer {
    // QR Payment: no physical cash is exchanged.
    if (_isQrPayment) return 0;
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
      _showRequiredIndicators &&
      _accountController.text.trim().isEmpty &&
      !_isQrPayment;

  bool get _isPrincipalMissing =>
      _showRequiredIndicators && _parseAmount(_principalController.text) <= 0;

  bool get _isOutflowSelection =>
      _selectedFlowDirection == _FlowDirection.outflow;

  String get _selectedWalletAccount {
    return _selectedWallet == _WalletSelection.maya
        ? context.l10n.mayaWalletOption
        : context.l10n.gcash;
  }

  Color get _selectedWalletColor {
    return _selectedWallet == _WalletSelection.maya
        ? AppColors.secondary
        : AppColors.primary;
  }

  String get _selectedFlowLabel {
    return _isOutflowSelection
        ? context.l10n.amountCustomerSends
        : context.l10n.amountSentToCustomerWallet;
  }

  String get _pesoLabel => '\u20B1';

  double _parseAmount(String raw) {
    final normalized = raw.replaceAll(',', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  static final TextInputFormatter _amountInputFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;
        if (text.isEmpty) {
          return newValue;
        }

        final regex = RegExp(r'^\d{0,9}(\.\d{0,2})?$');
        if (regex.hasMatch(text)) {
          return newValue;
        }
        return oldValue;
      });

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
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [],
      ),
      body: Stack(
        children: [
          ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            children: [
              ScreenHeaderCard(
                title: 'New Transaction',
                subtitle:
                    'Select wallet & service, then enter the customer account and amount.',
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Transaction Details'),
                    const SizedBox(height: 12),
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
                      inputFormatters: [_amountInputFormatter],
                      onChanged: _onPrincipalChanged,
                      isRequired: true,
                      hasError: _isPrincipalMissing,
                    ),
                    if (_canCustomizeFeeHandling) ...[
                      const SizedBox(height: 16),
                      _buildChargeHandlingSelector(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Additional Details'),
                    const SizedBox(height: 12),
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
              context.l10n.verifiedAccountFound(name),
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
              Expanded(
                child: Text(
                  context.l10n.accountNotInContacts,
                  style: const TextStyle(
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
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              return Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.reviewTotals,
                      maxLines: compact ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (compact)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showSummaryDetails = !_showSummaryDetails;
                        });
                      },
                      tooltip: _showSummaryDetails
                          ? context.l10n.hideDetails
                          : context.l10n.showDetails,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        _showSummaryDetails
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showSummaryDetails = !_showSummaryDetails;
                        });
                      },
                      child: Text(
                        _showSummaryDetails
                            ? context.l10n.hideDetails
                            : context.l10n.showDetails,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                _buildPreviewRow(
                  context.l10n.whoPaysServiceFee,
                  _chargeHandlingMode == null
                      ? 'Select fee handling'
                      : _chargeHandlingDisplayLabel,
                ),
                const SizedBox(height: 4),
                _buildPreviewRow(
                  context.l10n.usingWallet,
                  _selectedWalletAccount,
                ),
                const SizedBox(height: 4),
                _buildPreviewRow(
                  context.l10n.serviceFee,
                  '$_pesoLabel ${_chargeFee.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 4),
                _buildPreviewRow(
                  context.l10n.feeDestination,
                  _chargeDestinationAccount,
                ),
                if (_matchedChargeBracket != null) ...[
                  const SizedBox(height: 4),
                  _buildPreviewRow(
                    context.l10n.feeRange,
                    '$_pesoLabel ${_matchedChargeBracket!.lowerBound.toStringAsFixed(2)} - $_pesoLabel ${_matchedChargeBracket!.upperBound.toStringAsFixed(2)}',
                  ),
                ],
                const SizedBox(height: 4),
              ],
            ),
            crossFadeState: _showSummaryDetails
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
          _buildHighlightedPreviewRow(
            _isOutflowSelection
                ? context.l10n.amountCustomerSends
                : context.l10n.amountSentToCustomerWallet,
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
          _buildCustomerPaysRow(context),
          const SizedBox(height: 8),
          _buildCashDrawerRow(context),
          if (_showSummaryDetails) ...[
            const SizedBox(height: 12),
            Text(
              _effectiveChargeHandlingMode == _ChargeHandlingMode.addOnTop
                  ? context.l10n.feeAddedExample
                  : context.l10n.feeDeductedExample,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.82),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 6,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        );
      },
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 340;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
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
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
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
          );
        },
      ),
    );
  }

  Widget _buildCustomerPaysRow(BuildContext context) {
    final value = '$_pesoLabel ${_totalCollected.toStringAsFixed(2)}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.customerPays,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.l10n.customerPays,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCashDrawerRow(BuildContext context) {
    final value = '$_pesoLabel ${_netCashToDrawer.toStringAsFixed(2)}';
    final label = _isOutflowSelection
        ? context.l10n.cashPaidOut
        : context.l10n.cashAddedToDrawer;
    final tooltip = _isOutflowSelection
        ? context.l10n.cashPaidOutTooltip
        : context.l10n.cashAddedToDrawerTooltip;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: tooltip,
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: tooltip,
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
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
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.l10n.noFeeRuleForAmount,
              style: const TextStyle(
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
    final showChargeHandlingError =
        _showRequiredIndicators &&
        _canCustomizeFeeHandling &&
        _chargeHandlingMode == null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(
            context.l10n.whoPaysServiceFee,
            isRequired: true,
            showErrorIndicator: showChargeHandlingError,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<_ChargeHandlingMode>(
            value: _chargeHandlingMode,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: InputDecoration(
              hintText: 'Select fee handling',
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: showChargeHandlingError
                      ? AppColors.error
                      : AppColors.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.2,
                ),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: _ChargeHandlingMode.addOnTop,
                child: Text(context.l10n.customerPaysFeeLabel),
              ),
              DropdownMenuItem(
                value: _ChargeHandlingMode.deductFromEnteredAmount,
                child: Text(context.l10n.deductedFromSentLabel),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _chargeHandlingMode = value;
              });
            },
            hint: Text(
              'Select fee handling',
              style: TextStyle(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          if (_chargeHandlingMode == null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: showChargeHandlingError
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: showChargeHandlingError
                      ? AppColors.error.withValues(alpha: 0.25)
                      : AppColors.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 16,
                    color: showChargeHandlingError
                        ? AppColors.error
                        : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please choose a fee handling option.',
                      style: TextStyle(
                        fontSize: 12,
                        color: showChargeHandlingError
                            ? AppColors.error
                            : AppColors.onSurfaceVariant.withValues(
                                alpha: 0.88,
                              ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Applicable fee: $_pesoLabel ${_chargeFee.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.saveTransactionAction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
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
    final selectedServiceLabel = _selectedServiceKey == null
        ? 'Choose transaction type'
        : _serviceLabel(_selectedServiceKey!);
    final showTypeError =
        _showRequiredIndicators && _selectedServiceKey == null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(
              context.l10n.walletAndService,
              isRequired: true,
              showErrorIndicator: showTypeError,
            ),
            const SizedBox(height: 8),
            _buildSelectorStepCard(
              compact: compact,
              title: context.l10n.walletLabel,
              subtitle: 'GCash or Maya',
              child: Row(
                children: [
                  Expanded(
                    child: _buildWalletOptionButton(
                      compact: compact,
                      label: context.l10n.gcash,
                      icon: Icons.account_balance_wallet_rounded,
                      selected: _selectedWallet == _WalletSelection.gcash,
                      onTap: () {
                        setState(() {
                          _selectedWalletSelection = _WalletSelection.gcash;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: compact ? 6 : 8),
                  Expanded(
                    child: _buildWalletOptionButton(
                      compact: compact,
                      label: context.l10n.mayaWalletOption,
                      icon: Icons.account_balance_wallet_outlined,
                      selected: _selectedWallet == _WalletSelection.maya,
                      onTap: () {
                        setState(() {
                          _selectedWalletSelection = _WalletSelection.maya;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: compact ? 8 : 10),
            _buildSelectorStepCard(
              compact: compact,
              title: context.l10n.transactionTypeLabel,
              subtitle: 'Cash In, Cash Out, Load, Bills, or QR',
              child: DropdownButtonFormField<String>(
                value: _selectedServiceKey,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: InputDecoration(
                  hintText: 'Choose transaction type',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: showTypeError
                          ? AppColors.error
                          : AppColors.outlineVariant.withValues(alpha: 0.55),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: showTypeError
                          ? AppColors.error
                          : AppColors.outlineVariant.withValues(alpha: 0.55),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                  ),
                ),
                items: _serviceOptions
                    .map((serviceKey) {
                      final selected = _selectedServiceKey == serviceKey;
                      return DropdownMenuItem<String>(
                        value: serviceKey,
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.outlineVariant,
                                  width: 1.4,
                                ),
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.transparent,
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _serviceLabel(serviceKey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _selectedServiceKey = value;
                  });
                },
                hint: Text(
                  'Choose transaction type',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            if (_selectedServiceKey == null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: showTypeError
                      ? AppColors.error.withValues(alpha: 0.08)
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: showTypeError
                        ? AppColors.error.withValues(alpha: 0.25)
                        : AppColors.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_box_outline_blank_rounded,
                      size: 16,
                      color: showTypeError
                          ? AppColors.error
                          : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please choose a transaction type.',
                        style: TextStyle(
                          fontSize: 12,
                          color: showTypeError
                              ? AppColors.error
                              : AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.88,
                                ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: compact ? 8 : 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 12,
                vertical: compact ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: compact ? 14 : 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: compact ? 6 : 8),
                  Expanded(
                    child: Text(
                      context.l10n.selectedWalletService(
                        _selectedWalletAccount,
                        selectedServiceLabel,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 11.5 : 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectorStepCard({
    required bool compact,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 11.5 : 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: compact ? 10.5 : 11,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.92),
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          child,
        ],
      ),
    );
  }

  Widget _buildWalletOptionButton({
    required bool compact,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 9 : 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: compact ? 14 : 16,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              SizedBox(width: compact ? 4 : 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11.5 : 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  String _serviceLabel(String serviceKey) {
    switch (serviceKey) {
      case 'cashin':
        return context.l10n.cashIn;
      case 'cashout':
        return context.l10n.cashOut;
      case 'load':
        return context.l10n.loadService;
      case 'paybills':
        return context.l10n.payBillsService;
      case 'qrpayment':
        return context.l10n.qrPaymentService;
      default:
        return serviceKey;
    }
  }

  IconData _serviceIcon(String serviceKey) {
    switch (serviceKey) {
      case 'cashin':
        return Icons.south_west_rounded;
      case 'cashout':
        return Icons.north_east_rounded;
      case 'load':
        return Icons.mobile_friendly_rounded;
      case 'paybills':
        return Icons.receipt_long_rounded;
      case 'qrpayment':
        return Icons.qr_code_scanner_rounded;
      default:
        return Icons.tune_rounded;
    }
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

    var serviceKey = _selectedServiceKey ?? 'cashin';
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
    final nextWallet = nextType.startsWith('maya_')
        ? _WalletSelection.maya
        : _WalletSelection.gcash;
    final nextService = nextType.split('_').last;

    setState(() {
      _selectedWalletSelection = nextWallet;
      _selectedServiceKey = nextService;

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
    _showMessage(context.l10n.receiptDataAppliedReview);
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
    setState(() {
      if (_parseAmount(_principalController.text) > 0) {
        _showSummaryDetails = true;
      }
    });

    final principal = _parseAmount(_principalController.text);
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
              Text(
                context.l10n.noFeeRangeFoundTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.noFeeRangeFoundMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                  child: Text(context.l10n.cancel),
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
          initialTypeKey: _effectiveTypeKey,
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
    final l10n = context.l10n;
    final accountNumber = _accountController.text.trim();
    final principal = _parseAmount(_principalController.text);

    if (accountNumber.isEmpty && !_isQrPayment) {
      _showMessage(l10n.accountNumberRequiredBeforeSaving, isError: true);
      return;
    }

    if (principal <= 0) {
      _showMessage(l10n.transactionAmountRequiredBeforeSaving, isError: true);
      return;
    }

    if (_selectedServiceKey == null) {
      _showMessage(l10n.transactionTypeLabel, isError: true);
      return;
    }

    if (_canCustomizeFeeHandling && _chargeHandlingMode == null) {
      _showMessage(l10n.whoPaysServiceFee, isError: true);
      return;
    }

    if (_matchedChargeBracket == null) {
      _showMessage(l10n.noFeeRangeFoundForAmount, isError: true);
      _showMissingChargeRangeAlert();
      return;
    }

    if (_amountToSend <= 0) {
      _showMessage(l10n.amountToSendMustBeGreaterThanZero, isError: true);
      return;
    }

    final isOutflow = _isOutflowSelection;
    final (gcashBalance, mayaWalletBalance, onHandBalance) =
        await _loadCurrentBalances();
    if (!mounted) {
      return;
    }

    final selectedWalletAccount = _selectedWalletAccount;
    final selectedWalletBalance = _selectedWallet == _WalletSelection.maya
        ? mayaWalletBalance
        : gcashBalance;
    // QR Payment: store receives money — no source balance check needed.
    if (!_isQrPayment) {
      final sourceLabel = isOutflow
          ? l10n.onHandCashLabel
          : selectedWalletAccount;
      final requiredSourceAmount =
          _effectiveChargeHandlingMode ==
              _ChargeHandlingMode.deductFromEnteredAmount
          ? _enteredAmount - _chargeFee
          : _enteredAmount;
      final available = isOutflow ? onHandBalance : selectedWalletBalance;
      if (requiredSourceAmount > available) {
        _showMessage(
          l10n.insufficientBalance(sourceLabel, available.toStringAsFixed(2)),
          isError: true,
        );
        return;
      }
    }

    // Capture messenger before any async gap to avoid 'attached' assertion.
    final messenger = ScaffoldMessenger.maybeOf(context);

    // QR Payment: no customer account or party registration needed.
    if (!_isQrPayment) {
      await _resolvePartyFromAccount(accountNumber);

      if (!_isRegisteredAccount) {
        _showMessage(
          l10n.partyNotRegisteredYet,
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
          _showMessage(l10n.partyRegisteredSaving, messenger: messenger);
        } else {
          _showMessage(
            l10n.unableToVerifyRegistration,
            isError: true,
            messenger: messenger,
          );
          return;
        }
      }
    }

    if (!mounted) return;

    // Try backend preview when available, but do not block local save if
    // preview cannot be loaded.
    final previewLoaded = await _loadAndValidatePreview();
    final proceed = previewLoaded
        ? await _showFeeBreakdownDialog()
        : await _showProceedWithoutPreviewDialog();

    if (!proceed) {
      if (!mounted) return;
      return;
    }

    if (!mounted) return;

    final saved = await _saveTransactionRecord();
    if (!saved) {
      if (!mounted) return;
      _showMessage(
        l10n.unableToSaveTransaction,
        isError: true,
        messenger: messenger,
      );
      return;
    }

    if (!mounted) return;

    final partyName = _matchedParty?.name;
    _showMessage(
      partyName != null
          ? l10n.transactionSaved(partyName)
          : 'QR Payment saved successfully.',
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

    // QR Payment does not require a registered party.
    if (principal <= 0 || (!_isQrPayment && _matchedParty == null)) {
      return false;
    }

    final selectedType = FixedTransactionType.forKey(_effectiveTypeKey).label;
    final isOutflow = _isOutflowSelection;
    final walletAccount = _selectedWalletAccount;
    final usesMayaWallet = _selectedWallet == _WalletSelection.maya;
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
    //
    // QR Payment (Top-up): customer pays amount + fee digitally via QR.
    //   wallet increases, on-hand unchanged (no cash exchange).
    //   walletDelta = +(amount + fee), onHandDelta = 0
    final double selectedWalletDelta;
    final double onHandDelta;
    if (_isQrPayment) {
      selectedWalletDelta = amount + chargeFee;
      onHandDelta = 0;
    } else if (!isOutflow) {
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
    final chargeDestination = _chargeDestinationAccount;
    final now = DateTime.now();
    final reference = referenceText.isNotEmpty
        ? referenceText
        : accountNumber.isNotEmpty
        ? accountNumber
        : 'QR-${DateTime.now().millisecondsSinceEpoch}';
    final iconKey = isOutflow ? 'cash_out' : 'cash_in';
    final title = selectedType;
    final noteBase = notes.isNotEmpty
        ? notes
        : _matchedParty != null
        ? 'Account $accountNumber \u2022 ${_matchedParty!.name}'
        : 'QR Payment received';
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
          'charge_destination': chargeDestination,
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

  /// Load and validate preview from backend.
  /// Returns true if preview succeeds, false otherwise.
  /// Stores preview data in [_lastPreview] for display.
  Future<bool> _loadAndValidatePreview() async {
    final amount = _enteredAmount;
    if (amount <= 0) {
      setState(
        () => _previewErrorMessage = context.l10n.amountMustBeGreaterThanZero,
      );
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
        transactionTypeKey: _effectiveTypeKey,
      );

      setState(() {
        _lastPreview = preview;
        _previewErrorMessage = null;
      });
      return true;
    } on TransactionApiException catch (e) {
      final status = e.statusCode == null ? '' : ' (${e.statusCode})';
      setState(
        () => _previewErrorMessage = context.l10n.feeValidationFailedStatus(
          status,
          e.message,
        ),
      );
      return false;
    } catch (e) {
      setState(
        () => _previewErrorMessage = context.l10n.feeValidationFailed('$e'),
      );
      return false;
    }
  }

  Future<bool> _showProceedWithoutPreviewDialog() async {
    final proceed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.backendPreviewUnavailable),
            content: Text(
              _previewErrorMessage ??
                  context.l10n.unableToValidateFeePreviewNow,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.saveLocally),
              ),
            ],
          ),
        ) ??
        false;

    return proceed;
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
            title: Text(context.l10n.feeBreakdownTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.reviewTotals,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewField(
                    _isOutflowSelection
                        ? context.l10n.amountCustomerSends
                        : context.l10n.amountSentToCustomerWallet,
                    '$_pesoLabel ${(_isOutflowSelection ? _totalCollected : _amountToSend).toStringAsFixed(2)}',
                  ),
                  _buildPreviewField(
                    context.l10n.serviceFee,
                    '$_pesoLabel ${_dialogFeeAmount(preview).toStringAsFixed(2)}',
                  ),
                  _buildPreviewField(
                    context.l10n.walletChangeLabel,
                    _signedMoney(_dialogWalletChange(preview)),
                  ),
                  _buildPreviewField(
                    context.l10n.cashChangeLabel,
                    _signedMoney(_dialogCashChange(preview)),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.feeRouting,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    preview.feeRoutingExplanation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.confirmAndSave),
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

  Widget _buildSectionTitle(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
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
              Text(
                context.l10n.selectRegisteredContact,
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
                  hintText: context.l10n.searchNameOrAccount,
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
                        subtitle: context.l10n.registerPartyFirstThenSearch,
                      )
                    : (filtered.isEmpty
                          ? _PartyPickerEmptyState(
                              title: context.l10n.noMatchingContact,
                              subtitle: context.l10n.tryDifferentNameOrAccount,
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
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
                                    context.l10n.accountWithNumber(
                                      party.accountNumber,
                                    ),
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
        _errorText = context.l10n.completeNameAndAccount;
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
        _errorText = context.l10n.unableToSaveParty;
      });
      return;
    }

    if (!mounted) return;

    if (!inserted) {
      setState(() {
        _isSaving = false;
        _errorText = context.l10n.accountAlreadyRegistered;
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
            Expanded(
              child: Text(
                context.l10n.partyRegistrationTitle,
                style: const TextStyle(
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
          Text(
            context.l10n.defineFinancialEntityBeforeTransaction,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
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
                label: Text(
                  _isSaving ? context.l10n.saving : context.l10n.registerParty,
                ),
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
