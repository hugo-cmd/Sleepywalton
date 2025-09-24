import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/alarm_card.dart';
import 'set_alarm_screen.dart';
import 'nfc_management_screen.dart';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> {
  @override
  Widget build(BuildContext context) {
    final alarms = StorageService.getAllAlarms();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              // TODO: Navigate to insights dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insights coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.nfc),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NfcManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current time display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _getCurrentTime(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  _getCurrentDate(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Alarms list
          Expanded(
            child: alarms.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = alarms[index];
                      return AlarmCard(
                        alarm: alarm,
                        onToggle: (isEnabled) => _toggleAlarm(alarm, isEnabled),
                        onEdit: () => _editAlarm(alarm),
                        onDelete: () => _deleteAlarm(alarm),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No alarms set',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first alarm',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _addAlarm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SetAlarmScreen(),
      ),
    );
  }

  void _editAlarm(Alarm alarm) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SetAlarmScreen(alarm: alarm),
      ),
    );
  }

  Future<void> _toggleAlarm(Alarm alarm, bool isEnabled) async {
    final updatedAlarm = alarm.copyWith(
      isEnabled: isEnabled,
      updatedAt: DateTime.now(),
    );
    
    await StorageService.saveAlarm(updatedAlarm);
    
    if (isEnabled) {
      await AlarmService.scheduleAlarm(updatedAlarm);
    } else {
      await AlarmService.cancelAlarm(alarm.id);
    }
    
    setState(() {});
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text('Are you sure you want to delete "${alarm.name}"?'),
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
      await AlarmService.cancelAlarm(alarm.id);
      await StorageService.deleteAlarm(alarm.id);
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm "${alarm.name}" deleted')),
        );
      }
    }
  }
}
