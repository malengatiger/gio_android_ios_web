// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_units.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HourlyUnitsAdapter extends TypeAdapter<HourlyUnits> {
  @override
  final int typeId = 53;

  @override
  HourlyUnits read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourlyUnits(
      time: fields[0] as String?,
      temperature2m: fields[1] as String?,
      relativehumidity2m: fields[2] as String?,
      rain: fields[3] as String?,
      showers: fields[4] as String?,
      pressureMsl: fields[5] as String?,
      surfacePressure: fields[6] as String?,
      cloudcover: fields[7] as String?,
      cloudcoverLow: fields[8] as String?,
      cloudcoverMid: fields[9] as String?,
      cloudcoverHigh: fields[10] as String?,
      windspeed10m: fields[11] as String?,
      windspeed80m: fields[12] as String?,
      windspeed120m: fields[13] as String?,
      windspeed180m: fields[14] as String?,
      winddirection80m: fields[15] as String?,
      temperature80m: fields[16] as String?,
      temperature120m: fields[17] as String?,
      temperature180m: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HourlyUnits obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.temperature2m)
      ..writeByte(2)
      ..write(obj.relativehumidity2m)
      ..writeByte(3)
      ..write(obj.rain)
      ..writeByte(4)
      ..write(obj.showers)
      ..writeByte(5)
      ..write(obj.pressureMsl)
      ..writeByte(6)
      ..write(obj.surfacePressure)
      ..writeByte(7)
      ..write(obj.cloudcover)
      ..writeByte(8)
      ..write(obj.cloudcoverLow)
      ..writeByte(9)
      ..write(obj.cloudcoverMid)
      ..writeByte(10)
      ..write(obj.cloudcoverHigh)
      ..writeByte(11)
      ..write(obj.windspeed10m)
      ..writeByte(12)
      ..write(obj.windspeed80m)
      ..writeByte(13)
      ..write(obj.windspeed120m)
      ..writeByte(14)
      ..write(obj.windspeed180m)
      ..writeByte(15)
      ..write(obj.winddirection80m)
      ..writeByte(16)
      ..write(obj.temperature80m)
      ..writeByte(17)
      ..write(obj.temperature120m)
      ..writeByte(18)
      ..write(obj.temperature180m);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyUnitsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
