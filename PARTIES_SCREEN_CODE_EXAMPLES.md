# PARTIES SCREEN - Implementation Code Samples

## Sample 1: Simple & Friendly - Code Structure

### 1. Updated Localization Strings
```dart
// In app_en.arb
{
  "yourPeople": "Your People",
  "manageCustomersPartners": "Manage customers & partners you work with",
  "peopleStats": "{total} people saved • {verified} verified ({percent}%)",
  "waitingVerify": "{count} waiting to verify",
  "quickStats": "Quick Stats",
  "addNewPerson": "Add New Person",
  "searchByNameAccount": "Search by name or account number...",
  "allPeople": "All People",
  "verifiedPeople": "Verified",
  "pendingPeople": "Pending",
  "joinedDate": "Joined {date}",
  "theirAccount": "Account: {account}",
  "statusVerified": "Verified ✓",
  "statusPending": "Waiting for Verification",
  "viewHistory": "View History",
  "nobodyHereYet": "Nobody Here Yet! 👋",
  "letAddFirst": "Your contact list is empty. Let's add your first customer or business partner."
}
```

### 2. Updated Main Screen Widget Structure
```dart
class PartyManagementScreen extends StatefulWidget {
  // ... existing code ...
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppSideDrawer(),
      appBar: ArchitectAppBar(
        title: context.l10n.yourPeople, // Changed from appTitle
        onSettingsPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          ArchitectSearchInput(
            hintText: context.l10n.searchByNameAccount,
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 24),
          
          // SIMPLIFIED: Quick Stats Card instead of Complex Chart
          _buildQuickStatsCard(context),
          
          const SizedBox(height: 24),
          
          // NEW: Filter Tabs
          _buildFilterTabs(context),
          
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
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddParty,
        label: Text(context.l10n.addNewPerson),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
  
  // NEW: Simplified quick stats card
  Widget _buildQuickStatsCard(BuildContext context) {
    return ValueListenableBuilder<List<PartyRecord>>(
      valueListenable: _partyRepository.parties,
      builder: (context, parties, child) {
        final total = parties.length;
        final verified = parties.where((p) => p.isVerified).length;
        final percent = total == 0 ? 0 : (verified / total * 100).toStringAsFixed(1);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '👥 $total ${context.l10n.peopleSaved}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '✓ $verified ${context.l10n.verified} ($percent%)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (pending > 0)
                Text(
                  '⏳ $pending ${context.l10n.waitingVerify}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  // NEW: Filter tabs
  Widget _buildFilterTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context.l10n.allPeople,
            _currentFilter == 'all',
            () => setState(() => _currentFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            '✓ ${context.l10n.verifiedPeople}',
            _currentFilter == 'verified',
            () => setState(() => _currentFilter = 'verified'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            '⏳ ${context.l10n.pendingPeople}',
            _currentFilter == 'pending',
            () => setState(() => _currentFilter = 'pending'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
```

### 3. Updated Party List Item Widget
```dart
class PartyListItem extends StatelessWidget {
  // ... existing parameters ...
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ArchitectCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar with initials
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Status Badge (IMPROVED)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == PartyStatus.verified
                                  ? AppColors.secondary.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status == PartyStatus.verified
                                  ? '✓ ${context.l10n.statusVerified}'
                                  : '⏳ ${context.l10n.statusPending}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: status == PartyStatus.verified
                                    ? AppColors.secondary
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.joinedDate(joinDate),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.theirAccount(id),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons (IMPROVED)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(context.l10n.edit),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(context.l10n.delete),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {}, // onViewHistory
                  icon: const Icon(Icons.history, size: 16),
                  label: Text(context.l10n.history),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Improved Empty State
```dart
Widget _buildEmptyState(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: Column(
      children: [
        const Text('👋', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          context.l10n.nobodyHereYet,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.letAddFirst,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _onAddParty,
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.addNewPerson),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

## Sample 2: Business Professional - Code Structure

### 1. Table-Style List Widget
```dart
Widget _buildTableHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 40,
          child: Checkbox(
            value: _allSelected,
            onChanged: (v) => setState(() => _allSelected = v ?? false),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            context.l10n.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            context.l10n.account,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            context.l10n.status,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTableRow(
  BuildContext context,
  PartyRecord party,
  bool isSelected,
  ValueChanged<bool> onSelect,
) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: AppColors.outlineVariant),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: isSelected,
              onChanged: (v) => onSelect(v ?? false),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(party.name, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              party.accountNumber.substring(0, 6) + '***',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: party.isVerified
                        ? AppColors.secondary
                        : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  party.isVerified ? '✓' : '⏳',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

### 2. Dashboard Stats Section
```dart
Widget _buildDashboardStats(BuildContext context) {
  return ValueListenableBuilder<List<PartyRecord>>(
    valueListenable: _partyRepository.parties,
    builder: (context, parties, child) {
      final total = parties.length;
      final verified = parties.where((p) => p.isVerified).length;
      final pending = total - verified;
      
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.partiesManagement,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Last Updated: 2 hours ago',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatPill(
                  context,
                  '$total',
                  context.l10n.total,
                ),
                _buildStatPill(
                  context,
                  '$verified',
                  context.l10n.verified,
                ),
                _buildStatPill(
                  context,
                  '$pending',
                  context.l10n.pending,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildStatPill(BuildContext context, String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    ],
  );
}
```

### 3. Sort & Filter Controls
```dart
Widget _buildControlsRow(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Text(
            '${context.l10n.show}: ',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _filterOption,
            items: [
              DropdownMenuItem(value: 'all', child: Text(context.l10n.all)),
              DropdownMenuItem(
                value: 'verified',
                child: Text(context.l10n.verified),
              ),
              DropdownMenuItem(
                value: 'pending',
                child: Text(context.l10n.pending),
              ),
            ],
            onChanged: (v) => setState(() => _filterOption = v ?? 'all'),
          ),
        ],
      ),
      Row(
        children: [
          Text(
            '${context.l10n.sort}: ',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortOption,
            items: [
              DropdownMenuItem(value: 'newest', child: Text(context.l10n.newest)),
              DropdownMenuItem(value: 'oldest', child: Text(context.l10n.oldest)),
              DropdownMenuItem(value: 'name', child: Text(context.l10n.name)),
            ],
            onChanged: (v) => setState(() => _sortOption = v ?? 'newest'),
          ),
        ],
      ),
    ],
  );
}
```

---

## Sample 3: Guided & Progressive - Code Structure

### 1. Onboarding Tooltip Widget
```dart
class OnboardingTooltip extends StatelessWidget {
  final VoidCallback onDismiss;
  
  const OnboardingTooltip({
    required this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip: Add your regular customers',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'and suppliers here. We\'ll help verify them!',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}
```

### 2. Onboarding Progress Card
```dart
class OnboardingProgressCard extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final VoidCallback onContinue;
  
  const OnboardingProgressCard({
    required this.completedSteps,
    required this.totalSteps,
    required this.onContinue,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = completedSteps / totalSteps;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                context.l10n.gettingStarted,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepItem(context, 1, 'Add a person', true),
          const SizedBox(height: 8),
          _buildStepItem(context, 2, 'Enter their account', completedSteps >= 2),
          const SizedBox(height: 8),
          _buildStepItem(
            context,
            3,
            'Verify information',
            completedSteps >= 3,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.outlineVariant.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: Text(context.l10n.continueText),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepItem(
    BuildContext context,
    int stepNumber,
    String stepText,
    bool completed,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? AppColors.secondary : AppColors.outlineVariant,
          ),
          child: Center(
            child: Text(
              completed ? '✓' : '$stepNumber',
              style: TextStyle(
                color: completed ? Colors.white : AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          stepText,
          style: TextStyle(
            fontSize: 14,
            color: completed ? AppColors.secondary : AppColors.onSurface,
            fontWeight: completed ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        if (completed)
          const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
      ],
    );
  }
}
```

### 3. Add Party Wizard
```dart
class AddPartyWizard extends StatefulWidget {
  final Function(String name, String account, String type) onComplete;
  
  const AddPartyWizard({required this.onComplete});
  
  @override
  State<AddPartyWizard> createState() => _AddPartyWizardState();
}

class _AddPartyWizardState extends State<AddPartyWizard> {
  int _currentStep = 0;
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  String _selectedType = 'customer';
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgressBar(),
            const SizedBox(height: 24),
            _buildStepContent(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_currentStep + 1} of 3: ${_getStepTitle()}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s their name?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter full name',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.info_outline, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ⓘ At least 2 characters',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What type?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _buildRadioOption('Customer', 'customer'),
            _buildRadioOption('Supplier', 'supplier'),
            _buildRadioOption('Other', 'other'),
            const SizedBox(height: 12),
            Text(
              'ℹ This helps us organize your contacts',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Their account number',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountController,
              decoration: InputDecoration(
                hintText: 'e.g., 09123456789',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ⓘ We\'ll verify this is valid',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildRadioOption(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedType,
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _currentStep > 0
              ? () => setState(() => _currentStep--)
              : null,
          child: const Text('Back'),
        ),
        if (_currentStep > 0)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip for now'),
          ),
        ElevatedButton(
          onPressed: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              widget.onComplete(
                _nameController.text,
                _accountController.text,
                _selectedType,
              );
              Navigator.pop(context);
            }
          },
          child: Text(_currentStep == 2 ? 'Complete' : 'Next'),
        ),
      ],
    );
  }
  
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Type';
      case 2:
        return 'Account';
      default:
        return '';
    }
  }
}
```

---

## Testing Checklist for Each Sample

### Sample 1 - Simple & Friendly
- [ ] Empty state displays correctly with emoji
- [ ] Quick stats update when parties added/removed
- [ ] Filter tabs work (All / Verified / Pending)
- [ ] Status badges show correct icon & color
- [ ] Search works with name, account, description
- [ ] Delete confirmation dialog appears
- [ ] Edit dialog works
- [ ] Responsive on mobile (stack buttons)

### Sample 2 - Business Professional  
- [ ] Table header sticky on scroll
- [ ] Checkbox selection works
- [ ] Batch delete button appears when selected
- [ ] Sort dropdown changes order
- [ ] Filter dropdown filters correctly
- [ ] Stats update in real-time
- [ ] Account number masked properly
- [ ] Verification queue section displays

### Sample 3 - Guided & Progressive
- [ ] Onboarding tooltip shows on first visit
- [ ] Progress card shows correct step count
- [ ] Wizard steps work correctly
- [ ] Step validation prevents skipping required fields
- [ ] Cancel/Skip buttons work
- [ ] Empty state shows dual options (add / import)
- [ ] Verification explainer modal works
- [ ] Tooltips appear on hover/focus

---

## Migration Path from Current to Sample

**Step 1**: Update localization strings (copy from samples above)
**Step 2**: Replace `PartyManagementScreen` build method
**Step 3**: Update `PartyListItem` widget
**Step 4**: Update `PartyHealthCard` or replace with quick stats
**Step 5**: Add filter chips / tabs
**Step 6**: Test on multiple devices
**Step 7**: Add Sample 2 or 3 features progressively

Good luck with implementation! 🚀
