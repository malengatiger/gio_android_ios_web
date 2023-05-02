// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConditionAdapter extends TypeAdapter<Condition> {
  @override
  final int typeId = 12;

  @override
  Condition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Condition(
      url: fields[0] as String?,
      caption: fields[1] as String?,
      created: fields[2] as String?,
      conditionId: fields[3] as String?,
      userId: fields[5] as String?,
      userName: fields[6] as String?,
      projectPosition: fields[7] as Position?,
      rating: fields[8] as int?,
      projectPositionId: fields[4] as String?,
      projectId: fields[9] as String?,
      projectName: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Condition obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.caption)
      ..writeByte(2)
      ..write(obj.created)
      ..writeByte(3)
      ..write(obj.conditionId)
      ..writeByte(4)
      ..write(obj.projectPositionId)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.projectPosition)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.projectId)
      ..writeByte(10)
      ..write(obj.projectName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
