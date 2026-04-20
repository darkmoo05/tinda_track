import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/architect_app_bar.dart';
import 'data/party_repository.dart';
import 'widgets/search_input.dart';
import 'widgets/party_health_card.dart';
import 'widgets/party_list_item.dart';

class PartyManagementScreen extends StatefulWidget {
  const PartyManagementScreen({super.key});

  @override
  State<PartyManagementScreen> createState() => _PartyManagementScreenState();
}

class _PartyManagementScreenState extends State<PartyManagementScreen> {
  final PartyRepository _partyRepository = PartyRepository.instance;
  Timer? _searchDebounce;
  String _searchQuery = '';

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
    return Scaffold(
      appBar: ArchitectAppBar(
        title: 'PocketLedger',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          ArchitectSearchInput(onChanged: _onSearchChanged),
          const SizedBox(height: 24),
          ValueListenableBuilder<List<PartyRecord>>(
            valueListenable: _partyRepository.parties,
            builder: (context, parties, child) {
              final total = parties.length;
              final verified = parties.where((p) => p.isVerified).length;
              final rate = total == 0 ? 0.0 : (verified / total) * 100;
              return FutureBuilder<List<PartyActivityRecord>>(
                future: _partyRepository.loadMostActiveParties(limit: 5),
                builder: (context, snapshot) {
                  return PartyHealthHero(
                    totalEntities: total,
                    verificationRate: rate,
                    activeParties: snapshot.data ?? const [],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          _buildListHeader(context),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<PartyRecord>>(
            valueListenable: _partyRepository.parties,
            builder: (context, parties, child) {
              final filteredParties = _applySearch(parties);
              return _buildPartiesList(
                filteredParties,
                hasActiveSearch: _searchQuery.trim().isNotEmpty,
              );
            },
          ),
          const SizedBox(height: 100), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registered Parties',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your customer ecosystem and entity associations.',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ACTIVE ENTITIES',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _onAddParty,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('ADD PARTY'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartiesList(
    List<PartyRecord> parties, {
    required bool hasActiveSearch,
  }) {
    if (parties.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.people_outline_rounded,
              size: 32,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasActiveSearch
                  ? 'No matching parties found'
                  : 'No parties saved yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              hasActiveSearch
                  ? 'Try a different keyword for name, entity ID, account, or description.'
                  : 'This screen now shows only records stored in your local database.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
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
              description: '${party.description} • ${party.accountNumber}',
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

  List<PartyRecord> _applySearch(List<PartyRecord> parties) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<PartyRecord>.of(parties)
        : parties
              .where((party) {
                final searchable = [
                  party.name,
                  party.entityId,
                  party.accountNumber,
                  party.description,
                ].join(' ').toLowerCase();
                return searchable.contains(query);
              })
              .toList(growable: false);

    filtered.sort((a, b) => b.id.compareTo(a.id));
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
              const Text(
                'Delete Party',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${party.name}"? This action cannot be undone.',
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
                  onPressed: () => Navigator.of(ctx).pop(true),
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
                child: const Text('Cancel'),
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
                label: Text(_isSaving ? 'Saving…' : 'Add Party'),
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
