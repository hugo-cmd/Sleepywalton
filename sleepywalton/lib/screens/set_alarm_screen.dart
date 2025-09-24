import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/repeat_selector.dart';
import '../widgets/dismissal_method_selector.dart';

class SetAlarmScreen extends ConsumerStatefulWidget {
  final Alarm? alarm;

  const SetAlarmScreen({super.key, this.alarm});

  @override
  ConsumerState<SetAlarmScreen> createState() => _SetAlarmScreenState();
}

class _SetAlarmScreenState extends ConsumerState<SetAlarmScreen> {
  late TextEditingController _nameController;
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;
  late DismissalMethod _dismissalMethod;
  late String? _selectedNfcTagId;
  late String _soundPath;
  late bool _isVibrationEnabled;

  bool get _isEditing => widget.alarm != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      final alarm = widget.alarm!;
      _nameController = TextEditingController(text: alarm.name);
      _selectedTime = TimeOfDay(hour: alarm.hour, minute: alarm.minute);
      _selectedDays = List.from(alarm.repeatDays);
      _dismissalMethod = alarm.dismissalMethod;
      _selectedNfcTagId = alarm.nfcTagId;
      _soundPath = alarm.soundPath;
      _isVibrationEnabled = alarm.isVibrationEnabled;
    } else {
      _nameController = TextEditingController(text: 'Alarm');
      _selectedTime = TimeOfDay.now();
      _selectedDays = [];
      _dismissalMethod = DismissalMethod.standard;
      _selectedNfcTagId = null;
      _soundPath = 'default';
      _isVibrationEnabled = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Alarm' : 'New Alarm'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteAlarm,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alarm name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Alarm Name',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            
            const SizedBox(height: 24),
            
            // Time picker
            _buildTimePicker(),
            
            const SizedBox(height: 24),
            
            // Repeat settings
            _buildRepeatSection(),
            
            const SizedBox(height: 24),
            
            // Dismissal method
            _buildDismissalMethodSection(),
            
            const SizedBox(height: 24),
            
            // Sound settings
            _buildSoundSection(),
            
            const SizedBox(height: 24),
            
            // Vibration toggle
            _buildVibrationSection(),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAlarm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'Update Alarm' : 'Create Alarm',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text('Time'),
        subtitle: Text(
          _selectedTime.format(context),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectTime,
      ),
    );
  }

  Widget _buildRepeatSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.repeat),
                SizedBox(width: 12),
                Text('Repeat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          RepeatSelector(
            selectedDays: _selectedDays,
            onChanged: (days) => setState(() => _selectedDays = days),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissalMethodSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.security),
                SizedBox(width: 12),
                Text('Dismissal Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          DismissalMethodSelector(
            selectedMethod: _dismissalMethod,
            selectedNfcTagId: _selectedNfcTagId,
            onMethodChanged: (method) => setState(() => _dismissalMethod = method),
            onNfcTagChanged: (tagId) => setState(() => _selectedNfcTagId = tagId),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.music_note),
        title: const Text('Sound'),
        subtitle: Text(_getSoundDisplayName()),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectSound,
      ),
    );
  }

  Widget _buildVibrationSection() {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.vibration),
        title: const Text('Vibration'),
        subtitle: const Text('Vibrate when alarm goes off'),
        value: _isVibrationEnabled,
        onChanged: (value) => setState(() => _isVibrationEnabled = value),
      ),
    );
  }

  String _getSoundDisplayName() {
    switch (_soundPath) {
      case 'default':
        return 'Default Alarm';
      case 'gentle':
        return 'Gentle Wake';
      case 'energetic':
        return 'Energetic';
      default:
        return 'Default Alarm';
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _selectSound() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Sound', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            _buildSoundOption('default', 'Default Alarm'),
            _buildSoundOption('gentle', 'Gentle Wake'),
            _buildSoundOption('energetic', 'Energetic'),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOption(String soundPath, String displayName) {
    return ListTile(
      title: Text(displayName),
      leading: Radio<String>(
        value: soundPath,
        groupValue: _soundPath,
        onChanged: (value) {
          setState(() => _soundPath = value!);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _saveAlarm() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an alarm name')),
      );
      return;
    }

    final now = DateTime.now();
    final alarm = Alarm(
      id: _isEditing ? widget.alarm!.id : '${now.millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      isEnabled: _isEditing ? widget.alarm!.isEnabled : true,
      repeatDays: _selectedDays,
      soundPath: _soundPath,
      isVibrationEnabled: _isVibrationEnabled,
      dismissalMethod: _dismissalMethod,
      nfcTagId: _dismissalMethod == DismissalMethod.nfc ? _selectedNfcTagId : null,
      createdAt: _isEditing ? widget.alarm!.createdAt : now,
      updatedAt: now,
    );

    await StorageService.saveAlarm(alarm);
    
    if (alarm.isEnabled) {
      await AlarmService.scheduleAlarm(alarm);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Alarm updated' : 'Alarm created')),
      );
    }
  }

  Future<void> _deleteAlarm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text('Are you sure you want to delete "${widget.alarm!.name}"?'),
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
      await AlarmService.cancelAlarm(widget.alarm!.id);
      await StorageService.deleteAlarm(widget.alarm!.id);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm "${widget.alarm!.name}" deleted')),
        );
      }
    }
  }
}
