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

  String _selectedType = 'Bank Deposit';
  PartyRecord? _matchedParty;

  final List<String> _transactionTypes = [
    'Bank Deposit',
    'Bank Withdrawal',
    'GCash Cash In',
    'GCash Cash Out',
    'Bills Payment',
    'Money Transfer',
  ];

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
                  value: _selectedType,
                  items: _transactionTypes,
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
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
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          decoration: _inputDecoration(),
          icon: const Icon(
            Icons.expand_more_rounded,
            color: AppColors.onSurfaceVariant,
          ),
          items: items
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
        ),
      ],
    );
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

    final isOutflow =
        _selectedType.contains('Out') || _selectedType.contains('Withdrawal');
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
