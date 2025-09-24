import 'package:hive/hive.dart';

part 'nfc_tag.g.dart';

@HiveType(typeId: 2)
class NfcTag extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nickname;

  @HiveField(2)
  String nfcId; // The actual NFC tag identifier

  @HiveField(3)
  NfcTagType type;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime lastUsed;

  @HiveField(6)
  int usageCount;

  NfcTag({
    required this.id,
    required this.nickname,
    required this.nfcId,
    required this.type,
    required this.createdAt,
    required this.lastUsed,
    this.usageCount = 0,
  });

  NfcTag copyWith({
    String? id,
    String? nickname,
    String? nfcId,
    NfcTagType? type,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
  }) {
    return NfcTag(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      nfcId: nfcId ?? this.nfcId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  void markAsUsed() {
    lastUsed = DateTime.now();
    usageCount++;
    save();
  }

  String get displayName {
    if (nickname.isNotEmpty) return nickname;
    return 'NFC Tag ${nfcId.substring(0, 8)}...';
  }

  String get icon {
    switch (type) {
      case NfcTagType.wakeUp:
        return '🌅';
      case NfcTagType.sleep:
        return '😴';
      case NfcTagType.custom:
        return '🏷️';
    }
  }
}

@HiveType(typeId: 3)
enum NfcTagType {
  @HiveField(0)
  wakeUp,
  
  @HiveField(1)
  sleep,
  
  @HiveField(2)
  custom,
}
