// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 5;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      name: fields[0] as String?,
      description: fields[2] as String?,
      organizationId: fields[3] as String?,
      communities: (fields[11] as List?)?.cast<Community>(),
      nearestCities: (fields[6] as List?)?.cast<City>(),
      photos: (fields[8] as List?)?.cast<Photo>(),
      videos: (fields[9] as List?)?.cast<Video>(),
      ratings: (fields[10] as List?)?.cast<RatingContent>(),
      created: fields[4] as String?,
      projectPositions: (fields[7] as List?)?.cast<ProjectPosition>(),
      monitorReports: (fields[12] as List?)?.cast<MonitorReport>(),
      organizationName: fields[5] as String?,
      translatedMessage: fields[14] as String?,
      translatedTitle: fields[15] as String?,
      monitorMaxDistanceInMetres: fields[13] as double?,
      projectId: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.organizationId)
      ..writeByte(4)
      ..write(obj.created)
      ..writeByte(5)
      ..write(obj.organizationName)
      ..writeByte(6)
      ..write(obj.nearestCities)
      ..writeByte(7)
      ..write(obj.projectPositions)
      ..writeByte(8)
      ..write(obj.photos)
      ..writeByte(9)
      ..write(obj.videos)
      ..writeByte(10)
      ..write(obj.ratings)
      ..writeByte(11)
      ..write(obj.communities)
      ..writeByte(12)
      ..write(obj.monitorReports)
      ..writeByte(13)
      ..write(obj.monitorMaxDistanceInMetres)
      ..writeByte(14)
      ..write(obj.translatedMessage)
      ..writeByte(15)
      ..write(obj.translatedTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
