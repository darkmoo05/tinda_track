import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/data/app_database.dart';
import '../../core/app_theme.dart';
import '../charges/data/charge_repository.dart';
import '../charges/charges_screen.dart';
import '../parties/data/party_repository.dart';

enum _ChargeHandlingMode { addOnTop, deductFromEnteredAmount }

enum _WalletSelection { gcash, maya }

enum _FlowDirection { inflow, outflow }

enum _ReceiptImageSource { camera, gallery, file }

enum _FieldConfidence { unknown, low, medium, high }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _accountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _principalController = TextEditingController();
  final _notesController = TextEditingController();
  final PartyRepository _partyRepository = PartyRepository.instance;
  final ChargeRepository _chargeRepository = ChargeRepository.instance;
  final AppDatabase _database = AppDatabase.instance;
  bool _missingRangeAlertVisible = false;
  bool _missingRangeAlertShownForCurrentInput = false;
  bool _isLoadingTransactionTypes = true;
  bool _isScanningReceipt = false;
  String?
  _lastScannedAccountName; // Temporarily store account name from receipt scan
  bool _showRequiredIndicators = false;
  bool _isSaving = false;
  _ChargeHandlingMode _chargeHandlingMode = _ChargeHandlingMode.addOnTop;
  _WalletSelection _selectedWallet = _WalletSelection.gcash;
  _FlowDirection _selectedFlowDirection = _FlowDirection.inflow;

  int? _selectedTypeId;
  PartyRecord? _matchedParty;

  List<TransactionTypeRecord> _transactionTypes = const [];

  void _applyTypeSelection(int? typeId) {
    _selectedTypeId = typeId;
    final selectedRecord = _selectedTransactionType;
    if (selectedRecord == null) {
      return;
    }

    _selectedWallet =
        selectedRecord.walletAccount.toLowerCase().contains('maya')
        ? _WalletSelection.maya
        : _WalletSelection.gcash;
    _selectedFlowDirection = selectedRecord.isOutflow
        ? _FlowDirection.outflow
        : _FlowDirection.inflow;
  }

  TransactionTypeRecord? get _selectedTransactionType {
    final selectedTypeId = _selectedTypeId;
    if (selectedTypeId == null) {
      return null;
    }

    for (final type in _transactionTypes) {
      if (type.id == selectedTypeId) {
        return type;
      }
    }
    return null;
  }

  ChargeBracketRecord? get _matchedChargeBracket {
    final principal = double.tryParse(_principalController.text) ?? 0;
    if (principal <= 0) {
      return null;
    }

    for (final bracket in _chargeRepository.brackets.value) {
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
    if (_chargeHandlingMode == _ChargeHandlingMode.deductFromEnteredAmount) {
      final amount = _enteredAmount - _chargeFee;
      return amount > 0 ? amount : 0;
    }
    return _enteredAmount;
  }

  double get _totalCollected {
    if (_chargeHandlingMode == _ChargeHandlingMode.deductFromEnteredAmount) {
      return _enteredAmount;
    }
    return _enteredAmount + _chargeFee;
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

  bool get _isTypeMissing =>
      _showRequiredIndicators && _selectedTransactionType == null;

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

  String get _defaultTransactionTitle {
    final walletLabel = _selectedWallet == _WalletSelection.maya
        ? 'Maya'
        : 'GCash';
    final flowLabel = _isOutflowSelection ? 'Cash Out' : 'Cash In';
    return '$walletLabel $flowLabel';
  }

  @override
  void initState() {
    super.initState();
    _loadTransactionTypes();
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
        title: const Text(
          'New Entry',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Record Transaction',
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
                _buildDropdownField(
                  label: 'Transaction Type',
                  value:
                      _selectedTypeId != null &&
                          _transactionTypes.any(
                            (type) => type.id == _selectedTypeId,
                          )
                      ? _selectedTypeId
                      : null,
                  items: _transactionTypes,
                  hintText: 'Choose Transaction Type',
                  onChanged: _isLoadingTransactionTypes
                      ? null
                      : (val) {
                          setState(() {
                            _applyTypeSelection(val);
                          });
                        },
                  onAddPressed: _showAddTransactionTypeDialog,
                  onManagePressed: _showManageTransactionTypesDialog,
                  isRequired: true,
                  hasError: _isTypeMissing,
                ),
                if (_isLoadingTransactionTypes) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                const SizedBox(height: 16),
                _buildTypeProfilePreview(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _accountController,
                  label: 'Account Number',
                  hint: 'Search or enter account number',
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
                  child: OutlinedButton.icon(
                    onPressed: _isScanningReceipt
                        ? null
                        : _scanReceiptAndAutofill,
                    icon: _isScanningReceipt
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.document_scanner_outlined, size: 16),
                    label: Text(
                      _isScanningReceipt
                          ? 'Scanning receipt...'
                          : 'Scan Receipt (Camera/Gallery)',
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                if (_hasTypedAccount && _isRegisteredAccount) ...[
                  const SizedBox(height: 8),
                  _buildPartyFoundBanner(_matchedParty!.name),
                ],
                if (_hasTypedAccount && !_isRegisteredAccount) ...[
                  const SizedBox(height: 8),
                  _buildPartyNotRegisteredAlert(),
                ],
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _principalController,
                  label: 'Transaction Amount',
                  hint: '0.00',
                  prefixText: '₱  ',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;
                      if (text.isEmpty) return newValue;
                      if (text.startsWith('.')) return oldValue;
                      final dotCount = '.'.allMatches(text).length;
                      if (dotCount > 1) return oldValue;
                      return newValue;
                    }),
                  ],
                  onChanged: _onPrincipalChanged,
                  isRequired: true,
                  hasError: _isPrincipalMissing,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _referenceController,
                  label: 'Reference',
                  hint: 'Enter receipt / reference number',
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                ),
                const SizedBox(height: 12),
                _buildChargeHandlingSelector(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Optional notes...',
                  maxLines: 3,
                  inputFormatters: [LengthLimitingTextInputFormatter(300)],
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

  Widget _buildDropdownField({
    required String label,
    required int? value,
    required List<TransactionTypeRecord> items,
    String? hintText,
    ValueChanged<int?>? onChanged,
    VoidCallback? onAddPressed,
    VoidCallback? onManagePressed,
    bool isRequired = false,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _fieldLabel(
              label,
              isRequired: isRequired,
              showErrorIndicator: hasError,
            ),
            const Spacer(),
            if (onAddPressed != null)
              _buildTypeActionButton(
                label: 'Add Type',
                icon: Icons.add_rounded,
                color: AppColors.primary,
                onTap: onAddPressed,
              ),
            if (onManagePressed != null)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _buildTypeActionButton(
                  label: 'Manage',
                  icon: Icons.settings_rounded,
                  color: AppColors.onSurfaceVariant,
                  onTap: onManagePressed,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          decoration: _inputDecoration(
            hasError: hasError,
          ).copyWith(hintText: hintText),
          icon: const Icon(
            Icons.expand_more_rounded,
            color: AppColors.onSurfaceVariant,
          ),
          selectedItemBuilder: (context) {
            return items
                .map(
                  (t) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList();
          },
          items: items
              .map(
                (t) => DropdownMenuItem(
                  value: t.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          t.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: t.isOutflow
                              ? AppColors.error.withValues(alpha: 0.12)
                              : AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t.isOutflow ? 'RECEIVE' : 'SEND',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: t.isOutflow
                                ? AppColors.error
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: t.walletAccount.toLowerCase().contains('maya')
                              ? AppColors.secondary.withValues(alpha: 0.14)
                              : AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t.walletAccount.toLowerCase().contains('maya')
                              ? 'MAYA'
                              : 'GCASH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color:
                                t.walletAccount.toLowerCase().contains('maya')
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTypeActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeProfilePreview() {
    final selectedType = _selectedTransactionType;
    final walletColor = _selectedWalletColor;

    if (selectedType == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select a transaction type to auto-set wallet and flow.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: walletColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: walletColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(
            _selectedWallet == _WalletSelection.maya
                ? Icons.wallet_rounded
                : Icons.account_balance_wallet_outlined,
            size: 16,
            color: walletColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${selectedType.walletAccount} — ${selectedType.isOutflow ? 'Customer Receives' : 'Customer Sends'}',
              style: TextStyle(
                fontSize: 12,
                color: walletColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTransactionTypes({int? preferSelectId}) async {
    setState(() {
      _isLoadingTransactionTypes = true;
    });

    final loadedTypes = await _database.loadTransactionTypeRecords();
    if (!mounted) {
      return;
    }

    int? nextSelectedId;
    if (preferSelectId != null) {
      if (loadedTypes.any((type) => type.id == preferSelectId)) {
        nextSelectedId = preferSelectId;
      }
    } else if (_selectedTypeId != null &&
        loadedTypes.any((type) => type.id == _selectedTypeId)) {
      nextSelectedId = _selectedTypeId;
    }

    setState(() {
      _transactionTypes = loadedTypes;
      _applyTypeSelection(nextSelectedId);
      _isLoadingTransactionTypes = false;
    });
  }

  Future<void> _showAddTransactionTypeDialog() async {
    final createdType = await showDialog<_TransactionTypeDraft>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (_) =>
          _UpsertTransactionTypeDialog(existingTypes: _transactionTypes),
    );

    if (createdType == null || createdType.name.trim().isEmpty) {
      return;
    }

    final insertedId = await _database.insertTransactionType(
      createdType.name,
      isOutflow: createdType.isOutflow,
      walletAccount: createdType.walletSelection == _WalletSelection.maya
          ? 'Maya Wallet'
          : 'GCash',
    );
    if (!mounted) {
      return;
    }

    await _loadTransactionTypes(preferSelectId: insertedId);
    if (!mounted) {
      return;
    }
    _showMessage(
      'Transaction type added: ${createdType.name.trim()} (${createdType.isOutflow ? 'Customer Receives' : 'Customer Sends'} • ${createdType.walletSelection == _WalletSelection.maya ? 'Maya Wallet' : 'GCash'})',
    );
  }

  Future<void> _showManageTransactionTypesDialog() async {
    if (_transactionTypes.isEmpty) {
      _showMessage(
        'No transaction types available. Add one first.',
        isError: true,
      );
      return;
    }

    final selectedAction = await showDialog<_TypeActionPayload>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (_) => _ManageTransactionTypesDialog(
        types: _transactionTypes,
        selectedTypeId: _selectedTypeId,
      ),
    );

    if (selectedAction == null || !mounted) {
      return;
    }

    switch (selectedAction.action) {
      case _TypeAction.edit:
        await _editTransactionType(selectedAction.type);
        break;
      case _TypeAction.delete:
        await _deleteTransactionType(selectedAction.type);
        break;
    }
  }

  Future<void> _editTransactionType(TransactionTypeRecord type) async {
    final result = await showDialog<_TransactionTypeDraft>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (_) => _UpsertTransactionTypeDialog(
        existingTypes: _transactionTypes,
        initialName: type.name,
        initialIsOutflow: type.isOutflow,
        initialWalletSelection:
            type.walletAccount.toLowerCase().contains('maya')
            ? _WalletSelection.maya
            : _WalletSelection.gcash,
      ),
    );

    if (result == null || result.name.trim().isEmpty) {
      return;
    }

    try {
      await _database.updateTransactionType(
        id: type.id,
        name: result.name,
        isOutflow: result.isOutflow,
        walletAccount: result.walletSelection == _WalletSelection.maya
            ? 'Maya Wallet'
            : 'GCash',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(
        'Unable to update type. Name may already exist.',
        isError: true,
      );
      return;
    }

    if (!mounted) {
      return;
    }
    await _loadTransactionTypes(preferSelectId: type.id);
    if (!mounted) {
      return;
    }
    _showMessage('Transaction type updated.');
  }

  Future<void> _deleteTransactionType(TransactionTypeRecord type) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                    color: AppColors.error.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Delete Transaction Type',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${type.name}"? This cannot be undone.',
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
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    icon: const Icon(
                      Icons.delete_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _database.deleteTransactionType(type.id);
    if (!mounted) {
      return;
    }

    await _loadTransactionTypes();
    if (!mounted) {
      return;
    }
    _showMessage('Transaction type deleted.');
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? suffixIcon,
    VoidCallback? onSuffixPressed,
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
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
          onChanged: (value) {
            setState(() {});
            onChanged?.call(value);
          },
          decoration: _inputDecoration(hasError: hasError).copyWith(
            hintText: hint,
            prefixText: prefixText,
            suffixIcon: suffixIcon != null
                ? (onSuffixPressed != null
                      ? IconButton(
                          onPressed: onSuffixPressed,
                          tooltip: 'Search contacts',
                          icon: Icon(
                            suffixIcon,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                        )
                      : Icon(
                          suffixIcon,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ))
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _openAccountSearchPicker() async {
    await _partyRepository.ensureLoaded();
    if (!mounted) {
      return;
    }

    final selectedParty = await showModalBottomSheet<PartyRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _PartyContactPickerSheet(
        parties: _partyRepository.parties.value,
        initialQuery: _accountController.text.trim(),
      ),
    );

    if (!mounted || selectedParty == null) {
      return;
    }

    _accountController.text = selectedParty.accountNumber;
    await _resolvePartyFromAccount(selectedParty.accountNumber);
  }

  Future<void> _scanReceiptAndAutofill() async {
    if (_isScanningReceipt) {
      return;
    }

    setState(() {
      _isScanningReceipt = true;
    });

    var stage = 'initialization';
    try {
      stage = 'image selection';
      final path = await _pickReceiptImagePath();
      if (path == null || path.isEmpty) {
        return;
      }

      stage = 'OCR processing';
      // Fast path: parse direct OCR first.
      final rawText = await _runOcrOnImagePath(path);
      var mergedRawText = rawText;

      stage = 'quick parse';
      final quickDraft = _parseReceiptDraftSafely(
        rawText,
        sourceName: p.basename(path),
      );

      final shouldRunCropPass =
          quickDraft == null ||
          !quickDraft.hasAnyAutofillField ||
          !_isPlausibleScannedAmount(quickDraft.amount) ||
          quickDraft.amountConfidence == _FieldConfidence.low ||
          quickDraft.amountConfidence == _FieldConfidence.unknown;

      if (shouldRunCropPass) {
        stage = 'OCR crop pass';
        final croppedText = await _runCroppedOcrPass(path);
        if (croppedText.isNotEmpty) {
          mergedRawText = '$rawText\n$croppedText';
        }
      }

      stage = 'receipt parsing';
      final draft = _parseReceiptDraftSafely(
        mergedRawText,
        sourceName: p.basename(path),
      );
      if (!mounted) {
        return;
      }
      if (draft == null || !draft.hasAnySignal) {
        _showMessage(
          'OCR completed but no usable amount/account/reference was detected. Try a clearer receipt image.',
          isError: true,
        );
        return;
      }

      stage = 'confirmation dialog';
      final shouldApply = await _confirmReceiptAutofill(draft);
      if (!mounted || !shouldApply) {
        return;
      }

      final suggestedTypeId = _pickBestTransactionTypeId(draft);

      stage = 'field autofill';
      setState(() {
        if (draft.accountNumber != null && draft.accountNumber!.isNotEmpty) {
          _accountController.text = draft.accountNumber!;
        }
        if (draft.amount != null && draft.amount! > 0) {
          final formattedAmount = _formatScannedAmountForInput(draft.amount!);
          if (formattedAmount.isNotEmpty) {
            _principalController.text = formattedAmount;
          }
        }
        if (draft.reference != null && draft.reference!.trim().isNotEmpty) {
          _referenceController.text = draft.reference!.trim();
        }
        if (suggestedTypeId != null) {
          _applyTypeSelection(suggestedTypeId);
        } else if (draft.walletSelection != null &&
            _selectedTransactionType == null) {
          _selectedWallet = draft.walletSelection!;
        }
      });

      if (draft.accountNumber != null && draft.accountNumber!.isNotEmpty) {
        stage = 'party resolution';
        // Store account name from scan for later use in party registration
        _lastScannedAccountName = draft.accountName;
        try {
          await _resolvePartyFromAccount(draft.accountNumber!);
        } catch (error, stackTrace) {
          debugPrint(
            'Receipt scan: party lookup failed but autofill continues: $error\n$stackTrace',
          );
        }
      }

      stage = 'post-processing';
      _onPrincipalChanged(_principalController.text);
      if (!mounted) {
        return;
      }

      if (!draft.hasAnyAutofillField) {
        _showMessage(
          'Receipt scanned. No direct amount/account/reference was detected.',
        );
        return;
      }

      _showMessage('Receipt details applied. Please review before saving.');
    } catch (error, stackTrace) {
      debugPrint('Receipt scan failed at $stage: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      _showMessage(
        'Receipt scan failed during $stage. Please try again with a clearer image.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanningReceipt = false;
        });
      }
    }
  }

  _ReceiptDraft? _parseReceiptDraftSafely(
    String rawText, {
    String? sourceName,
  }) {
    try {
      return _parseReceiptDraft(rawText, sourceName: sourceName);
    } catch (error, stackTrace) {
      debugPrint('Receipt parse crashed, using fallback: $error\n$stackTrace');

      final fallbackText = [
        if (sourceName != null && sourceName.trim().isNotEmpty) sourceName,
        rawText,
      ].join('\n');

      try {
        return _buildFallbackDraftFromRaw(fallbackText);
      } catch (fallbackError, fallbackStackTrace) {
        debugPrint(
          'Receipt fallback parse failed: $fallbackError\n$fallbackStackTrace',
        );
        return null;
      }
    }
  }

  _ReceiptDraft _buildFallbackDraftFromRaw(String text) {
    final normalized = text.trim();
    debugPrint('=== Receipt Parse Debug ===');
    debugPrint(
      'Normalized OCR text (first 500 chars): ${normalized.substring(0, (normalized.length < 500 ? normalized.length : 500))}',
    );

    final walletSelection = _detectWalletSelection(normalized);
    final flowDirection = _detectFlowDirection(normalized);
    final amountData = _extractLikelyAmountFromText(normalized);
    final accountData = _extractLikelyAccountNumber(normalized);
    final accountNameData = _extractLikelyAccountName(normalized);
    final referenceData = _extractLikelyReference(normalized);

    debugPrint(
      'Extracted: Amount=${amountData.value} (${amountData.confidence}), Account=${accountData.value} (${accountData.confidence}), Name=${accountNameData.value} (${accountNameData.confidence}), Ref=${referenceData.value} (${referenceData.confidence})',
    );
    debugPrint('Wallet=$walletSelection, Flow=$flowDirection');

    return _ReceiptDraft(
      amount: amountData.value,
      amountConfidence: amountData.confidence,
      accountNumber: accountData.value,
      accountConfidence: accountData.confidence,
      accountName: accountNameData.value,
      accountNameConfidence: accountNameData.confidence,
      reference: referenceData.value,
      referenceConfidence: referenceData.confidence,
      walletSelection: walletSelection,
      flowDirection: flowDirection,
      rawOcrPreview: normalized,
    );
  }

  Future<String> _runOcrOnImagePath(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognized = await recognizer.processImage(inputImage);
      return recognized.text;
    } finally {
      await recognizer.close();
    }
  }

  Future<String> _runCroppedOcrPass(String originalPath) async {
    try {
      final originalBytes = await File(originalPath).readAsBytes();
      final decoded = img.decodeImage(originalBytes);
      if (decoded == null || decoded.width < 80 || decoded.height < 80) {
        return '';
      }

      final segmentTexts = <String>[];

      // Preprocess one region: crop → grayscale → optional invert → upscale → contrast.
      // invertIfDark: inverts regions with a predominantly dark/colored background
      // (e.g. GCash blue header) so ML Kit always sees dark text on white.
      Future<void> addSegment({
        required double x,
        required double y,
        required double w,
        required double h,
        double scale = 3.0,
        double contrast = 1.5,
        bool invertIfDark = false,
      }) async {
        final cropX = (decoded.width * x).round();
        final cropY = (decoded.height * y).round();
        final cropW = (decoded.width * w).round().clamp(
          1,
          decoded.width - cropX,
        );
        final cropH = (decoded.height * h).round().clamp(
          1,
          decoded.height - cropY,
        );

        final cropped = img.copyCrop(
          decoded,
          x: cropX,
          y: cropY,
          width: cropW,
          height: cropH,
        );

        var grayscale = img.grayscale(cropped);

        if (invertIfDark) {
          // Sample average luminance in the centre strip to decide whether
          // to invert (dark background → white text → invert for OCR).
          int totalLum = 0;
          final sampleY = (grayscale.height * 0.4).round();
          final sampleH = (grayscale.height * 0.2)
              .clamp(1.0, grayscale.height.toDouble())
              .round();
          for (var py = sampleY; py < sampleY + sampleH; py++) {
            for (var px = 0; px < grayscale.width; px++) {
              totalLum += grayscale.getPixel(px, py).r.toInt();
            }
          }
          final avgLum = totalLum / (grayscale.width * sampleH);
          if (avgLum < 128) {
            grayscale = img.invert(grayscale);
          }
        }

        // Upscale — ML Kit accuracy improves significantly at ≥3x
        final resized = img.copyResize(
          grayscale,
          width: (grayscale.width * scale).round(),
        );

        final enhanced = img.adjustColor(
          resized,
          contrast: contrast,
          brightness: 1.06,
          saturation: 0,
        );

        final text = await _runOcrOnTempImage(enhanced, 'seg');
        if (text.trim().isNotEmpty) {
          segmentTexts.add(text.trim());
        }
      }

      // Generic enhanced pass: full image grayscale + upscale + contrast.
      // Works for any receipt layout (GCash, Maya, BPI, BDO, store POS, etc.).
      // A single pass is much faster than 4 fixed GCash-specific segments.
      await addSegment(
        x: 0.0,
        y: 0.0,
        w: 1.0,
        h: 1.0,
        scale: 2.5,
        contrast: 1.5,
        invertIfDark: true,
      );

      // Focused centre strip — covers the core data rows of most receipts
      // (amount, reference, account) without the often-noisy header/footer.
      await addSegment(
        x: 0.0,
        y: 0.12,
        w: 1.0,
        h: 0.76,
        scale: 3.0,
        contrast: 1.6,
        invertIfDark: true,
      );

      return segmentTexts.join('\n');
    } catch (error, stackTrace) {
      debugPrint('Receipt crop OCR failed: $error\n$stackTrace');
      return '';
    }
  }

  Future<String> _runOcrOnTempImage(img.Image image, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    final cropPath = p.join(
      tempDir.path,
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    final cropFile = File(cropPath);
    await cropFile.writeAsBytes(img.encodeJpg(image, quality: 94));
    return _runOcrOnImagePath(cropPath);
  }

  Future<String?> _pickReceiptImagePath() async {
    final source = await _showReceiptImageSourcePicker();
    if (!mounted || source == null) {
      return null;
    }

    if (source == _ReceiptImageSource.file) {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'heic'],
        withData: true,
      );
      final file = picked?.files.single;
      if (file == null) {
        return null;
      }
      if (file.path != null && file.path!.isNotEmpty) {
        return file.path;
      }

      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final ext = p.extension(file.name).isNotEmpty
          ? p.extension(file.name)
          : '.jpg';
      final tempPath = p.join(
        tempDir.path,
        'receipt_${DateTime.now().millisecondsSinceEpoch}$ext',
      );
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes, flush: true);
      return tempFile.path;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source == _ReceiptImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 90,
    );
    return file?.path;
  }

  Future<_ReceiptImageSource?> _showReceiptImageSourcePicker() async {
    return showModalBottomSheet<_ReceiptImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Use Camera'),
              subtitle: const Text('Take a photo of the receipt'),
              onTap: () =>
                  Navigator.of(context).pop(_ReceiptImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pick from Gallery'),
              subtitle: const Text('Choose existing screenshot/photo'),
              onTap: () =>
                  Navigator.of(context).pop(_ReceiptImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Browse Files'),
              subtitle: const Text('Pick from any folder'),
              onTap: () => Navigator.of(context).pop(_ReceiptImageSource.file),
            ),
          ],
        ),
      ),
    );
  }

  _ReceiptDraft? _parseReceiptDraft(String rawText, {String? sourceName}) {
    final normalized = rawText.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final combinedText = sourceName == null || sourceName.trim().isEmpty
        ? normalized
        : '$sourceName\n$normalized';
    final safeText = combinedText
        .replaceAll('\u0000', ' ')
        .replaceAll(RegExp(r'\uFFFD'), ' ')
        .trim();

    ({double? value, _FieldConfidence confidence}) amountData = (
      value: null,
      confidence: _FieldConfidence.unknown,
    );
    ({String? value, _FieldConfidence confidence}) accountData = (
      value: null,
      confidence: _FieldConfidence.unknown,
    );
    ({String? value, _FieldConfidence confidence}) referenceData = (
      value: null,
      confidence: _FieldConfidence.unknown,
    );
    _WalletSelection? walletSelection;
    _FlowDirection? flowDirection;

    try {
      amountData = _extractLikelyAmountFromText(safeText);
    } catch (error, stackTrace) {
      debugPrint('Receipt parse amount failed: $error\n$stackTrace');
    }

    try {
      accountData = _extractLikelyAccountNumber(safeText);
    } catch (error, stackTrace) {
      debugPrint('Receipt parse account failed: $error\n$stackTrace');
    }

    try {
      referenceData = _extractLikelyReference(safeText);
    } catch (error, stackTrace) {
      debugPrint('Receipt parse reference failed: $error\n$stackTrace');
    }

    try {
      walletSelection = _detectWalletSelection(safeText);
    } catch (error, stackTrace) {
      debugPrint('Receipt parse wallet failed: $error\n$stackTrace');
    }

    try {
      flowDirection = _detectFlowDirection(safeText);
    } catch (error, stackTrace) {
      debugPrint('Receipt parse flow failed: $error\n$stackTrace');
    }

    ({String? value, _FieldConfidence confidence}) accountNameData = (
      value: null,
      confidence: _FieldConfidence.unknown,
    );

    try {
      accountNameData = _extractLikelyAccountName(safeText);
    } catch (error, stackTrace) {
      debugPrint('Receipt parse account name failed: $error\n$stackTrace');
    }

    return _ReceiptDraft(
      amount: amountData.value,
      amountConfidence: amountData.confidence,
      accountNumber: accountData.value,
      accountConfidence: accountData.confidence,
      accountName: accountNameData.value,
      accountNameConfidence: accountNameData.confidence,
      reference: referenceData.value,
      referenceConfidence: referenceData.confidence,
      walletSelection: walletSelection,
      flowDirection: flowDirection,
      rawOcrPreview: safeText,
    );
  }

  _FlowDirection? _detectFlowDirection(String text) {
    final lower = text.toLowerCase();
    // Outflow: user sent/withdrew money
    if (lower.contains('cash out') ||
        lower.contains('withdraw') ||
        lower.contains('withdrawal') ||
        lower.contains(
          'sent money',
        ) || // Maya: 'Sent money to' or OCR misread 'Sent money o'
        lower.contains('sent to') ||
        lower.contains('purchased from') ||
        lower.contains('purchase')) {
      return _FlowDirection.outflow;
    }
    // Inflow: user received money
    if (lower.contains('cash in') ||
        lower.contains('cashin') ||
        lower.contains('received') ||
        lower.contains('sent by')) {
      return _FlowDirection.inflow;
    }
    return null;
  }

  _WalletSelection? _detectWalletSelection(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('maya') || lower.contains('paymaya')) {
      return _WalletSelection.maya;
    }
    if (lower.contains('gcash') || lower.contains('g-cash')) {
      return _WalletSelection.gcash;
    }
    // Other wallets/banks — map to nearest supported selection if available
    if (lower.contains('shopeepay') ||
        lower.contains('shopee pay') ||
        lower.contains('seabank')) {
      return _WalletSelection.maya; // fallback to maya as closest e-wallet
    }
    return null;
  }

  ({double? value, _FieldConfidence confidence}) _extractLikelyAmountFromText(
    String text,
  ) {
    // Normalize whitespace but do NOT replace o->0 yet (it destroys keywords)
    final flat = text
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'  +'), ' ')
        .trim();

    debugPrint(
      '[Amount] Input text sample: ${flat.substring(0, (flat.length < 200 ? flat.length : 200))}',
    );
    final candidates = <({double value, int score})>[];

    // Amount pattern: matches with OR without thousands comma, 1–2 decimal places
    // e.g. 5.00 / 5,000.00 / 5.0
    const _decimalAmt = r'\d{1,3}(?:,\d{3})*\.\d{1,2}';

    // 0a. Special OCR misread: -PI00.00 where ₱ → P and digit 1 → I
    // When OCR reads ₱100.00 as PI00.00, the '1' is absorbed into 'I'
    // So we detect -PI followed by 2+ digits and prepend '1'
    final piMisreadPattern = RegExp(
      r'-PI(\d{2,}\.\d{1,2})',
      caseSensitive: false,
    );
    for (final m in piMisreadPattern.allMatches(flat)) {
      final corrected = '1${m.group(1)!}';
      final parsed = double.tryParse(corrected.replaceAll(',', ''));
      if (_isPlausibleScannedAmount(parsed)) {
        debugPrint('[Amount] PI-misread corrected: $corrected');
        candidates.add((value: parsed!, score: 13));
      }
    }

    // 0. Simple minus+currency pattern first (catches -PI100.00, -P100.00, -₱100.00)
    final simpleMinusPattern = RegExp(
      '-\\s*(?:pi|p|php|₱)?\\s*($_decimalAmt)',
      caseSensitive: false,
    );
    for (final m in simpleMinusPattern.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        candidates.add((value: parsed!, score: 13));
      }
    }

    // 1. Minus-prefixed currency (Maya format: -₱100.00)
    final minusCurrencyPattern = RegExp(
      '-\\s*(?:php|₱|PI|P)\\s*($_decimalAmt)',
      caseSensitive: false,
    );
    for (final m in minusCurrencyPattern.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        candidates.add((value: parsed!, score: 13));
      }
    }

    // 2. Currency prefix: PHP / ₱ / P, with or without commas
    // Highest priority — e.g. PHP 100.00, ₱5.00, P5.00, ₱5,000.00, ₱ 5.00
    final currencyPattern = RegExp(
      '(?:php|₱|PI|(?<![a-zA-Z])P)\\s*($_decimalAmt)',
      caseSensitive: false,
    );
    for (final m in currencyPattern.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        final score = m.group(1)!.contains(',') ? 14 : 12;
        candidates.add((value: parsed!, score: score));
      }
    }

    // 2. Keyword label + value on the NEXT line (ML Kit splits label/value rows)
    // e.g. line "Total Amount Sent" followed by line "₱5.00"
    final lineList = text.split(RegExp(r'[\r\n]+'));
    for (var i = 0; i < lineList.length - 1; i++) {
      final lineLower = lineList[i].toLowerCase().trim();
      final isAmountLabel =
          lineLower == 'amount' ||
          lineLower == 'total amount' ||
          lineLower == 'total amount sent' ||
          lineLower == 'total' ||
          lineLower == 'grand total' ||
          lineLower == 'net amount' ||
          lineLower == 'subtotal' ||
          lineLower == 'payment' ||
          lineLower == 'paid' ||
          lineLower == 'charge' ||
          lineLower == 'price' ||
          lineLower == 'fee' ||
          lineLower == 'transaction amount' ||
          lineLower.startsWith('amount:') ||
          lineLower.startsWith('total amount:') ||
          lineLower.startsWith('total:') ||
          lineLower.startsWith('grand total:') ||
          lineLower.startsWith('subtotal:') ||
          lineLower.startsWith('payment:') ||
          lineLower.startsWith('paid:') ||
          lineLower.startsWith('net amount:') ||
          lineLower.startsWith('transaction amount:');
      if (isAmountLabel) {
        // Check next 1–2 lines for the value
        for (var j = i + 1; j <= i + 2 && j < lineList.length; j++) {
          final nextLine = lineList[j].trim();
          // Extract isolated decimal tokens so phone/reference digits
          // cannot be concatenated into a fake large amount.
          final nextLineAmountTokens = RegExp(
            r'(?:php|₱|P)?\s*(\d{1,3}(?:,\d{3})*\.\d{1,2})',
            caseSensitive: false,
          );
          for (final token in nextLineAmountTokens.allMatches(nextLine)) {
            final parsed = _parseAmountToken(token.group(1));
            if (_isPlausibleScannedAmount(parsed)) {
              candidates.add((value: parsed!, score: 13));
              break;
            }
          }
        }
      }
    }

    // 3. Keyword + amount on SAME line, allow currency symbol between them
    // Handles: "Amount 5.00", "Total Amount Sent ₱5.00", "Amount: 5.00", "sent PHP 100.00"
    final keywordSameLine = RegExp(
      '(?:sent|total\\s+amount\\s+sent|transaction\\s+amount|grand\\s+total|net\\s+amount|total\\s+amount|subtotal|total|amount|payment|paid|charge|price|fee)\\s{0,4}[:\\-]?\\s{0,4}(?:php|₱|P)?\\s{0,2}(\\d{1,3}(?:,\\d{3})*\\.\\d{1,2})',
      caseSensitive: false,
    );
    for (final m in keywordSameLine.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        candidates.add((value: parsed!, score: 10));
      }
    }

    // 4. Comma-formatted amount anywhere (e.g. 5,000.00) — still reliable signal
    final commaFormatted = RegExp(r'\b(\d{1,3}(?:,\d{3})+\.\d{1,2})\b');
    for (final m in commaFormatted.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (_isPlausibleScannedAmount(parsed)) {
        candidates.add((value: parsed!, score: 8));
      }
    }

    if (candidates.isNotEmpty) {
      candidates.sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        // If same score, prefer the larger amount
        return b.value.compareTo(a.value);
      });
      final top = candidates.first;
      debugPrint('[Amount] Found with score ${top.score}: ${top.value}');
      final confidence = switch (top.score) {
        >= 12 => _FieldConfidence.high,
        >= 10 => _FieldConfidence.medium,
        _ => _FieldConfidence.low,
      };
      return (value: top.value, confidence: confidence);
    }

    // 5. Last resort: any decimal number that looks like an amount
    final generic = RegExp(r'\b(\d{1,3}(?:,\d{3})*\.\d{2})\b');
    double? best;
    for (final m in generic.allMatches(flat)) {
      final parsed = _parseAmountToken(m.group(1));
      if (!_isPlausibleScannedAmount(parsed)) {
        continue;
      }
      final parsedValue = parsed!;
      if (parsedValue >= 2000 &&
          parsedValue <= 2100 &&
          m.group(1)!.endsWith('.00')) {
        continue; // skip year-like values
      }
      if (best == null || parsedValue > best) {
        best = parsedValue;
      }
    }
    if (best != null) {
      debugPrint('[Amount] Found (generic fallback): $best');
      return (value: best, confidence: _FieldConfidence.low);
    }
    debugPrint('[Amount] Not found');
    return (value: null, confidence: _FieldConfidence.unknown);
  }

  double? _parseAmountToken(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final normalized = _normalizeOcrDigits(
      raw,
    ).replaceAll(' ', '').replaceAll('P', '').replaceAll('p', '');

    final cleaned = normalized
        .replaceAll(RegExp(r'[^0-9\.,]'), '')
        .replaceAll(',', '')
        .trim();
    if (cleaned.isEmpty) {
      return null;
    }
    return double.tryParse(cleaned);
  }

  bool _isPlausibleScannedAmount(double? value) {
    if (value == null || !value.isFinite) {
      return false;
    }
    // Guardrails to prevent phone/reference digits from being interpreted
    // as an amount. Adjust upper bound if your business needs larger values.
    return value >= 1 && value <= 500000;
  }

  String _normalizeOcrDigits(String value) {
    return value
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('Q', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('|', '1')
        .replaceAll('S', '5')
        .replaceAll('s', '5')
        .replaceAll('B', '8');
  }

  ({String? value, _FieldConfidence confidence}) _extractLikelyAccountNumber(
    String text,
  ) {
    // 0. Prioritize "Destination:" label — Maya "Sent money" receipts show
    //    Source (user's own wallet) then Destination (recipient). We want Destination.
    final destinationPattern = RegExp(
      r'destination[:\s]+(\+?6?3?9\d{2}[\s-]?\d{3}[\s-]?\d{4}|0?9\d{9})',
      caseSensitive: false,
    );
    final destMatch = destinationPattern.firstMatch(text);
    if (destMatch != null) {
      final raw = destMatch.group(1)!.replaceAll(RegExp(r'[^0-9]'), '');
      final normalized = _normalizeAccountDigits(raw);
      if (normalized != null) {
        return (value: normalized, confidence: _FieldConfidence.high);
      }
    }

    // Detect Source number — OCR reads two-column layouts with labels first, values later.
    // Source is the user's own wallet; we want to skip it and pick the Destination instead.
    // Match the spaced phone that appears near/after 'My Wallet' or 'Source' keyword.
    final sourceNumPattern = RegExp(
      r'(?:source|my wallet)[^\n]{0,40}(\+63[\s-]9\d{2}[\s-]\d{3}[\s-]\d{4}|\+639\d{9}|\b0?9\d{9}\b)',
      caseSensitive: false,
    );
    final sourceNumMatch = sourceNumPattern.firstMatch(text);
    final sourceNumber = sourceNumMatch != null
        ? sourceNumMatch.group(1)!.replaceAll(RegExp(r'[^0-9]'), '')
        : null;

    // For Maya "Sent money" receipts: the Destination phone is always compact (+639...)
    // while the Source is spaced (+63 9xx xxx xxxx). Try compact first so we don't
    // accidentally return the source number.
    final hasMayaSentLayout =
        text.toLowerCase().contains('destination') ||
        text.toLowerCase().contains('sent money');

    if (hasMayaSentLayout) {
      // 1a. Try compact format first (Destination is always compact in Maya Sent Money)
      final intlCompactFirst = RegExp(r'\+639\d{9}');
      for (final m in intlCompactFirst.allMatches(text)) {
        final digits = m.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
        if (sourceNumber != null && digits == sourceNumber) continue;
        final normalized = _normalizeAccountDigits(digits);
        if (normalized != null) {
          return (value: normalized, confidence: _FieldConfidence.high);
        }
      }
    }

    // 1. International format with spaces: +63 975 307 9315 or +63-975-307-9315
    //    Skip if it's the same as the "Source" (user's own wallet number)
    final intlSpaced = RegExp(r'\+63[\s-]?9\d{2}[\s-]\d{3}[\s-]\d{4}');
    for (final m in intlSpaced.allMatches(text)) {
      final digits = m.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      if (sourceNumber != null && digits == sourceNumber) continue;
      final normalized = _normalizeAccountDigits(digits);
      if (normalized != null) {
        return (value: normalized, confidence: _FieldConfidence.high);
      }
    }

    // 2. International format compact: +639753079315
    //    Skip if it's the same as the "Source" (user's own wallet number)
    final intlCompact = RegExp(r'\+639\d{9}');
    for (final m in intlCompact.allMatches(text)) {
      final digits = m.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      if (sourceNumber != null && digits == sourceNumber) continue;
      final normalized = _normalizeAccountDigits(digits);
      if (normalized != null) {
        return (value: normalized, confidence: _FieldConfidence.high);
      }
    }

    // 3. Local format with spaces: 0975 307 9315 or 09753079315
    final localPhone = RegExp(r'\b0?9\d{2}[\s-]?\d{3}[\s-]?\d{4}\b');
    final localMatch = localPhone.firstMatch(text);
    if (localMatch != null) {
      final digits = localMatch.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      final normalized = _normalizeAccountDigits(digits);
      if (normalized != null) {
        return (value: normalized, confidence: _FieldConfidence.medium);
      }
    }

    // 4. Contextual keyword search (use raw text to keep keywords intact)
    // Handles SMS format: "sent PHP 100.00 to +639101706761"
    final contextualPattern = RegExp(
      r'(?:mobile|account|number|recipient|to|from|sent\s+(?:php|₱)?\s*[\d.]+\s+to)[^0-9]{0,20}(\+?6?3?9\d{2}[\s-]?\d{3}[\s-]?\d{4}|0?9\d{9})',
      caseSensitive: false,
    );
    final contextMatch = contextualPattern.firstMatch(text);
    if (contextMatch != null) {
      final raw = contextMatch.group(1) ?? '';
      final normalized = _normalizeAccountDigits(
        raw.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (normalized != null) {
        return (value: normalized, confidence: _FieldConfidence.high);
      }
    }

    // 5. Maya QR merchant receipts: use Payment ID as account identifier
    //    e.g. "Payment ID  E115 8DF2 812E"
    final paymentIdPattern = RegExp(
      r'payment\s+id[:\s]+([A-Z0-9]{4}(?:\s+[A-Z0-9]{4}){2}|[A-Z0-9]{12,16})',
      caseSensitive: false,
    );
    final paymentIdMatch = paymentIdPattern.firstMatch(text);
    if (paymentIdMatch != null) {
      final value = paymentIdMatch
          .group(1)!
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ')
          .toUpperCase();
      if (!value.startsWith('MAYA ')) {
        return (value: value, confidence: _FieldConfidence.high);
      }
    }

    // 5a. OCR two-column fallback for Payment ID:
    // labels and values can be separated, so scan all ID-like tokens and pick
    // the best candidate nearest to "payment id", excluding reference values.
    final lower = text.toLowerCase();
    if (lower.contains('payment id')) {
      final referenceCanonical = _extractLikelyReference(
        text,
      ).value?.replaceAll(RegExp(r'\s+'), '').toUpperCase();

      final spacedIdPattern = RegExp(
        r'\b([A-Z0-9]{4}(?:\s+[A-Z0-9]{4}){2})\b',
        caseSensitive: false,
      );
      final compactIdPattern = RegExp(r'\b([A-Z0-9]{12,24})\b');

      final candidates = <({String value, int start})>[];

      for (final m in spacedIdPattern.allMatches(text)) {
        final token = (m.group(1) ?? '').trim();
        final canonical = token.replaceAll(RegExp(r'\s+'), '').toUpperCase();
        if (canonical.length < 12 || canonical.length > 24) continue;
        final hasLetter = RegExp(r'[A-Z]').hasMatch(canonical);
        final hasDigit = RegExp(r'\d').hasMatch(canonical);
        if (!hasLetter || !hasDigit) continue;
        if (canonical.startsWith('MAYA')) continue;
        if (referenceCanonical != null && canonical == referenceCanonical) {
          continue;
        }
        candidates.add((value: token.toUpperCase(), start: m.start));
      }

      for (final m in compactIdPattern.allMatches(text.toUpperCase())) {
        final token = (m.group(1) ?? '').trim();
        if (token.length < 12 || token.length > 24) continue;
        final hasLetter = RegExp(r'[A-Z]').hasMatch(token);
        final hasDigit = RegExp(r'\d').hasMatch(token);
        if (!hasLetter || !hasDigit) continue;
        if (token.startsWith('MAYA')) continue;
        if (referenceCanonical != null && token == referenceCanonical) continue;
        // Avoid filename-like artifacts
        if (token.startsWith('SCALED') || token.startsWith('IMG')) continue;
        candidates.add((value: token, start: m.start));
      }

      if (candidates.isNotEmpty) {
        final paymentPos = lower.indexOf('payment id');

        candidates.sort((a, b) {
          final aAfter = a.start >= paymentPos;
          final bAfter = b.start >= paymentPos;
          if (aAfter != bAfter) return aAfter ? -1 : 1;
          final da = (a.start - paymentPos).abs();
          final db = (b.start - paymentPos).abs();
          return da.compareTo(db);
        });

        final best = candidates.first.value.replaceAll(RegExp(r'\s+'), ' ');
        return (value: best, confidence: _FieldConfidence.medium);
      }
    }

    // 6. Merchant ID fallback for QR Ph / merchant receipts (no phone number)
    //    e.g. "Merchant ID  777148000000062"
    final merchantIdPattern = RegExp(
      r'merchant\s+id[:\s]+(\d{8,20})',
      caseSensitive: false,
    );
    final merchantIdMatch = merchantIdPattern.firstMatch(text);
    if (merchantIdMatch != null) {
      final value = merchantIdMatch.group(1)!.trim();
      return (value: value, confidence: _FieldConfidence.medium);
    }

    // 6a. Merchant ID in OCR two-column layouts may have label/value split.
    // Prefer any long digit sequence when Merchant ID label is present,
    // excluding obvious non-account contexts.
    if (text.toLowerCase().contains('merchant id')) {
      final longDigits = RegExp(r'\b\d{12,20}\b');
      for (final m in longDigits.allMatches(text)) {
        final start = m.start > 50 ? m.start - 50 : 0;
        final context = text.substring(start, m.start).toLowerCase();
        final isExcludedContext =
            context.contains('reference id') ||
            context.contains('payment id') ||
            context.contains('invoice');
        if (!isExcludedContext) {
          return (value: m.group(0)!, confidence: _FieldConfidence.medium);
        }
      }
    }

    // 5. Filename token fallback: extract from GCash filename like GCash-639753079315-...
    final filenamePhone = RegExp(
      r'(?:GCash|Maya|Pay)[^0-9]*(63)?9(\d{9})',
      caseSensitive: false,
    );
    final fnMatch = filenamePhone.firstMatch(text);
    if (fnMatch != null) {
      final prefix = fnMatch.group(1) ?? '';
      final rest = fnMatch.group(2) ?? '';
      final normalized = _normalizeAccountDigits(
        '${prefix}9$rest'.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (normalized != null) {
        return (value: normalized, confidence: _FieldConfidence.low);
      }
    }

    return (value: null, confidence: _FieldConfidence.unknown);
  }

  String? _normalizeAccountDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return null;
    }
    if (digits.startsWith('63') && digits.length == 12) {
      return '0${digits.substring(2)}';
    }
    if (digits.length == 10 && digits.startsWith('9')) {
      return '0$digits';
    }
    if (digits.length >= 10 && digits.length <= 13) {
      return digits;
    }
    return null;
  }

  ({String? value, _FieldConfidence confidence}) _extractLikelyReference(
    String text,
  ) {
    // Collect all digit groups after any ref keyword, allowing spaces within the number
    // Handles: "Ref No. 2039 688 926688", "Ref No. 2039688926688", "Ref. No. 2040543627864", "Reference: ABC123"

    // Maya format: "Reference ID 1D6D BA77 DA29" — on the same or next line
    // Fix: do NOT use \s in capture group (it eats newlines and grabs wrong content).
    // Try same-line first, then next-line variant.
    debugPrint('[Reference] Looking for Maya Reference ID pattern...');

    // 1a. Standalone Maya-style reference: 4-char groups separated by spaces e.g. "1D6D BA77 DA29"
    //     Look for this FIRST anywhere in the text — it's the most distinctive pattern.
    final mayaStandalonePattern = RegExp(
      r'\b([A-Z0-9]{4} [A-Z0-9]{4} [A-Z0-9]{4})\b',
      caseSensitive: false,
    );
    final mayaStandaloneMatch = mayaStandalonePattern.firstMatch(text);
    if (mayaStandaloneMatch != null) {
      final raw = mayaStandaloneMatch.group(1)!.trim();
      final value = raw.replaceAll(' ', '');
      debugPrint('[Reference] Maya standalone pattern: $value');
      return (value: value, confidence: _FieldConfidence.high);
    }

    // 1a2. Compact Maya reference: 12-char uppercase alphanumeric after "Reference ID"
    //      e.g. "Reference ID  1D6DBA77DA29" (no spaces in the ID)
    final mayaCompactPattern = RegExp(
      r'reference\s+id\s+([A-Z0-9]{9,15})(?:\s|$)',
      caseSensitive: false,
    );
    final mayaCompactMatch = mayaCompactPattern.firstMatch(text);
    if (mayaCompactMatch != null) {
      final value = mayaCompactMatch.group(1)!.trim();
      debugPrint('[Reference] Maya compact pattern: $value');
      return (value: value, confidence: _FieldConfidence.high);
    }

    // 1b. "Reference ID" followed by alphanumeric on same line
    final referenceIdSameLine = RegExp(
      r'reference\s+(?:id|no)[:\s]+([A-Z0-9][A-Z0-9 ]{3,24}?)(?=\s*(?:Sent|money|to|Share|$|\n))',
      caseSensitive: false,
    );
    final refSameLineMatch = referenceIdSameLine.firstMatch(text);
    if (refSameLineMatch != null) {
      final raw = refSameLineMatch.group(1)?.trim() ?? '';
      final value = raw.replaceAll(RegExp(r'\s+'), '');
      final isCommon = RegExp(
        r'^(Sent|money|to|Share|Completed)$',
        caseSensitive: false,
      ).hasMatch(value);
      if (value.length >= 6 &&
          value.length <= 30 &&
          RegExp(r'^[A-Z0-9]+$').hasMatch(value) &&
          !isCommon) {
        debugPrint('[Reference] Maya same-line pattern: $value');
        return (value: value, confidence: _FieldConfidence.high);
      }
    }

    // 1c. "Reference ID" on one line, actual ID on the NEXT line
    final referenceIdNextLine = RegExp(
      r'reference\s+(?:id|no)\s*\n\s*([A-Z0-9][A-Z0-9 ]{3,24})',
      caseSensitive: false,
    );
    final refNextLineMatch = referenceIdNextLine.firstMatch(text);
    if (refNextLineMatch != null) {
      final raw = refNextLineMatch.group(1)?.trim() ?? '';
      final value = raw.replaceAll(RegExp(r'\s+'), '');
      if (value.length >= 6 &&
          value.length <= 30 &&
          RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
        debugPrint('[Reference] Maya next-line pattern: $value');
        return (value: value, confidence: _FieldConfidence.high);
      }
    }

    // First try explicit "Ref. No." pattern (common in SMS receipts)
    final refNoPattern = RegExp(
      r'ref\.?\s+no\.[\s:.-]*([\d][\d\s\-]{7,})',
      caseSensitive: false,
    );
    final refNoMatch = refNoPattern.firstMatch(text);
    if (refNoMatch != null) {
      final raw = refNoMatch.group(1) ?? '';
      final digitGroups = RegExp(r'\d+');
      final allDigits = digitGroups
          .allMatches(raw.split(RegExp(r'[A-Za-z]')).first)
          .map((m) => m.group(0)!)
          .join();
      if (allDigits.length >= 8) {
        debugPrint('[Reference] Found via Ref. No. pattern: $allDigits');
        return (value: allDigits, confidence: _FieldConfidence.high);
      }
    }

    // Then try generic ref keyword pattern
    final refKeywordPattern = RegExp(
      r'(?:ref(?:erence)?(?:\s*no\.?|\s*num(?:ber)?|\s*#|\s*id)?|transaction\s*(?:no\.?|id|num(?:ber)?)?|trx\s*(?:no\.?|id)?|trace\s*(?:no\.?|num(?:ber)?)?|control\s*(?:no\.?|num(?:ber)?)?|receipt\s*(?:no\.?|num(?:ber)?)?|or\s*(?:no\.?|num(?:ber)?)?|o\.r\.?\s*(?:no\.?|num(?:ber)?)?|txn\s*(?:no\.?|id)?|approval\s*(?:no\.?|code)?|auth(?:orization)?\s*(?:no\.?|code)?|rrn|stan)[\s:.-]*([\d][\d\s\-]{7,})',
      caseSensitive: false,
    );
    final refMatch = refKeywordPattern.firstMatch(text);
    if (refMatch != null) {
      final raw = refMatch.group(1) ?? '';
      // Extract consecutive digit groups, stopping at any word character (letter)
      final digitGroups = RegExp(r'\d+');
      final allDigits = digitGroups
          .allMatches(raw.split(RegExp(r'[A-Za-z]')).first)
          .map((m) => m.group(0)!)
          .join();
      if (allDigits.length >= 8) {
        debugPrint('[Reference] Found via keyword pattern: $allDigits');
        return (value: allDigits, confidence: _FieldConfidence.high);
      }
    }

    // Alphanumeric reference codes after keyword (e.g. "Ref: ABC123456", "Approval Code: XYZ")
    // Alphanumeric reference codes after keyword (e.g. "Ref: ABC123456", "Approval Code: XYZ")
    // Use \b word boundary to prevent matching partial words like 'erence' from 'Reference'
    final alphaRefPattern = RegExp(
      r'\b(?:reference|ref)\b(?:\s*(?:no\.?|num(?:ber)?|#|id))?[\s:.-]*([A-Z0-9][A-Z0-9\-]{5,})',
      caseSensitive: false,
    );
    final alphaMatch = alphaRefPattern.firstMatch(text);
    if (alphaMatch != null) {
      final value = alphaMatch.group(1)?.trim();
      // Reject common words that are not reference IDs
      final isCommonWord = RegExp(
        r'^(sent|money|share|initial|capital|completed|from|to|help|erence)$',
        caseSensitive: false,
      ).hasMatch(value ?? '');
      if (value != null && value.isNotEmpty && !isCommonWord) {
        debugPrint('[Reference] Found via alpha pattern: $value');
        return (value: value, confidence: _FieldConfidence.medium);
      }
    }

    // Any long digit-only sequence (12+ digits) that looks like a transaction ID
    // But skip phone numbers: don't match if it's 10-13 digits or starts with 63/09
    final longDigits = RegExp(r'\b(\d{12,})\b');
    for (final longMatch in longDigits.allMatches(text)) {
      final value = longMatch.group(1)!;

      // Skip phone number patterns: 10–13 digits, or starts with 63/09, or contains typical phone spacing
      final isPhonePatternStart =
          value.startsWith('0') ||
          value.startsWith('63') ||
          value.startsWith('639');
      final isPhoneLength = value.length >= 10 && value.length <= 13;
      final looksLikePhone = isPhonePatternStart || isPhoneLength;

      // Skip if it looks like a timestamp/date
      final isYearLike =
          value.startsWith('2') &&
          ((value.length == 8 &&
                  int.tryParse(value.substring(4)) != null) || // YYYYMMDD
              (value.length == 10 && value.endsWith('00')) // timestamp seconds
              );

      if (looksLikePhone || isYearLike) {
        continue;
      }

      if (value.length <= 20) {
        return (value: value, confidence: _FieldConfidence.low);
      }
    }

    // Standalone mixed alphanumeric token (letters + digits, 9–15 chars)
    // This catches Maya reference IDs like "1D6DBA77DA29" that OCR places anywhere
    // in the text due to two-column layout scrambling (not adjacent to "Reference ID").
    // Rules: must contain both letters and digits, not be a phone number, not a known word.
    final standaloneAlphaNum = RegExp(
      r'\b([A-Z0-9]{9,15})\b',
      caseSensitive: false,
    );
    final commonWords = RegExp(
      r'^(completed|destination|transaction|reference|my wallet|sent|money|details|initial|capital|contacts|wallet|source|share|add)$',
      caseSensitive: false,
    );
    for (final m in standaloneAlphaNum.allMatches(text)) {
      final token = m.group(1)!;
      // Must have both letters and digits (not purely numeric = phone/amount, not purely alpha = word)
      final hasLetters = RegExp(r'[A-Za-z]').hasMatch(token);
      final hasDigits = RegExp(r'[0-9]').hasMatch(token);
      if (!hasLetters || !hasDigits) continue;
      // Skip if it looks like a phone number
      if (token.startsWith('639') || token.startsWith('09')) continue;
      // Skip common words/labels
      if (commonWords.hasMatch(token)) continue;
      debugPrint('[Reference] Found via standalone alphanumeric: $token');
      return (value: token.toUpperCase(), confidence: _FieldConfidence.medium);
    }

    debugPrint('[Reference] Not found');
    return (value: null, confidence: _FieldConfidence.unknown);
  }

  ({String? value, _FieldConfidence confidence}) _extractLikelyAccountName(
    String text,
  ) {
    // Maya QR Ph "Purchased from" receipts: merchant name is the short label
    // that appears right after the amount line (e.g. "JNT", "JOLLIBEE").
    // In OCR it appears as: "-₱220.00\nJNT\nFeb 27, 2026..."
    final purchasedFromTitle = RegExp(
      r'purchased\s+from',
      caseSensitive: false,
    );
    if (purchasedFromTitle.hasMatch(text)) {
      // OCR often reads amount + name on the SAME line: "-P220.00 JNT Paid using..."
      // Extract the short merchant name between the amount and "Paid using" / "You may".
      final sameLinePattern = RegExp(
        r'[-–]\s*[₱P]\s*[\d,]+\.?\d*\s+([A-Z0-9][A-Z0-9&\.]{0,29}(?:\s+[A-Z0-9&\.]{1,20}){0,3}?)\s+(?:Paid\s+using|You\s+may)',
        caseSensitive: false,
      );
      final sameLineMatch = sameLinePattern.firstMatch(text);
      if (sameLineMatch != null) {
        final name = sameLineMatch.group(1)?.trim();
        if (name != null &&
            name.isNotEmpty &&
            name.length >= 2 &&
            name.length <= 50) {
          return (value: name, confidence: _FieldConfidence.high);
        }
      }

      // Common Maya layout: "Purchased from" then merchant token nearby.
      final purchasedFromInline = RegExp(
        r'purchased\s+from[^A-Za-z0-9]{0,12}([A-Za-z][A-Za-z0-9&\.\-]{1,39})(?:\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|\d{4}|paid\s+using|merchant\s+id|you\s+may)|$)',
        caseSensitive: false,
      );
      final purchasedInlineMatch = purchasedFromInline.firstMatch(text);
      if (purchasedInlineMatch != null) {
        final name = purchasedInlineMatch.group(1)?.trim();
        if (name != null &&
            name.isNotEmpty &&
            name.length >= 2 &&
            name.length <= 50) {
          return (value: name, confidence: _FieldConfidence.high);
        }
      }

      // Fallback: grab the line immediately after the amount sign line
      final lines = text.split(RegExp(r'[\r\n]+'));
      for (var i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        final nextLine = lines[i + 1].trim();
        // Amount line: starts with - and contains ₱ or P followed by digits
        final isAmountLine = RegExp(r'^[-–]\s*[₱P]?\s*\d').hasMatch(line);
        if (isAmountLine && nextLine.isNotEmpty && nextLine.length <= 50) {
          // Next line after amount = merchant name (short label like "JNT")
          final isDate = RegExp(
            r'\d{4}|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\b',
            caseSensitive: false,
          ).hasMatch(nextLine);
          final isUiText = RegExp(
            r'completed|confirm|paid|fee|reference|payment|invoice|merchant|bank|qr',
            caseSensitive: false,
          ).hasMatch(nextLine);
          if (!isDate && !isUiText && RegExp(r'[A-Za-z]').hasMatch(nextLine)) {
            return (value: nextLine, confidence: _FieldConfidence.high);
          }
        }
      }
    }

    // GCash receipt header format: name on one line, phone on next
    // E.g. "M.. TE......A A.\n+63 981 167 2398" or "M.. TE......A A.\nSent via GCash"
    final lineList = text.split(RegExp(r'[\r\n]+'));
    for (var i = 0; i < lineList.length - 1; i++) {
      final line = lineList[i].trim();
      final nextLine = lineList[i + 1].trim();

      // Check if next line contains a phone number pattern
      final hasPhoneNext = RegExp(r'\+?63|09\d{2}').hasMatch(nextLine);

      // Skip lines that contain currency symbols or look like amounts
      final hasCurrency = RegExp(r'[₱P\-][\s]?\d').hasMatch(line);
      final looksLikeAmount = line.contains(RegExp(r'^\s*[-₱PI]'));

      // Skip known Maya/wallet UI labels that are not real names
      final isUiLabel = RegExp(
        r'^(my wallet|source|destination|transaction|reference|completed|add to contacts|get help|share|sent money)$',
        caseSensitive: false,
      ).hasMatch(line);

      if (!looksLikeAmount &&
          !hasCurrency &&
          !isUiLabel &&
          hasPhoneNext &&
          line.isNotEmpty &&
          line.length >= 2 &&
          line.length <= 100 &&
          RegExp(r'[A-Za-z]').hasMatch(line) &&
          (line.contains('.') ||
              line.contains('*') ||
              RegExp(r'\s').hasMatch(line))) {
        // Looks like a masked/formatted name (has dots, asterisks, or spaces)
        // and is followed by a phone number, but NOT an amount or UI label
        return (value: line, confidence: _FieldConfidence.high);
      }
    }

    // SMS format: "sent PHP 100.00 to JO*E A. +639101706761"
    // Pattern: after "to" (or "sent to"), grab text before the phone number
    final toPattern = RegExp(
      r'(?:sent\s+(?:php|₱)?[\d.\s]+)?to\s+([A-Za-z\s\.\*\-]+?)(?:\s+\+?63|\s+09)',
      caseSensitive: false,
    );
    final toMatch = toPattern.firstMatch(text);
    if (toMatch != null) {
      final name = toMatch.group(1)?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name.length >= 2 &&
          name.length <= 100) {
        // Ensure it's not just digits or special chars
        if (RegExp(r'[A-Za-z]').hasMatch(name)) {
          return (value: name, confidence: _FieldConfidence.high);
        }
      }
    }

    // Alternative: "received from", "cash from", "payment from", or just "from NAME"
    final fromPattern = RegExp(
      r'(?:received\s+from|cash\s+from|payment\s+from|transfer\s+from|money\s+from|-\s+from|from)\s+([A-Za-z\s\.\*\-]{2,}?)(?:\s*[\+0-9]|\.|$|\n)',
      caseSensitive: false,
    );
    final fromMatch = fromPattern.firstMatch(text);
    if (fromMatch != null) {
      final name = fromMatch.group(1)?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name.length >= 2 &&
          name.length <= 100) {
        if (RegExp(r'[A-Za-z]').hasMatch(name)) {
          return (value: name, confidence: _FieldConfidence.high);
        }
      }
    }

    // Contextual keyword with name: "recipient: NAME", "account holder: NAME"
    final recipientPattern = RegExp(
      r'(?:recipient|account\s+holder|account\s+name|full\s+name|from)[\s:.-]+([A-Za-z\s\.\*\-]{2,}?)(?:\s*[\+0-9]|$)',
      caseSensitive: false,
    );
    final recipientMatch = recipientPattern.firstMatch(text);
    if (recipientMatch != null) {
      final name = recipientMatch.group(1)?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name.length >= 2 &&
          name.length <= 100) {
        if (RegExp(r'[A-Za-z]').hasMatch(name)) {
          return (value: name, confidence: _FieldConfidence.medium);
        }
      }
    }

    // Pattern: name-like text that appears right before a phone number
    // Extract capitalized words before the account number
    final beforePhonePattern = RegExp(
      r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)\s*[\*\.]?\s*(?:A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z)[\.\s]*(?:\+?639|09)\d',
      caseSensitive: true,
    );
    final beforePhoneMatch = beforePhonePattern.firstMatch(text);
    if (beforePhoneMatch != null) {
      final name = beforePhoneMatch.group(1)?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name.length >= 2 &&
          name.length <= 100) {
        return (value: name, confidence: _FieldConfidence.medium);
      }
    }

    return (value: null, confidence: _FieldConfidence.unknown);
  }

  int? _pickBestTransactionTypeId(_ReceiptDraft draft) {
    if (_transactionTypes.isEmpty) {
      return null;
    }

    int? bestId;
    var bestScore = -1;
    for (final type in _transactionTypes) {
      var score = 0;
      if (draft.walletSelection != null) {
        final typeWallet = type.walletAccount.toLowerCase().contains('maya')
            ? _WalletSelection.maya
            : _WalletSelection.gcash;
        if (typeWallet == draft.walletSelection) {
          score += 3;
        }
      }
      if (draft.flowDirection != null) {
        final typeFlow = type.isOutflow
            ? _FlowDirection.outflow
            : _FlowDirection.inflow;
        if (typeFlow == draft.flowDirection) {
          score += 4;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestId = type.id;
      }
    }

    return bestScore >= 4 ? bestId : null;
  }

  TransactionTypeRecord? _findTransactionTypeById(int id) {
    for (final type in _transactionTypes) {
      if (type.id == id) {
        return type;
      }
    }
    return null;
  }

  String _confidenceLabel(_FieldConfidence confidence) {
    return switch (confidence) {
      _FieldConfidence.high => 'High',
      _FieldConfidence.medium => 'Medium',
      _FieldConfidence.low => 'Low',
      _FieldConfidence.unknown => 'Unknown',
    };
  }

  String _formatScannedAmountForInput(double amount) {
    if (!amount.isFinite || amount <= 0) {
      return '';
    }

    try {
      return amount.toStringAsFixed(2);
    } catch (_) {
      return amount.toString();
    }
  }

  String _formatScannedAmountForDisplay(double amount) {
    if (!amount.isFinite || amount <= 0) {
      return 'Not found';
    }

    try {
      return '₱ ${amount.toStringAsFixed(2)}';
    } catch (_) {
      return '₱ ${amount.toString()}';
    }
  }

  Future<bool> _confirmReceiptAutofill(_ReceiptDraft draft) async {
    final suggestedTypeId = _pickBestTransactionTypeId(draft);
    final suggestedType = suggestedTypeId != null
        ? _findTransactionTypeById(suggestedTypeId)
        : null;

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Apply Scanned Receipt Data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${draft.amount != null ? _formatScannedAmountForDisplay(draft.amount!) : 'Not found'}',
            ),
            const SizedBox(height: 2),
            Text(
              'Confidence: ${_confidenceLabel(draft.amountConfidence)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Account: ${draft.accountNumber != null ? draft.accountNumber : 'Not found'}',
            ),
            const SizedBox(height: 2),
            Text(
              'Confidence: ${_confidenceLabel(draft.accountConfidence)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Account Name: ${draft.accountName != null ? draft.accountName : 'Not found'}',
            ),
            const SizedBox(height: 2),
            Text(
              'Confidence: ${_confidenceLabel(draft.accountNameConfidence)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Reference: ${draft.reference != null ? draft.reference : 'Not found'}',
            ),
            const SizedBox(height: 2),
            Text(
              'Confidence: ${_confidenceLabel(draft.referenceConfidence)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text('Wallet: ${draft.walletLabel ?? 'Not found'}'),
            const SizedBox(height: 6),
            Text('Flow: ${draft.flowLabel ?? 'Not found'}'),
            const SizedBox(height: 6),
            Text(
              'Suggested Type: ${suggestedType?.name ?? 'No confident match'}',
            ),
            const SizedBox(height: 10),
            if (draft.rawOcrPreview != null &&
                draft.rawOcrPreview!.trim().isNotEmpty)
              Text(
                'OCR Preview: ${_summarizeOcrPreview(draft.rawOcrPreview!)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            if (draft.rawOcrPreview != null &&
                draft.rawOcrPreview!.trim().isNotEmpty)
              const SizedBox(height: 8),
            const Text(
              'Always review values before saving. Receipt formats vary by app and version.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  String _summarizeOcrPreview(String raw) {
    final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 180) {
      return normalized;
    }
    return '${normalized.substring(0, 180)}...';
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
              '$name — Verified account record found',
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
            _chargeHandlingMode == _ChargeHandlingMode.addOnTop
                ? 'Fee charged to customer'
                : 'Fee taken from amount sent',
          ),
          const SizedBox(height: 4),
          _buildPreviewRow('Using Wallet', _selectedWalletAccount),
          const SizedBox(height: 4),
          _buildPreviewRow('Service Fee', '₱ ${_chargeFee.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _buildPreviewRow('Fee Goes To', _chargeDestinationAccount),
          if (_matchedChargeBracket != null) ...[
            const SizedBox(height: 4),
            _buildPreviewRow(
              'Fee Bracket',
              '₱ ${_matchedChargeBracket!.lowerBound.toStringAsFixed(2)} – ₱ ${_matchedChargeBracket!.upperBound.toStringAsFixed(2)}',
            ),
          ],
          const SizedBox(height: 4),
          _buildHighlightedPreviewRow(
            _isOutflowSelection
                ? 'E-money Received from Customer'
                : 'E-money You Send to Customer',
            '₱ ${(_isOutflowSelection ? _totalCollected : _amountToSend).toStringAsFixed(2)}',
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
                '₱ ${_totalCollected.toStringAsFixed(2)}',

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
                '₱ ${_netCashToDrawer.toStringAsFixed(2)}',
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
            _chargeHandlingMode == _ChargeHandlingMode.addOnTop
                ? 'Service fee is added on top. Example: ₱100 transaction + ₱5 fee = collect ₱105 from customer, send ₱100.'
                : 'Fee is deducted before sending. Example: ₱100 entered, ₱5 fee deducted = only ₱95 is sent to the customer\'s wallet.',
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
              label: const Text('Customer Pays the Fee'),
              selected: _chargeHandlingMode == _ChargeHandlingMode.addOnTop,
              onSelected: (_) {
                setState(() {
                  _chargeHandlingMode = _ChargeHandlingMode.addOnTop;
                });
              },
            ),
            ChoiceChip(
              label: const Text('Deduct Fee from Sent Amount'),
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
                  label: const Text('Go to Charges'),
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
        builder: (_) => const ChargesScreen(launchedFromTransaction: true),
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

    if (_selectedTransactionType == null) {
      _showMessage(
        'Transaction type is required before saving.',
        isError: true,
      );
      return;
    }

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
        _chargeHandlingMode == _ChargeHandlingMode.deductFromEnteredAmount
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
        _showMessage(
          'Party registered. Saving transaction now...',
          messenger: messenger,
        );
      } else {
        _showMessage(
          'Unable to verify registration. Please try again.',
          isError: true,
          messenger: messenger,
        );
        return;
      }
    }

    if (!mounted) return;

    final saved = await _saveTransactionRecord();
    if (!saved) {
      if (!mounted) return;
      _showMessage(
        'Unable to save transaction. Please try again.',
        isError: true,
        messenger: messenger,
      );
      return;
    }

    if (!mounted) return;

    _showMessage(
      'Transaction saved for ${_matchedParty!.name}.',
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

    final selectedType = _selectedTransactionType?.name.trim();
    final isOutflow = _isOutflowSelection;
    final walletAccount = _selectedWalletAccount;
    final usesMayaWallet = walletAccount == 'Maya Wallet';
    final amount = _enteredAmount;
    final isDeductFromAmount =
        _chargeHandlingMode == _ChargeHandlingMode.deductFromEnteredAmount;

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
    final title = (selectedType != null && selectedType.isNotEmpty)
        ? selectedType
        : _defaultTransactionTitle;
    final noteBase = notes.isEmpty
        ? 'Account $accountNumber • ${_matchedParty!.name}'
        : notes;
    final persistedNote =
        '$noteBase • $_selectedFlowLabel • Wallet ${selectedWalletDelta >= 0 ? 'increased' : 'decreased'} by ₱${selectedWalletDelta.abs().toStringAsFixed(2)} • On-hand ${onHandDelta >= 0 ? 'increased' : 'decreased'} by ₱${onHandDelta.abs().toStringAsFixed(2)} • Fee ₱${chargeFee.toStringAsFixed(2)} • Fee goes to $_chargeDestinationAccount';

    final db = await _database.database;
    try {
      await _database.ensureWalletSchema(db);
      final deviceId = await _database.getOrCreateDeviceId();
      final nowMs = now.millisecondsSinceEpoch;
      await db.insert(AppDatabase.ledgerTable, {
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
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('Failed to save transaction record: $error\n$stackTrace');
      return false;
    }
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

class _ReceiptDraft {
  const _ReceiptDraft({
    this.amount,
    this.amountConfidence = _FieldConfidence.unknown,
    this.accountNumber,
    this.accountConfidence = _FieldConfidence.unknown,
    this.accountName,
    this.accountNameConfidence = _FieldConfidence.unknown,
    this.reference,
    this.referenceConfidence = _FieldConfidence.unknown,
    this.walletSelection,
    this.flowDirection,
    this.rawOcrPreview,
  });

  final double? amount;
  final _FieldConfidence amountConfidence;
  final String? accountNumber;
  final _FieldConfidence accountConfidence;
  final String? accountName;
  final _FieldConfidence accountNameConfidence;
  final String? reference;
  final _FieldConfidence referenceConfidence;
  final _WalletSelection? walletSelection;
  final _FlowDirection? flowDirection;
  final String? rawOcrPreview;

  String? get walletLabel {
    return switch (walletSelection) {
      _WalletSelection.gcash => 'GCash',
      _WalletSelection.maya => 'Maya Wallet',
      null => null,
    };
  }

  String? get flowLabel {
    return switch (flowDirection) {
      _FlowDirection.inflow => 'Cash In',
      _FlowDirection.outflow => 'Cash Out',
      null => null,
    };
  }

  bool get hasAnySignal {
    return amount != null ||
        accountNumber != null ||
        accountName != null ||
        reference != null ||
        walletSelection != null ||
        flowDirection != null;
  }

  bool get hasAnyAutofillField {
    return amount != null || accountNumber != null || reference != null;
  }
}

class _UpsertTransactionTypeDialog extends StatefulWidget {
  const _UpsertTransactionTypeDialog({
    required this.existingTypes,
    this.initialName,
    this.initialIsOutflow,
    this.initialWalletSelection,
  });

  final List<TransactionTypeRecord> existingTypes;
  final String? initialName;
  final bool? initialIsOutflow;
  final _WalletSelection? initialWalletSelection;

  @override
  State<_UpsertTransactionTypeDialog> createState() =>
      _UpsertTransactionTypeDialogState();
}

class _UpsertTransactionTypeDialogState
    extends State<_UpsertTransactionTypeDialog> {
  String? _selectedPreset;
  late bool _isOutflow;
  late _WalletSelection _walletSelection;
  String? _errorText;

  static const Map<_WalletSelection, Map<bool, List<String>>> _presets = {
    _WalletSelection.gcash: {
      false: [
        'GCash Cash-In',
        'Cash In from Bank',
        'Cash In via Partner',
        'Payment Received',
        'Bills Payment',
        'Load Purchase / E-Load',
        'Bank Transfer',
      ],
      true: ['GCash Cash-Out'],
    },
    _WalletSelection.maya: {
      false: ['Maya Cash-In', 'Bank Transfer', 'Pay Bills', 'Load / Prepaid'],
      true: ['Maya Cash-Out'],
    },
  };

  List<String> get _currentPresets => _presets[_walletSelection]![_isOutflow]!;

  bool get _isEditing => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _isOutflow = widget.initialIsOutflow ?? false;
    _walletSelection = widget.initialWalletSelection ?? _WalletSelection.gcash;
    _selectedPreset = widget.initialName;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSave() {
    if (_selectedPreset == null || _selectedPreset!.trim().isEmpty) {
      setState(() {
        _errorText = 'Please select a transaction type.';
      });
      return;
    }

    final raw = _selectedPreset!.trim();
    final normalizedName = raw.toLowerCase();
    final initialNameLower = (widget.initialName ?? '').trim().toLowerCase();
    final initialIsOutflow = widget.initialIsOutflow ?? false;
    final initialWallet =
        widget.initialWalletSelection ?? _WalletSelection.gcash;

    final hasExactDuplicate = widget.existingTypes.any((type) {
      final typeNameLower = type.name.trim().toLowerCase();
      final typeWallet = type.walletAccount.toLowerCase().contains('maya')
          ? _WalletSelection.maya
          : _WalletSelection.gcash;

      final isSameAsEditedOriginal =
          _isEditing &&
          typeNameLower == initialNameLower &&
          type.isOutflow == initialIsOutflow &&
          typeWallet == initialWallet;
      if (isSameAsEditedOriginal) {
        return false;
      }

      return typeNameLower == normalizedName &&
          type.isOutflow == _isOutflow &&
          typeWallet == _walletSelection;
    });

    if (hasExactDuplicate) {
      setState(() {
        _errorText =
            'This type name already exists for the same direction and wallet.';
      });
      return;
    }

    Navigator.of(context).pop(
      _TransactionTypeDraft(
        name: raw,
        isOutflow: _isOutflow,
        walletSelection: _walletSelection,
      ),
    );
  }

  void _setOutflow(bool value) {
    setState(() {
      _isOutflow = value;
      _selectedPreset = null;
      _errorText = null;
    });
  }

  void _setWalletSelection(_WalletSelection value) {
    setState(() {
      _walletSelection = value;
      _selectedPreset = null;
      _errorText = null;
    });
  }

  Widget _buildFlowOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.12)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: 0.45)
                    : AppColors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: selected ? color : AppColors.onSurfaceVariant,
                    ),
                    const Spacer(),
                    if (selected)
                      Icon(Icons.check_circle_rounded, size: 18, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? color : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.category_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isEditing ? 'Edit Transaction Type' : 'Add Transaction Type',
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
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final presets = _currentPresets;
              final items = <String>[...presets];
              // When editing, keep the original name in the list even if it
              // doesn't match the current preset catalogue (legacy value).
              if (_selectedPreset != null && !items.contains(_selectedPreset)) {
                items.insert(0, _selectedPreset!);
              }
              return DropdownButtonFormField<String>(
                value: _selectedPreset,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Select a transaction type',
                  errorText: _errorText,
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: items
                    .map(
                      (name) => DropdownMenuItem(
                        value: name,
                        child: Text(name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPreset = value;
                    _errorText = null;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Transaction Direction',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFlowOption(
                label: 'Customer Sends',
                subtitle:
                    'Customer gives you cash, you send e-money to their wallet.',
                icon: Icons.call_made_rounded,
                color: AppColors.secondary,
                selected: !_isOutflow,
                onTap: () => _setOutflow(false),
              ),
              const SizedBox(width: 10),
              _buildFlowOption(
                label: 'Customer Receives',
                subtitle:
                    'Customer receives cash from you, you get e-money from their wallet.',
                icon: Icons.call_received_rounded,
                color: AppColors.error,
                selected: _isOutflow,
                onTap: () => _setOutflow(true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Use Which Wallet',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFlowOption(
                label: 'GCash',
                subtitle: 'This transaction goes through GCash.',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                selected: _walletSelection == _WalletSelection.gcash,
                onTap: () => _setWalletSelection(_WalletSelection.gcash),
              ),
              const SizedBox(width: 10),
              _buildFlowOption(
                label: 'Maya',
                subtitle: 'This transaction goes through Maya.',
                icon: Icons.wallet_rounded,
                color: AppColors.secondary,
                selected: _walletSelection == _WalletSelection.maya,
                onTap: () => _setWalletSelection(_WalletSelection.maya),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choosing this type will automatically set direction to ${_isOutflow ? 'Customer Receives' : 'Customer Sends'} via ${_walletSelection == _WalletSelection.maya ? 'Maya Wallet' : 'GCash'}.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _onSave,
                child: Text(_isEditing ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ManageTransactionTypesDialog extends StatelessWidget {
  const _ManageTransactionTypesDialog({
    required this.types,
    required this.selectedTypeId,
  });

  final List<TransactionTypeRecord> types;
  final int? selectedTypeId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Manage Transaction Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 420,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: types.length,
          separatorBuilder: (_, __) => const Divider(height: 12),
          itemBuilder: (context, index) {
            final type = types[index];
            final isSelected = type.id == selectedTypeId;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${type.isOutflow ? 'Outflow' : 'Inflow'} • ${type.walletAccount.toLowerCase().contains('maya') ? 'Maya Wallet' : 'GCash'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: type.isOutflow
                              ? AppColors.error
                              : AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () {
                    Navigator.of(context).pop(
                      _TypeActionPayload(action: _TypeAction.edit, type: type),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () {
                    Navigator.of(context).pop(
                      _TypeActionPayload(
                        action: _TypeAction.delete,
                        type: type,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }
}

class _TransactionTypeDraft {
  const _TransactionTypeDraft({
    required this.name,
    required this.isOutflow,
    required this.walletSelection,
  });

  final String name;
  final bool isOutflow;
  final _WalletSelection walletSelection;
}

enum _TypeAction { edit, delete }

class _TypeActionPayload {
  const _TypeActionPayload({required this.action, required this.type});

  final _TypeAction action;
  final TransactionTypeRecord type;
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
                    ? const _PartyPickerEmptyState(
                        title: 'No contacts found',
                        subtitle:
                            'Register a party first, then use search to pick an account.',
                      )
                    : (filtered.isEmpty
                          ? const _PartyPickerEmptyState(
                              title: 'No matching contact',
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

// ---------------------------------------------------------------------------
// Extracted StatefulWidget for party registration dialog.
// Using a proper StatefulWidget ensures that `mounted` and `setState` are
// reliably tied to this widget's own element — avoiding the RenderObject
// 'attached' assertion that occurs when StatefulBuilder's setState is called
// after an async gap during dialog overlay transitions.
// ---------------------------------------------------------------------------

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

    // Pop and return the registered account number to the caller.
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
            label: 'Full Name / Entity',
            hint: 'Enter party full name',
          ),
          const SizedBox(height: 12),
          _dialogField(
            controller: _accountController,
            label: 'Account Number',
            hint: 'Enter account number',
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
                child: const Text('Cancel'),
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
                label: Text(_isSaving ? 'Saving…' : 'Register Party'),
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
