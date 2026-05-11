import 'package:flutter/material.dart';

import '../../core/data/app_database.dart';
import '../../core/app_theme.dart';
import '../../shared/receipt_scan/receipt_draft.dart';
import '../../shared/receipt_scan/receipt_scan_button.dart';
import '../../shared/receipt_scan/receipt_scan_service.dart';
import '../../core/l10n_extension.dart';

class AddOwnerMovementScreen extends StatefulWidget {
  const AddOwnerMovementScreen({
    super.key,
    this.initialMovementType,
    this.initialDestination,
  });

  final String? initialMovementType;
  final String? initialDestination;

  @override
  State<AddOwnerMovementScreen> createState() => _AddOwnerMovementScreenState();
}

class _AddOwnerMovementScreenState extends State<AddOwnerMovementScreen> {
  final AppDatabase _database = AppDatabase.instance;
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  static const List<String> _movementTypes = [
    'Top-up',
    'Cash Transfer (On-hand to Wallet)',
    'Borrowed Funds',
    'Fee Withdrawal',
    'Borrowed Funds Repayment',
  ];
  static const List<String> _walletDestinations = ['GCash', 'Maya Wallet'];
  static const List<String> _destinations = [
    'GCash',
    'Maya Wallet',
    'On-hand Cash',
  ];

  String? _movementType;
  late String _destination;
  List<String> _expenseCategories = const [];
  String? _selectedCategory;
  double? _availableFeeIncome;
  double? _availableFeeIncomeOnHand;
  bool _includeFeeIncomeInTransfer = false;
  bool _isSaving = false;
  bool _isLoadingCategories = true;
  bool _isLoadingFeeIncome = false;
  bool _showRequiredIndicators = false;

  bool get _isPersonalExpense => _movementType == 'Borrowed Funds';

  bool get _isPersonalExpensePayment =>
      _movementType == 'Borrowed Funds Repayment';

  bool get _isCashTransferToWallet =>
      _movementType == 'Cash Transfer (On-hand to Wallet)';

  bool get _isFeeWithdrawal => _movementType == 'Fee Withdrawal';

  bool get _isRepayment => _isPersonalExpensePayment;

  bool get _isMovementTypeMissing =>
      _showRequiredIndicators && _movementType == null;

  bool get _isAmountMissing =>
      _showRequiredIndicators &&
      (double.tryParse(_amountController.text.trim()) ?? 0) <= 0;

  bool get _isCategoryMissing =>
      _showRequiredIndicators &&
      _isPersonalExpense &&
      (_selectedCategory == null || _selectedCategory!.trim().isEmpty);

  bool get _isInflow {
    if (_isCashTransferToWallet) {
      return true;
    }
    if (_isFeeWithdrawal) {
      return false;
    }
    return _movementType != null && !_isPersonalExpense;
  }

  List<String> get _accountOptions {
    if (_isCashTransferToWallet) {
      return _walletDestinations;
    }
    return _destinations;
  }

  String get _ownerScope => (_isPersonalExpense || _isPersonalExpensePayment)
      ? 'Personal'
      : 'Business';

  String get _destinationLabel =>
      _destination == 'On-hand Cash' ? 'On-Hand Cash' : _destination;

  bool get _usesGcash => _destination == 'GCash';

  bool get _usesMayaWallet => _destination == 'Maya Wallet';

  double get _cashTransferFeeMoveAmount => _includeFeeIncomeInTransfer
      ? (_availableFeeIncomeOnHand ?? 0.0).clamp(0.0, double.infinity)
      : 0.0;

  String _accountLabel(BuildContext context) {
    if (_isCashTransferToWallet) {
      return 'Transfer to Wallet';
    }
    if (_isFeeWithdrawal) {
      return 'Withdraw From';
    }
    if (_isRepayment) {
      return context.l10n.repayTo;
    }
    return _isInflow ? context.l10n.destination : context.l10n.sourceAccount;
  }

  String _autoDirectionLabel(BuildContext context) {
    if (_isCashTransferToWallet) {
      return 'Internal transfer (no total money change)';
    }
    if (_isFeeWithdrawal) {
      return 'Fee income withdrawal (permanent withdrawal)';
    }
    return _isInflow ? context.l10n.cashIn : context.l10n.cashOut;
  }

  String _movementSummaryLabel(BuildContext context) {
    if (_movementType == null) {
      return context.l10n.movementTypePending;
    }
    if (_isPersonalExpense) {
      final categoryLabel = _selectedCategory ?? context.l10n.categoryPending;
      return '$_movementType • $categoryLabel';
    }
    if (_isCashTransferToWallet) {
      return '$_movementType • On-Hand Cash -> $_destinationLabel';
    }
    if (_isFeeWithdrawal) {
      return '$_movementType • From $_destinationLabel';
    }
    return '$_movementType • $_destinationLabel';
  }

  String get _movementDescription {
    if (_isCashTransferToWallet) {
      return 'You moved money from On-Hand Cash to $_destinationLabel. Wallet balance increases, on-hand cash decreases, total business money stays the same.';
    }
    if (_isFeeWithdrawal) {
      return 'You withdrew accumulated service fees from $_destinationLabel as personal income. This is permanent withdrawal; money does not return to business.';
    }
    if (_isPersonalExpense) {
      return 'You took money from $_destinationLabel as borrowed funds. This reduces your business wallet balance.';
    }
    if (_isPersonalExpensePayment) {
      return 'You repaid borrowed funds to $_destinationLabel. This adds back to your business wallet balance.';
    }
    return 'You added funds to $_destinationLabel to keep the business running.';
  }

  @override
  void initState() {
    super.initState();
    _movementType = _resolveInitialMovementType();
    _destination = _resolveInitialDestination();
    _loadExpenseCategories();
    _refreshAvailableFeeIncome();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _resolveInitialMovementType() {
    final candidate = widget.initialMovementType?.trim();
    if (candidate != null && _movementTypes.contains(candidate)) {
      return candidate;
    }
    return null;
  }

  String _resolveInitialDestination() {
    final candidate = widget.initialDestination?.trim();
    if (candidate == null) {
      return _destinations.first;
    }

    for (final destination in _destinations) {
      if (destination.toLowerCase() == candidate.toLowerCase()) {
        return destination;
      }
    }

    return _destinations.first;
  }

  Future<void> _loadExpenseCategories({String? preferredCategory}) async {
    setState(() => _isLoadingCategories = true);
    final categories = await _database.loadOwnerMovementCategories();
    if (!mounted) {
      return;
    }

    setState(() {
      _expenseCategories = categories;
      if (categories.isEmpty) {
        _selectedCategory = null;
      } else if (preferredCategory != null &&
          categories.contains(preferredCategory)) {
        _selectedCategory = preferredCategory;
      } else if (_selectedCategory == null ||
          !categories.contains(_selectedCategory)) {
        _selectedCategory = categories.first;
      }
      _isLoadingCategories = false;
    });
  }

  void _onMovementTypeChanged(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _movementType = value;
      if ((_isCashTransferToWallet || _isFeeWithdrawal) &&
          !_walletDestinations.contains(_destination)) {
        _destination = _isFeeWithdrawal
            ? _destinations.first
            : _walletDestinations.first;
      }
      if (!_isPersonalExpense) {
        _selectedCategory = null;
      } else if (_expenseCategories.isNotEmpty) {
        _selectedCategory = _selectedCategory ?? _expenseCategories.first;
      }
    });

    _refreshAvailableFeeIncome();
  }

  Future<void> _refreshAvailableFeeIncome() async {
    if (!_isFeeWithdrawal && !_isCashTransferToWallet) {
      if (_availableFeeIncome != null ||
          _availableFeeIncomeOnHand != null ||
          _isLoadingFeeIncome) {
        setState(() {
          _availableFeeIncome = null;
          _availableFeeIncomeOnHand = null;
          _includeFeeIncomeInTransfer = false;
          _isLoadingFeeIncome = false;
        });
      }
      return;
    }

    setState(() => _isLoadingFeeIncome = true);

    final destinationAtRequest = _destination;

    if (_isFeeWithdrawal) {
      final availableFee = await _loadAvailableFeeIncomeForSelectedSource();
      if (!mounted) return;
      if (!_isFeeWithdrawal || destinationAtRequest != _destination) return;
      setState(() {
        _availableFeeIncome = availableFee;
        _isLoadingFeeIncome = false;
      });
      return;
    }

    if (_isCashTransferToWallet) {
      final availableOnHand = await _loadAvailableFeeIncomeForSource(
        'On-hand Cash',
      );
      if (!mounted) return;
      if (!_isCashTransferToWallet) return;
      setState(() {
        _availableFeeIncomeOnHand = availableOnHand;
        if ((_availableFeeIncomeOnHand ?? 0) <= 0) {
          _includeFeeIncomeInTransfer = false;
        }
        _isLoadingFeeIncome = false;
      });
      return;
    }
  }

  void _applyMaxFeeWithdrawalAmount() {
    final maxAmount = (_availableFeeIncome ?? 0).clamp(0.0, double.infinity);
    _amountController.text = maxAmount.toStringAsFixed(2);
  }

  void _applyReceiptDraft(ReceiptDraft draft) {
    final service = ReceiptScanService.instance;
    setState(() {
      if (draft.amount != null && draft.amount! > 0) {
        final formatted = service.formatAmountForInput(draft.amount!);
        if (formatted.isNotEmpty) _amountController.text = formatted;
      }
      if (draft.reference != null && draft.reference!.trim().isNotEmpty) {
        _referenceController.text = draft.reference!.trim();
      }
    });
    final noteText = service.buildReceiptNote(draft);
    if (noteText.isNotEmpty && _notesController.text.trim().isEmpty) {
      _notesController.text = noteText;
    }
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

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
          context.l10n.newOwnerMovement,
          style: const TextStyle(
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
            context.l10n.recordOwnerMovement,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.phase3Description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  label: context.l10n.movementType,
                  value: _movementType,
                  items: _movementTypes,
                  onChanged: _onMovementTypeChanged,
                  hintText: context.l10n.chooseMovementType,
                  isRequired: true,
                  hasError: _isMovementTypeMissing,
                ),
                const SizedBox(height: 20),
                _buildFlowMetaCard(),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: _accountLabel(context),
                  value: _destination,
                  items: _accountOptions,
                  onChanged: (val) {
                    if (val == null) {
                      return;
                    }
                    setState(() => _destination = val);
                    if (_isFeeWithdrawal || _isCashTransferToWallet) {
                      _refreshAvailableFeeIncome();
                    }
                  },
                ),
                if (_isFeeWithdrawal) ...[
                  const SizedBox(height: 8),
                  if (_isLoadingFeeIncome)
                    const LinearProgressIndicator(minHeight: 2)
                  else
                    Text(
                      'Available fee income in $_destinationLabel: ₱ ${(_availableFeeIncome ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 16),
                ] else if (_isCashTransferToWallet) ...[
                  const SizedBox(height: 8),
                  if (_isLoadingFeeIncome)
                    const LinearProgressIndicator(minHeight: 2)
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Available fee income in On-Hand Cash: ₱ ${(_availableFeeIncomeOnHand ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Switch(
                          value: _includeFeeIncomeInTransfer,
                          onChanged: (_availableFeeIncomeOnHand ?? 0) <= 0
                              ? null
                              : (v) => setState(
                                  () => _includeFeeIncomeInTransfer = v,
                                ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                ] else
                  const SizedBox(height: 16),

                if (_isPersonalExpense) ...[
                  _buildCategorySection(),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  controller: _amountController,
                  label: 'Amount',
                  hint: '0.00',
                  prefixText: '₱  ',
                  isRequired: true,
                  hasError: _isAmountMissing,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                if (_isCashTransferToWallet) ...[
                  const SizedBox(height: 6),
                  Builder(
                    builder: (context) {
                      final availableFeeOnHand = _availableFeeIncomeOnHand ?? 0;
                      final requiredOnHand =
                          amount + _cashTransferFeeMoveAmount;
                      // Hint when fee switch is ON: remind about cap
                      final showFeeCapHint =
                          _includeFeeIncomeInTransfer &&
                          availableFeeOnHand > 0 &&
                          amount > 0;
                      // Hint when fee switch is OFF: warn that amount may eat into fee income
                      final showFeeConsumeHint =
                          !_includeFeeIncomeInTransfer &&
                          availableFeeOnHand > 0 &&
                          amount > 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requested On-Hand: ₱ ${requiredOnHand.toStringAsFixed(2)} = Transfer ₱ ${amount.toStringAsFixed(2)} + Fee Move ₱ ${_cashTransferFeeMoveAmount.toStringAsFixed(2)}. Fee move is capped by remaining On-Hand after transfer.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (showFeeCapHint)
                            const Text(
                              'To move fee income, leave enough On-hand Cash after transfer or turn off the fee transfer option.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                          if (showFeeConsumeHint)
                            Text(
                              'On-Hand Cash contains ₱ ${availableFeeOnHand.toStringAsFixed(2)} of undrawn fee income. '
                              'If your transfer exceeds the non-fee portion, it will be blocked. '
                              'Enable the fee toggle to move fee income along with the transfer.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
                if (_isFeeWithdrawal) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _isLoadingFeeIncome
                          ? null
                          : _applyMaxFeeWithdrawalAmount,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: Text(
                        'Use Max (₱ ${(_availableFeeIncome ?? 0).toStringAsFixed(2)})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _referenceController,
                  label: context.l10n.referenceOptional,
                  hint: _referenceHint,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ReceiptScanButton(onDraftReady: _applyReceiptDraft),
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
          _buildSummaryCard(amount),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFlowMetaCard() {
    final tone = _isCashTransferToWallet
        ? AppColors.primary
        : (_isFeeWithdrawal
              ? AppColors.error
              : (_isInflow ? AppColors.secondary : AppColors.error));
    final icon = _isCashTransferToWallet
        ? Icons.swap_horiz_rounded
        : (_isFeeWithdrawal
              ? Icons.money_rounded
              : (_isInflow
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.moneyDirection,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tone,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _autoDirectionLabel(context),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _movementDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fieldLabel(
              context.l10n.expenseCategory,
              isRequired: true,
              showErrorIndicator: _isCategoryMissing,
            ),
            const Spacer(),
            _buildCategoryAction(
              label: context.l10n.add,
              icon: Icons.add_rounded,
              onTap: _showAddCategoryDialog,
            ),
            const SizedBox(width: 8),
            _buildCategoryAction(
              label: context.l10n.manage,
              icon: Icons.settings_rounded,
              onTap: _showManageCategoriesDialog,
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (_isLoadingCategories)
          const LinearProgressIndicator(minHeight: 2)
        else if (_expenseCategories.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.l10n.addCategoryFirst,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text(
              context.l10n.chooseExpenseCategory,
              style: const TextStyle(
                color: AppColors.outlineVariant,
                fontSize: 13,
              ),
            ),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedCategory = value);
            },
            decoration: _inputDecoration(hasError: _isCategoryMissing),
            icon: const Icon(
              Icons.expand_more_rounded,
              color: AppColors.onSurfaceVariant,
            ),
            items: _expenseCategories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildCategoryAction({
    required String label,
    required IconData icon,
    required Future<void> Function() onTap,
  }) {
    return TextButton.icon(
      onPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          onTap();
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSummaryCard(double amount) {
    final color = _isCashTransferToWallet
        ? AppColors.primary
        : (_isFeeWithdrawal
              ? AppColors.error
              : (_isInflow ? AppColors.secondary : AppColors.error));
    final sign = _isCashTransferToWallet
        ? '±'
        : (_isFeeWithdrawal ? '⤓' : (_isInflow ? '+' : '-'));
    final icon = _isCashTransferToWallet
        ? Icons.swap_horiz_rounded
        : (_isFeeWithdrawal
              ? Icons.money_rounded
              : (_isInflow
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _movementSummaryLabel(context),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _movementDescription,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (_referenceController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _referenceController.text.trim(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$sign ₱ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
            color: Colors.black.withOpacity(0.04),
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
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hintText,
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
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: _inputDecoration(
            hasError: hasError,
          ).copyWith(hintText: hintText),
          hint: hintText != null && value == null
              ? Text(
                  hintText,
                  style: const TextStyle(
                    color: AppColors.outlineVariant,
                    fontSize: 13,
                  ),
                )
              : null,
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
    String? prefixText,
    TextInputType? keyboardType,
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
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hasError: hasError,
          ).copyWith(hintText: hint, prefixText: prefixText),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final color = _isInflow ? AppColors.secondary : AppColors.error;
    final endColor = _isInflow
        ? const Color(0xFF388E3C)
        : const Color(0xFFD32F2F);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, endColor],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleSave,
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
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'SAVE RECORD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    var feeTransferAmountForSave = 0.0;
    var requestedFeeTransferAmount = 0.0;

    if (!_showRequiredIndicators) {
      setState(() => _showRequiredIndicators = true);
    }

    if (_movementType == null) {
      _showSnackBar(
        messenger,
        'Please choose what happened before saving.',
        isError: true,
      );
      return;
    }

    if (amount <= 0) {
      _showSnackBar(
        messenger,
        'Enter an amount greater than zero.',
        isError: true,
      );
      return;
    }

    if (_isPersonalExpense &&
        (_selectedCategory == null || _selectedCategory!.trim().isEmpty)) {
      _showSnackBar(
        messenger,
        'Select or create a borrowed funds category.',
        isError: true,
      );
      return;
    }

    if (_isPersonalExpense) {
      final availableBalance = await _loadSelectedAccountBalance();
      if (!mounted) {
        return;
      }

      if (amount > availableBalance) {
        _showSnackBar(
          messenger,
          'Borrowed funds cannot be processed due to low $_destinationLabel balance. Available: ₱ ${availableBalance.toStringAsFixed(2)}.',
          isError: true,
        );
        return;
      }
    }

    if (_isCashTransferToWallet) {
      final onHandBalance = await _loadOnHandCashBalance();
      if (!mounted) {
        return;
      }
      if (amount > onHandBalance) {
        _showSnackBar(
          messenger,
          'Transfer cannot be processed due to low On-Hand Cash balance. Available: ₱ ${onHandBalance.toStringAsFixed(2)}.',
          isError: true,
        );
        return;
      }

      // Block if fee switch is OFF but amount would consume the fee-income portion of On-Hand Cash.
      if (!_includeFeeIncomeInTransfer) {
        final availableFeeOnHand = _availableFeeIncomeOnHand ?? 0;
        final nonFeePortion = (onHandBalance - availableFeeOnHand).clamp(
          0.0,
          double.infinity,
        );
        if (availableFeeOnHand > 0 && amount > nonFeePortion) {
          _showSnackBar(
            messenger,
            'Your On-Hand Cash includes ₱ ${availableFeeOnHand.toStringAsFixed(2)} of undrawn fee income. '
            'Transferring ₱ ${amount.toStringAsFixed(2)} would consume part of it. '
            'Enable the fee transfer toggle to move it along, or reduce the transfer to ₱ ${nonFeePortion.toStringAsFixed(2)} (non-fee portion only).',
            isError: true,
          );
          return;
        }
      }

      // Block if user tries to move all On-hand with fee switch enabled and available fee income
      if (_includeFeeIncomeInTransfer &&
          (_availableFeeIncomeOnHand ?? 0) > 0 &&
          (amount - onHandBalance).abs() < 0.0001) {
        _showSnackBar(
          messenger,
          'You must leave enough On-hand Cash for the fee move, or turn off the fee transfer option.',
          isError: true,
        );
        return;
      }

      requestedFeeTransferAmount = _cashTransferFeeMoveAmount;
      final remainingOnHandAfterTransfer = (onHandBalance - amount)
          .clamp(0.0, double.infinity)
          .toDouble();
      feeTransferAmountForSave = requestedFeeTransferAmount > 0
          ? (requestedFeeTransferAmount > remainingOnHandAfterTransfer
                ? remainingOnHandAfterTransfer
                : requestedFeeTransferAmount)
          : 0.0;
    }

    if (_isFeeWithdrawal) {
      final availableFee = await _loadAvailableFeeIncomeForSelectedSource();
      if (!mounted) {
        return;
      }
      if (amount > availableFee) {
        _showSnackBar(
          messenger,
          'Withdrawal cannot be processed because available fee income in $_destinationLabel is only ₱ ${availableFee.toStringAsFixed(2)}.',
          isError: true,
        );
        return;
      }

      final sourceBalance = await _loadSelectedAccountBalance();
      if (!mounted) {
        return;
      }
      if (amount > sourceBalance) {
        _showSnackBar(
          messenger,
          'Withdrawal cannot be processed due to insufficient $_destinationLabel balance. Available: ₱ ${sourceBalance.toStringAsFixed(2)}.',
          isError: true,
        );
        return;
      }
    }

    if (_isPersonalExpensePayment) {
      final (outstanding, _) = await _loadPersonalExpenseBalance();
      if (!mounted) {
        return;
      }
      if (outstanding <= 0) {
        _showSnackBar(
          messenger,
          'No borrowed funds recorded yet. Add one before repaying.',
          isError: true,
        );
        return;
      }
      if (amount > outstanding) {
        _showSnackBar(
          messenger,
          'Repayment amount (₱ ${amount.toStringAsFixed(2)}) is more than your remaining borrowed funds balance (₱ ${outstanding.toStringAsFixed(2)}). Please enter a lower amount.',
          isError: true,
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    final saved = await _saveMovementRecord(
      amount,
      feeTransferAmountOverride: feeTransferAmountForSave,
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (!saved) {
      _showSnackBar(
        messenger,
        'Unable to save. Please try again.',
        isError: true,
      );
      return;
    }

    if (_isCashTransferToWallet && _includeFeeIncomeInTransfer) {
      if (requestedFeeTransferAmount <= 0) {
        _showSnackBar(
          messenger,
          'Transfer saved. No available fee income to move.',
        );
      } else if (feeTransferAmountForSave <= 0) {
        _showSnackBar(
          messenger,
          'Transfer saved. Fee move skipped because no On-Hand cash remained after transfer.',
        );
      } else if (feeTransferAmountForSave + 0.0001 <
          requestedFeeTransferAmount) {
        _showSnackBar(
          messenger,
          'Transfer saved. Fee moved partially: ₱ ${feeTransferAmountForSave.toStringAsFixed(2)} of ₱ ${requestedFeeTransferAmount.toStringAsFixed(2)}.',
        );
      } else {
        _showSnackBar(
          messenger,
          'Transfer saved. Fee moved fully: ₱ ${feeTransferAmountForSave.toStringAsFixed(2)}.',
        );
      }
    }

    Navigator.of(context).pop(true);
  }

  Future<bool> _saveMovementRecord(
    double amount, {
    double feeTransferAmountOverride = 0.0,
  }) async {
    final now = DateTime.now();
    final referenceInput = _referenceController.text.trim();
    final notes = _notesController.text.trim();
    final reference = referenceInput.isNotEmpty
        ? referenceInput
        : _buildAutoReference(now);
    final walletDelta = _isCashTransferToWallet
        ? (_usesGcash ? amount : 0.0)
        : (_isFeeWithdrawal
              ? (_usesGcash ? -amount : 0.0)
              : (_usesGcash ? (_isInflow ? amount : -amount) : 0.0));
    final mayaWalletDelta = _isCashTransferToWallet
        ? (_usesMayaWallet ? amount : 0.0)
        : (_isFeeWithdrawal
              ? (_usesMayaWallet ? -amount : 0.0)
              : (_usesMayaWallet ? (_isInflow ? amount : -amount) : 0.0));
    final onHandDelta = _isCashTransferToWallet
        ? -amount
        : (_isFeeWithdrawal
              ? (_destination == 'On-hand Cash' ? -amount : 0.0)
              : (_destination == 'On-hand Cash'
                    ? (_isInflow ? amount : -amount)
                    : 0.0));
    final persistedNote = notes.isNotEmpty ? notes : _defaultNote;
    final transferTitle = 'Cash Transfer - On-Hand Cash to $_destinationLabel';
    final feeWithdrawalTitle = 'Fee Withdrawal - From $_destinationLabel';
    final title = _isPersonalExpense
        ? 'Borrowed Funds - ${_selectedCategory ?? 'Uncategorized'}'
        : _isCashTransferToWallet
        ? transferTitle
        : _isFeeWithdrawal
        ? feeWithdrawalTitle
        : '$_movementType - $_destinationLabel';
    final iconKey = _isCashTransferToWallet
        ? (_usesGcash ? 'wallet' : 'maya_wallet')
        : _isFeeWithdrawal
        ? (_destination == 'On-hand Cash'
              ? 'cash'
              : (_usesGcash ? 'wallet' : 'maya_wallet'))
        : _isInflow
        ? (_usesGcash
              ? 'wallet'
              : _usesMayaWallet
              ? 'maya_wallet'
              : 'cash')
        : 'cash_out';

    final db = await _database.database;
    try {
      await _database.ensureWalletSchema(db);
      final deviceId = await _database.getOrCreateDeviceId();
      final nowMs = now.millisecondsSinceEpoch;
      await db.insert(AppDatabase.ledgerTable, {
        'entry_type': 'owner_movement',
        'title': title,
        'note': persistedNote,
        'reference': reference,
        'amount': amount,
        'wallet_delta': walletDelta,
        'maya_wallet_delta': mayaWalletDelta,
        'on_hand_delta': onHandDelta,
        'recorded_flow': amount,
        'tag': _isPersonalExpensePayment ? _movementType : _ownerScope,
        'icon_key': iconKey,
        'wallet_account': _destination,
        'owner_scope': _ownerScope,
        'owner_movement_type': _movementType,
        'owner_category': _isPersonalExpense ? _selectedCategory : null,
        'owner_party_name': null,
        'owner_party_account': null,
        AppDatabase.syncIdColumn: AppDatabase.generateSyncId('entry'),
        AppDatabase.deviceIdColumn: deviceId,
        AppDatabase.updatedAtMsColumn: nowMs,
        AppDatabase.isDeletedColumn: 0,
        AppDatabase.isDirtyColumn: 1,
        'created_at': now.toIso8601String(),
      });
      // Optionally also transfer available fee income from On-Hand Cash into the
      // selected wallet as a separate, explicit ledger row. This preserves
      // fee accounting and shows a distinct `Fee Transfer` movement in history.
      if (_isCashTransferToWallet && _includeFeeIncomeInTransfer) {
        final feeTransferAmount = feeTransferAmountOverride.clamp(
          0.0,
          double.infinity,
        );
        if (feeTransferAmount > 0) {
          final feeTitle =
              'Fee Transfer - From On-Hand Cash to $_destinationLabel';
          final feeIconKey = _usesGcash ? 'wallet' : 'maya_wallet';
          await db.insert(AppDatabase.ledgerTable, {
            'entry_type': 'owner_movement',
            'title': feeTitle,
            'note': 'Transferred fee income to $_destinationLabel',
            'reference': reference,
            'amount': feeTransferAmount,
            'wallet_delta': _usesGcash ? feeTransferAmount : 0.0,
            'maya_wallet_delta': _usesMayaWallet ? feeTransferAmount : 0.0,
            'on_hand_delta': -feeTransferAmount,
            'recorded_flow': feeTransferAmount,
            'tag': _ownerScope,
            'icon_key': feeIconKey,
            'wallet_account': _destination,
            'owner_scope': _ownerScope,
            'owner_movement_type': 'Fee Transfer',
            'owner_category': null,
            'owner_party_name': null,
            // Keep source account explicit so fee availability remains accurate.
            'owner_party_account': 'On-hand Cash',
            AppDatabase.syncIdColumn: AppDatabase.generateSyncId('entry'),
            AppDatabase.deviceIdColumn: deviceId,
            AppDatabase.updatedAtMsColumn: nowMs,
            AppDatabase.isDeletedColumn: 0,
            AppDatabase.isDirtyColumn: 1,
            'created_at': now.toIso8601String(),
          });
        }
      }

      return true;
    } on Exception {
      return false;
    }
  }

  String _buildAutoReference(DateTime timestamp) {
    final prefix = _isPersonalExpense
        ? 'PEX'
        : _isCashTransferToWallet
        ? 'XFR'
        : _isFeeWithdrawal
        ? 'FEE'
        : _isPersonalExpensePayment
        ? 'PEP'
        : 'TOP';
    final stamp = timestamp.millisecondsSinceEpoch.toString();
    return '$prefix-${stamp.substring(stamp.length - 6)}';
  }

  Future<(double outstanding, double totalExpense)>
  _loadPersonalExpenseBalance() async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN owner_movement_type IN ('Borrowed Funds', 'Personal Expense') THEN amount ELSE 0 END), 0) AS total_expense,
        COALESCE(SUM(CASE WHEN owner_movement_type IN ('Borrowed Funds Repayment', 'Personal Expense Payment') THEN amount ELSE 0 END), 0) AS total_paid
      FROM ${AppDatabase.ledgerTable}
      WHERE entry_type = 'owner_movement'
        AND owner_movement_type IN ('Borrowed Funds', 'Borrowed Funds Repayment', 'Personal Expense', 'Personal Expense Payment')
    ''');

    if (result.isEmpty) {
      return (0.0, 0.0);
    }

    final row = result.first;
    final totalExpense = (row['total_expense'] as num?)?.toDouble() ?? 0.0;
    final totalPaid = (row['total_paid'] as num?)?.toDouble() ?? 0.0;
    final outstanding = (totalExpense - totalPaid)
        .clamp(0.0, double.infinity)
        .toDouble();
    return (outstanding, totalExpense);
  }

  Future<double> _loadSelectedAccountBalance() async {
    final db = await _database.database;
    await _database.ensureWalletSchema(db);
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(wallet_delta), 0) AS wallet_balance,
        COALESCE(SUM(maya_wallet_delta), 0) AS maya_wallet_balance,
        COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ${AppDatabase.ledgerTable}
    ''');

    if (result.isEmpty) {
      return 0;
    }

    final row = result.first;
    final walletBalance = (row['wallet_balance'] as num?)?.toDouble() ?? 0;
    final mayaWalletBalance =
        (row['maya_wallet_balance'] as num?)?.toDouble() ?? 0;
    final onHandBalance = (row['on_hand_balance'] as num?)?.toDouble() ?? 0;

    if (_usesGcash) {
      return walletBalance;
    }
    if (_usesMayaWallet) {
      return mayaWalletBalance;
    }
    return onHandBalance;
  }

  Future<double> _loadOnHandCashBalance() async {
    final db = await _database.database;
    await _database.ensureWalletSchema(db);
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ${AppDatabase.ledgerTable}
    ''');

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['on_hand_balance'] as num?)?.toDouble() ?? 0;
  }

  Future<double> _loadAvailableFeeIncomeForSelectedSource() async {
    return _loadAvailableFeeIncomeForSource(_destination);
  }

  Future<double> _loadAvailableFeeIncomeForSource(String source) async {
    final db = await _database.database;
    await _database.ensureWalletSchema(db);

    final feeIncomeRows = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(fee_amount), 0) AS total_fee_income
      FROM ${AppDatabase.feeTransactionsTable}
      WHERE is_deleted = 0
        AND LOWER(charge_destination) = LOWER(?)
    ''',
      [source],
    );

    final totalFeeIncome = feeIncomeRows.isEmpty
        ? 0.0
        : (feeIncomeRows.first['total_fee_income'] as num?)?.toDouble() ?? 0.0;

    final withdrawnRows = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total_withdrawn
      FROM ${AppDatabase.ledgerTable}
      WHERE is_deleted = 0
        AND entry_type = 'owner_movement'
        AND (
          (
            owner_movement_type = 'Fee Withdrawal'
            AND LOWER(wallet_account) = LOWER(?)
          )
          OR (
            owner_movement_type = 'Fee Transfer'
            AND LOWER(COALESCE(owner_party_account, '')) = LOWER(?)
          )
        )
    ''',
      [source, source],
    );

    final totalWithdrawn = withdrawnRows.isEmpty
        ? 0.0
        : (withdrawnRows.first['total_withdrawn'] as num?)?.toDouble() ?? 0.0;

    return (totalFeeIncome - totalWithdrawn)
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  String get _defaultNote {
    if (_isCashTransferToWallet) {
      return 'Owner moved business cash from On-Hand Cash to $_destinationLabel. This is an internal transfer; total business money is unchanged.';
    }
    if (_isFeeWithdrawal) {
      return 'Owner withdrew accumulated service fees from $_destinationLabel as personal income. This is permanent withdrawal from business; money does not return.';
    }
    if (_isPersonalExpense) {
      return 'Owner logged borrowed funds for ${_selectedCategory?.toLowerCase() ?? 'general use'} from $_destinationLabel. This amount increases owner credit payable to business.';
    }
    if (_isPersonalExpensePayment) {
      return 'Owner repaid borrowed funds to $_destinationLabel. This amount reduces owner credit payable to business.';
    }
    return 'Owner added top-up funds to $_destinationLabel as business float baseline/refill.';
  }

  String get _referenceHint {
    if (_isCashTransferToWallet) {
      return 'e.g. XFR-0001 (on-hand cash to wallet transfer)';
    }
    if (_isFeeWithdrawal) {
      return 'e.g. FEE-0001 (accumulated service fee withdrawal)';
    }
    if (_isPersonalExpense) {
      return 'e.g. PEX-0001 or bill receipt';
    }
    if (_isPersonalExpensePayment) {
      return 'e.g. PEP-0001';
    }
    return 'e.g. TOP-0001 (baseline or refill)';
  }

  Future<void> _showAddCategoryDialog() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const _AddCategoryDialog(),
    );

    if (!mounted || value == null || value.trim().isEmpty) {
      return;
    }

    final normalized = value.trim();
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (_categoryExists(normalized)) {
      _showSnackBar(
        messenger,
        'That category already exists. Please use a different name.',
        isError: true,
      );
      return;
    }

    try {
      await _database.insertOwnerMovementCategory(normalized);
      if (!mounted) {
        return;
      }
      await _loadExpenseCategories(preferredCategory: normalized);
      if (!mounted) {
        return;
      }
      _showSnackBar(messenger, 'Category "$normalized" added.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(
        messenger,
        'Unable to add category. Please try a different name.',
        isError: true,
      );
    }
  }

  bool _categoryExists(String candidate, {String? excluding}) {
    final normalizedCandidate = candidate.trim().toLowerCase();
    final normalizedExcluding = excluding?.trim().toLowerCase();
    return _expenseCategories.any((name) {
      final normalized = name.trim().toLowerCase();
      if (normalizedExcluding != null && normalized == normalizedExcluding) {
        return false;
      }
      return normalized == normalizedCandidate;
    });
  }

  Future<void> _showManageCategoriesDialog() async {
    final preferredCategory = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _ManageCategoriesSheet(
        database: _database,
        initialCategories: _expenseCategories,
      ),
    );

    if (!mounted) {
      return;
    }
    await _loadExpenseCategories(preferredCategory: preferredCategory);
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

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _ManageCategoriesSheet extends StatefulWidget {
  const _ManageCategoriesSheet({
    required this.database,
    required this.initialCategories,
  });

  final AppDatabase database;
  final List<String> initialCategories;

  @override
  State<_ManageCategoriesSheet> createState() => _ManageCategoriesSheetState();
}

class _ManageCategoriesSheetState extends State<_ManageCategoriesSheet> {
  final TextEditingController _nameController = TextEditingController();
  String _editingCategory = '';
  String _searchQuery = '';
  bool _isSaving = false;
  String? _preferredCategory;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List<String>.from(widget.initialCategories);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isRenaming => _editingCategory.isNotEmpty;

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_isSaving;

  List<String> get _visibleCategories {
    final normalizedSearch = _searchQuery.trim().toLowerCase();
    return _categories
        .where(
          (category) =>
              normalizedSearch.isEmpty ||
              category.toLowerCase().contains(normalizedSearch),
        )
        .toList(growable: false);
  }

  Future<void> _reloadCategories({String? preferred}) async {
    final updated = await widget.database.loadOwnerMovementCategories();
    if (!mounted) {
      return;
    }
    setState(() {
      _categories = updated;
      if (preferred != null && preferred.isNotEmpty) {
        _preferredCategory = preferred;
      }
    });
  }

  Future<void> _saveCategory() async {
    final normalized = _nameController.text.trim();
    if (normalized.isEmpty) {
      _showSnackBar(context.l10n.enterCategoryName, isError: true);
      return;
    }

    if (_isRenaming &&
        normalized.trim().toLowerCase() ==
            _editingCategory.trim().toLowerCase()) {
      _showSnackBar('This category already has that name.');
      return;
    }

    if (_categoryExists(
      normalized,
      excluding: _isRenaming ? _editingCategory : null,
    )) {
      _showSnackBar(
        'That category already exists. Please use a different name.',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isRenaming) {
        await widget.database.updateOwnerMovementCategory(
          previousName: _editingCategory,
          newName: normalized,
        );
      } else {
        await widget.database.insertOwnerMovementCategory(normalized);
      }

      await _reloadCategories(preferred: normalized);
      if (!mounted) {
        return;
      }
      setState(() {
        _editingCategory = '';
        _nameController.clear();
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showSnackBar(
        'Unable to save category. Check if the name already exists.',
        isError: true,
      );
    }
  }

  bool _categoryExists(String candidate, {String? excluding}) {
    final normalizedCandidate = candidate.trim().toLowerCase();
    final normalizedExcluding = excluding?.trim().toLowerCase();
    return _categories.any((name) {
      final normalized = name.trim().toLowerCase();
      if (normalizedExcluding != null && normalized == normalizedExcluding) {
        return false;
      }
      return normalized == normalizedCandidate;
    });
  }

  Future<void> _deleteCategory(String category) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Delete category?'),
              content: Text('Delete "$category"? This cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    await widget.database.deleteOwnerMovementCategory(category);
    await _reloadCategories();
    if (!mounted) {
      return;
    }

    setState(() {
      if (_editingCategory == category) {
        _editingCategory = '';
        _nameController.clear();
      }
    });
    _showSnackBar(context.l10n.categoryDeleted);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.74,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.settings_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Manage Categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: _inputDecoration().copyWith(
                  hintText: 'Search categories',
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration().copyWith(
                  hintText: context.l10n.categoryName,
                  labelText: _isRenaming
                      ? 'Rename "$_editingCategory"'
                      : 'Add category',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _canSave ? _saveCategory : null,
                    icon: Icon(
                      _isRenaming ? Icons.save_rounded : Icons.add_rounded,
                    ),
                    label: Text(
                      _isRenaming ? context.l10n.save : context.l10n.add,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      if (_isRenaming) {
                        setState(() {
                          _editingCategory = '';
                          _nameController.clear();
                        });
                        return;
                      }
                      Navigator.of(context).pop(_preferredCategory);
                    },
                    child: Text(
                      _isRenaming ? context.l10n.cancel : context.l10n.done,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.existingCategories,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _visibleCategories.isEmpty
                    ? const Center(
                        child: Text(
                          'No category found.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _visibleCategories.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final category = _visibleCategories[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(category),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: context.l10n.rename,
                                  icon: const Icon(Icons.edit_outlined),
                                  color: AppColors.primary,
                                  onPressed: () {
                                    setState(() {
                                      _editingCategory = category;
                                      _nameController.text = category;
                                      _nameController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  _nameController.text.length,
                                            ),
                                          );
                                    });
                                  },
                                ),
                                IconButton(
                                  tooltip: context.l10n.delete,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  color: AppColors.error,
                                  onPressed: () => _deleteCategory(category),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: AppColors.outlineVariant, fontSize: 13),
    );
  }
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _textController.text.trim();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Create a category for borrowed-funds tracking (e.g. Food, Transport).',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  context,
                ).copyWith(hintText: context.l10n.categoryName),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: value.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(value),
                      icon: const Icon(Icons.save_rounded),
                      label: Text(context.l10n.add),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: AppColors.outlineVariant, fontSize: 13),
    );
  }
}
