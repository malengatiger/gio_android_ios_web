// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitor_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonitorReportAdapter extends TypeAdapter<MonitorReport> {
  @override
  final int typeId = 9;

  @override
  MonitorReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonitorReport(
      projectId: fields[0] as String?,
      monitorReportId: fields[2] as String?,
      description: fields[4] as String?,
      created: fields[1] as String?,
      user: fields[7] as User?,
      photos: (fields[5] as List).cast<Photo>(),
      videos: (fields[6] as List).cast<Video>(),
      rating: fields[3] as Rating?,
      organizationId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MonitorReport obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.created)
      ..writeByte(2)
      ..write(obj.monitorReportId)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.photos)
      ..writeByte(6)
      ..write(obj.videos)
      ..writeByte(7)
      ..write(obj.user)
      ..writeByte(8)
      ..write(obj.organizationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonitorReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
