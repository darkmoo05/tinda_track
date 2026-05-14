import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/architect_app_bar.dart';
import '../../shared/widgets/app_side_drawer.dart';
import '../../shared/widgets/screen_header_card.dart';
import 'data/party_repository.dart';
import 'widgets/search_input.dart';
import 'widgets/party_list_item.dart';

class PartyManagementScreen extends StatefulWidget {
  const PartyManagementScreen({super.key});

  @override
  State<PartyManagementScreen> createState() => _PartyManagementScreenState();
}

class _PartyManagementScreenState extends State<PartyManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PartyRepository _partyRepository = PartyRepository.instance;
  Timer? _searchDebounce;
  String _searchQuery = '';
  String _currentFilter = 'all'; // 'all', 'verified', 'pending'
  String _currentSort = 'newest'; // 'newest', 'oldest', 'name'

  @override
  void initState() {
    super.initState();
    _partyRepository.ensureLoaded();
  }

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
      drawer: const AppSideDrawer(),
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
          ValueListenableBuilder<List<PartyRecord>>(
            valueListenable: _partyRepository.parties,
            builder: (context, parties, child) {
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
              heroTag: 'partyManagementFab',
              onPressed: _onAddParty,
              tooltip: context.l10n.addNewPerson,
              child: const Icon(Icons.add_rounded),
            )
          : FloatingActionButton.extended(
              heroTag: 'partyManagementFab',
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
    return ValueListenableBuilder<List<PartyRecord>>(
      valueListenable: _partyRepository.parties,
      builder: (context, parties, child) {
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
              const SizedBox(width: 8),
              _buildFilterChip(
                '⏳ ${context.l10n.pending}',
                _currentFilter == 'pending',
                () => setState(() => _currentFilter = 'pending'),
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
    List<PartyRecord> parties, {
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

  List<PartyRecord> _applyFiltersAndSearch(List<PartyRecord> parties) {
    // Apply filter first
    List<PartyRecord> filtered = List.from(parties);

    if (_currentFilter == 'verified') {
      filtered = filtered.where((p) => p.isVerified).toList();
    } else if (_currentFilter == 'pending') {
      filtered = filtered.where((p) => !p.isVerified).toList();
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
      filtered.sort((a, b) => b.id.compareTo(a.id));
    } else if (_currentSort == 'oldest') {
      filtered.sort((a, b) => a.id.compareTo(b.id));
    } else if (_currentSort == 'name') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }

  Future<void> _onAddParty() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddPartyDialog(repository: _partyRepository),
    );
  }

  Future<void> _onEditParty(PartyRecord party) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _EditPartyDialog(party: party, repository: _partyRepository),
    );
  }

  Future<void> _onDeleteParty(PartyRecord party) async {
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
    await _partyRepository.deleteParty(party.id);
  }
}

// ---------------------------------------------------------------------------
// Edit Party Dialog — proper StatefulWidget so async save is safe.
// ---------------------------------------------------------------------------

class _EditPartyDialog extends StatefulWidget {
  const _EditPartyDialog({required this.party, required this.repository});

  final PartyRecord party;
  final PartyRepository repository;

  @override
  State<_EditPartyDialog> createState() => _EditPartyDialogState();
}

class _EditPartyDialogState extends State<_EditPartyDialog> {
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

    final bool updated;
    try {
      updated = await widget.repository.updateParty(
        widget.party.id,
        fullName: fullName,
        accountNumber: accountNumber,
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

    if (!updated) {
      setState(() {
        _isSaving = false;
        _errorText =
            'Account number may already be in use. Use a different number.';
      });
      return;
    }

    Navigator.of(context).pop();
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Update the party details below.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
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

class _AddPartyDialog extends StatefulWidget {
  const _AddPartyDialog({required this.repository});

  final PartyRepository repository;

  @override
  State<_AddPartyDialog> createState() => _AddPartyDialogState();
}

class _AddPartyDialogState extends State<_AddPartyDialog> {
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

    final bool added;
    try {
      added = await widget.repository.registerParty(
        fullName: fullName,
        accountNumber: accountNumber,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = 'Unable to add party. Please try again.';
      });
      return;
    }

    if (!mounted) return;

    if (!added) {
      setState(() {
        _isSaving = false;
        _errorText =
            'Account number may already be in use. Use a different number.';
      });
      return;
    }

    Navigator.of(context).pop();
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
          color: AppColors.secondary.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Create a new party record for Active Entities.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
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
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
