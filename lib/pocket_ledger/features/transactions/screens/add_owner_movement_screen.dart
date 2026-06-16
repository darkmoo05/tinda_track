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
import '../../dashboard/logic/onboarding_provider.dart';
import '../../more/logic/monitoring_session_provider.dart';
import '../../../../shared/widgets/tutorial_spotlight.dart';

enum _MovementOnboardingStep {
  inactive,
  selectType,
  walletTransferDetails,
  saveMovement,
  completed,
}

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
  AppDatabase get _database => ref.read(currentAppDatabaseProvider);
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountFieldKey = GlobalKey(debugLabel: 'onboardingAmountField');
  final _saveButtonKey = GlobalKey(debugLabel: 'onboardingSaveButton');

  _MovementOnboardingStep _microOnboardingStep = _MovementOnboardingStep.inactive;

  final GlobalKey _typeSelectorKey = GlobalKey(debugLabel: 'ownerMovementTypeSelector');
  final GlobalKey _transferDetailsKey = GlobalKey(debugLabel: 'ownerMovementTransferDetails');

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
  bool _showDetails = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final onboardingState = ref.read(onboardingProvider);
        if (onboardingState.step == OnboardingStep.setupCapitalPrompt) {
          ref.read(onboardingProvider.notifier).setStep(OnboardingStep.addCapitalForm);
        } else {
          _checkMicroTutorialStatus();
        }
      }
    });
  }

  Future<void> _checkMicroTutorialStatus() async {
    try {
      final appMeta = ref.read(databaseAppMetaDaoProvider);
      final completed = await appMeta.get('tutorial_completed_owner_movement');
      if (completed != 'true' && mounted) {
        setState(() {
          _microOnboardingStep = _MovementOnboardingStep.selectType;
        });
      }
    } catch (_) {}
  }

  Future<void> _completeMicroTutorial() async {
    setState(() {
      _microOnboardingStep = _MovementOnboardingStep.completed;
    });
    try {
      final appMeta = ref.read(databaseAppMetaDaoProvider);
      await appMeta.set('tutorial_completed_owner_movement', 'true');
    } catch (_) {}
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedSession = ref.watch(selectedSessionProvider).value;
    final isClosed = selectedSession != null && selectedSession.status == 'CLOSED';

    final onboardingState = ref.watch(onboardingProvider);
    final isTourActive = onboardingState.step == OnboardingStep.addCapitalForm;
    final showSaveSpotlight = isTourActive && _amountController.text.isNotEmpty;
    final showAmountSpotlight = isTourActive && _amountController.text.isEmpty;

    final scaffold = Scaffold(
      backgroundColor: isDark ? AppColors.darkNavy : AppColors.background,
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (isClosed)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Viewing historical session: Recording movements is disabled.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.red.shade300 : Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          IgnorePointer(
            ignoring: isClosed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      const SizedBox(height: 14),
                      _buildMovementTypeSelector(),
                      const SizedBox(height: 20),
                      _buildFlowMetaCard(),
                      const SizedBox(height: 20),
                      _buildAccountSelector(context),
                      if (_isFeeWithdrawal) ...[
                        const SizedBox(height: 16),
                      ] else if (_isCashTransferToWallet) ...[
                        const SizedBox(height: 12),
                        Container(
                          key: _transferDetailsKey,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : AppColors.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: _isLoadingFeeIncome
                              ? Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF60A5FA) : AppColors.primary),
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Transfer Fee Earnings?',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Avail. Fee On-Hand: ₱ ${(_availableFeeIncomeOnHand ?? 0).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: _includeFeeIncomeInTransfer,
                                          activeThumbColor: AppColors.primary,
                                          onChanged: (_availableFeeIncomeOnHand ?? 0) <= 0
                                              ? null
                                              : (v) => setState(
                                                  () => _includeFeeIncomeInTransfer = v,
                                                ),
                                        ),
                                      ],
                                    ),
                                    if (_onHandFeeIncomeTotal > 0 ||
                                        _onHandFeeWithdrawnTotal > 0) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Earned: ₱ ${_onHandFeeIncomeTotal.toStringAsFixed(2)} • Moved: ₱ ${_onHandFeeWithdrawnTotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                    if (_onHandFeeAdjustment > 0) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Historical over-withdrawal adjusted: ₱ ${_onHandFeeAdjustment.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                    if ((_availableFeeIncomeOnHand ?? 0) <= 0 &&
                                        _onHandFeeIncomeTotal > 0) ...[
                                      const SizedBox(height: 4),
                                      const Text(
                                        'No On-Hand fee is currently available because previous withdrawals/transfers already consumed it.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        const SizedBox(height: 16),
                      ],

                      if (_isPersonalExpense) ...[
                        _buildCategorySection(),
                        const SizedBox(height: 16),
                      ],

                      KeyedSubtree(
                        key: _amountFieldKey,
                        child: _buildTextField(
                          controller: _amountController,
                          label: 'Amount',
                          hint: '0.00',
                          prefixText: '₱  ',
                          isRequired: true,
                          hasError: _isAmountMissing,
                          isUnderline: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
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
                            final showFeeCapHint =
                                _includeFeeIncomeInTransfer &&
                                availableFeeOnHand > 0 &&
                                amount > 0;
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'Requested On-Hand: ₱ ${requiredOnHand.toStringAsFixed(2)} = Transfer ₱ ${amount.toStringAsFixed(2)} + Fee Move ₱ ${_cashTransferFeeMoveAmount.toStringAsFixed(2)}. Fee move is capped by remaining On-Hand after transfer.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF60A5FA) : AppColors.primary).withValues(alpha: isDark ? 0.15 : 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _isLoadingFeeIncome
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF60A5FA) : AppColors.primary),
                                      ),
                                    )
                                  : Text(
                                      'Available Fee: ₱ ${(_availableFeeIncome ?? 0).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: _isLoadingFeeIncome ? null : _applyMaxFeeWithdrawalAmount,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF60A5FA) : AppColors.primary).withValues(alpha: isDark ? 0.25 : 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Use Max',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () => setState(() => _showDetails = !_showDetails),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Additional Details (Optional)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                _showDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showDetails) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _referenceController,
                          label: context.l10n.referenceOptional,
                          hint: _referenceHint,
                          isBorderless: true,
                        ),
                        const SizedBox(height: 12),
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
                          isBorderless: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(amount),
              ],
            ),
          ),
          const SizedBox(height: 24),
          KeyedSubtree(
            key: _saveButtonKey,
            child: _buildSaveButton(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );

    return Stack(
      children: [
        scaffold,
        if (showAmountSpotlight)
          TutorialSpotlight(
            targetKey: _amountFieldKey,
            title: 'Enter Starting Capital',
            description: 'Type your starting GCash balance (e.g. 1000) here to fund your business.',
            onNext: () {
              setState(() {
                _amountController.text = '1000';
              });
            },
            onSkip: () => ref.read(onboardingProvider.notifier).completeTour(),
            nextLabel: 'Fill 1,000',
            showNext: true,
            borderRadius: 12.0,
            shape: BoxShape.rectangle,
          ),
        if (showSaveSpotlight)
          TutorialSpotlight(
            targetKey: _saveButtonKey,
            title: 'Save Balance',
            description: 'Awesome! Now tap \'Save\' to record this capital in your ledger.',
            onNext: _handleSave,
            onSkip: () => ref.read(onboardingProvider.notifier).completeTour(),
            nextLabel: 'Save',
            showNext: true,
            borderRadius: 12.0,
            shape: BoxShape.rectangle,
          ),
        if (_microOnboardingStep == _MovementOnboardingStep.selectType)
          TutorialSpotlight(
            targetKey: _typeSelectorKey,
            title: 'Select Movement Type',
            description: 'Choose the movement category. Select "Cash Transfer" to move funds from physical cash on-hand to your digital wallets.',
            onNext: () {
              setState(() {
                _movementType = 'Cash Transfer (On-hand to Wallet)';
                _microOnboardingStep = _MovementOnboardingStep.walletTransferDetails;
              });
            },
            onSkip: _completeMicroTutorial,
            nextLabel: 'Next',
            showNext: true,
            shape: BoxShape.rectangle,
            borderRadius: 14.0,
          ),
        if (_microOnboardingStep == _MovementOnboardingStep.walletTransferDetails)
          TutorialSpotlight(
            targetKey: _transferDetailsKey,
            title: 'Shift Fee Earnings',
            description: 'Here you can select the destination wallet. Toggle "Transfer Fee Earnings" to move collected fees back into your active wallet capital.',
            onNext: () {
              setState(() {
                _microOnboardingStep = _MovementOnboardingStep.saveMovement;
              });
            },
            onSkip: _completeMicroTutorial,
            nextLabel: 'Next',
            showNext: true,
            shape: BoxShape.rectangle,
            borderRadius: 12.0,
          ),
        if (_microOnboardingStep == _MovementOnboardingStep.saveMovement)
          TutorialSpotlight(
            targetKey: _saveButtonKey,
            title: 'Record Movement',
            description: 'After entering the transfer amount, tap "Save Record" to update your balances. GCash/Maya will increase and On-hand cash will decrease!',
            onNext: _completeMicroTutorial,
            onSkip: _completeMicroTutorial,
            nextLabel: 'Finish',
            showNext: true,
            shape: BoxShape.rectangle,
            borderRadius: 12.0,
          ),
      ],
    );
  }

  Widget _buildFlowMetaCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = _isCashTransferToWallet
        ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
        : (_isFeeWithdrawal
              ? AppColors.error
              : (_isInflow
                    ? (isDark ? const Color(0xFF34D399) : AppColors.secondary)
                    : AppColors.error));
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
        color: tone.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: isDark ? 0.25 : 0.15),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _movementDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.l10n.addCategoryFirst,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
              ),
            ),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            hint: Text(
              context.l10n.chooseExpenseCategory,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.outlineVariant,
                fontSize: 13,
              ),
            ),
            dropdownColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
            style: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
              fontSize: 14,
            ),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedCategory = value);
            },
            decoration: _inputDecoration(hasError: _isCategoryMissing),
            icon: Icon(
              Icons.expand_more_rounded,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
            ),
            items: _expenseCategories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                      ),
                    ),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        foregroundColor: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _isCashTransferToWallet
        ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
        : (_isFeeWithdrawal
              ? AppColors.error
              : (_isInflow ? (isDark ? const Color(0xFF34D399) : AppColors.secondary) : AppColors.error));
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
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _movementSummaryLabel(context),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _movementDescription,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: DashedLinePainter(color: color.withValues(alpha: 0.25)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record Summary',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$sign ₱ ${displayAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
    bool hasError = false,
    bool isUnderline = false,
    bool isBorderless = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            fontSize: 14,
          ),
          decoration: _inputDecoration(
            hasError: hasError,
            isUnderline: isUnderline,
            isBorderless: isBorderless,
          ).copyWith(
            hintText: hint,
            prefixText: prefixText,
            prefixStyle: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            ),
          ),
        ),
      ],
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

  Widget _buildSaveButton() {
    final selectedSession = ref.watch(selectedSessionProvider).value;
    final isClosed = selectedSession != null && selectedSession.status == 'CLOSED';

    final color = _isInflow ? AppColors.secondary : AppColors.error;
    final endColor = _isInflow
        ? AppColors.successMedium
        : AppColors.errorDeep;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isClosed
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, endColor],
              ),
        color: isClosed ? (isDark ? Colors.white24 : Colors.grey.shade400) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: (isClosed || _isSaving) ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: isClosed ? (isDark ? Colors.white12 : Colors.grey.shade300) : Colors.transparent,
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
            : const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'SAVE RECORD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    // Fix 4: Re-check session status at save time to guard against the race
    // where the session was closed while this form was already open on screen.
    final currentSession = ref.read(selectedSessionProvider).value;
    if (currentSession != null &&
        currentSession.status.toUpperCase() == 'CLOSED') {
      _showSnackBar(
        messenger,
        'Cannot save to a closed session. Switch to the active session first.',
        isError: true,
      );
      return;
    }

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
      // Repayment = owner brings money from their personal pocket INTO the
      // business wallet. The money source is external (outside the system), so
      // NO source balance check is needed — the wallet is the destination, not
      // the source. The only meaningful check is how much debt is still outstanding.
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

    // Fix 1: Guard unprotected outflow types (e.g. "Withdrawal") against
    // driving the source balance negative. The other specific outflow types
    // (CashTransferToWallet, FeeWithdrawal, PersonalExpense) each have their
    // own tailored checks above — this catches everything else.
    if (!_isInflow &&
        !_isCashTransferToWallet &&
        !_isFeeWithdrawal &&
        !_isPersonalExpense &&
        !_isPersonalExpensePayment) {
      final sourceBalance = await _loadSelectedAccountBalance();
      if (!mounted) return;
      if (amount > sourceBalance) {
        _showSnackBar(
          messenger,
          'Withdrawal cannot be processed due to insufficient '
          '$_destinationLabel balance. '
          'Available: \u20b1 ${sourceBalance.toStringAsFixed(2)}.',
          isError: true,
        );
        return;
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
    final isTourActive = ref.read(onboardingProvider).step == OnboardingStep.addCapitalForm;
    final reference = isTourActive
        ? 'CAP-INITIAL-3D'
        : (referenceInput.isNotEmpty
            ? referenceInput
            : _buildAutoReference(now));
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color deltaColor(double v) {
      if (v > 0) return isDark ? const Color(0xFF34D399) : AppColors.success;
      if (v < 0) return AppColors.error;
      return isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;
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
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
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
          backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
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
                color: _isInflow ? (isDark ? const Color(0xFF34D399) : AppColors.secondary) : AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirm Movement',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  ),
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
                    color: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movementLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_destinationLabel  •  ₱ ${displayAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Balance Changes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                deltaRow('GCash Wallet', walletDeltaDisplay),
                deltaRow('Maya Wallet', mayaDeltaDisplay),
                deltaRow('On-Hand Cash', onHandDeltaDisplay),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant,
                    thickness: 0.5,
                  ),
                ),
                Text(
                  _movementDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (repaymentPlan != null && repaymentPlan.topUpAmount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF60A5FA) : AppColors.primary).withValues(alpha: isDark ? 0.15 : 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      repaymentPlan.repaymentAmount > 0
                          ? '₱ ${repaymentPlan.repaymentAmount.toStringAsFixed(2)} as repayment  +  ₱ ${repaymentPlan.topUpAmount.toStringAsFixed(2)} as Top-up'
                          : 'Full ₱ ${repaymentPlan.topUpAmount.toStringAsFixed(2)} saved as Top-up',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                      ),
                    ),
                  ),
                ],
                if (_isCashTransferToWallet && feeTransferAmount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF60A5FA) : AppColors.primary).withValues(alpha: isDark ? 0.15 : 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Includes ₱ ${feeTransferAmount.toStringAsFixed(2)} of fee earnings moved to $_destinationLabel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
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
              child: Text(
                context.l10n.cancel,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: _isInflow
                    ? (isDark ? const Color(0xFF34D399) : AppColors.secondary)
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
          title: Text(
            'Convert extra amount to Top-up?',
            style: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (outstanding > 0)
                Text(
                  'Remaining borrowed balance: ₱ ${outstanding.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  ),
                )
              else
                Text(
                  'There is no remaining borrowed balance to repay.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                repaymentAmount > 0
                    ? 'This will save ₱ ${repaymentAmount.toStringAsFixed(2)} as Borrowed Funds Repayment and ₱ ${topUpAmount.toStringAsFixed(2)} as Top-up.'
                    : 'This will save the full ₱ ${topUpAmount.toStringAsFixed(2)} as Top-up for business capital.',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                context.l10n.cancel,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
              ),
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
    final isTourActive = ref.read(onboardingProvider).step == OnboardingStep.addCapitalForm;
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
        isDirty: !isTourActive,
      ),
    );
    await ref.read(ledgerEntryRepositoryProvider).save(entry);
    if (isTourActive) {
      ref.read(onboardingProvider.notifier).setHasDemoData(true);
      ref.read(onboardingProvider.notifier).setStep(OnboardingStep.tapFabPrompt);
    }
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
    // Fix 3: Scope balance to the active session's start date so the check
    // reflects only money earned/spent in the current accounting cycle.
    final session = ref.read(selectedSessionProvider).value;
    final sessionFilter = (session != null)
        ? 'AND created_at_ms >= ${session.startDateMs}'
        : '';

    final result = await _database.customSelect('''
      SELECT
        COALESCE(SUM(wallet_delta), 0) AS wallet_balance,
        COALESCE(SUM(maya_wallet_delta), 0) AS maya_wallet_balance,
        COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ledger_entries
      WHERE is_deleted = 0
        $sessionFilter
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
    // Fix 3: Scope to current session so balance reflects this cycle only.
    final session = ref.read(selectedSessionProvider).value;
    final sessionFilter = (session != null)
        ? 'AND created_at_ms >= ${session.startDateMs}'
        : '';

    final result = await _database.customSelect('''
      SELECT COALESCE(SUM(on_hand_delta), 0) AS on_hand_balance
      FROM ledger_entries
      WHERE is_deleted = 0
        $sessionFilter
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preferredCategory = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
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

  InputDecoration _inputDecoration({
    bool hasError = false,
    bool isUnderline = false,
    bool isBorderless = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow;
    final hintColor = isDark ? const Color(0xFF94A3B8) : AppColors.outlineVariant;
    final focusedBorderColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final defaultBorderColor = isDark ? const Color(0xFF1E293B) : Colors.transparent;
    final underlineBorderColor = isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant;

    if (isBorderless) {
      return InputDecoration(
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: hintColor, fontSize: 13),
      );
    }

    if (isUnderline) {
      return InputDecoration(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? AppColors.error : underlineBorderColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? AppColors.error : underlineBorderColor,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? AppColors.error : focusedBorderColor,
            width: hasError ? 1.6 : 1.2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        hintStyle: TextStyle(color: hintColor, fontSize: 13),
      );
    }

    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : defaultBorderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : defaultBorderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : focusedBorderColor,
          width: hasError ? 1.6 : 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: hintColor, fontSize: 13),
    );
  }

  Widget _buildMovementTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTourActive = ref.read(onboardingProvider).step == OnboardingStep.addCapitalForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(
          context.l10n.movementType,
          isRequired: true,
          showErrorIndicator: _isMovementTypeMissing,
        ),
        const SizedBox(height: 10),
        SizedBox(
          key: _typeSelectorKey,
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _movementTypes.length,
            itemBuilder: (context, index) {
              final type = _movementTypes[index];
              final isSelected = _movementType == type;
              
              final Color activeColor;
              if (type == 'Borrowed Funds' || type == 'Fee Withdrawal') {
                activeColor = AppColors.error;
              } else if (type == 'Cash Transfer (On-hand to Wallet)') {
                activeColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
              } else {
                activeColor = isDark ? const Color(0xFF34D399) : AppColors.secondary;
              }

              final inactiveTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

              return GestureDetector(
                onTap: () {
                  if (isTourActive) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This field is locked to Top-up during the tutorial.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    return;
                  }
                  _onMovementTypeChanged(type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
                        : (isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.transparent,
                      width: 1.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor.withValues(alpha: isDark ? 0.25 : 0.15)
                              : inactiveTextColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _typeIcon(type),
                          color: isSelected ? activeColor : inactiveTextColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _typeShortLabel(type),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? activeColor
                                  : inactiveTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _typeIcon(String type) {
    return switch (type) {
      'Top-up' => Icons.arrow_downward_rounded,
      'Cash Transfer (On-hand to Wallet)' => Icons.swap_horiz_rounded,
      'Borrowed Funds' => Icons.arrow_upward_rounded,
      'Fee Withdrawal' => Icons.savings_rounded,
      'Borrowed Funds Repayment' => Icons.settings_backup_restore_rounded,
      _ => Icons.help_outline_rounded,
    };
  }

  String _typeShortLabel(String type) {
    return switch (type) {
      'Top-up' => 'Top-up',
      'Cash Transfer (On-hand to Wallet)' => 'Cash Transfer',
      'Borrowed Funds' => 'Borrow Funds',
      'Fee Withdrawal' => 'Fee Withdraw',
      'Borrowed Funds Repayment' => 'Repay Borrow',
      _ => type,
    };
  }

  Widget _buildAccountSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = _accountOptions;
    final isTourActive = ref.read(onboardingProvider).step == OnboardingStep.addCapitalForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(_accountLabel(context)),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            final isSelected = _destination == option;
            
            final Color activeColor;
            final Color logoBgColor;
            final Widget logoWidget;
            final String displayText = option == 'On-hand Cash' ? 'Cash' : option;

            if (option == 'GCash') {
              activeColor = isDark ? AppColors.gcashNeon : AppColors.gcash;
              logoBgColor = Colors.white;
              logoWidget = const Text(
                'G',
                style: TextStyle(
                  color: AppColors.gcash,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            } else if (option == 'Maya Wallet') {
              activeColor = isDark ? AppColors.mayaNeon : AppColors.maya;
              logoBgColor = isDark ? Colors.white : Colors.black;
              logoWidget = Text(
                'm',
                style: TextStyle(
                  color: isDark ? Colors.black : AppColors.maya,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            } else {
              activeColor = isDark ? AppColors.cashNeon : AppColors.onHandGold;
              logoBgColor = isDark ? AppColors.darkNavy : AppColors.onHandLight;
              logoWidget = Icon(
                Icons.payments_rounded,
                color: isDark ? AppColors.cashNeon : AppColors.onHandGold,
                size: 12,
              );
            }

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (isTourActive) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This is locked to GCash during the tutorial.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    return;
                  }
                  setState(() => _destination = option);
                  if (_isFeeWithdrawal || _isCashTransferToWallet) {
                    _refreshAvailableFeeIncome();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
                        : (isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.transparent,
                      width: 1.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: logoBgColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: activeColor.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: logoWidget,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            displayText,
                            style: TextStyle(
                              fontSize: 12,
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
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

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
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
              title: Text(
                'Delete category?',
                style: TextStyle(
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                ),
              ),
              content: Text(
                'Delete "$category"? This cannot be undone.',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    context.l10n.cancel,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    ),
                  ),
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
          backgroundColor: isError ? AppColors.error : AppColors.success,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.settings_rounded,
                    size: 20,
                    color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Manage Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  fontSize: 14,
                ),
                decoration: _inputDecoration().copyWith(
                  hintText: 'Search categories',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                style: TextStyle(
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  fontSize: 14,
                ),
                decoration: _inputDecoration().copyWith(
                  hintText: context.l10n.categoryName,
                  labelText: _isRenaming
                      ? 'Rename "$_editingCategory"'
                      : 'Add category',
                  labelStyle: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _canSave ? _saveCategory : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
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
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                    ),
                    child: Text(
                      _isRenaming ? context.l10n.cancel : context.l10n.done,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.existingCategories,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _visibleCategories.isEmpty
                    ? Center(
                        child: Text(
                          'No category found.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _visibleCategories.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant,
                        ),
                        itemBuilder: (context, index) {
                          final category = _visibleCategories[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              category,
                              style: TextStyle(
                                color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: context.l10n.rename,
                                  icon: const Icon(Icons.edit_outlined),
                                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow;
    final hintColor = isDark ? const Color(0xFF94A3B8) : AppColors.outlineVariant;
    final focusedBorderColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final defaultBorderColor = isDark ? const Color(0xFF1E293B) : Colors.transparent;

    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: defaultBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: defaultBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusedBorderColor, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: hintColor, fontSize: 13),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final value = _textController.text.trim();

    return Dialog(
      backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 20,
                    color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Create a category for borrowed-funds tracking (e.g. Food, Transport).',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                  fontSize: 14,
                ),
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
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant,
                        ),
                        foregroundColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                      ),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: value.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(value),
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow;
    final hintColor = isDark ? const Color(0xFF94A3B8) : AppColors.outlineVariant;
    final focusedBorderColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final defaultBorderColor = isDark ? const Color(0xFF1E293B) : Colors.transparent;

    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: defaultBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: defaultBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusedBorderColor, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: hintColor, fontSize: 13),
    );
  }
}
