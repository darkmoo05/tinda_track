import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/data/app_database.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/architect_app_bar.dart';
import '../../shared/widgets/app_side_drawer.dart';
import '../../shared/widgets/screen_header_card.dart';
import 'data/charge_repository.dart';

class ChargesScreen extends StatefulWidget {
  const ChargesScreen({
    super.key,
    this.launchedFromTransaction = false,
    this.initialTypeKey,
  });

  final bool launchedFromTransaction;
  final String? initialTypeKey;

  @override
  State<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends State<ChargesScreen> {
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
  final ChargeRepository _chargeRepository = ChargeRepository.instance;
  late String _selectedTypeKey;
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

  String _localizeRepoError(BuildContext context, ChargeRepositoryError error) {
    switch (error.code) {
      case ChargeRepoErrorCode.overlapRange:
        return context.l10n.chargeErrorOverlapRange;
      case ChargeRepoErrorCode.updateTargetMissing:
        return context.l10n.chargeErrorUpdateTargetMissing;
      case ChargeRepoErrorCode.lowerBoundNonPositive:
        return context.l10n.chargeErrorLowerBoundNonPositive;
      case ChargeRepoErrorCode.upperBoundTooSmall:
        return context.l10n.chargeErrorUpperBoundTooSmall;
      case ChargeRepoErrorCode.chargeNegative:
        return context.l10n.chargeErrorNegative;
      case ChargeRepoErrorCode.chargeTooHigh:
        return context.l10n.chargeErrorTooHigh(
          (error.maxAllowed ?? 0).toStringAsFixed(2),
          (error.upperBound ?? 0).toString(),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedTypeKey =
        widget.initialTypeKey ?? FixedTransactionType.all.first.key;
    _chargeRepository.ensureLoaded();
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
    final walletPrefix = _selectedTypeKey.startsWith('maya') ? 'maya' : 'gcash';
    final service = _selectedTypeKey.replaceFirst('${walletPrefix}_', '');

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppSideDrawer(),
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
        actions: [
          if (widget.launchedFromTransaction)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                tooltip: context.l10n.backToTransaction,
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                ),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                tooltip: context.l10n.openMenu,
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                ),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.onSurfaceVariant,
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
          _buildActiveServiceTag(walletPrefix, service),
          const SizedBox(height: 24),
          _buildAddTierCard(context),
          const SizedBox(height: 24),
          _buildHelpSection(),
          const SizedBox(height: 24),
          ValueListenableBuilder<List<ChargeBracketRecord>>(
            valueListenable: _chargeRepository.brackets,
            builder: (context, brackets, child) {
              final filtered = brackets
                  .where((b) => b.transactionTypeKey == _selectedTypeKey)
                  .toList();
              return _buildActiveTiersSection(context, filtered);
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWalletToggle(
    String prefix,
    String label,
    Color color,
    bool selected,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.60)
                : AppColors.outlineVariant.withValues(alpha: 0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? color : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? color : AppColors.onSurfaceVariant,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_rounded, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDropdown({
    required String currentService,
    required String walletPrefix,
    required ValueChanged<String> onChanged,
  }) {
    final color = walletPrefix == 'maya'
        ? AppColors.secondary
        : AppColors.primary;
    final currentLabel = _serviceLabel(context, currentService);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentService,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: AppColors.surfaceContainerLowest,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: color),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          selectedItemBuilder: (context) {
            return _serviceOptionKeys
                .map((serviceKey) {
                  final isCurrent = serviceKey == currentService;
                  final label = _serviceLabel(context, serviceKey);
                  return Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isCurrent
                              ? context.l10n.selectFeeType(currentLabel)
                              : context.l10n.selectFeeType(label),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  );
                })
                .toList(growable: false);
          },
          items: _serviceOptionKeys
              .map((serviceKey) {
                final isSelected = serviceKey == currentService;
                return DropdownMenuItem<String>(
                  value: serviceKey,
                  child: Row(
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_rounded, size: 18, color: color),
                        const SizedBox(width: 8),
                      ],
                      if (!isSelected) const SizedBox(width: 26),
                      Expanded(child: Text(_serviceLabel(context, serviceKey))),
                    ],
                  ),
                );
              })
              .toList(growable: false),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            onChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return ScreenHeaderCard(
      title: context.l10n.chargesManagement,
      subtitle: context.l10n.setServiceFeeBrackets,
    );
  }

  Widget _buildActiveServiceTag(String walletPrefix, String service) {
    final walletLabel = walletPrefix == 'maya'
        ? context.l10n.mayaWalletOption
        : context.l10n.gcashWalletOption;
    final walletIcon = walletPrefix == 'maya'
        ? Icons.wallet_rounded
        : Icons.account_balance_wallet_outlined;
    final walletColor = walletPrefix == 'maya'
        ? AppColors.secondary
        : AppColors.primary;
    final serviceLabel = _serviceLabel(context, service);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.configureFeesFor,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border.all(color: walletColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: walletColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(walletIcon, size: 20, color: walletColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      walletLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      serviceLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showServiceSwitchMenu,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 20,
                      color: walletColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showServiceSwitchMenu() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        String selectedWalletPrefix = _selectedTypeKey.startsWith('maya')
            ? 'maya'
            : 'gcash';
        String selectedService = _selectedTypeKey.replaceFirst(
          '${selectedWalletPrefix}_',
          '',
        );

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void applySelection(String walletPrefix, String service) {
              setDialogState(() {
                selectedWalletPrefix = walletPrefix;
                selectedService = service;
              });

              setState(() {
                _selectedTypeKey = '${walletPrefix}_$service';
                _lowerBoundController.clear();
                _upperBoundController.clear();
                _chargeAmountController.clear();
              });
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AlertDialog(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  titlePadding: EdgeInsets.zero,
                  contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  title: Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                            Icons.swap_horiz_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n.switchService,
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
                      Text(
                        context.l10n.selectWalletAndTransactionType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildWalletToggle(
                              'gcash',
                              context.l10n.gcashWalletOption,
                              AppColors.primary,
                              selectedWalletPrefix == 'gcash',
                              Icons.account_balance_wallet_outlined,
                              () => applySelection('gcash', selectedService),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildWalletToggle(
                              'maya',
                              context.l10n.mayaWalletOption,
                              AppColors.secondary,
                              selectedWalletPrefix == 'maya',
                              Icons.wallet_rounded,
                              () => applySelection('maya', selectedService),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildServiceDropdown(
                        currentService: selectedService,
                        walletPrefix: selectedWalletPrefix,
                        onChanged: (service) =>
                            applySelection(selectedWalletPrefix, service),
                      ),
                    ],
                  ),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(context.l10n.done),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddTierCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.addNewBracket,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _lowerBoundController,
            label: context.l10n.lowerBound,
            hint: context.l10n.lowerBoundHint,
            keyboardType: TextInputType.number,
            helpText: context.l10n.startingAmountHelp,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _upperBoundController,
            label: context.l10n.upperBound,
            hint: context.l10n.upperBoundHint,
            keyboardType: TextInputType.number,
            helpText: context.l10n.endingAmountHelp,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _chargeAmountController,
            label: context.l10n.chargeAmount,
            hint: context.l10n.chargeAmountHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            helpText: context.l10n.feeAmountHelp,
          ),
          if (_lowerBoundController.text.isNotEmpty &&
              _upperBoundController.text.isNotEmpty &&
              _chargeAmountController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.feePreview(
                    _lowerBoundController.text,
                    _chargeAmountController.text,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _addBracket,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                context.l10n.addNewBracket.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _helpExpanded = !_helpExpanded),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.whatTheseFieldsMean,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _helpExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
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
              color: AppColors.surfaceContainerLowest,
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (helpText != null)
              Tooltip(
                message: helpText,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.outlineVariant),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
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

  Widget _buildActiveTiersSection(
    BuildContext context,
    List<ChargeBracketRecord> brackets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.activeTiers,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                context.l10n.totalTiers(brackets.length.toString()),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
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
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.sell_outlined,
                  size: 32,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.noFeeTiersTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.noFeeTiersMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
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

  Widget _buildTierCard(
    BuildContext context,
    ChargeBracketRecord bracket,
    int tierNumber,
  ) {
    String getTierDescription() {
      if (bracket.lowerBound <= 1000 && bracket.upperBound <= 5000) {
        return context.l10n.smallTransactions;
      } else if (bracket.lowerBound > 1000 && bracket.upperBound <= 10000) {
        return context.l10n.mediumTransactions;
      }
      return context.l10n.largeTransactions;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${bracket.lowerBound} — ₱${bracket.upperBound}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
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
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.feeAmount(
                    bracket.chargeAmount.toStringAsFixed(2),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.tierStatus(context.l10n.active),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.availableForTransactions,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editBracket(bracket),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(context.l10n.edit),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteBracket(bracket),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text(context.l10n.delete),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
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

    final error = await _chargeRepository.addBracket(
      lowerBound: lowerBound,
      upperBound: upperBound,
      chargeAmount: chargeAmount,
      transactionTypeKey: _selectedTypeKey,
    );

    if (!mounted) {
      return;
    }

    if (error != null) {
      _showMessage(_localizeRepoError(context, error), isError: true);
      return;
    }

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

  Future<void> _editBracket(ChargeBracketRecord bracket) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _ChargeBracketDialog(
            repository: _chargeRepository,
            bracket: bracket,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteBracket(ChargeBracketRecord bracket) async {
    final confirmed = await showDialog<bool>(
      context: context,
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
                  color: AppColors.error.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.layers_clear_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.deleteBracketTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.deleteBracketMessage(
                  bracket.lowerBound.toString(),
                  bracket.upperBound.toString(),
                ),
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
                  child: Text(context.l10n.cancel),
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
                  label: Text(
                    context.l10n.delete,
                    style: TextStyle(color: Colors.white),
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

    final deleted = await _chargeRepository.deleteBracket(bracket.id);
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

class _ChargeBracketDialog extends StatefulWidget {
  const _ChargeBracketDialog({required this.repository, required this.bracket});

  final ChargeRepository repository;
  final ChargeBracketRecord bracket;

  @override
  State<_ChargeBracketDialog> createState() => _ChargeBracketDialogState();
}

class _ChargeBracketDialogState extends State<_ChargeBracketDialog> {
  late final TextEditingController _lowerBoundController;
  late final TextEditingController _upperBoundController;
  late final TextEditingController _chargeAmountController;
  String? _errorText;
  bool _isSaving = false;

  String _localizeRepoError(BuildContext context, ChargeRepositoryError error) {
    switch (error.code) {
      case ChargeRepoErrorCode.overlapRange:
        return context.l10n.chargeErrorOverlapRange;
      case ChargeRepoErrorCode.updateTargetMissing:
        return context.l10n.chargeErrorUpdateTargetMissing;
      case ChargeRepoErrorCode.lowerBoundNonPositive:
        return context.l10n.chargeErrorLowerBoundNonPositive;
      case ChargeRepoErrorCode.upperBoundTooSmall:
        return context.l10n.chargeErrorUpperBoundTooSmall;
      case ChargeRepoErrorCode.chargeNegative:
        return context.l10n.chargeErrorNegative;
      case ChargeRepoErrorCode.chargeTooHigh:
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
      text: widget.bracket.lowerBound.toString(),
    );
    _upperBoundController = TextEditingController(
      text: widget.bracket.upperBound.toString(),
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

    final error = await widget.repository.updateBracket(
      widget.bracket.id,
      lowerBound: lowerBound,
      upperBound: upperBound,
      chargeAmount: chargeAmount,
    );

    if (!mounted) {
      return;
    }

    if (error != null) {
      setState(() {
        _isSaving = false;
        _errorText = _localizeRepoError(context, error);
      });
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
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.editChargeBracketTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _dialogField(
            controller: _lowerBoundController,
            label: context.l10n.lowerBound,
            hint: context.l10n.lowerBoundHint,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _dialogField(
            controller: _upperBoundController,
            label: context.l10n.upperBound,
            hint: context.l10n.upperBoundHint,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _dialogField(
            controller: _chargeAmountController,
            label: context.l10n.chargeAmount,
            hint: context.l10n.chargeAmountHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: Text(context.l10n.cancel),
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
