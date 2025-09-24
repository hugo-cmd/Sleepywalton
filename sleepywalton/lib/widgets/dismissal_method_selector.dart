import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../screens/nfc_management_screen.dart';

class DismissalMethodSelector extends StatefulWidget {
  final DismissalMethod selectedMethod;
  final String? selectedNfcTagId;
  final ValueChanged<DismissalMethod> onMethodChanged;
  final ValueChanged<String?> onNfcTagChanged;

  const DismissalMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.selectedNfcTagId,
    required this.onMethodChanged,
    required this.onNfcTagChanged,
  });

  @override
  State<DismissalMethodSelector> createState() => _DismissalMethodSelectorState();
}

class _DismissalMethodSelectorState extends State<DismissalMethodSelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Standard dismissal option
          _buildMethodOption(
            DismissalMethod.standard,
            'Standard',
            'Tap to dismiss or snooze',
            Icons.touch_app,
          ),
          
          const SizedBox(height: 12),
          
          // NFC dismissal option
          _buildMethodOption(
            DismissalMethod.nfc,
            'NFC Tag Required',
            'Must scan registered NFC tag to dismiss',
            Icons.nfc,
          ),
          
          // NFC tag selection (only shown when NFC method is selected)
          if (widget.selectedMethod == DismissalMethod.nfc) ...[
            const SizedBox(height: 16),
            _buildNfcTagSelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodOption(
    DismissalMethod method,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = widget.selectedMethod == method;
    
    return GestureDetector(
      onTap: () => widget.onMethodChanged(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcTagSelector() {
    final nfcTags = StorageService.getAllNfcTags();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.nfc,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Select NFC Tag',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (nfcTags.isEmpty)
            _buildNoNfcTagsMessage()
          else
            ...nfcTags.map((tag) => _buildNfcTagOption(tag)),
          
          const SizedBox(height: 12),
          
          TextButton.icon(
            onPressed: _addNfcTag,
            icon: const Icon(Icons.add),
            label: const Text('Add NFC Tag'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNfcTagsMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.nfc,
            size: 32,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No NFC tags registered',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add an NFC tag to use this dismissal method',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNfcTagOption(NfcTag tag) {
    final isSelected = widget.selectedNfcTagId == tag.id;
    
    return GestureDetector(
      onTap: () => widget.onNfcTagChanged(tag.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Text(
              tag.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag.nickname,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Used ${tag.usageCount} times',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _addNfcTag() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NfcManagementScreen(),
      ),
    );
  }
}
