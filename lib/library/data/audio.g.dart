// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioAdapter extends TypeAdapter<Audio> {
  @override
  final int typeId = 23;

  @override
  Audio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Audio(
      url: fields[0] as String?,
      caption: fields[1] as String?,
      projectPositionId: fields[4] as String?,
      projectPolygonId: fields[12] as String?,
      created: fields[2] as String?,
      userId: fields[5] as String?,
      userName: fields[6] as String?,
      projectPosition: fields[8] as Position?,
      distanceFromProjectPosition: fields[9] as double?,
      projectId: fields[10] as String?,
      audioId: fields[3] as String?,
      durationInSeconds: fields[13] as int?,
      organizationId: fields[7] as String?,
      translatedMessage: fields[15] as String?,
      translatedTitle: fields[16] as String?,
      userUrl: fields[14] as String?,
      projectName: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Audio obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.caption)
      ..writeByte(2)
      ..write(obj.created)
      ..writeByte(3)
      ..write(obj.audioId)
      ..writeByte(4)
      ..write(obj.projectPositionId)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.organizationId)
      ..writeByte(8)
      ..write(obj.projectPosition)
      ..writeByte(9)
      ..write(obj.distanceFromProjectPosition)
      ..writeByte(10)
      ..write(obj.projectId)
      ..writeByte(11)
      ..write(obj.projectName)
      ..writeByte(12)
      ..write(obj.projectPolygonId)
      ..writeByte(13)
      ..write(obj.durationInSeconds)
      ..writeByte(14)
      ..write(obj.userUrl)
      ..writeByte(15)
      ..write(obj.translatedMessage)
      ..writeByte(16)
      ..write(obj.translatedTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
