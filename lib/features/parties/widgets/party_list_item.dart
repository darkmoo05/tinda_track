import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/l10n_extension.dart';
import '../../../shared/widgets/architect_card.dart';

enum PartyStatus { verified, pending }

class PartyListItem extends StatelessWidget {
  final String name;
  final String joinDate;
  final String id;
  final String description;
  final String accountNumber;
  final PartyStatus status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PartyListItem({
    super.key,
    required this.name,
    required this.joinDate,
    required this.id,
    required this.description,
    required this.accountNumber,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 360;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ArchitectCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _buildStatusBadge(context, status),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.joinedDate(joinDate),
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.theirAccount(accountNumber),
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: isCompact
                      ? OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(context.l10n.edit),
                        )
                      : OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text(context.l10n.edit),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: isCompact
                      ? OutlinedButton(
                          onPressed: onDelete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(context.l10n.delete),
                        )
                      : OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: Text(context.l10n.delete),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, PartyStatus status) {
    final isVerified = status == PartyStatus.verified;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 168),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isVerified
              ? AppColors.secondary.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
              size: 12,
              color: isVerified ? AppColors.secondary : Colors.orange,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                isVerified
                    ? context.l10n.statusVerified
                    : context.l10n.statusPending,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isVerified ? AppColors.secondary : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
