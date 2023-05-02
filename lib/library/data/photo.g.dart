// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final int typeId = 4;

  @override
  Photo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Photo(
      url: fields[0] as String?,
      caption: fields[2] as String?,
      created: fields[3] as String?,
      userId: fields[6] as String?,
      userName: fields[8] as String?,
      projectPosition: fields[9] as Position?,
      distanceFromProjectPosition: fields[10] as double?,
      projectId: fields[11] as String?,
      thumbnailUrl: fields[1] as String?,
      photoId: fields[4] as String?,
      organizationId: fields[7] as String?,
      projectName: fields[12] as String?,
      height: fields[13] as int?,
      translatedMessage: fields[18] as String?,
      translatedTitle: fields[19] as String?,
      projectPositionId: fields[5] as String?,
      projectPolygonId: fields[16] as String?,
      width: fields[14] as int?,
      userUrl: fields[17] as String?,
      landscape: fields[15] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.thumbnailUrl)
      ..writeByte(2)
      ..write(obj.caption)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.photoId)
      ..writeByte(5)
      ..write(obj.projectPositionId)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.organizationId)
      ..writeByte(8)
      ..write(obj.userName)
      ..writeByte(9)
      ..write(obj.projectPosition)
      ..writeByte(10)
      ..write(obj.distanceFromProjectPosition)
      ..writeByte(11)
      ..write(obj.projectId)
      ..writeByte(12)
      ..write(obj.projectName)
      ..writeByte(13)
      ..write(obj.height)
      ..writeByte(14)
      ..write(obj.width)
      ..writeByte(15)
      ..write(obj.landscape)
      ..writeByte(16)
      ..write(obj.projectPolygonId)
      ..writeByte(17)
      ..write(obj.userUrl)
      ..writeByte(18)
      ..write(obj.translatedMessage)
      ..writeByte(19)
      ..write(obj.translatedTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
