// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_assignment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAssignmentAdapter extends TypeAdapter<ProjectAssignment> {
  @override
  final int typeId = 38;

  @override
  ProjectAssignment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectAssignment(
      updated: fields[0] as String?,
      date: fields[2] as String?,
      userId: fields[4] as String?,
      userName: fields[6] as String?,
      projectId: fields[7] as String?,
      active: fields[1] as int?,
      projectAssignmentId: fields[3] as String?,
      organizationId: fields[5] as String?,
      projectName: fields[8] as String?,
      adminId: fields[9] as String?,
      adminName: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectAssignment obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.updated)
      ..writeByte(1)
      ..write(obj.active)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.projectAssignmentId)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.organizationId)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.projectId)
      ..writeByte(8)
      ..write(obj.projectName)
      ..writeByte(9)
      ..write(obj.adminId)
      ..writeByte(10)
      ..write(obj.adminName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAssignmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
