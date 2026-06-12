import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
import '../../../../core/domain/sync_metadata.dart';
import '../../transactions/data/fixed_transaction_type.dart';
import '../domain/entities/charge.dart';
import '../presentation/providers/charge_providers.dart';

enum _ChargeRepoErrorCode {
  overlapRange,
  updateTargetMissing,
  lowerBoundNonPositive,
  upperBoundTooSmall,
  chargeNegative,
  chargeTooHigh,
}

class _ChargeRepositoryError {
  const _ChargeRepositoryError({
    required this.code,
    this.maxAllowed,
    this.upperBound,
  });

  final _ChargeRepoErrorCode code;
  final double? maxAllowed;
  final int? upperBound;
}

_ChargeRepositoryError? _validateBracketInput({
  required int lowerBound,
  required int upperBound,
  required double chargeAmount,
}) {
  if (lowerBound <= 0) {
    return const _ChargeRepositoryError(
      code: _ChargeRepoErrorCode.lowerBoundNonPositive,
    );
  }
  if (upperBound <= lowerBound) {
    return const _ChargeRepositoryError(
      code: _ChargeRepoErrorCode.upperBoundTooSmall,
    );
  }
  if (chargeAmount < 0) {
    return const _ChargeRepositoryError(
      code: _ChargeRepoErrorCode.chargeNegative,
    );
  }
  final maxAllowed = upperBound * 0.10;
  if (chargeAmount > maxAllowed) {
    return _ChargeRepositoryError(
      code: _ChargeRepoErrorCode.chargeTooHigh,
      maxAllowed: maxAllowed,
      upperBound: upperBound,
    );
  }
  return null;
}

bool _hasOverlap(
  List<Charge> existing,
  int lowerBound,
  int upperBound, {
  String? excludedId,
  required String typeKey,
}) {
  for (final c in existing) {
    if (c.transactionTypeKey != typeKey) continue;
    if (excludedId != null && c.id == excludedId) continue;
    final low = c.lowerBound;
    final high = c.upperBound;
    if (lowerBound <= high && upperBound >= low) {
      return true;
    }
  }
  return false;
}

class ChargesScreen extends ConsumerStatefulWidget {
  const ChargesScreen({
    super.key,
    this.openDrawer,
    this.launchedFromTransaction = false,
    this.initialTypeKey,
  });

  final VoidCallback? openDrawer;
  final bool launchedFromTransaction;
  final String? initialTypeKey;

  @override
  ConsumerState<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends ConsumerState<ChargesScreen> {
  static const List<String> _serviceOptionKeys = [
    'cashin',
    'cashout',
    'load',
    'paybills',
    'qrpayment',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _lowerBoundController = TextEditingController();
  final _upperBoundController = TextEditingController();
  final _chargeAmountController = TextEditingController();
  late String _selectedWalletPrefix;
  late String _selectedService;
  String get _selectedTypeKey => '${_selectedWalletPrefix}_$_selectedService';
  bool _helpExpanded = false;

  String _serviceLabel(BuildContext context, String serviceKey) {
    switch (serviceKey) {
      case 'cashin':
        return context.l10n.serviceCashIn;
      case 'cashout':
        return context.l10n.serviceCashOut;
      case 'load':
        return context.l10n.serviceLoad;
      case 'paybills':
        return context.l10n.servicePayBills;
      case 'qrpayment':
        return context.l10n.serviceQrPayment;
      default:
        return serviceKey;
    }
  }

  String _localizeRepoError(
    BuildContext context,
    _ChargeRepositoryError error,
  ) {
    switch (error.code) {
      case _ChargeRepoErrorCode.overlapRange:
        return context.l10n.chargeErrorOverlapRange;
      case _ChargeRepoErrorCode.updateTargetMissing:
        return context.l10n.chargeErrorUpdateTargetMissing;
      case _ChargeRepoErrorCode.lowerBoundNonPositive:
        return context.l10n.chargeErrorLowerBoundNonPositive;
      case _ChargeRepoErrorCode.upperBoundTooSmall:
        return context.l10n.chargeErrorUpperBoundTooSmall;
      case _ChargeRepoErrorCode.chargeNegative:
        return context.l10n.chargeErrorNegative;
      case _ChargeRepoErrorCode.chargeTooHigh:
        return context.l10n.chargeErrorTooHigh(
          (error.maxAllowed ?? 0).toStringAsFixed(2),
          (error.upperBound ?? 0).toString(),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    final initialKey =
        widget.initialTypeKey ?? FixedTransactionType.all.first.key;
    if (initialKey.startsWith('maya')) {
      _selectedWalletPrefix = 'maya';
      _selectedService = initialKey.replaceFirst('maya_', '');
    } else {
      _selectedWalletPrefix = 'gcash';
      _selectedService = initialKey.replaceFirst('gcash_', '');
    }
  }

  @override
  void dispose() {
    _lowerBoundController.dispose();
    _upperBoundController.dispose();
    _chargeAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLow;
    final actionIconColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

    return Scaffold(
      key: _scaffoldKey,
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        onSettingsPressed: widget.openDrawer,
        actions: [
          if (!widget.launchedFromTransaction)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                tooltip: context.l10n.openMenu,
                onPressed: widget.openDrawer,
                style: IconButton.styleFrom(
                  backgroundColor: actionBg,
                ),
                icon: Icon(
                  Icons.settings_outlined,
                  color: actionIconColor,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildPageHeader(context),
          const SizedBox(height: 24),
          _buildInlineWalletSelector(),
          const SizedBox(height: 16),
          _buildInlineServiceChips(),
          const SizedBox(height: 24),
          _buildHelpSection(),
          const SizedBox(height: 24),
          Consumer(
            builder: (context, ref, _) {
              final asyncCharges = ref.watch(chargesStreamProvider(null));
              final all = asyncCharges.value ?? const <Charge>[];
              final filtered = all
                  .where((c) => c.transactionTypeKey == _selectedTypeKey)
                  .toList();
              return _buildActiveTiersSection(context, filtered);
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showAddBracketBottomSheet(context),
              borderRadius: BorderRadius.circular(28),
              child: Tooltip(
                message: context.l10n.addNewBracket,
                child: const Center(
                  child: Icon(
                    Icons.add_box_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineWalletSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: const Color(0xFF1E293B)) : null,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildWalletTab(
              label: context.l10n.gcashWalletOption,
              prefix: 'gcash',
              color: AppColors.primary,
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildWalletTab(
              label: context.l10n.mayaWalletOption,
              prefix: 'maya',
              color: AppColors.secondary,
              icon: Icons.wallet_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTab({
    required String label,
    required String prefix,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedWalletPrefix == prefix;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWalletPrefix = prefix;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineServiceChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = _selectedWalletPrefix == 'maya'
        ? (isDark ? const Color(0xFF34D399) : AppColors.secondary)
        : (isDark ? const Color(0xFF60A5FA) : AppColors.primary);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _serviceOptionKeys.map((key) {
          final isSelected = _selectedService == key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(_serviceLabel(context, key)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedService = key;
                  });
                }
              },
              selectedColor: activeColor.withValues(alpha: 0.12),
              backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLow,
              side: BorderSide(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.4)
                    : (isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant.withValues(alpha: 0.2)),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return ScreenHeaderCard(
      title: context.l10n.chargesManagement,
      subtitle: context.l10n.setServiceFeeBrackets,
    );
  }

  void _showAddBracketBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeColor = _selectedWalletPrefix == 'maya'
                ? (isDark ? const Color(0xFF34D399) : AppColors.secondary)
                : (isDark ? const Color(0xFF60A5FA) : AppColors.primary);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_circle_outline_rounded,
                              color: activeColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.l10n.addNewBracket,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildBottomSheetField(
                    controller: _lowerBoundController,
                    label: context.l10n.lowerBound,
                    hint: context.l10n.lowerBoundHint,
                    activeColor: activeColor,
                    onChanged: () => setSheetState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _buildBottomSheetField(
                    controller: _upperBoundController,
                    label: context.l10n.upperBound,
                    hint: context.l10n.upperBoundHint,
                    activeColor: activeColor,
                    onChanged: () => setSheetState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _buildBottomSheetField(
                    controller: _chargeAmountController,
                    label: context.l10n.chargeAmount,
                    hint: context.l10n.chargeAmountHint,
                    activeColor: activeColor,
                    onChanged: () => setSheetState(() {}),
                    isDecimal: true,
                  ),
                  if (_lowerBoundController.text.isNotEmpty &&
                      _upperBoundController.text.isNotEmpty &&
                      _chargeAmountController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: activeColor.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        context.l10n.feePreview(
                          _lowerBoundController.text,
                          _chargeAmountController.text,
                        ),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: activeColor,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _selectedWalletPrefix == 'maya'
                              ? [activeColor, const Color(0xFF059669)]
                              : [activeColor, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await _addBracket();
                            if (_lowerBoundController.text.isEmpty) {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                context.l10n.addNewBracket.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color activeColor,
    required VoidCallback onChanged,
    bool isDecimal = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            fontSize: 14,
          ),
          keyboardType: isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          onChanged: (_) {
            onChanged();
            setState(() {});
          },
          decoration: InputDecoration(
            prefixText: '₱ ',
            prefixStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            ),
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? const Color(0xFF475569) : AppColors.outlineVariant),
            filled: true,
            fillColor: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _helpExpanded = !_helpExpanded),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: isDark ? Border.all(color: const Color(0xFF1E293B)) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.whatTheseFieldsMean,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _helpExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_helpExpanded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkNavyTile : AppColors.surfaceContainerLowest,
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpRow(
                  context.l10n.startingAmountLabel,
                  context.l10n.startingAmountHelp,
                ),
                const SizedBox(height: 12),
                _buildHelpRow(
                  context.l10n.endingAmountLabel,
                  context.l10n.endingAmountHelp,
                ),
                const SizedBox(height: 12),
                _buildHelpRow(
                  context.l10n.feeAmountLabel,
                  context.l10n.feeAmountHelp,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.l10n.exampleTransactionText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHelpRow(String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }



  Widget _buildActiveTiersSection(BuildContext context, List<Charge> brackets) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.activeTiers,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkNavyTile : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                context.l10n.totalTiers(brackets.length.toString()),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (brackets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 32,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.noFeeTiersTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFF8FAFC) : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.noFeeTiersMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(brackets.length, (i) {
            final bracket = brackets[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTierCard(context, bracket, i + 1),
            );
          }),
      ],
    );
  }

  Widget _buildTierCard(BuildContext context, Charge bracket, int tierNumber) {
    String getTierDescription() {
      if (bracket.lowerBound <= 1000 && bracket.upperBound <= 5000) {
        return context.l10n.smallTransactions;
      } else if (bracket.lowerBound > 1000 && bracket.upperBound <= 10000) {
        return context.l10n.mediumTransactions;
      }
      return context.l10n.largeTransactions;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = _selectedWalletPrefix == 'maya'
        ? (isDark ? const Color(0xFF34D399) : AppColors.secondary)
        : (isDark ? const Color(0xFF60A5FA) : AppColors.primary);
    final errorColor = isDark ? const Color(0xFFF87171) : AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: const Color(0xFF1E293B)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: activeColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.tierName(
                            tierNumber.toString(),
                            getTierDescription(),
                          ),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.sync_alt_rounded,
                              size: 14,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₱${bracket.lowerBound.toInt()} — ₱${bracket.upperBound.toInt()}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      context.l10n.feeAmount(
                        bracket.chargeAmount.toStringAsFixed(2),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: (isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant).withValues(alpha: 0.2),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF34D399) : AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.tierStatus(context.l10n.active),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF34D399) : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _editBracket(bracket),
                        style: IconButton.styleFrom(
                          backgroundColor: activeColor.withValues(alpha: 0.08),
                          foregroundColor: activeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 14),
                        tooltip: context.l10n.edit,
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => _deleteBracket(bracket),
                        style: IconButton.styleFrom(
                          backgroundColor: errorColor.withValues(alpha: 0.08),
                          foregroundColor: errorColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.delete_rounded, size: 14),
                        tooltip: context.l10n.delete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addBracket() async {
    final lowerBound = _parseIntInput(_lowerBoundController.text);
    final upperBound = _parseIntInput(_upperBoundController.text);
    final chargeAmount = _parseDoubleInput(_chargeAmountController.text);

    if (lowerBound == null || upperBound == null || chargeAmount == null) {
      _showMessage(context.l10n.chargeInputInvalid, isError: true);
      return;
    }

    final validationError = _validateBracketInput(
      lowerBound: lowerBound,
      upperBound: upperBound,
      chargeAmount: chargeAmount,
    );
    if (validationError != null) {
      _showMessage(_localizeRepoError(context, validationError), isError: true);
      return;
    }

    final existing =
        ref.read(chargesStreamProvider(null)).value ?? const <Charge>[];
    if (_hasOverlap(
      existing,
      lowerBound,
      upperBound,
      typeKey: _selectedTypeKey,
    )) {
      _showMessage(
        _localizeRepoError(
          context,
          const _ChargeRepositoryError(code: _ChargeRepoErrorCode.overlapRange),
        ),
        isError: true,
      );
      return;
    }

    final now = DateTime.now();
    final newCharge = Charge(
      id: '',
      lowerBound: lowerBound.toDouble(),
      upperBound: upperBound.toDouble(),
      chargeAmount: chargeAmount,
      transactionTypeKey: _selectedTypeKey,
      sync: SyncMetadata(
        syncId: '',
        createdAt: now,
        updatedAt: now,
        isDirty: true,
      ),
    );

    try {
      await ref.read(chargesNotifierProvider.notifier).save(newCharge);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.chargeInputInvalid, isError: true);
      return;
    }

    if (!mounted) return;
    _lowerBoundController.clear();
    _upperBoundController.clear();
    _chargeAmountController.clear();
    _showMessage(context.l10n.chargeBracketAdded);
  }

  int? _parseIntInput(String raw) {
    final normalized = raw.replaceAll(',', '').trim();
    return int.tryParse(normalized);
  }

  double? _parseDoubleInput(String raw) {
    final normalized = raw.replaceAll(',', '').trim();
    return double.tryParse(normalized);
  }

  Future<void> _editBracket(Charge bracket) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _ChargeBracketDialog(bracket: bracket),
        ),
      ),
    );
  }

  Future<void> _deleteBracket(Charge bracket) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? const Color(0xFFF87171) : AppColors.error;

    final confirmed = await showDialog<bool>(
      context: context,
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
                  color: errorColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.layers_clear_rounded,
                  color: errorColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.deleteBracketTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.deleteBracketMessage(
                  bracket.lowerBound.toInt().toString(),
                  bracket.upperBound.toInt().toString(),
                ),
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
                    side: BorderSide(color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant),
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
                    backgroundColor: errorColor,
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
                  label: Text(
                    context.l10n.delete,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final deleted = await () async {
      try {
        await ref.read(chargesNotifierProvider.notifier).delete(bracket.id);
        return true;
      } catch (_) {
        return false;
      }
    }();
    if (!mounted) {
      return;
    }

    _showMessage(
      deleted
          ? context.l10n.chargeBracketDeleted
          : context.l10n.unableToDeleteBracket,
      isError: !deleted,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
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
}

class _ChargeBracketDialog extends ConsumerStatefulWidget {
  const _ChargeBracketDialog({required this.bracket});

  final Charge bracket;

  @override
  ConsumerState<_ChargeBracketDialog> createState() =>
      _ChargeBracketDialogState();
}

class _ChargeBracketDialogState extends ConsumerState<_ChargeBracketDialog> {
  late final TextEditingController _lowerBoundController;
  late final TextEditingController _upperBoundController;
  late final TextEditingController _chargeAmountController;
  String? _errorText;
  bool _isSaving = false;

  String _localizeRepoError(
    BuildContext context,
    _ChargeRepositoryError error,
  ) {
    switch (error.code) {
      case _ChargeRepoErrorCode.overlapRange:
        return context.l10n.chargeErrorOverlapRange;
      case _ChargeRepoErrorCode.updateTargetMissing:
        return context.l10n.chargeErrorUpdateTargetMissing;
      case _ChargeRepoErrorCode.lowerBoundNonPositive:
        return context.l10n.chargeErrorLowerBoundNonPositive;
      case _ChargeRepoErrorCode.upperBoundTooSmall:
        return context.l10n.chargeErrorUpperBoundTooSmall;
      case _ChargeRepoErrorCode.chargeNegative:
        return context.l10n.chargeErrorNegative;
      case _ChargeRepoErrorCode.chargeTooHigh:
        return context.l10n.chargeErrorTooHigh(
          (error.maxAllowed ?? 0).toStringAsFixed(2),
          (error.upperBound ?? 0).toString(),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _lowerBoundController = TextEditingController(
      text: widget.bracket.lowerBound.toInt().toString(),
    );
    _upperBoundController = TextEditingController(
      text: widget.bracket.upperBound.toInt().toString(),
    );
    _chargeAmountController = TextEditingController(
      text: widget.bracket.chargeAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _lowerBoundController.dispose();
    _upperBoundController.dispose();
    _chargeAmountController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final lowerBound = _parseIntInput(_lowerBoundController.text);
    final upperBound = _parseIntInput(_upperBoundController.text);
    final chargeAmount = _parseDoubleInput(_chargeAmountController.text);

    if (lowerBound == null || upperBound == null || chargeAmount == null) {
      setState(() {
        _errorText = context.l10n.chargeInputInvalid;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final validationError = _validateBracketInput(
      lowerBound: lowerBound,
      upperBound: upperBound,
      chargeAmount: chargeAmount,
    );
    if (validationError != null) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = _localizeRepoError(context, validationError);
      });
      return;
    }

    final existing =
        ref.read(chargesStreamProvider(null)).value ?? const <Charge>[];
    if (_hasOverlap(
      existing,
      lowerBound,
      upperBound,
      excludedId: widget.bracket.id,
      typeKey: widget.bracket.transactionTypeKey,
    )) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = _localizeRepoError(
          context,
          const _ChargeRepositoryError(code: _ChargeRepoErrorCode.overlapRange),
        );
      });
      return;
    }

    final now = DateTime.now();
    final updated = widget.bracket.copyWith(
      lowerBound: lowerBound.toDouble(),
      upperBound: upperBound.toDouble(),
      chargeAmount: chargeAmount,
      sync: widget.bracket.sync.copyWith(isDirty: true, updatedAt: now),
    );

    try {
      await ref.read(chargesNotifierProvider.notifier).save(updated);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = context.l10n.chargeInputInvalid;
      });
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  int? _parseIntInput(String raw) {
    final normalized = raw.replaceAll(',', '').trim();
    return int.tryParse(normalized);
  }

  double? _parseDoubleInput(String raw) {
    final normalized = raw.replaceAll(',', '').trim();
    return double.tryParse(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMaya = widget.bracket.transactionTypeKey.startsWith('maya');
    final activeColor = isMaya
        ? (isDark ? const Color(0xFF34D399) : AppColors.secondary)
        : (isDark ? const Color(0xFF60A5FA) : AppColors.primary);

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: activeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.editChargeBracketTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
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
            context.l10n.editChargeBracketHint,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _dialogField(
            controller: _lowerBoundController,
            label: context.l10n.lowerBound,
            hint: context.l10n.lowerBoundHint,
            keyboardType: TextInputType.number,
            isDark: isDark,
            activeColor: activeColor,
          ),
          const SizedBox(height: 12),
          _dialogField(
            controller: _upperBoundController,
            label: context.l10n.upperBound,
            hint: context.l10n.upperBoundHint,
            keyboardType: TextInputType.number,
            isDark: isDark,
            activeColor: activeColor,
          ),
          const SizedBox(height: 12),
          _dialogField(
            controller: _chargeAmountController,
            label: context.l10n.chargeAmount,
            hint: context.l10n.chargeAmountHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isDark: isDark,
            activeColor: activeColor,
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
                  side: BorderSide(color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: Text(context.l10n.cancel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: activeColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSaving ? null : _onSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 16),
                label: Text(
                  _isSaving ? context.l10n.saving : context.l10n.saveChanges,
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
    required bool isDark,
    required Color activeColor,
    TextInputType? keyboardType,
  }) {
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
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixText: '₱ ',
            prefixStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            ),
            hintText: hint,
            filled: true,
            fillColor: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
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
