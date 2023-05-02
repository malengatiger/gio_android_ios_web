// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_forecast.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HourlyForecastAdapter extends TypeAdapter<HourlyForecast> {
  @override
  final int typeId = 52;

  @override
  HourlyForecast read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourlyForecast(
      hourlyUnits: fields[0] as HourlyUnits?,
      time: fields[1] as String?,
      temperature: fields[2] as double?,
      relativeHumidity: fields[3] as int?,
      rain: fields[4] as double?,
      showers: fields[5] as double?,
      pressure: fields[6] as double?,
      surfacePressure: fields[7] as double?,
      cloudCover: fields[8] as int?,
      windSpeed: fields[9] as double?,
      projectPositionId: fields[10] as String?,
      date: fields[13] as String?,
      projectId: fields[11] as String?,
      projectName: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HourlyForecast obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.hourlyUnits)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.temperature)
      ..writeByte(3)
      ..write(obj.relativeHumidity)
      ..writeByte(4)
      ..write(obj.rain)
      ..writeByte(5)
      ..write(obj.showers)
      ..writeByte(6)
      ..write(obj.pressure)
      ..writeByte(7)
      ..write(obj.surfacePressure)
      ..writeByte(8)
      ..write(obj.cloudCover)
      ..writeByte(9)
      ..write(obj.windSpeed)
      ..writeByte(10)
      ..write(obj.projectPositionId)
      ..writeByte(11)
      ..write(obj.projectId)
      ..writeByte(12)
      ..write(obj.projectName)
      ..writeByte(13)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyForecastAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
