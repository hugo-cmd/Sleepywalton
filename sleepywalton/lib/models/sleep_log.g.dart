// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepLogAdapter extends TypeAdapter<SleepLog> {
  @override
  final int typeId = 4;

  @override
  SleepLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      bedtime: fields[2] as DateTime?,
      wakeTime: fields[3] as DateTime?,
      nfcTagId: fields[4] as String?,
      wakeLatencySeconds: fields[5] as int?,
      dismissalMethod: fields[6] as DismissalMethod,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SleepLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.bedtime)
      ..writeByte(3)
      ..write(obj.wakeTime)
      ..writeByte(4)
      ..write(obj.nfcTagId)
      ..writeByte(5)
      ..write(obj.wakeLatencySeconds)
      ..writeByte(6)
      ..write(obj.dismissalMethod)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
