// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_monitor_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FieldMonitorScheduleAdapter extends TypeAdapter<FieldMonitorSchedule> {
  @override
  final int typeId = 2;

  @override
  FieldMonitorSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FieldMonitorSchedule(
      fieldMonitorId: fields[1] as String?,
      adminId: fields[2] as String?,
      projectId: fields[4] as String?,
      date: fields[6] as String?,
      fieldMonitorScheduleId: fields[0] as String?,
      perDay: fields[8] as int?,
      perWeek: fields[9] as int?,
      perMonth: fields[10] as int?,
      projectName: fields[5] as String?,
      organizationName: fields[7] as String?,
      userId: fields[11] as String?,
      organizationId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FieldMonitorSchedule obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.fieldMonitorScheduleId)
      ..writeByte(1)
      ..write(obj.fieldMonitorId)
      ..writeByte(2)
      ..write(obj.adminId)
      ..writeByte(3)
      ..write(obj.organizationId)
      ..writeByte(4)
      ..write(obj.projectId)
      ..writeByte(5)
      ..write(obj.projectName)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.organizationName)
      ..writeByte(8)
      ..write(obj.perDay)
      ..writeByte(9)
      ..write(obj.perWeek)
      ..writeByte(10)
      ..write(obj.perMonth)
      ..writeByte(11)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldMonitorScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
