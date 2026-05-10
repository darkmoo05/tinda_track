import 'package:flutter/material.dart';

import '../../core/data/app_database.dart';
import '../../core/app_theme.dart';
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
  final _categoryNameController = TextEditingController();
  static const List<String> _movementTypes = [
    'Top-up',
    'Cash Transfer (On-hand to Wallet)',
    'Personal Expense',
    'Fee Withdrawal',
    'Borrowing',
    'Borrowing Repayment',
    'Personal Expense Payment',
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
  String? _editingCategory;
  double? _availableFeeIncome;
  double? _availableFeeIncomeOnHand;
  bool _includeFeeIncomeInTransfer = false;
  bool _isSaving = false;
  bool _isLoadingCategories = true;
  bool _isLoadingFeeIncome = false;
  bool _isManagingCategories = false;
  bool _showRequiredIndicators = false;

  bool get _isPersonalExpense => _movementType == 'Personal Expense';

  bool get _isBorrowing => _movementType == 'Borrowing';

  bool get _isBorrowingRepayment => _movementType == 'Borrowing Repayment';

  bool get _isPersonalExpensePayment =>
      _movementType == 'Personal Expense Payment';

  bool get _isCashTransferToWallet =>
      _movementType == 'Cash Transfer (On-hand to Wallet)';

  bool get _isFeeWithdrawal => _movementType == 'Fee Withdrawal';

  bool get _isRepayment => _isBorrowingRepayment || _isPersonalExpensePayment;

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
    return _movementType != null && !_isPersonalExpense && !_isBorrowing;
  }

  List<String> get _accountOptions {
    if (_isCashTransferToWallet) {
      return _walletDestinations;
    }
    return _destinations;
  }

  String get _ownerScope =>
      (_isPersonalExpense ||
          _isBorrowing ||
          _isBorrowingRepayment ||
          _isPersonalExpensePayment)
      ? 'Personal'
      : 'Business';

  String get _destinationLabel =>
      _destination == 'On-hand Cash' ? 'On-Hand Cash' : _destination;

  bool get _usesGcash => _destination == 'GCash';

  bool get _usesMayaWallet => _destination == 'Maya Wallet';

  String _accountLabel(BuildContext context) {
    if (_isCashTransferToWallet) {
      return 'Transfer to Wallet';
    }
    if (_isFeeWithdrawal) {
      return 'Withdraw From';
    }
    if (_isBorrowing) {
      return context.l10n.borrowFrom;
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
      return 'You took money from $_destinationLabel for personal use. This reduces your business wallet balance.';
    }
    if (_isBorrowing) {
      return 'You borrowed money from $_destinationLabel. This reduces your business wallet balance.';
    }
    if (_isBorrowingRepayment) {
      return 'You returned borrowed money to $_destinationLabel. This adds back to your business wallet balance.';
    }
    if (_isPersonalExpensePayment) {
      return 'You returned personal expense money to $_destinationLabel. This adds back to your business wallet balance.';
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
    _categoryNameController.dispose();
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

    // Capture current destination so we don't update stale results after await.
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
      // For cash transfers, we show available fee income currently sitting in On-Hand Cash.
      final availableOnHand = await _loadAvailableFeeIncomeForSource(
        'On-hand Cash',
      );
      if (!mounted) return;
      if (!_isCashTransferToWallet) return;
      setState(() {
        _availableFeeIncomeOnHand = availableOnHand;
        // reset include flag if nothing is available
        if ((_availableFeeIncomeOnHand ?? 0) <= 0)
          _includeFeeIncomeInTransfer = false;
        _isLoadingFeeIncome = false;
      });
      return;
    }
  }

  void _applyMaxFeeWithdrawalAmount() {
    final maxAmount = (_availableFeeIncome ?? 0).clamp(0.0, double.infinity);
    _amountController.text = maxAmount.toStringAsFixed(2);
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
        if (_isManagingCategories) ...[
          const SizedBox(height: 12),
          _buildCategoryManagerCard(),
        ],
      ],
    );
  }

  Widget _buildCategoryManagerCard() {
    final isEditing = _editingCategory != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? context.l10n.renameCategory : context.l10n.addCategory,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _categoryNameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration().copyWith(
              hintText: context.l10n.categoryName,
              suffixIcon: _categoryNameController.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _categoryNameController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _submitCategoryEdit,
                icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                label: Text(isEditing ? context.l10n.save : context.l10n.add),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _cancelCategoryManagement,
                child: Text(
                  isEditing ? context.l10n.cancel : context.l10n.done,
                ),
              ),
            ],
          ),
          if (_expenseCategories.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
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
            ..._expenseCategories.map(
              (category) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(category),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _startEditingCategory(category),
                      icon: const Icon(Icons.edit_outlined),
                      color: AppColors.primary,
                      tooltip: context.l10n.rename,
                    ),
                    IconButton(
                      onPressed: () => _deleteExpenseCategory(category),
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: AppColors.error,
                      tooltip: context.l10n.delete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
        'Select or create a personal expense category.',
        isError: true,
      );
      return;
    }

    if (_isBorrowing || _isPersonalExpense) {
      final availableBalance = await _loadSelectedAccountBalance();
      if (!mounted) {
        return;
      }

      if (amount > availableBalance) {
        final movementLabel = _isBorrowing ? 'Borrowing' : 'Personal expense';
        _showSnackBar(
          messenger,
          '$movementLabel cannot be processed due to low $_destinationLabel balance. Available: ₱ ${availableBalance.toStringAsFixed(2)}.',
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

    if (_isBorrowingRepayment) {
      final (outstanding, _) = await _loadBorrowingBalance();
      if (!mounted) {
        return;
      }
      if (outstanding <= 0) {
        _showSnackBar(
          messenger,
          'No borrowing recorded yet. Add one before repaying.',
          isError: true,
        );
        return;
      }
      if (amount > outstanding) {
        _showSnackBar(
          messenger,
          'Repayment amount (₱ ${amount.toStringAsFixed(2)}) is more than your remaining borrowing debt (₱ ${outstanding.toStringAsFixed(2)}). Please enter a lower amount.',
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
          'No personal expense recorded yet. Add one before paying back.',
          isError: true,
        );
        return;
      }
      if (amount > outstanding) {
        _showSnackBar(
          messenger,
          'Payment amount (₱ ${amount.toStringAsFixed(2)}) is more than your remaining personal expense debt (₱ ${outstanding.toStringAsFixed(2)}). Please enter a lower amount.',
          isError: true,
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    final saved = await _saveMovementRecord(amount);

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

    Navigator.of(context).pop(true);
  }

  Future<bool> _saveMovementRecord(double amount) async {
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
        ? 'Personal Expense - ${_selectedCategory ?? 'Uncategorized'}'
        : _isCashTransferToWallet
        ? transferTitle
        : _isFeeWithdrawal
        ? feeWithdrawalTitle
        : (_isBorrowing || _isBorrowingRepayment || _isPersonalExpensePayment)
        ? '$_movementType - $_destinationLabel'
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
      final mainInsertId = await db.insert(AppDatabase.ledgerTable, {
        'entry_type': 'owner_movement',
        'title': title,
        'note': persistedNote,
        'reference': reference,
        'amount': amount,
        'wallet_delta': walletDelta,
        'maya_wallet_delta': mayaWalletDelta,
        'on_hand_delta': onHandDelta,
        'recorded_flow': amount,
        'tag':
            (_isBorrowing || _isBorrowingRepayment || _isPersonalExpensePayment)
            ? _movementType
            : _ownerScope,
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
        final feeTransferAmount = (_availableFeeIncomeOnHand ?? 0.0).clamp(
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
            'owner_party_account': null,
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
        : _isBorrowing
        ? 'BOR'
        : _isBorrowingRepayment
        ? 'BRP'
        : _isPersonalExpensePayment
        ? 'PEP'
        : 'TOP';
    final stamp = timestamp.millisecondsSinceEpoch.toString();
    return '$prefix-${stamp.substring(stamp.length - 6)}';
  }

  Future<(double outstanding, double totalBorrowed)>
  _loadBorrowingBalance() async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN owner_movement_type = 'Borrowing' THEN amount ELSE 0 END), 0) AS total_borrowed,
        COALESCE(SUM(CASE WHEN owner_movement_type = 'Borrowing Repayment' THEN amount ELSE 0 END), 0) AS total_repaid
      FROM ${AppDatabase.ledgerTable}
      WHERE entry_type = 'owner_movement'
        AND owner_movement_type IN ('Borrowing', 'Borrowing Repayment')
    ''');

    if (result.isEmpty) {
      return (0.0, 0.0);
    }

    final row = result.first;
    final totalBorrowed = (row['total_borrowed'] as num?)?.toDouble() ?? 0.0;
    final totalRepaid = (row['total_repaid'] as num?)?.toDouble() ?? 0.0;
    final outstanding = (totalBorrowed - totalRepaid)
        .clamp(0.0, double.infinity)
        .toDouble();
    return (outstanding, totalBorrowed);
  }

  Future<(double outstanding, double totalExpense)>
  _loadPersonalExpenseBalance() async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN owner_movement_type = 'Personal Expense' THEN amount ELSE 0 END), 0) AS total_expense,
        COALESCE(SUM(CASE WHEN owner_movement_type = 'Personal Expense Payment' THEN amount ELSE 0 END), 0) AS total_paid
      FROM ${AppDatabase.ledgerTable}
      WHERE entry_type = 'owner_movement'
        AND owner_movement_type IN ('Personal Expense', 'Personal Expense Payment')
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
        AND owner_movement_type IN ('Fee Withdrawal', 'Fee Transfer')
        AND LOWER(wallet_account) = LOWER(?)
    ''',
      [source],
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
      return 'Owner logged a personal ${_selectedCategory?.toLowerCase() ?? 'expense'} from $_destinationLabel. This amount increases owner credit payable to business.';
    }
    if (_isBorrowing) {
      return 'Owner borrowed personal funds from $_destinationLabel. This amount increases owner credit payable to business.';
    }
    if (_isBorrowingRepayment) {
      return 'Owner repaid borrowed personal funds back to $_destinationLabel. This amount reduces owner credit payable to business.';
    }
    if (_isPersonalExpensePayment) {
      return 'Owner paid back personal expense funds to $_destinationLabel. This amount reduces owner credit payable to business.';
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
    if (_isBorrowing) {
      return 'e.g. BOR-0001';
    }
    if (_isBorrowingRepayment) {
      return 'e.g. BRP-0001';
    }
    if (_isPersonalExpensePayment) {
      return 'e.g. PEP-0001';
    }
    return 'e.g. TOP-0001 (baseline or refill)';
  }

  Future<void> _showAddCategoryDialog() async {
    setState(() {
      _isManagingCategories = true;
      _editingCategory = null;
      _categoryNameController.clear();
    });
  }

  Future<void> _showManageCategoriesDialog() async {
    setState(() {
      _isManagingCategories = !_isManagingCategories;
      if (!_isManagingCategories) {
        _editingCategory = null;
        _categoryNameController.clear();
      }
    });
  }

  void _startEditingCategory(String category) {
    setState(() {
      _isManagingCategories = true;
      _editingCategory = category;
      _categoryNameController.text = category;
      _categoryNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _categoryNameController.text.length),
      );
    });
  }

  Future<void> _deleteExpenseCategory(String category) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await _database.deleteOwnerMovementCategory(category);
    await _loadExpenseCategories();
    if (!mounted) {
      return;
    }
    if (_editingCategory == category) {
      _editingCategory = null;
      _categoryNameController.clear();
    }
    _showSnackBar(messenger, context.l10n.categoryDeleted);
  }

  Future<void> _submitCategoryEdit() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final normalized = _categoryNameController.text.trim();
    if (normalized.isEmpty) {
      _showSnackBar(messenger, context.l10n.enterCategoryName, isError: true);
      return;
    }

    try {
      if (_editingCategory == null) {
        await _database.insertOwnerMovementCategory(normalized);
      } else {
        await _database.updateOwnerMovementCategory(
          previousName: _editingCategory!,
          newName: normalized,
        );
      }
      await _loadExpenseCategories(preferredCategory: normalized);
      if (!mounted) {
        return;
      }
      setState(() {
        _editingCategory = null;
        _categoryNameController.clear();
      });
    } catch (_) {
      _showSnackBar(
        messenger,
        'Unable to save category. Check if the name already exists.',
        isError: true,
      );
    }
  }

  void _cancelCategoryManagement() {
    setState(() {
      _editingCategory = null;
      _categoryNameController.clear();
      _isManagingCategories = false;
    });
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
