// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RatingAdapter extends TypeAdapter<Rating> {
  @override
  final int typeId = 26;

  @override
  Rating read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rating(
      remarks: fields[0] as String?,
      photoId: fields[4] as String?,
      videoId: fields[11] as String?,
      created: fields[2] as String?,
      userId: fields[5] as String?,
      userName: fields[6] as String?,
      ratingCode: fields[8] as int?,
      projectId: fields[9] as String?,
      audioId: fields[3] as String?,
      position: fields[13] as Position?,
      ratingId: fields[12] as String?,
      organizationId: fields[7] as String?,
      projectName: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Rating obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.remarks)
      ..writeByte(2)
      ..write(obj.created)
      ..writeByte(3)
      ..write(obj.audioId)
      ..writeByte(4)
      ..write(obj.photoId)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.organizationId)
      ..writeByte(8)
      ..write(obj.ratingCode)
      ..writeByte(9)
      ..write(obj.projectId)
      ..writeByte(10)
      ..write(obj.projectName)
      ..writeByte(11)
      ..write(obj.videoId)
      ..writeByte(12)
      ..write(obj.ratingId)
      ..writeByte(13)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
