// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_forecast.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyForecastAdapter extends TypeAdapter<DailyForecast> {
  @override
  final int typeId = 50;

  @override
  DailyForecast read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyForecast(
      dailyUnits: fields[0] as DailyUnits?,
      time: fields[1] as String?,
      weatherCode: fields[2] as int?,
      minTemperature: fields[3] as double?,
      maxTemperature: fields[4] as double?,
      apparentMinTemp: fields[5] as double?,
      apparentMaxTemp: fields[6] as double?,
      sunrise: fields[7] as String?,
      sunset: fields[8] as String?,
      precipitationSum: fields[9] as double?,
      rainSum: fields[10] as double?,
      showersSum: fields[11] as double?,
      precipitationHours: fields[12] as double?,
      windSpeedMax: fields[13] as double?,
      windDirectionDominant: fields[14] as double?,
      shortwaveRadiation: fields[15] as double?,
      evapoTranspiration: fields[16] as double?,
      projectPositionId: fields[17] as String?,
      date: fields[18] as String?,
      projectId: fields[19] as String?,
      projectName: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyForecast obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.dailyUnits)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.weatherCode)
      ..writeByte(3)
      ..write(obj.minTemperature)
      ..writeByte(4)
      ..write(obj.maxTemperature)
      ..writeByte(5)
      ..write(obj.apparentMinTemp)
      ..writeByte(6)
      ..write(obj.apparentMaxTemp)
      ..writeByte(7)
      ..write(obj.sunrise)
      ..writeByte(8)
      ..write(obj.sunset)
      ..writeByte(9)
      ..write(obj.precipitationSum)
      ..writeByte(10)
      ..write(obj.rainSum)
      ..writeByte(11)
      ..write(obj.showersSum)
      ..writeByte(12)
      ..write(obj.precipitationHours)
      ..writeByte(13)
      ..write(obj.windSpeedMax)
      ..writeByte(14)
      ..write(obj.windDirectionDominant)
      ..writeByte(15)
      ..write(obj.shortwaveRadiation)
      ..writeByte(16)
      ..write(obj.evapoTranspiration)
      ..writeByte(17)
      ..write(obj.projectPositionId)
      ..writeByte(18)
      ..write(obj.date)
      ..writeByte(19)
      ..write(obj.projectId)
      ..writeByte(20)
      ..write(obj.projectName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyForecastAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
