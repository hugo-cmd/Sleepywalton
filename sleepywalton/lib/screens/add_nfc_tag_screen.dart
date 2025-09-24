import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

class AddNfcTagScreen extends ConsumerStatefulWidget {
  final NfcTag? tag;

  const AddNfcTagScreen({super.key, this.tag});

  @override
  ConsumerState<AddNfcTagScreen> createState() => _AddNfcTagScreenState();
}

class _AddNfcTagScreenState extends ConsumerState<AddNfcTagScreen> {
  late TextEditingController _nicknameController;
  late NfcTagType _selectedType;
  bool _isScanning = false;
  String? _detectedNfcId;
  String? _errorMessage;

  bool get _isEditing => widget.tag != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      final tag = widget.tag!;
      _nicknameController = TextEditingController(text: tag.nickname);
      _selectedType = tag.type;
      _detectedNfcId = tag.nfcId;
    } else {
      _nicknameController = TextEditingController();
      _selectedType = NfcTagType.wakeUp;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit NFC Tag' : 'Add NFC Tag'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nickname input
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Tag Nickname',
                hintText: 'e.g., Kitchen Sink, Bathroom Mirror',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 24),
            
            // Tag type selection
            _buildTypeSelector(),
            
            const SizedBox(height: 24),
            
            // NFC scanning section
            if (!_isEditing) _buildScanningSection(),
            
            if (_isEditing) _buildEditInfo(),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSave() ? _saveTag : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'Update Tag' : 'Save Tag',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tag Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildTypeOption(
              NfcTagType.wakeUp,
              'Wake Up Tag',
              'Use this tag to dismiss wake-up alarms',
              '🌅',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildTypeOption(
              NfcTagType.sleep,
              'Sleep Tag',
              'Use this tag to log when you go to sleep',
              '😴',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildTypeOption(
              NfcTagType.custom,
              'Custom Tag',
              'General purpose tag for any use',
              '🏷️',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    NfcTagType type,
    String title,
    String subtitle,
    String emoji,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
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
                color: color,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.nfc,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'NFC Tag Detection',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_detectedNfcId == null && !_isScanning) ...[
              Text(
                'Tap the button below and hold your NFC tag near the back of your device.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startScanning,
                  icon: const Icon(Icons.nfc),
                  label: const Text('Scan NFC Tag'),
                ),
              ),
            ],
            
            if (_isScanning) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Hold your NFC tag near the device...'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _stopScanning,
                  child: const Text('Cancel'),
                ),
              ),
            ],
            
            if (_detectedNfcId != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NFC Tag Detected!',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'ID: ${_detectedNfcId!.substring(0, 8)}...',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _startScanning,
                      child: const Text('Rescan'),
                    ),
                  ],
                ),
              ),
            ],
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tag Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('NFC ID', '${widget.tag!.nfcId.substring(0, 8)}...'),
            _buildInfoRow('Created', _formatDate(widget.tag!.createdAt)),
            _buildInfoRow('Last Used', _formatDate(widget.tag!.lastUsed)),
            _buildInfoRow('Usage Count', '${widget.tag!.usageCount} times'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _canSave() {
    if (_nicknameController.text.trim().isEmpty) return false;
    if (!_isEditing && _detectedNfcId == null) return false;
    return true;
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final tag = await NfcService.registerNfcTag(
        nickname: _nicknameController.text.trim().isNotEmpty 
            ? _nicknameController.text.trim() 
            : 'New Tag',
        type: _selectedType,
        onTagDetected: (nfcId) {
          setState(() {
            _detectedNfcId = nfcId;
            _isScanning = false;
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = error;
            _isScanning = false;
          });
        },
      );

      if (tag != null) {
        setState(() {
          _detectedNfcId = tag.nfcId;
          _isScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isScanning = false;
      });
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    NfcService.stopTagSession();
  }

  Future<void> _saveTag() async {
    if (!_canSave()) return;

    final now = DateTime.now();
    
    if (_isEditing) {
      final updatedTag = widget.tag!.copyWith(
        nickname: _nicknameController.text.trim(),
        type: _selectedType,
      );
      await StorageService.saveNfcTag(updatedTag);
    } else {
      final newTag = NfcTag(
        id: '${now.millisecondsSinceEpoch}',
        nickname: _nicknameController.text.trim(),
        nfcId: _detectedNfcId!,
        type: _selectedType,
        createdAt: now,
        lastUsed: now,
      );
      await StorageService.saveNfcTag(newTag);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'NFC tag updated' : 'NFC tag added')),
      );
    }
  }
}
