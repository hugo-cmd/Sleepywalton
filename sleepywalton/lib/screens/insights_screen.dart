import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/sleep_chart.dart';
import '../widgets/stat_card.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _selectedPeriod = 7; // 7 days by default

  @override
  Widget build(BuildContext context) {
    final sleepLogs = StorageService.getSleepLogsInRange(
      DateTime.now().subtract(Duration(days: _selectedPeriod)),
      DateTime.now(),
    );
    
    final averageSleep = StorageService.getAverageSleepDuration(days: _selectedPeriod);
    final averageWakeLatency = StorageService.getAverageWakeLatency(days: _selectedPeriod);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Insights'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 7,
                child: Text('Last 7 days'),
              ),
              const PopupMenuItem(
                value: 14,
                child: Text('Last 14 days'),
              ),
              const PopupMenuItem(
                value: 30,
                child: Text('Last 30 days'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(),
            
            const SizedBox(height: 24),
            
            // Statistics cards
            _buildStatsCards(averageSleep, averageWakeLatency, sleepLogs),
            
            const SizedBox(height: 24),
            
            // Sleep duration chart
            _buildSleepChart(sleepLogs),
            
            const SizedBox(height: 24),
            
            // Recent sleep logs
            _buildRecentLogs(sleepLogs),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Text(
          'Showing last $_selectedPeriod days',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    _buildPeriodOption(7, 'Last 7 days'),
                    _buildPeriodOption(14, 'Last 14 days'),
                    _buildPeriodOption(30, 'Last 30 days'),
                  ],
                ),
              ),
            );
          },
          icon: const Icon(Icons.calendar_today),
        ),
      ],
    );
  }

  Widget _buildPeriodOption(int days, String label) {
    return ListTile(
      title: Text(label),
      leading: Radio<int>(
        value: days,
        groupValue: _selectedPeriod,
        onChanged: (value) {
          setState(() => _selectedPeriod = value!);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildStatsCards(Duration averageSleep, Duration averageWakeLatency, List<SleepLog> sleepLogs) {
    final completeLogs = sleepLogs.where((log) => log.isComplete).length;
    final totalLogs = sleepLogs.length;
    final completionRate = totalLogs > 0 ? (completeLogs / totalLogs * 100).round() : 0;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Avg Sleep',
                value: _formatDuration(averageSleep),
                icon: Icons.bedtime,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Wake Latency',
                value: _formatDuration(averageWakeLatency),
                icon: Icons.timer,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Completion Rate',
                value: '$completionRate%',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Total Logs',
                value: '$totalLogs',
                icon: Icons.analytics,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepChart(List<SleepLog> sleepLogs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Duration Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SleepChart(sleepLogs: sleepLogs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLogs(List<SleepLog> sleepLogs) {
    final recentLogs = sleepLogs.take(10).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Sleep Logs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            if (recentLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bedtime_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sleep data yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start using alarms to track your sleep patterns',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentLogs.map((log) => _buildLogItem(log)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(SleepLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(log.date),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                _getDayOfWeek(log.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Sleep data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (log.bedtime != null)
                  Text(
                    'Bedtime: ${_formatTime(log.bedtime!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (log.wakeTime != null)
                  Text(
                    'Wake: ${_formatTime(log.wakeTime!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (log.sleepDuration != null)
                  Text(
                    'Duration: ${log.sleepDurationText}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(log.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              log.status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Complete':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return 'N/A';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
