// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_packed.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HourlyPackedAdapter extends TypeAdapter<HourlyPacked> {
  @override
  final int typeId = 41;

  @override
  HourlyPacked read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourlyPacked(
      temperature: fields[0] as double?,
      rain: fields[2] as double?,
      time: fields[3] as String?,
      surfacePressure: fields[6] as double?,
      cloudCover: fields[7] as int?,
      windSpeed: fields[8] as double?,
      relativeHumidity: fields[1] as int?,
      showers: fields[4] as double?,
      pressure: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, HourlyPacked obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.relativeHumidity)
      ..writeByte(2)
      ..write(obj.rain)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.showers)
      ..writeByte(5)
      ..write(obj.pressure)
      ..writeByte(6)
      ..write(obj.surfacePressure)
      ..writeByte(7)
      ..write(obj.cloudCover)
      ..writeByte(8)
      ..write(obj.windSpeed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyPackedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
