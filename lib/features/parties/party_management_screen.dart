import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/architect_app_bar.dart';
import 'widgets/search_input.dart';
import 'widgets/party_health_card.dart';
import 'widgets/verification_warning_card.dart';
import 'widgets/party_list_item.dart';

class PartyManagementScreen extends StatelessWidget {
  const PartyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ArchitectAppBar(
        title: 'Financial Architect',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          const ArchitectSearchInput(),
          const SizedBox(height: 24),
          const PartyHealthHero(
            totalEntities: 124,
            verificationRate: 98.2,
          ),
          const SizedBox(height: 24),
          VerificationWarningCard(
            count: 12,
            onReview: () {},
          ),
          const SizedBox(height: 32),
          _buildListHeader(context),
          const SizedBox(height: 16),
          _buildPartiesList(),
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
          'PARTY DETAILS & STATUS',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          'ACTIONS',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildPartiesList() {
    return Column(
      children: [
        PartyListItem(
          name: 'Acme Global Holdings',
          id: 'FA-8829-001',
          description: 'Corporate Primary',
          joinDate: 'Oct 2023',
          status: PartyStatus.verified,
          onEdit: () {},
          onDelete: () {},
        ),
        PartyListItem(
          name: 'Julian Rivera',
          id: 'FA-1102-044',
          description: 'Private Wealth',
          joinDate: 'Jan 2024',
          status: PartyStatus.pending,
          onEdit: () {},
          onDelete: () {},
        ),
        PartyListItem(
          name: 'Terra Labs ESG',
          id: 'FA-4402-992',
          description: 'Institutional Trust',
          joinDate: 'Dec 2022',
          status: PartyStatus.verified,
          onEdit: () {},
          onDelete: () {},
        ),
      ],
    );
  }
}
