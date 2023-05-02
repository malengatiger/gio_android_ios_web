// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_for_upload.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoForUploadAdapter extends TypeAdapter<PhotoForUpload> {
  @override
  final int typeId = 33;

  @override
  PhotoForUpload read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoForUpload(
      filePath: fields[0] as String?,
      thumbnailPath: fields[1] as String?,
      projectPositionId: fields[3] as String?,
      projectPolygonId: fields[4] as String?,
      project: fields[2] as Project?,
      position: fields[5] as Position?,
      photoId: fields[7] as String?,
      date: fields[6] as String?,
      userId: fields[8] as String?,
      userName: fields[9] as String?,
      fileBytes: fields[13] as Uint8List?,
      thumbnailBytes: fields[12] as Uint8List?,
      userThumbnailUrl: fields[11] as String?,
      organizationId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PhotoForUpload obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.thumbnailPath)
      ..writeByte(2)
      ..write(obj.project)
      ..writeByte(3)
      ..write(obj.projectPositionId)
      ..writeByte(4)
      ..write(obj.projectPolygonId)
      ..writeByte(5)
      ..write(obj.position)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.photoId)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.userName)
      ..writeByte(10)
      ..write(obj.organizationId)
      ..writeByte(11)
      ..write(obj.userThumbnailUrl)
      ..writeByte(12)
      ..write(obj.thumbnailBytes)
      ..writeByte(13)
      ..write(obj.fileBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoForUploadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
