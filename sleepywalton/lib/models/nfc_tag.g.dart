// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfc_tag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NfcTagAdapter extends TypeAdapter<NfcTag> {
  @override
  final int typeId = 2;

  @override
  NfcTag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NfcTag(
      id: fields[0] as String,
      nickname: fields[1] as String,
      nfcId: fields[2] as String,
      type: fields[3] as NfcTagType,
      createdAt: fields[4] as DateTime,
      lastUsed: fields[5] as DateTime,
      usageCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NfcTag obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.nfcId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastUsed)
      ..writeByte(6)
      ..write(obj.usageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NfcTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NfcTagTypeAdapter extends TypeAdapter<NfcTagType> {
  @override
  final int typeId = 3;

  @override
  NfcTagType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NfcTagType.wakeUp;
      case 1:
        return NfcTagType.sleep;
      case 2:
        return NfcTagType.custom;
      default:
        return NfcTagType.wakeUp;
    }
  }

  @override
  void write(BinaryWriter writer, NfcTagType obj) {
    switch (obj) {
      case NfcTagType.wakeUp:
        writer.writeByte(0);
        break;
      case NfcTagType.sleep:
        writer.writeByte(1);
        break;
      case NfcTagType.custom:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NfcTagTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
