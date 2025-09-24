import 'package:flutter/material.dart';
import '../models/models.dart';

class NfcTagCard extends StatelessWidget {
  final NfcTag tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NfcTagCard({
    super.key,
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTypeColor(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              tag.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          tag.nickname,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTypeDisplayName(),
              style: TextStyle(
                color: _getTypeColor(context),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Used ${tag.usageCount} times',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              'Last used: ${_formatLastUsed()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }

  String _getTypeDisplayName() {
    switch (tag.type) {
      case NfcTagType.wakeUp:
        return 'Wake Up Tag';
      case NfcTagType.sleep:
        return 'Sleep Tag';
      case NfcTagType.custom:
        return 'Custom Tag';
    }
  }

  Color _getTypeColor(BuildContext context) {
    switch (tag.type) {
      case NfcTagType.wakeUp:
        return Colors.orange;
      case NfcTagType.sleep:
        return Colors.blue;
      case NfcTagType.custom:
        return Colors.green;
    }
  }

  String _formatLastUsed() {
    final now = DateTime.now();
    final difference = now.difference(tag.lastUsed);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
