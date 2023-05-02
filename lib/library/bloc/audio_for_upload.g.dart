// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_for_upload.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioForUploadAdapter extends TypeAdapter<AudioForUpload> {
  @override
  final int typeId = 35;

  @override
  AudioForUpload read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioForUpload(
      filePath: fields[0] as String?,
      project: fields[2] as Project?,
      position: fields[5] as Position?,
      audioId: fields[7] as String?,
      userId: fields[8] as String?,
      userName: fields[9] as String?,
      userThumbnailUrl: fields[11] as String?,
      organizationId: fields[10] as String?,
      durationInSeconds: fields[12] as int?,
      fileBytes: fields[13] as Uint8List?,
      date: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AudioForUpload obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.project)
      ..writeByte(5)
      ..write(obj.position)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.audioId)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.userName)
      ..writeByte(10)
      ..write(obj.organizationId)
      ..writeByte(11)
      ..write(obj.userThumbnailUrl)
      ..writeByte(12)
      ..write(obj.durationInSeconds)
      ..writeByte(13)
      ..write(obj.fileBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioForUploadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
