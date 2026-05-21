import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import '../data/inventory_repository.dart';
import '../data/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final TtProduct? existing;

  const AddProductScreen({super.key, this.existing});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _sellCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _reorderCtrl = TextEditingController();
  bool _isActive = true;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.existing!;
      _nameCtrl.text = p.name;
      _skuCtrl.text = p.sku;
      _descCtrl.text = p.description;
      _categoryCtrl.text = p.category;
      _unitCtrl.text = p.unit;
      _costCtrl.text = p.costPrice.toStringAsFixed(2);
      _sellCtrl.text = p.sellingPrice.toStringAsFixed(2);
      _stockCtrl.text = p.stockQuantity.toString();
      _reorderCtrl.text = p.reorderPoint.toString();
      _isActive = p.isActive;
    } else {
      _categoryCtrl.text = 'General';
      _unitCtrl.text = 'pcs';
      _stockCtrl.text = '0';
      _reorderCtrl.text = '5';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _unitCtrl.dispose();
    _costCtrl.dispose();
    _sellCtrl.dispose();
    _stockCtrl.dispose();
    _reorderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await InventoryRepository.instance.updateProduct(widget.existing!.id, {
          'name': _nameCtrl.text.trim(),
          'sku': _skuCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'category': _categoryCtrl.text.trim(),
          'unit': _unitCtrl.text.trim(),
          'costPrice': double.tryParse(_costCtrl.text) ?? 0,
          'sellingPrice': double.parse(_sellCtrl.text),
          'reorderPoint': int.tryParse(_reorderCtrl.text) ?? 0,
          'isActive': _isActive,
        });
      } else {
        final product = TtProduct(
          id: '',
          name: _nameCtrl.text.trim(),
          sku: _skuCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          unit: _unitCtrl.text.trim(),
          costPrice: double.tryParse(_costCtrl.text) ?? 0,
          sellingPrice: double.parse(_sellCtrl.text),
          stockQuantity: int.tryParse(_stockCtrl.text) ?? 0,
          reorderPoint: int.tryParse(_reorderCtrl.text) ?? 0,
          isActive: _isActive,
        );
        await InventoryRepository.instance.createProduct(product);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          _isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Basic Info'),
              _FormField(
                controller: _nameCtrl,
                label: 'Product Name',
                required: true,
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _skuCtrl,
                label: 'SKU',
                required: true,
                hint: 'e.g. RICE-5KG-001',
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _descCtrl,
                label: 'Description',
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Categorization'),
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      controller: _categoryCtrl,
                      label: 'Category',
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      controller: _unitCtrl,
                      label: 'Unit',
                      required: true,
                      hint: 'pcs, kg, L',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _SectionLabel('Pricing'),
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      controller: _costCtrl,
                      label: 'Cost Price (₱)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      controller: _sellCtrl,
                      label: 'Selling Price (₱)',
                      required: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _SectionLabel('Stock'),
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      controller: _stockCtrl,
                      label: _isEdit ? 'Current Stock' : 'Initial Stock',
                      keyboardType: TextInputType.number,
                      enabled: !_isEdit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      controller: _reorderCtrl,
                      label: 'Low Stock Alert At',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Active (visible in POS)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                value: _isActive,
                activeColor: AppColors.secondary,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Save Changes' : 'Add Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;

  const _FormField({
    required this.controller,
    required this.label,
    this.required = false,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.surfaceContainerHigh,
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
          : null,
    );
  }
}
