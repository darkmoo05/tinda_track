import 'package:flutter/material.dart';

import '../../core/data/app_database.dart';
import '../../core/app_theme.dart';

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
    'Personal Expense',
    'Borrowing',
    'Repayment',
  ];
  static const List<String> _destinations = ['GCash', 'On-hand Cash'];

  String? _movementType;
  late String _destination;
  List<String> _expenseCategories = const [];
  String? _selectedCategory;
  String? _editingCategory;
  bool _isSaving = false;
  bool _isLoadingCategories = true;
  bool _isManagingCategories = false;

  bool get _isPersonalExpense => _movementType == 'Personal Expense';

  bool get _isBorrowing => _movementType == 'Borrowing';

  bool get _isRepayment => _movementType == 'Repayment';

  bool get _isInflow =>
      _movementType != null && !_isPersonalExpense && !_isBorrowing;

  String get _ownerScope => (_isPersonalExpense || _isBorrowing || _isRepayment)
      ? 'Personal'
      : 'Business';

  String get _destinationLabel =>
      _destination == 'On-hand Cash' ? 'On-Hand Cash' : _destination;

  String get _accountLabel {
    if (_isBorrowing) {
      return 'Borrow From';
    }
    if (_isRepayment) {
      return 'Repay To';
    }
    return _isInflow ? 'Destination' : 'Source Account';
  }

  String get _autoDirectionLabel => _isInflow ? 'Cash In' : 'Cash Out';

  String get _movementSummaryLabel {
    if (_movementType == null) {
      return 'Movement Type Pending';
    }
    if (_isPersonalExpense) {
      final categoryLabel = _selectedCategory ?? 'Category Pending';
      return '$_movementType • $categoryLabel';
    }
    return '$_movementType • $_destinationLabel';
  }

  String get _movementDescription {
    if (_isPersonalExpense) {
      return 'Logs a personal cash-out from $_destinationLabel and records it as owner credit to be paid back to business.';
    }
    if (_isBorrowing) {
      return 'Records owner cash borrowed from $_destinationLabel for personal use. This increases owner credit to pay back.';
    }
    if (_isRepayment) {
      return 'Records owner repayment returned to $_destinationLabel and reduces outstanding owner credit.';
    }
    return 'Adds more business float into $_destinationLabel.';
  }

  @override
  void initState() {
    super.initState();
    _movementType = _resolveInitialMovementType();
    _destination = _resolveInitialDestination();
    _loadExpenseCategories();
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
      if (!_isPersonalExpense) {
        _selectedCategory = null;
      } else if (_expenseCategories.isNotEmpty) {
        _selectedCategory = _selectedCategory ?? _expenseCategories.first;
      }
    });
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
        title: const Text(
          'New Owner Movement',
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
            'Record Owner Movement',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Phase 3 tracks owner borrowing and repayment directly against wallet or on-hand cash to monitor owner credit and payback.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  label: 'Movement Type',
                  value: _movementType,
                  items: _movementTypes,
                  onChanged: _onMovementTypeChanged,
                  hintText: 'Choose Movement Type',
                ),
                const SizedBox(height: 20),

                _buildFlowMetaCard(),
                const SizedBox(height: 20),

                _buildDropdownField(
                  label: _accountLabel,
                  value: _destination,
                  items: _destinations,
                  onChanged: (val) {
                    if (val == null) {
                      return;
                    }
                    setState(() => _destination = val);
                  },
                ),
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _referenceController,
                  label: 'Reference (Optional)',
                  hint: _referenceHint,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  hint: 'Additional details...',
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
    final tone = _isInflow ? AppColors.secondary : AppColors.error;
    final icon = _isInflow
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

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
                  'Money Direction',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tone,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_autoDirectionLabel • $_ownerScope funds',
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
            _fieldLabel('Expense Category'),
            const Spacer(),
            _buildCategoryAction(
              label: 'Add',
              icon: Icons.add_rounded,
              onTap: _showAddCategoryDialog,
            ),
            const SizedBox(width: 8),
            _buildCategoryAction(
              label: 'Manage',
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
            child: const Text(
              'Add at least one personal expense category before saving this entry.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: const Text(
              'Choose Expense Category',
              style: TextStyle(color: AppColors.outlineVariant, fontSize: 13),
            ),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedCategory = value);
            },
            decoration: _inputDecoration(),
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
            isEditing ? 'Rename Category' : 'Add Category',
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
              hintText: 'Category name',
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
                label: Text(isEditing ? 'Save' : 'Add'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _cancelCategoryManagement,
                child: Text(isEditing ? 'Cancel' : 'Done'),
              ),
            ],
          ),
          if (_expenseCategories.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Text(
              'Existing Categories',
              style: TextStyle(
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
                      tooltip: 'Rename',
                    ),
                    IconButton(
                      onPressed: () => _deleteExpenseCategory(category),
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: AppColors.error,
                      tooltip: 'Delete',
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
    final color = _isInflow ? AppColors.secondary : AppColors.error;
    final sign = _isInflow ? '+' : '-';
    final icon = _isInflow
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

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
                  _movementSummaryLabel,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: _inputDecoration().copyWith(hintText: hintText),
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
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration().copyWith(
            hintText: hint,
            prefixText: prefixText,
          ),
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
                'SAVE MOVEMENT',
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

    if (_movementType == null) {
      _showSnackBar(
        messenger,
        'Please choose a movement type before saving.',
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

    if (_isRepayment) {
      final (outstanding, totalBorrowed) =
          await _loadOutstandingBorrowingBalance();
      if (!mounted) {
        return;
      }
      if (totalBorrowed <= 0) {
        _showSnackBar(
          messenger,
          'No borrowing transaction found. Record a borrowing first before making a repayment.',
          isError: true,
        );
        return;
      }
      if (amount > outstanding) {
        _showSnackBar(
          messenger,
          'Repayment amount (₱ ${amount.toStringAsFixed(2)}) exceeds outstanding borrowing balance (₱ ${outstanding.toStringAsFixed(2)}). Adjust the amount.',
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
        'Unable to save owner movement. Please try again.',
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
    final walletDelta = _destination == 'GCash'
        ? (_isInflow ? amount : -amount)
        : 0.0;
    final onHandDelta = _destination == 'On-hand Cash'
        ? (_isInflow ? amount : -amount)
        : 0.0;
    final persistedNote = notes.isNotEmpty ? notes : _defaultNote;
    final title = _isPersonalExpense
        ? 'Personal Expense - ${_selectedCategory ?? 'Uncategorized'}'
        : (_isBorrowing || _isRepayment)
        ? '$_movementType - $_destinationLabel'
        : '$_movementType - $_destinationLabel';
    final iconKey = _isInflow
        ? (_destination == 'GCash' ? 'wallet' : 'cash')
        : 'cash_out';

    final db = await _database.database;
    try {
      await db.insert(AppDatabase.ledgerTable, {
        'entry_type': 'owner_movement',
        'title': title,
        'note': persistedNote,
        'reference': reference,
        'amount': amount,
        'wallet_delta': walletDelta,
        'on_hand_delta': onHandDelta,
        'recorded_flow': amount,
        'tag': (_isBorrowing || _isRepayment) ? _movementType : _ownerScope,
        'icon_key': iconKey,
        'owner_scope': _ownerScope,
        'owner_movement_type': _movementType,
        'owner_category': _isPersonalExpense ? _selectedCategory : null,
        'owner_party_name': null,
        'owner_party_account': null,
        'created_at': now.toIso8601String(),
      });
      return true;
    } on Exception {
      return false;
    }
  }

  String _buildAutoReference(DateTime timestamp) {
    final prefix = _isPersonalExpense
        ? 'PEX'
        : _isBorrowing
        ? 'BOR'
        : _isRepayment
        ? 'REP'
        : 'TOP';
    final stamp = timestamp.millisecondsSinceEpoch.toString();
    return '$prefix-${stamp.substring(stamp.length - 6)}';
  }

  Future<(double outstanding, double totalBorrowed)>
  _loadOutstandingBorrowingBalance() async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN owner_movement_type = 'Borrowing' THEN amount ELSE 0 END), 0) AS total_borrowed,
        COALESCE(SUM(CASE WHEN owner_movement_type = 'Repayment' THEN amount ELSE 0 END), 0) AS total_repaid
      FROM ${AppDatabase.ledgerTable}
      WHERE entry_type = 'owner_movement'
        AND owner_movement_type IN ('Borrowing', 'Repayment')
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

  Future<double> _loadSelectedAccountBalance() async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(wallet_delta), 0) AS wallet_balance,
        COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ${AppDatabase.ledgerTable}
    ''');

    if (result.isEmpty) {
      return 0;
    }

    final row = result.first;
    final walletBalance = (row['wallet_balance'] as num?)?.toDouble() ?? 0;
    final onHandBalance = (row['on_hand_balance'] as num?)?.toDouble() ?? 0;

    return _destination == 'GCash' ? walletBalance : onHandBalance;
  }

  String get _defaultNote {
    if (_isPersonalExpense) {
      return 'Owner logged a personal ${_selectedCategory?.toLowerCase() ?? 'expense'} from $_destinationLabel. This amount increases owner credit payable to business.';
    }
    if (_isBorrowing) {
      return 'Owner borrowed personal funds from $_destinationLabel. This amount increases owner credit payable to business.';
    }
    if (_isRepayment) {
      return 'Owner repaid borrowed personal funds back to $_destinationLabel. This amount reduces owner credit payable to business.';
    }
    return 'Owner added top-up funds to $_destinationLabel as business float baseline/refill.';
  }

  String get _referenceHint {
    if (_isPersonalExpense) {
      return 'e.g. PEX-0001 or bill receipt';
    }
    if (_isBorrowing) {
      return 'e.g. BOR-0001';
    }
    if (_isRepayment) {
      return 'e.g. REP-0001';
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
    _showSnackBar(messenger, 'Category deleted.');
  }

  Future<void> _submitCategoryEdit() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final normalized = _categoryNameController.text.trim();
    if (normalized.isEmpty) {
      _showSnackBar(messenger, 'Enter a category name.', isError: true);
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
