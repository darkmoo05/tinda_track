import 'package:flutter/material.dart';
import '../../core/data/app_database.dart';
import '../../core/app_theme.dart';
import '../charges/data/charge_repository.dart';
import '../charges/charges_screen.dart';
import '../parties/data/party_repository.dart';

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

  String _selectedType = 'Bank Deposit';
  PartyRecord? _matchedParty;

  List<TransactionTypeRecord> _transactionTypes = const [];

  TransactionTypeRecord? get _selectedTransactionType {
    for (final type in _transactionTypes) {
      if (type.name == _selectedType) {
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

  double get _taxAdjustment => 0.0;

  double get _totalCollected {
    final principal = double.tryParse(_principalController.text) ?? 0;
    return principal + _chargeFee;
  }

  double get _netCashToDrawer {
    return _totalCollected;
  }

  bool get _hasTypedAccount => _accountController.text.trim().isNotEmpty;

  bool get _isRegisteredAccount => _matchedParty != null;

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
                      _transactionTypes.any(
                        (type) => type.name == _selectedType,
                      )
                      ? _selectedType
                      : null,
                  items: _transactionTypes,
                  onChanged: _isLoadingTransactionTypes
                      ? null
                      : (val) {
                          if (val == null) {
                            return;
                          }
                          setState(() => _selectedType = val);
                        },
                  onAddPressed: _showAddTransactionTypeDialog,
                  onManagePressed: _showManageTransactionTypesDialog,
                ),
                if (_selectedTransactionType != null) ...[
                  const SizedBox(height: 8),
                  _buildFlowTypeHint(_selectedTransactionType!.isOutflow),
                ],
                if (_isLoadingTransactionTypes) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _accountController,
                  label: 'Account Number',
                  hint: 'Search or enter account number',
                  suffixIcon: Icons.search_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: _resolvePartyFromAccount,
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
                ),
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
    required String? value,
    required List<TransactionTypeRecord> items,
    ValueChanged<String?>? onChanged,
    VoidCallback? onAddPressed,
    VoidCallback? onManagePressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _fieldLabel(label),
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
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          onChanged: onChanged,
          decoration: _inputDecoration(),
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
                  value: t.name,
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

  Widget _buildFlowTypeHint(bool isOutflow) {
    return Row(
      children: [
        Icon(
          isOutflow ? Icons.trending_down_rounded : Icons.trending_up_rounded,
          size: 14,
          color: isOutflow ? AppColors.error : AppColors.secondary,
        ),
        const SizedBox(width: 6),
        Text(
          isOutflow
              ? 'This type is marked as Outflow.'
              : 'This type is marked as Inflow.',
          style: TextStyle(
            fontSize: 11,
            color: isOutflow ? AppColors.error : AppColors.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> _loadTransactionTypes({String? preferSelect}) async {
    setState(() {
      _isLoadingTransactionTypes = true;
    });

    final loadedTypes = await _database.loadTransactionTypeRecords();
    if (!mounted) {
      return;
    }

    final fallbackType = loadedTypes.isNotEmpty
        ? loadedTypes.first.name
        : 'Bank Deposit';
    final preferred = preferSelect?.trim();
    final nextSelected =
        (preferred != null && loadedTypes.any((type) => type.name == preferred))
        ? preferred
        : (loadedTypes.any((type) => type.name == _selectedType)
              ? _selectedType
              : fallbackType);

    setState(() {
      _transactionTypes = loadedTypes;
      _selectedType = nextSelected;
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

    await _database.insertTransactionType(
      createdType.name,
      isOutflow: createdType.isOutflow,
    );
    if (!mounted) {
      return;
    }

    await _loadTransactionTypes(preferSelect: createdType.name.trim());
    if (!mounted) {
      return;
    }
    _showMessage('Transaction type added: ${createdType.name.trim()}');
  }

  Future<void> _showManageTransactionTypesDialog() async {
    if (_transactionTypes.isEmpty) {
      _showMessage('No transaction types available. Add one first.');
      return;
    }

    final selectedAction = await showDialog<_TypeActionPayload>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (_) => _ManageTransactionTypesDialog(
        types: _transactionTypes,
        selectedTypeName: _selectedType,
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
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Unable to update type. Name may already exist.');
      return;
    }

    if (!mounted) {
      return;
    }
    await _loadTransactionTypes(preferSelect: result.name);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Transaction Type'),
          content: Text('Are you sure you want to delete "${type.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
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
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: _inputDecoration().copyWith(
            hintText: hint,
            prefixText: prefixText,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.onSurfaceVariant, size: 20)
                : null,
          ),
        ),
      ],
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
          _buildPreviewRow('Charge Fee', '₱ ${_chargeFee.toStringAsFixed(2)}'),
          if (_matchedChargeBracket != null) ...[
            const SizedBox(height: 4),
            _buildPreviewRow(
              'Charge Range',
              '${_matchedChargeBracket!.lowerBound} - ${_matchedChargeBracket!.upperBound}',
            ),
          ],
          const SizedBox(height: 8),
          _buildPreviewRow(
            'Tax Adjustment',
            '₱ ${_taxAdjustment.toStringAsFixed(2)}',
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
            'Charge fee is based on configured bracket ranges for the principal amount.',
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Missing Charge Range',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'The entered principal amount does not match any configured charge range. Please create a new charges range first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.payments_outlined, size: 18),
            label: const Text('Go to Charges'),
          ),
        ],
      ),
    );
    _missingRangeAlertVisible = false;

    if (!mounted || goToCharges != true) {
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChargesScreen()));

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
    final accountNumber = _accountController.text.trim();
    final principal = double.tryParse(_principalController.text.trim()) ?? 0;

    if (accountNumber.isEmpty) {
      _showMessage('Account number is required before saving.');
      return;
    }

    if (principal <= 0) {
      _showMessage('Principal amount is required before saving.');
      return;
    }

    if (_matchedChargeBracket == null) {
      _showMessage(
        'No charge range found for this principal amount. Create a new range first.',
      );
      _showMissingChargeRangeAlert();
      return;
    }

    // Capture messenger before any async gap to avoid 'attached' assertion.
    final messenger = ScaffoldMessenger.maybeOf(context);

    await _resolvePartyFromAccount(accountNumber);

    if (!_isRegisteredAccount) {
      _showSnackBar(
        messenger,
        'Party is not registered yet. Register details first.',
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
        _showSnackBar(
          messenger,
          'Party registered! Review the details and tap Save to continue.',
        );
      } else {
        _showSnackBar(
          messenger,
          'Unable to verify registration. Please try again.',
        );
      }
      return; // Stay on transaction screen so user can review before saving.
    }

    if (!mounted) return;

    final saved = await _saveTransactionRecord();
    if (!saved) {
      if (!mounted) return;
      _showSnackBar(messenger, 'Unable to save transaction. Please try again.');
      return;
    }

    if (!mounted) return;

    _showSnackBar(messenger, 'Transaction saved for ${_matchedParty!.name}.');
    Navigator.of(context).pop(true);
  }

  Future<bool> _saveTransactionRecord() async {
    final principal = double.tryParse(_principalController.text.trim()) ?? 0;
    final chargeFee = _chargeFee;
    final totalCollected = _totalCollected;
    final accountNumber = _accountController.text.trim();
    final notes = _notesController.text.trim();

    if (principal <= 0 || _matchedParty == null) {
      return false;
    }

    final isOutflow = _selectedTransactionType?.isOutflow ?? false;
    final walletDelta = isOutflow ? principal : -principal;
    final onHandDelta = isOutflow ? -principal : totalCollected;
    final now = DateTime.now();
    final reference = accountNumber;
    final iconKey = isOutflow ? 'cash_out' : 'cash_in';
    final noteBase = notes.isEmpty
        ? 'Account $accountNumber • ${_matchedParty!.name}'
        : notes;
    final persistedNote = '$noteBase • Charge ₱${chargeFee.toStringAsFixed(2)}';

    final db = await _database.database;
    try {
      await db.insert(AppDatabase.ledgerTable, {
        'entry_type': 'transaction',
        'title': _selectedType,
        'note': persistedNote,
        'reference': reference,
        'amount': totalCollected,
        'wallet_delta': walletDelta,
        'on_hand_delta': onHandDelta,
        'recorded_flow': totalCollected,
        'tag': 'Transaction',
        'icon_key': iconKey,
        'created_at': now.toIso8601String(),
      });
      return true;
    } on Exception {
      return false;
    }
  }

  void _showSnackBar(ScaffoldMessengerState? messenger, String message) {
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Text _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
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
  });

  final List<TransactionTypeRecord> existingTypes;
  final String? initialName;
  final bool? initialIsOutflow;

  @override
  State<_UpsertTransactionTypeDialog> createState() =>
      _UpsertTransactionTypeDialogState();
}

class _UpsertTransactionTypeDialogState
    extends State<_UpsertTransactionTypeDialog> {
  late final TextEditingController _controller;
  late bool _isOutflow;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _isOutflow = widget.initialIsOutflow ?? false;
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

    final initialLower = (widget.initialName ?? '').trim().toLowerCase();
    final exists = widget.existingTypes.any((type) {
      final lower = type.name.toLowerCase();
      if (lower == initialLower) {
        return false;
      }
      return lower == raw.toLowerCase();
    });
    if (exists) {
      setState(() {
        _errorText = 'Transaction type already exists.';
      });
      return;
    }

    Navigator.of(
      context,
    ).pop(_TransactionTypeDraft(name: raw, isOutflow: _isOutflow));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEditing ? 'Edit Transaction Type' : 'Add Transaction Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Remittance Pickup',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isOutflow ? 'Mark as Outflow' : 'Mark as Inflow',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _isOutflow ? AppColors.error : AppColors.secondary,
                    ),
                  ),
                ),
                Switch(
                  value: _isOutflow,
                  onChanged: (value) {
                    setState(() {
                      _isOutflow = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}

class _ManageTransactionTypesDialog extends StatelessWidget {
  const _ManageTransactionTypesDialog({
    required this.types,
    required this.selectedTypeName,
  });

  final List<TransactionTypeRecord> types;
  final String selectedTypeName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Manage Transaction Types'),
      content: SizedBox(
        width: 420,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: types.length,
          separatorBuilder: (_, __) => const Divider(height: 12),
          itemBuilder: (context, index) {
            final type = types[index];
            final isSelected = type.name == selectedTypeName;
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
                        type.isOutflow ? 'Outflow type' : 'Inflow type',
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _TransactionTypeDraft {
  const _TransactionTypeDraft({required this.name, required this.isOutflow});

  final String name;
  final bool isOutflow;
}

enum _TypeAction { edit, delete }

class _TypeActionPayload {
  const _TypeActionPayload({required this.action, required this.type});

  final _TypeAction action;
  final TransactionTypeRecord type;
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: const Text(
        'Party Registration',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _onRegister,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_add_alt_1_rounded, size: 18),
          label: Text(_isSaving ? 'Saving…' : 'Register Party'),
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
