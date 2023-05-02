// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectSummaryAdapter extends TypeAdapter<ProjectSummary> {
  @override
  final int typeId = 65;

  @override
  ProjectSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectSummary(
      photos: fields[0] as int?,
      audios: fields[2] as int?,
      date: fields[3] as String?,
      calculatedHourly: fields[6] as int?,
      projectPositions: fields[8] as int?,
      projectPolygons: fields[9] as int?,
      projectId: fields[10] as String?,
      videos: fields[1] as int?,
      schedules: fields[4] as int?,
      organizationId: fields[5] as String?,
      projectName: fields[11] as String?,
      organizationName: fields[7] as String?,
      day: fields[12] as int?,
      hour: fields[13] as int?,
      startDate: fields[14] as String?,
      endDate: fields[15] as String?,
      batchId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectSummary obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.photos)
      ..writeByte(1)
      ..write(obj.videos)
      ..writeByte(2)
      ..write(obj.audios)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.schedules)
      ..writeByte(5)
      ..write(obj.organizationId)
      ..writeByte(6)
      ..write(obj.calculatedHourly)
      ..writeByte(7)
      ..write(obj.organizationName)
      ..writeByte(8)
      ..write(obj.projectPositions)
      ..writeByte(9)
      ..write(obj.projectPolygons)
      ..writeByte(10)
      ..write(obj.projectId)
      ..writeByte(11)
      ..write(obj.projectName)
      ..writeByte(12)
      ..write(obj.day)
      ..writeByte(13)
      ..write(obj.hour)
      ..writeByte(14)
      ..write(obj.startDate)
      ..writeByte(15)
      ..write(obj.endDate)
      ..writeByte(16)
      ..write(obj.batchId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
