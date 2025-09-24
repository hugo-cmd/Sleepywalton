import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart' as nfc_manager;
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/nfc_tag_card.dart';
import 'add_nfc_tag_screen.dart';

class NfcManagementScreen extends ConsumerStatefulWidget {
  const NfcManagementScreen({super.key});

  @override
  ConsumerState<NfcManagementScreen> createState() => _NfcManagementScreenState();
}

class _NfcManagementScreenState extends ConsumerState<NfcManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final nfcTags = StorageService.getAllNfcTags();
    
    // Check if NFC is available
    return FutureBuilder<bool>(
      future: _checkNfcAvailability(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final isNfcAvailable = snapshot.data ?? false;
        
        if (!isNfcAvailable) {
          return _buildNfcNotAvailableScreen();
        }
        
        return _buildNfcManagementContent(nfcTags);
      },
    );
  }

  Future<bool> _checkNfcAvailability() async {
    try {
      return await nfc_manager.NfcManager.instance.isAvailable();
    } catch (e) {
      return false;
    }
  }

  Widget _buildNfcNotAvailableScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Tags'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nfc,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'NFC Not Available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'NFC is not available on this device.\nThis feature requires a mobile device with NFC support.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNfcManagementContent(List<NfcTag> nfcTags) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Tags'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Register NFC tags to dismiss alarms securely. Place tags in locations that require you to get up, like your bathroom or kitchen.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // NFC tags list
          Expanded(
            child: nfcTags.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: nfcTags.length,
                    itemBuilder: (context, index) {
                      final tag = nfcTags[index];
                      return NfcTagCard(
                        tag: tag,
                        onEdit: () => _editNfcTag(tag),
                        onDelete: () => _deleteNfcTag(tag),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNfcTag,
        icon: const Icon(Icons.nfc),
        label: const Text('Add NFC Tag'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nfc,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No NFC tags registered',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first NFC tag to enable\nsecure alarm dismissal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNfcTag,
            icon: const Icon(Icons.nfc),
            label: const Text('Add NFC Tag'),
          ),
        ],
      ),
    );
  }

  void _addNfcTag() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddNfcTagScreen(),
      ),
    );
  }

  void _editNfcTag(NfcTag tag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNfcTagScreen(tag: tag),
      ),
    );
  }

  Future<void> _deleteNfcTag(NfcTag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete NFC Tag'),
        content: Text('Are you sure you want to delete "${tag.nickname}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NfcService.deleteNfcTag(tag.id);
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('NFC tag "${tag.nickname}" deleted')),
        );
      }
    }
  }
}
