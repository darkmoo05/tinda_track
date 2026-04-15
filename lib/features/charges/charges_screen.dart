import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/architect_app_bar.dart';

class ChargesScreen extends StatefulWidget {
  const ChargesScreen({super.key});

  @override
  State<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends State<ChargesScreen> {
  final _lowerBoundController = TextEditingController();
  final _chargeAmountController = TextEditingController();

  final List<_ChargeBracket> _brackets = [
    _ChargeBracket(lower: 1, upper: 500, charge: 10.00),
    _ChargeBracket(lower: 501, upper: 1000, charge: 15.00),
    _ChargeBracket(lower: 1001, upper: 5000, charge: 20.00),
  ];

  @override
  void dispose() {
    _lowerBoundController.dispose();
    _chargeAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ArchitectAppBar(title: 'Financial Architect'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildPageHeader(context),
          const SizedBox(height: 24),
          _buildAddBracketCard(context),
          const SizedBox(height: 24),
          _buildActiveBracketsSection(context),
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

  Widget _buildActiveBracketsSection(BuildContext context) {
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
                'Total: ${_brackets.length} Brackets',
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
        ...List.generate(_brackets.length, (i) {
          final b = _brackets[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBracketTile(context, b, i),
          );
        }),
      ],
    );
  }

  Widget _buildBracketTile(
    BuildContext context,
    _ChargeBracket bracket,
    int index,
  ) {
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
                  '${bracket.lower} - ${bracket.upper} PHP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Charge: ${bracket.charge.toStringAsFixed(2)} PHP',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editBracket(index),
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _deleteBracket(index),
            icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  void _addBracket() {
    final lower = int.tryParse(_lowerBoundController.text);
    final charge = double.tryParse(_chargeAmountController.text);
    if (lower == null || charge == null) return;
    setState(() {
      final upper = lower + 499;
      _brackets.add(_ChargeBracket(lower: lower, upper: upper, charge: charge));
      _lowerBoundController.clear();
      _chargeAmountController.clear();
    });
  }

  void _editBracket(int index) {
    // Placeholder for edit action
  }

  void _deleteBracket(int index) {
    setState(() => _brackets.removeAt(index));
  }
}

class _ChargeBracket {
  final int lower;
  final int upper;
  final double charge;
  _ChargeBracket({
    required this.lower,
    required this.upper,
    required this.charge,
  });
}
