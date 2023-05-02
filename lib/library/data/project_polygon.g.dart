// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_polygon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectPolygonAdapter extends TypeAdapter<ProjectPolygon> {
  @override
  final int typeId = 19;

  @override
  ProjectPolygon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectPolygon(
      projectName: fields[0] as String?,
      projectPolygonId: fields[3] as String?,
      created: fields[2] as String?,
      positions: (fields[5] as List).cast<Position>(),
      nearestCities: (fields[6] as List).cast<City>(),
      organizationId: fields[4] as String?,
      name: fields[7] as String?,
      translatedMessage: fields[10] as String?,
      translatedTitle: fields[11] as String?,
      projectId: fields[1] as String?,
      userId: fields[8] as String?,
      userName: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectPolygon obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.projectName)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.created)
      ..writeByte(3)
      ..write(obj.projectPolygonId)
      ..writeByte(4)
      ..write(obj.organizationId)
      ..writeByte(5)
      ..write(obj.positions)
      ..writeByte(6)
      ..write(obj.nearestCities)
      ..writeByte(7)
      ..write(obj.name)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.userName)
      ..writeByte(10)
      ..write(obj.translatedMessage)
      ..writeByte(11)
      ..write(obj.translatedTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectPolygonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
