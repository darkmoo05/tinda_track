import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/domain/sync_metadata.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
import '../domain/entities/party.dart';
import '../presentation/providers/party_providers.dart';
import '../widgets/search_input.dart';
import '../widgets/party_list_item.dart';
import '../../../../shared/widgets/tutorial_spotlight.dart';
import '../../../../core/di/database_providers.dart';

String _normalizeAccount(String raw) =>
    raw.replaceAll(RegExp(r'[^0-9]'), '').trim();

class PartyManagementScreen extends ConsumerStatefulWidget {
  const PartyManagementScreen({super.key, this.openDrawer});

  final VoidCallback? openDrawer;

  @override
  ConsumerState<PartyManagementScreen> createState() =>
      _PartyManagementScreenState();
}

enum _PartiesOnboardingStep {
  inactive,
  searchField,
  addPerson,
  completed,
}

class _PartyManagementScreenState extends ConsumerState<PartyManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String _currentSort = 'newest'; // 'newest', 'oldest', 'name'

  _PartiesOnboardingStep _onboardingStep = _PartiesOnboardingStep.inactive;

  final GlobalKey _searchFieldKey = GlobalKey();
  final GlobalKey _addPersonFABKey = GlobalKey();
  final GlobalKey _addPersonEmptyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    try {
      final appMeta = ref.read(databaseAppMetaDaoProvider);
      final completed = await appMeta.get('tutorial_completed_party_management');
      if (completed != 'true' && mounted) {
        setState(() {
          _onboardingStep = _PartiesOnboardingStep.searchField;
        });
      }
    } catch (_) {}
  }

  Future<void> _completeTutorial() async {
    setState(() {
      _onboardingStep = _PartiesOnboardingStep.completed;
    });
    try {
      final appMeta = ref.read(databaseAppMetaDaoProvider);
      await appMeta.set('tutorial_completed_party_management', 'true');
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 380;
    final parties = ref.watch(partiesStreamProvider).value ?? const <Party>[];
    final hasData = parties.isNotEmpty;
    final scaffold = Scaffold(
      key: _scaffoldKey,
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        onSettingsPressed: widget.openDrawer,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 24,
          vertical: 24,
        ),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          ArchitectSearchInput(
            key: _searchFieldKey,
            hintText: context.l10n.searchByNameAccount,
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 24),
          _buildQuickStatsCard(context),
          const SizedBox(height: 24),
          _buildFilterAndSortRow(context),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final parties =
                  ref.watch(partiesStreamProvider).value ?? const <Party>[];
              final filteredParties = _applyFiltersAndSearch(parties);
              final animationKey = ValueKey(
                '${_currentSort}_${_searchQuery.trim()}_${filteredParties.length}',
              );
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: animationKey,
                  child: _buildPartiesList(
                    filteredParties,
                    hasActiveSearch: _searchQuery.trim().isNotEmpty,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: !hasData
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: Container(
                key: _addPersonFABKey,
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
                    onTap: _onAddParty,
                    borderRadius: BorderRadius.circular(28),
                    child: Tooltip(
                      message: context.l10n.addNewPerson,
                      child: const Center(
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
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

    return Stack(
      children: [
        scaffold,
        if (_onboardingStep == _PartiesOnboardingStep.searchField)
          TutorialSpotlight(
            targetKey: _searchFieldKey,
            title: 'Search Customers & Suppliers',
            description: 'Type a name or phone number here to quickly find existing customer accounts and check their transaction history.',
            onNext: () {
              setState(() {
                _onboardingStep = _PartiesOnboardingStep.addPerson;
              });
            },
            onSkip: _completeTutorial,
            nextLabel: 'Next',
            showNext: true,
            shape: BoxShape.rectangle,
            borderRadius: 12.0,
          ),
        if (_onboardingStep == _PartiesOnboardingStep.addPerson)
          TutorialSpotlight(
            targetKey: hasData ? _addPersonFABKey : _addPersonEmptyKey,
            title: 'Register New Entity',
            description: 'Tap this button to register a new customer or supplier. Keeping account names matches transaction records automatically.',
            onNext: _completeTutorial,
            onSkip: _completeTutorial,
            nextLabel: 'Finish',
            showNext: true,
            shape: hasData ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: hasData ? 28.0 : 14.0,
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ScreenHeaderCard(
      title: context.l10n.yourPeople,
      subtitle: context.l10n.manageCustomersPartners,
    );
  }

  Widget _buildQuickStatsCard(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final parties =
            ref.watch(partiesStreamProvider).value ?? const <Party>[];
        final total = parties.length;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$total ${context.l10n.peopleSaved}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterAndSortRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerRight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkNavyTile : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<String>(
            value: _currentSort,
            items: [
              DropdownMenuItem(
                value: 'newest',
                child: Text(context.l10n.newest),
              ),
              DropdownMenuItem(
                value: 'oldest',
                child: Text(context.l10n.oldest),
              ),
              DropdownMenuItem(
                value: 'name',
                child: Text(context.l10n.name),
              ),
            ],
            onChanged: (v) => setState(() => _currentSort = v ?? 'newest'),
            isDense: true,
            underline: const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildPartiesList(
    List<Party> parties, {
    required bool hasActiveSearch,
  }) {
    final isCompact = MediaQuery.sizeOf(context).width < 360;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (parties.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isCompact ? 20 : 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              hasActiveSearch
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 56,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveSearch
                  ? context.l10n.noMatchingParties
                  : context.l10n.nobodyHereYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? const Color(0xFFF8FAFC) : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveSearch
                  ? context.l10n.tryDifferentKeyword
                  : context.l10n.letAddFirst,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
              ),
            ),
            if (!hasActiveSearch) ...[
              const SizedBox(height: 24),
              Container(
                key: _addPersonEmptyKey,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onAddParty,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.addNewPerson,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: parties
          .map(
            (party) => PartyListItem(
              name: party.name,
              id: party.entityId,
              description: party.description,
              accountNumber: party.accountNumber,
              joinDate: party.joinDate,
              onEdit: () => _onEditParty(party),
              onDelete: () => _onDeleteParty(party),
            ),
          )
          .toList(),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value;
      });
    });
  }

  List<Party> _applyFiltersAndSearch(List<Party> parties) {
    List<Party> filtered = List.from(parties);

    // Apply search
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((party) {
        final searchable = [
          party.name,
          party.entityId,
          party.accountNumber,
          party.description,
        ].join(' ').toLowerCase();
        return searchable.contains(query);
      }).toList();
    }

    // Apply sort
    if (_currentSort == 'newest') {
      filtered.sort((a, b) => b.sync.createdAt.compareTo(a.sync.createdAt));
    } else if (_currentSort == 'oldest') {
      filtered.sort((a, b) => a.sync.createdAt.compareTo(b.sync.createdAt));
    } else if (_currentSort == 'name') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }

  Future<void> _onAddParty() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AddPartyDialog(),
    );
  }

  Future<void> _onEditParty(Party party) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditPartyDialog(party: party),
    );
  }

  Future<void> _onDeleteParty(Party party) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
                  Icons.person_remove_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.deleteParty,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.deletePartyConfirm(party.name),
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
                  onPressed: () => Navigator.of(ctx).pop(false),
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
                  onPressed: () => Navigator.of(ctx).pop(true),
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

    if (confirmed != true || !mounted) return;
    await ref.read(partiesNotifierProvider.notifier).delete(party.id);
  }
}

// ---------------------------------------------------------------------------
// Edit Party Dialog — proper StatefulWidget so async save is safe.
// ---------------------------------------------------------------------------

class _EditPartyDialog extends ConsumerStatefulWidget {
  const _EditPartyDialog({required this.party});

  final Party party;

  @override
  ConsumerState<_EditPartyDialog> createState() => _EditPartyDialogState();
}

class _EditPartyDialogState extends ConsumerState<_EditPartyDialog> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _accountController;
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.party.name);
    _accountController = TextEditingController(
      text: widget.party.accountNumber,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final fullName = _fullNameController.text.trim();
    final accountNumber = _accountController.text.trim();

    if (fullName.isEmpty || accountNumber.isEmpty) {
      setState(() {
        _errorText = 'Please complete full name and account number.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final normalizedAccount = _normalizeAccount(accountNumber);
    final parties = ref.read(partiesStreamProvider).value ?? const <Party>[];
    final duplicate = parties.any(
      (p) =>
          p.id != widget.party.id &&
          _normalizeAccount(p.accountNumber) == normalizedAccount,
    );
    if (duplicate) {
      setState(() {
        _isSaving = false;
        _errorText =
            'Account number may already be in use. Use a different number.';
      });
      return;
    }

    try {
      await ref
          .read(partiesNotifierProvider.notifier)
          .save(
            widget.party.copyWith(
              name: fullName,
              accountNumber: normalizedAccount,
            ),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = 'Unable to save changes. Please try again.';
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.06),
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
                      color: primaryColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Party',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // ── Form ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update the party details below.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dialogField(
                    controller: _fullNameController,
                    label: 'Full Name / Entity',
                    hint: 'Enter party full name',
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    controller: _accountController,
                    label: 'Account Number',
                    hint: 'Enter account number',
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                    primaryColor: primaryColor,
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
            ),
            // ── Actions ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF2563EB) : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    required Color primaryColor,
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
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF475569) : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
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
              borderSide: BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPartyDialog extends ConsumerStatefulWidget {
  const _AddPartyDialog();

  @override
  ConsumerState<_AddPartyDialog> createState() => _AddPartyDialogState();
}

class _AddPartyDialogState extends ConsumerState<_AddPartyDialog> {
  static final DateFormat _joinDateFormat = DateFormat('MMM yyyy');

  late final TextEditingController _fullNameController;
  late final TextEditingController _accountController;
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _accountController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _onAdd() async {
    final fullName = _fullNameController.text.trim();
    final accountNumber = _accountController.text.trim();

    if (fullName.isEmpty || accountNumber.isEmpty) {
      setState(() {
        _errorText = 'Please complete full name and account number.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final normalizedAccount = _normalizeAccount(accountNumber);
    final parties = ref.read(partiesStreamProvider).value ?? const <Party>[];
    final duplicate = parties.any(
      (p) => _normalizeAccount(p.accountNumber) == normalizedAccount,
    );
    if (duplicate) {
      setState(() {
        _isSaving = false;
        _errorText =
            'Account number may already be in use. Use a different number.';
      });
      return;
    }

    final now = DateTime.now();
    final newParty = Party(
      id: '',
      name: fullName,
      accountNumber: normalizedAccount,
      entityId: _buildEntityId(normalizedAccount, parties.length),
      description: 'Newly Registered',
      joinDate: _joinDateFormat.format(now),
      isVerified: true,
      sync: SyncMetadata(
        syncId: '',
        createdAt: now,
        updatedAt: now,
        isDirty: true,
      ),
    );

    try {
      await ref.read(partiesNotifierProvider.notifier).save(newParty);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = 'Unable to add party. Please try again.';
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _buildEntityId(String accountNumber, int currentCount) {
    final digitsOnly = _normalizeAccount(accountNumber);
    final suffix = digitsOnly.length >= 3
        ? digitsOnly.substring(digitsOnly.length - 3)
        : digitsOnly.padLeft(3, '0');
    final sequence = (currentCount + 1).toString().padLeft(3, '0');
    return 'FA-$suffix-$sequence';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkIndigo : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.06),
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
                      color: primaryColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Party',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // ── Form ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a new party record for Active Entities.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dialogField(
                    controller: _fullNameController,
                    label: 'Full Name / Entity',
                    hint: 'Enter party full name',
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    controller: _accountController,
                    label: 'Account Number',
                    hint: 'Enter account number',
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                    primaryColor: primaryColor,
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
            ),
            // ── Actions ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _isSaving
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: _isSaving ? Colors.white.withValues(alpha: 0.12) : null,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _isSaving
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSaving ? null : _onAdd,
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                const SizedBox(width: 8),
                                Text(
                                  _isSaving ? context.l10n.saving : context.l10n.addParty,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    required Color primaryColor,
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
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF475569) : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkNavy : AppColors.surfaceContainerLow,
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
              borderSide: BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
