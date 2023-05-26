// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_counts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataCountsAdapter extends TypeAdapter<DataCounts> {
  @override
  final int typeId = 70;

  @override
  DataCounts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataCounts(
      projectId: fields[0] as String?,
      users: fields[2] as int?,
      created: fields[3] as String?,
      userId: fields[5] as String?,
      videos: fields[7] as int?,
      audios: fields[9] as int?,
      projectPositions: fields[10] as int?,
      projects: fields[1] as int?,
      photos: fields[4] as String?,
      organizationId: fields[6] as String?,
      projectPolygons: fields[11] as int?,
      fieldMonitorSchedules: fields[12] as int?,
      activities: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DataCounts obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.projects)
      ..writeByte(2)
      ..write(obj.users)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.photos)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.organizationId)
      ..writeByte(7)
      ..write(obj.videos)
      ..writeByte(9)
      ..write(obj.audios)
      ..writeByte(10)
      ..write(obj.projectPositions)
      ..writeByte(11)
      ..write(obj.projectPolygons)
      ..writeByte(12)
      ..write(obj.fieldMonitorSchedules)
      ..writeByte(13)
      ..write(obj.activities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataCountsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
