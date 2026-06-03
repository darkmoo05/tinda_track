import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/app_meta_dao.dart';
import '../../../../core/di/database_providers.dart';
import '../../../../core/domain/sync_metadata.dart';
import '../../../../core/app_theme.dart';
import '../../../../shared/receipt_scan/receipt_draft.dart';
import '../../../../shared/receipt_scan/receipt_scan_button.dart';
import '../../../../shared/receipt_scan/receipt_scan_service.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../domain/entities/ledger_entry.dart';
import '../domain/entities/movement_category.dart';
import '../logic/owner_movement_fee_logic.dart';
import '../presentation/providers/ledger_entry_providers.dart';
import '../presentation/providers/movement_category_providers.dart';

class AddOwnerMovementScreen extends ConsumerStatefulWidget {
  const AddOwnerMovementScreen({
    super.key,
    this.initialMovementType,
    this.initialDestination,
  });

  final String? initialMovementType;
  final String? initialDestination;

  @override
  ConsumerState<AddOwnerMovementScreen> createState() =>
      _AddOwnerMovementScreenState();
}

class _AddOwnerMovementScreenState
    extends ConsumerState<AddOwnerMovementScreen> {
  AppDatabase get _database => ref.read(appDatabaseProvider);
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
  double _onHandFeeIncomeTotal = 0.0;
  double _onHandFeeWithdrawnTotal = 0.0;
  double _onHandFeeAdjustment = 0.0;

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
      return 'Fee earnings withdrawal (permanent withdrawal)';
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

  Future<List<String>> _fetchCategoryNames() async {
    final repo = ref.read(movementCategoryRepositoryProvider);
    final categories = await repo.watchAll().first;
    return categories.map((c) => c.name).toList(growable: false);
  }

  MovementCategory _newCategoryEntity(String name) {
    final now = DateTime.now();
    return MovementCategory(
      id: '',
      name: name,
      sync: SyncMetadata(syncId: '', createdAt: now, updatedAt: now),
    );
  }

  Future<void> _loadExpenseCategories({String? preferredCategory}) async {
    setState(() => _isLoadingCategories = true);
    final categories = await _fetchCategoryNames();
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

    try {
      if (_isFeeWithdrawal) {
        final availableFee = await _loadAvailableFeeIncomeForSelectedSource();
        if (!mounted) return;
        if (!_isFeeWithdrawal || destinationAtRequest != _destination) return;
        setState(() {
          _availableFeeIncome = availableFee;
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
        });
        return;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to refresh available fee income: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        if (_isCashTransferToWallet) {
          _availableFeeIncomeOnHand = 0.0;
          _includeFeeIncomeInTransfer = false;
        }
        if (_isFeeWithdrawal) {
          _availableFeeIncome = 0.0;
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingFeeIncome = false);
      }
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
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ScreenHeaderCard(
            title: 'Owner Movement',
            subtitle:
                'Record a top-up, cash transfer, borrowed funds, or fee withdrawal.',
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Movement Details'),
                const SizedBox(height: 12),
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
                      'Available fee earnings in $_destinationLabel: ₱ ${(_availableFeeIncome ?? 0).toStringAsFixed(2)}',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Available fee earnings in On-Hand Cash: ₱ ${(_availableFeeIncomeOnHand ?? 0).toStringAsFixed(2)}',
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
                        if (_onHandFeeIncomeTotal > 0 ||
                            _onHandFeeWithdrawnTotal > 0)
                          Text(
                            'Earned: ₱ ${_onHandFeeIncomeTotal.toStringAsFixed(2)} • Withdrawn/Moved: ₱ ${_onHandFeeWithdrawnTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        if (_onHandFeeAdjustment > 0)
                          Text(
                            'Historical over-withdrawal adjusted: ₱ ${_onHandFeeAdjustment.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        if ((_availableFeeIncomeOnHand ?? 0) <= 0 &&
                            _onHandFeeIncomeTotal > 0)
                          const Text(
                            'No On-Hand fee is currently available because previous withdrawals/transfers already consumed it.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
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
                      final totalToWallet = amount + _cashTransferFeeMoveAmount;
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
                            _includeFeeIncomeInTransfer &&
                                    _cashTransferFeeMoveAmount > 0
                                ? 'Total to wallet: ₱ ${totalToWallet.toStringAsFixed(2)} = Transfer ₱ ${amount.toStringAsFixed(2)} + Fee Move ₱ ${_cashTransferFeeMoveAmount.toStringAsFixed(2)}'
                                : 'Total to wallet: ₱ ${amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Requested On-Hand: ₱ ${requiredOnHand.toStringAsFixed(2)} = Transfer ₱ ${amount.toStringAsFixed(2)} + Fee Move ₱ ${_cashTransferFeeMoveAmount.toStringAsFixed(2)}. Fee move is capped by remaining On-Hand after transfer.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (showFeeCapHint)
                            const Text(
                              'To move fee earnings, leave enough On-hand Cash after transfer or turn off the fee transfer option.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                          if (showFeeConsumeHint)
                            Text(
                              'On-Hand Cash contains ₱ ${availableFeeOnHand.toStringAsFixed(2)} of undrawn fee earnings. '
                              'If your transfer exceeds the non-fee portion, it will be blocked. '
                              'Enable the fee toggle to move fee earnings along with the transfer.',
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
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.15),
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
            initialValue: _selectedCategory,
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
    final displayAmount = _isCashTransferToWallet
        ? amount + _cashTransferFeeMoveAmount
        : amount;
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
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
            '$sign ₱ ${displayAmount.toStringAsFixed(2)}',
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
          initialValue: value,
          isExpanded: true,
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
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
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
    var feeConsumedWithinTransferForSave = 0.0;
    var totalFeeMovedForSave = 0.0;
    _RepaymentSavePlan? repaymentSavePlan;

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
      final availableFeeOnHand = await _loadAvailableFeeIncomeForSource(
        'On-hand Cash',
      );
      if (!mounted) {
        return;
      }

      _availableFeeIncomeOnHand = availableFeeOnHand;

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
        final nonFeePortion = (onHandBalance - availableFeeOnHand).clamp(
          0.0,
          double.infinity,
        );
        if (availableFeeOnHand > 0 && amount > nonFeePortion) {
          _showSnackBar(
            messenger,
            'Your On-Hand Cash includes ₱ ${availableFeeOnHand.toStringAsFixed(2)} of undrawn fee earnings. '
            'Transferring ₱ ${amount.toStringAsFixed(2)} would consume part of it. '
            'Enable the fee transfer toggle to move it along, or reduce the transfer to ₱ ${nonFeePortion.toStringAsFixed(2)} (non-fee portion only).',
            isError: true,
          );
          return;
        }
      }

      if (_includeFeeIncomeInTransfer) {
        final feeComputation = computeCashTransferFeeComputation(
          onHandBalance: onHandBalance,
          availableFeeOnHand: availableFeeOnHand,
          transferAmount: amount,
        );

        feeConsumedWithinTransferForSave =
            feeComputation.feeConsumedWithinTransfer;
        requestedFeeTransferAmount = feeComputation.requestedExtraFeeTransfer;
        feeTransferAmountForSave = feeComputation.extraFeeTransfer;
        totalFeeMovedForSave = feeComputation.totalFeeMoved;
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
          'Withdrawal cannot be processed because available fee earnings in $_destinationLabel are only ₱ ${availableFee.toStringAsFixed(2)}.',
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
        final confirmed = await _showRepaymentTopUpDialog(
          repaymentAmount: 0,
          topUpAmount: amount,
          outstanding: 0,
        );
        if (!mounted || !confirmed) {
          return;
        }
        repaymentSavePlan = _RepaymentSavePlan(
          repaymentAmount: 0,
          topUpAmount: amount,
        );
      } else if (amount > outstanding) {
        final confirmed = await _showRepaymentTopUpDialog(
          repaymentAmount: outstanding,
          topUpAmount: amount - outstanding,
          outstanding: outstanding,
        );
        if (!mounted || !confirmed) {
          return;
        }
        repaymentSavePlan = _RepaymentSavePlan(
          repaymentAmount: outstanding,
          topUpAmount: amount - outstanding,
        );
      } else {
        repaymentSavePlan = _RepaymentSavePlan(
          repaymentAmount: amount,
          topUpAmount: 0,
        );
      }
    }

    if (!mounted) return;
    final confirmed = await _showMovementConfirmationDialog(
      amount: amount,
      feeTransferAmount: feeTransferAmountForSave,
      repaymentPlan: repaymentSavePlan,
    );
    if (!mounted || !confirmed) return;

    setState(() => _isSaving = true);
    final saved = _isPersonalExpensePayment
        ? await _saveRepaymentPlan(repaymentSavePlan!)
        : await _saveMovementRecord(
            amount,
            feeTransferAmountOverride: feeTransferAmountForSave,
            feeMovedForAccounting: totalFeeMovedForSave,
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

    if (_isPersonalExpensePayment &&
        repaymentSavePlan != null &&
        repaymentSavePlan.topUpAmount > 0) {
      _showSnackBar(
        messenger,
        repaymentSavePlan.repaymentAmount > 0
            ? 'Repayment saved. Extra ₱ ${repaymentSavePlan.topUpAmount.toStringAsFixed(2)} recorded as Top-up.'
            : 'No borrowed balance remained. Full amount recorded as Top-up.',
      );
    }

    if (_isCashTransferToWallet && _includeFeeIncomeInTransfer) {
      if (totalFeeMovedForSave <= 0) {
        _showSnackBar(
          messenger,
          'Transfer saved. No available fee earnings to move.',
        );
      } else if (feeConsumedWithinTransferForSave > 0 &&
          feeTransferAmountForSave > 0) {
        _showSnackBar(
          messenger,
          'Transfer saved. Fee moved: ₱ ${totalFeeMovedForSave.toStringAsFixed(2)} (₱ ${feeConsumedWithinTransferForSave.toStringAsFixed(2)} within transfer + ₱ ${feeTransferAmountForSave.toStringAsFixed(2)} extra).',
        );
      } else if (feeConsumedWithinTransferForSave > 0) {
        _showSnackBar(
          messenger,
          'Transfer saved. Fee moved via transfer amount: ₱ ${feeConsumedWithinTransferForSave.toStringAsFixed(2)}.',
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
    double feeMovedForAccounting = 0.0,
  }) async {
    final now = DateTime.now();
    final referenceInput = _referenceController.text.trim();
    final notes = _notesController.text.trim();
    final reference = referenceInput.isNotEmpty
        ? referenceInput
        : _buildAutoReference(now);
    final feeTransferAmount = _isCashTransferToWallet
        ? feeTransferAmountOverride.clamp(0.0, double.infinity)
        : 0.0;
    final feeMovedAmount = _isCashTransferToWallet
        ? feeMovedForAccounting.clamp(0.0, double.infinity)
        : 0.0;
    final combinedTransferAmount = _isCashTransferToWallet
        ? amount + feeTransferAmount
        : amount;
    final walletDelta = _isCashTransferToWallet
        ? (_usesGcash ? combinedTransferAmount : 0.0)
        : (_isFeeWithdrawal
              ? (_usesGcash ? -amount : 0.0)
              : (_usesGcash ? (_isInflow ? amount : -amount) : 0.0));
    final mayaWalletDelta = _isCashTransferToWallet
        ? (_usesMayaWallet ? combinedTransferAmount : 0.0)
        : (_isFeeWithdrawal
              ? (_usesMayaWallet ? -amount : 0.0)
              : (_usesMayaWallet ? (_isInflow ? amount : -amount) : 0.0));
    final onHandDelta = _isCashTransferToWallet
        ? -combinedTransferAmount
        : (_isFeeWithdrawal
              ? (_destination == 'On-hand Cash' ? -amount : 0.0)
              : (_destination == 'On-hand Cash'
                    ? (_isInflow ? amount : -amount)
                    : 0.0));
    final cashTransferBreakdown = _isCashTransferToWallet && feeMovedAmount > 0
        ? 'Transfer ₱${amount.toStringAsFixed(2)} • Charge ₱${feeMovedAmount.toStringAsFixed(2)} • Charge routed to $_destinationLabel'
        : null;
    final persistedNote = [
      notes.isNotEmpty ? notes : _defaultNote,
      ?cashTransferBreakdown,
    ].join(' • ');
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

    try {
      final deviceId = await AppMetaDao(_database).getOrCreateDeviceId();
      final nowMs = now.millisecondsSinceEpoch;
      await _insertOwnerMovementEntry(
        title: title,
        note: persistedNote,
        reference: reference,
        amount: _isCashTransferToWallet ? combinedTransferAmount : amount,
        walletDelta: walletDelta,
        mayaWalletDelta: mayaWalletDelta,
        onHandDelta: onHandDelta,
        recordedFlow: _isCashTransferToWallet ? combinedTransferAmount : amount,
        tag: _isPersonalExpensePayment ? _movementType! : _ownerScope,
        iconKey: iconKey,
        walletAccount: _destination,
        ownerScope: _ownerScope,
        ownerMovementType: _movementType!,
        ownerCategory: _isPersonalExpense ? _selectedCategory : null,
        deviceId: deviceId,
        now: now,
        nowMs: nowMs,
      );

      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> _saveRepaymentPlan(_RepaymentSavePlan plan) async {
    final now = DateTime.now();

    try {
      final deviceId = await AppMetaDao(_database).getOrCreateDeviceId();
      final referenceInput = _referenceController.text.trim();
      final notes = _notesController.text.trim();

      await _database.transaction(() async {
        if (plan.repaymentAmount > 0) {
          final repaymentReference = referenceInput.isNotEmpty
              ? referenceInput
              : _buildReferenceForType('Borrowed Funds Repayment', now);
          final repaymentNote = plan.topUpAmount > 0
              ? [
                  notes.isNotEmpty ? notes : _defaultNote,
                  'Extra ₱ ${plan.topUpAmount.toStringAsFixed(2)} recorded separately as Top-up.',
                ].join(' • ')
              : (notes.isNotEmpty ? notes : _defaultNote);
          await _insertCustomMovementRecord(
            movementType: 'Borrowed Funds Repayment',
            amount: plan.repaymentAmount,
            reference: repaymentReference,
            note: repaymentNote,
            title: 'Borrowed Funds Repayment - $_destinationLabel',
            ownerScope: 'Personal',
            tag: 'Borrowed Funds Repayment',
            iconKey: _iconKeyForMovementType(
              'Borrowed Funds Repayment',
              _destination,
            ),
            deviceId: deviceId,
            now: now,
          );
        }

        if (plan.topUpAmount > 0) {
          final topUpReference = referenceInput.isNotEmpty
              ? '$referenceInput-TOP'
              : _buildReferenceForType('Top-up', now);
          final topUpNote = [
            notes.isNotEmpty
                ? notes
                : 'Owner added top-up funds to $_destinationLabel as business float baseline/refill.',
            if (plan.repaymentAmount > 0)
              'Created from repayment overage after settling ₱ ${plan.repaymentAmount.toStringAsFixed(2)} of borrowed funds.'
            else
              'Created because no borrowed balance remained to repay.',
          ].join(' • ');
          await _insertCustomMovementRecord(
            movementType: 'Top-up',
            amount: plan.topUpAmount,
            reference: topUpReference,
            note: topUpNote,
            title: 'Top-up - $_destinationLabel',
            ownerScope: 'Business',
            tag: 'Business',
            iconKey: _iconKeyForMovementType('Top-up', _destination),
            deviceId: deviceId,
            now: now,
          );
        }
      });

      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> _showMovementConfirmationDialog({
    required double amount,
    required double feeTransferAmount,
    required _RepaymentSavePlan? repaymentPlan,
  }) async {
    final displayAmount = _isCashTransferToWallet
        ? amount + feeTransferAmount
        : (repaymentPlan != null ? amount : amount);

    // Compute deltas for display
    final double walletDeltaDisplay;
    final double mayaDeltaDisplay;
    final double onHandDeltaDisplay;

    if (repaymentPlan != null) {
      // Repayment plan: show net effect
      final isGcash = _usesGcash;
      final isMaya = _usesMayaWallet;
      final repay = repaymentPlan.repaymentAmount;
      final topUp = repaymentPlan.topUpAmount;
      walletDeltaDisplay = isGcash ? repay + topUp : 0.0;
      mayaDeltaDisplay = isMaya ? repay + topUp : 0.0;
      onHandDeltaDisplay = (!isGcash && !isMaya) ? repay + topUp : 0.0;
    } else if (_isCashTransferToWallet) {
      final total = amount + feeTransferAmount;
      walletDeltaDisplay = _usesGcash ? total : 0.0;
      mayaDeltaDisplay = _usesMayaWallet ? total : 0.0;
      onHandDeltaDisplay = -total;
    } else if (_isFeeWithdrawal) {
      walletDeltaDisplay = _usesGcash ? -amount : 0.0;
      mayaDeltaDisplay = _usesMayaWallet ? -amount : 0.0;
      onHandDeltaDisplay = _destination == 'On-hand Cash' ? -amount : 0.0;
    } else {
      walletDeltaDisplay = _usesGcash ? (_isInflow ? amount : -amount) : 0.0;
      mayaDeltaDisplay = _usesMayaWallet ? (_isInflow ? amount : -amount) : 0.0;
      onHandDeltaDisplay = _destination == 'On-hand Cash'
          ? (_isInflow ? amount : -amount)
          : 0.0;
    }

    String signedAmount(double v) {
      if (v == 0) return '₱ 0.00';
      final sign = v > 0 ? '+' : '-';
      return '$sign ₱ ${v.abs().toStringAsFixed(2)}';
    }

    Color deltaColor(double v) {
      if (v > 0) return const Color(0xFF2E7D32);
      if (v < 0) return AppColors.error;
      return AppColors.onSurfaceVariant;
    }

    Widget deltaRow(String label, double delta) {
      if (delta == 0) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              signedAmount(delta),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: deltaColor(delta),
              ),
            ),
          ],
        ),
      );
    }

    final movementLabel = repaymentPlan != null
        ? _movementType ?? 'Borrowed Funds Repayment'
        : _movementType ?? '';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: _isInflow ? AppColors.secondary : AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Confirm Movement',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movementLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_destinationLabel  •  ₱ ${displayAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Balance Changes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                deltaRow('GCash Wallet', walletDeltaDisplay),
                deltaRow('Maya Wallet', mayaDeltaDisplay),
                deltaRow('On-Hand Cash', onHandDeltaDisplay),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    color: AppColors.outlineVariant,
                    thickness: 0.5,
                  ),
                ),
                Text(
                  _movementDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (repaymentPlan != null && repaymentPlan.topUpAmount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      repaymentPlan.repaymentAmount > 0
                          ? '₱ ${repaymentPlan.repaymentAmount.toStringAsFixed(2)} as repayment  +  ₱ ${repaymentPlan.topUpAmount.toStringAsFixed(2)} as Top-up'
                          : 'Full ₱ ${repaymentPlan.topUpAmount.toStringAsFixed(2)} saved as Top-up',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                if (_isCashTransferToWallet && feeTransferAmount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Includes ₱ ${feeTransferAmount.toStringAsFixed(2)} of fee earnings moved to $_destinationLabel',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: _isInflow
                    ? AppColors.secondary
                    : AppColors.error,
              ),
              child: const Text('Confirm & Save'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _showRepaymentTopUpDialog({
    required double repaymentAmount,
    required double topUpAmount,
    required double outstanding,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Convert extra amount to Top-up?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (outstanding > 0)
                Text(
                  'Remaining borrowed balance: ₱ ${outstanding.toStringAsFixed(2)}',
                )
              else
                const Text('There is no remaining borrowed balance to repay.'),
              const SizedBox(height: 10),
              Text(
                repaymentAmount > 0
                    ? 'This will save ₱ ${repaymentAmount.toStringAsFixed(2)} as Borrowed Funds Repayment and ₱ ${topUpAmount.toStringAsFixed(2)} as Top-up.'
                    : 'This will save the full ₱ ${topUpAmount.toStringAsFixed(2)} as Top-up for business capital.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _insertCustomMovementRecord({
    required String movementType,
    required double amount,
    required String reference,
    required String note,
    required String title,
    required String ownerScope,
    required String tag,
    required String iconKey,
    required String deviceId,
    required DateTime now,
  }) async {
    final isInflow =
        movementType != 'Borrowed Funds' && movementType != 'Fee Withdrawal';
    final usesGcash = _destination == 'GCash';
    final usesMayaWallet = _destination == 'Maya Wallet';
    final walletDelta = usesGcash ? (isInflow ? amount : -amount) : 0.0;
    final mayaWalletDelta = usesMayaWallet
        ? (isInflow ? amount : -amount)
        : 0.0;
    final onHandDelta = _destination == 'On-hand Cash'
        ? (isInflow ? amount : -amount)
        : 0.0;

    await _insertOwnerMovementEntry(
      title: title,
      note: note,
      reference: reference,
      amount: amount,
      walletDelta: walletDelta,
      mayaWalletDelta: mayaWalletDelta,
      onHandDelta: onHandDelta,
      recordedFlow: amount,
      tag: tag,
      iconKey: iconKey,
      walletAccount: _destination,
      ownerScope: ownerScope,
      ownerMovementType: movementType,
      ownerCategory: null,
      deviceId: deviceId,
      now: now,
      nowMs: now.millisecondsSinceEpoch,
    );
  }

  Future<void> _insertOwnerMovementEntry({
    required String title,
    required String note,
    required String reference,
    required double amount,
    required double walletDelta,
    required double mayaWalletDelta,
    required double onHandDelta,
    required double recordedFlow,
    required String tag,
    required String iconKey,
    required String walletAccount,
    required String ownerScope,
    required String ownerMovementType,
    required String? ownerCategory,
    required String deviceId,
    required DateTime now,
    required int nowMs,
  }) async {
    final entry = LedgerEntry(
      id: '',
      entryType: 'owner_movement',
      title: title,
      note: note,
      reference: reference,
      amount: amount,
      walletDelta: walletDelta,
      mayaWalletDelta: mayaWalletDelta,
      onHandDelta: onHandDelta,
      recordedFlow: recordedFlow,
      tag: tag,
      iconKey: iconKey,
      walletAccount: walletAccount,
      ownerScope: ownerScope,
      ownerMovementType: ownerMovementType,
      ownerCategory: ownerCategory,
      entryDate: now.toIso8601String(),
      sync: SyncMetadata(
        syncId: '',
        deviceId: deviceId,
        createdAt: now,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(nowMs),
        isDirty: true,
      ),
    );
    await ref.read(ledgerEntryRepositoryProvider).save(entry);
  }

  String _buildReferenceForType(String movementType, DateTime timestamp) {
    final prefix = switch (movementType) {
      'Borrowed Funds' => 'PEX',
      'Borrowed Funds Repayment' => 'PEP',
      'Cash Transfer (On-hand to Wallet)' => 'XFR',
      'Fee Withdrawal' => 'FEE',
      _ => 'TOP',
    };
    final stamp = timestamp.millisecondsSinceEpoch.toString();
    return '$prefix-${stamp.substring(stamp.length - 6)}';
  }

  String _iconKeyForMovementType(String movementType, String destination) {
    final usesGcash = destination == 'GCash';
    final usesMayaWallet = destination == 'Maya Wallet';

    if (movementType == 'Cash Transfer (On-hand to Wallet)') {
      return usesGcash ? 'wallet' : 'maya_wallet';
    }
    if (movementType == 'Fee Withdrawal') {
      if (destination == 'On-hand Cash') {
        return 'cash';
      }
      return usesGcash ? 'wallet' : 'maya_wallet';
    }
    if (movementType == 'Top-up' ||
        movementType == 'Borrowed Funds Repayment') {
      if (usesGcash) {
        return 'wallet';
      }
      if (usesMayaWallet) {
        return 'maya_wallet';
      }
      return 'cash';
    }
    return 'cash_out';
  }

  String _buildAutoReference(DateTime timestamp) {
    return _buildReferenceForType(_movementType ?? 'Top-up', timestamp);
  }

  Future<(double outstanding, double totalExpense)>
  _loadPersonalExpenseBalance() async {
    final result = await _database.customSelect('''
      SELECT
        COALESCE(SUM(CASE WHEN owner_movement_type IN ('Borrowed Funds', 'Personal Expense') THEN amount ELSE 0 END), 0) AS total_expense,
        COALESCE(SUM(CASE WHEN owner_movement_type IN ('Borrowed Funds Repayment', 'Personal Expense Payment') THEN amount ELSE 0 END), 0) AS total_paid
      FROM ledger_entries
      WHERE is_deleted = 0
        AND entry_type = 'owner_movement'
        AND owner_movement_type IN ('Borrowed Funds', 'Borrowed Funds Repayment', 'Personal Expense', 'Personal Expense Payment')
    ''').get();

    if (result.isEmpty) {
      return (0.0, 0.0);
    }

    final row = result.first.data;
    final totalExpense = (row['total_expense'] as num?)?.toDouble() ?? 0.0;
    final totalPaid = (row['total_paid'] as num?)?.toDouble() ?? 0.0;
    final outstanding = (totalExpense - totalPaid)
        .clamp(0.0, double.infinity)
        .toDouble();
    return (outstanding, totalExpense);
  }

  Future<double> _loadSelectedAccountBalance() async {
    final result = await _database.customSelect('''
      SELECT
        COALESCE(SUM(wallet_delta), 0) AS wallet_balance,
        COALESCE(SUM(maya_wallet_delta), 0) AS maya_wallet_balance,
        COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ledger_entries
      WHERE is_deleted = 0
    ''').get();

    if (result.isEmpty) {
      return 0;
    }

    final row = result.first.data;
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
    final result = await _database.customSelect('''
      SELECT COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ledger_entries
      WHERE is_deleted = 0
    ''').get();

    if (result.isEmpty) {
      return 0;
    }

    return (result.first.data['on_hand_balance'] as num?)?.toDouble() ?? 0;
  }

  Future<double> _loadAvailableFeeIncomeForSelectedSource() async {
    return _loadAvailableFeeIncomeForSource(_destination);
  }

  Future<double> _loadAvailableFeeIncomeForSource(String source) async {
    final normalizedSource = _normalizeWalletKey(source);

    // Source of truth: fee_transactions.fee_amount.
    // This avoids mixing principal amount into withdrawable fee earnings.
    final feeRowsRaw = await _database.customSelect('''
      SELECT
        related_transaction_sync_id,
        fee_amount,
        charge_destination,
        strftime('%Y-%m-%dT%H:%M:%fZ', created_at_ms / 1000.0, 'unixepoch') AS created_at
      FROM fee_transactions
      WHERE is_deleted = 0
    ''').get();
    final feeRows = feeRowsRaw
        .map((r) => Map<String, Object?>.from(r.data))
        .toList(growable: false);

    final transactionRowsRaw = await _database.customSelect('''
      SELECT
        id,
        note,
        strftime('%Y-%m-%dT%H:%M:%fZ', created_at_ms / 1000.0, 'unixepoch') AS created_at,
        wallet_account,
        icon_key
      FROM ledger_entries
      WHERE is_deleted = 0 AND entry_type = 'transaction'
    ''').get();
    final transactionRows = transactionRowsRaw
        .map((r) => Map<String, Object?>.from(r.data))
        .toList(growable: false);

    final transactionById = <String, Map<String, Object?>>{};
    for (final row in transactionRows) {
      final id = row['id'] as String?;
      if (id == null || id.isEmpty) {
        continue;
      }
      transactionById[id] = row;
    }

    var totalFeeIncome = 0.0;
    final feeEvents = <_FeeBalanceEvent>[];
    final linkedTransactionIds = <String>{};

    for (final row in feeRows) {
      final feeAmount = (row['fee_amount'] as num?)?.toDouble() ?? 0.0;
      if (feeAmount <= 0) {
        continue;
      }

      final relatedTransactionId =
          row['related_transaction_sync_id'] as String?;
      if (relatedTransactionId != null && relatedTransactionId.isNotEmpty) {
        linkedTransactionIds.add(relatedTransactionId);
      }

      final destination = ((row['charge_destination'] as String?) ?? '').trim();
      var destinationKey = _normalizeWalletKey(destination);

      if (destinationKey.isEmpty &&
          relatedTransactionId != null &&
          relatedTransactionId.isNotEmpty) {
        final tx = transactionById[relatedTransactionId];
        if (tx != null) {
          final iconKey = ((tx['icon_key'] as String?) ?? '').toLowerCase();
          final walletAccount = ((tx['wallet_account'] as String?) ?? '')
              .trim();
          destinationKey = iconKey.contains('out')
              ? _normalizeWalletKey(walletAccount)
              : 'on_hand';
        }
      }
      if (destinationKey != normalizedSource) {
        continue;
      }

      totalFeeIncome += feeAmount;
      feeEvents.add(
        _FeeBalanceEvent(
          timestampMs: _eventTimestampMs(row['created_at']),
          amount: feeAmount,
          isIncome: true,
        ),
      );
    }

    // Conservative legacy fallback: only parse explicit "Charge ..." markers
    // from transaction notes when there is no fee_transactions row.
    for (final row in transactionRows) {
      final transactionId = row['id'] as String?;
      if (transactionId == null ||
          transactionId.isEmpty ||
          linkedTransactionIds.contains(transactionId)) {
        continue;
      }

      final note = (row['note'] as String?) ?? '';
      final chargeAmount = _extractChargeAmountFromNote(note);
      if (chargeAmount <= 0) {
        continue;
      }

      final destination = _extractChargeDestinationFromNote(note);
      final destinationKey = _normalizeWalletKey(destination);
      if (destinationKey != normalizedSource) {
        continue;
      }

      totalFeeIncome += chargeAmount;
      feeEvents.add(
        _FeeBalanceEvent(
          timestampMs: _eventTimestampMs(row['created_at']),
          amount: chargeAmount,
          isIncome: true,
        ),
      );
    }

    final withdrawnRowsRaw = await _database.customSelect('''
      SELECT
        owner_movement_type,
        wallet_account,
        owner_party_account,
        amount,
        note,
        strftime('%Y-%m-%dT%H:%M:%fZ', created_at_ms / 1000.0, 'unixepoch') AS created_at
      FROM ledger_entries
      WHERE is_deleted = 0 AND entry_type = 'owner_movement'
    ''').get();
    final withdrawnRows = withdrawnRowsRaw
        .map((r) => Map<String, Object?>.from(r.data))
        .toList(growable: false);

    var totalWithdrawn = 0.0;
    for (final row in withdrawnRows) {
      final movementType = ((row['owner_movement_type'] as String?) ?? '')
          .trim()
          .toLowerCase();
      final walletAccount = _normalizeWalletKey(
        ((row['wallet_account'] as String?) ?? '').trim(),
      );
      final ownerPartyAccount = _normalizeWalletKey(
        ((row['owner_party_account'] as String?) ?? '').trim(),
      );
      final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;
      final note = (row['note'] as String?) ?? '';

      if (movementType == 'fee withdrawal' &&
          walletAccount == normalizedSource) {
        totalWithdrawn += amount;
        feeEvents.add(
          _FeeBalanceEvent(
            timestampMs: _eventTimestampMs(row['created_at']),
            amount: amount,
            isIncome: false,
          ),
        );
        continue;
      }

      if (movementType == 'fee transfer' &&
          ownerPartyAccount == normalizedSource) {
        totalWithdrawn += amount;
        feeEvents.add(
          _FeeBalanceEvent(
            timestampMs: _eventTimestampMs(row['created_at']),
            amount: amount,
            isIncome: false,
          ),
        );
        continue;
      }

      if (movementType == 'cash transfer (on-hand to wallet)' &&
          normalizedSource == 'on_hand') {
        final charge = _extractChargeAmountFromNote(note);
        totalWithdrawn += charge;
        if (charge > 0) {
          feeEvents.add(
            _FeeBalanceEvent(
              timestampMs: _eventTimestampMs(row['created_at']),
              amount: charge,
              isIncome: false,
            ),
          );
        }
      }
    }

    feeEvents.sort((a, b) => a.timestampMs.compareTo(b.timestampMs));

    var reconciledAvailable = 0.0;
    var reconciledWithdrawn = 0.0;
    for (final event in feeEvents) {
      if (event.isIncome) {
        reconciledAvailable += event.amount;
        continue;
      }

      final applied = event.amount > reconciledAvailable
          ? reconciledAvailable
          : event.amount;
      reconciledAvailable -= applied;
      reconciledWithdrawn += applied;
    }

    final available = reconciledAvailable
        .clamp(0.0, double.infinity)
        .toDouble();
    final adjustedOverWithdraw = (totalWithdrawn - reconciledWithdrawn)
        .clamp(0.0, double.infinity)
        .toDouble();

    if (normalizedSource == 'on_hand') {
      _onHandFeeIncomeTotal = totalFeeIncome;
      _onHandFeeWithdrawnTotal = reconciledWithdrawn;
      _onHandFeeAdjustment = adjustedOverWithdraw;
    }

    return available;
  }

  double _extractChargeAmountFromNote(String note) {
    final match = RegExp(
      r'Charge\s*(?:₱|PHP)?\s*([0-9]+(?:,[0-9]{3})*(?:\.[0-9]+)?)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match == null || match.groupCount < 1) {
      return 0.0;
    }

    final rawAmount = (match.group(1) ?? '').replaceAll(',', '');
    return double.tryParse(rawAmount) ?? 0.0;
  }

  String _extractChargeDestinationFromNote(String note) {
    final match = RegExp(
      r'Charge\s+routed\s+to\s*([^•]+)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match == null || match.groupCount < 1) {
      return '';
    }

    return (match.group(1) ?? '').trim();
  }

  int _eventTimestampMs(Object? raw) {
    final value = (raw as String?)?.trim();
    if (value == null || value.isEmpty) {
      return 0;
    }

    final parsed = DateTime.tryParse(value);
    return parsed?.millisecondsSinceEpoch ?? 0;
  }

  String _normalizeWalletKey(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }

    final compact = normalized.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (compact.contains('gcash')) {
      return 'gcash';
    }
    if (compact.contains('maya')) {
      return 'maya';
    }
    if (compact.contains('onhand') ||
        compact.contains('cashonhand') ||
        compact.contains('drawer') ||
        compact.contains('cashdrawer') ||
        compact.contains('cash') ||
        compact.contains('cashsakamot') ||
        compact.contains('cashsakamay') ||
        compact.contains('kamot') ||
        compact.contains('kamay')) {
      return 'on_hand';
    }

    return normalized;
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
      await ref
          .read(movementCategoriesNotifierProvider.notifier)
          .save(_newCategoryEntity(normalized));
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
      builder: (_) =>
          _ManageCategoriesSheet(initialCategories: _expenseCategories),
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

class _RepaymentSavePlan {
  const _RepaymentSavePlan({
    required this.repaymentAmount,
    required this.topUpAmount,
  });

  final double repaymentAmount;
  final double topUpAmount;
}

class _FeeBalanceEvent {
  const _FeeBalanceEvent({
    required this.timestampMs,
    required this.amount,
    required this.isIncome,
  });

  final int timestampMs;
  final double amount;
  final bool isIncome;
}

class _ManageCategoriesSheet extends ConsumerStatefulWidget {
  const _ManageCategoriesSheet({required this.initialCategories});

  final List<String> initialCategories;

  @override
  ConsumerState<_ManageCategoriesSheet> createState() =>
      _ManageCategoriesSheetState();
}

class _ManageCategoriesSheetState
    extends ConsumerState<_ManageCategoriesSheet> {
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
    final entities = await ref
        .read(movementCategoryRepositoryProvider)
        .watchAll()
        .first;
    final updated = entities.map((c) => c.name).toList(growable: false);
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
      final repo = ref.read(movementCategoryRepositoryProvider);
      final notifier = ref.read(movementCategoriesNotifierProvider.notifier);
      if (_isRenaming) {
        final existing = await repo.watchAll().first.then((list) {
          final target = _editingCategory.trim().toLowerCase();
          for (final c in list) {
            if (c.name.trim().toLowerCase() == target) {
              return c;
            }
          }
          return null;
        });
        if (existing == null) {
          throw StateError('Category not found: $_editingCategory');
        }
        await notifier.save(existing.copyWith(name: normalized));
      } else {
        final now = DateTime.now();
        await notifier.save(
          MovementCategory(
            id: '',
            name: normalized,
            sync: SyncMetadata(syncId: '', createdAt: now, updatedAt: now),
          ),
        );
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

    final entities = await ref
        .read(movementCategoryRepositoryProvider)
        .watchAll()
        .first;
    final target = category.trim().toLowerCase();
    MovementCategory? existing;
    for (final c in entities) {
      if (c.name.trim().toLowerCase() == target) {
        existing = c;
        break;
      }
    }
    if (existing != null) {
      await ref
          .read(movementCategoriesNotifierProvider.notifier)
          .delete(existing.id);
    }
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
                        separatorBuilder: (_, _) => const Divider(height: 1),
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
