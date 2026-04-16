import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/architect_card.dart';

enum PartyStatus { verified, pending }

class PartyListItem extends StatelessWidget {
  final String name;
  final String joinDate;
  final String id;
  final String description;
  final PartyStatus status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PartyListItem({
    super.key,
    required this.name,
    required this.joinDate,
    required this.id,
    required this.description,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Text(
                    name[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(status),
                        ],
                      ),
                      Text(
                        'Joined $joinDate',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(Icons.edit_outlined, onEdit),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      Icons.delete_outline_rounded,
                      onDelete,
                      color: Colors.red[100],
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PartyStatus status) {
    final isVerified = status == PartyStatus.verified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isVerified ? 'VERIFIED' : 'PENDING DOCS',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onTap, {
    Color? color,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? const Color(0xFFF3F3F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
