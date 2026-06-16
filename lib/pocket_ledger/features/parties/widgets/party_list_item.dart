import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_card.dart';

class PartyListItem extends StatelessWidget {
  final String name;
  final String joinDate;
  final String id;
  final String description;
  final String accountNumber;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PartyListItem({
    super.key,
    required this.name,
    required this.joinDate,
    required this.id,
    required this.description,
    required this.accountNumber,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final errorColor = isDark ? const Color(0xFFF87171) : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ArchitectCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: primaryColor.withValues(alpha: 0.12),
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.theirAccount(accountNumber),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.joinedDate(joinDate),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty && description != 'Newly Registered') ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    backgroundColor: primaryColor.withValues(alpha: 0.08),
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  tooltip: context.l10n.edit,
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: errorColor.withValues(alpha: 0.08),
                    foregroundColor: errorColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.delete_rounded, size: 14),
                  tooltip: context.l10n.delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
