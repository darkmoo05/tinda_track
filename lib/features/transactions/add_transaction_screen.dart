import 'package:flutter/material.dart';
import '../../core/data/app_database.dart';
import '../../core/app_theme.dart';
import '../charges/data/charge_repository.dart';
import '../charges/charges_screen.dart';
import '../parties/data/party_repository.dart';

enum _ChargeHandlingMode { addOnTop, deductFromEnteredAmount }

enum _WalletSelection { gcash, maya }

enum _FlowDirection { inflow, outflow }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _accountController = TextEditingController();
  final _principalController = TextEditingController();
  final _notesController = TextEditingController();
  final PartyRepository _partyRepository = PartyRepository.instance;
  final ChargeRepository _chargeRepository = ChargeRepository.instance;
  final AppDatabase _database = AppDatabase.instance;
  bool _missingRangeAlertVisible = false;
  bool _missingRangeAlertShownForCurrentInput = false;
  bool _isLoadingTransactionTypes = true;
  bool _showRequiredIndicators = false;
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
    return _totalCollected;
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
    return _isOutflowSelection ? 'Outflow from Wallet' : 'Inflow to Wallet';
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
      _resolvePartyFromAccount(_accountController.text);
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
                  onChanged: _resolvePartyFromAccount,
                  isRequired: true,
                  hasError: _isAccountNumberMissing,
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
                  label: 'Principal Amount',
                  hint: '0.00',
                  prefixText: '₱  ',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: _onPrincipalChanged,
                  isRequired: true,
                  hasError: _isPrincipalMissing,
                ),
                const SizedBox(height: 12),
                _buildChargeHandlingSelector(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Optional notes...',
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
          initialValue: value,
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
                          t.isOutflow ? 'OUTFLOW' : 'INFLOW',
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
              'Type profile: ${selectedType.walletAccount} • ${selectedType.isOutflow ? 'Outflow' : 'Inflow'}',
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

  Widget _buildWalletSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Wallet Account', isRequired: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                label: 'GCash',
                subtitle: 'Route balance through GCash',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                selected: _selectedWallet == _WalletSelection.gcash,
                onTap: () {
                  setState(() {
                    _selectedWallet = _WalletSelection.gcash;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSelectionCard(
                label: 'Maya',
                subtitle: 'Route balance through Maya',
                icon: Icons.wallet_rounded,
                color: AppColors.secondary,
                selected: _selectedWallet == _WalletSelection.maya,
                onTap: () {
                  setState(() {
                    _selectedWallet = _WalletSelection.maya;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowSelector() {
    final accentColor = _isOutflowSelection
        ? AppColors.error
        : AppColors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Flow Direction', isRequired: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                label: 'Inflow',
                subtitle: 'Money goes into the wallet',
                icon: Icons.call_made_rounded,
                color: AppColors.secondary,
                selected: _selectedFlowDirection == _FlowDirection.inflow,
                onTap: () {
                  setState(() {
                    _selectedFlowDirection = _FlowDirection.inflow;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSelectionCard(
                label: 'Outflow',
                subtitle: 'Money goes out from the wallet',
                icon: Icons.call_received_rounded,
                color: AppColors.error,
                selected: _selectedFlowDirection == _FlowDirection.outflow,
                onTap: () {
                  setState(() {
                    _selectedFlowDirection = _FlowDirection.outflow;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(
                _isOutflowSelection
                    ? Icons.trending_down_rounded
                    : Icons.trending_up_rounded,
                size: 16,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selected flow: $_selectedFlowLabel',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
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
      'Transaction type added: ${createdType.name.trim()} (${createdType.isOutflow ? 'Outflow' : 'Inflow'} • ${createdType.walletSelection == _WalletSelection.maya ? 'Maya Wallet' : 'GCash'})',
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
                  'Parties not registered. Tap here to register details before saving.',
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
            'Charge Handling',
            _chargeHandlingMode == _ChargeHandlingMode.addOnTop
                ? 'Charge Added On Top'
                : 'Charge Deducted From Amount',
          ),
          const SizedBox(height: 4),
          _buildPreviewRow('Wallet', _selectedWalletAccount),
          const SizedBox(height: 4),
          _buildPreviewRow('Flow', _selectedFlowLabel),
          const SizedBox(height: 4),
          _buildPreviewRow('Charge Fee', '₱ ${_chargeFee.toStringAsFixed(2)}'),
          if (_matchedChargeBracket != null) ...[
            const SizedBox(height: 4),
            _buildPreviewRow(
              'Charge Range',
              '${_matchedChargeBracket!.lowerBound} - ${_matchedChargeBracket!.upperBound}',
            ),
          ],
          const SizedBox(height: 4),
          _buildHighlightedPreviewRow(
            _isOutflowSelection
                ? 'Amount Received from ${_selectedWalletAccount == 'Maya Wallet' ? 'Maya' : 'GCash'}'
                : 'Amount Sent to ${_selectedWalletAccount == 'Maya Wallet' ? 'Maya' : 'GCash'}',
            '₱ ${_amountToSend.toStringAsFixed(2)}',
            _selectedWalletColor,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.outlineVariant, thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Collected',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
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
                  const Text(
                    'Net Cash to Drawer',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
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
                ? 'Charge is added on top of the entered amount. Example: entered ₱100 + charge ₱5 = collect ₱105, send ₱100.'
                : 'Charge is deducted from the entered amount. Example: entered ₱100 with charge ₱5 = send ₱95.',
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
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
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
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

  Widget _buildChargeHandlingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Charge Handling'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Add Charge On Top'),
              selected: _chargeHandlingMode == _ChargeHandlingMode.addOnTop,
              onSelected: (_) {
                setState(() {
                  _chargeHandlingMode = _ChargeHandlingMode.addOnTop;
                });
              },
            ),
            ChoiceChip(
              label: const Text('Deduct Charge From Amount'),
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
        onPressed: _onSaveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
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
                'Missing Charge Range',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The entered principal amount does not match any configured charge range. Please create a new charges range first.',
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
    if (!_showRequiredIndicators) {
      setState(() => _showRequiredIndicators = true);
    }

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
        'Principal amount is required before saving.',
        isError: true,
      );
      return;
    }

    if (_matchedChargeBracket == null) {
      _showMessage(
        'No charge range found for this principal amount. Create a new range first.',
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
    final available = isOutflow ? onHandBalance : selectedWalletBalance;
    if (principal > available) {
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
      _showSnackBar(
        messenger,
        'Party is not registered yet. Register details first.',
        isError: true,
      );
      final registered = await _openPartyRegistrationPopup(
        prefilledAccountNumber: accountNumber,
      );
      if (!registered) {
        return;
      }

      if (!mounted) return;

      await _resolvePartyFromAccount(_accountController.text);

      if (!mounted) return;

      if (_isRegisteredAccount) {
        _showSnackBar(messenger, 'Party registered. Saving transaction now...');
      } else {
        _showSnackBar(
          messenger,
          'Unable to verify registration. Please try again.',
          isError: true,
        );
        return;
      }
    }

    if (!mounted) return;

    final saved = await _saveTransactionRecord();
    if (!saved) {
      if (!mounted) return;
      _showSnackBar(
        messenger,
        'Unable to save transaction. Please try again.',
        isError: true,
      );
      return;
    }

    if (!mounted) return;

    _showSnackBar(messenger, 'Transaction saved for ${_matchedParty!.name}.');
    Navigator.of(context).pop(true);
  }

  Future<bool> _saveTransactionRecord() async {
    final principal = _amountToSend;
    final chargeFee = _chargeFee;
    final totalCollected = _totalCollected;
    final accountNumber = _accountController.text.trim();
    final notes = _notesController.text.trim();

    if (principal <= 0 || _matchedParty == null) {
      return false;
    }

    final selectedType = _selectedTransactionType?.name.trim();
    final isOutflow = _isOutflowSelection;
    final walletAccount = _selectedWalletAccount;
    final usesMayaWallet = walletAccount == 'Maya Wallet';
    final walletDelta = usesMayaWallet
        ? 0.0
        : (isOutflow ? principal : -principal);
    final mayaWalletDelta = usesMayaWallet
        ? (isOutflow ? principal : -principal)
        : 0.0;
    final onHandDelta = isOutflow ? -principal : totalCollected;
    final now = DateTime.now();
    final reference = accountNumber;
    final iconKey = isOutflow ? 'cash_out' : 'cash_in';
    final title = (selectedType != null && selectedType.isNotEmpty)
        ? selectedType
        : _defaultTransactionTitle;
    final noteBase = notes.isEmpty
        ? 'Account $accountNumber • ${_matchedParty!.name}'
        : notes;
    final persistedNote =
        '$noteBase • $_selectedFlowLabel • Charge ₱${chargeFee.toStringAsFixed(2)}';

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

  void _showSnackBar(
    ScaffoldMessengerState? messenger,
    String message, {
    bool isError = false,
  }) {
    messenger
      ?..hideCurrentSnackBar()
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

  Future<bool> _openPartyRegistrationPopup({
    required String prefilledAccountNumber,
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
        repository: _partyRepository,
      ),
    );

    if (registeredAccount != null && mounted) {
      _accountController.text = registeredAccount;
      return true;
    }
    return false;
  }

  Widget _buildPopupField({
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

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
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
  late final TextEditingController _controller;
  late bool _isOutflow;
  late _WalletSelection _walletSelection;
  String? _errorText;

  bool get _isEditing => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _isOutflow = widget.initialIsOutflow ?? false;
    _walletSelection = widget.initialWalletSelection ?? _WalletSelection.gcash;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _errorText = 'Type name is required.';
      });
      return;
    }

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
            'Transaction type already exists for this flow and wallet.';
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
    });
  }

  void _setWalletSelection(_WalletSelection value) {
    setState(() {
      _walletSelection = value;
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
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Cash In, Cash Out',
              errorText: _errorText,
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Flow Behavior',
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
                label: 'Inflow',
                subtitle: 'Selecting this type sets the transaction to inflow.',
                icon: Icons.call_made_rounded,
                color: AppColors.secondary,
                selected: !_isOutflow,
                onTap: () => _setOutflow(false),
              ),
              const SizedBox(width: 10),
              _buildFlowOption(
                label: 'Outflow',
                subtitle:
                    'Selecting this type sets the transaction to outflow.',
                icon: Icons.call_received_rounded,
                color: AppColors.error,
                selected: _isOutflow,
                onTap: () => _setOutflow(true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Wallet Target',
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
                subtitle: 'Assign this type to GCash wallet.',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                selected: _walletSelection == _WalletSelection.gcash,
                onTap: () => _setWalletSelection(_WalletSelection.gcash),
              ),
              const SizedBox(width: 10),
              _buildFlowOption(
                label: 'Maya',
                subtitle: 'Assign this type to Maya wallet.',
                icon: Icons.wallet_rounded,
                color: AppColors.secondary,
                selected: _walletSelection == _WalletSelection.maya,
                onTap: () => _setWalletSelection(_WalletSelection.maya),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_isOutflow ? 'Outflow' : 'Inflow'} • ${_walletSelection == _WalletSelection.maya ? 'Maya Wallet' : 'GCash'} will auto-apply when this type is selected.',
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
    required this.repository,
  });

  final String prefilledAccountNumber;
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
    _fullNameController = TextEditingController();
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
