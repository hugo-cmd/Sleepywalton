import 'package:hive/hive.dart';
import 'alarm.dart';

part 'sleep_log.g.dart';

@HiveType(typeId: 4)
class SleepLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date; // The date this log represents (YYYY-MM-DD)

  @HiveField(2)
  DateTime? bedtime; // When user went to sleep

  @HiveField(3)
  DateTime? wakeTime; // When user woke up

  @HiveField(4)
  String? nfcTagId; // Which NFC tag was used for sleep/wake

  @HiveField(5)
  int? wakeLatencySeconds; // How long it took to dismiss alarm

  @HiveField(6)
  DismissalMethod dismissalMethod; // How the alarm was dismissed

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  SleepLog({
    required this.id,
    required this.date,
    this.bedtime,
    this.wakeTime,
    this.nfcTagId,
    this.wakeLatencySeconds,
    this.dismissalMethod = DismissalMethod.standard,
    required this.createdAt,
    required this.updatedAt,
  });

  SleepLog copyWith({
    String? id,
    DateTime? date,
    DateTime? bedtime,
    DateTime? wakeTime,
    String? nfcTagId,
    int? wakeLatencySeconds,
    DismissalMethod? dismissalMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepLog(
      id: id ?? this.id,
      date: date ?? this.date,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      nfcTagId: nfcTagId ?? this.nfcTagId,
      wakeLatencySeconds: wakeLatencySeconds ?? this.wakeLatencySeconds,
      dismissalMethod: dismissalMethod ?? this.dismissalMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Duration? get sleepDuration {
    if (bedtime == null || wakeTime == null) return null;
    
    final duration = wakeTime!.difference(bedtime!);
    return duration.isNegative ? null : duration;
  }

  String get sleepDurationText {
    final duration = sleepDuration;
    if (duration == null) return 'N/A';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get wakeLatencyText {
    if (wakeLatencySeconds == null) return 'N/A';
    
    final minutes = wakeLatencySeconds! ~/ 60;
    final seconds = wakeLatencySeconds! % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  bool get isComplete => bedtime != null && wakeTime != null;

  bool get isPartial => bedtime != null || wakeTime != null;

  String get status {
    if (isComplete) return 'Complete';
    if (isPartial) return 'Partial';
    return 'Empty';
  }
}

