// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_units.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyUnitsAdapter extends TypeAdapter<DailyUnits> {
  @override
  final int typeId = 51;

  @override
  DailyUnits read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyUnits(
      time: fields[0] as String?,
      weathercode: fields[1] as String?,
      temperature2mMax: fields[2] as String?,
      temperature2mMin: fields[3] as String?,
      apparentTemperatureMax: fields[4] as String?,
      apparentTemperatureMin: fields[5] as String?,
      sunrise: fields[6] as String?,
      sunset: fields[7] as String?,
      precipitationSum: fields[8] as String?,
      rainSum: fields[9] as String?,
      showersSum: fields[10] as String?,
      snowfallSum: fields[11] as String?,
      precipitationHours: fields[12] as String?,
      windspeed10mMax: fields[13] as String?,
      windgusts10mMax: fields[14] as String?,
      winddirection10mDominant: fields[15] as String?,
      shortwaveRadiationSum: fields[16] as String?,
      et0FaoEvapotranspiration: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyUnits obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.weathercode)
      ..writeByte(2)
      ..write(obj.temperature2mMax)
      ..writeByte(3)
      ..write(obj.temperature2mMin)
      ..writeByte(4)
      ..write(obj.apparentTemperatureMax)
      ..writeByte(5)
      ..write(obj.apparentTemperatureMin)
      ..writeByte(6)
      ..write(obj.sunrise)
      ..writeByte(7)
      ..write(obj.sunset)
      ..writeByte(8)
      ..write(obj.precipitationSum)
      ..writeByte(9)
      ..write(obj.rainSum)
      ..writeByte(10)
      ..write(obj.showersSum)
      ..writeByte(11)
      ..write(obj.snowfallSum)
      ..writeByte(12)
      ..write(obj.precipitationHours)
      ..writeByte(13)
      ..write(obj.windspeed10mMax)
      ..writeByte(14)
      ..write(obj.windgusts10mMax)
      ..writeByte(15)
      ..write(obj.winddirection10mDominant)
      ..writeByte(16)
      ..write(obj.shortwaveRadiationSum)
      ..writeByte(17)
      ..write(obj.et0FaoEvapotranspiration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyUnitsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
