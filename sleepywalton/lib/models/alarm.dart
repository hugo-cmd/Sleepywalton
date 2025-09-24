import 'package:hive/hive.dart';

part 'alarm.g.dart';

@HiveType(typeId: 0)
class Alarm extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int hour;

  @HiveField(3)
  int minute;

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  List<int> repeatDays; // 0 = Sunday, 1 = Monday, etc.

  @HiveField(6)
  String soundPath;

  @HiveField(7)
  bool isVibrationEnabled;

  @HiveField(8)
  DismissalMethod dismissalMethod;

  @HiveField(9)
  String? nfcTagId; // null for standard dismissal

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  Alarm({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.repeatDays = const [],
    this.soundPath = 'default',
    this.isVibrationEnabled = true,
    this.dismissalMethod = DismissalMethod.standard,
    this.nfcTagId,
    required this.createdAt,
    required this.updatedAt,
  });

  Alarm copyWith({
    String? id,
    String? name,
    int? hour,
    int? minute,
    bool? isEnabled,
    List<int>? repeatDays,
    String? soundPath,
    bool? isVibrationEnabled,
    DismissalMethod? dismissalMethod,
    String? nfcTagId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      name: name ?? this.name,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      soundPath: soundPath ?? this.soundPath,
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      dismissalMethod: dismissalMethod ?? this.dismissalMethod,
      nfcTagId: nfcTagId ?? this.nfcTagId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime get nextAlarmTime {
    final now = DateTime.now();
    var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If alarm time has passed today, move to next occurrence
    if (alarmTime.isBefore(now)) {
      if (repeatDays.isEmpty) {
        // One-time alarm, move to tomorrow
        alarmTime = alarmTime.add(const Duration(days: 1));
      } else {
        // Repeating alarm, find next occurrence
        alarmTime = _getNextRepeatingAlarm(now);
      }
    }
    
    return alarmTime;
  }

  DateTime _getNextRepeatingAlarm(DateTime now) {
    var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // Check next 7 days for the next occurrence
    for (int i = 0; i < 7; i++) {
      final checkDate = alarmTime.add(Duration(days: i));
      if (repeatDays.contains(checkDate.weekday % 7)) {
        return checkDate;
      }
    }
    
    // Fallback to tomorrow
    return alarmTime.add(const Duration(days: 1));
  }

  bool get isRepeating => repeatDays.isNotEmpty;

  String get repeatDaysText {
    if (repeatDays.isEmpty) return 'Once';
    
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDays = repeatDays.map((day) => dayNames[day]).toList();
    
    if (selectedDays.length == 7) return 'Every day';
    if (selectedDays.length == 5 && 
        !selectedDays.contains('Sun') && 
        !selectedDays.contains('Sat')) {
      return 'Weekdays';
    }
    if (selectedDays.length == 2 && 
        selectedDays.contains('Sun') && 
        selectedDays.contains('Sat')) {
      return 'Weekends';
    }
    
    return selectedDays.join(', ');
  }
}

@HiveType(typeId: 1)
enum DismissalMethod {
  @HiveField(0)
  standard,
  
  @HiveField(1)
  nfc,
}
