// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failed_audio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FailedAudioAdapter extends TypeAdapter<FailedAudio> {
  @override
  final int typeId = 24;

  @override
  FailedAudio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FailedAudio(
      filePath: fields[0] as String?,
      projectPositionId: fields[2] as String?,
      project: fields[1] as Project?,
      projectPosition: fields[4] as Position?,
      audio: fields[6] as Audio?,
      projectPolygonId: fields[3] as String?,
      date: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FailedAudio obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.project)
      ..writeByte(2)
      ..write(obj.projectPositionId)
      ..writeByte(3)
      ..write(obj.projectPolygonId)
      ..writeByte(4)
      ..write(obj.projectPosition)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.audio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailedAudioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
