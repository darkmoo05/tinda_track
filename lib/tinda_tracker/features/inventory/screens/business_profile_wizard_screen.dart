import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/providers/database_providers.dart';
import '../../../../core/sync/sync_orchestrator.dart';
import '../../../../core/sync/sync_result.dart';

class BusinessProfileWizardScreen extends ConsumerStatefulWidget {
  const BusinessProfileWizardScreen({super.key, this.onComplete});

  final VoidCallback? onComplete;

  @override
  ConsumerState<BusinessProfileWizardScreen> createState() =>
      _BusinessProfileWizardScreenState();
}

class _BusinessProfileWizardScreenState
    extends ConsumerState<BusinessProfileWizardScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  String _businessType = 'retail';
  String _currency = 'PHP';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final syncId = const Uuid().v4();
      final deviceId = await ref.read(appMetaDaoProvider).getOrCreateDeviceId();
      final now = DateTime.now().millisecondsSinceEpoch;

      final defaultPrefs = {
        'showRecipes': _businessType == 'food_service',
        'showSerialTracking': ['auto_parts', 'hardware'].contains(_businessType),
        'showMultiLocation': ['auto_parts', 'hardware'].contains(_businessType),
        'showBundles': ['auto_parts', 'hardware'].contains(_businessType),
      };

      final companion = BusinessProfilesCompanion(
        id: Value(const Uuid().v4()),
        syncId: Value(syncId),
        deviceId: Value(deviceId),
        isDeleted: const Value(false),
        isDirty: const Value(true),
        createdAtMs: Value(now),
        updatedAtMs: Value(now),
        businessName: Value(_nameController.text.trim()),
        businessType: Value(_businessType),
        defaultCurrency: Value(_currency),
        preferencesJson: Value(json.encode(defaultPrefs)),
      );

      await ref
          .read(tindaTrackerDaoProvider)
          .businessProfiles
          .upsertLocal(companion);

      // Trigger sync in the background so it pushes immediately
      unawaited(
        ref.read(syncOrchestratorProvider).runOnce().catchError((_) => <SyncResult>[]),
      );

      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _next() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a business name')),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else {
      _saveProfile();
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGlow = Color(0xFF00E5FF);
    const secondaryGlow = Color(0xFF651FFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryGlow.withValues(alpha: 0.08),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: secondaryGlow.withValues(alpha: 0.08),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      'Store Setup',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure your business preferences in seconds.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Progress indicators
                    Row(
                      children: List.generate(3, (index) {
                        final isActive = index <= _currentStep;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(
                              right: index < 2 ? 8.0 : 0.0,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? primaryGlow
                                  : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Step Contents
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryGlow,
                              ),
                            )
                          : SingleChildScrollView(
                              child: _buildStepContent(),
                            ),
                    ),

                    // Bottom navigation buttons
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentStep > 0)
                            TextButton(
                              onPressed: _prev,
                              child: Text(
                                'BACK',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGlow,
                              foregroundColor: const Color(0xFF0F0F12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _currentStep == 2 ? 'FINISH' : 'NEXT',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is your store name?',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will appear on your receipts and dashboard.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Aling Nena’s Store',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                prefixIcon: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white30,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your business name';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Select Currency',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              dropdownColor: const Color(0xFF1E1E24),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'PHP', child: Text('Philippine Peso (₱ / PHP)')),
                DropdownMenuItem(value: 'USD', child: Text(r'US Dollar ($ / USD)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _currency = val;
                  });
                }
              },
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your industry template',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We customize feature modules based on your business type.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            _buildTypeCard(
              type: 'retail',
              title: 'Sari-Sari / Retail',
              desc: 'Simple stock, POS sales, and customer credit (utang). Hides complex raw ingredients and serial numbers.',
              icon: Icons.storefront_rounded,
            ),
            _buildTypeCard(
              type: 'food_service',
              title: 'Carinderia / Food Service',
              desc: 'Perishable ingredients, dish recipes / Bill of Materials (BOM), auto-deducting stock, and waste reports.',
              icon: Icons.restaurant_rounded,
            ),
            _buildTypeCard(
              type: 'auto_parts',
              title: 'Auto Shop / Services',
              desc: 'Tracking parts by serial numbers, custom compatibility fields, multi-location storage, and kits/bundles.',
              icon: Icons.build_rounded,
            ),
            _buildTypeCard(
              type: 'hardware',
              title: 'Hardware Store',
              desc: 'Supports size/dimensions attributes, multi-shelf locations, bulk conversions, and serial/lot tracking.',
              icon: Icons.construction_rounded,
            ),
            _buildTypeCard(
              type: 'marketplace',
              title: 'Public Market Stall',
              desc: 'Optimized for quick weight conversions (kilo/grams) and high-speed sales entries.',
              icon: Icons.shopping_basket_rounded,
            ),
            _buildTypeCard(
              type: 'general',
              title: 'General Inventory',
              desc: 'Standard inventory with shelf locations, category groupings, and reorder levels.',
              icon: Icons.inventory_2_rounded,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm details',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Store Name', _nameController.text),
                  const Divider(color: Colors.white10, height: 24),
                  _buildSummaryRow('Currency', _currency),
                  const Divider(color: Colors.white10, height: 24),
                  _buildSummaryRow('Industry Template', _templateName(_businessType)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF00E5FF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can change these configuration flags anytime from Store Settings.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTypeCard({
    required String type,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    final isSelected = _businessType == type;
    const accent = Color(0xFF00E5FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _businessType = type;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.06),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? accent : Colors.white54,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.45),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white30,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _templateName(String type) {
    switch (type) {
      case 'retail':
        return 'Sari-Sari / Retail';
      case 'food_service':
        return 'Carinderia / Food Service';
      case 'auto_parts':
        return 'Auto Shop';
      case 'hardware':
        return 'Hardware';
      case 'marketplace':
        return 'Public Market';
      default:
        return 'General / Other';
    }
  }
}
