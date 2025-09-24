import 'package:flutter/material.dart';

class RepeatSelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;

  const RepeatSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const List<String> _dayNames = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick selection buttons
          Row(
            children: [
              _buildQuickButton('Never', [], context),
              const SizedBox(width: 8),
              _buildQuickButton('Daily', [0, 1, 2, 3, 4, 5, 6], context),
              const SizedBox(width: 8),
              _buildQuickButton('Weekdays', [1, 2, 3, 4, 5], context),
              const SizedBox(width: 8),
              _buildQuickButton('Weekends', [0, 6], context),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Individual day toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final isSelected = selectedDays.contains(index);
              return GestureDetector(
                onTap: () => _toggleDay(index),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _dayNames[index],
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Display current selection
          if (selectedDays.isNotEmpty)
            Text(
              _getSelectionText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, List<int> days, BuildContext context) {
    final isSelected = _listsEqual(selectedDays, days);
    
    return GestureDetector(
      onTap: () => onChanged(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _toggleDay(int day) {
    final newDays = List<int>.from(selectedDays);
    if (newDays.contains(day)) {
      newDays.remove(day);
    } else {
      newDays.add(day);
    }
    newDays.sort();
    onChanged(newDays);
  }

  String _getSelectionText() {
    if (selectedDays.isEmpty) return 'No repeat';
    
    if (_listsEqual(selectedDays, [0, 1, 2, 3, 4, 5, 6])) {
      return 'Every day';
    }
    
    if (_listsEqual(selectedDays, [1, 2, 3, 4, 5])) {
      return 'Weekdays only';
    }
    
    if (_listsEqual(selectedDays, [0, 6])) {
      return 'Weekends only';
    }
    
    final selectedDayNames = selectedDays.map((day) => _dayNames[day]).toList();
    return selectedDayNames.join(', ');
  }

  bool _listsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
