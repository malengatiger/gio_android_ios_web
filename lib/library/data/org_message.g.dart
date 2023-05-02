// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrgMessageAdapter extends TypeAdapter<OrgMessage> {
  @override
  final int typeId = 14;

  @override
  OrgMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrgMessage(
      name: fields[0] as String?,
      message: fields[2] as String?,
      userId: fields[1] as String?,
      orgMessageId: fields[11] as String?,
      created: fields[3] as String?,
      projectId: fields[5] as String?,
      projectName: fields[6] as String?,
      adminId: fields[7] as String?,
      adminName: fields[8] as String?,
      frequency: fields[9] as String?,
      organizationId: fields[4] as String?,
    )..result = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, OrgMessage obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.organizationId)
      ..writeByte(5)
      ..write(obj.projectId)
      ..writeByte(6)
      ..write(obj.projectName)
      ..writeByte(7)
      ..write(obj.adminId)
      ..writeByte(8)
      ..write(obj.adminName)
      ..writeByte(9)
      ..write(obj.frequency)
      ..writeByte(10)
      ..write(obj.result)
      ..writeByte(11)
      ..write(obj.orgMessageId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrgMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
