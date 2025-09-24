// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmAdapter extends TypeAdapter<Alarm> {
  @override
  final int typeId = 0;

  @override
  Alarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alarm(
      id: fields[0] as String,
      name: fields[1] as String,
      hour: fields[2] as int,
      minute: fields[3] as int,
      isEnabled: fields[4] as bool,
      repeatDays: (fields[5] as List).cast<int>(),
      soundPath: fields[6] as String,
      isVibrationEnabled: fields[7] as bool,
      dismissalMethod: fields[8] as DismissalMethod,
      nfcTagId: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Alarm obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.minute)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.repeatDays)
      ..writeByte(6)
      ..write(obj.soundPath)
      ..writeByte(7)
      ..write(obj.isVibrationEnabled)
      ..writeByte(8)
      ..write(obj.dismissalMethod)
      ..writeByte(9)
      ..write(obj.nfcTagId)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DismissalMethodAdapter extends TypeAdapter<DismissalMethod> {
  @override
  final int typeId = 1;

  @override
  DismissalMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DismissalMethod.standard;
      case 1:
        return DismissalMethod.nfc;
      default:
        return DismissalMethod.standard;
    }
  }

  @override
  void write(BinaryWriter writer, DismissalMethod obj) {
    switch (obj) {
      case DismissalMethod.standard:
        writer.writeByte(0);
        break;
      case DismissalMethod.nfc:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissalMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
