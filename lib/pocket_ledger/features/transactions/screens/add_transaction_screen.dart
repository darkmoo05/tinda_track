import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/app_meta_dao.dart';
import '../../../../core/di/database_providers.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/domain/sync_metadata.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/receipt_scan/receipt_draft.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
import '../../../../shared/receipt_scan/receipt_scan_button.dart';
import '../../../../shared/receipt_scan/receipt_scan_service.dart';
import '../../charges/domain/entities/charge.dart';
import '../../charges/presentation/providers/charge_providers.dart';
import '../../charges/screens/charges_screen.dart';
import '../../parties/domain/entities/party.dart';
import '../../parties/presentation/providers/party_providers.dart';
import '../data/transaction_repository.dart';
import '../data/transaction_models.dart';
import '../data/fixed_transaction_type.dart';
import '../domain/entities/fee_transaction.dart';
import '../domain/entities/ledger_entry.dart';
import '../presentation/providers/fee_transaction_providers.dart';
import '../presentation/providers/ledger_entry_providers.dart';

enum _ChargeHandlingMode { addOnTop, deductFromEnteredAmount }

enum _WalletSelection { gcash, maya }

enum _FlowDirection { inflow, outflow }

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
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
  final TransactionRepository _transactionRepository =
      TransactionRepository.instance;
  AppDatabase get _database => ref.read(currentAppDatabaseProvider);
  bool _missingRangeAlertVisible = false;
  bool _missingRangeAlertShownForCurrentInput = false;
  String? _lastScannedAccountName;
  bool _showRequiredIndicators = false;
  bool _isSaving = false;
  TransactionPreviewResponse? _lastPreview;
  _ChargeHandlingMode? _chargeHandlingMode;
  bool _showSummaryDetails = false;

  _WalletSelection _selectedWalletSelection = _WalletSelection.gcash;
  String? _selectedServiceKey;
  Party? _matchedParty;

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

  Charge? get _matchedChargeBracket {
    final principal = _parseAmount(_principalController.text);
    if (principal <= 0) {
      return null;
    }

    final typeKey = _selectedTypeKey;
    if (typeKey == null) {
      return null;
    }

    final brackets =
        ref.read(chargesStreamProvider(null)).value ?? const <Charge>[];
    for (final bracket in brackets) {
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
    if (_isQrPayment) {
      return amount + fee;
    }
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

  String get _localFeeRoutingExplanation {
    final amount = _enteredAmount;
    final fee = _chargeFee;
    final chargeHandling = _effectiveChargeHandlingMode;

    if (_isQrPayment) {
      return 'QR Payment (Top-up): customer sends ₱${(amount + fee).toStringAsFixed(2)} via QR (₱${amount.toStringAsFixed(2)} + ₱${fee.toStringAsFixed(2)} service fee). Business wallet increases by ₱${(amount + fee).toStringAsFixed(2)}, no cash exchange.';
    } else if (!_isOutflowSelection) {
      return chargeHandling == _ChargeHandlingMode.addOnTop
          ? 'Inflow: customer pays ₱${amount.toStringAsFixed(2)} + ₱${fee.toStringAsFixed(2)} in cash. Business wallet decreases by ₱${amount.toStringAsFixed(2)} and on-hand increases by ₱${(amount + fee).toStringAsFixed(2)}.'
          : 'Inflow: customer pays ₱${amount.toStringAsFixed(2)} cash. Business wallet decreases by ₱${(amount - fee).toStringAsFixed(2)} (fee deducted from wallet transfer) and on-hand increases by ₱${amount.toStringAsFixed(2)}.';
    } else {
      return chargeHandling == _ChargeHandlingMode.addOnTop
          ? 'Outflow: customer\'s wallet is charged ₱${amount.toStringAsFixed(2)} + ₱${fee.toStringAsFixed(2)}. Business wallet increases by ₱${(amount + fee).toStringAsFixed(2)} and on-hand decreases by ₱${amount.toStringAsFixed(2)}.'
          : 'Outflow: customer\'s wallet is charged ₱${amount.toStringAsFixed(2)}. Business wallet increases by ₱${amount.toStringAsFixed(2)} and on-hand decreases by ₱${(amount - fee).toStringAsFixed(2)} (fee deducted from cash payout).';
    }
  }

  String _signedMoney(double value) {
    final sign = value < 0 ? '-' : '+';
    return '$sign$_pesoLabel ${value.abs().toStringAsFixed(2)}';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_accountController.text.trim().isNotEmpty) {
        _resolvePartyFromAccount(_accountController.text);
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Watch partiesStreamProvider to keep it active and ensure cache matches database
    ref.watch(partiesStreamProvider);

    // Listen to partiesStreamProvider to automatically re-resolve the matched party
    // when the database changes
    ref.listen<AsyncValue<List<Party>>>(partiesStreamProvider, (previous, next) {
      if (next.hasValue) {
        _resolvePartyFromAccount(_accountController.text);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkNavy : AppColors.background,
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
          ),
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
                      isUnderline: true,
                      suffixWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _openAccountSearchPicker,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.search,
                                size: 18,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ReceiptScanButton(
                            onDraftReady: _applyReceiptDraft,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _resolvePartyFromAccount,
                      isRequired: true,
                      hasError: _isAccountNumberMissing,
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.outlineVariant, thickness: 0.5),
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          'Additional Details (Optional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFF8FAFC).withValues(alpha: 0.8)
                                : AppColors.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(top: 8, bottom: 8),
                        iconColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                        collapsedIconColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                        children: [
                          _buildTextField(
                            controller: _referenceController,
                            label: context.l10n.referenceOptional,
                            hint: context.l10n.enterReferenceNumber,
                            isBorderless: true,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _notesController,
                            label: context.l10n.notesOptional,
                            hint: context.l10n.additionalDetails,
                            maxLines: 3,
                            isBorderless: true,
                          ),
                        ],
                      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF022C22) : AppColors.successLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF065F46) : AppColors.successBorder,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: isDark ? const Color(0xFF34D399) : AppColors.success,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.verifiedAccountFound(name),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF34D399) : AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyNotRegisteredAlert() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.accountNotInContacts,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+ Register',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationPreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? (_selectedWalletSelection == _WalletSelection.maya
            ? AppColors.mayaNeon
            : AppColors.gcashNeon)
        : _selectedWalletColor;
    final surfaceColor = isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest;
    final borderColor = isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant.withValues(alpha: 0.6);
    final labelColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;
    final valueColor = isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface;
    final dashedColor = isDark ? const Color(0xFF334155) : AppColors.outlineVariant.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: activeColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.reviewTotals,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showSummaryDetails = !_showSummaryDetails;
                    });
                  },
                  icon: Icon(
                    _showSummaryDetails
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _showSummaryDetails ? 'Hide details' : 'Show details',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: activeColor,
                  ),
                ),
              ],
            ),
          ),

          // Collapsible breakdown details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildPreviewRow(
                    context.l10n.whoPaysServiceFee,
                    _chargeHandlingMode == null
                        ? 'Select fee handling'
                        : _chargeHandlingDisplayLabel,
                    labelColor: labelColor,
                    valueColor: valueColor,
                  ),
                  const SizedBox(height: 6),
                  _buildPreviewRow(
                    context.l10n.usingWallet,
                    _selectedWalletAccount,
                    labelColor: labelColor,
                    valueColor: valueColor,
                  ),
                  const SizedBox(height: 6),
                  _buildPreviewRow(
                    context.l10n.feeDestination,
                    _chargeDestinationAccount,
                    labelColor: labelColor,
                    valueColor: valueColor,
                  ),
                  if (_matchedChargeBracket != null) ...[
                    const SizedBox(height: 6),
                    _buildPreviewRow(
                      context.l10n.feeRange,
                      '$_pesoLabel ${_matchedChargeBracket!.lowerBound.toStringAsFixed(2)} - $_pesoLabel ${_matchedChargeBracket!.upperBound.toStringAsFixed(2)}',
                      labelColor: labelColor,
                      valueColor: valueColor,
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
            crossFadeState: _showSummaryDetails
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),

          // Dotted Perforated Line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: DashedLinePainter(color: dashedColor),
            ),
          ),

          // Main receipt details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReceiptLine(
                  'Principal Amount',
                  '$_pesoLabel ${_enteredAmount.toStringAsFixed(2)}',
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
                const SizedBox(height: 8),
                _buildReceiptLine(
                  'Service Fee',
                  '$_pesoLabel ${_chargeFee.toStringAsFixed(2)}',
                  labelColor: labelColor,
                  valueColor: _chargeFee > 0 ? AppColors.error : valueColor,
                ),
                const SizedBox(height: 14),

                // Dashed separator for total
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: DashedLinePainter(color: dashedColor),
                ),
                const SizedBox(height: 14),

                // Digital Wallet Impact Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _isQrPayment
                                ? 'Total Received in Wallet'
                                : _isOutflowSelection
                                    ? 'Total Charged to Wallet'
                                    : 'Total Sent to Wallet',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$_pesoLabel ${(_isQrPayment
                              ? _walletDeltaPreview
                              : _isOutflowSelection
                                  ? _totalCollected
                                  : _amountToSend).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: valueColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Physical Cash Handover Row (Large & Highlighted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _isQrPayment
                                ? 'Cash Exchange (Digital)'
                                : _isOutflowSelection
                                    ? 'Cash to Hand to Customer'
                                    : 'Cash to Collect from Customer',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$_pesoLabel ${(_isQrPayment
                              ? 0.0
                              : _isOutflowSelection
                                  ? _amountToSend
                                  : _totalCollected).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_enteredAmount > 0 && _matchedChargeBracket == null) ...[
                  const SizedBox(height: 12),
                  _buildNoBracketWarning(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptLine(
    String label,
    String value, {
    Color? labelColor,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: labelColor ?? (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? (isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewRow(
    String label,
    String value, {
    Color? labelColor,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedLabelColor = labelColor ?? (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant);
    final resolvedValueColor = valueColor ?? (isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: resolvedLabelColor,
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: resolvedValueColor,
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
                style: TextStyle(
                  fontSize: 12,
                  color: resolvedLabelColor,
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: resolvedValueColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoBracketWarning() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF450A0A) : AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? const Color(0xFF991B1B) : AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? const Color(0xFFFCA5A5) : AppColors.error,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.l10n.noFeeRuleForAmount,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFFFCA5A5) : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeHandlingSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showChargeHandlingError =
        _showRequiredIndicators &&
        _canCustomizeFeeHandling &&
        _chargeHandlingMode == null;
    final activeColor = isDark
        ? (_selectedWalletSelection == _WalletSelection.maya
            ? AppColors.mayaNeon
            : AppColors.gcashNeon)
        : _selectedWalletColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant.withValues(alpha: 0.55),
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
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B0F19) : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: showChargeHandlingError
                    ? AppColors.error
                    : (isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant.withValues(alpha: 0.55)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFeeHandlingOption(
                    label: context.l10n.customerPaysFeeLabel,
                    selected: _chargeHandlingMode == _ChargeHandlingMode.addOnTop,
                    activeColor: activeColor,
                    onTap: () {
                      setState(() {
                        _chargeHandlingMode = _ChargeHandlingMode.addOnTop;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildFeeHandlingOption(
                    label: context.l10n.deductedFromSentLabel,
                    selected: _chargeHandlingMode == _ChargeHandlingMode.deductFromEnteredAmount,
                    activeColor: activeColor,
                    onTap: () {
                      setState(() {
                        _chargeHandlingMode = _ChargeHandlingMode.deductFromEnteredAmount;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (showChargeHandlingError) ...[
            const SizedBox(height: 6),
            Text(
              'Please choose a fee handling option.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Applicable fee: $_pesoLabel ${_chargeFee.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeHandlingOption({
    required String label,
    required bool selected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 185),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? activeColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? activeColor
                  : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
            ),
          ),
        ),
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
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.l10n.saveTransactionAction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showTypeError =
        _showRequiredIndicators && _selectedServiceKey == null;
    final activeColor = isDark
        ? (_selectedWalletSelection == _WalletSelection.maya
            ? AppColors.mayaNeon
            : AppColors.gcashNeon)
        : _selectedWalletColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(
          context.l10n.walletAndService,
          isRequired: true,
          showErrorIndicator: showTypeError,
        ),
        const SizedBox(height: 10),
        
        // Distinct Wallet Selector buttons side-by-side
        Row(
          children: [
            Expanded(
              child: _buildWalletButton(
                label: 'GCash',
                selected: _selectedWalletSelection == _WalletSelection.gcash,
                activeBgColor: isDark ? AppColors.gcash.withValues(alpha: 0.2) : AppColors.gcash,
                activeTextColor: isDark ? AppColors.gcashNeon : Colors.white,
                activeBorderColor: isDark ? AppColors.gcashNeon : AppColors.gcash,
                logoWidget: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _selectedWalletSelection == _WalletSelection.gcash 
                        ? (isDark ? AppColors.gcashNeon : Colors.white) 
                        : (isDark ? const Color(0xFF161D30) : AppColors.gcash),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'G',
                    style: TextStyle(
                      color: _selectedWalletSelection == _WalletSelection.gcash 
                          ? (isDark ? Colors.black : AppColors.gcash) 
                          : (isDark ? const Color(0xFF94A3B8) : Colors.white),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedWalletSelection = _WalletSelection.gcash;
                  });
                  _onPrincipalChanged(_principalController.text);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWalletButton(
                label: 'Maya',
                selected: _selectedWalletSelection == _WalletSelection.maya,
                activeBgColor: isDark ? AppColors.secondary.withValues(alpha: 0.2) : Colors.white,
                activeTextColor: isDark ? AppColors.mayaNeon : AppColors.maya,
                activeBorderColor: isDark ? AppColors.mayaNeon : AppColors.maya,
                logoWidget: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _selectedWalletSelection == _WalletSelection.maya
                        ? (isDark ? AppColors.mayaNeon : Colors.black)
                        : (isDark ? const Color(0xFF161D30) : Colors.black),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'm',
                    style: TextStyle(
                      color: _selectedWalletSelection == _WalletSelection.maya
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark ? const Color(0xFF94A3B8) : Colors.white),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedWalletSelection = _WalletSelection.maya;
                  });
                  _onPrincipalChanged(_principalController.text);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Custom vertical service selection chips row
        SizedBox(
          height: 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _serviceOptions.map((serviceKey) {
                final isSelected = _selectedServiceKey == serviceKey;
                final icon = _serviceIcon(serviceKey);
                final label = _serviceLabel(serviceKey);

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedServiceKey = serviceKey;
                      });
                      _onPrincipalChanged(_principalController.text);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 68,
                      height: 76,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? activeColor.withValues(alpha: 0.08) 
                            : (isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? activeColor
                              : (isDark ? const Color(0xFF1E293B) : Colors.transparent),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? activeColor 
                                  : (isDark ? const Color(0xFF1E293B) : Colors.grey.withValues(alpha: 0.15)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 16,
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected
                                      ? activeColor
                                      : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (showTypeError) ...[
          const SizedBox(height: 8),
          const Text(
            'Please choose a transaction type.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWalletButton({
    required String label,
    required bool selected,
    required Color activeBgColor,
    required Color activeTextColor,
    required Color activeBorderColor,
    required Widget logoWidget,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        decoration: BoxDecoration(
          color: selected ? activeBgColor : (isDark ? AppColors.darkNavyTile : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? activeBorderColor
                : (isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeBorderColor.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logoWidget,
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? activeTextColor
                        : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _serviceIcon(String serviceKey) {
    switch (serviceKey) {
      case 'cashin':
        return Icons.payments_rounded;
      case 'cashout':
        return Icons.swap_vert_rounded;
      case 'load':
        return Icons.phone_android_rounded;
      case 'paybills':
        return Icons.receipt_rounded;
      case 'qrpayment':
        return Icons.qr_code_2_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefixText,
    IconData? suffixIcon,
    Future<void> Function()? onSuffixPressed,
    Widget? suffixWidget,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
    bool isRequired = false,
    bool hasError = false,
    bool isUnderline = false,
    bool isBorderless = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    InputDecoration decoration;
    if (isUnderline) {
      final borderSide = BorderSide(
        color: hasError
            ? AppColors.error
            : (isDark ? const Color(0xFF334155) : AppColors.outlineVariant),
        width: 1.0,
      );
      final activeBorderSide = BorderSide(
        color: hasError ? AppColors.error : AppColors.primary,
        width: 1.5,
      );
      final underlineBorder = UnderlineInputBorder(borderSide: borderSide);
      final activeUnderlineBorder = UnderlineInputBorder(borderSide: activeBorderSide);

      decoration = InputDecoration(
        filled: false,
        border: underlineBorder,
        enabledBorder: underlineBorder,
        focusedBorder: activeUnderlineBorder,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF64748B) : AppColors.outlineVariant,
          fontSize: 13,
        ),
      );
    } else if (isBorderless) {
      final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      );
      decoration = InputDecoration(
        filled: true,
        fillColor: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF64748B) : AppColors.outlineVariant,
          fontSize: 13,
        ),
      );
    } else {
      decoration = _inputDecoration(hasError: hasError);
    }

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
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
          ),
          decoration: decoration.copyWith(
            hintText: hint,
            prefixText: prefixText,
            prefixStyle: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            ),
            suffixIcon: suffixWidget ?? (suffixIcon == null
                ? null
                : IconButton(
                    icon: Icon(
                      suffixIcon,
                      size: 18,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    ),
                    onPressed: onSuffixPressed == null
                        ? null
                        : () async {
                            await onSuffixPressed();
                          },
                  )),
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

  Future<void> _openAccountSearchPicker() async {
    if (!mounted) return;
    final parties = ref.read(partiesStreamProvider).value ?? const <Party>[];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selected = await showModalBottomSheet<Party>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _PartyContactPickerSheet(
        parties: parties,
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
    final parties = ref.read(partiesStreamProvider).value ?? const <Party>[];
    Party? matchedParty;
    for (final p in parties) {
      if (p.accountNumber == requestedAccount) {
        matchedParty = p;
        break;
      }
    }
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
    if (_selectedTypeKey == null) {
      _missingRangeAlertShownForCurrentInput = false;
      return;
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goToCharges = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
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
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: isDark ? AppColors.gcashNeon : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.noFeeRangeFoundTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.noFeeRangeFoundMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
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
                    side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.outlineVariant),
                    foregroundColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
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
                    backgroundColor: isDark ? AppColors.primaryContainer : AppColors.primary,
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
    // preview cannot be loaded (instead, fallback to local calculation breakdown).
    final previewLoaded = await _loadAndValidatePreview();
    final proceed = await _showFeeBreakdownDialog(isOffline: !previewLoaded);

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

    final db = _database;
    try {
      final deviceId = await AppMetaDao(db).getOrCreateDeviceId();
      final nowMs = now.millisecondsSinceEpoch;
      final entrySyncId = const Uuid().v4();

      final ledgerEntry = LedgerEntry(
        id: entrySyncId,
        entryType: 'transaction',
        title: title,
        note: persistedNote,
        reference: reference,
        amount: totalCollected,
        walletDelta: walletDelta,
        mayaWalletDelta: mayaWalletDelta,
        onHandDelta: onHandDelta,
        recordedFlow: totalCollected,
        tag: 'Transaction',
        iconKey: iconKey,
        walletAccount: walletAccount,
        entryDate: now.toIso8601String(),
        sync: SyncMetadata(
          syncId: entrySyncId,
          deviceId: deviceId,
          createdAt: now,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(nowMs),
          isDirty: true,
        ),
      );

      await db.transaction(() async {
        await ref.read(ledgerEntryRepositoryProvider).save(ledgerEntry);

        // Save fee as separate record if fee exists
        if (chargeFee > 0) {
          final feeSyncId = const Uuid().v4();
          final fee = FeeTransaction(
            id: feeSyncId,
            relatedTransactionSyncId: entrySyncId,
            feeAmount: chargeFee,
            feeType: title,
            chargeDestination: chargeDestination,
            sync: SyncMetadata(
              syncId: feeSyncId,
              deviceId: deviceId,
              createdAt: now,
              updatedAt: DateTime.fromMillisecondsSinceEpoch(nowMs),
              isDirty: true,
            ),
          );
          await ref.read(feeTransactionRepositoryProvider).save(fee);
        }
      });

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
      });
      return true;
    } on TransactionApiException catch (e) {
      debugPrint('Failed to load transaction preview: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Failed to load transaction preview: $e');
      return false;
    }
  }

  Future<bool> _showFeeBreakdownDialog({bool isOffline = false}) async {
    final preview = _lastPreview;
    if (!isOffline && preview == null) return false;

    final chargeAmount = isOffline ? _chargeFee : preview!.chargeAmount;
    final walletCredit = isOffline ? _walletDeltaPreview : preview!.walletCredit;
    final onHandChange = isOffline ? _cashDeltaPreview : preview!.onHandChange;
    final explanation = isOffline ? _localFeeRoutingExplanation : preview!.feeRoutingExplanation;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? (_selectedWalletSelection == _WalletSelection.maya
            ? AppColors.mayaNeon
            : AppColors.gcashNeon)
        : _selectedWalletColor;

    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
            title: Text(
              context.l10n.feeBreakdownTitle,
              style: TextStyle(
                color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOffline) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: activeColor.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            color: activeColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Offline Mode • Calculating locally. Syncs when connection is restored.',
                              style: TextStyle(
                                fontSize: 10,
                                color: activeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    context.l10n.reviewTotals,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewField(
                    _isQrPayment
                        ? 'Total Received in Wallet'
                        : _isOutflowSelection
                            ? 'Total Charged to Wallet'
                            : 'Total Sent to Wallet',
                    '$_pesoLabel ${(isOffline
                        ? (_isOutflowSelection ? _totalCollected : _amountToSend)
                        : _isOutflowSelection
                            ? preview!.totalCollected
                            : preview!.walletCredit.abs()).toStringAsFixed(2)}',
                  ),
                  _buildPreviewField(
                    context.l10n.serviceFee,
                    '$_pesoLabel ${chargeAmount.toStringAsFixed(2)}',
                  ),
                  _buildPreviewField(
                    '$_selectedWalletAccount Balance Change',
                    _signedMoney(walletCredit),
                  ),
                  _buildPreviewField(
                    'Cash Balance Change',
                    _signedMoney(onHandChange),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? const Color(0xFF1E293B) : null),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.feeRouting,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    explanation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
                child: Text(context.l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryContainer : AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.l10n.confirmAndSave),
              ),
            ],
          ),
        ) ??
        false;

    return confirmed;
  }

  Widget _buildPreviewField(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Future<(double walletBalance, double mayaWalletBalance, double onHandBalance)>
  _loadCurrentBalances() async {
    final rawRows = await _database.customSelect('''
      SELECT
        COALESCE(SUM(wallet_delta), 0) AS wallet_balance,
        COALESCE(SUM(maya_wallet_delta), 0) AS maya_wallet_balance,
        COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ledger_entries
      WHERE is_deleted = 0
    ''').get();

    if (rawRows.isEmpty) {
      return (0.0, 0.0, 0.0);
    }

    final row = rawRows.first.data;
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

    final registeredParty = await showDialog<Party>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PartyRegistrationDialog(
        prefilledAccountNumber: prefilledAccountNumber,
        prefilledAccountName: prefilledAccountName,
      ),
    );

    if (registeredParty != null && mounted) {
      _accountController.text = registeredParty.accountNumber;
      setState(() {
        _matchedParty = registeredParty;
      });
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
          backgroundColor: isError ? AppColors.error : AppColors.success,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: showErrorIndicator
          ? AppColors.error
          : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
      ),
    );
  }

  InputDecoration _inputDecoration({bool hasError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
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
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF64748B) : AppColors.outlineVariant,
        fontSize: 13,
      ),
    );
  }
}

class _PartyContactPickerSheet extends StatefulWidget {
  const _PartyContactPickerSheet({
    required this.parties,
    required this.initialQuery,
  });

  final List<Party> parties;
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

  List<Party> get _filteredParties {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    color: isDark ? const Color(0xFF334155) : AppColors.outlineVariant.withValues(alpha: 0.7),
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
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.searchNameOrAccount,
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : AppColors.outlineVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
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
                                  Divider(
                                    height: 1,
                                    color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant,
                                  ),
                              itemBuilder: (context, index) {
                                final party = filtered[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isDark
                                        ? AppColors.primary.withValues(alpha: 0.25)
                                        : AppColors.primary.withValues(alpha: 0.15),
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: isDark ? AppColors.gcashNeon : AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    party.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    context.l10n.accountWithNumber(
                                      party.accountNumber,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 32,
              color: isDark ? const Color(0xFF64748B) : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyRegistrationDialog extends ConsumerStatefulWidget {
  const _PartyRegistrationDialog({
    required this.prefilledAccountNumber,
    this.prefilledAccountName,
  });

  final String prefilledAccountNumber;
  final String? prefilledAccountName;

  @override
  ConsumerState<_PartyRegistrationDialog> createState() =>
      _PartyRegistrationDialogState();
}

class _PartyRegistrationDialogState
    extends ConsumerState<_PartyRegistrationDialog> {
  static final DateFormat _joinDateFormat = DateFormat('MMM yyyy');

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

  String _normalizeAccount(String raw) =>
      raw.replaceAll(RegExp(r'[^0-9]'), '').trim();

  String _buildEntityId(String accountNumber, int currentCount) {
    final digitsOnly = _normalizeAccount(accountNumber);
    final suffix = digitsOnly.length >= 3
        ? digitsOnly.substring(digitsOnly.length - 3)
        : digitsOnly.padLeft(3, '0');
    final sequence = (currentCount + 1).toString().padLeft(3, '0');
    return 'FA-$suffix-$sequence';
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

    final normalizedAccount = _normalizeAccount(accountNumber);
    final parties = ref.read(partiesStreamProvider).value ?? const <Party>[];
    final duplicate = parties.any(
      (p) => _normalizeAccount(p.accountNumber) == normalizedAccount,
    );
    if (duplicate) {
      setState(() {
        _isSaving = false;
        _errorText = context.l10n.accountAlreadyRegistered;
      });
      return;
    }

    final now = DateTime.now();
    final newParty = Party(
      id: '',
      name: fullName,
      accountNumber: normalizedAccount,
      entityId: _buildEntityId(normalizedAccount, parties.length),
      description: 'Newly Registered',
      joinDate: _joinDateFormat.format(now),
      isVerified: true,
      sync: SyncMetadata(
        syncId: '',
        createdAt: now,
        updatedAt: now,
        isDirty: true,
      ),
    );

    try {
      final savedParty = await ref.read(partiesNotifierProvider.notifier).save(newParty);
      if (!mounted) return;
      Navigator.of(context).pop(savedParty);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = context.l10n.unableToSaveParty;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.12)
              : AppColors.secondary.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.secondary.withValues(alpha: 0.25)
                    : AppColors.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_add_alt_1_rounded,
                color: isDark ? AppColors.secondaryContainer : AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.partyRegistrationTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
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
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
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
                  side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.outlineVariant),
                  foregroundColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
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
                  backgroundColor: isDark ? AppColors.secondaryContainer : AppColors.secondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF64748B) : AppColors.outlineVariant,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
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

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({this.color = const Color(0xFFCBD5E1)});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
