// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationRequestAdapter extends TypeAdapter<LocationRequest> {
  @override
  final int typeId = 23;

  @override
  LocationRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationRequest(
      organizationId: fields[0] as String?,
      requesterId: fields[1] as String?,
      created: fields[2] as String?,
      requesterName: fields[3] as String?,
      userName: fields[5] as String?,
      userId: fields[4] as String?,
      translatedMessage: fields[7] as String?,
      translatedTitle: fields[8] as String?,
      organizationName: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationRequest obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.organizationId)
      ..writeByte(1)
      ..write(obj.requesterId)
      ..writeByte(2)
      ..write(obj.created)
      ..writeByte(3)
      ..write(obj.requesterName)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.userName)
      ..writeByte(6)
      ..write(obj.organizationName)
      ..writeByte(7)
      ..write(obj.translatedMessage)
      ..writeByte(8)
      ..write(obj.translatedTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
