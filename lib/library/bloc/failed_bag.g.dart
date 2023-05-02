// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failed_bag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FailedBagAdapter extends TypeAdapter<FailedBag> {
  @override
  final int typeId = 20;

  @override
  FailedBag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FailedBag(
      filePath: fields[0] as String?,
      thumbnailPath: fields[1] as String?,
      projectPositionId: fields[3] as String?,
      projectPolygonId: fields[4] as String?,
      project: fields[2] as Project?,
      projectPosition: fields[5] as Position?,
      photo: fields[7] as Photo?,
      video: fields[8] as Video?,
      date: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FailedBag obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.projectPosition)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.photo)
      ..writeByte(8)
      ..write(obj.video);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailedBagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
