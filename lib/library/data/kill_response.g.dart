// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kill_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KillResponseAdapter extends TypeAdapter<KillResponse> {
  @override
  final int typeId = 25;

  @override
  KillResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KillResponse(
      message: fields[1] as String?,
      organizationId: fields[2] as String?,
      date: fields[3] as String?,
      user: fields[4] as User?,
      killer: fields[0] as User?,
    );
  }

  @override
  void write(BinaryWriter writer, KillResponse obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.killer)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.organizationId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KillResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
