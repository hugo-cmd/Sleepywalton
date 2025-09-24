import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class StorageService {
  static const String _alarmsBoxName = 'alarms';
  static const String _nfcTagsBoxName = 'nfc_tags';
  static const String _sleepLogsBoxName = 'sleep_logs';
  static const String _settingsBoxName = 'settings';

  static late Box<Alarm> _alarmsBox;
  static late Box<NfcTag> _nfcTagsBox;
  static late Box<SleepLog> _sleepLogsBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(AlarmAdapter());
    Hive.registerAdapter(DismissalMethodAdapter());
    Hive.registerAdapter(NfcTagAdapter());
    Hive.registerAdapter(NfcTagTypeAdapter());
    Hive.registerAdapter(SleepLogAdapter());

    // Open boxes
    _alarmsBox = await Hive.openBox<Alarm>(_alarmsBoxName);
    _nfcTagsBox = await Hive.openBox<NfcTag>(_nfcTagsBoxName);
    _sleepLogsBox = await Hive.openBox<SleepLog>(_sleepLogsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Alarm operations
  static List<Alarm> getAllAlarms() {
    return _alarmsBox.values.toList();
  }

  static Alarm? getAlarm(String id) {
    return _alarmsBox.get(id);
  }

  static Future<void> saveAlarm(Alarm alarm) async {
    await _alarmsBox.put(alarm.id, alarm);
  }

  static Future<void> deleteAlarm(String id) async {
    await _alarmsBox.delete(id);
  }

  static List<Alarm> getEnabledAlarms() {
    return _alarmsBox.values.where((alarm) => alarm.isEnabled).toList();
  }

  // NFC Tag operations
  static List<NfcTag> getAllNfcTags() {
    return _nfcTagsBox.values.toList();
  }

  static NfcTag? getNfcTag(String id) {
    return _nfcTagsBox.get(id);
  }

  static NfcTag? getNfcTagByNfcId(String nfcId) {
    try {
      return _nfcTagsBox.values.firstWhere(
        (tag) => tag.nfcId == nfcId,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveNfcTag(NfcTag tag) async {
    await _nfcTagsBox.put(tag.id, tag);
  }

  static Future<void> deleteNfcTag(String id) async {
    await _nfcTagsBox.delete(id);
  }

  static List<NfcTag> getNfcTagsByType(NfcTagType type) {
    return _nfcTagsBox.values.where((tag) => tag.type == type).toList();
  }

  // Sleep Log operations
  static List<SleepLog> getAllSleepLogs() {
    return _sleepLogsBox.values.toList();
  }

  static SleepLog? getSleepLog(String id) {
    return _sleepLogsBox.get(id);
  }

  static SleepLog? getSleepLogByDate(DateTime date) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return _sleepLogsBox.values.firstWhere(
        (log) => log.date.toIso8601String().startsWith(dateString),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveSleepLog(SleepLog log) async {
    await _sleepLogsBox.put(log.id, log);
  }

  static Future<void> deleteSleepLog(String id) async {
    await _sleepLogsBox.delete(id);
  }

  static List<SleepLog> getSleepLogsInRange(DateTime startDate, DateTime endDate) {
    return _sleepLogsBox.values.where((log) {
      return log.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             log.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Settings operations
  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  static Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  static Future<void> removeSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // Statistics
  static Duration getAverageSleepDuration({int days = 7}) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final logs = getSleepLogsInRange(startDate, endDate);
    
    final completeLogs = logs.where((log) => log.isComplete).toList();
    if (completeLogs.isEmpty) return Duration.zero;
    
    final totalMinutes = completeLogs
        .map((log) => log.sleepDuration?.inMinutes ?? 0)
        .reduce((a, b) => a + b);
    
    return Duration(minutes: totalMinutes ~/ completeLogs.length);
  }

  static Duration getAverageWakeLatency({int days = 7}) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final logs = getSleepLogsInRange(startDate, endDate);
    
    final logsWithLatency = logs.where((log) => log.wakeLatencySeconds != null).toList();
    if (logsWithLatency.isEmpty) return Duration.zero;
    
    final totalSeconds = logsWithLatency
        .map((log) => log.wakeLatencySeconds!)
        .reduce((a, b) => a + b);
    
    return Duration(seconds: totalSeconds ~/ logsWithLatency.length);
  }

  static void close() {
    _alarmsBox.close();
    _nfcTagsBox.close();
    _sleepLogsBox.close();
    _settingsBox.close();
  }
}
