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

String _normalizeAccount(String raw) =>
    raw.replaceAll(RegExp(r'[^0-9]'), '').trim();

class PartyManagementScreen extends ConsumerStatefulWidget {
  const PartyManagementScreen({super.key, this.openDrawer});

  final VoidCallback? openDrawer;

  @override
  ConsumerState<PartyManagementScreen> createState() =>
      _PartyManagementScreenState();
}

class _PartyManagementScreenState extends ConsumerState<PartyManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String _currentFilter = 'all'; // 'all', 'verified'
  String _currentSort = 'newest'; // 'newest', 'oldest', 'name'

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 380;
    final isVeryCompact = MediaQuery.of(context).size.width < 340;
    return Scaffold(
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
                '${_currentFilter}_${_currentSort}_${_searchQuery.trim()}_${filteredParties.length}',
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
      floatingActionButton: isVeryCompact
          ? FloatingActionButton(
              heroTag: null,
              onPressed: _onAddParty,
              tooltip: context.l10n.addNewPerson,
              child: const Icon(Icons.add_rounded),
            )
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: _onAddParty,
              label: Text(
                context.l10n.addNewPerson,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              icon: const Icon(Icons.add_rounded),
            ),
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
        final verified = parties.where((p) => p.isVerified).length;
        final percent = total == 0
            ? 0
            : (verified / total * 100).toStringAsFixed(1);
        final pending = total - verified;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatPill(
                    context,
                    Icons.people_alt_rounded,
                    '$total ${context.l10n.peopleSaved}',
                    AppColors.surfaceContainerLow,
                    AppColors.onSurface,
                  ),
                  _buildStatPill(
                    context,
                    Icons.verified_rounded,
                    '$verified ${context.l10n.verified} ($percent%)',
                    AppColors.secondary.withValues(alpha: 0.12),
                    AppColors.secondary,
                  ),
                ],
              ),
              if (pending > 0) ...[
                const SizedBox(height: 8),
                _buildStatPill(
                  context,
                  Icons.schedule_rounded,
                  '$pending ${context.l10n.waitingToVerify}',
                  Colors.orange.withValues(alpha: 0.12),
                  Colors.orange.shade800,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatPill(
    BuildContext context,
    IconData icon,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context.l10n.all,
                _currentFilter == 'all',
                () => setState(() => _currentFilter = 'all'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                '✓ ${context.l10n.verified}',
                _currentFilter == 'verified',
                () => setState(() => _currentFilter = 'verified'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
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
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.14),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.35)
            : AppColors.outlineVariant.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.primary : AppColors.onSurface,
      ),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPartiesList(
    List<Party> parties, {
    required bool hasActiveSearch,
  }) {
    final isCompact = MediaQuery.sizeOf(context).width < 360;
    if (parties.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isCompact ? 20 : 32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              hasActiveSearch
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 56,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveSearch
                  ? context.l10n.noMatchingParties
                  : context.l10n.nobodyHereYet,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveSearch
                  ? context.l10n.tryDifferentKeyword
                  : context.l10n.letAddFirst,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (!hasActiveSearch) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _onAddParty,
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.addNewPerson),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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
              status: party.isVerified
                  ? PartyStatus.verified
                  : PartyStatus.pending,
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
    // Apply filter first
    List<Party> filtered = List.from(parties);

    if (_currentFilter == 'verified') {
      filtered = filtered.where((p) => p.isVerified).toList();
    }

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
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
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
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Party',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
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
                  const Text(
                    'Update the party details below.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dialogField(
                    controller: _fullNameController,
                    label: 'Full Name / Entity',
                    hint: 'Enter party full name',
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    controller: _accountController,
                    label: 'Account Number',
                    hint: 'Enter account number',
                    keyboardType: TextInputType.number,
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
                        side: const BorderSide(color: AppColors.outlineVariant),
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
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
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
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
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
                color: AppColors.secondary.withValues(alpha: 0.06),
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
                      color: AppColors.secondary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Party',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
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
                  const Text(
                    'Create a new party record for Active Entities.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dialogField(
                    controller: _fullNameController,
                    label: 'Full Name / Entity',
                    hint: 'Enter party full name',
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    controller: _accountController,
                    label: 'Account Number',
                    hint: 'Enter account number',
                    keyboardType: TextInputType.number,
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
                        side: const BorderSide(color: AppColors.outlineVariant),
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
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _onAdd,
                      icon: _isSaving
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
                      label: Text(
                        _isSaving ? context.l10n.saving : context.l10n.addParty,
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
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
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
