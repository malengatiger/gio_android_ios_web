// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_mark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaceMarkAdapter extends TypeAdapter<PlaceMark> {
  @override
  final int typeId = 17;

  @override
  PlaceMark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaceMark(
      administrativeArea: fields[0] as String?,
      subAdministrativeArea: fields[1] as String?,
      subLocality: fields[3] as String?,
      locality: fields[2] as String?,
      name: fields[6] as String?,
      subThoroughfare: fields[5] as String?,
      street: fields[7] as String?,
      country: fields[8] as String?,
      isoCountryCode: fields[9] as String?,
      postalCode: fields[10] as String?,
      thoroughfare: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlaceMark obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.administrativeArea)
      ..writeByte(1)
      ..write(obj.subAdministrativeArea)
      ..writeByte(2)
      ..write(obj.locality)
      ..writeByte(3)
      ..write(obj.subLocality)
      ..writeByte(4)
      ..write(obj.thoroughfare)
      ..writeByte(5)
      ..write(obj.subThoroughfare)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.street)
      ..writeByte(8)
      ..write(obj.country)
      ..writeByte(9)
      ..write(obj.isoCountryCode)
      ..writeByte(10)
      ..write(obj.postalCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceMarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
