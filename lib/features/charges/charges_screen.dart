import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../shared/widgets/architect_app_bar.dart';
import '../../shared/widgets/app_side_drawer.dart';
import 'data/charge_repository.dart';

class ChargesScreen extends StatefulWidget {
  const ChargesScreen({super.key, this.launchedFromTransaction = false});

  final bool launchedFromTransaction;

  @override
  State<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends State<ChargesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _lowerBoundController = TextEditingController();
  final _upperBoundController = TextEditingController();
  final _chargeAmountController = TextEditingController();
  final ChargeRepository _chargeRepository = ChargeRepository.instance;

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppSideDrawer(),
      appBar: ArchitectAppBar(
        title: 'PocketLedger',
        onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
        actions: [
          if (widget.launchedFromTransaction)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                tooltip: 'Back to transaction',
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
                tooltip: 'Open menu',
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
          _buildAddBracketCard(context),
          const SizedBox(height: 24),
          ValueListenableBuilder<List<ChargeBracketRecord>>(
            valueListenable: _chargeRepository.brackets,
            builder: (context, brackets, child) {
              return _buildActiveBracketsSection(context, brackets);
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charges Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Configure service fee structures and monitor architectural fund flows.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAddBracketCard(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Add New Bracket',
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
            label: 'Lower Bound (PHP)',
            hint: 'e.g. 1000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _upperBoundController,
            label: 'Upper Bound (PHP)',
            hint: 'e.g. 1500',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _chargeAmountController,
            label: 'Charge Amount (PHP)',
            hint: 'e.g. 25.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _addBracket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CREATE BRACKET',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
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
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
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

  Widget _buildActiveBracketsSection(
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
              'Active Charge Brackets',
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
                'Total: ${brackets.length} Brackets',
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
                  'No charge brackets saved yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This section now loads bracket ranges from your local database.',
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
              child: _buildBracketTile(context, bracket),
            );
          }),
      ],
    );
  }

  Widget _buildBracketTile(BuildContext context, ChargeBracketRecord bracket) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bracket.lowerBound} - ${bracket.upperBound} PHP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Charge: ${bracket.chargeAmount.toStringAsFixed(2)} PHP',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editBracket(bracket),
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _deleteBracket(bracket),
            icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            tooltip: 'Delete',
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
      _showMessage(
        'Enter valid lower bound, upper bound, and charge amount.',
        isError: true,
      );
      return;
    }

    final error = await _chargeRepository.addBracket(
      lowerBound: lowerBound,
      upperBound: upperBound,
      chargeAmount: chargeAmount,
    );

    if (!mounted) {
      return;
    }

    if (error != null) {
      _showMessage(error, isError: true);
      return;
    }

    _lowerBoundController.clear();
    _upperBoundController.clear();
    _chargeAmountController.clear();
    _showMessage('Charge bracket added.');
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
      builder: (_) =>
          _ChargeBracketDialog(repository: _chargeRepository, bracket: bracket),
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
              const Text(
                'Delete Bracket',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Delete the \u20b1${bracket.lowerBound}\u2013\u20b1${bracket.upperBound} charge range? This cannot be undone.',
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
      deleted ? 'Charge bracket deleted.' : 'Unable to delete bracket.',
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
        _errorText = 'Enter valid lower bound, upper bound, and charge amount.';
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
        _errorText = error;
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
            const Text(
              'Edit Charge Bracket',
              style: TextStyle(
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
          const Text(
            'Update the exact lower and upper bounds for this charge range.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _dialogField(
            controller: _lowerBoundController,
            label: 'Lower Bound (PHP)',
            hint: 'e.g. 1000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _dialogField(
            controller: _upperBoundController,
            label: 'Upper Bound (PHP)',
            hint: 'e.g. 1500',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _dialogField(
            controller: _chargeAmountController,
            label: 'Charge Amount (PHP)',
            hint: 'e.g. 25.00',
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
                label: Text(_isSaving ? 'Saving…' : 'Save Changes'),
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
