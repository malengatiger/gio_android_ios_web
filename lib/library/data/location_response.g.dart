// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationResponseAdapter extends TypeAdapter<LocationResponse> {
  @override
  final int typeId = 27;

  @override
  LocationResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationResponse(
      position: fields[6] as Position?,
      date: fields[0] as String?,
      userId: fields[1] as String?,
      userName: fields[3] as String?,
      locationResponseId: fields[4] as String?,
      organizationId: fields[2] as String?,
      organizationName: fields[5] as String?,
      requesterId: fields[7] as String?,
      translatedMessage: fields[9] as String?,
      translatedTitle: fields[10] as String?,
      requesterName: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationResponse obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.organizationId)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.locationResponseId)
      ..writeByte(5)
      ..write(obj.organizationName)
      ..writeByte(6)
      ..write(obj.position)
      ..writeByte(7)
      ..write(obj.requesterId)
      ..writeByte(8)
      ..write(obj.requesterName)
      ..writeByte(9)
      ..write(obj.translatedMessage)
      ..writeByte(10)
      ..write(obj.translatedTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
